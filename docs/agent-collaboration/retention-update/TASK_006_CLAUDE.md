---
slug: retention-update-task-006
status: progress
---

# TASK 006 — 도감 (워커 C)

공통 규칙: `COMMON_RULES.md`.

## 목표
모으는 맛: 만난 적·행성·항성계·승무원이 채워지는 도감과 수집 보상.

## 설계
- 진입: 타이틀과 일시정지 메뉴의 '도감' 버튼. 새로 채워진 항목이 있으면 빨간 점.
- 탭 4개:
  1. **적**: 해적 종류 전부(`PirateKind`), 항성계 두목 원형, 섹터 두목, 우주 해파리 등. 처치 수 표시. 스프라이트(`assets/sprites/pirate_*.png` 등) 사용.
  2. **행성**: 행성 종류 5가지 + 정착한 행성 이름 목록(가장 높은 식민지 레벨).
  3. **항성계**: 실제 항성계 목록(`lib/game/star_catalog.dart`) 순서대로, 도달한 곳만 이름·특성(`system_traits.dart`) 표시, 아직은 '???'.
  4. **승무원**: 직업 6 × 희귀도 ★1~3 = 18칸, 얻어 본 조합 채움.
- 미발견은 실루엣(어둡게) + '???'. 발견 시 처음 한 번 HUD 토스트 "도감에 새 항목: 저격선".
- 기록은 **Profile 수준**(새 게임·은하 명예 후에도 유지). 기존 저장 하위 호환. 발견 기록 지점은 기존 처치/정착/도착/승무원 획득 코드에 한 줄 훅(`world.dart`의 기존 `GameTelemetry.emit` 근처가 참고 위치).
- **수집 보상**: 탭별 25/50/75/100% 마일스톤 → 크레딧·광석·승무원, 탭 100%는 고유 외형(선장 의상 또는 함선 스킨 색 조합 1개, 기존 cosmetics 구조 재사용). 젬은 쓰지 않는다(필요하면 `earnGems('play', …)` 소량만). 수령 버튼 + 연출.
- `codex_open` emit.

## 수용 기준
- 단위: 발견 기록(중복 없음, 환생 후 유지), 퍼센트 계산, 마일스톤 1회 수령, 저장/복원(구버전 저장 로드 시 빈 도감).
- 렌더 게이트: 도감 4탭 ko/en/de, 세로·가로, 글자 1.3 넘침 0, 미발견/발견 섞인 상태 증거 PNG.

## 수정 가능
새 파일(`lib/game/codex.dart`, `lib/ui/codex_screen.dart`), `lib/game/profile.dart`, `lib/game/world.dart`(훅 한 줄씩), `lib/game/cosmetics.dart`(외형 1개), `lib/main.dart`(진입 버튼 1곳), `lib/ui/pause_menu.dart`, `lib/ui/game_screen.dart`(토스트 최소), 번역(도구로), `test/`.
