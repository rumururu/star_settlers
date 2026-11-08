---
slug: gameplay-depth-result-007
status: complete
---

# RESULT 007 — 세로 HUD 겹침

## 원인

- 세로 HUD의 선장 카드와 항성계 정보가 각각 좌우에 독립적으로 고정돼 서로의 폭을 예약하지 않았다. 상황 버튼의 고정된 하단 오프셋도 순항·전투 묶음의 실제 높이를 고려하지 않았다.
- 수정 전 원본 게이트에서 ko/en/de × 390×844·360×740의 6개 조합이 실패했다. 가로 폰·iPad의 12개 조합은 통과했다.
- 360×740 한국어 렌더 기준: 선장 카드 오른쪽 `212`와 정보 영역 왼쪽 `190`이 겹쳤다. 상황 버튼 아래쪽 `540`이 순항 위쪽 `536`, 전투 묶음 위쪽 `524`를 침범했다.

## 수정

제품 코드는 `lib/ui/game_screen.dart`만 수정했다.

- `lib/ui/game_screen.dart:789`, `:872`: 기존 720dp 분기에서 세로 폰을 `_hudPortrait`로 배치한다. `SafeArea`, `Row`/`Column`, `Expanded`로 상단 정보 폭과 하단 조작 높이를 예약하고 `Space` 토큰으로 간격을 둔다. 상황 버튼은 조작 행 위에, 대사는 상단 정보 아래의 남은 공간에 배치하며 긴 대사는 스크롤할 수 있다. 조이스틱·발사는 각각 좌하단·우하단을 유지한다.
- `lib/ui/game_screen.dart:967`: 자원 숫자의 표시 폭을 유지하고 초상화가 남은 폭에 맞춰 축소되도록 했다. 글자 배율 1.3에서도 숫자 행이 넘치지 않는다.
- `lib/ui/game_screen.dart:1059`: 식민지 방어막 상태 문구를 `Flexible` 안에서 줄바꿈한다. 좁아진 선장 카드에서 러시아어 상태 문구가 21px 넘치는 문제도 해결했다.
- `lib/ui/game_screen.dart:1234`, `:1839`: 항성계 배지를 남은 행 폭에 제한하고 배지·메뉴의 터치 영역을 최소 48dp로 확보한다.
- `lib/ui/game_screen.dart:1508`: 순항 문구가 배정된 폭에서 줄바꿈하도록 했다.
- `lib/ui/game_screen.dart:1552`, `:1629`: 세로 전투 묶음을 행·열로 구성해 불필요한 폭을 줄이고 자동 사격 토글과 스킬을 분리했다. 기본 배율에서 묶음은 190×200 → 160×216dp이며, 자동 사격의 최소 터치 크기는 `Tap.min`(48dp)이다. 발사 92dp·스킬 56dp 크기는 유지한다.

360×740 한국어 수정 후 실측: 선장 오른쪽 `209.6` / 정보 왼쪽 `217.6`으로 8dp 간격, 상황 버튼 아래쪽 `500` / 전투 위쪽 `508`으로 8dp 간격이다. 순항 위쪽은 `540`이다. ko/en/de의 세로 두 크기 모두 `overlaps: []`, `outsideSafeArea: []`를 확인했다.

## 검증 결과

| 검사 | 결과 |
|---|---|
| 수정 전 `flutter test --no-pub test/landscape_layout_test.dart --plain-name '게임 HUD'` | 세로 6개 실패, 가로·iPad 12개 통과 |
| 수정 후 HUD 게이트 및 최종 전체 테스트 내 동일 검사 | 세로·가로·iPad 18개 통과 |
| `flutter test --no-pub test/invasion_test.dart --plain-name 'HUD 배너'` | 10개 언어 모두 통과; 글자 배율 1.3, 360×740·800×360, calm·경보·진행·승리·퇴각 포함 |
| `dart analyze lib test` | `No issues found!` |
| `flutter test --no-pub` | `02:16 +490: All tests passed!`; 패널·메뉴 검사 포함 |
| 수정 후 임시 렌더 하네스 | 6개 통과; 겹침·안전 영역, 순항·자동 사격·메뉴·발사의 48dp 이상 크기, 순항·자동 사격 탭에 따른 상태 변경 확인 |
| `git diff --check` | 통과 |

게이트, `hudRects`/`overlaps` 및 다른 기존 테스트는 수정하지 않았다. 시작할 때 이미 변경돼 있던 `test/landscape_layout_test.dart`를 보존했다. 작업 전후 SHA-1은 동일하다: `c5cd8f51837d5003f5113ded191991e342836e49`.

## PNG와 로그

모든 증거의 저장 디렉터리:

`/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/8c303f23-a6f8-467a-a28b-99d3781e7ca6/scratchpad/hud_portrait/`

| 언어·크기 | 수정 전 PNG | 수정 후 PNG |
|---|---|---|
| ko 390×844 | `before_ko_390x844.png` | `after_ko_390x844.png` |
| ko 360×740 | `before_ko_360x740.png` | `after_ko_360x740.png` |
| en 390×844 | `before_en_390x844.png` | `after_en_390x844.png` |
| en 360×740 | `before_en_360x740.png` | `after_en_360x740.png` |
| de 390×844 | `before_de_390x844.png` | `after_de_390x844.png` |
| de 360×740 | `before_de_360x740.png` | `after_de_360x740.png` |

각 PNG와 같은 이름의 `.txt`에 HUD 사각형과 겹침·안전 영역 결과를 저장했다. 실제 `GameScreen`을 원본 게이트의 `busyWorld`, 안전 영역, Jua 폰트 및 이미지 에셋으로 렌더했다. 한국어 360×740, 독일어 390×844의 수정 전후 이미지를 직접 열어 비교했다.

로그: `before_gate.log`, `after_gate.log`, `invasion.log`, `analyze.log`, `full_test.log`, `before_render.log`, `after_render.log`. `after_gate.log`는 중간 수정 단계의 검사이며, 최종 코드의 전체 게이트 통과 근거는 `full_test.log`다. 진단용 `invasion_debug.log`에는 수정 과정에서 확인한 러시아어 넘침 기록이 남아 있다. 임시 렌더·진단 테스트 파일 2개는 삭제했다.

기기·에뮬레이터는 실행하지 않았으며 위 결과는 정적 분석 및 헤드리스 위젯·렌더 검증이다. 캡처의 일부 아이콘·문자는 테스트 폰트 환경에서 사각형 글리프로 표시되며 수정 전에도 동일하다. 실기기의 폰트 대체·가독성은 검증하지 않았다. 커밋이나 배포는 하지 않았다.
