---
slug: gameplay-depth-rework-004
status: active
---

# REWORK 004 — 항성계 두목이 헤이븐 레이저에 바로 녹는 문제

## 실기기 관측 (SM M205N, 2026-10-21, Claude)
알파 센타우리(교역로) 저장에서 위협도 7.5에 항성계 두목(약탈 상선) 등장 → 경고 대사는 정상 출력 →
**약 4초 뒤 '두목 사냥' 업적**, 플레이어는 두목을 보지도 못함. 이후 화면엔 일반 재등장 두목('해적 두목')만 있었다.

## 헤드리스 재현 (같은 저장, 입력 없음)
두목이 본거지에서 655 거리에 생성 → 본거지로 접근 → 6.8초 만에 체력 1933 → 0, `bossDefeated=true`.
원인: `_updateHaven`의 헤이븐 레이저가 두목에게 한 발당 최대 체력의 `havenBossDamageRatio`(4%)를 0.22초마다 → 초당 약 18%.
(기존 두목도 같은 문제였지만, 이제 두목 패턴이 항성계별 핵심 콘텐츠라 플레이어가 싸울 기회가 있어야 한다.)

## 요구
- **항성계 두목(`sectorBoss`)**은 헤이븐 레이저로 한 발당 최대 체력의 **0.6%**까지만 깎인다(초당 약 2.7%, 혼자 두면 약 37초 이상). 일반 두목·잡몹은 지금 그대로.
  상수로 두고(`havenSectorBossDamageRatio` 등) 이유를 주석 한 줄.
- 정거장·식민지 포탑은 그대로.
- 테스트(`test/system_boss_test.dart`에 추가): 플레이어 입력 없이 본거지 근처에 생성된 항성계 두목이 **20초 안에 죽지 않는다**, 일반 두목은 기존 비율 유지.
  가능하면 위 재현과 같은 조건(섹터 1, 플레이어가 본거지 옆, 두목이 본거지 650 거리)으로.
- `flutter test --no-pub` 전체 통과, `dart analyze lib test` 0. 밸런스 기대값 완화 금지(밸런스 수치 변화는 보고).
- 결과: `docs/agent-collaboration/gameplay-depth/RESULT_004_REWORK_CLAUDE.md`.
- 금지: git commit/checkout/reset/revert/stash, 기기 실행, 범위 밖 파일.
