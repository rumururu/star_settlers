---
slug: gameplay-depth-task-002
status: active
---

# TASK 002 — 항성계 특성 (Codex)

> TASK 001(레벨 상한) 결과 위에서 작업한다. 001의 변경을 되돌리지 않는다.

## 목표
항성계마다 숫자만 커지는 대신 **규칙 하나가 달라지게** 한다. 도착하면 이번 항성계에서 무엇을 우선할지
(사냥, 채굴, 방어, 교역)가 바뀌어야 한다.

## 배경
- 프로젝트: `/Volumes/home_extension/AndroidStudioProjects/star_settlers` (Flutter 게임)
- 상태 문서: `docs/agent-collaboration/gameplay-depth/PIPELINE_STATE.md`
- 항성계 이름: `lib/game/star_catalog.dart` (`systemName(sector)`), 하늘 그림 프로필: `lib/ui/star_systems.dart` `_catalog`
  (게임 로직은 UI를 import하지 않는다. 분위기를 맞출 때 참고만 한다. 예: 블랙홀이 있는 항성계 → 중력 우물)

## 특성 6종 (이대로 구현, 수치 그대로)
| id | 이름(ko) | 효과 |
|---|---|---|
| pirateNest | 해적 소굴 | 해적 스폰 간격 ×0.7, 현상금 ×1.5 |
| richVeins | 풍부한 광맥 | 식민지 광석 생산 ×2, 소행성 채굴 광석 ×1.5 |
| solarFlare | 항성 플레어 | 식민지 크레딧 생산 ×1.25, 식민지 방어막 재생 ×0.5 |
| ionNebula | 이온 성운 | 플레이어 스킬 쿨타임 ×0.7, 식민지·정거장 포탑 피해 ×0.7 |
| gravityWell | 중력 우물 | 플레이어 최고 속도 ×0.85, 전투·임무 보상 ×1.3 |
| tradeLane | 교역로 | 시장 광석 판매가 ×1.3, 식민지 습격 빈도 ×1.3 |

- 태양계(인덱스 0)는 특성 없음(튜토리얼).
- 인덱스 1~26은 손으로 정한 고정 표(각 특성 최소 3번, 연속 두 항성계에 같은 특성 금지),
  27 이상은 sector로 결정되는 결정적 선택(같은 규칙 유지). `lib/game/` 아래(예: `star_catalog.dart` 또는 새 `system_traits.dart`)에 둔다.
- 생산에 걸리는 효과(크레딧·광석)는 떠나온 항성계의 원격 수입과 "내 식민지" 패널 수입 표시에도 똑같이 적용한다.
- 효과는 기존 배율 지점에 곱하는 식으로 넣는다. 새 시스템을 만들지 말고, 적용 지점마다 `trait` 조회 한 줄로 끝나게.

## UI
- `lib/ui/system_panel.dart`: 항성계 이름 아래에 특성 아이콘·이름·효과 한 줄(특성 없으면 표시 안 함).
- 새 항성계에 처음 도착하면 미나 대사로 특성을 한 번 알린다(기존 `g_foeIntro`처럼 카운터로 1회, ARB `select`).
- 새 ARB 키는 `lib/l10n/app_ko.arb`(템플릿)에 `@설명`과 함께, 10개 언어 모두 번역. `flutter gen-l10n` 재생성.
- 아이콘은 기존 `GameIcon` 에셋이나 이모지 중 맞는 것을 쓴다. 새 이미지 파일은 만들지 않는다.

## 밸런스 요구
- `flutter test` 전체 통과. `test/balance_test.dart` 기대값을 완화하지 않는다.
  깨지면 원인(어느 특성, 어느 항성계)을 찾아 결과 파일에 수치로 보고하고, 표의 수치를 임의로 바꾸지 않는다.
- 새 테스트 `test/system_traits_test.dart`: 인덱스 0 특성 없음, 1~26 표 규칙(각 3회 이상, 연속 중복 없음),
  27+ 결정성, 각 특성 효과가 해당 배율에 실제로 반영됨(최소 6개 케이스), 원격 수입에도 반영.

## 수정해도 되는 파일
`lib/game/*.dart`, `lib/ui/system_panel.dart`, `lib/ui/colonies_panel.dart`, `lib/l10n/app_*.arb`, `lib/l10n/generated/*`,
`test/support/progression_bot.dart`, 새 테스트, 영향받는 기존 테스트, `docs/GAME_DESIGN.md`(새 "항성계 특성" 단락).

## 수정하면 안 되는 것
- 위 목록 밖 파일 (`android/`, `ios/`, `pubspec.yaml`, 릴리스 문서, 배포된 changelog, `assets/`).
- 테스트 기대값 완화·skip·디버그 플래그 우회 금지.
- git commit/checkout/reset/revert/stash 금지. 기기·에뮬레이터 실행 금지.

## 반드시 실행할 검증
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
flutter gen-l10n
dart analyze lib test
flutter test
```

## 결과
`docs/agent-collaboration/gameplay-depth/RESULT_002_CODEX.md`: 변경 파일, 요약, 1~26 배정표,
검증 명령과 결과(통과 수, S1 분·S3~S6 일수), 못 한 검증, 남은 리스크.
