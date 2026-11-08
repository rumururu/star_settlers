---
slug: retention-update-result-001
status: progress
---

# RESULT 001 — 이탈 지점 측정 (Claude 워커)

지시서: `TASK_001_CODEX.md` (Claude 워커가 대신 수행). 실서버 접속·배포·커밋 없음.

## 변경 파일

| 파일 | 내용 |
|---|---|
| `supabase/migrations/20261108000000_starset_events.sql` (새) | `starset_events` + 요청 제한용 `starset_event_calls`, RLS on·정책 없음·권한 회수, 허용 목록 함수 `starset_event_names()`(SQL 유일 사본), `starset_track(uuid, jsonb)` security definer(anon만 execute), `starset_events_purge()`(1년, 앱 권한 없음), pg_cron 매일 03:17 삭제(확장 불가 시 NOTICE만 내고 마이그레이션은 성공) |
| `supabase/tests/events_live.sh` (새, 실행 권한) | `live.sh` 형식의 실서버 검사. **실행하지 않음** |
| `lib/game/game_telemetry.dart` (새) | `TelemetryEvent` enum(Dart 유일 사본, 서버 이름 `wire`, first_*는 `once`) + 정적 훅 `GameTelemetry.emit/sink` (예외 삼킴) |
| `lib/services/telemetry.dart` (새) | `TelemetryService`: 메모리 큐 + 저장(SharedPreferences 키 `starset_telemetry_v1`, 프로필과 분리), 상한 200(오래된 것 버림), 30초 주기·백그라운드 시 50개씩(한 번에 최대 3묶음) 전송, first_* 1회, day_return 하루 1회, 세션 시작/끝, 생명주기 관찰자 |
| `lib/services/app_state.dart` | `AppState.telemetry` (교체 가능 static, wallet과 같은 방식), `init()`에서 `load()`+`attach()`, `watchAd()` 성공 시 `ad_watch` |
| `lib/game/world.dart` | emit 한 줄씩 10곳 + import 1줄 (아래 표) |
| `lib/game/profile.dart` | emit 2곳 + import 1줄 |
| `lib/ui/shop_screen.dart` | emit 2곳 + import 1줄 (**지시서 수정 가능 목록 밖** — 아래 설명) |
| `docs/PRIVACY_POLICY.md` | 요약에 통계 추가, `## 11. 게임 개선 통계` 신설(이후 절 번호 12~14로 밀림), 데이터 삭제 절에 1년 자동 삭제 문장 |
| `test/telemetry_test.dart` (새) | 20개 테스트 |

`lib/main.dart`는 고치지 않았다 — 세션 시작/끝은 `AppState.init()` → `telemetry.attach()`가 `WidgetsBindingObserver`로 처리한다.
`lib/ui/game_screen.dart`, `test/landscape_layout_test.dart`의 기존 미커밋 변경은 건드리지 않았다. `lib/ui/world_painter.dart`, `lib/ui/sprites.dart`, `assets/`, `pubspec.yaml`도 건드리지 않았다(diff에 보이는 world_painter/sprites 변경은 TASK 002 작업자 것).

## 이벤트별 발생 위치

| 이벤트 | 위치 | 비고 |
|---|---|---|
| `session_start` | `lib/services/telemetry.dart` `sessionStart()` | `attach()`(앱 시작) + 생명주기 `resumed` |
| `session_end`(초) | `lib/services/telemetry.dart` `sessionEnd()` | 생명주기 `paused`/`detached`, 이어서 저장·전송 |
| `day_return`(경과 일수) | `lib/services/telemetry.dart` `sessionStart()` 안 | 기기 현지 날짜 기준 하루 1회, 첫 실행일 = 0 |
| `tutorial_step`(마친 단계 수) | `lib/game/world.dart:2312` (`_checkStory`, `storyIndex++` 직후) | |
| `tutorial_done` | `lib/game/world.dart:2314` | `storyIndex == storySteps.length` |
| `first_warp` | `lib/game/world.dart:838` (`warp` 성공 경로) | |
| `system_reached`(항성계 번호, 1부터) | `lib/game/world.dart:841` (`to > maxSector`) | |
| `first_colony` | `lib/game/world.dart:1139` (`upgradePlanet`, Lv.0→1) | |
| `first_building` | `lib/game/world.dart:1353` (`buildColony`) | 원격 식민지 건물·본거지(home) 건물은 미포함 |
| `first_crew` | `lib/game/world.dart:1864` (`_addCrew`) | 모집·상인·결제 지급 모두 |
| `first_death` | `lib/game/world.dart:2726` (`_damagePlayer`, hp ≤ 0) | |
| `first_kill` | `lib/game/world.dart:3657` (`_onKilled`, 해파리 제외) | |
| `first_boss` | `lib/game/world.dart:3678` (`_onKilled`, `boss`) | |
| `login_claim`(연속일) | `lib/game/profile.dart:299` (`claimLogin`) | |
| `daily_quest_claim` | `lib/game/profile.dart:408` (`claimDaily` 성공) | 보너스 포함 |
| `ad_watch` | `lib/services/app_state.dart:171` (`watchAd` 성공) | 사령관 패스(광고 없음)는 제외 |
| `shop_open` | `lib/ui/shop_screen.dart:41` (`initState`) | |
| `iap_start` | `lib/ui/shop_screen.dart:56` (`_buy`, `money.buy` 직전) | |

shop_screen.dart를 고친 이유: 상점은 `main.dart:67`과 `game_screen.dart:114` 두 곳에서 열리고 결제 호출은 `shop_screen.dart:54` 한 곳뿐이다. game_screen.dart(미커밋 변경 보존 대상)를 피하면서 두 경로를 모두 잡는 유일한 한 줄 지점이라 여기에 넣었다.

first_* 중복 거르기는 서비스가 한다(`_sentOnce`, 저장됨). 게임은 처치마다 `emit(firstKill)`을 불러도 큐에는 설치당 1개만 들어간다.

## 서버 설계 요약

- 요청: `{"p_install_id": uuid, "p_events": [{"n","v","t","app","loc","os"}, ...]}` 최대 50개.
  지시서의 시그니처 `starset_track(p_install_id uuid, p_events jsonb)`를 그대로 지키려고 앱 버전·언어·플랫폼은 항목마다 넣었다(오프라인 큐가 앱 업데이트를 넘어가도 이벤트가 생긴 버전이 남는다).
- 항목 검증(틀리면 그 항목만 버림): 이름 허용 목록, 값 정수 0..100,000,000 또는 null, `app ~ ^[0-9]{1,4}(\.[0-9]{1,4}){0,3}$`, `loc ~ ^[a-z]{2,3}(-[A-Z]{2})?$`, `os ∈ android/ios/web/macos/windows/linux`. 컬럼 check 제약도 같은 규칙.
- `t`(클라이언트 유닉스 초)는 최근 7일 ~ 5분 뒤 범위일 때만 `at`으로 쓰고 아니면 `now()`.
- 오류: install id 없음·배열 아님·50개 초과 → 22023(400), 설치당 롤링 1분 10회 초과 → PT429(429). 반환 `{"stored": n}`.
- 클라이언트: 2xx → 보낸 것 제거, 400 → 그 묶음 버림(다시 보내도 같음), 그 밖(429·5xx·네트워크) → 보존.

## 검증

- `dart analyze lib test` → **No issues found!**
- `flutter test --no-pub test/telemetry_test.dart` → **20개 전부 통과**
  - 큐 상한 200 / 항목 형식 / 저장 후 재로드(로드 전 이벤트는 뒤에) / 깨진 저장 무시
  - 50개 묶음 분할 전송, 1회 최대 3묶음, 오프라인·500·429·503 보존, 400 폐기, 전송 중 들어온 이벤트 보존
  - `enabled=false` 미전송 + 기본값(디버그·테스트 빌드)은 꺼짐
  - first_* 1회(재실행·전송 뒤에도), day_return 하루 1회·경과 일수(0,1,3), session_end 초
  - 게임 훅: sink 없음/예외 안전, 출석·일일 퀘스트 이벤트
  - 새 월드에서 처치 2회·정착 2곳·건물 2회·워프 왕복 → first_kill/first_colony/first_building/first_warp 각 1개, 새 항성계 도착 시 `system_reached` 값 2
  - 동기화: `TelemetryConfig.appVersion` = pubspec 버전 이름, Dart enum 이름 집합 = SQL `starset_event_names()` 집합
- 전체 `flutter test --no-pub` → **+505 / -6**. 실패 6개는 모두 `test/landscape_layout_test.dart:272` "게임 HUD @ portrait (390x844, 360x740) × ko/en/de — 항성계 배지 글자 크기 ≥ 10" (실측 4.0~6.5).
  **이 작업과 무관한 기존 실패**다: 이 검사는 미커밋 `test/landscape_layout_test.dart`에 10-25 08:28에 추가된 것이고(파일 SHA-1 `f5b213c…`, RESULT_007에 적힌 `c5cd8f5…`와 다름), 대상인 `lib/ui/game_screen.dart`(미커밋, 10-25 07:59)는 이 작업과 TASK 002 모두 건드리지 않았다. 이 작업의 변경은 HUD 배치에 영향이 없다(게임 쪽은 sink가 null인 no-op emit 한 줄). gameplay-depth TASK 007 후속으로 처리해야 한다. 나머지 505개(새 telemetry 20개 포함, TASK 002 작업 중 파일 포함) 통과.
- SQL: 임시 로컬 PostgreSQL 15(스크래치 폴더, 검사 후 삭제)에 `anon`/`authenticated` 역할만 만들어 마이그레이션 적용 → 성공(pg_cron 없음 NOTICE, 마이그레이션은 계속). anon으로: 혼합 묶음 11개 중 유효 3개만 저장(소수 값·음수·자유 텍스트 버전·대문자 언어·모르는 플랫폼·문자열 값·비객체 항목 버림, 오래된 `t`는 now로), 테이블 직접 읽기 거부, purge 실행 거부, null id/객체/51개 → 오류, 11번째 호출 rate limited. Supabase 실서버(PostgREST HTTP 코드 매핑)는 `events_live.sh`로 확인 필요.

## 실행하지 못한 검증

- 실서버 적용·`events_live.sh` 실행(지시서상 오케스트레이터 몫). 실행 예:
  `STARSET_API_URL=https://qfhbkfzxhldfycmcwntw.supabase.co STARSET_ANON_KEY=<anon> SUPABASE_ACCESS_TOKEN=<키체인 mkideabox-games-mgmt-token> STARSET_PROJECT_REF=qfhbkfzxhldfycmcwntw supabase/tests/events_live.sh`
- 실기기에서 출시 빌드 전송 확인(디버그 빌드는 보내지 않으므로 출시 빌드/프로파일로 확인하거나, 확인용으로 `AppState.telemetry.enabled = true`를 임시로 켜야 함).

## 남은 리스크 / 오케스트레이터 확인 사항

1. **앱 버전 상수**: `TelemetryConfig.appVersion = '1.0.7'` (package_info 의존성을 늘리지 않으려고 상수). 1.0.8로 올릴 때 pubspec과 같이 바꿔야 하며, 안 바꾸면 `telemetry_test.dart`의 동기화 테스트가 실패해 알려 준다.
2. **pg_cron**: 공용 프로젝트에서 `create extension pg_cron`이 안 되면 자동 삭제가 없다. 배포 후 `events_live.sh` 출력의 `pg_cron purge job` 줄을 확인하고, 없으면 정기적으로 `select public.starset_events_purge();`를 돌려야 한다(개인정보처리방침에 1년 보관 명시).
3. **기존 사용자의 day_return**: 첫 실행일을 업데이트 후 첫 실행 날짜로 잡는다(기존 설치의 진짜 설치일은 모름). 1.0.8 이후 설치자 기준으로 보면 정확하다.
4. **환생/새 게임**: `tutorial_step`·`system_reached`는 새 게임·환생 뒤 다시 나온다(설치 단위 1회 아님). 퍼널은 `count(distinct install_id)`로 집계해야 한다. first_*는 설치당 1회.
5. **세션 수**: 생명주기 `paused`마다 session_end, `resumed`마다 session_start이므로 광고·결제 창으로 앱이 잠시 백그라운드에 가도 세션이 나뉜다.
6. **전송 대상 서버**: 순위표와 같은 `LeaderboardConfig`(mkideabox-games)를 쓴다. 무료 한도 계산: 이벤트 1행 ≈ 100바이트 내외, 설치당 하루 수십 행 수준.
7. **다국어 개인정보처리방침**: 저장소에는 한국어본(`docs/PRIVACY_POLICY.md`)만 있다. 게시본 원본(`~/VSCodeProject/mkideabox/star_settlers/source/content.json`, 10개 언어)은 이 작업 범위 밖이라 고치지 않았다 — 배포 전에 같은 절을 반영해야 한다. 시행일도 갱신 필요.
8. **Play Console 데이터 보안**: "앱 활동 > 앱 내 상호작용(분석)" + "기기 또는 기타 ID" 수집(필수, 공유 없음, 암호화 전송) 추가 필요(PIPELINE_STATE 미결과 동일).
9. **events 삭제 요청**: `starset_forget`(모든 데이터 초기화)는 이벤트를 지우지 않는다. 메일 요청 시 운영자가 install_id로 삭제.
