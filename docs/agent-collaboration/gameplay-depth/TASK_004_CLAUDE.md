---
slug: gameplay-depth-task-004
status: active
---

# TASK 004 — 항성계 보스 (Claude 워커)

> TASK 003(식민지 특화) 결과 위에서 작업한다. 003·001·002 변경을 되돌리지 않는다.

## 목표
지금은 모든 항성계 두목이 같은 `PirateKind.boss`(원형 탄막 + 체력 50%에서 부하 소환)다.
항성계 특성(`lib/game/system_traits.dart`)에 맞춰 **두목의 싸움 방식이 항성계마다 달라지게** 한다.

## 배경
- 상태·이전 결과: `docs/agent-collaboration/gameplay-depth/` (`PIPELINE_STATE.md`, `RESULT_00*`)
- 두목 등장·처치·패턴: `lib/game/world.dart` (`sectorBoss`, `sectorBossSpawned`, `bossDefeated`, `_bossPattern`, 두목 격파 보상 블록)
- 재사용할 기존 기제(새로 만들지 말고 가져다 쓴다): 적 레이저 `_fireEnemyLaser`/`LaserBeam(hostile: true)`, 은신 `Pirate.cloaked`, 기뢰 `SpaceMine`, 유도탄 `EnemyMissile`, 소환 `_spawnQueue`
- 그림: `lib/ui/world_painter.dart` (적 그리기, `_paintFoeAura`), 스프라이트 `pirate_boss`

## 규칙 (이대로 구현)
`sectorBoss == true`인 두목(항성계 두목)에게만 항성계 특성에 따른 원형(archetype)을 붙인다. 태양계(특성 없음)와 격파 후 재등장하는 일반 두목은 지금 그대로.

| 특성 | 두목 이름(ko) | 고유 패턴 (기존 원형 탄막·50% 분노는 유지) |
|---|---|---|
| pirateNest | 해적 함대장 | 10초마다 호위 2기(습격선) 소환, 맵 위 호위 최대 6 |
| richVeins | 광맥 포식자 | 5초마다 자기 주위에 기뢰 3개 살포 (기존 기뢰 규칙, 맵 최대치 공유) |
| solarFlare | 플레어 포격함 | 7초마다 1.5초 충전 후 적 레이저 3갈래(±20°) 발사, 충전 중 조준선 표시 |
| ionNebula | 이온 유령 | 4초 은신 ↔ 4초 노출 반복(은신 중 피격·조준 불가, 기존 phantom 규칙) |
| gravityWell | 중력 군주 | 반경 700 안 플레이어를 초당 120만큼 두목 쪽으로 끌어당김(부스트 중엔 무시), 범위 링 표시 |
| tradeLane | 약탈 상선 | 이동 속도 ×1.4, 플레이어에게 탄이 맞을 때마다 크레딧 1%(최대 처치 보상의 50%까지 누적) 빼앗음, 처치 시 빼앗은 만큼 + 기존 보상 돌려받음 |

- 등장 대사: 두목 이름이 들어간 경고 한 줄(미나), 처치 시 기존 보상 대사 유지.
- 겉모습: 새 이미지 없이 `pirate_boss` 스프라이트에 원형별 색조(ColorFilter) + 원형별 오라(중력 링, 충전 조준선 등). 두목 이름표가 있다면 이름을 원형 이름으로.
- 저장: 진행 중 두목 상태는 저장하지 않아도 된다(기존처럼). 원형은 항성계 인덱스에서 결정되므로 별도 저장 불필요.
- 밸런스: 두목 체력·보상 수치는 그대로.

## UI·문구
- 새 ARB 키(두목 이름 select, 등장 경고 select)는 `app_ko.arb`에 `@설명`과 함께, 10개 언어 모두. `flutter gen-l10n` 재생성.
- `docs/GAME_DESIGN.md` 적 표 아래 "항성계 두목" 표 추가.
- 스크래치 패드의 적 도감 HTML은 건드리지 않는다.

## 테스트 (새 파일 `test/system_boss_test.dart`)
- 태양계 두목: 원형 없음(기존 패턴), 각 특성 항성계의 항성계 두목: 해당 원형
- 원형별 기제가 실제로 일어남: 소환 수·상한, 기뢰 살포, 레이저 3갈래 생성, 은신 주기·은신 중 피해 무시, 중력 끌림(부스트 중 무시), 약탈 누적 상한·처치 시 반환
- 일반 재등장 두목은 원형 없음
- `flutter test --no-pub` 전체 통과, 밸런스 기대값 완화 금지

## 수정 가능 파일
`lib/game/models.dart`, `lib/game/world.dart`, `lib/game/system_traits.dart`, `lib/ui/world_painter.dart`, `lib/l10n/app_*.arb`, `lib/l10n/generated/*`,
새 테스트, 영향받는 기존 테스트, `docs/GAME_DESIGN.md`.

## 금지
- 위 목록 밖 파일, 새 에셋, 테스트 기대 완화/skip/디버그 플래그 우회
- git commit/checkout/reset/revert/stash, 기기·에뮬레이터 실행 금지

## 검증 (반드시 실행)
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
flutter gen-l10n
dart analyze lib test
flutter test --no-pub
```
그림은 기존 렌더 하네스 방식(임시 테스트로 `WorldPainter`를 PNG로 그려 확인 후 임시 파일 삭제)으로 6개 원형을 한 장씩 렌더해
스크래치 경로 `/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/8c303f23-a6f8-467a-a28b-99d3781e7ca6/scratchpad/bosses/`에 저장한다.

## 결과
`docs/agent-collaboration/gameplay-depth/RESULT_004_CLAUDE.md`: 변경 파일, 요약, 검증 결과(통과 수, S1 분·S3~S6 일수), 렌더 PNG 경로, 못 한 검증, 남은 리스크.
