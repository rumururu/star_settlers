#!/usr/bin/env bash
# 균열 런 순위표(20261108020000_starset_rift.sql)를 mkideabox-games 실서버에 배포하고 검사한다.
# 실행: bash supabase/tests/deploy_rift.sh   (저장소 루트에서)
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

echo "== 배포 전: $(q "select to_regclass('public.starset_rift_scores') t")"
echo "== 배포"
python3 -c "import json;print(json.dumps({'query':open('supabase/migrations/20261108020000_starset_rift.sql').read()}))" |
  curl -s -X POST -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" -H "Content-Type: application/json" -d @- \
  "https://api.supabase.com/v1/projects/$STARSET_PROJECT_REF/database/query"; echo
echo "== 배포 후: $(q "select to_regclass('public.starset_rift_scores') t")"
echo "== 균열 순위 실서버 검사"; bash supabase/tests/rift_live.sh 2>&1 | tail -8
echo "== 기존 개척 순위 회귀 검사"; bash supabase/tests/live.sh 2>&1 | tail -4
