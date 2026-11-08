---
slug: retention-update-result-006
status: progress
---

# RESULT 006 — 도감 (워커 C)

## 변경 파일

새 파일
- `lib/game/codex.dart`: 도감 상태와 규칙. 탭 4개, 항목 id, 기록, 퍼센트, 마일스톤, 보상 대기열, 저장(`toJson`/`load`)
- `lib/game/codex_world.dart`: 도감과 월드 연결. `syncCodexFromWorld`(기존 진행을 토스트 없이 채움), `deliverCodexRewards`(받은 보상을 월드에 넣음)
- `lib/ui/codex_screen.dart`: `CodexScreen`(4탭 화면), `CodexTitleButton`(타이틀 버튼), `CodexHud`(게임 화면 토스트·보상 지급 층)
- `test/codex_test.dart`: 단위 테스트 13개 + 화면 테스트 11개 (렌더 게이트 포함)

공유 파일 (모두 한 줄 훅, 편집 직전에 다시 읽음)
- `lib/game/profile.dart`: import 1줄, 필드 `late final Codex codex = Codex(() => dirty = true);`, toJson `'codex'` 1줄, fromJson `p.codex.load(j['codex']);` 1줄
- `lib/game/world.dart`: 훅 5줄
  - `warp()`의 `profile.maxStat('sector', …)` 다음: `recordSystem(to)`
  - `upgradePlanet()`의 `p.colonyLevel++` 다음: `recordColony(sector, planets.indexOf(p), planets.length, …)`
  - `upgradeRemotePlanet()`의 `p.colonyLevel++` 다음: `recordColony(sector, index, save.colonyLevels.length, …)`
  - `_addCrew()`의 `roster.add(c)` 다음: `recordCrew(c.role, c.rarity)`
  - `_onKilled()` 첫 줄: `recordKill(e)`
- `lib/game/cosmetics.dart`: 도감 의상 `codexOutfit` 1개와 이름 case 1줄. `outfitById`가 이 의상도 찾는다
- `lib/main.dart`: import 1줄. 설정 버튼을 `Wrap[CodexTitleButton, 설정]`으로 감쌈(설정 버튼 내용은 그대로)
- `lib/ui/game_screen.dart`: import 1줄, Stack에 `CodexHud` 1줄, 일시정지 메뉴에 `MenuTile(도감)` 1줄. `pause_menu.dart`는 고치지 않음
- 번역: `tool/arb_add.py`로 `codex_` 키 19개, 10개 언어 추가 후 `flutter gen-l10n` 실행. ARB 파일은 직접 고치지 않음

## 설계 결정

- **기록은 Profile 단위다.** 새 게임이나 은하 명예 뒤에도 남는다. 예전 저장에 `codex`가 없으면 빈 도감으로 연다.
- **탭과 전체 칸 수**
  - 적 21: 해적 12종, 우주 해파리, 해적 두목(원형 없음), 침공 지휘함, 항성계 두목 원형 6. 처치 수를 함께 센다. 아직 못 만난 후반 적과 원형은 "항성계 N부터"라는 힌트를 띄운다.
  - 행성 5: 정착한 행성의 종류로 채운다. 아래에 정착한 행성 목록(이름·항성계·최고 레벨)을 따로 둔다. 이름은 `"항성계:번호:행성수"`로 저장하고, 보여 줄 때 `planetIdentity`로 그때 언어에 맞춰 만든다.
  - 항성계 27: 태양계와 카탈로그 26곳. 도달한 곳은 이름과 `u_systemTrait` 특성 설명을 보여 주고, 다음 갈 곳 한 칸에만 힌트를 띄운다. 27번째부터의 미지 섹터는 칸에 넣지 않는다.
  - 승무원 18: 직업 6 × ★1~3. ★4 전설은 젬 전용이라 칸이 없다.
- **미발견 표시**: 그림을 어두운 실루엣(`ColorFilter srcIn`)으로 바꾸고 이름 자리에 `???`를 쓴다.
- **새 항목**
  - 처음 발견하면 `toasts` 대기열에 넣는다. `CodexHud`가 화면 중앙 위(`Alignment(0,-0.45)`, 월드 영역)에 2.6초 동안 하나씩 띄운다.
  - 토스트는 `IgnorePointer`라 터치를 막지 않는다. 문구는 "도감에 새 항목: 플레어 포격함".
  - 새 항목은 `fresh`에도 넣어 빨간 점을 띄운다. 빨간 점은 타이틀 버튼(`Badge`), 일시정지 메뉴 칸(숫자 = 새 항목 + 받을 수 있는 보상), 탭, 칸 테두리에 나온다. 탭을 열면 지운다.
- **도감 이전부터 하던 플레이어**: 게임 화면이 열릴 때 `syncCodexFromWorld`가 도달 항성계(`maxSector`), 현재·원격 정착지, 보유 승무원을 토스트 없이 채운다. 적 처치는 종류별 기록이 없어서 채울 수 없다. 앞으로 잡는 적부터 센다.
- **마일스톤 보상** (탭마다 같음, 젬 없음)
  - 25%: 💰2,000
  - 50%: 💰3,000 + 💎1,500
  - 75%: 💰5,000 + 💎3,000 + ★2 승무원
  - 100%: ★3 승무원 + 도감 전용 선장 의상 "별지도 탐험가"
  - 의상은 계정에 바로 들어간다. 크레딧·광석·승무원은 `pending*`에 쌓았다가 월드가 있으면 바로 넣고, 타이틀에서 받았으면 다음 게임 화면이 열릴 때 넣는다(안내 문구 있음). 승무원 정원이 차 있으면 자리가 날 때까지 기다린다.
  - 수령 연출: 효과음 + 보상 대화상자. 의상이면 초상화와 "장착" 버튼을 함께 띄운다.
- **도감 의상은 상점 목록(`captainOutfits`)에 넣지 않았다.** 넣으면 가격 0인 의상이 상점에서 "0젬 구매"로 풀린다. 그래서 `outfitById`만 찾게 하고, 장착은 도감 화면에서 한다.
- **화면 레이아웃**
  - 머리 카드: 진행도 바, 마일스톤 4칸(받음·받을 수 있음·아직), 다음 보상 한 줄과 받기 버튼.
  - 그 아래 칸 격자: 폭에 따라 열 수를 정한다. 줄마다 `IntrinsicHeight`로 높이를 맞추고, 글자가 커지면 칸이 늘어난다.
  - 넓은 화면은 `contentWidth`(720)로 폭을 제한한다.
  - 토큰은 `Ts`/`Space`/`Tap`/`IconSz`를 쓰고, 버튼은 `actionBtn`(48dp)을 쓴다.
- **메뉴 아이콘**: 전용 도감 아이콘이 없어 `tab_mission`(클립보드)을 쓴다(`codexMenuIcon` 상수 한 곳). 타이틀 버튼은 Material `menu_book` 아이콘.

## 이벤트 발생 위치

- `codex_open`: `CodexScreen.initState` (`lib/ui/codex_screen.dart`). value = 그 순간 받을 수 있는 마일스톤 수
- 새 이벤트 이름은 만들지 않았다.

## 균열 런(워커 B)과의 관계

- `RiftWorld`는 런 전용 `Profile`(`RiftWorld.riftProfile`, 저장하지 않음)을 쓰고 `_onKilled`를 직접 재정의한다(`lib/game/rift_world.dart:536`). 그래서 균열 처치는 메인 도감에 들어가지 않는다. 혹시 훅을 거쳐도 버리는 프로필에 기록된다.
- 균열 화면은 `lib/ui/rift_screen.dart`라 `CodexHud` 토스트도 뜨지 않는다.
- 이 구조가 바뀌면(예: 런이 메인 Profile을 공유) `world.dart:_onKilled`의 훅에 런 여부 확인을 넣어야 한다.

## 증거 PNG

`/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/d6219fb0-cb74-4608-b426-4ff0b861575e/scratchpad/task006/`
- `codex_{ko,en,de}_{portrait,landscape}_{enemies,planets,systems,crew}.png`: 24장. 글자 1.3, 세로 390×844, 가로 800×360, 발견·미발견 섞인 상태
- `codex_toast_{ko,en,de}_{portrait,landscape}.png`: 6장
- `codex_title_{ko,de}_{portrait,landscape}.png`: 4장
- 모아 본 그림(1200px 이하): `sheet_{ko,en,de}_{portrait,landscape}.png`, `toast_crop.png`, `title_sheet.png`

직접 본 결과: 넘침·겹침 없음. 탭·칸·마일스톤이 모두 화면 안에 들어오고, 독일어 긴 문구는 줄바꿈된다.
테스트 엔진에는 이모지·Material 아이콘·움라우트 글꼴이 없어 네모로 보인다(앱에서는 시스템 글꼴로 나온다. 다른 화면 증거도 같다).
처음 그린 판은 마일스톤 카드 4개가 세로 화면을 거의 다 차지해서, 진행 칸 4개 + 다음 보상 한 줄로 줄였다.

## 검증

- `dart analyze lib test`: 내 파일 0건. 남은 5건은 다른 워커 파일이다(`lib/game/next_goal.dart` info 4, `test/support/rift_bot.dart` 미사용 import 경고 1).
- `flutter test --no-pub test/codex_test.dart test/landscape_layout_test.dart`: 83/83 통과
- `flutter test --no-pub` 전체: 556 통과, **1 실패** — `test/balance_test.dart` "진행 밸런스 뒤 항성계(3~6)…"(Expected < 5.773, Actual 5.977)
  - 내 탓이 아님을 확인했다. 작업 트리 사본에서 `world.dart`의 도감 훅 5줄을 빼고 돌려도 같은 값(5.977)으로 실패한다.
  - 훅은 RNG를 쓰지 않고 게임 상태도 바꾸지 않는다. 동시에 작업 중인 다른 워커(A의 첫 5분/진행 봇 변경 등) 쪽 원인으로 보이며, 고치지 않았다.
- 렌더 게이트(`test/codex_test.dart` 화면 그룹)
  - ko/en/de × 세로·가로 × 글자 1.3 × 4탭: 그리기 오류 0
  - 토스트: ko/en/de 세로·가로
  - 타이틀 도감 버튼: 세로·가로, 화면 안, 높이 40 이상
- 단위 테스트: 중복 없는 기록, 원형·지휘함 구분, id 목록이 실제 적 종류를 모두 덮는지, 정착 최고 레벨, ★4 제외, 퍼센트 내림, 마일스톤 1회 수령, 100% 보상에 젬 없음 + 상점 미노출, 월드 지급과 정원 초과 대기, 저장 왕복, 구버전 저장 = 빈 도감, dirty 표시, 게임 훅(처치·정착·승무원·워프), 환생 뒤 유지, 기존 진행 무음 채움

## 남은 리스크

- **도감 의상을 상점에서 다시 고를 수 없다.** 상점에서 다른 의상을 입으면 도감 화면에서 다시 장착해야 한다. 상점 의상 탭에 "도감 보상" 칸을 넣으려면 `shop_screen.dart` 수정이 필요한데, 이번 수정 범위 밖이라 하지 않았다.
- **도감 의상은 전용 초상화 스프라이트가 없다.** `portrait_captain_codex.png`가 없어서 대화창 초상화가 기존 그림 대신 치비 도형 그림으로 나온다(`ChibiPortrait` errorBuilder). 다른 의상과 그림 결이 다르다. 오케스트레이터가 Gemini로 초상화 1장을 만들면 해결된다.
- **도감 전용 메뉴 아이콘이 없다.** 지금은 `tab_mission`을 재사용한다.
- **적 처치는 소급하지 않는다.** 기존 플레이어도 적 탭은 0부터 시작한다(종류별 처치 기록이 원래 없었다).
- **100% 목표는 길다.** 적 탭 100%는 항성계 두목 원형 6종을 모두 잡아야 하고, 항성계 100%는 26번째 항성계까지 가야 한다. 25/50%가 초반 동기를 맡는다.
- **보상 크레딧·광석은 고정값이다.** 후반 항성계에서는 체감이 작다. 반응을 보고 `codexReward`를 조정하면 된다.
- 실기기 확인은 하지 않았다(지시대로). 화면 동작은 위젯 테스트와 렌더 증거로만 확인했다.

## 오케스트레이터 추가 (2026-11-08, Claude)

- 도감 의상 초상화 `assets/sprites/portrait_captain_codex.png`(512×512) 추가 — 사용자 지시. Gemini에 기존 `portrait_captain_alien.png`를 참고 이미지로 올려 같은 화풍·구도로 생성(하늘색 머리, 청록 탐험복, 끝에 금별이 달린 안테나 헬멧, 가슴의 별자리 문양) → 흰 배경 제거 → 기존 초상화와 같은 경계 상자·바닥 정렬.
- `ChibiStyle.captainIn(codexOutfit)`이 이름(`portrait_captain_codex`)으로 찾으므로 코드 변경 없음. 위젯 렌더로 그림이 실제로 쓰이는 것 확인(대체 그림 아님).
- 도감 아이콘 `assets/icons/menu_codex.png`(256×256) 추가 — 사용자 지시. 기존 `menu_trophy`·`tab_mission`을 참고 이미지로 올려 Gemini 생성(파란 양장 책, 금색 모서리, 고리 행성 문양, 금별) → 배경 제거.
  `codexMenuIcon`을 `tab_mission` → `menu_codex`로 바꾸고, 타이틀 도감 버튼과 새 항목 토스트의 머티리얼 `menu_book_outlined`도 `GameIcon(codexMenuIcon)`으로 교체(`lib/ui/codex_screen.dart:31,712,790`). codex_test 24/24, 렌더로 타이틀·토스트 표시 확인.
