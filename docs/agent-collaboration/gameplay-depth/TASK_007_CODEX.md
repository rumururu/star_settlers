---
slug: gameplay-depth-task-007
status: active
---

# TASK 007 — 세로 HUD 겹침 (Codex)

## 문제
세로 화면 HUD에서 위젯 사각형이 겹친다. 출시본(1.0.7 이전부터)에 있던 문제다.
- `action0`(기지/행성 앞 상황 버튼, `hud-actions` Wrap의 버튼) × `hud-cruise`(순항 토글), × `hud-combat`(오른쪽 아래 전투 묶음)
- `hud-captain`(좌상단 선장 카드) × `hud-info`(우상단 항성계 정보 배지)
화면: 390×844(아이폰급), 360×740(갤럭시 S8·S9급). ko/en/de 모두.

## 게이트 (Claude가 작성, 수정 금지)
`test/landscape_layout_test.dart`
- 화면 목록에 `portrait android 360x740` 추가
- "게임 HUD @ …" 테스트의 겹침·안전 영역 검사(`hudRects` → `overlaps`, `outsideSafeArea`)를 가로뿐 아니라 **세로에도** 적용
현재 RED (ko/en/de × 세로 2종): 위 세 쌍. 가로·iPad는 GREEN이어야 하고 계속 GREEN이어야 한다.

## 요구
- **레이아웃을 고쳐** 사각형이 실제로 겹치지 않게 한다 (`lib/ui/game_screen.dart` 세로 HUD 약 800~870줄: `hud-captain`, `hud-info`, `hud-joystick`, `hud-cruise`, `hud-combat`, `hud-actions` 배치).
  예: 상황 버튼 줄을 순항·전투 묶음보다 위로 올리거나 폭을 그 사이로 제한, 선장 카드/정보 배지 최대 폭 조정.
  전투 묶음의 사각형이 보이는 버튼보다 크게 잡혀 있다면(투명 여백) 위젯 크기를 실제 버튼에 맞게 줄이는 것도 정당한 수정이다.
- `~/.claude/GAME_UI_ARCHITECTURE.md` 기준: 절대좌표 땜질 대신 기존 디자인 토큰(Space, Tap, IconSz)·flex/anchor 사용, 터치 타겟 48dp 이상, thumb zone(조이스틱·발사) 유지.
- 게이트·다른 테스트의 기대 완화·skip 금지. `hudRects`/`overlaps` 정의 수정 금지.
- 다른 화면(가로, iPad, 패널, 메뉴)과 10개 언어 위젯 테스트(`test/invasion_test.dart` 등)가 계속 통과해야 한다.

## 검증 (반드시)
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
dart analyze lib test
flutter test --no-pub
```
전체 통과. 수정 전/후 세로 2종 HUD를 렌더 하네스(임시 테스트로 PNG 저장 후 임시 파일 삭제)로 그려
`/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/8c303f23-a6f8-467a-a28b-99d3781e7ca6/scratchpad/hud_portrait/`에 저장.

## 수정 가능
`lib/ui/game_screen.dart`, `lib/ui/common.dart`(최소), HUD 관련 기존 위젯 파일.

## 금지
git commit/checkout/reset/revert/stash, 기기·에뮬레이터 실행, 위 목록 밖 파일, 테스트 파일 수정.

## 결과
`docs/agent-collaboration/gameplay-depth/RESULT_007_CODEX.md`: 원인, 수정(file:line), 검증 결과, PNG 경로.
