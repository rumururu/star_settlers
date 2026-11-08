---
slug: retention-update-result-002
status: progress
---

# RESULT 002 — 식민지 건물 외형 (Claude 워커)

지시서: `TASK_002_CODEX.md` (스프라이트 생성은 오케스트레이터가 Gemini로 따로 → 이 라운드는 로드 코드 + 도형 대체 그림까지).

## 변경 파일

| 파일 | 내용 |
|---|---|
| `lib/ui/colony_buildings.dart` (새) | 건물 6종 + 거주 돔 배치·그리기 (`ColonyBuildingArt`). 스프라이트 우선, 없으면 종류·단계별 도형 그림. 애니메이션. |
| `lib/ui/world_painter.dart` | 회색 반원 n개 → `ColonyBuildingArt.paint`. 이모지 라벨(`🔫3 ⛏3…`) 제거. 깃발은 가운데 거주 돔 위로. `domeState()`(돔 색·켜짐)를 돔과 방어막 발생기가 같이 씀. 에너지선 시작점 = 안정기 접시 초점. 테스트용 `planetLabelRect()`. |
| `lib/ui/sprites.dart` | `Sprites.buildingNames`(21개). `load()`를 처음 부를 때 함께 읽는다 (`lib/main.dart`는 TASK 001 작업 중이라 건드리지 않음). |
| `lib/game/world.dart` | `colonyTurretTarget(p)`(발사 판정 루프의 표적 선택을 그대로 옮긴 함수, 루프도 이것을 호출), `colonyTurretFlash(p)`(읽기 전용). 밸런스·동작 변화 없음. |
| `test/colony_buildings_render_test.dart` (새) | 게이트 테스트 (a)~(d). |
| `test/support/colony_scene.dart` (새) | 빈 우주에 행성을 놓고 WorldPainter로 그리는 테스트 도우미. |

`pubspec.yaml`: `assets/sprites/` 디렉터리 단위 등록이라 변경 불필요.

## 배치 / 각도

- 각도(0°=오른쪽, -90°=위, 화면 좌표): 포탑 -48°, 광산 -10°, 정비소 28°, 방어막 발생기 -132°, 교역소 -170°, 안정기 152°.
  아래 28°~152°(행성 이름표·안정기 내구도 막대 자리)는 비운다. 이웃 건물 간격 38° 이상.
- 거주 돔: -90°(가운데, 깃발), -101°, -79°. 식민지 Lv.1-2 → 1개, Lv.3-4 → 2개, Lv.5+ → 3개.
- 크기: `fullSize = min(max(R×0.58, 36/zoom), R×0.6)` (줌 아웃에서도 화면 36px 이상, 이웃과 안 겹치게 상한). 외형 단계별 배율 0.74 / 0.87 / 1.0.
- 단계: Lv.1-2 → 1, Lv.3-4 → 2, Lv.5+ → 3. 레벨 점은 구조물 꼭대기 바로 위 (Lv.5 금색, Lv.6+는 흰 점 하나 추가).
- 건물 상자: 표면 법선 방향으로 세운 폭 1 × 높이 1.14(레벨 점 포함) 단위 상자, 바닥은 0.05만큼 묻음.

## 스프라이트 키

- `bld_turret_{1,2,3}_base`, `bld_turret_{1,2,3}_gun`, `bld_{mine,trade,dock,shieldGen,stabilizer}_{1,2,3}` (`assets/sprites/*.png`).
- 받침/건물 스프라이트: 단위 상자 전체(한 변 = 건물 크기, 아래 가장자리 = 표면)에 그린다.
- 포신 스프라이트: 회전축 = 상자 안 높이 0.40/0.45/0.50(단계별, `_turretPivotY`), 그리기 크기 = 건물 크기 × 0.9, 이미지 가운데가 회전축.
  Gemini 그림의 포탑 받침 높이와 안 맞으면 `_turretPivotY`와 `0.9`만 고치면 된다.
- 스프라이트가 하나라도 없으면 그 건물만 도형으로 그린다 (`Sprites.draw`가 false).

## 동작 (게임 상태에서 읽음)

- 포탑: `world.colonyTurretTarget(p)` 방향으로 포신 회전(표적 없으면 법선 ±20° 천천히 훑기). 발사 직후 0.12초 섬광(`turretCooldown`이 `turretInterval`로 다시 찬 시점).
- 광산: 드릴 톱니 회전(레벨 비례 속도) + 흙먼지, 주기적으로 광석 셔틀이 떠서 본거지 방향으로 꺾여 날아가다 사라짐. 습격(`p.raided`) 중엔 정지.
- 교역소: 화물선이 지붕에서 떠서 바깥 고리를 돌고 돌아옴. 습격 중엔 지붕에 내려앉음.
- 정비소: 크레인 팔 흔들림 + 용접 불꽃. 플레이어를 실제로 수리 중(정비 범위 안, HP<최대)이면 더 빠르게 흔들리고 불꽃이 많아짐.
- 방어막 발생기: 구슬·고리 발광 색 = `_paintDome`과 같은 돔 색(`domeState`), 피격 직후 번쩍, 돔이 깨지면 어두운 빨강으로 느리게 깜박.
- 안정기: 접시가 본거지 방향으로 회전(법선 ±66° 제한). 접시 초점이 에너지선(`_paintEnergyLinks`) 시작점, 연결 시 청록 발광.
  스프라이트가 있으면 접시는 그림에 고정되어 회전하지 않고, 초점 발광·에너지선만 본거지를 향한다.
- 프레임당 Path 생성 없음: 도형 Path는 처음 쓸 때 한 번 만들어 캐시(`_Art`), Paint는 정적 객체를 재사용. 행성 컬링은 기존 그대로(건물은 `_paintPlanet` 안에서 그림).

## 증거 PNG

`/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/d6219fb0-cb74-4608-b426-4ff0b861575e/scratchpad/buildings/`
- `tiers.png` — Lv.1 / Lv.3 / Lv.5 나란히 (Lv.5 포탑은 표적 조준 + 발사 섬광)
- `close_lv1.png`, `close_lv3.png`, `close_lv5.png` — 같은 행성 확대(줌 2.6)
- `kinds.png` — 용암·얼음·사막·정원·가스 × 건물 전부
- `zoomout.png` — 최소 줌 0.55

임시 하네스(`test/zz_bld_harness_test.dart`)는 저장 후 삭제했다. 테스트 글꼴(Ahem)이라 이름표 글자는 네모로 나온다.

## 검증

- `dart analyze lib test` → No issues found
- `flutter test --no-pub test/colony_buildings_render_test.dart` → 3/3 통과
  - (a) 건물만 있는 화면 − 건물 없는 화면 차이가 각 건물 상자 안 8% 이상 (6종 × Lv.1/3/5). 색이 아니라 차이로 판정 → 스프라이트로 바뀌어도 유효.
  - (b)(c) 반지름 90/110/140/200 × 줌 0.55/0.8/1.1/1.6 × Lv.1/3/5/8에서 건물 상자끼리, 거주 돔과, 이름표(긴 이름, 테스트 글꼴 글자당 14px로 실제보다 넓게)와 분리축 판정으로 안 겹침.
  - (d) 조준 각도 = 표적 방향(±15°), 그리고 화면 픽셀: (표적 A 화면 − 표적 없음) 중 표적 B 화면에 없는 픽셀의 무게중심 방향이 표적 A 방향 ±15° (Lv.1/3/5, 좌우 ±75°).
  - 변이 확인: 포신 +0.6rad 회전 → (d) 실패, 교역소 미그리기 → (a) 실패(3.7%), 거주 돔 -60° → (b) 실패, 정비소 60° → (c) 이름표 겹침 실패.
- `flutter test --no-pub` 전체 → +507 −6. 실패 6건은 모두 `test/landscape_layout_test.dart:272`
  "게임 HUD @ portrait (phone 390x844 / android 360x740) 항성계 배지 글자 크기 ≥10 (실제 4.9~6.5)" × ko/en/de.
  HUD 위젯(`lib/ui/game_screen.dart`, gameplay-depth TASK 007 미커밋 변경)의 검사로, 이 라운드가 고친 파일(월드 페인터·스프라이트)과 무관하다.
  이 라운드는 해당 파일을 건드리지 않았다(보존 지시). 오케스트레이터 확인 필요.

## 남은 리스크

- Gemini 스프라이트의 실제 여백·받침 높이에 따라 포신 회전축(`_turretPivotY`)과 레벨 점 높이(스프라이트일 때 1.02)를 조정해야 할 수 있다. 스프라이트를 넣은 뒤 게이트 테스트와 증거 하네스를 다시 돌려야 한다.
- 스프라이트 로드는 `Sprites.load` 첫 호출에 덧붙이는 방식. `lib/main.dart`의 목록에 `...Sprites.buildingNames`를 넣는 편이 명확하다(TASK 001 종료 후 오케스트레이터가 판단).
- 포탑 위치가 고정(-48°)이라 표적이 행성 반대편이면 포신이 행성 쪽을 향한다(실제 탄은 기존대로 행성 중심 기준에서 나간다).
- 실기기 확인 안 함(금지). 프레임 비용은 화면 안 식민지 행성당 건물 6채 × Path 수 개 drawPath 수준.


## 오케스트레이터 추가 (2026-11-08, Claude)

- 스프라이트: Gemini 웹(사용자 Chrome)으로 건물별 3단계 한 장씩 생성 → 흰 배경을 가장자리 flood fill로 투명 처리 → 3열 분할 → 256×256, 바닥 정렬.
  스크립트: 스크래치패드 `gemini/slice.py`, 포신은 `gemini/gun_pivot.py`(허브 중심을 이미지 중심(128,128)에 맞춤).
- 1차 포신 슬라이스는 그림 전체를 가운데 놓아 회전축이 허브가 아니었고, 게이트 (d)가 "포신 -155° vs 표적 26°"로 잡았다 → 허브 중심 정렬로 재슬라이스 후 3/3 통과.
- 반영: `assets/sprites/bld_{turret_N_base,turret_N_gun,mine_N,trade_N,dock_N,shieldGen_N}.png` 18장(1.6MB). 안정기 3장은 미반영 → 도형 대체 그림으로 표시 중.
- AI 생성 에셋 기록: 위 18장 모두 Gemini 생성(Google). 프롬프트 요지 — 카툰 우주 식민지 모바일 게임, 같은 건물 3단계 한 줄, 굵은 남색 외곽선, 셀 셰이딩, 흰 배경, 그림자·글자 없음.
