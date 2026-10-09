---
slug: star-settlers-release-assets
status: review
owner: mkideabox
updated: 2026-10-10
---
# 우주 개척단 (Star Settlers) — 스토어 그래픽 자산

크기 규칙은 `~/AndroidStudioProjects/code_bridge/docs/release_assets/STORE_ASSET_GUIDE.md`를 따른다.
구성 방식(제목 + 부제 + 실제 캡처 기기 프레임 + 캐릭터 + 하단 설명/페이지)은 cozy_pet의 `docs/release_assets/cozy_pet` 소개 이미지를 기준으로 했다.

## 산출물

| 경로 | 수량 | 규격 | 용도 |
|---|---:|---|---|
| `final/locales/ko-KR/phone/NN_*.png` | 7 | 1320×2868 RGB | App Store iPhone 6.9" |
| `final/locales/ko-KR/phone/NN_*-google.png` | 7 | 1440×2880 RGB | Google Play 폰 (긴 변 ≤ 짧은 변 2배) |
| `final/locales/ko-KR/common/feature_graphic_1024x500.png` | 1 | 1024×500 RGB | Google Play 피처 그래픽 |
| `final/locales/ko-KR/tablet/` | 0 | 2752×2064 | **미생성** — 아래 "남은 일" 참고 |

앱 아이콘은 메인 작업에서 따로 만든다(`app_icon/`은 이 묶음에 없음).

슬롯 순서: 01 타이틀 · 02 기지 레이저 전투 · 03 방어막 돔 식민지 · 04 식민지 건물 · 05 항성계 · 06 격납고(노바 드래곤) · 07 정거장 함선 개조.

## 소스

- `captures/phone/` — 실제 앱 화면 원본 1320×2868. frun으로 임대한 Android 에뮬레이터 `nametree_test`에서 `wm size 1320x2868`, SystemUI 데모 모드(9:41)로 `screencap`했다. 데모 진행 상태(식민지 11곳, 크레딧, 승무원, 함선)는 디버그 빌드의 `shared_prefs` 세이브로 넣었다. 화면 UI는 전부 실제 렌더링이다.
- `intermediate/trimmed/phone/` — 상태바 150px / 하단 제스처바 41px를 잘라낸 중간본. 업로드용이 아니다.
- `screenshot/copy/ko-KR.json` — 슬롯별 제목·부제·하단 설명·캐릭터·색 테마.
- `feature_graphic/copy/ko-KR.json`, `feature_graphic/art/fg_art.png` — 피처 그래픽 문구와 배경 그림. 배경 그림은 승인된 스프라이트(정찰선, 정거장, 정원 행성, 해적선, 타이틀 배경)를 참조로 넣어 Codex 이미지 생성으로 만들었다(1774×887, 글자 없음).
- `templates/marketing.css`, `screenshot/html/`, `feature_graphic/html/` — 합성용 HTML/CSS. 글꼴은 앱과 같은 `assets/fonts/Jua-Regular.ttf`를 쓴다.

## 재생성

```bash
python3 docs/release_assets/tools/generate_store_assets.py            # ko-KR
python3 docs/release_assets/tools/generate_store_assets.py --locale en-US   # copy/en-US*.json 추가 후
```

설치된 Google Chrome을 headless로 실행해 HTML을 렌더링하고, RGB PNG로 저장한 뒤 정확한 픽셀 크기를 assert한다. 태블릿은 `captures/tablet/`에 가로 캡처가 있고 `screenshot/copy/<locale>.tablet.json`이 있을 때만 2752×2064 가로 레이아웃(`.land`)으로 만든다.

## 검수

- 위 15개 파일 모두 PIL로 크기와 RGB(알파 없음)를 확인했다.
- 축소본을 보고 확인한 항목: 제목·부제 잘림 없음, 캐릭터가 핵심 UI를 가리지 않음, 피처 그래픽 로고와 그림이 겹치지 않음, `테스트`/디버그 문구 없음.

## 남은 일

1. **iPad 13" (2752×2064) 세트.** iOS 타깃이 `TARGETED_DEVICE_FAMILY = "1,2"`라서 App Store에 iPad 스크린샷이 필요하다. 호스트 과부하로 에뮬레이터가 계속 멈춰서 실제 태블릿 화면을 캡처하지 못했다. `frun acquire --os android --form tablet --emulator prefer`로 캡처한 뒤 생성기를 다시 돌리면 된다.
2. **02 전투 슬롯은 약하다.** 기지 레이저가 섹터 두목을 쏘는 장면인데, 두목이 HUD 뒤에 가려진다. 해적과 근접전을 벌이는 장면으로 다시 찍는 것이 좋다.
3. **승무원 슬롯 없음.** 캡처 도중 에뮬레이터 시스템이 죽어서 찍지 못했다.
4. **다국어.** 문구는 ko-KR만 있다. 다국어(10개 언어) 작업이 끝나면 언어별 캡처와 `screenshot/copy/<locale>.json`, `feature_graphic/copy/<locale>.json`이 필요하다. 번역 대상: 슬롯마다 `title`·`sub`·`detail`, 그리고 `brand`, 피처 그래픽의 `tagline`·`sub`.
