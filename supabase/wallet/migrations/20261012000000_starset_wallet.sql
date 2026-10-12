-- Star Settlers (우주 개척단) gem wallet. The server is the only place gems are added or taken.
--
-- Where: the claires-ranch project (wthrfgiotkzjxmroljwt), not a project of its own. Owner decision 2026-10-12: the
-- mkideabox-games organization is on the free plan, which holds two active projects (mkideabox-games, claires-ranch),
-- and money must stay out of the shared leaderboard project. Every object here is starset_-prefixed and never touches
-- claire_ objects.
--
-- Rules
-- - The app calls four functions as anon: starset_wallet, starset_earn, starset_spend. Tables are locked (RLS on, no
--   policies, privileges revoked). There is no call that adds gems except starset_earn, and it only pays what the
--   rules below allow.
-- - Cash purchases are credited by the Edge Function starset-purchase-webhook (RevenueCat → service role).
-- - Every balance change carries a request id (p_ref): the same id twice returns the first answer and changes nothing,
--   so a lost response can be retried safely.
--
-- What starset_earn pays (the game itself is played on the device, so the server cannot check gameplay; it caps it):
--   ach    one achievement id, once per wallet, the amount from starset_achievement_gems (lib/game/profile.dart)
--   login  once per day, server-kept streak: 5,5,10,10,15,20,50 (lib/game/profile.dart loginRewards)
--   quest  a daily quest id (at most 3 a day) or 'bonus', once per day each, amounts from starset_quest_gems
--   ad     at most 3 a day, 5 each (Profile.adGemsPerDay / adGemAmount)
--   play   everything earned in play: pickups, supply capsules, missions, story goals, raids, the planet gift and the
--          merchant. Up to starset_play_cap() a UTC day; the rest is answered as not credited and the app sends it
--          again on a later day, so an honest player loses nothing and a forged amount gains at most the cap a day.
-- Days for login/quest/ad are the player's local date (yyyymmdd) so they match what the game shows. The server accepts
-- the UTC date -7 .. +1 (any time zone, and a week of offline play); each day is counted once.

create table public.starset_wallets (
  install_id   uuid primary key,
  gems         int not null default 0 check (gems >= 0),
  premium      boolean not null default false,
  starter      boolean not null default false,
  login_day    int,
  login_streak int not null default 0,
  purchases    int not null default 0,       -- credited purchases; the app watches it after paying
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table public.starset_ledger (
  id         bigserial primary key,
  install_id uuid not null references public.starset_wallets (install_id) on delete cascade,
  ref        text not null,
  kind       text not null,
  gems       int not null default 0,
  result     jsonb not null,
  at         timestamptz not null default now(),
  unique (install_id, ref)
);

-- per day and source: how many claims and gems, and which keys (quest ids) were taken
create table public.starset_earn_days (
  install_id uuid not null references public.starset_wallets (install_id) on delete cascade,
  day        int not null,
  source     text not null,
  n          int not null default 0,
  gems       int not null default 0,
  keys       text[] not null default '{}',
  primary key (install_id, day, source)
);

create table public.starset_achievements (
  install_id uuid not null references public.starset_wallets (install_id) on delete cascade,
  id         text not null,
  at         timestamptz not null default now(),
  primary key (install_id, id)
);

create table public.starset_purchases (
  transaction_id text primary key,
  install_id     uuid not null,
  product_id     text not null,
  gems           int not null,
  premium        boolean not null default false,
  starter        boolean not null default false,
  price          numeric,
  currency       text,
  store          text,
  environment    text,
  refunded_at    timestamptz,
  at             timestamptz not null default now()
);
create index starset_purchases_install_idx on public.starset_purchases (install_id);

-- per-install request limit (60 a minute)
create table public.starset_calls (install_id uuid not null, at timestamptz not null default now());
create index starset_calls_idx on public.starset_calls (install_id, at);

alter table public.starset_wallets      enable row level security;
alter table public.starset_ledger       enable row level security;
alter table public.starset_earn_days    enable row level security;
alter table public.starset_achievements enable row level security;
alter table public.starset_purchases    enable row level security;
alter table public.starset_calls        enable row level security;
revoke all on public.starset_wallets, public.starset_ledger, public.starset_earn_days, public.starset_achievements,
  public.starset_purchases, public.starset_calls from public, anon, authenticated;

-- ── reward tables (keep in step with the app; test/wallet_rules_test.dart compares them) ──────────────────────────
create or replace function public.starset_achievement_gems(p_id text)
returns int language sql immutable as $$
  select case p_id
    when 'first_blood' then 5
    when 'hunter' then 20
    when 'legend' then 50
    when 'miner' then 10
    when 'miner2' then 30
    when 'colonist' then 15
    when 'metropolis' then 15
    when 'builder' then 15
    when 'boss1' then 10
    when 'boss10' then 30
    when 'explorer' then 20
    when 'voyager' then 40
    when 'rich' then 15
    when 'crew6' then 15
    when 'crew3star' then 20
    when 'missions' then 20
    when 'jelly' then 10
    when 'fashion' then 5
    when 'ascend' then 30
    when 'drone' then 5
    when 'home5' then 15
    when 'homeMax' then 30
    else null end
$$;

create or replace function public.starset_quest_gems(p_id text)
returns int language sql immutable as $$
  select case p_id
    when 'kill' then 5
    when 'ore' then 5
    when 'mission' then 10
    when 'colony' then 5
    when 'boss' then 10
    when 'power' then 5
    when 'play' then 5
    when 'jelly' then 5
    when 'bonus' then 10
    else null end
$$;

create or replace function public.starset_login_gems(p_streak int)
returns int language sql immutable as $$
  select (array[5, 5, 10, 10, 15, 20, 50])[((p_streak - 1) % 7) + 1]
$$;

create or replace function public.starset_ad_gems() returns int language sql immutable as $$ select 5 $$;
create or replace function public.starset_ads_per_day() returns int language sql immutable as $$ select 3 $$;

-- Play earnings a UTC day. Continuous play earns about 150-200 an hour (pirate and boss drops, supply capsules every
-- few minutes, missions, raids, three merchant trades a visit, the 8-hourly planet gift), so 1000 is five or more
-- hours of non-stop play. Anything above waits for the next day instead of being lost.
create or replace function public.starset_play_cap() returns int language sql immutable as $$ select 1000 $$;

-- What each store product gives. starter_pack and premium_pass are non-consumable: once per wallet.
create or replace function public.starset_product(p_product_id text)
returns jsonb language sql immutable as $$
  select case split_part(p_product_id, ':', 1)
    when 'gems_100'     then '{"gems":100}'
    when 'gems_550'     then '{"gems":550}'
    when 'gems_1200'    then '{"gems":1200}'
    when 'starter_pack' then '{"gems":300,"starter":true}'
    when 'premium_pass' then '{"gems":0,"premium":true}'
    else null end::jsonb
$$;

-- ── helpers (not callable by the app) ──────────────────────────────────────────
create or replace function public.starset_gate(p_install_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare v int;
begin
  if p_install_id is null then raise exception 'install_id required' using errcode = '22023'; end if;
  perform pg_advisory_xact_lock(hashtext('starset_wallet:' || p_install_id::text));
  delete from starset_calls where install_id = p_install_id and at < now() - interval '1 minute';
  select count(*) into v from starset_calls where install_id = p_install_id;
  if v >= 60 then raise exception 'rate limited' using errcode = 'PT429'; end if;
  insert into starset_calls (install_id) values (p_install_id);
  insert into starset_wallets (install_id) values (p_install_id) on conflict do nothing;
end $$;

create or replace function public.starset_wallet_json(p_install_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'gems', w.gems, 'premium', w.premium, 'starter', w.starter, 'purchases', w.purchases,
    'login_day', w.login_day, 'login_streak', w.login_streak,
    'now', (extract(epoch from now()) * 1000)::bigint)
  from starset_wallets w where w.install_id = p_install_id
$$;

-- yyyymmdd → date, null when it is not a real date
create or replace function public.starset_day(p_day int)
returns date language plpgsql immutable as $$
begin
  if p_day is null or p_day not between 20000101 and 99991231 then return null; end if;
  return to_date(p_day::text, 'YYYYMMDD');
exception when others then return null;
end $$;

revoke all on function public.starset_gate(uuid), public.starset_wallet_json(uuid), public.starset_day(int),
  public.starset_achievement_gems(text), public.starset_quest_gems(text), public.starset_login_gems(int),
  public.starset_ad_gems(), public.starset_ads_per_day(), public.starset_play_cap(), public.starset_product(text)
  from public, anon, authenticated;

-- ── app functions ──────────────────────────────────────────────────────────────
-- Balance, flags and server time.
create or replace function public.starset_wallet(p_install_id uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
begin
  perform starset_gate(p_install_id);
  return starset_wallet_json(p_install_id);
end $$;

-- Earn by the rules in the header. Answers {ok, credited, reason?, wallet}. credited may be less than asked
-- (0 when already taken, the rest of the play cap otherwise); that is not an error.
create or replace function public.starset_earn(
  p_install_id uuid, p_ref text, p_source text, p_key text, p_amount int, p_day int)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  w starset_wallets; prior jsonb; res jsonb; give int := 0; why text;
  today date := (now() at time zone 'utc')::date; d date; dk int; e starset_earn_days; streak int;
begin
  perform starset_gate(p_install_id);
  if p_ref is null or p_ref !~ '^[A-Za-z0-9_-]{8,64}$' then raise exception 'invalid ref' using errcode = '22023'; end if;
  select result into prior from starset_ledger where install_id = p_install_id and ref = p_ref;
  if prior is not null then return prior || jsonb_build_object('wallet', starset_wallet_json(p_install_id), 'repeat', true); end if;
  if p_amount is null or p_amount < 1 or p_amount > 100000 then raise exception 'invalid amount' using errcode = '22023'; end if;
  select * into w from starset_wallets where install_id = p_install_id for update;

  if p_source = 'ach' then
    give := starset_achievement_gems(p_key);
    if give is null then raise exception 'invalid achievement' using errcode = '22023'; end if;
    insert into starset_achievements (install_id, id) values (p_install_id, p_key) on conflict do nothing;
    if not found then give := 0; why := 'claimed'; end if;

  elsif p_source = 'play' then
    dk := to_char(today, 'YYYYMMDD')::int;
    insert into starset_earn_days (install_id, day, source) values (p_install_id, dk, 'play') on conflict do nothing;
    select * into e from starset_earn_days where install_id = p_install_id and day = dk and source = 'play' for update;
    give := least(p_amount, greatest(0, starset_play_cap() - e.gems));
    if give < p_amount then why := 'cap'; end if;
    update starset_earn_days set n = n + 1, gems = gems + give where install_id = p_install_id and day = dk and source = 'play';

  elsif p_source in ('login', 'quest', 'ad') then
    d := starset_day(p_day);
    if d is null or d < today - 7 or d > today + 1 then raise exception 'invalid day' using errcode = '22023'; end if;
    if p_source = 'login' then
      if w.login_day is not null and p_day <= w.login_day then
        why := 'claimed';
      else
        streak := case when starset_day(w.login_day) = d - 1 then w.login_streak + 1 else 1 end;
        give := starset_login_gems(streak);
        update starset_wallets set login_day = p_day, login_streak = streak where install_id = p_install_id;
      end if;
    else
      insert into starset_earn_days (install_id, day, source) values (p_install_id, p_day, p_source) on conflict do nothing;
      select * into e from starset_earn_days where install_id = p_install_id and day = p_day and source = p_source for update;
      if p_source = 'ad' then
        if e.n >= starset_ads_per_day() then why := 'limit'; else give := starset_ad_gems(); end if;
      else
        give := starset_quest_gems(p_key);
        if give is null then raise exception 'invalid quest' using errcode = '22023'; end if;
        if p_key = any (e.keys) then give := 0; why := 'claimed';
        elsif p_key <> 'bonus' and (select count(*) from unnest(e.keys) k where k <> 'bonus') >= 3 then give := 0; why := 'limit';
        end if;
      end if;
      if give > 0 then
        update starset_earn_days set n = n + 1, gems = gems + give,
          keys = case when p_source = 'quest' then keys || p_key else keys end
        where install_id = p_install_id and day = p_day and source = p_source;
      end if;
    end if;

  else
    raise exception 'invalid source' using errcode = '22023';
  end if;

  if give > 0 then
    update starset_wallets set gems = gems + give, updated_at = now() where install_id = p_install_id;
  end if;
  res := jsonb_build_object('ok', true, 'credited', give) || case when why is null then '{}'::jsonb else jsonb_build_object('reason', why) end;
  insert into starset_ledger (install_id, ref, kind, gems, result)
  values (p_install_id, p_ref, 'earn:' || p_source || coalesce(':' || nullif(p_key, ''), ''), give, res);
  return res || jsonb_build_object('wallet', starset_wallet_json(p_install_id));
end $$;

-- Spend. The app has already checked its own rules (what the gems buy is game progress kept on the device);
-- the server only makes sure the gems exist. p_reason is a short label for the record.
-- Answers {ok, wallet}; not enough → ok false, reason 'not enough', nothing changes.
create or replace function public.starset_spend(p_install_id uuid, p_ref text, p_reason text, p_amount int)
returns jsonb language plpgsql security definer set search_path = public as $$
declare w starset_wallets; prior jsonb; res jsonb;
begin
  perform starset_gate(p_install_id);
  if p_ref is null or p_ref !~ '^[A-Za-z0-9_-]{8,64}$' then raise exception 'invalid ref' using errcode = '22023'; end if;
  select result into prior from starset_ledger where install_id = p_install_id and ref = p_ref;
  if prior is not null then return prior || jsonb_build_object('wallet', starset_wallet_json(p_install_id), 'repeat', true); end if;
  if p_amount is null or p_amount < 1 or p_amount > 1000000 then raise exception 'invalid amount' using errcode = '22023'; end if;
  if p_reason is null or p_reason !~ '^[a-z0-9_]{1,32}$' then raise exception 'invalid reason' using errcode = '22023'; end if;
  select * into w from starset_wallets where install_id = p_install_id for update;
  if w.gems < p_amount then
    return jsonb_build_object('ok', false, 'reason', 'not enough', 'wallet', starset_wallet_json(p_install_id));
  end if;
  update starset_wallets set gems = gems - p_amount, updated_at = now() where install_id = p_install_id;
  res := jsonb_build_object('ok', true, 'spent', p_amount);
  insert into starset_ledger (install_id, ref, kind, gems, result) values (p_install_id, p_ref, 'spend:' || p_reason, -p_amount, res);
  return res || jsonb_build_object('wallet', starset_wallet_json(p_install_id));
end $$;

-- ── purchases (service role, from starset-purchase-webhook) ────────────────────
-- Returns {credited, gems} or {credited:false, reason}. A transaction is credited once. A non-consumable the wallet
-- already owns is recorded but gives nothing again.
create or replace function public.starset_credit_purchase(
  p_install_id uuid, p_transaction_id text, p_product_id text, p_price numeric, p_currency text, p_store text, p_environment text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare
  product jsonb := starset_product(p_product_id); pid text := split_part(p_product_id, ':', 1);
  w starset_wallets; g int; prem boolean; start boolean;
begin
  if p_install_id is null or p_transaction_id is null then raise exception 'invalid purchase' using errcode = '22023'; end if;
  if product is null then return jsonb_build_object('credited', false, 'reason', 'unknown product'); end if;
  perform pg_advisory_xact_lock(hashtext('starset_wallet:' || p_install_id::text));
  if exists (select 1 from starset_purchases where transaction_id = p_transaction_id) then
    return jsonb_build_object('credited', false, 'reason', 'already credited');
  end if;
  insert into starset_wallets (install_id) values (p_install_id) on conflict do nothing;
  select * into w from starset_wallets where install_id = p_install_id for update;
  g := (product->>'gems')::int;
  prem := coalesce((product->>'premium')::boolean, false);
  start := coalesce((product->>'starter')::boolean, false);
  if (prem and w.premium) or (start and w.starter) then
    g := 0; prem := false; start := false;
  end if;
  insert into starset_purchases (transaction_id, install_id, product_id, gems, premium, starter, price, currency, store, environment)
  values (p_transaction_id, p_install_id, pid, g, prem, start, p_price, p_currency, p_store, p_environment);
  update starset_wallets set gems = gems + g, premium = premium or prem, starter = starter or start,
    purchases = purchases + 1, updated_at = now() where install_id = p_install_id;
  insert into starset_ledger (install_id, ref, kind, gems, result)
  values (p_install_id, 'buy:' || p_transaction_id, 'purchase:' || pid, g, jsonb_build_object('product', pid));
  return jsonb_build_object('credited', true, 'gems', g, 'premium', prem, 'starter', start);
end $$;

-- Refund: take back what is left of the gems (never below zero) and the flag it gave.
create or replace function public.starset_refund_purchase(p_transaction_id text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare p starset_purchases; taken int;
begin
  select * into p from starset_purchases where transaction_id = p_transaction_id;
  if p.transaction_id is null or p.refunded_at is not null then return jsonb_build_object('refunded', false); end if;
  perform pg_advisory_xact_lock(hashtext('starset_wallet:' || p.install_id::text));
  update starset_purchases set refunded_at = now() where transaction_id = p_transaction_id;
  select least(gems, p.gems) into taken from starset_wallets where install_id = p.install_id for update;
  update starset_wallets set gems = gems - taken,
    premium = premium and not p.premium, starter = starter and not p.starter, updated_at = now()
  where install_id = p.install_id;
  insert into starset_ledger (install_id, ref, kind, gems, result)
  values (p.install_id, 'refund:' || p_transaction_id, 'refund:' || p.product_id, -taken, jsonb_build_object('asked', p.gems, 'taken', taken));
  return jsonb_build_object('refunded', true, 'taken', taken);
end $$;

-- RevenueCat TRANSFER: the store account's purchases moved to another install (reinstall + restore, a new phone).
-- The wallet goes with them: gems add up, flags join, the old wallets are emptied. Returns {moved}.
create or replace function public.starset_transfer(p_from uuid[], p_to uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare src starset_wallets; moved int := 0;
begin
  if p_to is null then raise exception 'invalid transfer' using errcode = '22023'; end if;
  perform pg_advisory_xact_lock(hashtext('starset_wallet:' || p_to::text));
  insert into starset_wallets (install_id) values (p_to) on conflict do nothing;
  for src in select * from starset_wallets where install_id = any (p_from) and install_id <> p_to for update loop
    update starset_wallets set gems = gems + src.gems, premium = premium or src.premium, starter = starter or src.starter,
      purchases = purchases + 1, updated_at = now() where install_id = p_to;
    update starset_wallets set gems = 0, premium = false, starter = false, updated_at = now() where install_id = src.install_id;
    update starset_purchases set install_id = p_to where install_id = src.install_id;
    insert into starset_ledger (install_id, ref, kind, gems, result)
    values (p_to, 'transfer-in:' || src.install_id || ':' || (extract(epoch from now()) * 1000)::bigint, 'transfer', src.gems, jsonb_build_object('from', src.install_id)),
           (src.install_id, 'transfer-out:' || p_to || ':' || (extract(epoch from now()) * 1000)::bigint, 'transfer', -src.gems, jsonb_build_object('to', p_to));
    moved := moved + src.gems;
  end loop;
  return jsonb_build_object('moved', moved);
end $$;

-- Housekeeping: rate-limit rows older than a day are never needed.
create or replace function public.starset_purge_calls()
returns void language sql security definer set search_path = public as $$
  delete from starset_calls where at < now() - interval '1 day'
$$;

revoke all on function public.starset_wallet(uuid), public.starset_earn(uuid, text, text, text, int, int),
  public.starset_spend(uuid, text, text, int), public.starset_credit_purchase(uuid, text, text, numeric, text, text, text),
  public.starset_refund_purchase(text), public.starset_transfer(uuid[], uuid), public.starset_purge_calls()
  from public, anon, authenticated;
grant execute on function public.starset_wallet(uuid), public.starset_earn(uuid, text, text, text, int, int),
  public.starset_spend(uuid, text, text, int) to anon;
grant execute on function public.starset_credit_purchase(uuid, text, text, numeric, text, text, text),
  public.starset_refund_purchase(text), public.starset_transfer(uuid[], uuid), public.starset_purge_calls() to service_role;
