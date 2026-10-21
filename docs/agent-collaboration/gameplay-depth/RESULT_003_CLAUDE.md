---
slug: gameplay-depth-result-003
status: active
---

# RESULT 003 — 식민지 특화 (Claude 워커)

Lv.5 이상 식민지에 산업/채굴/요새 특화를 고르게 했다. 현재 항성계와 떠나온 항성계 식민지 모두에서 고를 수 있다.
`flutter gen-l10n`, `dart analyze lib test`(이슈 0)를 실행했고 `flutter test --no-pub`는 **437개가 모두 통과**했다. 밸런스 수치는 RESULT 002와 같다.
커밋과 기기 실행은 하지 않았다.

## 변경 파일

| 파일 | 내용 |
|---|---|
| `lib/game/models.dart` | `enum ColonySpec`(minLevel 5, 배율 상수, `fromName`), `ColonySpecInfo`(label/effect/emoji/iconAsset). `Planet.spec`, `activeSpec`(Lv.5 이상일 때만). `baseCreditRate`(×1.5), `baseOreRate`(×2.5), `shieldMax`(×2), `turretDamage`(×1.5)에서 한 번씩 곱한다 |
| `lib/game/world.dart` | `SectorSave.specs` + `specAt`, JSON 키 `spec`(없으면 빈 목록). 불러오기·저장(`_loadSector`, `_saveCurrentSector`), `remotePlanet`에 특화 반영. `canSpecialize`, `specCost`, `setColonySpec`, `remoteSpecCost`, `setRemoteColonySpec`. `upgradeRemotePlanet`의 SectorSave 재구성을 `_storeRemote`로 분리해 특화와 같이 쓰도록 했다(동작 동일, 특화 목록 보존). 첫 Lv.5 미나 안내(`specHint` 카운터, 현재·원격 레벨업 공통). 습격 종료 시 요새가 활성(Lv.5 이상)이면 레벨 손실 없이 `g_dlgRaidFortress`를 낸다 |
| `lib/ui/colony_panel.dart` | 레벨 줄 아래에 "특화" 섹션. Lv.5 미만이면 `🔒 Lv.5에서 특화 해금` 한 줄. 특화가 있는데 레벨이 떨어지면 특화 이름과 "Lv.5 이상에서만 효과"를 보여 준다. Lv.5 이상이면 세 줄(아이콘·이모지+이름·효과)과 버튼이 나온다. 버튼은 처음엔 "무료", 이후엔 바꾸기 비용, 현재 특화는 초록 테두리 강조에 ✓이다. 포탑 효과 미리보기에 요새 배율 반영 |
| `lib/ui/colonies_panel.dart` | 펼침 상태 때문에 StatefulWidget으로 바꿨다. 정박기 줄 앞에 `🏭 산업 특화 ▾`(없으면 `✨ 특화 선택 ▾`)를 표시하며 한 줄이고 넘치면 말줄임한다. 행(버튼 밖)을 누르면 행 아래에 세 가지 선택이 펼쳐진다. 모달 위 모달은 쓰지 않았다. 레벨이 떨어져 효과가 꺼진 특화는 안내 한 줄을 붙인다 |
| `lib/l10n/app_*.arb` (10개) + `lib/l10n/generated/*` | 새 키 9개: `u_specTitle`, `u_specName`(select), `u_specEffect`(select), `u_specLocked`, `u_specInactive`, `u_specFree`, `u_specChoose`, `g_dlgSpecUnlocked`, `g_dlgRaidFortress`. ko에는 `@설명`을 달았다 |
| `test/colony_spec_test.dart` (새 파일) | 아래 33개 |
| `docs/GAME_DESIGN.md` | 새 단락 "4.3.2 식민지 특화"만 추가 |

`test/support/progression_bot.dart`와 기존 테스트는 수정하지 않았다.

## 테스트 (`test/colony_spec_test.dart`, 33개)

- 선택과 비용: Lv.4는 거부, Lv.5 첫 선택은 무료(자원 변화 없음)이고 같은 특화를 다시 고르면 거부. 바꾸기 비용은 `planetCost`와 같고 상한(Lv.5, 항성계 2)에 막혀도 같다. 크레딧이나 광석이 모자라면 거부. 미나 안내는 1회
- 효과: 산업은 기초값과 `planetCreditRate` 모두 ×1.5, 채굴은 광석 ×2.5(크레딧 불변), 요새는 방어막 최대 ×2·포탑 ×1.5. 요새를 해제하면 남은 방어막을 새 최대치로 깎는다. 습격 종료 시 요새 Lv.5만 레벨 5를 유지하고 산업·채굴은 4로 떨어진다. Lv.4로 떨어지면 특화는 남고 효과는 꺼지며(특화 없는 Lv.4와 같은 수입), Lv.5로 돌아오면 다시 켜진다. Lv.4에서는 바꿀 수 없다
- 저장: 저장→불러오기 유지. `spec` 필드가 없는 옛 저장과 모르는 값·null은 특화 없음으로 읽는다. 워프로 떠난 뒤 `idleCredits` 차이 = 기초 크레딧 × 0.5, `idleOre` 차이 = 기초 광석 × 1.5로 정확히 맞아 이중 적용이 없다. 저장 후 유지되고 돌아가면 행성에 다시 붙는다. 원격 선택(Lv.4 거부, 무료)과 원격 변경(비용 = `remotePlanetCost`, 산업 보너스는 빠지고 채굴 보너스가 붙음)도 확인했다. 다른 행성의 특화·건물은 보존되고, 원격 레벨업 뒤에도 특화가 유지되며, 자원이 모자라면 거부한다
- 위젯(10개 언어 × 360×740 / 800×360 × 글자 1.3배, 예외 없음)
  - `ColonyPanel`: Lv.4 잠금 문구가 보이고, Lv.5에서 무료 버튼 3개가 모두 48dp 이상이다. 채굴 탭이 적용되고 그 뒤 ✓ 1개, 무료 버튼 0개다
  - `ColoniesPanel`: 현재 항성계 요새 표시가 보이고, 원격 행 터치 영역이 48dp 이상이다. 행 탭으로 펼치면 무료 버튼 3개가 나오고, 산업을 고르면 저장에 반영된다. 다시 탭하면 접힌다

## 검증 명령과 결과

```
flutter gen-l10n          → 성공
dart analyze lib test     → No issues found!
flutter test --no-pub     → 02:00 +437: All tests passed!
```

밸런스(`test/balance_test.dart` 출력, 봇은 특화를 쓰지 않음, RESULT 002와 동일):
- S1 (seed 1·2·3): **19.1 / 20.4 / 21.2분**, 사망 0, 정체 세션 0
- S3~S6 일수: 무료 **7.87**, 장비 **5.00**, 팩 **6.30**, 패스 **4.67**, 패스+장비 **3.17**
- S3~S4 일수: 무료 2.86, 패스 1.87, 팩 1.34

## 진행 중 수정한 문제

처음에는 "내 식민지" 행에 48dp 특화 버튼 줄을 따로 넣었다. 그러자 기존 `colonies_panel_test`의 "화면 크기를 바꾼 뒤에도 현재 항성계 헤더가 보인다" 검증이 de/en/es/fr/id/pt/ru 7개 언어에서 실패했다. 360×740·1.3배에서 두 Lv.5 행이 길어져 스크롤이 생겼기 때문이다(ru는 RESULT_001_REWORK 기준 여유가 약 1dp). 테스트 기대는 바꾸지 않았다. 대신 특화 표시를 기존 정박기 캡션 줄에 한 줄로 넣고 행 자체를 탭 대상으로 바꿔 행 높이가 늘지 않게 했다. 이 방식으로 다시 돌린 전체 테스트가 통과했다.

## 실행하지 못한 검증

- 실기기·에뮬레이터 확인(과제에서 금지). 행 탭으로 펼치는 방식이 실제로 눈에 띄는지와 이모지(🏭⛏🏰✨) 렌더링은 기기에서 확인되지 않았다.
- 밸런스 봇이 특화를 쓰는 경우는 측정하지 않았다(봇 미변경).

## 남은 리스크 (Claude 리뷰 확인 요청)

1. **"내 식민지" 캡션 말줄임**: 특화 이름을 정박기 이름 앞에 한 줄로 두었다. 좁은 폭에서 긴 언어(ru `Промышленность ▾ · Фазовый якорь Ур.N`)는 뒤쪽 정박기 레벨이 잘릴 수 있다. 특화 이름은 앞에 있어 남는다.
2. **발견성**: "특화 선택"은 버튼이 아니라 행 탭이다(▾ 표시와 하늘색 문구). 행이 48dp 이상이어서 터치 영역 기준은 지킨다. 다만 사용자가 행을 누를 수 있다는 걸 알아챌지는 실기기에서 판단해야 한다.
3. **요새와 공유(중계) 방어막**: 요새 ×2는 식민지 돔(`shieldMax`)에만 적용했다. `relayShieldMax`(정박기 공유 방어막)에는 적용하지 않았다(과제 표 그대로).
4. **요새 습격 대사**: 요새가 레벨을 지켰을 때 새 대사 `g_dlgRaidFortress`를 낸다. 이때 기존 "약탈하고 떠났다" 대사는 나오지 않는다.
5. 특화 변경 비용이 레벨업 비용과 같아 고레벨(예: Lv.12)에서는 매우 비싸다. 과제 규칙대로다.
6. `lib/ui/colonies_panel.dart`는 git 미추적 파일이라 diff로 원본과 비교할 수 없다. 수정 후 `dart format`을 적용했다.
