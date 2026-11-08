---
slug: retention-update-task-005
status: progress
---

# TASK 005 — 균열 런 모드 (워커 B)

공통 규칙: `COMMON_RULES.md`.

## 목표
3~5분짜리 짧은 로그라이트 판. 반복 플레이 동기 + 짧은 세션.

## 설계
- 타이틀(그리고 일시정지 메뉴)에서 '균열 런' 진입. 해금: 스토리 '해적 3 처치' 단계 완료 후(그 전엔 자물쇠 + 해금 조건 표시).
- **기존 전투 재사용**: 새 엔진 금지. `GameWorld`/`WorldPainter`/HUD 조작을 재사용하되, 식민지·정거장·경제 없는 아레나 모드(예: `GameWorld`의 모드 플래그 또는 얇은 래퍼). 메인 게임 저장과 완전히 분리(런 상태는 저장하지 않음, 런 도중 종료 = 포기).
- **공정성**: 함선 능력치는 런 전용 기본값(메인 게임 강화 무시, 외형/스킨만 반영). 업그레이드는 런 카드로만.
- **파도**: 파도 10개 + 10파 균열 두목. 파도마다 적 종류·수 증가(기존 해적 종류 재사용). 파도 클리어마다 **카드 3장 중 1장 선택**(예: 피해+, 연사+, 다중 사격, 관통, 유도 미사일, 실드 재생, 드론, 자석, 치명타, 회전 칼날 등 12종 이상, 중첩 가능, 레어도). 카드 효과는 순수 Dart로 단위 테스트.
- **오늘의 균열**: 날짜(UTC) 시드로 파도 구성·카드 풀이 모두에게 같다(순위 공정).
- **보상**: 결과 화면(도달 파도, 점수, 개인 최고, 받은 보상). 메인 게임에 크레딧·광석(현재 항성계 배율, 하루 처음 3판만 전액) + 승무원 경험치. 젬은 `earnGems('play', …)` 소량만(10파 클리어 등).
- **주간 균열 순위**: 기존 순위표(`lib/services/leaderboard.dart`, `lib/ui/leaderboard_screen.dart`, 참여 동의·별명 체계 그대로)에 '균열' 탭 추가. 서버는 새 마이그레이션 **파일만** 작성: `supabase/migrations/20261108020000_starset_rift.sql` — `starset_rift_scores(install_id, week, score, waves, submitted_at)`, `starset_submit_rift(...)`, `starset_rift_board(...)`, 기존 starset_leaderboard.sql과 같은 잠금 패턴(RLS, security definer, 요청 제한, 이번 주·지난주만). **점수 상한 근거**를 주석에 계산해 적는다. `starset_forget`이 균열 점수도 지우도록 `create or replace`. 실서버 검사 스크립트 `supabase/tests/rift_live.sh`. 배포는 오케스트레이터.
- `rift_start`, `rift_end`(value=도달 파도) emit.
- 목표 길이: 보통 실력 3~5분. 헤드리스 봇(기존 `test/support/progression_bot.dart` / `tool/fight_sim_test.dart` 방식)으로 파도별 소요 시간·도달 파도 분포를 재서 결과에 표로.

## 수용 기준
- 단위: 시드 결정성(같은 날 같은 구성), 카드 효과·중첩, 점수 계산, 보상 하루 상한, 메인 저장 불변(런 전후 메인 world/profile JSON 비교 — 보상 외 변화 0).
- 위젯/렌더 게이트: 카드 선택 화면·결과 화면·순위 '균열' 탭 ko/en/de, 세로·가로, 글자 1.3 넘침 0. 런 HUD는 기존 HUD 겹침 게이트 기준 통과.
- 봇: 기본 카드 선택 전략으로 평균 런 3~5분.

## 수정 가능
새 파일(`lib/game/rift*.dart`, `lib/ui/rift_*.dart`), `lib/game/world.dart`(모드 분기 최소), `lib/ui/game_screen.dart`(모드 분기 최소), `lib/main.dart`(진입 버튼 1곳), `lib/ui/pause_menu.dart`, `lib/services/leaderboard.dart`, `lib/ui/leaderboard_screen.dart`, `supabase/migrations/`(새 파일), `supabase/tests/`(새 파일), 번역(도구로), `test/`.
