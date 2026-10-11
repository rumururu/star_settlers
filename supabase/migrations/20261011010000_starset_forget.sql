-- Star Settlers: delete one install's leaderboard data ("모든 데이터 초기화" in the game's settings).
-- Same rules as 20261011000000_starset_leaderboard.sql: security definer, only anon may execute, rate-limited per install.
-- Returns {"deleted": <score rows removed>}. Unknown ids are not an error (returns 0), so the call reveals nothing.

create or replace function public.starset_forget(p_install_id uuid)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_recent  int;
  v_deleted int;
begin
  if p_install_id is null then
    raise exception 'install_id required' using errcode = '22023';
  end if;

  -- Shares the submit limit window: at most 5 calls per install per rolling minute (PT429 -> HTTP 429).
  perform pg_advisory_xact_lock(hashtext('starset_submit:' || p_install_id::text));
  select count(*) into v_recent from starset_submissions
   where install_id = p_install_id and at > now() - interval '1 minute';
  if v_recent >= 5 then
    raise exception 'rate limited' using errcode = 'PT429';
  end if;

  delete from starset_scores where install_id = p_install_id;
  get diagnostics v_deleted = row_count;
  delete from starset_players where install_id = p_install_id;
  -- Only the last minute's rate-limit rows (bare timestamps) stay, plus one for this call, so repeated forget calls are
  -- still rate-limited. Housekeeping below removes them after 10 minutes on any later forget call.
  delete from starset_submissions where install_id = p_install_id and at < now() - interval '1 minute';
  insert into starset_submissions (install_id, at) values (p_install_id, now());
  -- Housekeeping: rate-limit rows older than 10 minutes are never needed (also removes earlier forget markers).
  delete from starset_submissions where at < now() - interval '10 minutes';

  return json_build_object('deleted', v_deleted);
end;
$$;

revoke all on function public.starset_forget(uuid) from public, anon, authenticated;
grant execute on function public.starset_forget(uuid) to anon;
