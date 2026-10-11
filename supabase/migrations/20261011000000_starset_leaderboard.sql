-- Star Settlers (우주 개척단) weekly "개척 점수" leaderboard on the shared game backend
-- (/Volumes/home_extension/mkideabox-corp-process/processes/infrastructure/game-shared-backend.md).
-- Structure copied from claires-ranch (claire_leaderboard). Every object is starset_-prefixed.
-- Clients never touch the tables: RLS is on with no policies and table privileges are revoked from
-- public/anon/authenticated. The only way in is the two security definer functions below.
--
-- KIDS SAFETY: nicknames are NOT free text. The client picks them from fixed word lists and sends only a code
-- "<adjIndex>-<animalIndex>-<4 digits>" (e.g. "12-7-0427"); every client renders the words in its own language.
-- No user-typed text ever reaches the server or other players. Index ranges must match
-- lib/services/leaderboard.dart (NicknameCode.adjectiveCount / animalCount = 40).
--
-- Week = ISO 8601 week as yyyyww (e.g. 202641), computed by the client in UTC. Submissions are accepted only for
-- the current or the previous ISO week (UTC), so a score earned just before Monday 00:00 UTC can still be sent.
--
-- Score cap (one week). Scoring formula (lib/game/weekly_score.dart):
--   +100 per colony level gained, +500 per new star system reached, +5 per pirate destroyed by the player ship,
--   +200 per boss defeated.
-- Kills dominate. Pirate spawning (world.dart _updateSpawning) is at most one group of <= 4 every >= 3 s
-- (~1.33/s); allowing 1.5 kills/s for bounty/event pirates, 168 h of non-stop play gives
--   168 * 3600 * 1.5 * 5 = 4,536,000.
-- Colony levels (<= 21 planets * 5 levels per system), new systems and bosses are each well under 100,000 a week
-- even with ascension restarts. Cap = 5,000,000 (generous: no honest player can reach it; anything above is junk).

create table public.starset_players (
  install_id uuid primary key,
  nickname   text not null check (nickname ~ '^([0-9]|[1-3][0-9])-([0-9]|[1-3][0-9])-[0-9]{4}$'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.starset_scores (
  install_id   uuid not null references public.starset_players (install_id) on delete cascade,
  week         int  not null check (week between 200001 and 999953),
  score        int  not null check (score between 0 and 5000000),
  submitted_at timestamptz not null default now(),
  primary key (install_id, week)
);
create index starset_scores_board_idx on public.starset_scores (week, score desc, submitted_at);

create table public.starset_submissions (
  install_id uuid not null,
  at         timestamptz not null default now()
);
create index starset_submissions_install_at_idx on public.starset_submissions (install_id, at);

alter table public.starset_players     enable row level security;
alter table public.starset_scores      enable row level security;
alter table public.starset_submissions enable row level security;

revoke all on public.starset_players, public.starset_scores, public.starset_submissions from public, anon, authenticated;

-- Submit this week's score. Returns {"rank": n, "total": m} for that week.
create or replace function public.starset_submit_score(
  p_install_id uuid, p_nickname text, p_week int, p_score int)
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
  -- "<adj 0..39>-<animal 0..39>-<0000..9999>", no leading zeros on the indices
  if p_nickname is null or p_nickname !~ '^([0-9]|[1-3][0-9])-([0-9]|[1-3][0-9])-[0-9]{4}$' then
    raise exception 'invalid nickname' using errcode = '22023';
  end if;
  if p_score is null or p_score not between 0 and 5000000 then
    raise exception 'invalid score' using errcode = '22023';
  end if;
  if p_week is null or p_week not in (v_cur, v_prev) then
    raise exception 'invalid week' using errcode = '22023';
  end if;

  -- Rate limit: at most 5 calls per install in any rolling minute (PT429 -> HTTP 429). The advisory lock
  -- serialises concurrent calls from the same install so the count cannot be raced.
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

  -- Best score only; an equal score keeps the earlier submitted_at (tie rule).
  insert into starset_scores (install_id, week, score, submitted_at)
  values (p_install_id, p_week, p_score, now())
  on conflict (install_id, week) do update
    set score = excluded.score, submitted_at = excluded.submitted_at
    where excluded.score > starset_scores.score;

  select r.rn, r.total into v_rank, v_total from (
    select install_id,
           row_number() over (order by score desc, submitted_at asc, install_id) as rn,
           count(*) over () as total
      from starset_scores
     where week = p_week) r
   where r.install_id = p_install_id;

  return json_build_object('rank', v_rank, 'total', v_total);
end;
$$;

-- Top 50 (score desc, earlier submission first) plus the caller's own row when it is outside the top 50.
create or replace function public.starset_leaderboard(p_week int, p_install_id uuid)
returns table (rank int, nickname text, score int, me boolean)
language sql
stable
security definer
set search_path = public
as $$
  with ranked as (
    select s.install_id, p.nickname, s.score,
           (row_number() over (order by s.score desc, s.submitted_at asc, s.install_id))::int as rn
      from starset_scores s
      join starset_players p on p.install_id = s.install_id
     where s.week = p_week)
  select r.rn, r.nickname, r.score, (p_install_id is not null and r.install_id = p_install_id)
    from ranked r
   where r.rn <= 50 or (p_install_id is not null and r.install_id = p_install_id)
   order by r.rn;
$$;

revoke all on function public.starset_submit_score(uuid, text, int, int) from public, anon, authenticated;
revoke all on function public.starset_leaderboard(int, uuid) from public, anon, authenticated;
grant execute on function public.starset_submit_score(uuid, text, int, int) to anon;
grant execute on function public.starset_leaderboard(int, uuid) to anon;
