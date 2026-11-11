---
slug: surface-exploration-task-002
status: spec
---

# TASK 002 — 지표 탐험 화면

## 목표
TASK 001의 규칙 위에 화면을 얹는다. [SPEC.md](SPEC.md) §1, §3, §7, §8.

## 수정해도 되는 파일
- 새 파일: `lib/ui/surface_screen.dart`(소개·탐사·결과, 한 번에 하나만 뜨는 모달 층), `lib/ui/surface_painter.dart`(지형·위험 지대·장애물·지점·착륙선·산소 경고 화살표), 테스트 `test/surface_*_test.dart`
- `lib/ui/world_painter.dart`: `SurfaceWorld`일 때 우주 배경(성운·별·항성·궤도·행성·본거지) 대신 지형을 그리고, 선장 함선 대신 탐사 차량(`srf_rover`), 적 대신 생물 그림(`srf_crawler`/`srf_spitter`/`srf_brute`)을 쓰는 **작은 갈래**만 넣는다(나머지 그리기는 그대로 재사용).
- `lib/ui/game_screen.dart`: 행성 곁 행동 버튼에 「착륙 탐사」(아이콘 `act_land`), 누르면 `SurfaceScreen`을 기존 `_modalRoute`로 연다(메인 월드 멈춤). 가스 행성은 비활성 + 이유.
- `lib/ui/colony_panel.dart`: 헤더에 영구 발견 배지(광맥·둥지 소탕·완전 탐사)와 효과 한 줄.
- `lib/ui/codex_screen.dart`: 유물 탭(아이콘 `menu_relic`), 못 찾은 유물은 실루엣 + "행성 유적에서 발굴".
- 번역: `python3 tool/arb_add.py <keys.json>` 로만, 10개 언어, 접두사 `srf_`. 그다음 `flutter gen-l10n`.
- `lib/ui/sprites.dart`: 새 스프라이트 이름을 불러오는 목록(필요하면).

## 화면 요구사항
- HUD는 균열 런 화면 구성을 따른다(조이스틱·전투 버튼·자동 사격 자리 동일). 위쪽: 산소 막대(30초 아래 빨강 깜박임), 남은 지점 수, 이번 판 전리품. 착륙선 반경 안이면 「귀환」 큰 버튼.
- 발굴·채굴 중 진행 막대는 지점 위(월드 좌표)에.
- 결과 화면: 전리품(남긴 비율 표시), 새 발견 배지, 새 유물 카드, 오늘 남은 온전 보상 횟수, 「돌아가기」.
- 일시정지(앱 백그라운드 → 멈춤), 중간에 나가기 = 비상 귀환 50%(확인 창).
- 그림이 없으면 도형으로 대체(테스트 환경에도 그림이 없을 수 있다).
- `~/.claude/GAME_UI_ARCHITECTURE.md` 기준: 디자인 토큰(`lib/ui/tokens.dart`), 터치 48dp, 절대좌표 금지, 모달 층.

## 게이트 테스트
- ko·en·de × 세로 390×844, 360×740, 가로 800×360 × 글자 배율 1.3에서 소개·탐사 HUD·결과·식민지 배지·도감 유물 탭: 넘침 없음, HUD 키끼리 겹침 없음(`test/codex_toast_layout_test.dart`, `test/landscape_layout_test.dart` 방식).
- 증거 PNG: `SNAP_DIR` 방식으로 `/private/tmp/claude-501/-Volumes-home-extension-AndroidStudioProjects-star-settlers/d6219fb0-cb74-4608-b426-4ff0b861575e/scratchpad/surface/`에 저장하고, 1200px 이하로 줄여 직접 보고 판정한다. 종류별(정원·사막·얼음·용암) 탐사 화면 한 장씩 포함.

## 검증 명령
```bash
dart analyze lib test
flutter test --no-pub
```

## 금지
git 명령, 기기·에뮬레이터 실행, 실서버 접속, `assets/` 편집.

## 결과
`RESULT_002_CLAUDE.md`(한국어): 변경 파일, 화면 결정, 증거 PNG 경로와 판정, 검증 결과, 남은 리스크.
