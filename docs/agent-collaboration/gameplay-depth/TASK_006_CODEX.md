---
slug: gameplay-depth-task-006
status: active
---

# TASK 006 — 러시아어 가로 화면 기지 행동 버튼 넘침 (Codex)

## 문제
러시아어(ru), 화면 800×360, 글자 배율 1.3에서 기지 옆 행동 버튼 영역이 `A RenderFlex overflowed by 38 pixels on the right`.
침공과 무관하게 원래 있던 넘침이다. 행동 버튼은 `lib/ui/game_screen.dart`의 `keyHint('${st.name} (E)')` 등 `actionBtn` 목록(약 1160~1250줄)과 그것을 배치하는 Row/Wrap.

## 게이트 (Claude가 작성, 수정 금지)
`test/invasion_test.dart`의 "배너 ru: 경보·진행·결과, 넘침·겹침 없음" — 침공 없는 같은 장면(calm)에서도 넘침이 있으면 실패하도록 바꿔 두었다. 현재 RED:
`'ru calm Size(800.0, 360.0): A RenderFlex overflowed by 38 pixels on the right.'`

## 요구
- 넘침의 정확한 위치를 찾아 **UI를 고친다**(긴 라벨 줄바꿈/말줄임, 버튼 최대 폭 제한, Flexible/FittedBox 등). 기존 디자인 토큰·`actionBtn` 패턴 유지, 터치 타겟 48dp 이상 유지.
- HUD 예약 영역(조이스틱·발사 버튼·미니맵·임무 카드) 침범 금지. 다른 언어·세로 화면 표시가 나빠지지 않게.
- 테스트 기대 완화·skip 금지. 게이트 파일 수정 금지.

## 검증 (반드시)
```bash
cd /Volumes/home_extension/AndroidStudioProjects/star_settlers
dart analyze lib test
flutter test --no-pub
```
전체 통과.

## 수정 가능
`lib/ui/game_screen.dart`, `lib/ui/common.dart`(필요 시 최소), 필요하면 ru ARB 문구(`lib/l10n/app_ru.arb` + `flutter gen-l10n`) — 단 문구를 줄이는 것보다 레이아웃 수정을 우선.

## 금지
git commit/checkout/reset/revert/stash, 기기·에뮬레이터 실행, 위 목록 밖 파일.

## 결과
`docs/agent-collaboration/gameplay-depth/RESULT_006_CODEX.md`: 원인 위치(file:line), 수정 내용, 검증 결과.
