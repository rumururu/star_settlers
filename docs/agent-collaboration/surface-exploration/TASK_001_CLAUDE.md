---
slug: surface-exploration-task-001
status: spec
---

# TASK 001 — 지표 탐험 게임 규칙 (그다음 TASK 002 화면)

## 목표
[SPEC.md](SPEC.md)의 지표 탐험을 게임 규칙 계층에서 구현하고 단위 테스트로 고정한다. 끝나면 이어서 [TASK_002_CLAUDE.md](TASK_002_CLAUDE.md)를 한다.

## 배경
- 저장소: `/Volumes/home_extension/AndroidStudioProjects/star_settlers` (Flutter). 사용자에게 보이는 문구·문서·결과는 한국어.
- 본보기: 균열 런 `lib/game/rift_world.dart`(`part of 'world.dart'`, `GameWorld`를 상속해 전투 엔진을 다시 쓰고 피해·격추·줍기만 바꿈), `lib/game/rift.dart`(기록·보상), `lib/ui/rift_screen.dart`.
- 공통 규칙은 `docs/agent-collaboration/retention-update/COMMON_RULES.md`를 따른다(젬 규칙, 번역은 `tool/arb_add.py`, 하위 호환 저장, 금지 사항). 이번엔 워커가 혼자라 동시 작업 조항은 신경 쓰지 않아도 된다. 번역 키 접두사 `srf_`.

## 수정해도 되는 파일
- 새 파일: `lib/game/surface.dart`(지도·지점·기록·보상 같은 순수 규칙), `lib/game/surface_world.dart`(`part of 'world.dart'`), 테스트 `test/surface_*_test.dart`
- `lib/game/world.dart`(part 선언, 행성 영구 발견 저장·적용, 진입 가능 판정, 미나 안내 한 번), `lib/game/models.dart`(`Planet` 발견 필드, 방어막·생산 적용)
- `lib/game/codex.dart`(유물 탭 데이터), `lib/game/game_telemetry.dart`(이벤트 2개), `lib/game/profile.dart`(필요할 때만)
- `supabase/migrations/20261111000000_starset_events_v3.sql`(새 파일), `test/telemetry_test.dart`(동기화 검사가 새 마이그레이션을 읽게 할 필요가 있을 때만)

## 수정하면 안 되는 것
- 서버 지갑 SQL·서버 함수, `assets/`(그림은 오케스트레이터가 넣는다), 기존 균열 런 동작, git 명령 전부.

## 구현 요구사항
1. `SurfaceWorld extends GameWorld`: SPEC §1~§6. 진입 때 메인 월드에서 선장 능력치(§5)와 적 배율, `sectorMul`·`rewardMul`을 읽는다. 메인 월드 객체는 정산 함수 말고는 바꾸지 않는다.
   - 장애물 충돌(차량·생물·탄), 위험 지대 효과, 사각 경계.
   - 지점 상태 기계(유적 4초·광맥 3초 머물기, 잔해 1초, 둥지 체력·생물 낳기), 산소 150초, 30초 경고, 귀환 판정, 결과 `SurfaceOutcome`(전리품·발견·유물·끝난 이유·남긴 비율).
   - 생물: 기존 `PirateKind` 동작을 쓰되 생물 종류(crawler/spitter/brute)를 알 수 있게(그리기용). 격추 때 크레딧·젬·통계·임무·도감 적 항목이 쌓이지 않게 `_onKilled`/`_collect` 등을 재정의.
2. 지도 생성은 시드로 결정적. 같은 행성 = 같은 지도. 지점·착륙선 주변에 장애물 없음, 모든 지점이 착륙선에서 도달 가능(장애물로 막힌 지점 없음 — 테스트로 확인).
3. 행성 영구 발견(`vein`, `nest`, `surveyed`)을 `Planet`에 두고 현재 항성계 저장과 `SectorSave`(다른 항성계)에 **하위 호환**으로 저장. 효과는 SPEC §6대로 생산·방어막·원격 수입에 반영.
4. 정산 `SurfaceOutcome.settle(...)`: 하루 3회 온전 보상(`srfDay`/`srfRuns`), 완전 탐사 첫 회 젬 3개(`earnGems('play', …)`), 유물을 도감에 기록(토스트), 영구 발견 기록, 통계 `surface_end`.
5. 진입 판정 `GameWorld.canLand(Planet)`: 가스 아님 + 해금(SPEC §1). 해금 직후 처음 행성 곁에 가면 미나 대사 한 번(프로필 플래그).
6. 유물 8종: 도감 데이터(`CodexTab.relics`, 항목 id, 그림 이름 `relic_<id>`, 마일스톤). 도감 UI는 TASK 002.
7. 통계: `surfaceStart('surface_start')`, `surfaceEnd('surface_end')` + 허용 목록 마이그레이션 v3.

## acceptance criteria (테스트로 남길 것)
- 지도 결정성, 지점 5곳 구성, 지점·착륙선 주변 장애물 없음, 모든 지점 도달 가능(격자 BFS 등).
- 유적·광맥 머물기 진행/중단, 둥지 파괴 시 생물 낳기 중단, 산소 0 → 50%, 격추 → 50%, 귀환 → 100%.
- 정산: 하루 4회째 30%, 완전 탐사 젬은 행성당 한 번, 유물 꽝 3연속 뒤 확정, 이미 가진 유물은 다시 안 나옴.
- 영구 발견이 생산·방어막·원격 수입에 반영되고, 저장/불러오기 왕복에서 유지. 발견 필드가 없는 옛 저장도 읽힘.
- 보상 기준값 고정 테스트(한 판 100% ≈ 같은 항성계 본 게임 약 2분 수입, 허용 범위를 테스트에 적는다).
- 봇 테스트: 간단한 자동 조종(가까운 지점 → 착륙선)으로 시드 여러 개를 돌려 한 판 평균 시간이 90~170초이고, 기본 능력치(새 게임 첫 항성계 + 첫 식민지)로 격추율이 너무 높지 않음(봇 기준치를 결과에 적는다).

## 검증 명령
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
dart analyze lib test
flutter test --no-pub
```
전체 테스트가 통과해야 한다(이전 기준 639개 + 새 테스트).

## 결과
`docs/agent-collaboration/surface-exploration/RESULT_001_CLAUDE.md`(한국어): 변경 파일, 설계 결정(SPEC과 다르게 한 것과 이유), 봇 측정값, 검증 결과, 남은 리스크.
