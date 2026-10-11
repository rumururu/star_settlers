#!/usr/bin/env bash
# Leaderboard checks against the LOCAL Supabase stack of this repo (project_id "star-settlers").
#   supabase start            # from the repo root (ports 556xx, see supabase/config.toml)
#   supabase/tests/run.sh
# Each SQL case runs in its own transaction and is rolled back. The REST cases go through the local API
# gateway with the anon key, the way the game calls it, and delete what they wrote.
set -u
cd "$(dirname "$0")/../.."

CONTAINER="${STARSET_DB_CONTAINER:-supabase_db_star-settlers}"
API="${STARSET_API_URL:-http://127.0.0.1:55621}"
pass=0; fail=0

psqlc() { docker exec -i "$CONTAINER" psql -U postgres -d postgres -X -q -v ON_ERROR_STOP=1 "$@"; }

# :cw = current ISO week (UTC) as yyyyww, :pw = previous, :nw = next (must be rejected)
PRELUDE=$(cat <<'SQL'
create function pg_temp.assert(ok boolean, msg text) returns void language plpgsql as $f$
begin if ok is not true then raise exception 'ASSERT: %', msg; end if; end $f$;
create function pg_temp.expect_error(q text, pat text) returns void language plpgsql as $f$
begin
  begin
    execute q;
  exception when others then
    if sqlerrm ~ pat then return; end if;
    raise exception 'ASSERT: wrong error "%" (wanted /%/)', sqlerrm, pat;
  end;
  raise exception 'ASSERT: not rejected: %', q;
end $f$;
select to_char(now() at time zone 'utc', 'IYYYIW')::int as cw,
       to_char(now() at time zone 'utc' - interval '7 days', 'IYYYIW')::int as pw,
       to_char(now() at time zone 'utc' + interval '7 days', 'IYYYIW')::int as nw,
       to_char(now() at time zone 'utc' - interval '14 days', 'IYYYIW')::int as ow \gset
SQL
)

result() { # name, ok(0/1), detail
  if [ "$2" -eq 0 ]; then echo "PASS  $1"; pass=$((pass+1)); else echo "FAIL  $1"; [ -n "$3" ] && echo "$3" | sed 's/^/        /'; fail=$((fail+1)); fi
}

case_sql() { # name, sql
  local out rc
  out=$(printf 'begin;\n%s\n%s\nrollback;\n' "$PRELUDE" "$2" | psqlc 2>&1); rc=$?
  result "$1" $rc "$out"
}

if ! docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null | grep -q true; then
  echo "FAIL  db container $CONTAINER is not running (supabase start from the repo root)"; exit 1
fi

case_sql "valid submit returns rank 1 of 1 (called as anon)" "
set local role anon;
select starset_submit_score('00000000-0000-0000-0000-000000000001','12-7-0427',:cw,1200)::jsonb as r \gset
reset role;
select pg_temp.assert(:'r'::jsonb = '{\"rank\":1,\"total\":1}'::jsonb, 'got ' || :'r');
select pg_temp.assert((select nickname from starset_players where install_id='00000000-0000-0000-0000-000000000001') = '12-7-0427', 'nickname stored');
select pg_temp.assert((select score from starset_scores where install_id='00000000-0000-0000-0000-000000000001') = 1200, 'score stored');"

case_sql "previous ISO week accepted" "
select starset_submit_score('00000000-0000-0000-0000-000000000011','0-0-0000',:pw,5);
select pg_temp.assert((select week from starset_scores where install_id='00000000-0000-0000-0000-000000000011') = :pw, 'prev week stored');"

case_sql "best score only (800 -> 700 keeps 800 -> 900 takes 900), nickname upserted" "
select starset_submit_score('00000000-0000-0000-0000-000000000002','1-1-0001',:cw,800);
select starset_submit_score('00000000-0000-0000-0000-000000000002','1-1-0001',:cw,700);
select pg_temp.assert((select score from starset_scores where install_id='00000000-0000-0000-0000-000000000002') = 800, 'lower score must not replace');
select starset_submit_score('00000000-0000-0000-0000-000000000002','39-39-9999',:cw,900);
select pg_temp.assert((select score from starset_scores where install_id='00000000-0000-0000-0000-000000000002') = 900, 'higher score replaces');
select pg_temp.assert((select count(*) from starset_scores where install_id='00000000-0000-0000-0000-000000000002') = 1, 'one row per key');
select pg_temp.assert((select nickname from starset_players where install_id='00000000-0000-0000-0000-000000000002') = '39-39-9999', 'nickname upserted');"

case_sql "score 5000001 and -1 rejected, 5000000 accepted" "
select pg_temp.expect_error(\$q\$select starset_submit_score('00000000-0000-0000-0000-000000000003','1-1-0001',to_char(now() at time zone 'utc','IYYYIW')::int,5000001)\$q\$, 'invalid score');
select pg_temp.expect_error(\$q\$select starset_submit_score('00000000-0000-0000-0000-000000000003','1-1-0001',to_char(now() at time zone 'utc','IYYYIW')::int,-1)\$q\$, 'invalid score');
select starset_submit_score('00000000-0000-0000-0000-000000000003','1-1-0001',:cw,5000000);"

case_sql "free-text / out-of-range / malformed nicknames rejected" "
select pg_temp.expect_error(format(\$q\$select starset_submit_score('00000000-0000-0000-0000-000000000004',%L,%s,50)\$q\$, n, :cw), 'invalid nickname')
  from unnest(array['40-1-0000','1-40-0000','01-1-0000','1-1-000','1-1-00000','-1-1-0000','1-1-0000 ','<script>','우주고양이','Bad Word','1_1_0000','']) n;
select pg_temp.expect_error(format(\$q\$select starset_submit_score('00000000-0000-0000-0000-000000000004',null,%s,50)\$q\$, :cw), 'invalid nickname');"

case_sql "next week, week before last and junk weeks rejected" "
select pg_temp.expect_error(format(\$q\$select starset_submit_score('00000000-0000-0000-0000-000000000005','1-1-0001',%s,50)\$q\$, w), 'invalid week')
  from unnest(array[:nw, :ow, 0, 999999, 202600, 202654]) w;"

case_sql "6th call within a minute rejected (5 allowed)" "
select starset_submit_score('00000000-0000-0000-0000-000000000006','2-3-0004',:cw,s) from generate_series(1,5) s;
select pg_temp.expect_error(format(\$q\$select starset_submit_score('00000000-0000-0000-0000-000000000006','2-3-0004',%s,6)\$q\$, :cw), 'rate limited');
select pg_temp.assert((select score from starset_scores where install_id='00000000-0000-0000-0000-000000000006') = 5, '6th not applied');
update starset_submissions set at = now() - interval '61 seconds' where install_id='00000000-0000-0000-0000-000000000006';
select starset_submit_score('00000000-0000-0000-0000-000000000006','2-3-0004',:cw,7);"

case_sql "ordering: score desc, tie -> earlier submission first; equal resubmit keeps old time" "
insert into starset_players(install_id,nickname) values
 ('00000000-0000-0000-0000-00000000000a','1-0-0001'),('00000000-0000-0000-0000-00000000000b','2-0-0002'),('00000000-0000-0000-0000-00000000000c','3-0-0003');
insert into starset_scores(install_id,week,score,submitted_at) values
 ('00000000-0000-0000-0000-00000000000a',:cw,900,'2026-01-02'),
 ('00000000-0000-0000-0000-00000000000b',:cw,900,'2026-01-01'),
 ('00000000-0000-0000-0000-00000000000c',:cw,950,'2026-01-03');
select pg_temp.assert((select string_agg(nickname||':'||rank, ',' order by rank) from starset_leaderboard(:cw,null)) = '3-0-0003:1,2-0-0002:2,1-0-0001:3', 'order');
select starset_submit_score('00000000-0000-0000-0000-00000000000a','1-0-0001',:cw,900)::jsonb as r \gset
select pg_temp.assert(:'r'::jsonb = '{\"rank\":3,\"total\":3}'::jsonb, 'tie resubmit rank ' || :'r');
select pg_temp.assert((select submitted_at from starset_scores where install_id='00000000-0000-0000-0000-00000000000a') = '2026-01-02'::timestamptz, 'tie keeps earlier submitted_at');"

case_sql "own row appended when outside top 50 (55 players); other weeks not mixed" "
insert into starset_players(install_id,nickname)
 select ('00000000-0000-0000-0001-' || lpad(i::text,12,'0'))::uuid, (i % 40) || '-' || (i % 40) || '-' || lpad(i::text,4,'0') from generate_series(1,55) i;
insert into starset_scores(install_id,week,score,submitted_at)
 select ('00000000-0000-0000-0001-' || lpad(i::text,12,'0'))::uuid, :cw, 1001-i, '2026-01-01' from generate_series(1,55) i;
insert into starset_scores(install_id,week,score) values ('00000000-0000-0000-0001-000000000001', :pw, 99999);
select pg_temp.assert((select count(*) from starset_leaderboard(:cw,null)) = 50, 'top 50 only without id');
select pg_temp.assert((select count(*) from starset_leaderboard(:cw,'00000000-0000-0000-0001-000000000055')) = 51, '51 rows with own id');
select pg_temp.assert((select rank||':'||nickname||':'||score||':'||me from starset_leaderboard(:cw,'00000000-0000-0000-0001-000000000055') order by rank desc limit 1) = '55:15-15-0055:946:true', 'own row');
select pg_temp.assert((select count(*) from starset_leaderboard(:cw,'00000000-0000-0000-0001-000000000003') where me) = 1, 'me flag inside top 50');
select pg_temp.assert((select count(*) from starset_leaderboard(:cw,'00000000-0000-0000-0001-000000000003')) = 50, 'no extra row when inside top 50');
select pg_temp.assert((select count(*) from starset_leaderboard(:pw,null)) = 1, 'previous week separate');"

case_sql "forget deletes only that install's rows (anon), unknown id returns 0" "
select starset_submit_score('00000000-0000-0000-0000-0000000000f1','7-7-0007',:cw,300);
select starset_submit_score('00000000-0000-0000-0000-0000000000f2','8-8-0008',:cw,400);
set local role anon;
select starset_forget('00000000-0000-0000-0000-0000000000f1')::jsonb as r \gset
select starset_forget('00000000-0000-0000-0000-0000000000ff')::jsonb as u \gset
reset role;
select pg_temp.assert(:'r'::jsonb = '{\"deleted\":1}'::jsonb, 'got ' || :'r');
select pg_temp.assert(:'u'::jsonb = '{\"deleted\":0}'::jsonb, 'unknown ' || :'u');
select pg_temp.assert(not exists(select 1 from starset_scores where install_id='00000000-0000-0000-0000-0000000000f1'), 'scores gone');
select pg_temp.assert(not exists(select 1 from starset_players where install_id='00000000-0000-0000-0000-0000000000f1'), 'player gone');
select pg_temp.assert((select count(*) from starset_submissions where install_id='00000000-0000-0000-0000-0000000000f1') = 2, 'only last-minute rate rows (submit + forget)');
select pg_temp.assert(exists(select 1 from starset_scores where install_id='00000000-0000-0000-0000-0000000000f2'), 'other install kept');"

case_sql "forget is rate-limited (5 per minute) and null id rejected" "
select starset_forget('00000000-0000-0000-0000-0000000000f3') from generate_series(1,5);
select pg_temp.expect_error(\$q\$select starset_forget('00000000-0000-0000-0000-0000000000f3')\$q\$, 'rate limited');
select pg_temp.expect_error(\$q\$select starset_forget(null)\$q\$, 'install_id required');"

# anon must not reach the tables directly (expect permission errors, not success)
anon_check() { # name, sql, expected pattern
  local out
  out=$(printf 'begin;\nset local role anon;\n%s\nrollback;\n' "$2" | docker exec -i "$CONTAINER" psql -U postgres -d postgres -X -q 2>&1)
  if echo "$out" | grep -qE "$3"; then result "$1" 0 ""; else result "$1" 1 "$out"; fi
}
anon_check "anon cannot select starset_scores"  "select * from starset_scores;" "permission denied for table starset_scores"
anon_check "anon cannot select starset_players" "select * from starset_players;" "permission denied for table starset_players"
anon_check "anon cannot insert starset_scores"  "insert into starset_scores values ('00000000-0000-0000-0000-000000000009',202641,100,now());" "permission denied for table starset_scores"
anon_check "anon cannot insert starset_submissions" "insert into starset_submissions values ('00000000-0000-0000-0000-000000000009',now());" "permission denied for table starset_submissions"
anon_check "authenticated cannot call starset_forget" "reset role; set local role authenticated; select starset_forget('00000000-0000-0000-0000-000000000009');" "permission denied for function starset_forget"
anon_check "authenticated cannot call starset_submit_score" "reset role; set local role authenticated; select starset_submit_score('00000000-0000-0000-0000-000000000009','1-1-0001',202641,1);" "permission denied for function starset_submit_score"

# Through the API gateway with the anon key, as the game does.
ANON_KEY="${STARSET_ANON_KEY:-$(supabase status -o env 2>/dev/null | sed -n 's/^ANON_KEY="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' | head -1)}"
if [ -z "$ANON_KEY" ]; then
  result "REST: anon key from supabase status" 1 "could not read ANON_KEY"
else
  CW=$(python3 -c "import datetime as d;y,w,_=d.datetime.now(d.timezone.utc).isocalendar();print(y*100+w)")
  RID="00000000-0000-0000-00ff-$(printf '%012d' $$)"
  H=(-H "apikey: $ANON_KEY" -H "Authorization: Bearer $ANON_KEY" -H "Content-Type: application/json")
  sub() { curl -s -m 10 -w ' HTTP%{http_code}' -X POST "$API/rest/v1/rpc/starset_submit_score" "${H[@]}" \
    -d "{\"p_install_id\":\"$RID\",\"p_nickname\":\"$1\",\"p_week\":$2,\"p_score\":$3}"; }
  body=$(sub 5-6-0789 "$CW" 640)
  echo "$body" | grep -q '"rank" *: *[0-9].*HTTP200' && result "REST: rpc submit -> $body" 0 "" || result "REST: rpc submit" 1 "$body"
  body=$(curl -s -m 10 -X POST "$API/rest/v1/rpc/starset_leaderboard" "${H[@]}" -d "{\"p_week\":$CW,\"p_install_id\":\"$RID\"}")
  echo "$body" | grep -q '"me" *: *true' && result "REST: rpc leaderboard -> $body" 0 "" || result "REST: rpc leaderboard" 1 "$body"
  # rejected calls roll back, so they do not count toward the limit
  body=$(sub "hello" "$CW" 1); echo "$body" | grep -q 'HTTP400' && result "REST: free-text nickname -> 400" 0 "" || result "REST: nickname 400" 1 "$body"
  for i in 2 3 4 5; do sub 5-6-0789 "$CW" $i >/dev/null; done
  body=$(sub 5-6-0789 "$CW" 10)
  echo "$body" | grep -q 'rate limited.*HTTP429' && result "REST: 6th call -> HTTP 429 rate limited" 0 "" || result "REST: 6th call rate limited" 1 "$body"
  code=$(curl -s -m 10 -o /dev/null -w '%{http_code}' "$API/rest/v1/starset_scores?select=*" "${H[@]}")
  [ "$code" != "200" ] && result "REST: direct table read refused (HTTP $code)" 0 "" || result "REST: direct table read refused" 1 "HTTP $code"
  printf "delete from starset_scores where install_id='%s'; delete from starset_submissions where install_id='%s'; delete from starset_players where install_id='%s';\n" "$RID" "$RID" "$RID" | psqlc >/dev/null 2>&1
fi

echo "----"
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ]
