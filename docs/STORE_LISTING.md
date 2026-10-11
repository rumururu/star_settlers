---
slug: store-listing
status: canonical
owner: mkideabox
updated: 2026-10-10
---

# 스토어 등록 문구

> 한국어·영어 요약본. **10개 언어**(ko-KR, en-US, ja-JP, zh-CN, es-ES, fr-FR, de-DE, pt-BR, ru-RU, id-ID) 정본은
> `docs/release_info/l10n/<언어>.json` (`title`·`name`·`subtitle`·`short`·`full`·`keywords`·`promo`, 스크린샷 문구 `slides` 8장).
> Fastlane 폴더의 txt와 이미지는 이 json과 `docs/release_assets/final/locales/`에서 만든다:
>
> ```bash
> python3 docs/release_assets/tools/build_store_metadata.py           # 생성 + 길이·이미지 크기 검증
> python3 docs/release_assets/tools/build_store_metadata.py --check   # 검증만
> ```
>
> 업로드(빌드 없이 등록정보·이미지만): `cd android && fastlane listing` / `cd ios && fastlane listing`.

## 문구 원칙

- 대상: 어린이부터 어른까지. 쉬운 말, 무섭거나 자극적인 표현 없음.
- 뽑기·확률을 띄우는 문구(“대박 뽑기”, “한정 확률 UP” 등)를 쓰지 않는다. 승무원은 “모으기/만나기”로 쓴다.
- 결제 압박 금지. 설명 마지막 단락에 **결제 없이 끝까지 플레이 가능 + 인앱 구매는 선택 + 광고는 직접 눌렀을 때만**을 모든 언어에 넣는다.
- 게임 안 이름은 각 언어 ARB(`lib/l10n/app_*.arb`)와 같게 쓴다: 헤이븐 기지, 방어포탑·채굴 시설·교역소·수리 도크·방어막 발생기, 포수·기관사·조종사·상인·광부·과학자, 노바 드래곤·오로라, 부관 미나, 상인 냥냥, 함대 사령관 패스.
- 실제 천체: 태양계 → 화성(첫 식민지) → 알파 센타우리·시리우스 → 은하 중심 → 안드로메다 은하 (`lib/game/star_catalog.dart`).
- App Store 키워드는 이름에 있는 단어를 반복하지 않는다(애플이 이름·부제를 이미 색인한다). 쉼표 뒤 공백 없음.

## 스토어별 고정값

| 항목 | 값 |
|---|---|
| 개인정보처리방침 | https://rumururu.github.io/mkideabox/star_settlers/privacy.html |
| 지원 URL / 마케팅 URL | https://mkideabox.com |
| App Store 카테고리 | 게임 (기본) · 하위 카테고리 캐주얼, 액션 |
| 저작권 | 2026 mkideabox Co. Ltd. |
| Play 언어 코드 | ko-KR en-US ja-JP zh-CN es-ES fr-FR de-DE pt-BR ru-RU id |
| App Store 언어 코드 | ko en-US ja zh-Hans es-ES fr-FR de-DE pt-BR ru id |

## 이미지

| 스토어 | 위치 | 원본 | 규격 |
|---|---|---|---|
| Play 폰 8장 | `android/fastlane/metadata/android/<언어>/images/phoneScreenshots/` | `final/locales/<언어>/phone/*-google.png` | 1440×2880 |
| Play 10인치 태블릿 8장 | `…/images/tenInchScreenshots/` | `final/locales/<언어>/tablet/*.png` | 2064×2752 |
| Play 그래픽 이미지 | `…/images/featureGraphic.png` | `final/locales/<언어>/common/feature_graphic_1024x500.png` | 1024×500 |
| Play 아이콘 | `…/images/icon.png` | `docs/release_assets/app_icon/play_icon_512.png` | 512×512 |
| iPhone 6.9형 8장 | `ios/fastlane/screenshots/<언어>/NN_*.png` | `final/locales/<언어>/phone/NN_*.png` | 1320×2868 |
| iPad 13형 8장 | `ios/fastlane/screenshots/<언어>/ipad_NN_*.png` | `final/locales/<언어>/tablet/*.png` | 2064×2752 |

## 한국어 (ko-KR)

| 항목 | 글자 수 | 문구 |
|---|---:|---|
| Play 제목 (≤30) | 21 | 우주 개척단 - 치비 선장의 은하 모험 |
| App Store 이름 (≤30) | 21 | 우주 개척단 - 치비 선장의 은하 모험 |
| App Store 부제 (≤30) | 18 | 해적 전투·행성 개척·정거장 건설 |
| Play 짧은 설명 (≤80) | 43 | 화성에서 출발해 진짜 별들로! 귀여운 치비 선장의 해적 전투와 행성 개척 모험 |
| App Store 키워드 (≤100바이트) | 97B | `슈팅,방치형,식민지,우주선,귀여운,캐주얼,화성,태양계,승무원,함선,성장` |
| App Store 프로모션 텍스트 (≤170) | 92 | 지구에서 출발하는 치비 선장의 우주 모험! 화성에 첫 식민지를 세우고, 해적을 물리치고, 알파 센타우리와 안드로메다까지 날아가 보세요. 인앱 구매는 모두 선택이에요. |

### 자세한 설명 (Play 전체 설명 = App Store 설명, 1075자)

```text
🚀 귀여운 치비 선장이 되어 지구에서 출발하는 진짜 우주 모험을 떠나 보세요!

🪐 화성에서 시작해 진짜 별들로
모험은 우리 태양계에서 시작해요. 화성에 첫 깃발을 꽂고 달, 금성, 목성, 토성의 위성까지 하나씩 개척해요.
모든 행성을 키우면 워프 게이트가 열려요. 알파 센타우리, 시리우스 같은 실제 항성계를 지나 우리 은하 중심과 안드로메다 은하까지 날아가 보세요.

🏗 아기자기한 식민지 만들기
식민지는 방어막 돔이 지켜 주는 작은 행성 마을이에요.
방어포탑, 채굴 시설, 교역소, 수리 도크, 방어막 발생기를 지어 수입도 늘리고 해적 습격도 막아요.

⚔ 쉽고 신나는 우주 전투
조이스틱 하나로 움직이고 버튼으로 쏘면 끝!
유도 미사일, 에너지 실드, 전투 드론, 부스트로 해적과 현상수배범, 항성계 두목을 물리쳐요.
헤이븐 기지의 레이저도 든든하게 함께 싸워 줘요.

🛸 격납고와 정거장
정거장에서 무기, 장갑, 엔진, 미사일, 실드, 드론, 자석을 업그레이드해요.
빠른 인터셉터부터 노바 드래곤, 오로라까지 7종 함선 중에서 골라 타요.

👩‍🚀 귀여운 승무원
포수, 기관사, 조종사, 상인, 광부, 과학자를 모아 함선에 배치하면 함선이 더 강해져요.
반짝이는 ★4 전설 승무원도 만날 수 있어요!

💤 쉬는 동안에도 쌓이는 수입
게임을 꺼 두어도 식민지는 열심히 일해요. 돌아와서 부관 미나와 함께 수입을 받아 가세요.

📅 매일 즐거운 우주 생활
출석 보상, 일일 퀘스트, 업적, 임무, 유성우, 그리고 떠돌이 상인 냥냥이 기다려요.

✨ 나만의 스타일
함선 스킨과 냥냥 헬멧, 토끼 귀 같은 선장 의상으로 꾸미고, 내 행성도 예쁘게 가꿔요.

🌍 10개 언어 지원
한국어 · English · 日本語 · 简体中文 · Español · Français · Deutsch · Português · Русский · Bahasa Indonesia

💜 누구나 편하게
회원가입 없이 바로 시작하고, 진행 상황은 기기에 저장돼요.
결제하지 않아도 모험을 끝까지 즐길 수 있어요. 젬, 프리미엄 함선, 꾸미기, 함대 사령관 패스 같은 인앱 구매는 모두 선택이에요.
광고는 보상을 받고 싶을 때 직접 눌러야만 나와요.
```

## English (en-US)

| 항목 | 글자 수 | 문구 |
|---|---:|---|
| Play 제목 (≤30) | 29 | Star Settlers - Space Captain |
| App Store 이름 (≤30) | 29 | Star Settlers - Space Captain |
| App Store 부제 (≤30) | 29 | Fight pirates, settle planets |
| Play 짧은 설명 (≤80) | 80 | Fly from Mars to real stars! A chibi captain's adventure with pirates & colonies |
| App Store 키워드 (≤100바이트) | 91B | `galaxy,colony,shooter,chibi,cute,idle,spaceship,crew,casual,mars,solar,explore,tycoon,alien` |
| App Store 프로모션 텍스트 (≤170) | 166 | Set out from Earth with a cute chibi captain! Build your first colony on Mars, chase off pirates and warp to Alpha Centauri and Andromeda. All purchases are optional. |

### 자세한 설명 (Play 전체 설명 = App Store 설명, 2078자)

```text
🚀 Become a cute chibi captain and set out from Earth on a real space adventure!

🪐 Start on Mars, then fly to real stars
Your journey begins in our own Solar System. Plant your first flag on Mars, then settle the Moon, Venus, Jupiter, the moons of Saturn and more.
Develop every planet to open the warp gate. Visit real star systems like Alpha Centauri and Sirius, then travel all the way to the center of the Milky Way and the Andromeda Galaxy.

🏗 Build cozy colonies
Each colony is a little planet town, safe under a shield dome.
Build a Turret, Mining Rig, Trade Post, Repair Dock and Shield Generator to earn more and keep pirate raids away.

⚔ Easy, exciting space battles
Move with one joystick and tap to fire!
Use homing missiles, energy shields, combat drones and boost to chase off pirates, wanted outlaws and system bosses.
The laser at Haven Base has your back, too.

🛸 Hangar and Station
Upgrade your weapon, armor, engine, missiles, shield, drone and magnet at the station.
Pick from 7 ships, from the speedy Interceptor to the Nova Dragon and Aurora.

👩‍🚀 A cute crew
Recruit gunners, engineers, pilots, traders, miners and scientists, and assign them to your ship to make it stronger.
Shiny ★4 Legendary crew members can join you, too!

💤 Income while you rest
Your colonies keep working while you're away. Come back and collect your credits with Lt. Mina.

📅 Something new every day
Daily login rewards, daily quests, achievements, missions, meteor showers and Nyang, the wandering merchant cat.

✨ Your own style
Dress up your ship with skins and your captain with outfits like the Kitty Helmet and Bunny Ears, and decorate your very own planet.

🌍 10 languages
한국어 · English · 日本語 · 简体中文 · Español · Français · Deutsch · Português · Русский · Bahasa Indonesia

💜 Friendly for everyone
No sign-up needed. Your progress is saved on your device.
You can enjoy the whole adventure without paying. In-app purchases such as gems, premium ships, cosmetics and the Fleet Commander Pass are completely optional.
Ads only play when you choose to watch one for a reward.
```
