---
slug: gameplay-depth-result-006
status: complete
---

# RESULT 006 — 러시아어 가로 화면 기지 행동 버튼 넘침

## 원인과 수정

- 호출 위치: `lib/ui/game_screen.dart:1243`의 `keyHint('${st.name} (E)')`.
- 배치 위치: `lib/ui/game_screen.dart:741`의 가로 HUD `Wrap`. 가운데 영역에는 이미 유한한 폭이 배정돼 있다.
- 실제 원인: `lib/ui/common.dart:227`의 `_actionBtn` 내부 `Row`에서 라벨(`:233`)이 비유연 자식이었다. 아이콘·간격·라벨이 필요한 폭을 그대로 요구해 러시아어, 800×360, 글자 배율 1.3에서 오른쪽으로 38px 넘쳤다. 침공 없는 calm 장면의 원본 게이트로 재현했다.
- `lib/ui/common.dart:234`에서 라벨만 `Flexible`로 감쌌다. 아이콘·비용을 배치하고 남은 폭에서 라벨이 줄바꿈한다. 짧은 라벨은 기존 크기를 유지한다. 기존 `actionBtn`, `Ts.label`, `Space`, `Tap.min`(48dp), 색상과 터치 동작을 유지했다.
- 제품 코드 변경은 `lib/ui/common.dart` 한 곳뿐이다. `game_screen.dart`의 기존 작업, 번역, 게이트 및 다른 테스트는 수정하지 않았다.

## 필수 검증

| 명령 | 결과 |
|---|---|
| `flutter test --no-pub test/invasion_test.dart --plain-name '배너 ru: 경보·진행·결과, 넘침·겹침 없음'` — 수정 전 | 실패: `ru calm Size(800.0, 360.0): A RenderFlex overflowed by 38 pixels on the right.` |
| 같은 명령 — 수정 후 | 1개 통과 |
| `dart analyze lib test` | `No issues found!` |
| `flutter test --no-pub` | `02:35 +481: All tests passed!` |
| `git diff --check -- lib/ui/common.dart` | 통과 |

전체 테스트에는 원본 침공 게이트의 10개 언어, 360×740 / 800×360, 글자 배율 1.3, calm·경보·진행·승리·퇴각 검사와 기존 가로 HUD/패널 회귀 검사가 포함된다. 기대값 완화나 skip은 하지 않았다.

로그:

- `/tmp/star_settlers_task006_before.log`
- `/tmp/star_settlers_task006_gate.log`
- `/tmp/star_settlers_task006_analyze.log`
- `/tmp/star_settlers_task006_full.log`

## 추가 렌더·기하 검증과 한계

저장소 테스트를 변경하지 않고 `/tmp`의 보조 하네스에서 실제 `GameScreen`을 렌더했다. 한국어·영어·러시아어, 두 화면 크기, 글자 배율 1.3, 다섯 장면의 버튼 크기·화면 경계·히트 테스트·주변 HUD 사각형을 검사했다.

- 러시아어 가로 버튼은 `Rect.fromLTRB(316.9, 284.0, 548.0, 352.0)`, 약 **231.1×68dp**다. 라벨이 두 줄로 표시되고, 조이스틱·순항·전투 영역·미니맵·선장/임무 카드·대사와 겹치지 않는다. 확인한 세 언어 모두 가로 장면의 겹침은 없었다.
- 러시아어 가로 calm/경보, 한국어 가로 경보, 영어 가로 calm, 러시아어 세로 calm PNG를 직접 확인했다. 대표 이미지: `/tmp/star_settlers_task006_ru_800x360_calm.png`, `/tmp/star_settlers_task006_ru_800x360_warning.png`.
- **보조 검사는 세로 화면의 기존 겹침 때문에 세 언어 모두 실패했다.** 360×740에서 행동 버튼의 아래쪽(y=540)이 순항 토글 위쪽(y=536) 및 전투 묶음 사각형 위쪽(y=524)과 겹친다. 전투 묶음 상단에는 자동 사격 토글이 있다. 이 현상까지 해결했다고 주장하지 않는다.
- 수정 전 `common.dart`를 넣은 별도 `/tmp` 복사본과 비교했다. 세 언어의 세로 버튼 사각형은 다섯 장면 모두 동일하며, calm/경보 **PNG 6개는 파일 바이트까지 동일**했다. 따라서 이번 수정으로 세로 배치가 나빠지지는 않았다. 보조 검사 로그: `/tmp/star_settlers_task006_render.log`, `/tmp/star_settlers_task006_render_before.log`. 비교용 임시 환경은 초기 패키지 경로/그래프 설정 오류를 해결한 뒤 재실행했다.
- 테스트 폰트에는 키릴 문자 일부가 없어 러시아어 캡처가 사각형 글리프로 표시된다. 러시아어 실제 기기 폰트의 가독성은 검증하지 않았다.
- 기기·에뮬레이터 실행 및 커밋은 하지 않았다. 위 결과는 정적 분석과 헤드리스 위젯/렌더 검증이며 실기기 검증은 아니다.
