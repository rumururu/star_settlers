---
slug: retention-update-common-rules
status: spec
---

# 공통 규칙 (TASK 003~006 워커 전원)

같은 작업 트리에서 워커 3명이 **동시에** 작업한다 (A: 003→004, B: 005, C: 006).

## 동시 작업
- 공유 파일(`lib/game/world.dart`, `lib/game/profile.dart`, `lib/main.dart`, `lib/ui/game_screen.dart`, `lib/ui/pause_menu.dart`, `lib/services/app_state.dart`)은 **편집 직전에 다시 읽고**, 작은 Edit로만 고친다. 파일 전체 다시 쓰기(Write) 금지.
- 번역 키는 **`python3 tool/arb_add.py <keys.json>` 로만** 추가한다(파일 잠금, 10개 언어 필수). 그다음 `flutter gen-l10n`. ARB 직접 편집 금지. 키 접두사: A=`r3_`/`r4_`, B=`rift_`, C=`codex_`.
- 10개 언어(ko en ja zh de fr es pt ru id) 모두 자연스러운 번역. 한국어가 원문. 줄바꿈 필요한 한국어는 기존 `keepAll` 사용.
- 다른 워커 작업 중 생긴 컴파일 오류·테스트 실패는 고치지 말고 결과에 적는다(내 파일 때문이 아닌지 먼저 확인).
- 기존 미커밋 변경(`lib/ui/game_screen.dart`의 세로 HUD, `test/landscape_layout_test.dart`) 보존.

## 게임 규칙
- **젬**은 서버 지갑만 지급한다(`supabase/wallet/migrations/20261012000000_starset_wallet.sql` `starset_earn`). 허용 출처: `ach`(고정 목록), `play`(하루 상한), `login`(서버가 연속일로 계산), `quest`, `ad`. 새 기능의 젬 보상은 **`Profile.earnGems('play', …)`만** 쓴다(하루 상한에 포함). 서버 함수는 고치지 않는다.
- 크레딧·광석·승무원·외형·경험치는 클라이언트 보상으로 자유.
- 통계 이벤트는 이미 정의돼 있다(`lib/game/game_telemetry.dart`, 서버 배포 완료): `goal_done`, `mini_boss_kill`, `calendar_open`, `expedition_start`, `expedition_claim`, `rift_start`, `rift_end`, `codex_open`. `GameTelemetry.emit(...)` 한 줄로 보낸다. 새 이벤트 이름이 필요하면 만들지 말고 결과에 적는다.
- UI는 `~/.claude/GAME_UI_ARCHITECTURE.md` 기준(디자인 토큰 `lib/ui/tokens.dart`, 터치 48dp, 모달 레이어). 기존 패널 스타일(`kPanelColor`, `Ts`, `Space`)을 따른다.
- 저장: 새 상태는 기존 저장 형식(`Profile` toJson/fromJson 또는 world save)에 **하위 호환**으로 추가(없으면 기본값).

## 검증 (반드시)
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
dart analyze lib test
flutter test --no-pub
```
+ 새 화면은 임시 렌더 하네스로 ko·en·de(긴 문구), 세로 390×844·가로 800×360, 글자 배율 1.3에서 그려 넘침·겹침 없음을 확인하고 PNG를
`/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/d6219fb0-cb74-4608-b426-4ff0b861575e/scratchpad/<task>/`에 저장. 그림을 직접 보고(1200px 이하로 줄여서) 판정한다.
기존 위젯 테스트의 넘침 검사 패턴(`test/landscape_layout_test.dart`의 `expectNoOverflow`, `test/invasion_test.dart`)을 새 화면에 대한 **게이트 테스트**로 남긴다.

## 금지
git commit/checkout/reset/revert/stash, 기기·에뮬레이터 실행, 실서버 접속, 서버 SQL 수정(005의 새 순위 테이블 마이그레이션 *파일 작성*은 예외 — 배포는 오케스트레이터).

## 결과
`RESULT_00N_CLAUDE.md`(한국어): 변경 파일, 설계 결정, 이벤트 발생 위치, 증거 PNG 경로, 검증 결과, 남은 리스크.
