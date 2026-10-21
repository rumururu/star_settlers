---
slug: gameplay-depth-rework-001
status: active
---

# REWORK 001 — TASK 001 재작업 (Codex)

Claude가 샌드박스 밖에서 `flutter test --no-pub`를 실행했다: **377 통과, 2 실패**. `dart analyze` 깨끗, 밸런스 테스트 전부 통과
(S1 19.1/20.4/21.2분, S3~S6 무료 8.61일, 정체 세션 0). 이번 세션은 로컬 소켓이 허용되므로 직접 테스트를 실행할 수 있다.

## 실패 1 — 실제 UI 결함
`test/level_cap_test.dart` "colony and ship buttons distinguish progress, legacy locks and MAX"
- `Size(360.0, 740.0) / 4 / StationPanel`에서 `A RenderFlex overflowed by 9.8 pixels on the right`
  (`lib/ui/game_icons.dart:27`의 Row, 부모는 StationPanel 강화 행의 Wrap, 폭 206).
- 잠금 문구가 들어간 버튼/행이 좁은 폰 폭에 안 들어간다. **테스트를 완화하지 말고 UI를 고쳐라**
  (줄바꿈 허용, 문구를 버튼 밖 캡션 줄로 이동, FittedBox 등. 터치 타겟 48dp 유지).

## 실패 2
`test/colonies_panel_test.dart` "colonies panel ru: both systems listed, fits phone and landscape"
- `Found 0 widgets with text "Вы здесь"` — 기존(TASK 001 이전)에는 통과하던 테스트다. 이번 변경(잠금 행 높이 증가 등)으로
  현재 항성계 헤더가 화면 밖으로 밀리거나 렌더링되지 않는 원인을 찾아 고친다. 테스트 기대를 바꾸지 않는다.

## 완료 조건
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
dart analyze lib test
flutter test --no-pub
```
전체 통과. 결과는 `docs/agent-collaboration/gameplay-depth/RESULT_001_REWORK_CODEX.md` (변경 파일, 원인, 수정, 테스트 결과).
금지: 테스트 기대 완화/skip, git commit/checkout/reset/revert/stash, 기기 실행, TASK 001 범위 밖 파일 수정.
