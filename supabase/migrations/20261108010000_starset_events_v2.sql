-- Star Settlers 1.0.8 retention-update: more funnel events (TASK 003~006). Replaces the allow-list only.
-- Must match lib/game/game_telemetry.dart TelemetryEvent (test/telemetry_test.dart compares the latest definition).
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
    'day_return',
    'goal_done', 'mini_boss_kill', 'calendar_open', 'expedition_start', 'expedition_claim',
    'rift_start', 'rift_end', 'codex_open'
  ]::text[];
$$;
revoke all on function public.starset_event_names() from public, anon, authenticated;
