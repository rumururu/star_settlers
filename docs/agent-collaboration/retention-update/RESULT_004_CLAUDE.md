---
slug: retention-update-result-004
status: progress
---

# RESULT 004 — 다시 올 이유 (워커 A)

지시서: `TASK_004_CLAUDE.md`, 공통 규칙: `COMMON_RULES.md`.

## 1. 7일 출석 달력
- 규칙(순수 함수): `lib/game/attendance.dart` `Attendance`
  - 칸 = 연속 출석일의 7 나머지(1~7). 하루 빠지면 1칸부터. 젬은 서버 표(`loginRewards`)를 그대로 보여 주고 수령은 기존 `Profile.claimLogin`(서버 `login` 출처) — **젬 액수·서버 함수 변경 없음**.
  - 클라이언트 보상: 2일 광석 상자(150×보상 배율), 3일 ★2 승무원, 5일 크레딧 묶음(1000×보상 배율), 7일 **출석 전용 함선 스킨**(한 번만, 이후 7일째는 ★3 승무원). 1·4·6일은 젬만.
  - 시계 되돌리기: 기존 `pendingLogin`의 `dayKey` 검사를 그대로 쓴다(같은 날·과거 날짜로는 못 받음).
  - 월드 보상은 프로필에 쌓는다(`pendingOre/pendingCredits/pendingCrew2`, ★3은 기존 `pendingStarCrew`) → 타이틀에서 받아도 다음 게임 진입 때 `AppState.deliverPending` → `GameWorld.deliverCalendarRewards`가 넣는다(광석·크레딧은 `baseRewardMul` 곱, 승무원은 카드 공개). 저장 하위 호환(없으면 0).
- 화면: `lib/ui/calendar_panel.dart` `CalendarPanel` — 기존 AlertDialog를 교체. 7칸(넓으면 한 줄, 좁으면 4+3), 오늘 칸 금색 테두리·빛, 지난 칸 흐림 + 오른쪽 위 체크, 앞으로 칸은 보상 미리보기(아이콘+이름), 7일 칸 금색. 받은 뒤 '오늘 보상을 받았어요' + 내일 미리보기 + 닫기.
- 언제 뜨나
  - 타이틀(`lib/main.dart` `_dailyLogin`): 기존처럼 **저장이 있을 때만**, 받을 게 있으면.
  - 게임 안(`lib/ui/game_screen.dart`): 게임 진입·앱 복귀 때 한 번 확인. 처음 받는 사람은 **스토리 2단계(해적) 완료 후**(`Attendance.showInGame`), 받아 본 사람은 진입 즉시. 타이틀에서 이미 받았으면 안 뜬다. 첫 ★3 카드(003)가 먼저 뜨고 닫으면 달력(한 번에 하나, `star3GiftDue` 확인).
  - `calendar_open`(value=오늘 칸) — 패널이 열릴 때.
- 출석 전용 스킨(`lib/game/cosmetics.dart` `attendanceSkin`, id `attendance`): 무지개 스킨의 색 회전 구조를 재사용해 은하(galaxy) 그림에 색상 회전 150°(청록·금빛). 상점 판매 목록(`shipSkins`)에는 없고 `allShipSkins`로 상점 스킨 탭에 '7일 출석 보상'으로 보이며, 받으면 착용 가능. 게임(`world_painter`), 상점 미리보기, 격납고가 같은 그림을 쓰도록 `lib/ui/skin_image.dart` 추가.

## 2. 내일 보상 미리보기
- `TomorrowCard`('🎁 내일 접속: ⭐10 + ★3 승무원'): 타이틀(저장이 있을 때, 누르면 달력), 일시정지 메뉴(`PauseMenu.banner` 새 선택 인자, 누르면 달력), 달력의 받은 화면.
- 알림: 앱이 백그라운드로 갈 때 `NotificationService.scheduleReturn(tomorrowReward:)` — 기존 22시간 '해적' 알림 자리(id 2)를 출석 보상 미리보기로 바꾼다. 시각 = 떠난 지 20시간 뒤, 단 다음 날 09시보다 이르지 않게(`tomorrowRewardAt`). 알림 설정이 꺼져 있으면 기존 조건(`profile.notifications`)대로 예약하지 않는다. 문구 10개 언어(`r4_notifCalendar*`).

## 3. 승무원 원정
- 규칙: `lib/game/expedition.dart`, 월드 연결 `world.dart`(`startExpedition`/`claimExpedition`/`crewAway`/`idleCrew`).
  - 배치되지 않은 승무원을 1·4·8시간. 동시 2개, 사령관 패스 3개.
  - 실제 시간으로 진행(앱을 꺼도). **보상은 보낼 때 정해서 저장**(불러오기로 다시 굴리기 불가).
  - 시계 되돌리기: `ExpeditionClock`이 본 적 있는 가장 늦은 시각을 '지금'으로 쓴다 → 되돌려도 진행이 줄지 않고, 되돌린 뒤 보낸 원정도 앞선 시각부터 센다. (앞으로 돌리는 것은 서버 없이 막을 수 없음 — 출석 `dayKey`와 같은 수준)
  - 보상: 크레딧·광석 = max(최소 150·20 × 항성계 배율 × 시간, 현재 생산 × 6/20/36분) × 희귀도(★1 1.0 … ★4 1.3). 승무원 경험치 1/3/6(Lv.n→n+1에 n×3, 크레딧 없이 레벨업, `CrewMember.xp` 저장 하위 호환). 8시간만 30% 젬 5개(`earnGems('play')`, 하루 상한 포함) · 10% ★3 승무원(자리 있으면, 카드 공개).
  - 원정 중에는 배치·해고 불가(`toggleAssign`/`dismissCrew`가 거부, UI는 '🚀 원정 중' 표시).
  - 저장: 월드 저장 `expeditions`, `expClock`(없으면 빈 목록). 명단에 없거나 배치된 승무원의 원정은 불러올 때 버린다.
  - 귀환 알림: 백그라운드로 갈 때 원정마다 끝나는 시각에 로컬 알림(id 10~, `r4_notifExpedition*`).
- 화면: `lib/ui/expedition_panel.dart` — 정거장 **승무원 탭 맨 위** 섹션(새 창을 겹쳐 띄우지 않음). 진행 중 카드(초상화·시간·진행 막대·예상 보상·남은 시간), 귀환하면 '귀환! 보상 받기', 빈 자리면 쉬는 승무원 고르기 + 1/4/8시간 버튼(8시간엔 '⭐·★3 행운'). 받은 보상은 패널 안에 한 줄.
- 은하 명예(환생) 규칙: **원정은 월드에 속한다 — 환생하면 원정 중인 승무원도 다른 승무원처럼 사라지고 보상은 없다.** 환생 확인 창에 원정 중 인원을 경고로 보여 준다(`r4_ascendExpWarn`). 귀환했지만 안 받은 보상도 같이 사라진다(받고 환생하라는 경고 문구로 대신).
- `expedition_start`(value=시간), `expedition_claim`(value=시간) — `world.dart`.

## 이벤트 발생 위치
- `calendar_open`: `lib/ui/calendar_panel.dart` `initState` (value = 오늘 칸 1~7)
- `expedition_start` / `expedition_claim`: `lib/game/world.dart` `startExpedition` / `claimExpedition`
- (기존) `login_claim`: `Profile.claimLogin` — 달력 수령 때 그대로 나간다.

## 변경 파일
- 새 파일: `lib/game/attendance.dart`, `lib/game/expedition.dart`, `lib/ui/calendar_panel.dart`, `lib/ui/expedition_panel.dart`, `lib/ui/skin_image.dart`, `test/retention_return_test.dart`(단위), `test/retention_ui_test.dart`(렌더 게이트·흐름)
- 수정(작은 Edit): `lib/game/world.dart`(원정·달력 지급), `lib/game/profile.dart`(대기 보상 3필드), `lib/game/crew.dart`(xp), `lib/game/cosmetics.dart`(출석 스킨·`sprite`/`hue`), `lib/game/next_goal.dart`(원정 중 승무원 제외), `lib/main.dart`(달력·내일 카드), `lib/services/app_state.dart`(지급 한 줄), `lib/services/notifications.dart`(출석·원정 알림), `lib/ui/game_screen.dart`(달력 오버레이·알림 인자·일시정지 카드·환생 경고), `lib/ui/pause_menu.dart`(`banner`), `lib/ui/station_panel.dart`(원정 섹션·원정 중 표시), `lib/ui/shop_screen.dart`·`hangar_screen.dart`·`world_painter.dart`(스킨 그림 빌려 쓰기)
- 번역 32키(`r4_*`, 10개 언어) — `tool/arb_add.py`

## 증거 PNG
`/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/d6219fb0-cb74-4608-b426-4ff0b861575e/scratchpad/004/`
(파일명 `<화면>_<언어>_<portrait|landscape>_x<배율>.png`, ko/en/de × 세로 390×844 · 가로 800×360 × 1.0/1.3)
- `calendar_*`(받기 전), `calendar_claimed_*`(받은 뒤·내일 미리보기), `expedition_*`(보내기), `expedition_done_*`(귀환), `pause_*`(일시정지 카드), `title_*`(타이틀 카드), `reveal_*`(승무원 카드), `title_calendar_ko.png`(타이틀에서 자동으로 뜬 달력), `game_reveal_ko.png` → `game_calendar_ko.png`(게임 첫 세션: ★3 카드 다음 달력)
- 묶음: `../sheet_cal.png`, `../sheet_cal2.png`, `../sheet_land4.png`, `../sheet_exp2.png`, `../sheet_rev.png`, `../sheet_title.png`, `../sheet_game.png`
- 직접 보고 고친 것: 원정 카드 받기 버튼이 옆에 있으면 가로·독일어에서 정보 칸이 50px로 줄어 넘침 → 아래로, 가로 달력에서 받기 버튼이 스크롤 밖 → 설명보다 먼저, 받은 뒤 닫기 버튼 → 내일 카드와 나란히, 가로 승무원 카드 확인 버튼이 스크롤 밖 → 그림 왼쪽·내용 오른쪽, 지난 칸 체크가 젬 숫자를 가림 → 칸 모서리로.

## 검증 (003+004 최종)
- `dart analyze lib test`: No issues found
- `flutter test --no-pub test/retention_return_test.dart`: 21/21 (달력 칸 연속·끊김·시계 되돌림, 상태, 보상·스킨 1회, 저장, 지급, 첫날 게임 안 표시 조건, 내일 칸, 알림 시각, 원정 슬롯 2/3·배치/원정 중 거부·시간 경과·보상 범위·8시간 행운·저장/복원·시계 되돌림·경험치)
- `flutter test --no-pub test/retention_ui_test.dart`: 11/11 (렌더 게이트 6화면 × ko/en/de × 세로·가로 × 1.0/1.3 넘침 0, 받기 버튼 흐름, 타이틀 자동 달력, 게임 첫 세션 ★3 카드 → 달력 순서)
- 전체 `flutter test --no-pub`: 627 통과 / 3 실패 → 그중 내 변경 때문이던 2건 수정 후 해당 파일 재실행 139/139 통과:
  - `test/story_test.dart` '출석 보상을 표시한다': 예전 AlertDialog 제목을 찾던 기대 → 달력 패널(`calendar-panel`)로 바꿈(의도한 UI 교체).
  - `test/widget_test.dart` '식민지 방어막…': 첫 정착 직후 나온 미니 두목(003)이 돔을 쏴서 재충전 값이 달라짐 → 그 고정 장면에서만 미니 두목을 처치 상태로 둠(게임 코드 변경 없음).
  - 남은 1건 `test/balance_test.dart` 뒤 항성계 '크레딧 팩 20%↑': 내 기능을 끈 상태에서도 재현(RESULT_003 남은 리스크) — 기대값 수정하지 않음.

## 남은 리스크
- 원정 '앞으로 돌린 시계'는 막지 못한다(서버 시간 없음). 젬은 `play` 하루 상한 안이라 피해가 제한된다.
- 출석 전용 스킨은 그림 생성 없이 은하 스킨의 색만 돌린 것 — 실제 기기에서 색감 확인 필요(테스트 렌더 엔진에서는 함선 그림을 그리지 않았다).
- 게임 안 달력은 진입·복귀 때만 확인한다(플레이 중 자정을 넘기면 다음 복귀 때).
- 상점 '무료' 탭의 예전 7칸 출석 띠는 그대로 두었다(젬만 표시). 달력과 문구가 겹치면 정리 필요.
- 새 통계 이벤트 이름은 만들지 않았다.
