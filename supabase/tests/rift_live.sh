#!/usr/bin/env bash
# supabase/tests/rift_live.sh — Rift Run (균열 런) leaderboard checks against the deployed shared game project, through the
# public REST API with the anon key (what the game uses). Mirrors supabase/tests/live.sh: rows go into the real current
# ISO week under fresh random install ids and are deleted at the end through the Management API (by install_id) when
# SUPABASE_ACCESS_TOKEN and STARSET_PROJECT_REF are set.
#   STARSET_API_URL=https://<ref>.supabase.co STARSET_ANON_KEY=... \
#   [SUPABASE_ACCESS_TOKEN=... STARSET_PROJECT_REF=<ref>] supabase/tests/rift_live.sh
# Bounds (supabase/migrations/20261108020000_starset_rift.sql, lib/game/rift.dart RiftScore.maxForWave):
#   waves 1 -> max 450, waves 10 -> max 95700.
set -u
API="${STARSET_API_URL:?}"; KEY="${STARSET_ANON_KEY:?}"
H=(-H "apikey: $KEY" -H "Authorization: Bearer $KEY" -H "Content-Type: application/json")
pass=0; fail=0
ok(){ echo "PASS  $1"; pass=$((pass+1)); }; no(){ echo "FAIL  $1 — $2"; fail=$((fail+1)); }
uuid(){ python3 -c "import uuid;print(uuid.uuid4())"; }
isoweek(){ python3 -c "import datetime as d;y,w,_=(d.datetime.now(d.timezone.utc)+d.timedelta(days=$1)).isocalendar();print(y*100+w)"; }
A=$(uuid); B=$(uuid); C=$(uuid); D=$(uuid); E=$(uuid); F=$(uuid)
CW=$(isoweek 0); PW=$(isoweek -7); NW=$(isoweek 7)
submit(){ curl -s -m 10 -w ' HTTP%{http_code}' -X POST "$API/rest/v1/rpc/starset_submit_rift" "${H[@]}" \
  -d "{\"p_install_id\":\"$1\",\"p_nickname\":\"$2\",\"p_week\":$3,\"p_score\":$4,\"p_waves\":$5}"; }
weekly(){ curl -s -m 10 -w ' HTTP%{http_code}' -X POST "$API/rest/v1/rpc/starset_submit_score" "${H[@]}" \
  -d "{\"p_install_id\":\"$1\",\"p_nickname\":\"$2\",\"p_week\":$3,\"p_score\":$4}"; }
forget(){ curl -s -m 10 -w ' HTTP%{http_code}' -X POST "$API/rest/v1/rpc/starset_forget" "${H[@]}" -d "{\"p_install_id\":\"$1\"}"; }
board(){ curl -s -m 10 -X POST "$API/rest/v1/rpc/starset_rift_board" "${H[@]}" -d "{\"p_week\":$1,\"p_install_id\":\"$2\"}"; }

r=$(submit $A "12-7-0427" $CW 12000 8); echo "$r" | grep -q '"rank" *: *[0-9].*HTTP200' && ok "valid rift submit -> ${r}" || no "valid submit" "$r"
submit $A "12-7-0427" $CW 7000 9 >/dev/null; r=$(board $CW $A); echo "$r" | grep -q '"nickname":"12-7-0427","score":12000,"waves":8,"me":true' && ok "lower score keeps the best (12000, wave 8), caller row marked" || no "best only / me" "$r"
submit $A "12-7-0427" $CW 15000 9 >/dev/null; r=$(board $CW $A); echo "$r" | grep -q '"score":15000,"waves":9,"me":true' && ok "higher score replaces score and waves" || no "higher replaces" "$r"
r=$(submit $D "39-0-9999" $PW 10 1); echo "$r" | grep -q 'HTTP200' && ok "previous ISO week accepted" || no "prev week" "$r"
n=$(board $CW 00000000-0000-0000-0000-000000000000 | python3 -c "import json,sys;print(len(json.load(sys.stdin)))"); [ "$n" -ge 1 ] && [ "$n" -le 50 ] && ok "top-50 list returns $n rows (<= 50)" || no "top 50" "$n"
r=$(submit $B "Bad Name" $CW 50 1); echo "$r" | grep -q 'HTTP400' && ok "free-text nickname rejected (400)" || no "nickname text" "$r"
r=$(submit $B "1-1-0001" $NW 50 1); echo "$r" | grep -q 'HTTP400' && ok "next week rejected (400)" || no "week" "$r"
r=$(submit $B "1-1-0001" $CW 95701 10); echo "$r" | grep -q 'HTTP400' && ok "score above absolute cap 95700 rejected (400)" || no "score cap" "$r"
r=$(submit $B "1-1-0001" $CW 451 1); echo "$r" | grep -q 'HTTP400' && ok "score above the wave-1 bound (450) rejected (400)" || no "wave bound" "$r"
r=$(submit $B "1-1-0001" $CW 450 1); echo "$r" | grep -q 'HTTP200' && ok "score exactly at the wave-1 bound accepted" || no "wave bound exact" "$r"
r=$(submit $B "1-1-0001" $CW -1 1); echo "$r" | grep -q 'HTTP400' && ok "negative score rejected (400)" || no "score neg" "$r"
r=$(submit $B "1-1-0001" $CW 10 0); echo "$r" | grep -q 'HTTP400' && ok "waves 0 rejected (400)" || no "waves 0" "$r"
r=$(submit $B "1-1-0001" $CW 10 11); echo "$r" | grep -q 'HTTP400' && ok "waves 11 rejected (400)" || no "waves 11" "$r"
for s in 10 11 12 13; do submit $C "3-4-0005" $CW $s 1 >/dev/null; done; weekly $C "3-4-0005" $CW 5 >/dev/null; r=$(submit $C "3-4-0005" $CW 15 1)
echo "$r" | grep -q 'HTTP429' && ok "rate limit shared with the pioneer board: 6th call in a minute -> 429" || no "rate limit" "$r"
weekly $E "6-6-0006" $CW 77 >/dev/null; submit $E "6-6-0006" $CW 300 2 >/dev/null
r=$(forget $E); echo "$r" | grep -q '"deleted" *: *2.*HTTP200' && ok "forget deletes pioneer + rift rows -> ${r}" || no "forget" "$r"
r=$(board $CW $E); echo "$r" | grep -q '"me":true' && no "forget left a rift row" "$r" || ok "forgotten install no longer on the rift board"
submit $F "7-7-0007" $CW 100 1 >/dev/null; r=$(forget $F); echo "$r" | grep -q '"deleted" *: *1.*HTTP200' && ok "forget of a rift-only install -> ${r}" || no "forget rift-only" "$r"
r=$(curl -s -m 10 -w ' HTTP%{http_code}' "$API/rest/v1/starset_rift_scores?select=*" "${H[@]}"); echo "$r" | grep -qE 'HTTP40[13]' && ok "direct rift table read refused" || no "direct read" "$r"
r=$(curl -s -m 10 -w ' HTTP%{http_code}' -X POST "$API/rest/v1/starset_rift_scores" "${H[@]}" -d '{"install_id":"'$A'","week":'$CW',"score":100,"waves":1}'); echo "$r" | grep -qE 'HTTP40[13]' && ok "direct rift table insert refused" || no "direct insert" "$r"
r=$(curl -s -m 10 -w ' HTTP%{http_code}' -X POST "$API/rest/v1/rpc/starset_rift_max" "${H[@]}" -d '{"p_waves":10}'); echo "$r" | grep -qE 'HTTP40[0-9]' && ok "helper starset_rift_max not callable by anon" || no "rift_max exposed" "$r"

if [ -n "${SUPABASE_ACCESS_TOKEN:-}" ] && [ -n "${STARSET_PROJECT_REF:-}" ]; then
  ids="'$A','$B','$C','$D','$E','$F'"
  q="delete from starset_rift_scores where install_id in ($ids); delete from starset_scores where install_id in ($ids); delete from starset_submissions where install_id in ($ids); delete from starset_players where install_id in ($ids); select (select count(*) from starset_rift_scores where install_id in ($ids)) + (select count(*) from starset_scores where install_id in ($ids)) + (select count(*) from starset_players where install_id in ($ids)) + (select count(*) from starset_submissions where install_id in ($ids)) as left_rows;"
  r=$(curl -s -m 20 -X POST "https://api.supabase.com/v1/projects/$STARSET_PROJECT_REF/database/query" -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d "$(python3 -c 'import json,sys;print(json.dumps({"query":sys.argv[1]}))' "$q")")
  echo "cleanup: $r"
fi
echo "----"; echo "passed $pass, failed $fail"; [ $fail -eq 0 ]
