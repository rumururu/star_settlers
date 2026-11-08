---
slug: retention-update-result-005
status: progress
---

# RESULT 005 — 균열 런 모드 (워커 B)

지시서: `TASK_005_CLAUDE.md`, 공통 규칙 `COMMON_RULES.md`. 커밋·서버 배포·기기 실행 없음.

## 변경 파일

새 파일
- `lib/game/rift.dart` — 순수 규칙: UTC 날짜 시드, 파도 구성(`RiftPlan`), 카드 15종(`RiftCard`/`RiftLoadout`), 점수·서버 상한(`RiftScore`), 보상(`RiftRewards`), 기록(`RiftRecords`, Profile.stats)
- `lib/game/rift_world.dart` — `part of 'world.dart'`. `RiftWorld extends GameWorld`(아레나), `RiftOutcome`, `RiftSettlement`, `settle()`
- `lib/ui/rift_screen.dart` — 런 화면(HUD·조이스틱·전투 버튼, 키보드), `RiftArenaPainter`(균열 고리·칼날·충격파), `riftUnlocked()`, `RiftTitleButton` (오케스트레이터가 넣은 `riftMenuIcon` 유지)
- `lib/ui/rift_cards.dart` — 모달 틀 `RiftPanel`(액션 버튼 고정), 소개·카드 고르기·결과·일시정지 패널, 카드 문구
- `supabase/migrations/20261108020000_starset_rift.sql` — `starset_rift_scores`, `starset_rift_max`, `starset_submit_rift`, `starset_rift_board`, `starset_forget`(create or replace)
- `supabase/tests/rift_live.sh` — 실서버 검사 21항목 (live.sh와 같은 형식, 마지막에 Management API로 정리). **실행하지 않음**
- `test/rift_test.dart`(27), `test/rift_ui_test.dart`(13), `test/support/rift_bot.dart`, `tool/rift_sim_test.dart`(분포 측정, 일반 테스트에서 빠짐)

공유 파일 (최소 수정, 편집 직전 다시 읽음)
- `lib/game/world.dart` — `import 'rift.dart';` + `part 'rift_world.dart';` 2줄뿐
- `lib/ui/game_screen.dart` — import 1줄 + 일시정지 메뉴 타일 1개(잠금이면 해금 조건 토스트)
- `lib/main.dart` — import 1줄 + 타이틀 Wrap에 `RiftTitleButton` 1줄
- `lib/services/leaderboard.dart` — `submitRift`/`submitRiftWeekly`/`fetchRift`, `LeaderboardEntry.waves`(선택)
- `lib/ui/leaderboard_screen.dart` — `rift:` 인자가 있으면 '개척 점수 | 균열' 탭, `RiftBoardView`. 인자 없는 기존 사용(테스트)은 그대로
- 번역: `python3 tool/arb_add.py`로 `rift_` 68키 × 10개 언어 → `flutter gen-l10n`

## 설계 결정

- **엔진 재사용**: 새 엔진 없음. `RiftWorld`가 `GameWorld`를 상속해 `update()`만 줄인 판을 돈다 — `_updatePlayer/_updateDrone/_updatePirates/_updateMissiles/_updateHostileOrdnance/_updateBullets/_updatePickups/_updateParticles` 그대로 호출. 식민지·정거장·경제·스토리·이벤트·침공·스폰은 돌리지 않는다. part 파일이라 비공개 메서드 `_damagePlayer`(안전 구역·통계·대사 제거), `_onKilled`(점수·조각만), `_collect`(조각=점수, 젬·크레딧 없음), `_makePirate`(파도 배율), `_newbieMul`을 재정의.
- **그리기 재사용**: `WorldPainter` 그대로 + 위에 `RiftArenaPainter` 한 겹. 그리기 코드가 본거지를 늘 찾으므로 본거지 하나만 아레나 밖 먼 구석(-3800,-3800)에 둔다. 아레나 중심 (2200,2200) 반경 1300. 배경 항성계는 시드로 1~5 중 하나 → 그 항성계의 캠페인 임무는 `campaignMissionActive=false`로 끔.
- **메인 저장 분리**: 런은 런 전용 `Profile`(함선 종류·스킨·복장·순항만 복사)을 쓰고 아무것도 저장하지 않는다. 결과 때만 `settle()`이 메인 프로필(균열 기록·젬)과 메인 월드(크레딧·광석)를 고친다. 타이틀에서 들어오면 세이브를 읽어 넣고 저장, 일시정지 메뉴에서 들어오면 지금 월드에 넣고 저장.
- **공정성**: 능력치는 기본 정찰선 Lv.0 고정(체력 100·피해 10·간격 0.25초) + 미사일·방어막 Lv.1 기본 장비. 함선 고유 능력(치명타·관통·보호막·크레딧 배율)도 무시하고 카드로만. 카드 제시는 오늘 시드로 15장 전체에 가중 순위(A-ES)를 매겨 위에서 3장 → 같은 날·같은 파도면 모두 같은 순서, 이미 최대인 카드만 건너뜀.
- **파도**: 1~9파 `3+2n`척(기본 해적 → 3파 폭격선 → 4파 저격선 → 5·7·8파부터 오늘의 후반 적 3종, 큰 적은 파도당 2척까지), 10파 = 균열 두목(오늘의 원형 패턴) + 호위 8. 체력 ×(1+0.12(n−1)), 공격 ×(0.5+0.07(n−1)). 돌파 시 체력 30% 회복 → 카드 3장 중 1장 → 3초 카운트다운.
- **균열 붕괴**: 수리선 2척이 서로 고치거나 유령선이 숨으면 끝나지 않는 파도가 봇에서 나와(15분 정지), 파도 50초 뒤 남은 적이 초당 최대 체력 4%씩(10초마다 더 빨리) 깎이게 함. HUD에 '균열 붕괴 중!'.
- **점수·서버 상한**: 격추 = 종류 기본점 × 파도, 조각 = 격추점/2(주우면 점수), 돌파 150×n, 정복 3000 + 480초 미만 초당 10점. 균열이 직접 낸 적만 점수(모함 드론·두목 호위 0) → 상한 계산 가능. `maxForWave(r)`: [450, 1860, 4590, 9000, 15450, 24300, 35910, 50640, 68850, **95700**]. SQL `starset_rift_max`와 같은 식(파이썬으로 따로 계산해 일치 확인, 테스트가 값·SQL 문구를 고정).
- **보상**: 크레딧 (40+45×돌파)×메인 `rewardMul`, 광석 (6+5×돌파)×`sectorMul`. UTC 하루 처음 3판 전액, 이후 1/4. 젬은 전액 판에서만 `earnGems('play', …)`: 5파 이상 1, 10파 정복 3.
- **승무원 경험치**: 이 게임 승무원에는 경험치가 없다(레벨업 = 크레딧, `crew.dart`는 수정 범위 밖) → 크레딧 보상으로 대신함. 필요하면 별도 작업.
- **해금**: 스토리 2단계('습격 함선 3척 격파') 이상. 세이브 원문의 `story`나 현재 월드로 확인하고 `stats['riftOpen']=1`을 남김 → 환생해도 열림. 잠금이면 자물쇠 + 누르면 해금 조건 토스트.
- **기록 저장**: `Profile.stats`(기존 'stats' 정수 맵)에 `rift*` 키 — 저장 형식 변경 없음, 예전 저장은 0.
- **주간 순위**: 같은 별명·참여 동의. 런이 끝나면 참여 중일 때 이번 주 최고를 보냄(이미 보낸 점수는 다시 안 보냄, 지난주 미전송분은 다음 주 먼저). 서버 요청 제한은 개척 점수와 같은 표·같은 잠금 키를 공유(1분 5회).
- **UI**: 모달은 한 번에 하나(`RiftPanel`), 바깥 눌러도 안 닫힘. 내용만 스크롤, 버튼 줄은 늘 아래 고정(가로 폰). 가로는 패널을 680까지 넓히고 카드는 가로 3장·아이콘을 이름 옆에. 뒤로 가기 = 일시정지, 백그라운드 = 일시정지, 도중 나가기 = 포기(도달 파도까지 기록·보상).

## 이벤트 발생 위치

- `rift_start`: `lib/ui/rift_screen.dart` `_launch()` (출격·다시 도전)
- `rift_end`(value = 도달 파도): `lib/game/rift_world.dart` `RiftSettle.settle()` (격추·정복·포기 모두)
- 런 중에는 `first_kill/first_boss/first_death`를 보내지 않음(재정의한 `_onKilled/_damagePlayer`). 새 이벤트 이름 없음.

## 봇 측정 (헤드리스, 기존 전투 엔진, dt 1/20, 날짜 30개)

`flutter test --no-pub tool/rift_sim_test.dart` — 시간은 전투 시간(카운트다운 포함, 카드 고르는 시간 제외).

| 실력 / 카드 전략 | 평균 | 중앙값 | 최소~최대 | 정복 | 도달 파도 분포 | 파도별 평균 초 (1→10) |
|---|---|---|---|---|---|---|
| **보통 / 기본(선호 순서)** | **3.24분** | 2.82 | 1.16~7.55 | 3/30 | 4:1 5:2 6:9 7:6 8:6 9:1 10:5 | 10 17 16 24 30 31 35 56 52 42 |
| 보통 / 맨 왼쪽 | 3.05분 | 2.81 | 0.83~5.95 | 0/30 | 3:1 5:2 6:13 7:7 8:5 9:2 | 10 19 20 26 38 43 43 50 |
| 잘함 / 기본 | 4.87분 | 5.27 | 1.95~8.65 | 10/30 | 5:2 6:1 7:2 8:4 9:5 10:16 | 8 15 16 27 34 34 41 54 58 43 |
| 잘함 / 맨 왼쪽 | 4.87분 | 4.90 | 1.81~8.28 | 7/30 | 5:2 … 10:10 | 8 16 17 27 39 42 49 61 66 57 |
| 서툼 / 기본 | 0.45분 | 0.40 | 0.32~0.68 | 0/30 | 2:17 3:12 4:1 | 7 11 6 |

- 보통 봇은 카드 6장 안팎을 고르므로 실제 세션은 + 약 0.4분(장당 4초 가정) ≈ 3.6분.
- 서툼 봇 = 제자리에 서서 쏘기만(이동·스킬 없음): 1~2파에서 죽음. 하한 참고용.
- 게이트: `test/rift_test.dart` '보통 실력 + 기본 카드 전략: 평균 런 3~5분'(20일) 통과.

## 검증

- `dart analyze lib test`: **No issues found** (전체)
- `flutter test --no-pub test/rift_test.dart test/rift_ui_test.dart`: **40/40 통과**
  - 단위: 시드 결정성(UTC·같은 날 같은 구성·날짜별 차이), 카드 효과·중첩·최대, 제시 순서, 점수·상한(400일 구성 전수, SQL 값 고정), 보상 하루 상한, 기록·주 넘김·보낸 표시, 해금, 아레나 흐름(파도→카드→다음 파도·조각 줍기), 카드→엔진 능력치, 칼날·충격파·흡수, 아레나 경계, 격추·포기, 붕괴, 같은 조작 같은 결과, 봇 30판 점수 ≤ 상한, **메인 저장 불변**(런 전후 메인 world/profile JSON 동일, 정산 뒤 차이는 크레딧·광석·젬·`rift*` 통계뿐), 4판째 감액·다음 날 복구, 세이브 없음
  - 위젯/렌더 게이트: 소개·카드·결과(정복/감액+세이브 없음)·일시정지·순위 '균열' 탭·런 HUD·실제 런의 카드 화면을 ko/en/de × 세로 390×844 / 가로 800×360 × 글자 1.3에서 넘침 0, HUD 위젯(정보·상태·일시정지·조이스틱·전투) 겹침 0·안전 영역 안, 카드·일시정지 버튼 48dp 이상, 포기→결과 흐름
- 전체 `flutter test --no-pub` (다른 워커가 동시에 고치는 중인 트리): 마지막 실행 617 통과 / 3 실패 — 아래 '남은 리스크' 1 (내 파일 아님). 그 전 실행은 622/5 실패로, 실패 수가 다른 워커 편집에 따라 바뀌고 있다.
- SQL: 로컬 DB 컨테이너가 없어 실행 검증 못 함(다른 프로젝트 컨테이너는 손대지 않음). 식은 Dart와 파이썬 재계산으로 일치 확인.

## 증거 PNG

`/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/d6219fb0-cb74-4608-b426-4ff0b861575e/scratchpad/task005/`
- `{intro,picker,result_win,result_reduced,pause,board,hud,hud_picker}_{ko,en,de}_{portrait,landscape}.png` (48장, `RIFT_SNAP_DIR=… flutter test --no-pub test/rift_ui_test.dart`로 다시 만듦)
- 묶음: `sheet_p1_de.png`(HUD·카드·소개·일시정지 세로), `sheet_p2_de.png`(결과·카드·순위 세로), `sheet_l3_de.png`(가로 소개·결과·카드), `sheet_mix.png`(ko/en/de HUD), `arena_edge.png`(균열 고리·칼날 3개)
- 직접 보고 고친 것: 가로에서 결과·소개 버튼이 스크롤 아래로 숨음 → 버튼 줄 고정 + 가로 패널 확장 / 가로 카드 아래가 잘림 → 아이콘을 이름 옆으로 / 'Schildregeneration'이 단어 중간에서 끊김 → 이름 한 줄 축소 / '15 %'의 %만 다음 줄 → 숫자-단위 사이 줄바꿈 없는 공백 / 보상 숫자 자릿수 구분.
- 테스트 글꼴(Jua)에 독일어 움라우트·`·`·`−`·이모지·머티리얼 아이콘 글리프가 없어 □로 보임(기존 테스트와 같은 한계, 기기에서는 대체 글꼴).

## 남은 리스크

1. **전체 테스트 실패 3건 (균열 코드와 무관, 고치지 않음)**:
   - `test/story_test.dart:253` '플레이 저장이 있는 다음 접속에는 출석 보상을 표시한다' — '📅 출석 보상' 대화창을 못 찾음. 워커 A의 출석 달력(TASK 004) 작업으로 보임.
   - `test/widget_test.dart:606` '식민지 방어막: 탄을 대신 맞아 줄고…' — 300 기대, 260.8 나옴. 메인 게임 식민지 방어막 수치(내 변경은 world.dart에 part/import 2줄뿐).
   - `test/balance_test.dart` '뒤 항성계(3~6): 장비 ⭐1200…' 진행 밸런스 — 메인 게임 경제(균열은 메인 월드 update를 바꾸지 않음).
2. **서버 미배포**: 마이그레이션 `20261108020000_starset_rift.sql` 적용 + `supabase/tests/rift_live.sh` 실행은 오케스트레이터 몫. 배포 전 앱에서는 균열 탭이 서버 오류 문구를 보이고, 런 종료 시 제출은 조용히 실패(기록은 기기에 남고 다음에 다시 보냄).
3. `starset_forget`의 `deleted`가 이제 개척 점수 행 + 균열 행 합계. 기존 `live.sh`의 기대값(점수 1행 → 1)은 그대로 맞음.
4. 점수는 클라이언트 계산이라 상한 안의 조작은 막지 못함(기존 개척 점수와 같은 수준). 파도별 상한으로 '1파에서 9만 점' 같은 값은 거부.
5. 승무원 경험치 보상 없음(시스템 부재) — 크레딧으로 대체.
6. 실기기 미확인(규칙상 기기 실행 금지): 조작감, 카드 고르기 시간, 오디오, 실제 글꼴 렌더는 오케스트레이터 확인 필요.
7. 오늘 시드는 UTC 자정에 바뀜 — 런 도중 자정을 넘기면 그 판은 시작한 날 구성으로 끝나고 기록은 끝난 날 판 수에 들어감.
