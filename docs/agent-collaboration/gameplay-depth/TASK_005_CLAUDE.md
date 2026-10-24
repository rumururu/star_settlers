---
slug: gameplay-depth-task-005
status: active
---

# TASK 005 — 대규모 침공 (Claude 워커)

## 목표
평소 전투는 해적이 몇 기씩 들어오는 흐름이라 긴장감의 굴곡이 없다. 중간중간 **예고된 대규모 침공**이 와서
"경보 → 준비 → 파도 3번 → 지휘함 → 큰 보상"이라는 고비를 만든다.

## 배경
- 프로젝트: `/Volumes/home_extension/AndroidStudioProjects/star_settlers` (Flutter, 마지막 커밋 `80fb9c6`, 작업 트리 깨끗)
- 이전 라운드 기록: `docs/agent-collaboration/gameplay-depth/` (`PIPELINE_STATE.md`, `RESULT_00*`)
- 관련 코드 (`lib/game/world.dart`): 이벤트 `_updateEvents` / `_startRandomEvent` / `startEvent`(습격 `EventKind.raid`가 가장 비슷한 선례: `eventId`로 소속 표시, 성공 보상·실패 처리),
  일반 스폰(`spawnTimer`, `maxPirates`, `_randomKind(t)` — 항성계별 후반 적 포함), `_makePirate`, `threat`, `rewardMul`, `shipCreditMul`, 현상수배 엘리트(`name`),
  두목 원형(TASK 004) — 침공 지휘함에는 원형을 붙이지 않는다.
- HUD/화면: `lib/ui/game_screen.dart`(이벤트 표시·경보), `lib/ui/world_painter.dart`(방향 표시가 있다면 재사용), 미니맵.

## 규칙 (이대로 구현, 수치 그대로)
1. **해금**: 현재 항성계 식민지 수 ≥ 3. 태양계도 포함(단, 태양계는 아래 규모 ×0.6).
2. **주기**: 해금 뒤 첫 침공은 항성계 체류 300초 이후, 그다음은 끝난 시점부터 `randRange(360, 480)`초. 플레이어가 죽어 있으면 미룬다.
   항성계를 옮기면 타이머를 새로 시작(진행 중 침공은 취소, 보상 없음). 진행 중 침공·타이머는 저장하지 않아도 된다(불러오면 새로 시작).
3. **경보 20초**: 미나 경고 + HUD 상단 배너 "대규모 침공까지 N초" + 침공 방향 표시(본거지 기준 무작위 방향, 맵 가장자리 쪽).
4. **파도 3번**, 25초 간격. 파도 크기 = `min(18, (6 + threat * 1.5).round())` (태양계 ×0.6, 최소 4). 구성은 `_randomKind(threat)`.
   등장 위치는 침공 방향의 가장자리 부근(본거지에서 1600~2000)에 흩뿌린다. 침공 적은 본거지·정거장·식민지를 향해 온다(기존 습격 AI처럼 목표 지정이 가능하면 본거지).
   3번째 파도에 **침공 지휘함** 1기: `PirateKind.raider` 기반 엘리트(체력 ×6, 공격 ×1.5, 크기 ×1.4, 이름 "침공 지휘함" 표시, 현상금 ×4).
5. **일반 스폰 중지**: 침공 진행 중(경보 포함)엔 일반 해적 스폰을 멈춘다(맵 위 과부하 방지). 습격 이벤트는 새로 시작하지 않는다.
6. **판정**: 마지막 파도 등장 후 90초 안에 침공 소속 적 전멸 → **승리**: 크레딧 `600 × rewardMul × shipCreditMul` + 젬 5, 미나 축하.
   시간 초과 → **퇴각**: 남은 침공 적 제거, 보상 = 승리 크레딧 × (처치 비율) (젬 없음), 식민지 레벨 손실 없음.
7. HUD: 진행 중엔 배너에 "침공 2/3 · 남은 적 N", 승리/퇴각 때 한 줄 결과. 기존 이벤트 목록 표시 방식에 맞춘다.
8. 통계: `profile.addStat('invasions')`(승리 시). 업적·주간 점수 연결은 하지 않는다.

## UI·문구
- 새 ARB 키(경보, 배너 카운트다운, 파도 진행, 승리, 퇴각, 지휘함 이름)는 `app_ko.arb`에 `@설명`과 함께, 10개 언어 모두 기존 용어에 맞춰. `flutter gen-l10n` 재생성.
- 한국어 문구는 기존처럼 `keepAll` / 조사 헬퍼(`lib/game/josa.dart`) 사용.
- 배너는 기존 HUD 예약 영역을 침범하지 않게(조이스틱·발사·미니맵·임무 카드와 겹침 금지). 360×740, 800×360, 글자 1.3배에서 넘침 없음.
- 새 이미지 에셋 금지.
- `docs/GAME_DESIGN.md`에 "대규모 침공" 단락 추가.

## 밸런스
- `flutter test --no-pub` 전체 통과, `test/balance_test.dart` 기대값 완화 금지. 봇(`test/support/progression_bot.dart`)은 침공을 특별히 다루지 않아도 되지만,
  깨지면 원인(사망 증가 등)을 수치로 보고하고, 봇 우선순위(침공 중엔 본거지 근처에서 싸우기 등)로 해결한다. 규칙 수치는 바꾸지 말고 보고.

## 테스트 (새 파일 `test/invasion_test.dart`)
- 식민지 2개면 침공 없음, 3개면 300초 뒤 경보 → 20초 뒤 1파 → 25초 간격 3파, 3파에 지휘함 1기
- 파도 크기 공식(태양계 ×0.6, 최소 4, 최대 18), 경보·진행 중 일반 스폰 중지
- 전멸 승리 보상, 시간 초과 퇴각(남은 적 제거, 처치 비율 보상, 젬 없음, 식민지 레벨 그대로)
- 항성계 이동 시 취소, 플레이어 사망 중 시작 미룸, 다음 침공 간격 360~480초
- 위젯: 배너(경보/진행/결과) 10개 언어, 360×740 / 800×360, 글자 1.3배 넘침 없음

## 수정 가능 파일
`lib/game/models.dart`, `lib/game/world.dart`, `lib/ui/game_screen.dart`, `lib/ui/world_painter.dart`, HUD 관련 기존 위젯 파일, `lib/l10n/app_*.arb`, `lib/l10n/generated/*`,
`test/support/progression_bot.dart`, 새 테스트, 영향받는 기존 테스트, `docs/GAME_DESIGN.md`.

## 금지
- 위 목록 밖 파일, 새 에셋, 테스트 기대 완화/skip/디버그 플래그 우회
- git commit/checkout/reset/revert/stash, 기기·에뮬레이터 실행(`flutter run`, `frun`)

## 검증 (반드시 실행)
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
flutter gen-l10n
dart analyze lib test
flutter test --no-pub
```
배너·방향 표시는 렌더 하네스(임시 테스트로 실제 `WorldPainter`/HUD를 PNG로 그려 확인 후 임시 파일 삭제)로 경보·진행 두 장면을 렌더해
`/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/8c303f23-a6f8-467a-a28b-99d3781e7ca6/scratchpad/invasion/`에 저장한다.

## 결과
`docs/agent-collaboration/gameplay-depth/RESULT_005_CLAUDE.md`: 변경 파일, 요약, 검증 결과(통과 수, S1 분·S3~S6 일수·사망 변화), 렌더 PNG 경로, 못 한 검증, 남은 리스크.
