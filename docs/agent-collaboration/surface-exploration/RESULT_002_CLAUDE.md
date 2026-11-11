---
slug: surface-exploration-result-002
status: result
---

# RESULT 002 — 지표 탐험 화면

## 변경 파일
- 새 파일
  - `lib/ui/surface_screen.dart` — `SurfaceScreen`(소개 → 탐사 → 결과, 모달 층은 한 번에 하나), `SurfaceIntroPanel`, `SurfaceResultPanel`, `SurfaceDiscoveryBadge`, `planetDiscoveries`
  - `lib/ui/surface_painter.dart` — 바닥 타일(ImageShader 반복)·지도 경계·위험 지대·장애물·착륙선·지점(머물기 고리·이름·진행 막대·완료 표시)·차량·생물·화면 밖 지점 화살표·산소 경고 뒤 착륙선 큰 화살표. 그림이 없으면 모두 도형으로 대체. `surfaceSpriteNames`
  - `test/surface_ui_test.dart` (21개)
- 수정
  - `lib/ui/world_painter.dart` — `SurfaceWorld`일 때만 갈래: 우주 배경 대신 `paintSurfaceBackdrop`/`paintSurfaceGround`, 함선 대신 `paintRover`, 적 대신 `paintCreature`, 끝에 `paintSurfaceArrows`. 기존 우주 물체 그리기는 `_paintSpace`로 묶었을 뿐 내용은 그대로
  - `lib/ui/game_screen.dart` — 행성 곁 행동 버튼에 「착륙 탐사」(`act_land`, 키 `act-land`), `_modalRoute(SurfaceScreen(...))`로 열어 메인 월드 멈춤. 가스 행성은 「가스 행성 — 착륙 불가」 비활성. 해금 전에는 버튼 없음
  - `lib/ui/colony_panel.dart` — 헤더에 발견 배지(광맥·둥지 소탕·완전 탐사) + 효과 한 줄
  - `lib/ui/codex_screen.dart` — 유물 탭(`menu_relic` 아이콘, 못 찾은 유물은 실루엣 + "행성 유적에서 발굴", 찾은 유물은 한 줄 설명), 유물 탭 마일스톤 100% 하나
  - `lib/main.dart` — `Sprites.load`에 `surfaceSpriteNames` 추가(차량·착륙선·생물·지점·바위·바닥 타일·유물)
  - 번역 28개 추가(`srf_codexTab` … `srf_colonyDisc`, 10개 언어), `flutter gen-l10n`

## 화면 결정
- HUD는 균열 런과 같은 자리: 왼쪽 위 정보(체력·산소 막대 + 남은 초, 30초 아래면 빨강 깜박임, 남은 지점, 이번 판 💰/광석), 오른쪽 위 일시정지, 아래 조이스틱·전투 버튼(자동 사격·미사일·부스트·방어막·발사). 미사일·방어막 강화가 없으면 아이콘을 흐리게.
- 대사(산소 경고 등)는 정보 칸 아래 한 줄(가로 화면은 위 가운데).
- 「귀환」 큰 버튼: 착륙선 반경 안일 때만. 세로는 조이스틱 줄 위 가운데, 가로는 조이스틱과 전투 버튼 사이. 키보드 E/R.
- 발굴·채굴 진행 막대와 둥지 체력 막대는 지점 위(월드 좌표). 끝낸 지점은 회색·반투명 + ✓.
- 중간에 나가기: 일시정지 → 「비상 귀환」 → 확인 패널(「탐사를 그만둘까요? / 비상 귀환하면 전리품은 절반」) → 결과. 뒤로 가기·앱 백그라운드 = 일시정지. 모두 같은 모달 층(한 번에 하나).
- 결과: 끝난 이유 제목, 조사한 지점 n/5, 남긴 비율, 받은 💰·광석·젬, 하루 횟수 소진 안내, 새 발견 배지, 새 유물 카드(그림·이름·설명), 오늘 남은 온전 보상, 「돌아가기」. 「다시 착륙」은 없음(SPEC).
- 정산은 결과로 넘어갈 때 메인 월드에 바로 넣고 `SaveService.save(main)`. 통계 `surface_start`(행성 종류 index)는 「착륙」을 누를 때.
- 모달 틀은 균열 런의 `RiftPanel`을 재사용(같은 디자인 토큰, 넘치면 내용만 스크롤·버튼 줄 고정).

## 게이트 테스트 (`test/surface_ui_test.dart`)
- ko·en·de × 세로 390×844 / 360×740 / 가로 800×360 × 글자 1.3배: 소개(발견 3개·온전 보상 남음/소진), 결과(귀환·격추+30%), 식민지 패널 발견 배지, 도감 유물 탭, 탐사 HUD(유적 발굴 중 / 착륙선 위 귀환 버튼) — 넘침 0, HUD 키(`srf-info`, `srf-pause`, `srf-joystick`, `srf-combat`, `srf-status`, `srf-return`) 겹침 0·안전 영역 안, 일시정지·귀환 48dp 이상, 일시정지 → 비상 귀환 확인이 하나씩만 뜸.
- 끝까지 흐름: 비상 귀환하면 전리품 절반이 메인 월드에 들어가고 결과 화면·하루 횟수 기록.
- 게임 화면: 해금 뒤 행성 곁 「착륙 탐사」, 가스 행성은 비활성 문구, 해금 전엔 버튼 없음.

## 증거 PNG와 판정
폴더: `/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/d6219fb0-cb74-4608-b426-4ff0b861575e/scratchpad/surface/` (86장, `SNAP_DIR=… flutter test --no-pub test/surface_ui_test.dart`로 다시 만든다)
- `explore_garden.png`, `explore_desert.png`, `explore_ice.png`, `explore_lava.png` — 종류별 바닥 타일·바위(버섯/사암 기둥/얼음 결정/화산암)·위험 지대(보라 늪/모래/푸른 분출구/용암)·유적 발굴 막대·생물·차량·화면 밖 지점 화살표·산소 경고 대사가 보인다. 판정: 정상.
- `hud_lander_*` — 착륙선 귀환 반경 고리와 「귀환」 버튼, 조이스틱·전투 버튼과 겹치지 않음. 정상.
- `intro_*`, `result_*`, `result_lost_*`, `pause_*`, `leave_*`, `colony_*`, `codex_*`, `game_land_button.png` — 넘침·잘림 없음. 독일어 유물 이름 "Gravitationskompass"가 카드에서 잘리던 것을 발견해 FittedBox로 고쳤다.
- 테스트 엔진의 Jua 글꼴에 독일어 움라우트·×·₂ 글리프가 없어 네모로 보인다(균열 런 증거와 같은 테스트 환경 한계, 기기에서는 대체 글꼴로 나온다). 테스트 환경엔 Material 아이콘 글꼴도 없어 일시정지·체크 아이콘이 네모.

## 검증
- `dart analyze lib test` — No issues found
- `flutter test --no-pub` — **687개 모두 통과** (TASK 001 뒤 666 + 새 21)

## 남은 리스크
- 실기기 미확인(기기 실행 금지 범위). 손맛(차량 속도 0.5배, 생물 0.45배)·바닥 타일 크기(월드 512 단위 반복)·라벨 크기는 실기기에서 확인 필요.
- 지점 이름 라벨은 생물 그림에 가려질 수 있다(생물이 지형 위에 그려짐).
- 서버 통계 허용 목록 v3 마이그레이션 배포 전에는 `surface_start/end`가 서버에서 거부된다(오케스트레이터 배포 대기).
- 식민지 패널 헤더가 발견 3개일 때 세로 화면에서 두 줄 + 효과 줄로 커진다(넘침은 없음).
