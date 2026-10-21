---
slug: gameplay-depth-result-004
status: active
---

# RESULT 004 — 항성계 보스 (Claude 워커)

이제 항성계 두목(`sectorBoss`)은 항성계 특성에 따라 원형(`BossArchetype`) 하나를 받는다. 원형마다 싸움 방식이 다르다. 태양계 두목과 격파 후 재등장하는 일반 두목은 원형이 없고 예전 패턴 그대로다. 기존 원형 탄막과 50% 분노 소환은 모든 원형에 남아 있다. 두목 체력(×1.6)과 보상(1000 × 보상 배율)은 바꾸지 않았다.

`flutter gen-l10n`과 `dart analyze lib test`(이슈 0)를 실행했다. `flutter test --no-pub`는 **454개가 모두 통과**했다(기존 437 + 새 17).
커밋, 기기·에뮬레이터 실행, git 되돌리기는 하지 않았다.

## 변경 파일

| 파일 | 내용 |
|---|---|
| `lib/game/system_traits.dart` | `enum BossArchetype`(fleet/devourer/flare/wraith/gravity/plunder)를 추가했다. 수치 상수(호위 10초·2기·최대 6, 기뢰 5초·3개, 레이저 7초·충전 1.5초·±20°, 은신 4초, 중력 반경 700·초당 120, 약탈 속도 ×1.4·1%·상한 50%)도 여기에 둔다. 특성→원형 대응은 `SystemTrait?.bossArchetype`이다(null이면 null) |
| `lib/game/models.dart` | `Pirate`에 `archetype`, `archetypeTimer`, `plundered`를 추가했다. 약탈 상선은 `speed`에 ×1.4가 붙는다. `Bullet`에 선택 인자 `source`(쏜 적)를 추가했다 |
| `lib/game/world.dart` | 등장할 때 `trait.bossArchetype`과 첫 타이머를 붙인다. 원형 두목은 미나 경고가 `g_dlgBossArchetype`으로 바뀌고, 원형이 없으면 기존 `g_dlgBossWarning`을 쓴다. `_bossPattern`이 `_archetypePattern`을 호출한다. 기존 기제를 그대로 썼다: 호위는 `_spawnQueue` + `parent`(모함 드론과 같은 방식), 기뢰는 `SpaceMine`(맵 18개 상한 공유), 레이저는 `_fireEnemyLaser`(선택 인자 `angle` 추가), 은신은 `Pirate.cloaked`. 은신 중이거나 레이저를 충전하는 두목은 일반 사격과 원형 탄막을 쏘지 않는다. 충전 중에는 거의 멈춘다. 중력은 부스트 중(`boostTime > 0`)이 아닐 때 선장 위치를 끌어당긴다. `_damagePlayer`는 이제 선체가 실제로 피해를 입었는지(bool)를 돌려준다. 약탈 상선의 탄(`source`)이 선체에 맞으면 `_plunder`가 크레딧 1%를 빼앗는다. 누적 상한은 `sectorBossReward`(새 getter, 기존 1000 × rewardMul × shipCreditMul 식)의 50%다. 처치하면 빼앗긴 만큼 돌려받고, 보상 대사 금액에도 더한다 |
| `lib/ui/world_painter.dart` | 원형 두목에는 `pirate_boss` 스프라이트에 원형별 색조 행렬(ColorFilter)을 입힌다. 피격 섬광이 우선이다. 원형별 오라도 그린다: 함대장은 호위 연결선, 포식자는 도는 기뢰 고리, 포격함은 3갈래 조준선(고정 뒤 굵게)과 충전 광구, 유령은 고리, 중력 군주는 반경 700 링과 안쪽으로 줄어드는 물결, 상선은 금빛 고리(약탈 중엔 밝게). 이름표는 `u_bossName`이고, 은신한 원형 두목은 이름표와 체력 바도 숨긴다 |
| `lib/l10n/app_*.arb` (10개) + `lib/l10n/generated/*` | 새 키 2개를 추가했다. `u_bossName`(select, ☠ + 이름)과 `g_dlgBossArchetype`(select, 이름 + 공략 한 줄)이다. ko에는 `@설명`을 달았다 |
| `test/system_boss_test.dart` (새 파일) | 아래 17개 |
| `docs/GAME_DESIGN.md` | 4.2 후반 적 표 아래에 "항성계 두목" 단락과 표를 추가했다 |

## 테스트 (`test/system_boss_test.dart`, 17개)

- 배정: 특성 6종이 서로 다른 원형으로 대응한다. 태양계 두목은 실제 스폰 경로에서 원형이 없고 속도가 150이며 기존 경고를 쓴다. 인덱스 1~6에 실제로 워프해 위협도로 소환한 항성계 두목은 각각 해당 원형이고, 이름이 들어간 미나 경고가 나오며 기존 경고는 나오지 않는다. 재등장 일반 두목(`bossDefeated` 뒤)은 원형이 없다. 10개 언어 모두 이름과 경고가 있고, 경고에 이름이 들어 있다
- 함대장: 첫 소환은 습격선 2기다. 9.8초 동안 추가가 없고 10초에 4기가 된다. 이후 최대 6기에서 멈추고, 1기가 격추되면 상한까지만 다시 채운다
- 포식자: 반경+60 안에 3개를 깔고, 5초 뒤 6개가 된다. 맵에 17개가 있으면 18개에서 멈춘다
- 포격함: 충전 1.5초 동안에는 레이저가 없다. 그 뒤 적 레이저가 정확히 3줄기 나가고, 조준 대비 상대각은 −20°/0/+20°이며, 가운데 줄기가 선장에게 피해를 준다. 다음 발사는 7초 주기다
- 유령: 은신 중 탄 피해가 0이다. 4초 경계에서 노출되고, 노출 중에는 피해를 받으며, 다시 4초 뒤 은신한다
- 중력 군주: 1초에 120±6만큼 두목 쪽으로 끌린다. 부스트 중에는 1 미만이고, 반경 밖(1100)에서는 1 미만이다
- 약탈 상선: 속도는 일반 두목 ×1.4다. 한 번 맞으면 크레딧 1%(10000 → 100)를 빼앗는다. 다른 적의 탄이나 무적 중 피격은 약탈하지 않는다. 누적은 `sectorBossReward × 0.5`에서 멈춘다. 처치하면 크레딧이 `상한 + 보상`만큼 늘고, 보상 대사 금액에도 약탈분이 들어간다

## 검증 명령과 결과

```
flutter gen-l10n          → 성공
dart analyze lib test     → No issues found!
flutter test --no-pub     → 02:20 +454: All tests passed!
```

밸런스(`test/balance_test.dart` 출력). 기대값은 바꾸지 않았고 모두 통과했다.
- S1 (seed 1·2·3): **19.1 / 20.4 / 21.2분**, 사망 0, 정체 세션 0 (RESULT 003과 같음)
- S3~S6 일수: 무료 **8.06** (7.87), 장비 **5.31** (5.00), 팩 **6.31** (6.30), 패스 **4.66** (4.67), 패스+장비 **3.32** (3.17)
- S3~S4 일수: 무료 2.99 (2.86), 패스 1.98 (1.87), 팩 1.33 (1.34)

괄호는 RESULT 003 값이다. 인덱스 1 이후 두목이 원형 패턴을 쓰므로 봇이 두목을 잡는 데 시간이 조금 더 걸린다. 그래서 무료·장비 경로가 0.1~0.3일 늘었다. 테스트 한계 안이다.

## 렌더 확인

임시 테스트로 실제 `WorldPainter`를 1100×800으로 렌더했다. 스프라이트는 `lib/main.dart`와 같은 목록을 `Sprites.load`로 읽었고, `pirate_boss`가 로드됐는지 확인했다. 확인 뒤 임시 테스트 파일은 지웠다.

- `/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/8c303f23-a6f8-467a-a28b-99d3781e7ca6/scratchpad/bosses/boss_fleet.png` — 붉은 색조 두목, 습격선 호위 4기
- `/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/8c303f23-a6f8-467a-a28b-99d3781e7ca6/scratchpad/bosses/boss_devourer.png` — 청록 색조, 도는 기뢰 고리, 깔린 기뢰 2개와 그 범위 원
- `/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/8c303f23-a6f8-467a-a28b-99d3781e7ca6/scratchpad/bosses/boss_flare.png` — 주홍 색조, 충전 막판의 굵은 3갈래 조준선(가운데가 선장을 지남)과 충전 광구
- `/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/8c303f23-a6f8-467a-a28b-99d3781e7ca6/scratchpad/bosses/boss_wraith.png` — 노출 직후의 보라 색조와 고리. 드러나자마자 쏜 탄이 보인다
- `/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/8c303f23-a6f8-467a-a28b-99d3781e7ca6/scratchpad/bosses/boss_gravity.png` — 줌 0.45. 반경 700 링이 선장을 덮고, 안쪽 물결과 남색 두목이 보인다
- `/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/8c303f23-a6f8-467a-a28b-99d3781e7ca6/scratchpad/bosses/boss_plunder.png` — 금색 색조, 금빛 고리

처음에는 포격함(주황 0xFFFF9100)과 상선(금색)이 비슷해 보였다. 그래서 포격함을 주홍(0xFFFF5722)으로 바꾸고 다시 렌더했다.
테스트 환경 글꼴(Ahem) 때문에 이름표 글자는 네모로 나온다. 이름표 문구는 단위 테스트로 확인했다.

## 실행하지 못한 검증

- 실기기·에뮬레이터 확인(과제에서 금지). 실제 글꼴로 본 이름표 길이(특히 de `Eruptionskanonenboot`, ru `Гравитационный владыка`)와 색조의 실제 화면 인상은 기기에서 확인되지 않았다. **도구 통과 / 제품 미확인**이다.
- 대사 창에서 긴 경고 문장(id·ru)이 줄바꿈되는 모양은 확인하지 않았다.

## 남은 리스크 (리뷰 확인 요청)

1. **약탈 판정 범위**: 약탈은 상선이 쏜 일반 3연발과 원형 탄막(`Bullet.source`)이 선체에 실제 피해를 줬을 때만 일어난다. 방어막·수호막·무적·헤이븐 보호로 막히면 빼앗지 않는다. 분노 때 소환된 부하의 탄은 약탈하지 않는다. "1%"는 피격 시점에 가진 크레딧의 1%다.
2. **약탈 반환 시점**: 두목이 맵에서 사라지는 경우(처치 없이 제거)에는 약탈분을 돌려받지 못한다. 진행 중 두목 상태는 저장하지 않으므로, 저장 후 다시 불러오면 빼앗긴 크레딧은 돌아오지 않는다(과제의 "진행 중 두목 상태 미저장" 규칙대로).
3. **중력 끌림**: 선장이 헤이븐·돔 안에 있어도 반경 700 안이면 끌려간다. 과제 표에 예외가 없어 넣지 않았다.
4. **유령 은신 중 정보 숨김**: 은신한 원형 두목은 이름표와 체력 바도 숨긴다. 기존 유령선은 그대로다(체력 바 표시). `lib/ui/` 안에서 `sectorBoss`·`PirateKind.boss`를 쓰는 곳은 `world_painter.dart`뿐이라 다른 화면에서 두목 이름이 새는 곳은 없다.
5. **밸런스**: S3~S6 무료 경로가 7.87일에서 8.06일로 늘었다(+2.4%). 패스+장비는 3.17일에서 3.32일이다. 기대 한계 안이지만 두목이 확실히 어려워졌다.
6. `dart format`을 `lib/game/models.dart`, `lib/game/world.dart`, `lib/game/system_traits.dart`, `lib/ui/world_painter.dart`, 새 테스트에 적용했다. 커밋되지 않은 기존 변경이 많아 포맷만 바뀐 줄이 섞였는지는 diff로 따로 가려내지 않았다.
