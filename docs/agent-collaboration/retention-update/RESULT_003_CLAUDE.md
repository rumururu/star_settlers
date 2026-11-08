---
slug: retention-update-result-003
status: progress
---

# RESULT 003 — 첫 5분의 재미 (워커 A)

지시서: `TASK_003_CLAUDE.md`, 공통 규칙: `COMMON_RULES.md`.

## 측정 (밸런스 봇 `test/support/progression_bot.dart`, 새 게임 10분 1세션, seed 1~5)

측정 도구: `tool/r3_first_minutes_test.dart` (`flutter test --no-pub tool/r3_first_minutes_test.dart`).
봇에 `onTick` 훅 한 줄을 추가했다(매 틱 `update` 직후 호출, 기존 동작 변화 없음). 칸 값 = 그 스토리 단계를 **마친** 게임 시각(분:초).

수정 전

| seed | 1 소행성 | 2 해적 | 3 식민지 | 4 강화 | 5 승무원 | 6 임무 | 7 정거장 | 첫 승무원 | 첫 ★3 | 미니 두목 처치 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0:07 | 1:26 | 4:43 | 4:44 | 4:44 | 7:40 | - | 1:36 | - | (없음) |
| 2 | 0:10 | 1:34 | 5:00 | 5:00 | 5:01 | 6:44 | - | 1:40 | - | (없음) |
| 3 | 0:06 | 1:02 | 4:41 | 4:42 | 4:42 | 7:38 | 7:39 | 2:00 | - | (없음) |
| 4 | 0:17 | 1:13 | 4:49 | 4:50 | 4:50 | 6:39 | - | 2:08 | - | (없음) |
| 5 | 0:06 | 1:14 | 1:25 | 1:26 | 1:26 | 4:05 | 4:05 | 1:24 | 1:24 | (없음) |

수정 후

| seed | 1 소행성 | 2 해적 | 3 식민지 | 4 강화 | 5 승무원 | 6 임무 | 7 정거장 | 첫 승무원 | 첫 ★3 | 미니 두목 등장 | 미니 두목 처치 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0:07 | 1:26 | 4:24 | 4:25 | 4:25 | 5:48 | 5:48 | 1:26 | **1:26** | 4:00 | 4:15 |
| 2 | 0:10 | 1:34 | 4:19 | 4:19 | 4:20 | 5:12 | 5:27 | 1:34 | **1:34** | 4:00 | 4:20 |
| 3 | 0:06 | 1:02 | 4:20 | 4:21 | 4:21 | 4:36 | 5:16 | 1:02 | **1:02** | 4:00 | 4:20 |
| 4 | 0:17 | 1:13 | 4:40 | 4:41 | 4:41 | 5:24 | 5:25 | 1:13 | **1:13** | 4:00 | 4:19 |
| 5 | 0:06 | 1:14 | 1:25 | 1:26 | 1:26 | 6:27 | 6:28 | 1:14 | **1:14** | 1:25 | 1:55 |

- 첫 ★3: 수정 전 5판 중 1판(운) → 수정 후 5/5, 1:02~1:34 (기준 ≤ 3:00).
- 미니 두목 등장: 1:25~4:00 (기준 ≤ 4:00). 첫 정착이 4분보다 빠른 seed 5는 정착 직후.
- 정거장 단계(7)까지 마치는 판: 1/5 → 5/5 (10분 안).

미니 두목 vs 시작 함선(강화 0, 승무원 없음, 두목만 쫓다 체력 35%↓면 본거지 수리), 같은 도구의 두 번째 표:

| seed | 부두목 체력 | 처치 시간 | 격추 | 처치 후 무기 Lv |
|---|---|---|---|---|
| 1~8 | 701 | 19.8~23.6초 | 0 | 0 → 1 |

## 구현

### 1. 3분 안의 확실한 보상 (`lib/game/world.dart` `_checkFirstMinutes`)
- **★3 승무원 확정 지급**: 해적 단계(스토리 2단계)를 마치거나 3분(`star3GiftSeconds`) 중 먼저. 조건 `star3GiftDue` = 월드 카운터 `r3Crew`==0 && 튜토리얼 중(`!profile.tutorialDone`) && 첫 항성계. 지급 즉시 자리가 있으면 배치(효과 바로 적용), 미나 대사(`r3_star3Line`), `crewReveal`에 넣어 화면이 **카드 공개 연출**(`lib/ui/crew_reveal.dart` `CrewRevealCard`: 카드 뒤집힘 + 별이 하나씩 켜짐)을 띄운다. 중복 금지: 월드 카운터(저장됨) + 튜토리얼을 마친 프로필(환생한 새 월드)은 대상 아님.
- **미니 두목 '해적 부두목'**: 첫 정착 직후 또는 4분(`miniBossSeconds`) 중 먼저, 첫 항성계(`maxSector`==0)에서 한 번. 카운터 `r3MiniBoss` 0→1(등장)→2(처치). 해적은 저장되지 않으므로 불러온 뒤 1인데 없으면 다시 나온다.
  - 기존 코드 재사용: `_makePirate(PirateKind.raider, hpMul: 10, dmgMul: 0.8)` + `Pirate.miniBoss` 플래그(`models.dart`, 이름표 `r3_miniBossName` → 기존 '이름 붙은 적' 처리로 현상금 ×4·크기·화살표 표시).
  - 본거지 레이저 사거리 밖(안전 반경+600)에서 등장하고, 레이저 한 발 피해는 항성계 두목과 같은 상한(`havenSectorBossDamageRatio`)을 받는다 — 처음엔 레이저가 2초 만에 대신 잡아 싸움이 없었다(측정으로 확인 후 수정).
  - 처치(`_miniBossDown`): 크레딧 +300 + 광석, **함선 무기 +1 무료**(상한이면 그 강화비만큼 크레딧), 큰 글씨 "무기 Lv.N!"(`r3_weaponUp`), 화면 흔들림·효과음, 해적/미나 대사, `mini_boss_kill` emit.

### 2. 항상 보이는 '다음 목표' (`lib/game/next_goal.dart`, 순수 함수 `nextGoal(GameWorld)`)
- 기존 HUD 스토리 카드(선장 카드 아래 🎯 줄)를 **확장**해 목표 칩으로 바꿨다(새 위젯을 따로 띄우지 않음): 아이콘 + 한 줄 + 진행 막대/숫자. 키 `hud-goal`, 최소 터치 48.
- 우선순위: 최종 임무 → 작전 → 미니 두목(체력%) → 튜토리얼 스토리(정착 단계는 "화성 정착까지 💰N") → 쉬는 승무원 배치 → 살 수 있는 정착 → 안정화 장치 → 식민지 레벨업 → 빈 건물 칸(가장 싼 것) → (발전 100%) 워프 → 발전도. **언제나 하나를 돌려준다.**
- 탭하면 `pingGoal()` → 6초간 기존 초록 안내 화살표(`storyTarget`)가 그 목표를 가리킨다(원래 스토리 화살표는 `storyGuideTarget`으로 분리).
- 달성 판정: 목표가 바뀌는 순간 이전 목표의 `isDone`(대상 상태로 확인 — 행성 정착/건물 레벨/배치 수/스토리 번호 등) → 1.6초 초록 빛남 + '✔ 목표 달성!' + `goal_done`(value = `GoalKind.index`). 스토리 단계는 기존 보상 연출이 있어 떠다니는 글씨는 생략.
- 예전 HUD의 `_finalObjective`는 `next_goal.dart`로 옮겼다(문구 동일).

### 3. 세로 HUD 항성계 배지 글자 크기 (TASK 007 후속)
- 원인: 세로에서 배지가 화면 2/5 칸(약 92px)에 아이콘·메뉴와 함께 들어가 FittedBox가 4~6.5px로 줄였다.
- 수정(레이아웃): 세로 HUD 첫 줄을 **배지 + 메뉴 전폭 줄**(`hud-info`)로, 그 아래 **선장 카드(가변) | 미니맵·경보 열(`hud-map`, 폭 상한 화면 38%)**. `_rightColumn(top:, bottom:)`으로 나눠 그렸다. 게이트 완화 없음.
- `test/landscape_layout_test.dart`: `hudRects`에 `hud-map` 추가, 목표 칩(`hud-goal`)은 선장 카드 안에서 잘리지 않아야 한다는 검사 추가(밖으로 나가면 따로 겹침 검사에 걸림).

## 이벤트 발생 위치
- `mini_boss_kill`: `world.dart` `_miniBossDown`
- `goal_done`(value=목표 번호): `world.dart` `_updateGoal`

## 변경 파일
- 새 파일: `lib/game/next_goal.dart`, `lib/ui/crew_reveal.dart`, `test/first_minutes_test.dart`, `test/support/snap.dart`(렌더 하네스), `tool/r3_first_minutes_test.dart`(측정), `tool/r3_render_test.dart`(증거 PNG)
- 테스트 고정 장면: `test/widget_test.dart` 방어막 테스트에서 미니 두목을 처치 상태로(첫 정착 직후 등장하는 두목이 돔을 쏘던 간섭)
- 수정(작은 Edit): `lib/game/world.dart`(첫 5분·목표·레이저 상한), `lib/game/models.dart`(`Pirate.miniBoss`), `lib/ui/game_screen.dart`(목표 칩·세로 HUD·승무원 카드 오버레이), `test/landscape_layout_test.dart`(게이트 키), `test/support/progression_bot.dart`(`onTick`)
- 번역 16키(`r3_*`, 10개 언어) — `tool/arb_add.py` + `flutter gen-l10n`
- `lib/game/missions.dart`는 시험 삼아 바꿨다가 원래대로 되돌림(변경 없음).

## 증거 PNG
`/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/d6219fb0-cb74-4608-b426-4ff0b861575e/scratchpad/003/`
- `before/hud_*` 수정 전(세로 배지 글자 4~6px), `after/hud_{ko,en,de}_{portrait,portrait360,landscape}_x{1.0,1.3}.png`
- `after/reveal_*`(★3 카드), `after/miniboss_*`(목표 칩 '해적 부두목 격파'), `after/goalflash_*`(달성 연출)
- 묶음: `sheet_portrait.png`, `sheet_land.png`, `sheet_reveal.png`
- 넘침·겹침 없음, 세로 배지 13px 그대로 읽힘을 직접 확인. (테스트 엔진에 이모지·Material 아이콘 글꼴이 없어 네모로 보이는 것은 실제 앱과 무관)

## 검증
- `dart analyze lib test`: No issues found (내 파일 기준. 작업 중 `lib/game/rift_world.dart`(워커 B) 경고가 잠시 있었으나 마지막 실행에서는 0)
- `flutter test --no-pub test/first_minutes_test.dart`: 21/21 (★3 지급·중복 금지·저장, 미니 두목 등장 조건·재등장·시작 함선 8 seed 처치, NextGoal 우선순위·완료·goal_done·화살표, **봇 0~30분 목표 빈 프레임 0** 3 seed)
- `flutter test --no-pub test/landscape_layout_test.dart`: 59/59 (이전 실패 6건 포함)
- 전체 `flutter test --no-pub`: RESULT_004 '검증' 절 참고 (balance_test 1건만 남음, 기존 실패)

## 남은 리스크
- `test/balance_test.dart` '뒤 항성계(3~6)…' 1건 실패: `packs < free*0.8`(크레딧 팩 20%↑). **내 기능을 끈 상태에서도 재현**(임시 탐침, ★3·미니 두목 카운터를 미리 채워 끔): 끔 free 7.99일·packs 6.59일(비율 0.82) / 켬 free 7.22·packs 5.98(0.83). 즉 이 작업 이전부터 작업 트리에 있던 실패로 판단, 기대값은 고치지 않았다. ★3 승무원이 끝까지 남아 무료 진행이 약 10% 빨라지는 영향은 있다(다른 단언은 그대로 통과).
- 스토리 5단계 '승무원 1명 영입'은 ★3 지급으로 도달 즉시 완료된다(보상 200 크레딧). 정거장 영입 튜토리얼이 사실상 생략됨 — 의도적으로 유지(첫 세션 속도 우선). 원하면 이 단계를 `relative`로 바꾸면 되지만 봇 기준 정거장 단계가 10분 밖으로 밀린다(측정함).
- 도감(워커 C)의 '도감에 새 항목' 토스트가 세로 HUD 목표 칩 위치에 겹쳐 뜬다(`after/miniboss_ko_portrait.png`). 내 코드가 아니라 결과에만 적는다.
- `lib/ui/game_screen.dart`에 `dart format`을 한 번 돌렸다(내 Edit 직후). 다른 워커 편집과 충돌은 없었으나 서식만 바뀐 줄이 diff에 섞일 수 있다.
- 실기기 확인 안 함(규칙상 금지). 안내 화살표 탭 동작은 단위 테스트로만 확인.
