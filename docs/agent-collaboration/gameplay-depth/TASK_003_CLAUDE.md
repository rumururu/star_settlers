---
slug: gameplay-depth-task-003
status: active
---

# TASK 003 — 식민지 특화 (Claude 워커)

## 목표
식민지가 Lv.5에 오르면 **특화 하나를 고르게** 해서 행성마다 역할이 갈리게 한다.
레벨업만 누르던 개척에 "이 행성은 무엇을 맡길까"라는 선택을 넣는다.
Lv.5는 TASK 001 상한 규칙상 두 번째 항성계에 도착해야 열리므로, 특화는 진행의 보상이기도 하다.

## 배경
- 프로젝트: `/Volumes/home_extension/AndroidStudioProjects/star_settlers` (Flutter 게임, 커밋 안 된 작업이 많다. 보존할 것)
- 상태·이전 결과: `docs/agent-collaboration/gameplay-depth/PIPELINE_STATE.md`, `RESULT_001_*`, `RESULT_002_CODEX.md`
- 관련 코드: `Planet`(`lib/game/models.dart`: `baseCreditRate`, `baseOreRate`, `shieldMax`, `turretDamage`, `buildings`),
  `GameWorld`(`lib/game/world.dart`: `colonyLevelCap`, `upgradePlanet`, `remotePlanet`, `upgradeRemotePlanet`, `SectorSave` 직렬화, 행성 JSON 직렬화),
  UI `lib/ui/colony_panel.dart`, `lib/ui/colonies_panel.dart`, 문구 `lib/l10n/app_ko.arb`(템플릿).

## 규칙 (이대로 구현, 수치 그대로)
| id | 이름(ko) | 효과 (그 식민지에만) |
|---|---|---|
| industry | 산업 특화 | 크레딧 생산 ×1.5 |
| mining | 채굴 특화 | 광석 생산 ×2.5 |
| fortress | 요새 특화 | 식민지 방어막 최대치 ×2, 식민지 포탑 피해 ×1.5, 습격으로 식민지 레벨을 잃지 않음 |

- 식민지 레벨 5 이상에서만 고를 수 있다. 처음 고르기는 무료.
- 바꾸기는 가능하되 비용 = 그 식민지의 현재 레벨업 비용(`planetCost`/원격은 `remotePlanetCost`)과 같은 크레딧·광석. 상한에 막혀 레벨업 비용이 의미 없을 때도 이 공식으로 계산한다.
- 습격 등으로 레벨이 5 아래로 떨어져도 특화는 유지하되 효과는 Lv.5 이상일 때만 적용(요새는 습격 레벨 손실 방지가 핵심이므로, 요새가 Lv.5 이상이면 손실 자체가 안 일어난다).
- 효과는 `baseCreditRate`/`baseOreRate` 같은 기존 계산 지점에 곱한다. 그래야 떠나온 항성계 원격 수입(`idleCredits` 저장 시점 계산)과 "내 식민지" 표시에도 자동으로 반영된다. 이중 적용이 없게 확인할 것.
- 저장: 현재 항성계 행성과 `SectorSave` 양쪽에 특화를 저장. 기존 저장(필드 없음)은 특화 없음으로 읽는다. 저장 형식 하위 호환 필수.
- 원격 항성계 식민지도 "내 식민지" 패널에서 특화를 고르고 바꿀 수 있다(`upgradeRemotePlanet`처럼 SectorSave를 다시 만드는 방식).
- 처음으로 어떤 식민지가 Lv.5에 도달하면 미나가 특화를 한 번 안내한다(카운터로 1회).

## UI
- `colony_panel.dart`: Lv.5 이상이면 "특화" 섹션 — 세 가지 버튼(아이콘·이름·효과 한 줄). 현재 특화는 강조, 바꾸기 비용 표시. Lv.5 미만이면 "Lv.5에서 특화 해금" 한 줄.
- `colonies_panel.dart`: 행의 이름 옆이나 아래에 특화 표시(이모지+이름). 특화 선택/변경은 행에서 탭 → 작은 선택 시트/다이얼로그로 해도 된다. 기존 행 레이아웃이 좁은 폰(360dp)·가로·글자 1.3배에서 넘치지 않게.
- 아이콘은 이모지 또는 기존 `GameIcon` 에셋. 새 이미지 파일 금지.
- 한국어 문구는 `keepAll`(`lib/ui/common.dart`)로 단어 중간 줄바꿈 방지. 기존 패턴을 따를 것.
- 새 ARB 키는 `app_ko.arb`에 `@설명`과 함께, 10개 언어(`lib/l10n/app_*.arb`) 모두 번역. `flutter gen-l10n`으로 재생성.
- 터치 타겟 48dp 이상. 모달 위 모달 금지(기존 OverlayPanel 패턴 확인).

## 밸런스
- `flutter test --no-pub` 전체 통과. `test/balance_test.dart` 기대값 완화 금지. 봇(`test/support/progression_bot.dart`)은 특화를 안 써도 된다(쓰게 해도 됨). 깨지면 원인·수치를 결과에 보고.

## 테스트 (새 파일 `test/colony_spec_test.dart`)
- Lv.4에서 특화 거부, Lv.5에서 무료 선택, 변경 시 비용 차감·자원 부족 시 거부
- 세 특화 효과가 실제 수입/광석/방어막/포탑 피해에 반영, 요새 Lv.5 이상은 습격 레벨 손실 없음
- 저장→불러오기 유지, 필드 없는 옛 저장 호환, 워프로 떠난 뒤 원격 수입에 반영(이중 적용 없음), 원격 선택/변경
- 위젯: colony_panel·colonies_panel 10개 언어, 360×740 / 800×360, 글자 1.3배에서 예외(넘침) 없음

## 수정 가능 파일
`lib/game/models.dart`, `lib/game/world.dart`, `lib/ui/colony_panel.dart`, `lib/ui/colonies_panel.dart`, `lib/l10n/app_*.arb`, `lib/l10n/generated/*`,
`test/support/progression_bot.dart`, 새 테스트, 영향받는 기존 테스트, `docs/GAME_DESIGN.md`(새 "식민지 특화" 단락만).

## 금지
- 위 목록 밖 파일, 테스트 기대 완화/skip/디버그 플래그 우회
- git commit/checkout/reset/revert/stash, 기기·에뮬레이터 실행(`flutter run`, `frun`) 금지
- 다른 작업(항성계 보스)은 손대지 않는다

## 검증 (반드시 실행)
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
flutter gen-l10n
dart analyze lib test
flutter test --no-pub
```

## 결과
`docs/agent-collaboration/gameplay-depth/RESULT_003_CLAUDE.md`: 변경 파일, 요약, 검증 명령과 결과(통과 수, 밸런스 출력의 S1 분·S3~S6 일수), 못 한 검증, 남은 리스크.
