---
slug: retention-update-task-002
status: progress
---

# TASK 002 — 식민지 건물 외형 (Codex)

## 목표
식민지에 지은 건물이 **행성 위에 실제 구조물로 보이고, 하는 일이 화면에서 보이게** 한다. 업그레이드할 때마다 외형이 눈에 띄게 좋아져야 한다.

## 현재 (Claude 렌더 확인, 2026-11-08)
- 식민지 레벨 = 행성 위쪽 호에 똑같은 회색 반원 + 노란 막대 n개(`lib/ui/world_painter.dart:497-521`). 건물 종류와 무관.
- 건물 = 이름 아래 이모지 글자 `🔫3 ⛏3 …`(`:580-591`)뿐. 행성 위에 건물 그림이 없다.
- 건물 6종: `ColonyBuilding { turret, mine, trade, dock, shieldGen, stabilizer }` (`lib/game/models.dart:619`). 레벨 상한 = 식민지 레벨(최대 5).
- 식민지 포탑의 표적 선택: `lib/game/world.dart:3372` 근처(`p.turretRange`).

## 구현 요구
1. **스프라이트 생성**: 기존 생성 아트(`assets/sprites/*.png`, 256×256 RGBA, 투명 배경, 같은 카툰 화풍 — `planet_lava.png`, `pirate_raider.png` 참고)와 맞춰 Codex 이미지 생성으로 만든다.
   - 건물 6종 × 외형 3단계(Lv.1-2 / 3-4 / 5) = 18장, 이름 `bld_<kind>_<tier>.png` (예: `bld_turret_1.png`). 포탑은 받침과 포신을 분리(`bld_turret_<tier>_base`, `_gun`)해 포신을 회전시킨다.
   - 그림자·배경 없이, 아래쪽이 지면에 닿는 구도(행성 표면에 세우기 위해). 생성 후 투명도·크기 검사.
2. **배치**: 건물을 행성 둘레(표면 법선 방향으로 세움)에 겹치지 않게 고정 각도로 배치. 식민지 레벨 표시(지금의 돔들)는 정리 — 거주 돔은 레벨에 따라 1~3개로 줄이고 건물이 주인공이 되게. 행성 크기(radius)에 비례한 크기, 줌 아웃에서도 알아볼 수 있는 최소 크기.
3. **동작 애니메이션** (게임 상태를 읽어서, 가짜 장식 아님):
   - 포탑: 포신이 실제 표적(world의 식민지 포탑 표적)을 향해 회전, 발사 시 섬광.
   - 광산: 드릴 회전 + 주기적으로 작은 광석 셔틀이 본거지 방향으로 날아감(그림 효과만).
   - 교역소: 작은 화물선이 오가는 루프. 정비소: 크레인 흔들림 + 용접 불꽃.
   - 방어막 발생기: 안테나 발광이 돔(`_paintDome`) 상태 색과 연동. 안정기: 접시가 본거지 방향을 향하고 에너지선(`_paintEnergyLinks`)의 시작점이 됨.
   - 매 프레임 할당·Path 생성 최소화(기존 프레임 드롭 수정 이력 있음). 화면 밖 행성은 그리지 않는 기존 컬링 유지.
4. 이모지 라벨은 제거하거나 줌 아웃에서만 보조로. 건물 레벨은 작은 점/별로 구조물 옆에 표시.
5. 스프라이트가 없을 때의 도형 대체 그리기 유지(`Sprites.draw`가 false면 간단한 도형).

## 수용 기준 (게이트)
- 렌더 테스트 `test/colony_buildings_render_test.dart`(새): 식민지 Lv.5 + 건물 6종 각 Lv.1/3/5 장면을 그려
  (a) 각 건물 위치에 해당 스프라이트 픽셀이 실제로 그려졌는지, (b) 건물끼리 바운딩 박스가 겹치지 않는지, (c) 행성 이름 라벨과 겹치지 않는지, (d) 포탑 포신 각도가 표적 방향 ±15° 안인지 검사.
- 증거 PNG: Lv.1/3/5 비교, 행성 종류 5가지(용암·얼음·사막·정원·가스) × 건물 전부, 줌 아웃 1장을
  `/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/d6219fb0-cb74-4608-b426-4ff0b861575e/scratchpad/buildings/`에 저장(임시 하네스는 저장 후 삭제, 게이트 테스트는 남김).
- `pubspec.yaml`의 assets 등록 확인, 스프라이트 로드 목록에 추가.

## 검증 (반드시)
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
dart analyze lib test
flutter test --no-pub
```

## 수정 가능
`lib/ui/world_painter.dart`, `lib/ui/sprites.dart`(필요 시), 스프라이트 로드 목록이 있는 파일, `assets/sprites/bld_*.png`(새), `pubspec.yaml`(assets만), `lib/game/world.dart`(포탑 표적·발사 시점을 읽기 전용 getter로 노출하는 최소 변경), `test/colony_buildings_render_test.dart`(새).

## 금지
- `lib/services/`, `supabase/`, `docs/PRIVACY_POLICY*` (TASK 001이 동시에 작업 중)
- `lib/ui/game_screen.dart`, `test/landscape_layout_test.dart`의 기존 미커밋 변경 훼손
- 게임 밸런스(사거리·피해·비용) 변경, git commit/checkout/reset/revert/stash, 기기·에뮬레이터 실행

## 결과
`docs/agent-collaboration/retention-update/RESULT_002_CODEX.md`: 변경 파일, 스프라이트 생성 방법(프롬프트), 증거 PNG 경로, 검증 결과, 남은 리스크.
