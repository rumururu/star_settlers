#!/usr/bin/env bash
# 통계 이벤트 허용 목록 v3(20261111000000_starset_events_v3.sql: surface_start/surface_end 추가)를 mkideabox-games 실서버에 배포하고 검사한다.
# 실행: bash /Volumes/home_extension/AndroidStudioProjects/star_settlers/supabase/tests/deploy_events_v3.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
export STARSET_PROJECT_REF=qfhbkfzxhldfycmcwntw
export SUPABASE_ACCESS_TOKEN=$(security find-generic-password -a mkideabox-games-mgmt-token -s supabase -w)
export STARSET_API_URL=https://$STARSET_PROJECT_REF.supabase.co
export STARSET_ANON_KEY=$(curl -s -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
  "https://api.supabase.com/v1/projects/$STARSET_PROJECT_REF/api-keys?reveal=true" |
  python3 -c "import json,sys; print([k['api_key'] for k in json.load(sys.stdin) if k['name']=='anon'][0])")
q() { python3 -c "import json,sys;print(json.dumps({'query':sys.argv[1]}))" "$1" |
  curl -s -X POST -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d @- \
  "https://api.supabase.com/v1/projects/$STARSET_PROJECT_REF/database/query"; echo; }

has="select 'surface_start' = any(public.starset_event_names()) as surface"
echo "== 배포 전: $(q "$has")"
echo "== 배포"
python3 -c "import json;print(json.dumps({'query':open('supabase/migrations/20261111000000_starset_events_v3.sql').read()}))" |
  curl -s -X POST -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d @- \
  "https://api.supabase.com/v1/projects/$STARSET_PROJECT_REF/database/query"; echo
echo "== 배포 후: $(q "$has")"
echo "== 새 이벤트 저장 검사 (시험 행은 바로 지운다)"
ID=$(python3 -c "import uuid;print(uuid.uuid4())"); NOW=$(date +%s)
curl -s -m 10 -X POST "$STARSET_API_URL/rest/v1/rpc/starset_track" -H "apikey: $STARSET_ANON_KEY" \
  -H "Authorization: Bearer $STARSET_ANON_KEY" -H "Content-Type: application/json" \
  -d "{\"p_install_id\":\"$ID\",\"p_events\":[{\"n\":\"surface_start\",\"v\":1,\"app\":\"1.0.9\",\"loc\":\"ko\",\"os\":\"android\",\"t\":$NOW},{\"n\":\"surface_end\",\"v\":0,\"app\":\"1.0.9\",\"loc\":\"ko\",\"os\":\"android\",\"t\":$NOW}]}"; echo
echo "   저장된 행: $(q "select name, value from public.starset_events where install_id = '$ID' order by name")"
echo "   정리: $(q "delete from public.starset_events where install_id = '$ID' returning name")"
echo "== 기존 이벤트 회귀 검사"; bash supabase/tests/events_live.sh 2>&1 | tail -4
