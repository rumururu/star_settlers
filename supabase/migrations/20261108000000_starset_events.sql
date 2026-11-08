-- Star Settlers (우주 개척단) gameplay funnel events on the shared game backend (mkideabox-games)
-- (/Volumes/home_extension/mkideabox-corp-process/processes/infrastructure/game-shared-backend.md).
-- Purpose: see where new players stop (tutorial step N, first colony, first warp, day-N return ...).
-- Same locking pattern as 20261011000000_starset_leaderboard.sql: RLS on with no policies, table privileges revoked
-- from public/anon/authenticated, and the only way in is the security definer function starset_track (anon only).
--
-- PRIVACY / KIDS SAFETY: no free text reaches this table. A row is a random install UUID (the same one the leaderboard
-- and wallet use, not an ad ID or device ID), a fixed event name from the allow-list below, an optional integer, and
-- app version / language code / platform each restricted by a regex. Rows older than one year are deleted
-- (starset_events_purge, scheduled with pg_cron when the extension is available - see the end of this file).
--
-- Client: lib/services/telemetry.dart (event names: lib/game/game_telemetry.dart TelemetryEvent - keep both lists in
-- sync; adding an event = add it to the enum and to starset_event_names() below with `create or replace`).
--
-- Request body (PostgREST rpc): {"p_install_id": "<uuid>", "p_events": [ {...}, ... ]} with at most 50 items:
--   {"n": "tutorial_step", "v": 3, "t": 1794000000, "app": "1.0.8", "loc": "ko", "os": "android"}
--   n   event name (required, allow-list)
--   v   integer 0..100000000 or absent/null
--   t   client time in unix seconds; used only when within the last 7 days and not more than 5 minutes ahead,
--       otherwise the server time is stored (events queued offline keep roughly their real time)
--   app app version "1.2.3" (1-4 numeric parts), loc language code "ko" / "pt-BR", os one of the platforms below
-- Invalid items are dropped silently; the call returns {"stored": <rows inserted>}.
-- Errors: missing install id / p_events not an array / more than 50 items -> 22023 (HTTP 400);
--         more than 10 calls per install in a rolling minute -> PT429 (HTTP 429).

create table public.starset_events (
  install_id  uuid not null,
  name        text not null,
  value       int,
  app_version text not null check (app_version ~ '^[0-9]{1,4}(\.[0-9]{1,4}){0,3}$'),
  locale      text not null check (locale ~ '^[a-z]{2,3}(-[A-Z]{2})?$'),
  platform    text not null check (platform in ('android', 'ios', 'web', 'macos', 'windows', 'linux')),
  at          timestamptz not null default now()
);
create index starset_events_name_at_idx    on public.starset_events (name, at);
create index starset_events_install_at_idx on public.starset_events (install_id, at);

-- Rate-limit bookkeeping for starset_track (kept apart from starset_submissions so the leaderboard limit is unaffected)
create table public.starset_event_calls (
  install_id uuid not null,
  at         timestamptz not null default now()
);
create index starset_event_calls_install_at_idx on public.starset_event_calls (install_id, at);

alter table public.starset_events      enable row level security;
alter table public.starset_event_calls enable row level security;
revoke all on public.starset_events, public.starset_event_calls from public, anon, authenticated;

-- THE allow-list (the only SQL copy). Must match TelemetryEvent.wire in lib/game/game_telemetry.dart.
create or replace function public.starset_event_names()
returns text[]
language sql
immutable
set search_path = public
as $$
  select array[
    'session_start', 'session_end',
    'tutorial_step', 'tutorial_done',
    'first_kill', 'first_colony', 'first_building', 'first_crew', 'first_warp', 'first_boss', 'first_death',
    'system_reached', 'login_claim', 'daily_quest_claim', 'ad_watch', 'shop_open', 'iap_start',
    'day_return'
  ]::text[];
$$;

create or replace function public.starset_track(p_install_id uuid, p_events jsonb)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_names  text[] := starset_event_names();
  v_recent int;
  v_stored int := 0;
  e        jsonb;
  v_name   text;
  v_value  int;
  v_app    text;
  v_loc    text;
  v_os     text;
  v_at     timestamptz;
  v_num    numeric;
begin
  if p_install_id is null then
    raise exception 'install_id required' using errcode = '22023';
  end if;
  if p_events is null or jsonb_typeof(p_events) <> 'array' then
    raise exception 'events must be an array' using errcode = '22023';
  end if;
  if jsonb_array_length(p_events) > 50 then
    raise exception 'too many events' using errcode = '22023';
  end if;

  -- Rate limit: at most 10 calls per install in any rolling minute (the client sends every 30 s and on background).
  perform pg_advisory_xact_lock(hashtext('starset_track:' || p_install_id::text));
  delete from starset_event_calls where install_id = p_install_id and at < now() - interval '1 minute';
  select count(*) into v_recent from starset_event_calls
   where install_id = p_install_id and at > now() - interval '1 minute';
  if v_recent >= 10 then
    raise exception 'rate limited' using errcode = 'PT429';
  end if;
  insert into starset_event_calls (install_id, at) values (p_install_id, now());

  for e in select value from jsonb_array_elements(p_events) loop
    continue when jsonb_typeof(e) <> 'object';

    -- name: string in the allow-list
    continue when jsonb_typeof(e -> 'n') is distinct from 'string';
    v_name := e ->> 'n';
    continue when not (v_name = any (v_names));

    -- value: absent/null or an integer 0..100000000
    v_value := null;
    if e ? 'v' and jsonb_typeof(e -> 'v') <> 'null' then
      continue when jsonb_typeof(e -> 'v') <> 'number';
      v_num := (e ->> 'v')::numeric;
      continue when v_num <> trunc(v_num) or v_num < 0 or v_num > 100000000;
      v_value := v_num::int;
    end if;

    -- app version / language / platform: strict formats, no free text
    continue when jsonb_typeof(e -> 'app') is distinct from 'string'
               or jsonb_typeof(e -> 'loc') is distinct from 'string'
               or jsonb_typeof(e -> 'os') is distinct from 'string';
    v_app := e ->> 'app';
    v_loc := e ->> 'loc';
    v_os  := e ->> 'os';
    continue when v_app !~ '^[0-9]{1,4}(\.[0-9]{1,4}){0,3}$'
               or v_loc !~ '^[a-z]{2,3}(-[A-Z]{2})?$'
               or v_os not in ('android', 'ios', 'web', 'macos', 'windows', 'linux');

    -- client time (unix seconds) only when plausible
    v_at := now();
    if jsonb_typeof(e -> 't') = 'number' then
      v_num := (e ->> 't')::numeric;
      if v_num between extract(epoch from now() - interval '7 days') and extract(epoch from now() + interval '5 minutes') then
        v_at := to_timestamp(v_num);
      end if;
    end if;

    insert into starset_events (install_id, name, value, app_version, locale, platform, at)
    values (p_install_id, v_name, v_value, v_app, v_loc, v_os, v_at);
    v_stored := v_stored + 1;
  end loop;

  -- Housekeeping: rate-limit rows older than 10 minutes are never needed.
  delete from starset_event_calls where at < now() - interval '10 minutes';

  return json_build_object('stored', v_stored);
end;
$$;

-- Retention: one year. Not callable by app roles.
create or replace function public.starset_events_purge()
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deleted int;
begin
  delete from starset_events where at < now() - interval '1 year';
  get diagnostics v_deleted = row_count;
  return v_deleted;
end;
$$;

revoke all on function public.starset_event_names() from public, anon, authenticated;
revoke all on function public.starset_track(uuid, jsonb) from public, anon, authenticated;
revoke all on function public.starset_events_purge() from public, anon, authenticated;
grant execute on function public.starset_track(uuid, jsonb) to anon;

-- Daily purge with pg_cron when available. If the extension cannot be enabled the migration still succeeds and the
-- operator runs `select public.starset_events_purge();` by hand (docs/PRIVACY_POLICY.md states the one-year limit).
-- supabase/tests/events_live.sh reports whether the job exists.
do $$
begin
  create extension if not exists pg_cron;
  perform cron.unschedule(jobid) from cron.job where jobname = 'starset_events_purge';
  perform cron.schedule('starset_events_purge', '17 3 * * *', 'select public.starset_events_purge()');
exception when others then
  raise notice 'pg_cron not available (%); purge starset_events manually with select public.starset_events_purge()', sqlerrm;
end;
$$;
