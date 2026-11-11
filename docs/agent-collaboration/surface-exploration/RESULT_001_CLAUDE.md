---
slug: surface-exploration-result-001
status: result
---

# RESULT 001 — 지표 탐험 게임 규칙

## 변경 파일
- 새 파일
  - `lib/game/surface.dart` — 순수 규칙: 지도 시드(`surfaceSeed`), 지도 생성(`SurfaceMap.generate`, 격자 BFS `path`), 지점(`SurfaceSite`), 위험 지대 효과(`hazardEffectOf`), 생물 종류(`CreatureKind`, `pirateKindOf`, `creatureOf`), 규칙 상수(`SurfaceRules`), 전리품 기준값(`SurfaceLoot`), 유물(`relicIds`, `rollRelic`), 기록(`SurfaceRecords` — `srfDay`/`srfRuns`/`srfTotal`/`srfDry`/`srfHint`)
  - `lib/game/surface_world.dart` (`part of 'world.dart'`) — `SurfaceWorld extends GameWorld`, `SurfaceOutcome`, `SurfaceEnd`, `SurfaceSettlement`, `SurfaceSettle.settle`
  - `supabase/migrations/20261111000000_starset_events_v3.sql` — 허용 목록에 `surface_start`, `surface_end` 추가 (배포는 오케스트레이터)
  - `test/surface_test.dart` (27개), `test/support/surface_bot.dart`
- 수정
  - `lib/game/models.dart` — `Planet.vein/nest/surveyed` + `discoveries` 비트, 효과(광석 +0.4/초×Lv, 방어막 ×1.25, 크레딧 ×1.1)
  - `lib/game/world.dart` — part 선언, `SectorSave.discoveries`(저장 키 `disc`, 없으면 빈 목록·발견 없으면 키 생략), 불러오기/저장/원격 사본/원격 강화에 전달, `landUnlocked`·`canLand`, 미나 안내 1회(`_checkLandHint`), 적 추적 거리 훅 `_aggroRange`(메인 게임은 기존 1600 그대로)
  - `lib/game/codex.dart` — `CodexTab.relics`, `Codex.relics`(저장 키 `rl`), `recordRelic`(토스트), `codexMilestonesOf`(유물 탭은 100% 하나), `codexRewardOf`, `relicSprite`, `relicKey`
  - `lib/game/game_telemetry.dart` — `surfaceStart`, `surfaceEnd`
  - `lib/ui/codex_screen.dart` — 새 탭 때문에 컴파일이 깨지지 않게 유물 탭을 함께 넣음(TASK 002 범위를 앞당김)
  - 번역 7개(`srf_dlgUnlock`, `srf_dlgOxygen`, `srf_site`, `srf_floatSite`, `srf_floatRelic`, `srf_relicName`, `srf_relicDesc`) — `tool/arb_add.py`, 10개 언어

## 설계 결정 (SPEC과 다르게 한 것)
1. **지점은 늘 5곳(잔해 1곳)**. SPEC 표의 "잔해 1~2"와 "한 판에 5곳"이 충돌해서 "5곳 모두 → 완전 탐사"가 성립하도록 잔해를 1곳으로 고정.
2. **차량 속도 = 함선 속도 × 0.5** (`roverSpeedMul`). 함선 속도 그대로면 봇이 60초 안에 다 돌아 90~170초 목표를 못 맞춘다. 강화 비율은 그대로 체감된다.
3. **생물 공격력 = 항성계 해적 공격 배율 × 0.45** (`creatureDamageMul`). 체력 배율은 SPEC대로 그대로. 해적과 같은 공격력이면 새 선장 봇이 10~20초 만에 격추됐다(메인 게임엔 기지 수리·안전 구역·초반 0.6배가 있는데 지표엔 없음).
4. **착륙선 반경 안에서 차량 수리**(초당 최대 체력 12%) 추가. 돌아와 쉬었다 다시 나가는 선택지.
5. **생물 추적 거리 550**: 배회하는 생물은 550 안에 들어와야 쫓는다. 몰려온 생물(유적·둥지·산소 압박)과 맞은 생물은 기존처럼 멀리서도 쫓는다. 시작 생물은 착륙선에서 900 밖.
6. **용암 덩치(돌격함 동작)**: 체력 ×0.2·공격 ×0.4, 동시에 1마리(나머지 덩치는 습격선 동작). 돌격함은 정면 탄 60%를 막아 기본 무기로는 사실상 못 잡았다.
7. **용암 웅덩이 피해 8/초**(정원 3, 얼음 2, 사막 0·감속 0.45).
8. **둥지 체력 700 × 적 체력 배율**, 차량이 1500 안에 있을 때만 낳는다. 자동 사격은 둥지 420 안에서 200 안에 붙은 생물이 없으면 둥지를 조준(그렇지 않으면 새끼만 쏘다 끝나지 않았다).
9. **중간에 나가기 = 산소 소진과 같은 비상 귀환**(통계 값 1). 완전 탐사는 스스로 귀환일 때만.
10. 영구 발견·유물은 끝난 이유(격추 포함)와 상관없이 기록한다. 유물 연속 꽝 수는 판 안에서 이어 세고 정산 때 프로필에 저장.
11. 유물 탭 마일스톤: 8종 모두 → ★3 승무원 + 💰8,000 + 광석 4,000 (젬 없음).
12. 통계 `surface_start`는 화면(TASK 002)에서 보낸다(균열 런과 같음).

## 봇 측정값 (`test/surface_test.dart` 봇 그룹)
- 조건: 새 게임 태양계 + 테라노바 Lv.1, 강화 0, 기본 함선. 4종(정원은 태양계에 없어 같은 자리 대역 행성) × 12판 = 48판.
- 봇: 자동 사격, 가장 가까운 남은 지점으로 격자 경로(위험 지대 피함), 체력 35% 아래면 착륙선 수리, 돌아갈 시간만큼 산소가 남으면 귀환.
- **평균 105.7초, 격추 7판(15%)**: 정원 2·사막 2·얼음 1·용암 2, 완전 탐사 38판(79%).
- 기준치(테스트): 평균 90~170초, 격추율 ≤30%, 종류별 ≤50%, 완전 탐사 ≥40%.

## 보상 기준값
- 지점 합계 1,140💰 + 생물 처치(약 25마리 × 평균 11) ≈ 1,415💰 (×rewardMul), 광석 440 (×sectorMul).
- 기준(테스트): 태양계 식민지 3곳 Lv.2 선장의 2분 = 생산 120초 + 사냥(분당 정찰기 4척) ≈ 1,520💰 → 비율 0.93 (허용 0.6~1.4). 광석은 같은 선장 2분 생산의 0.57배 (허용 0.4~2.0).
- 하루 3회 뒤 30%, 귀환 100% / 비상·격추 50%, 완전 탐사 젬 3(`earnGems('play', …)`, 행성당 한 번).

## 검증
- `dart analyze lib test` — No issues found
- `flutter test --no-pub` — **666개 모두 통과** (기존 639 + 새 27)

## 남은 리스크
- 생물 공격 0.45배·차량 0.5배는 봇 기준. 실기기 손맛 확인 필요(특히 용암).
- 생물이 장애물 뒤에서 밀려 끼일 수 있다(밀어내기만 하고 길 찾기는 안 함).
- 대역 정원 행성은 봇 측정 전용. 실제 정원 행성은 두 번째 항성계부터 나온다.
- 뒤 항성계 보상은 rewardMul을 따르므로 식민지가 많은 후반엔 "2분 수입"보다 작아질 수 있다(현상금과 같은 규칙).
