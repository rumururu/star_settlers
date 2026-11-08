---
slug: retention-update-task-001
status: progress
---

# TASK 001 — 이탈 지점 측정 (Codex)

## 목표
신규 사용자가 **어디서 그만두는지** 서버에서 퍼널로 볼 수 있게 한다. 1~2주 뒤 "튜토리얼 N단계까지 몇 %"를 답할 수 있어야 한다.

## 배경
- `docs/agent-collaboration/retention-update/PIPELINE_STATE.md` 근거 데이터: 70%가 첫 출석 보상조차 안 받음. 지금은 분석 이벤트가 전혀 없다.
- 공용 백엔드 규칙: `/Volumes/home_extension/mkideabox-corp-process/processes/infrastructure/game-shared-backend.md` (읽을 것). 이벤트는 순위표와 같은 **`mkideabox-games`** 프로젝트에 `starset_` 접두사로 둔다.
- 기존 패턴: `supabase/migrations/20261011000000_starset_leaderboard.sql`(RLS 잠금 + security definer 함수 + 요청 제한), 클라이언트 `lib/services/leaderboard.dart`의 `_call`, 설치 ID `AppState.leaderboard.installId`(`lib/services/app_state.dart:28`).

## 구현 요구
1. **마이그레이션** `supabase/migrations/20261108000000_starset_events.sql`:
   - 테이블 `starset_events(install_id uuid, name text, value int null, app_version text, locale text, platform text, at timestamptz default now())`, 인덱스 `(name, at)`, `(install_id, at)`.
   - RLS on, 정책 없음, public/anon/authenticated 권한 회수.
   - 함수 `starset_track(p_install_id uuid, p_events jsonb)` security definer: 배열 최대 50개, `name`은 허용 목록(아래)만, 설치당 분당 호출 제한(기존 submissions 패턴), 잘못된 항목은 버리고 `{"stored": n}` 반환. anon에 execute 부여.
   - 자유 텍스트 금지(어린이 안전 원칙과 같은 이유). `app_version`/`locale`/`platform`도 정규식으로 제한.
2. **이벤트 목록** (이름 고정, 한 설치당 "first_*"는 한 번만 보낸다):
   - `session_start`, `session_end`(value=초)
   - `tutorial_step`(value=단계 번호 — 튜토리얼/스토리 진행 코드를 찾아 단계마다), `tutorial_done`
   - `first_kill`, `first_colony`, `first_building`, `first_crew`, `first_warp`, `first_boss`, `first_death`
   - `system_reached`(value=항성계 번호), `login_claim`(value=연속일), `daily_quest_claim`, `ad_watch`, `shop_open`, `iap_start`
   - `day_return`(value=첫 실행 후 경과 일수, 하루 한 번)
   - 003~006에서 이벤트를 더 붙일 수 있도록 목록은 Dart 한 곳(enum)과 SQL 한 곳에만 둔다.
3. **클라이언트** `lib/services/telemetry.dart`: 메모리 큐 + 저장(앱 종료·오프라인에도 유실 최소, 상한 200개, 넘치면 오래된 것 버림), 30초마다 또는 앱 백그라운드 전환 시 일괄 전송. 실패해도 게임에 영향 없음. 디버그/테스트에서는 전송하지 않는 스위치(기존 leaderboard/wallet 테스트 주입 방식과 같게).
   - 게임 로직(`lib/game/`)은 서비스에 의존하지 않게: `Profile.onEarn`처럼 정적 콜백 훅 하나(`GameTelemetry.emit`)를 두고 `AppState`에서 연결.
4. **개인정보처리방침** `docs/PRIVACY_POLICY.md`(+ 다른 언어본이 있으면 같이): "게임 개선 통계" 절 추가 — 무작위 설치 ID, 게임 진행 이벤트 이름·숫자, 앱 버전·언어·플랫폼, Supabase 서울, 개인 식별 정보 없음, 보관 기간(1년, 마이그레이션에 pg_cron 삭제가 가능하면 같이, 아니면 문서에 운영 삭제로 명시).

## 수용 기준
- 단위 테스트: 큐 상한, 일괄 전송, 실패 시 보존, first_* 1회 보장, day_return 하루 1회, 테스트 모드 미전송.
- 위젯/월드 테스트: 새 월드에서 첫 처치·첫 정착·워프 시 해당 이벤트가 1번씩 emit.
- SQL은 로컬 실행 불가하면 `supabase/tests/`에 기존 `live.sh` 형식으로 실서버 검사 스크립트(`events_live.sh`)를 만들어 둔다. **실서버 적용·실행은 하지 않는다**(Claude가 함).

## 검증 (반드시)
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
dart analyze lib test
flutter test --no-pub
```

## 수정 가능
`supabase/migrations/`(새 파일), `supabase/tests/`(새 파일), `lib/services/telemetry.dart`(새), `lib/services/app_state.dart`, `lib/game/`의 이벤트 발생 지점(emit 한 줄 수준), `lib/main.dart`(세션 시작/종료 훅), `docs/PRIVACY_POLICY*.md`, `test/`(새 테스트).

## 금지
- `lib/ui/world_painter.dart`, `assets/` 수정 (TASK 002가 동시에 작업 중)
- `lib/ui/game_screen.dart`, `test/landscape_layout_test.dart`의 기존 미커밋 변경 훼손
- 실서버 접속·배포, git commit/checkout/reset/revert/stash, 기기·에뮬레이터 실행

## 결과
`docs/agent-collaboration/retention-update/RESULT_001_CODEX.md`: 변경 파일, 이벤트별 발생 위치(file:line), 검증 결과, 남은 리스크.
