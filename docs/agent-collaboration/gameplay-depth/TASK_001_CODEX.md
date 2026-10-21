---
slug: gameplay-depth-task-001
status: active
---

# TASK 001 — 레벨 상한을 진척에 묶기 (Codex)

## 목표
첫 항성계에서 식민지·함선을 곧바로 최대 레벨까지 올릴 수 없게 하고,
새 항성계에 도착할 때마다 **모든 항성계의 식민지와 함선의 상한이 함께 오르게** 한다.
그래서 앞으로 나아갈 이유와, "내 식민지" 메뉴로 예전 항성계 식민지를 다시 키울 이유가 생긴다.

## 배경
- 프로젝트: Flutter 게임 `/Volumes/home_extension/AndroidStudioProjects/star_settlers`
- 상태 문서: `docs/agent-collaboration/gameplay-depth/PIPELINE_STATE.md` (진단 근거)
- 기획 정본: `docs/GAME_DESIGN.md` (§3.2 메타 루프, §4.1 함선, §4.3 개척, 위상 정박기 단락)
- 진척 지표: `counter('maxSector')` (가장 멀리 간 항성계 인덱스, 0 = 태양계). `lib/game/world.dart`

## 규칙 (이대로 구현)
1. 식민지 레벨 상한 = `min(4 + maxSector, 12)`. 태양계만 다녀본 플레이어는 Lv.4, 두 번째 항성계 도착 시 Lv.5 … 최대 Lv.12.
   - `GameWorld`에 `int get colonyLevelCap`(가칭) 하나를 두고, 현재 항성계 업그레이드(`upgradePlanet`)와
     원격 업그레이드(`upgradeRemotePlanet`) 모두 이 값으로 막는다.
   - `Planet.maxLevel` 상수는 "절대 상한 12"의 의미로 바꾸거나 제거하고, 모든 참조를 새 상한으로 옮긴다
     (`lib/ui/colony_panel.dart`, `lib/ui/colonies_panel.dart`, `lib/ui/system_panel.dart:172`, `world.dart`의 업적 `maxColony` 등).
   - 위상 정박기(건물) 상한은 지금처럼 식민지 레벨(`buildingCap`)을 따른다. `system_panel.dart:172`의 기여도 비율은 기존 의미(정박기 Lv/5 기준)가 깨지지 않게 판단해서 고친다.
   - 업적 `maxColony`는 "그 시점 상한에 도달"이 아니라 기존처럼 Lv.5 도달로 유지한다.
2. 함선 강화 상한: 무기·장갑·엔진 = `min(8, 4 + maxSector)`, 미사일·실드·드론·자석 = `min(5, 2 + maxSector)`.
   - `UpgradeKind.maxLevel`은 절대 상한으로 남기고, `GameWorld`에 `int upgradeCap(UpgradeKind k)`를 추가해 `upgrade` 판정과
     `lib/ui/station_panel.dart`의 MAX 표시에 쓴다.
3. 상한에 막힌 버튼은 "MAX"와 구분해서 보여준다: 절대 최대면 `MAX`, 진척 상한이면 잠금 표시 + "다음 항성계에서 Lv.N" 류 문구.
   - 새 ARB 키는 `lib/l10n/app_ko.arb`(템플릿)에 `@설명`과 함께 추가하고 10개 언어(`app_*.arb`) 모두 번역, `flutter gen-l10n`으로 재생성.
4. 기존 저장 호환: 상한보다 높은 레벨을 가진 저장은 **레벨을 깎지 않는다**. 더 올리는 것만 막는다.
5. 원격 식민지 수입·비용 공식은 그대로 둔다 (원격 업그레이드 비용 = 그 항성계 `costMulAt(sector)`).

## 밸런스 요구
- `test/balance_test.dart`가 모두 통과해야 한다. 봇(`test/support/progression_bot.dart`)이 새 상한을 지키도록 고친다.
  - 봇이 상한 때문에 "살 게 없어 멈추는 세션"(stallSessions)이 생기면 안 된다. 게이트 조건(정박기 합 ≥ 행성 수 × 3)은 Lv.4 상한에서도 달성 가능하다.
  - 첫 항성계 15~30분, S3~S6 일수 비율 조건 등 기존 기대값을 바꾸지 않는다. 깨지면 봇의 우선순위를 고치는 쪽으로 해결하고,
    그래도 안 되면 기대값을 바꾸지 말고 결과 파일에 수치와 함께 보고한다.
  - 봇이 새 항성계 도착 후 남는 돈으로 예전 항성계 식민지를 올리는 선택지를 쓰게 해도 된다.

## 수정해도 되는 파일
`lib/game/world.dart`, `lib/game/models.dart`, `lib/ui/colony_panel.dart`, `lib/ui/colonies_panel.dart`,
`lib/ui/system_panel.dart`, `lib/ui/station_panel.dart`, `lib/l10n/app_*.arb`, `lib/l10n/generated/*` (gen-l10n 산출물),
`test/support/progression_bot.dart`, 새 테스트 `test/level_cap_test.dart`, 영향받는 기존 테스트, `docs/GAME_DESIGN.md`(해당 단락만).

## 수정하면 안 되는 것
- 위 목록 밖의 파일. 특히 `android/`, `ios/`, `pubspec.yaml`, 릴리스 문서, 이미 배포된 changelog.
- 밸런스 테스트의 기대 수치 완화, `skip`, 디버그 플래그 등 우회 금지.
- git commit / checkout / reset / revert / stash 금지. 기기·에뮬레이터 실행 금지.

## 반드시 실행할 검증
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
flutter gen-l10n
dart analyze lib test
flutter test
```
`test/level_cap_test.dart`에 최소 다음을 넣는다:
- maxSector 0에서 식민지 Lv.4까지 오르고 Lv.5는 거부, maxSector 1이면 Lv.5 허용
- 원격 식민지 업그레이드도 같은 상한
- 상한보다 높은 레벨의 저장을 불러와도 레벨이 그대로
- 함선 무기 maxSector 0에서 Lv.4 상한, maxSector 4에서 Lv.8, 미사일 maxSector 0에서 Lv.2

## 결과
`docs/agent-collaboration/gameplay-depth/RESULT_001_CODEX.md`에 작성:
변경 파일 목록, 변경 요약, 실행한 검증 명령과 결과(통과 수, 밸런스 테스트 출력의 S1 분·S3~S6 일수),
실행 못 한 검증과 이유, 남은 리스크.
