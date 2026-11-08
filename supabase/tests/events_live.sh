#!/usr/bin/env bash
# supabase/tests/events_live.sh — starset_track (gameplay funnel events) checks against the deployed shared game
# project, through the public REST API with the anon key (what the game uses). Test rows go in under fresh random
# install ids and are deleted at the end through the Management API when SUPABASE_ACCESS_TOKEN and STARSET_PROJECT_REF
# are set (that also verifies stored values and reports whether the pg_cron purge job exists).
#   STARSET_API_URL=https://<ref>.supabase.co STARSET_ANON_KEY=... \
#   [SUPABASE_ACCESS_TOKEN=... STARSET_PROJECT_REF=<ref>] supabase/tests/events_live.sh
# Migration: supabase/migrations/20261108000000_starset_events.sql
set -u
API="${STARSET_API_URL:?}"; KEY="${STARSET_ANON_KEY:?}"
H=(-H "apikey: $KEY" -H "Authorization: Bearer $KEY" -H "Content-Type: application/json")
pass=0; fail=0
ok(){ echo "PASS  $1"; pass=$((pass+1)); }; no(){ echo "FAIL  $1 — $2"; fail=$((fail+1)); }
uuid(){ python3 -c "import uuid;print(uuid.uuid4())"; }
A=$(uuid); B=$(uuid); C=$(uuid)
NOW=$(date +%s)
track(){ curl -s -m 10 -w ' HTTP%{http_code}' -X POST "$API/rest/v1/rpc/starset_track" "${H[@]}" \
  -d "{\"p_install_id\":$1,\"p_events\":$2}"; }
ev(){ # name value(or null) [app loc os t]
  echo "{\"n\":\"$1\",\"v\":$2,\"app\":\"${3:-1.0.8}\",\"loc\":\"${4:-ko}\",\"os\":\"${5:-android}\",\"t\":${6:-$NOW}}"; }

# valid batch: 3 good rows, 6 bad rows dropped silently
GOOD="$(ev tutorial_step 3),$(ev first_kill null 1.0.8 pt-BR ios),$(ev day_return 2 1.0.8 en web 1)"
BAD="$(ev not_an_event 1),$(ev session_end 1.5),$(ev session_end -1),$(ev day_return 1 'hello world'),$(ev day_return 1 1.0.8 KO),$(ev day_return 1 1.0.8 ko amiga)"
r=$(track "\"$A\"" "[$GOOD,$BAD,5,\"x\"]"); echo "$r" | grep -q '"stored" *: *3.*HTTP200' && ok "valid rows stored, invalid dropped -> ${r}" || no "mixed batch" "$r"
r=$(track "\"$A\"" '[]'); echo "$r" | grep -q '"stored" *: *0.*HTTP200' && ok "empty array ok" || no "empty" "$r"
r=$(track null '[]'); echo "$r" | grep -q 'HTTP400' && ok "missing install id rejected (400)" || no "install id" "$r"
r=$(track "\"$B\"" '{"n":"first_kill"}'); echo "$r" | grep -q 'HTTP400' && ok "non-array rejected (400)" || no "array" "$r"
BIG=$(python3 -c "import json;print(json.dumps([{'n':'shop_open','app':'1.0.8','loc':'ko','os':'android'}]*51))")
r=$(track "\"$B\"" "$BIG"); echo "$r" | grep -q 'HTTP400' && ok "51 items rejected (400)" || no "max 50" "$r"
FIFTY=$(python3 -c "import json;print(json.dumps([{'n':'shop_open','app':'1.0.8','loc':'ko','os':'android'}]*50))")
r=$(track "\"$B\"" "$FIFTY"); echo "$r" | grep -q '"stored" *: *50.*HTTP200' && ok "50 items accepted" || no "50 items" "$r"
for i in 1 2 3 4 5 6 7 8 9 10; do track "\"$C\"" '[]' >/dev/null; done; r=$(track "\"$C\"" '[]')
echo "$r" | grep -q 'HTTP429' && ok "11th call in a minute rate-limited (429)" || no "rate limit" "$r"
r=$(curl -s -m 10 -w ' HTTP%{http_code}' "$API/rest/v1/starset_events?select=*" "${H[@]}"); echo "$r" | grep -qE 'HTTP40[13]' && ok "direct table read refused" || no "direct read" "$r"
r=$(curl -s -m 10 -w ' HTTP%{http_code}' -X POST "$API/rest/v1/starset_events" "${H[@]}" -d '{"install_id":"'$A'","name":"first_kill","app_version":"1","locale":"ko","platform":"android"}'); echo "$r" | grep -qE 'HTTP40[13]' && ok "direct table insert refused" || no "direct insert" "$r"
r=$(curl -s -m 10 -w ' HTTP%{http_code}' -X POST "$API/rest/v1/rpc/starset_events_purge" "${H[@]}" -d '{}'); echo "$r" | grep -qE 'HTTP40[134]' && ok "purge not callable by anon" || no "purge exposed" "$r"

if [ -n "${SUPABASE_ACCESS_TOKEN:-}" ] && [ -n "${STARSET_PROJECT_REF:-}" ]; then
  sql(){ curl -s -m 20 -X POST "https://api.supabase.com/v1/projects/$STARSET_PROJECT_REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d "$(python3 -c 'import json,sys;print(json.dumps({"query":sys.argv[1]}))' "$1")"; }
  r=$(sql "select name, value, locale, platform, abs(extract(epoch from at) - $NOW) < 600 as recent from starset_events where install_id = '$A' order by name")
  echo "stored rows: $r"
  echo "$r" | grep -q '"name":"tutorial_step","value":3,"locale":"ko","platform":"android","recent":true' && ok "tutorial_step row stored with value and client time" || no "row tutorial_step" "$r"
  echo "$r" | grep -q '"name":"first_kill","value":null,"locale":"pt-BR","platform":"ios"' && ok "first_kill row stored (null value, pt-BR, ios)" || no "row first_kill" "$r"
  echo "$r" | grep -q '"name":"day_return","value":2,"locale":"en","platform":"web","recent":true' && ok "implausible client time replaced by server time" || no "row day_return" "$r"
  r=$(sql "select count(*) as jobs from cron.job where jobname = 'starset_events_purge'"); echo "pg_cron purge job: $r (if this errors, pg_cron is off: purge by hand, see migration)"
  ids="'$A','$B','$C'"
  r=$(sql "delete from starset_events where install_id in ($ids); delete from starset_event_calls where install_id in ($ids); select (select count(*) from starset_events where install_id in ($ids)) + (select count(*) from starset_event_calls where install_id in ($ids)) as left_rows;")
  echo "cleanup: $r"
fi
echo "----"; echo "passed $pass, failed $fail"; [ $fail -eq 0 ]
