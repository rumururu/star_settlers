-- Star Settlers (우주 개척단) weekly Rift Run (균열 런) leaderboard on the shared game backend (mkideabox-games)
-- (/Volumes/home_extension/mkideabox-corp-process/processes/infrastructure/game-shared-backend.md).
-- Same locking pattern as 20261011000000_starset_leaderboard.sql: RLS on with no policies, table privileges revoked from
-- public/anon/authenticated, and the only way in is the security definer functions below (anon only).
-- Players (install id + nickname CODE, never free text) are shared with the weekly pioneer board: starset_players.
-- The rate limit is shared too (starset_submissions, same advisory-lock key): at most 5 leaderboard calls
-- (pioneer submit + rift submit + forget) per install in any rolling minute.
--
-- Client: lib/services/leaderboard.dart (submitRift / fetchRift), rules: lib/game/rift.dart.
-- Week = ISO 8601 week yyyyww (UTC). Only the current or the previous ISO week is accepted.
--
-- SCORE CAP (one run; the board keeps each install's best run of the week). Scoring (lib/game/rift.dart RiftScore):
--   kill   = base(kind) * wave,  base: scout 10, raider/bomber 15, sniper 20, missile/laser/mine/phantom 30,
--            warden/medic 35, carrier 45, juggernaut 60 (max regular base 60), boss 600.
--            Only enemies the rift itself spawns score (carrier drones / boss escorts score 0).
--   shards = kill / 2 (dropped pickups worth score)            -> kill + shards <= 1.5 * kill
--   clear  = 150 * wave for each cleared wave; wave 10 conquered: +3000 and +10 per second under 480 s (max 4800).
-- Wave n (1..9) spawns exactly 3 + 2n enemies; wave 10 = 1 boss + 8 escorts. The run ends at wave 10.
--   max kills+shards of wave n<10 = (3 + 2n) * 60 * n * 1.5 = (3 + 2n) * 90n
--   max kills+shards of wave 10   = (600*10 + 8*60*10) * 1.5 = 16,200
--   max score having REACHED wave r = sum_{n<=r} maxKills(n) + sum_{n<r} 150n  (+ 1500 + 3000 + 4800 when r = 10)
--   r = 10: 63,450 + 16,200 + 6,750 + 1,500 + 3,000 + 4,800 = 95,700  <- absolute cap
-- starset_rift_max(r) below is that formula; a submitted score above the bound for its wave count is rejected.

create table public.starset_rift_scores (
  install_id   uuid not null references public.starset_players (install_id) on delete cascade,
  week         int  not null check (week between 200001 and 999953),
  score        int  not null check (score between 0 and 95700),
  waves        int  not null check (waves between 1 and 10),
  submitted_at timestamptz not null default now(),
  primary key (install_id, week)
);
create index starset_rift_scores_board_idx on public.starset_rift_scores (week, score desc, submitted_at);

alter table public.starset_rift_scores enable row level security;
revoke all on public.starset_rift_scores from public, anon, authenticated;

-- Highest possible score for a run that reached wave p_waves (1..10). Mirrors RiftScore.maxForWave in lib/game/rift.dart.
create or replace function public.starset_rift_max(p_waves int)
returns int
language sql
immutable
set search_path = public
as $$
  select (
    (select coalesce(sum(case when n < 10 then (3 + 2 * n) * 90 * n else 16200 end), 0)
       from generate_series(1, p_waves) n)
    + (select coalesce(sum(150 * n), 0) from generate_series(1, p_waves - 1) n)
    + case when p_waves = 10 then 1500 + 3000 + 4800 else 0 end
  )::int;
$$;

-- Submit a run. Keeps the best score of the week (an equal score keeps the earlier submission). Returns {"rank", "total"}.
create or replace function public.starset_submit_rift(
  p_install_id uuid, p_nickname text, p_week int, p_score int, p_waves int)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_now    timestamp := now() at time zone 'utc';
  v_cur    int := to_char(v_now, 'IYYYIW')::int;
  v_prev   int := to_char(v_now - interval '7 days', 'IYYYIW')::int;
  v_recent int;
  v_rank   int;
  v_total  int;
begin
  if p_install_id is null then
    raise exception 'install_id required' using errcode = '22023';
  end if;
  if p_nickname is null or p_nickname !~ '^([0-9]|[1-3][0-9])-([0-9]|[1-3][0-9])-[0-9]{4}$' then
    raise exception 'invalid nickname' using errcode = '22023';
  end if;
  if p_waves is null or p_waves not between 1 and 10 then
    raise exception 'invalid waves' using errcode = '22023';
  end if;
  if p_score is null or p_score < 0 or p_score > starset_rift_max(p_waves) then
    raise exception 'invalid score' using errcode = '22023';
  end if;
  if p_week is null or p_week not in (v_cur, v_prev) then
    raise exception 'invalid week' using errcode = '22023';
  end if;

  -- Rate limit shared with starset_submit_score / starset_forget (same lock key, same table): 5 calls per rolling minute.
  perform pg_advisory_xact_lock(hashtext('starset_submit:' || p_install_id::text));
  delete from starset_submissions where install_id = p_install_id and at < now() - interval '1 minute';
  select count(*) into v_recent from starset_submissions
   where install_id = p_install_id and at > now() - interval '1 minute';
  if v_recent >= 5 then
    raise exception 'rate limited' using errcode = 'PT429';
  end if;
  insert into starset_submissions (install_id, at) values (p_install_id, now());

  insert into starset_players (install_id, nickname) values (p_install_id, p_nickname)
  on conflict (install_id) do update
    set nickname = excluded.nickname, updated_at = now()
    where starset_players.nickname is distinct from excluded.nickname;

  insert into starset_rift_scores (install_id, week, score, waves, submitted_at)
  values (p_install_id, p_week, p_score, p_waves, now())
  on conflict (install_id, week) do update
    set score = excluded.score, waves = excluded.waves, submitted_at = excluded.submitted_at
    where excluded.score > starset_rift_scores.score;

  select r.rn, r.total into v_rank, v_total from (
    select install_id,
           row_number() over (order by score desc, submitted_at asc, install_id) as rn,
           count(*) over () as total
      from starset_rift_scores
     where week = p_week) r
   where r.install_id = p_install_id;

  return json_build_object('rank', v_rank, 'total', v_total);
end;
$$;

-- Top 50 (score desc, earlier submission first) plus the caller's own row when it is outside the top 50.
create or replace function public.starset_rift_board(p_week int, p_install_id uuid)
returns table (rank int, nickname text, score int, waves int, me boolean)
language sql
stable
security definer
set search_path = public
as $$
  with ranked as (
    select s.install_id, p.nickname, s.score, s.waves,
           (row_number() over (order by s.score desc, s.submitted_at asc, s.install_id))::int as rn
      from starset_rift_scores s
      join starset_players p on p.install_id = s.install_id
     where s.week = p_week)
  select r.rn, r.nickname, r.score, r.waves, (p_install_id is not null and r.install_id = p_install_id)
    from ranked r
   where r.rn <= 50 or (p_install_id is not null and r.install_id = p_install_id)
   order by r.rn;
$$;

-- "모든 데이터 초기화": forget now also removes rift scores. Same contract as 20261011010000_starset_forget.sql;
-- "deleted" = pioneer score rows + rift score rows removed (an install with one weekly score and no rift run -> 1).
create or replace function public.starset_forget(p_install_id uuid)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_recent  int;
  v_deleted int;
  v_rift    int;
begin
  if p_install_id is null then
    raise exception 'install_id required' using errcode = '22023';
  end if;

  perform pg_advisory_xact_lock(hashtext('starset_submit:' || p_install_id::text));
  select count(*) into v_recent from starset_submissions
   where install_id = p_install_id and at > now() - interval '1 minute';
  if v_recent >= 5 then
    raise exception 'rate limited' using errcode = 'PT429';
  end if;

  delete from starset_scores where install_id = p_install_id;
  get diagnostics v_deleted = row_count;
  delete from starset_rift_scores where install_id = p_install_id;
  get diagnostics v_rift = row_count;
  delete from starset_players where install_id = p_install_id;
  delete from starset_submissions where install_id = p_install_id and at < now() - interval '1 minute';
  insert into starset_submissions (install_id, at) values (p_install_id, now());
  delete from starset_submissions where at < now() - interval '10 minutes';

  return json_build_object('deleted', v_deleted + v_rift);
end;
$$;

revoke all on function public.starset_rift_max(int) from public, anon, authenticated;
revoke all on function public.starset_submit_rift(uuid, text, int, int, int) from public, anon, authenticated;
revoke all on function public.starset_rift_board(int, uuid) from public, anon, authenticated;
revoke all on function public.starset_forget(uuid) from public, anon, authenticated;
grant execute on function public.starset_submit_rift(uuid, text, int, int, int) to anon;
grant execute on function public.starset_rift_board(int, uuid) to anon;
grant execute on function public.starset_forget(uuid) to anon;
