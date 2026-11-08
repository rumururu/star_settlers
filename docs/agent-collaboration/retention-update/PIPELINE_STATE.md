---
slug: retention-update-pipeline-state
status: progress
---

# retention-update — 상태 (1.0.8 목표)

목표: 첫날 이탈을 줄이고 다시 올 이유를 만든다. 동시에 어디서 그만두는지 측정한다.
결정(2026-11-08, 사용자): 이번 업데이트 = 측정 · 첫 5분 · 복귀 동기 · 균열 런 · 도감 · 건물 외형.
선택형 조우는 뺀다. 행성 지표 탐험 / 폐우주선 탐험은 **다음 업데이트**.

## 근거 데이터 (2026-11-08, 서버 조회)

- 설치(지갑) 169, 출석 보상 한 번도 안 받음 118(70%) — `starset_wallets.login_streak = 0`
- 플레이 젬을 번 44명 중 32명이 하루만 플레이, 3일 넘게 플레이 2명 — `starset_earn_days`
- 순위표 참여 4, 실결제 0(샌드박스 4) — `starset_players`, `starset_purchases`
- 지갑은 앱 실행만으로 생기고 테스트 기기가 섞여 있다. 업적은 수동 수령이라 처치 여부의 근거가 아니다.
- 건물 표시: 식민지 레벨 = 같은 돔 n개(`lib/ui/world_painter.dart:497`), 건물 = 이모지 글자 라벨뿐(`:580`).

## 라운드

| 라운드 | 작업자 | 내용 | 상태 |
|---|---|---|---|
| 001 | Claude 워커 | 이탈 지점 측정 (`starset_events`, 클라이언트 이벤트 송신, 개인정보처리방침) | GO (Claude 재검증: analyze 0, telemetry_test 20/20, SQL 검토). 실서버 배포·`events_live.sh`는 출시 전 사용자 확인 후 |
| 002 | Claude 워커(코드) + Claude(그림, Gemini) | 식민지 건물 외형 (건물 6종 표면 구조물, 동작 애니메이션, 레벨별 외형) | GO — 스프라이트 21/21, 실기기에서 화성 Lv.5 건물 6종 확인 |
| 003 | Claude 워커 A | 첫 5분 (3분 안 ★3 승무원, 미니 두목, 항상 보이는 다음 목표) + 세로 배지 글자 크기 | GO (통합 검사·실기기 확인) |
| 004 | Claude 워커 A (003 다음) | 다시 올 이유 (7일 출석 달력, 내일 보상 미리보기, 승무원 원정) | GO (통합 검사·실기기 확인, 원정 화면은 렌더 검사만) |
| 005 | Claude 워커 B | 균열 런 모드 (3~5분 로그라이트, 오늘의 시드, 주간 균열 순위) | CLAUDE_IMPLEMENTED — 봇 평균 3.24분, rift 테스트 66/66, 증거 그림 검토(ko 소개·카드·HUD·결과 정상), SQL 검토(starset_forget는 기존 동작 + 균열 삭제). 실서버 배포 완료(2026-11-08, 사용자가 `deploy_rift.sh` 직접 실행): `rift_live.sh` 20/20, 기존 `live.sh` 17/17, 테스트 행 0 |
| 006 | Claude 워커 C | 도감 (적·행성·항성계·승무원 수집, 마일스톤 보상) | GO (통합 검사·실기기 확인) |

001과 002는 수정 파일이 겹치지 않아 동시에 돌린다. 003부터는 001의 이벤트를 써서 효과를 잰다.
서버 배포(마이그레이션 적용), 실기기 확인, 커밋은 Claude(오케스트레이터)가 사용자 확인 후 한다.

## 작업자 변경 (2026-11-08)

Codex 사용 한도 소진(11/14 07:10 재개) → 사용자 결정: Claude 워커로 진행, 건물 그림은 Gemini 웹으로 생성.
지시서는 `TASK_00N_CODEX.md`를 그대로 쓰고, 결과는 `RESULT_00N_CLAUDE.md`로 남긴다.
TASK 002의 '스프라이트 생성'은 오케스트레이터(Claude)가 Gemini로 따로 한다. 워커는 `bld_*` 스프라이트를 읽는 코드와 도형 대체 그리기까지 만든다.

## 서버 (2026-11-08 사용자 지시로 즉시 배포)

- `20261108000000_starset_events.sql` 배포, `events_live.sh` 13/13, pg_cron 삭제 작업 등록.
- `20261108010000_starset_events_v2.sql`(003~006 이벤트 8종 추가, 허용 26종) 배포.
- 동시 번역 추가용 `tool/arb_add.py`(파일 잠금) 추가. 공통 규칙 `COMMON_RULES.md`.

## 오케스트레이터 아이콘 작업 (2026-11-08, 사용자 지시)

- `assets/icons/menu_rift.png`(Gemini, 보라 소용돌이 균열 + 금별): `riftMenuIcon` 상수(`lib/ui/rift_screen.dart`), 타이틀 균열 버튼(열렸을 때) + 일시정지 메뉴 칸(`cmb_boost` 대신). 렌더로 두 곳 표시 확인.
- `assets/icons/menu_codex.png`, `assets/sprites/portrait_captain_codex.png`: RESULT_006 추가 절 참고.

## 통합 검토 (2026-11-08, Claude)

- 전체: `dart analyze lib test` 0, `flutter test --no-pub` 639/639.
- `balance_test` 뒤 항성계(3~6) "크레딧 팩 20%↑" 실패: 작업 전 커밋(worktree)에서는 통과(무료 8.18일·팩 6.39일) → 이번 작업으로 무료가 빨라짐(7.22일, 팩 5.98일, 17%). 워커들은 서로 자기 탓이 아니라 했지만 합쳐진 효과. 기준 완화 없이 `GameWorld.creditPackBase` 12000 → 13500(무료 7.04일·팩 5.45일, 22.6%)으로 원래 차이 회복.
- 도감 토스트가 세로 HUD '다음 목표' 칩을 덮음(워커 A 보고) → 고정 위치 대신 **대사 칸**에 나오고 대사가 있으면 끝난 뒤 표시(`CodexHud`는 순서만, `GameScreen._message()`가 그림). 게이트 `test/codex_toast_layout_test.dart`(ko/en/de × 세로 2종·가로, 글자 1.3, HUD 요소와 겹침 0) 추가.
- 상점 '무료' 탭의 옛 7칸 젬 줄 → `TomorrowCard`.
- 실기기(SM-N960N, 디버그 빌드, 가로 설정): 타이틀 7일 달력·받기·내일 카드, 균열 런/도감 아이콘, ★3 승무원 공개 연출, 미니 두목 등장·격파, 다음 목표 칩, 화성 Lv.5 건물 6종(Gemini 그림), 일시정지 메뉴(내일 카드·도감·균열 런), 도감 화면, 균열 런(소개→전투→카드 선택→포기→결과), 통계 대기열 기기 저장. 테스트 저장을 넣었다가 원래 저장으로 바이트 단위 복구.
- 실기기 미확인: 승무원 원정 패널, 출석 전용 스킨 색, 알림, 세로 방향 화면.

## 미결

- gameplay-depth TASK 007(세로 HUD 겹침)은 Codex 결과가 나와 있으나 미커밋 상태(`lib/ui/game_screen.dart`, `test/landscape_layout_test.dart`). 이 initiative 작업은 그 변경을 보존한다.
- 전체 `flutter test`의 실패 6건 = `test/landscape_layout_test.dart:272` 세로 항성계 배지 글자 크기(4.0~6.5 < 10, ko/en/de). 이 세션 시작 전부터 있던 미커밋 테스트 변경(SHA f5b213c…, TASK 007 검증 시점 c5cd8f5…와 다름). gameplay-depth TASK 007 후속으로 처리.
- 001 남은 일: 공개 개인정보처리방침 10개 언어(`~/VSCodeProject/mkideabox/star_settlers/source/content.json`) 반영·시행일, `TelemetryConfig.appVersion`을 pubspec과 같이 올리기, pg_cron 가능 여부 확인.
- ~~Play Console 데이터 보안 양식~~ 확인 완료(2026-11-08): '앱 상호작용'·'기기 또는 기타 ID' 모두 이미 수집·필수·애널리틱스 목적으로 신고됨 → 변경 불필요. App Store 개인정보 라벨도 '제품 상호 작용'·'기기 ID' 분석 목적, 사용자와 연결 안 됨으로 이미 게시 → 변경 불필요.
- 개인정보처리방침 10개 언어 갱신·게시 완료(mkideabox `16d9ac8`, 시행일 2026-11-08, '게임 개선 통계' 절 + 균열 순위 + 삭제 안내). 저장소 `docs/PRIVACY_POLICY.md`는 render.py --md-out으로 재생성.
