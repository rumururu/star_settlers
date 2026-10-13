---
slug: pre-release-audit
status: active
owner: mkideabox
updated: 2026-10-13
---

# Release Pre-Audit Result - v1.0.0 (5) - 2026-10-11

우주 개척단 (Star Settlers) 첫 출시 사전점검 결과다.
기준 문서: `~/.claude/flutter-release-guides/Flutter_Codex_Pre_Release_Audit_Runbook.md`, `~/.claude/APP_REVIEW_REJECTIONS.md`.
항목별 체크 상태는 `docs/release_procedure/test_checklist.md`에 있다.

> **2026-10-13: 결제·젬 구조 변경으로 아래 GO는 결제·젬 항목에 대해 무효다. 다시 검증해야 한다.**
> 젬을 기기 저장에서 서버 지갑으로 옮겼다 (`supabase/wallet/`, `lib/services/wallet.dart`).
> - 젬은 서버(claires-ranch 프로젝트, `starset_` 접두사)에만 있고, 앱은 수입 알림(`starset_earn`, 업적 1회·하루 횟수·플레이 하루 1000 상한)과 차감 요청(`starset_spend`)만 할 수 있다. 쓸 때는 서버 차감이 먼저다.
> - 결제는 앱이 지급하지 않는다. RevenueCat 사용자 ID = 설치 ID, RevenueCat → `starset-purchase-webhook` → 서버 지급. 환불은 회수, 복원(TRANSFER)은 지갑 이동.
> - 실서버 검사 51/51 (`supabase/wallet/tests/live.sh`), `flutter test` 전체 통과, `flutter analyze` 0건.
> - 실기기(SM G525N): 출석 +5, 웹훅 테스트 구매 +100, 승무원 슬롯 서버 차감, 저장 파일 조작·오프라인 구매 거부, 초기화 후 서버 0 확인.
> - RevenueCat 웹훅 `whintgrdfebc4b862` (전체 앱·Production+Sandbox·전체 이벤트), v2 API 만들어 둔 비밀 키는 키체인 `star-settlers-revenuecat-v2-secret`/`revenuecat`. 키체인 비밀값으로 함수 호출 200, 틀린 값 401.
> - 개인정보처리방침 10개 언어 게시(`mkideabox` `115172d`). App Store 라벨(기기 ID·구입 내역·게임 플레이 콘텐츠, 앱 기능)과 Play 데이터 보안(구매 내역·기기 ID·앱 활동)이 이미 서버 지갑 데이터를 덮어 변경 없음.
> - 1.0.0 (7) 재제출: iOS 빌드 6 심사 취소 → 빌드 7 + IAP 5개 WAITING_FOR_REVIEW. Play 프로덕션 코드 6 → 7 교체(completed), 내부 테스트 7.
> - 실제 스토어 구매 → 웹훅 → 서버 지급 확인 (2026-10-13, SM M205N, Play 내부 테스트에서 설치한 빌드 7, 라이선스 테스터 계정, 테스트 카드): `gems_100` 거래 `GPA.3372-6296-4599-88218` → `starset_purchases` 1행(PLAY_STORE, SANDBOX) → 지갑 5 → 105, 앱 상점 표시 105.
> - 첫 시도(`GPA.3343-9959-2594-56480`)는 결제 완료 창 뒤에 Play 홍보 창이 떠서 결과가 앱에 늦게 돌아왔고, 테스트 구매의 짧은 승인 기한을 넘겨 구글이 자동 환불했다. 그래서 RevenueCat·서버에 기록이 없다(정상). 실사용자 승인 기한은 3일이라 같은 일은 드물다.
> - 같은 기기·빌드에서 이어서 확인 (2026-10-13): 스타터 팩 → 서버 +300·starter 켜짐, 앱 '보유 중' / 사령관 패스 → premium 켜짐, 앱 '보유 중' / 배치 슬롯 +1(100젬) → 서버 405→305, 앱 305, 슬롯 3→4 / 앱 삭제 → Play 재설치(새 설치 ID) → 구매 복원 → 새 지갑 310(옮겨 온 305 + 출석 5)·starter·premium, 예전 지갑 0.
> - 환불 회수는 Play 실주문으로 확인하지 못함 (주문 환불 API 호출이 권한 검사에서 막힘). 실서버 검사(live.sh)로만 확인. RevenueCat의 Google 개발자 알림(RTDN)이 연결되어 있지 않아 Play 환불이 RevenueCat에 늦게 전달될 수 있다.
> - 남은 것: iOS 샌드박스 구매 → 서버 지급 확인(선택, 심사 전 권장).
> - RevenueCat Google 개발자 알림(RTDN) 연결 (2026-10-13): RevenueCat 토픽 `projects/project-da4ee1b7-3fcf-4373-815/topics/Play-Store-Notifications`(ctw와 같은 토픽) + Play Console 수익 창출 설정에 같은 토픽, 알림 콘텐츠 '모든 일회성 제품'. Play 테스트 알림을 RevenueCat이 받음.
>
> **다음 버전(1.0.1)에 넣을 것: 클라우드 백업** (빌드 7에는 없음, 코드는 작업 트리에만)
> - `lib/services/cloud_backup.dart`: Play 게임즈 저장 게임 / Game Center 저장 게임(iCloud)에 프로필+월드+설치 ID 백업. 복원하면 설치 ID가 돌아와 서버 지갑·RevenueCat 사용자가 따라온다. 자동 백업은 그 기기에서 백업·복원을 한 번 한 뒤에만(새 기기에서 연결만 하고 덮어쓰기 방지), 10분 간격.
> - Play Games 서비스(2026-10-13 게시 완료): 프로젝트 ID `1080311738151`(GCP `star-settlers`), 저장된 게임 사용, Android OAuth 클라이언트 2개(Play 앱 서명 SHA-1 `FF:76:A5:…:E6:F8`, 디버그 키 `6E:82:25:…:2E:12`), 테스터 = 내부 테스트 트랙 + ru***. 설명(en-US)·아이콘·그래픽·카테고리(시뮬레이션) 입력.
> - iOS: App ID에 GAME_CENTER·ICLOUD 켬, iCloud 컨테이너 `iCloud.com.mkideabox.starsettlers` 등록·App ID에 연결, `ios/Runner/Runner.entitlements`. ASC Game Center 사용 설정(gameCenterDetail) 완료 — 1.0.1 버전을 만들 때 그 버전에도 Game Center를 붙인다. 디버그 빌드(xcodebuild, 자동 서명) 통과. 배포 프로필은 App ID 변경으로 무효가 되어 다음 `fastlane release`에서 sigh가 새로 만든다.
> - GCP OAuth 동의 화면을 프로덕션으로 게시(테스트 상태에서는 403 access_denied — 저장된 게임이 Drive 앱 데이터 범위를 쓰기 때문). 홈페이지·개인정보처리방침 링크 = privacy.html, 승인된 도메인 rumururu.github.io, 로고 없음(로고를 넣으면 인증 심사 필요).
> - 실기기 Android (2026-10-13, SM M205N, 디버그 빌드, rumururu 계정): 앱 시작 때 Play 게임즈 프로필 선택 → 권한 동의(Play 게임즈 활동, Drive 앱 데이터) → 새 게임(크레딧 155.87) → 설정 '지금 백업' → 앱 삭제·재설치(진행 없음) → '백업에서 복원' 확인창(10:21 백업) → 복원 → 이어하기 활성, 크레딧 155·광석 20 그대로, 오프라인 수입 2분. 고친 것: 실패한 백업이 시각을 바꾸던 문제, 자동 로그인 때 플레이어 이름 미표시.
> - 실기기 iOS: 미확인 (iPad 잠김으로 실행 불가). 디버그 빌드(Game Center·iCloud 권한 포함)는 통과.
> - 개인정보처리방침 10개 언어에 '클라우드 백업' 절과 요약 문장 추가·게시(`mkideabox` `abe3804`), 앱 안 요약(`m_privacyBody`)에도 문단 추가.
> - 이 변경 전에 기기에서 산 테스트 구매는 서버 지갑으로 옮겨지지 않는다 (출시 전이라 테스터만 해당).

## 사전 입력값

| 항목 | 값 |
|---|---|
| 릴리즈 타입 | First Release |
| 버전/빌드 | 1.0.0 (5) — `pubspec.yaml` `version: 1.0.0+5` (결제 검증은 4에서, 5는 복원 화면 갱신 수정만) |
| 대상 커밋 | `053ebe0` (브랜치 `claude/find-fun-project-di1hjq`, 작업 트리 깨끗함) |
| 관련 커밋 | `cda37e0` 게임플레이·가로 모드, `d32bf4c` 스토어 문구·이미지, `053ebe0` 젬 이중 지급 수정 |
| 배포 상태 | iOS 1.0.0 (4) TestFlight 내부 그룹 "Internal Testers". Android 1.0.0 (4) Play 내부 테스트 트랙, 테스터 목록 "TFNote internal testers" |
| 환경 | 운영(prod). RevenueCat 키는 빌드 때 `--dart-define`으로 넣는다 |

앱 기능 프로필 (확정):

- 광고: 있음. AdMob 보상형만. UMP 동의 + 설정에서 변경·철회.
- 인앱결제: 있음. 소모성 3종(`gems_100`, `gems_550`, `gems_1200`), 비소모성 2종(`starter_pack`, `premium_pass`). RevenueCat 경유.
- 커뮤니티: 없음. 선택형 주간 순위표만 (자동 별명, 자유 입력 없음).
- 다국어: 10개 (ko en ja zh es fr de pt ru id).
- 계정: 없음. 계정 삭제 대신 "모든 데이터 초기화".

## Verdict

- **GO** (심사 제출 조건: 첫 IAP 5개를 버전 1.0 제출에 함께 묶을 것 — P1-3)

P0는 없다. 하드 게이트 실패도 없다.
P1-1(Android 실결제)과 P1-2(iOS 재설치 후 복원)는 2026-10-11 실기기로 확인해 닫았다.
P1-3은 제출 시점에 하는 조치다.

## Failed Gates

- none (실패한 게이트 없음)
- 미완료(증적 부족)인 게이트:
  - (해결) Gate C / E: Android Play 테스트 구매, iOS 재설치 후 복원 모두 실기기 확인.
  - Gate B: iPad 가로 화면을 실기기로 보지 않았다. 위젯 테스트만 통과 (도구 통과 / 제품 미확인).

## 게이트별 판정

| Gate | 판정 | 근거 |
|---|---|---|
| A 가독성/테마 | 통과 (조건부) | 다크 고정 테마 `lib/main.dart:86-99`. 글자 배율 1.3배 상한 `lib/main.dart:101-103`. 색상은 토큰 `lib/ui/tokens.dart` 경유. 시스템 라이트 모드 다이얼로그 대비 실기기 캡처는 이번 감사에서 새로 찍지 않았다 |
| B 반응형/태블릿 | 미완료 | 폰 세로·가로(Note9 실기기) 확인. iPad 세로는 TestFlight 결제 테스트에서 사용. iPad 가로는 `test/landscape_layout_test.dart:43` (1366x1024) 통과만 있음. 설정에서 자동/세로/가로 선택 `lib/services/orientation.dart` |
| C 사용자 여정 | 통과 | iPad: 구매 3종·재실행 유지·재설치 후 복원(스타터 팩·패스 복원, 젬은 의도대로 미복원). Android(F966N, Play 설치본 빌드 4): 젬 한 줌 +100, 재실행 후 유지 |
| D 보안 | 통과 | 아래 보안 점검 결과 참고 |
| E 결제/광고 정책 | 통과 | RevenueCat 서버 검증 후 지급, 같은 거래 1회 지급(`053ebe0`). iOS 3종 + Android 젬 구매 실기기 확인 |
| F 다국어 | 통과 | 하드코딩 sink 스캔 0건, ARB 820키 × 10개 언어 누락 0 |

## Findings Summary

### P0

- 없음.

### P1

1. ~~Android Play 테스트 구매 미확인~~ → **해결 (2026-10-11).** F966N, Play 내부 테스트로 설치한 빌드 4(설치 출처 `com.android.vending`, versionCode 4). 구글 결제 창 "테스트 카드, 항상 승인"으로 `gems_100` 구매 → 젬 5 → 105 (+100), 앱 강제 종료 후 재실행해도 105.
2. ~~iOS 재설치 후 구매 복원 미완료~~ → **해결 (2026-10-11).** iPad TestFlight 빌드 4 삭제 후 재설치 → 젬 5(새 시작) → 구매 복원 → 재실행 시 스타터 팩·사령관 패스 "보유 중", 젬 305(스타터 팩 300 재지급, 소모성 젬은 미복원 = 의도). 이때 **복원 직후 상점 화면이 갱신되지 않는 버그**를 발견해 빌드 5에서 고쳤다 (`lib/ui/shop_screen.dart` 복원 후 `setState`, 회귀 테스트 `test/landscape_layout_test.dart` "구매 복원을 누르면…"). 빌드 5 실기기 재확인은 아직.
3. **첫 IAP는 앱 버전 1.0 심사와 같은 제출 묶음으로 내야 한다.** 5개 IAP가 READY_TO_SUBMIT인 것만으로는 제출이 아니다 (`APP_REVIEW_REJECTIONS.md` "In-App Purchase 미제출", Guideline 2.1(b)). 버전 제출 화면에서 5개를 모두 체크한다.

### P2

1. **Google 실시간 개발자 알림(RTDN) 미연결.** 선택 사항이다. 없으면 환불·취소가 RevenueCat에 늦게 반영된다. 출시 후 연결 권장.
2. **App Store Connect 한국 세금 정보 "세금 정보 없음" (사업자등록번호/국세청 확인 실패).** 출시는 막지 않는다. 대금 지급이 늦어질 수 있다. 소유자 조치.
3. **iPad 가로 실화면 미확인.** 위젯 테스트는 통과했다. 실제 iPad에서 가로로 한 번 보고 캡처를 남긴다. 실패해도 설정에서 세로로 고정할 수 있어 P2로 둔다. 단 심사관이 iPad 가로로 볼 수 있으므로 제출 전 확인을 권장한다.
4. **환불 반영 경로 미검증.** 소모성 환불 시 이미 쓴 젬을 회수하지 않는다. 클라이언트 지급 구조상 정상 범위다. 기록만 해 둔다.

### P3

1. `docs/STORE_LISTING.md`가 옛 문구("치비 선장")를 담고 있다. 실제 스토어 메타데이터(`ios/fastlane/metadata/ko/name.txt` = "우주 개척단 - 꼬마 선장의 은하 모험")와 다르다. 문서만 갱신하면 된다.
2. `docs/PRIVACY_POLICY.md`에 frontmatter(`slug`, `status`)가 없다.
3. 순위표 Supabase anon 키가 `lib/services/leaderboard.dart:22`에 있다. 공개용 키이며 서버는 함수 2개만 anon에 열어 두었다 (테이블 직접 접근 불가, 공용 게임 백엔드 규칙). 비밀값 아님.

## Apple 심사 거절 재발 방지 점검 (`APP_REVIEW_REJECTIONS.md`)

| 카테고리 | 판정 | 근거 |
|---|---|---|
| IAP 미제출 (2.1(b)) | 조치 필요 | 앱 코드 상품 ID 5개 = ASC IAP 5개 = RevenueCat offering "default" 5개 패키지. 5개 모두 READY_TO_SUBMIT + 심사 스크린샷 있음. **첫 IAP라 버전 1.0 제출에 함께 묶어야 한다** (P1-3) |
| 제3자 AI 데이터 전송 | 해당 없음 | AI 기능 없음 |
| 메타데이터 stale (4.1(c)/5.2.5) | 통과 (로컬) | `ios/fastlane/metadata` 전체에 Apple 상표·타사 AI 브랜드 단어 0건. "Google"은 `review_information/notes.txt`(심사 메모, 공개 안 됨)에만 있음. 제출 직전 ASC 웹에서 10개 언어 이름/부제를 한 번 더 눈으로 본다 |
| 4.1(c) 유행어 브랜드 겹침 | 통과 | 이름에서 "치비" 제거 완료 (`d32bf4c`). 현재 이름은 일반 서술 |
| 심사 메모 UI 경로 | 통과 | 노트에 광고 동의 경로, 복원 위치(상점 패키지 탭, 설정), 확률 공개, 순위표 opt-in이 적혀 있고 코드 위치와 일치 |

## Key Risks

- 결제 지급은 클라이언트가 한다. 검증은 RevenueCat이 하지만 지급 기록은 기기에 저장된다. 빌드 3에서 이중 지급(+200)이 있었다. 빌드 4에서 고쳤고 iPad에서 +100 정확히 확인했다. Android에서는 아직 같은 확인이 없다.
- 기기 저장 게임이라 앱 삭제 시 소모성 젬은 돌아오지 않는다. 심사 메모와 개인정보처리방침에 데이터가 기기 저장이라고 적혀 있다.
- 유료 무작위 영입(확률형) 때문에 벨기에를 양 스토어에서 뺐다. 확률은 게임 내 상시 공개 (`lib/ui/station_panel.dart:378-383`, `lib/ui/shop_screen.dart:325`).

## Evidence

### analyze/test logs (2026-10-11, 커밋 `053ebe0`)

- `flutter analyze` → `No issues found! (ran in 3.9s)`, exit 0
- `flutter test` → `+218: All tests passed!`, exit 0 (약 3분)
- 결제 회귀 테스트 `test/purchase_grant_test.dart` 7건: 같은 거래 1회 지급, 재설치 후 젬 반복 방지, 비소모성 복원, 저장 후 유지, 구매 결과와 고객 기록 ID가 달라도 1회, 연속 2회 구매는 2회 지급, 기록이 먼저 와도 1회

### 실기기/스토어 증적 (이번 세션 리드가 확인)

- iPad TestFlight 샌드박스, 빌드 4:
  - `gems_100` → 젬 493→593 (+100 정확), 재실행 후 593 유지
  - `starter_pack` → +300 젬, 보유 표시 (593→893), 재실행 후 유지
  - `premium_pass` → 재실행 후 보유, 젬 변화 없음
- 빌드 3 이중 지급(1회 구매 → +200) → `053ebe0`에서 수정
- RevenueCat: Play 자격증명 3/3 정상, App Store 자격증명 정상, offering "default" 5개 패키지. RTDN 미연결
- App Store Connect (앱 6821474077): IAP 5개 READY_TO_SUBMIT + 심사 스크린샷, 심사 연락처, 심사 메모 갱신, 173개 지역 (중국 본토·벨기에 제외), 13+, 개인정보 라벨 게시, 10개 언어 등록정보와 스크린샷 (폰 1320x2868, iPad 2064x2752)
- Google Play (앱 4975772601210261710): 앱 콘텐츠 선언 완료 (13+, 데이터 보안에 순위표 포함, 광고 ID, 벨기에 제외 177개국), IAP 5개 활성, 10개 언어 등록정보
- 가로 모드: Android 실기기(Note9) 가로 확인. iPad 가로는 미확인

### marionette scenario logs

- 이번 감사에서는 기기를 돌리지 않았다 (작업 범위 밖). 실기기 여정 증적은 위 리드 확인분이 전부다.

### security scan results

- secret 하드코딩: 없음. RevenueCat 키는 `String.fromEnvironment` (`lib/services/monetization.dart:171-172`). AdMob ID는 공개값 (`lib/services/ads.dart:30-37`, 디버그는 구글 테스트 단위). Supabase anon 키는 공개용 (P3-3)
- `git check-ignore` 결과 (모두 무시됨, 추적 안 됨):
  - `android/fastlane/.env` ← `.gitignore:56`
  - `ios/.env.local` ← `.gitignore:60`
  - `ios/fastlane/AuthKey_DGS7ANBS8T.p8` ← `.gitignore:58` (`ios/fastlane/AuthKey_*.p8`)
  - `android/app/star_settlers-release.jks` ← `android/.gitignore:14` (`**/*.jks`)
  - `android/key.properties` ← `android/.gitignore:12`
  - `android/fastlane/play-store-key.json` ← `.gitignore:55`
  - `git log --all`에 위 파일 이력 없음. `git ls-files`에도 없음
- `http://`: `lib/`에 0건. 플랫폼 폴더는 XML 네임스페이스·DTD 선언뿐
- TLS 우회/WebView 위험 설정 (`badCertificateCallback`, `NSAllowsArbitraryLoads`, `usesCleartextTraffic`, `JavascriptMode.unrestricted`): 0건
- 로그: `debugPrint` 15곳 모두 오류 코드/예외 메시지만 출력 (monetization 4, ads 4, notifications 3, audio 4). 토큰·키·영수증 출력 없음. RevenueCat 로그 레벨은 릴리즈에서 warn (`lib/services/monetization.dart:190`)
- 디버그 결제(`DevMonetization`)는 `kReleaseMode`가 아니고 키가 없을 때만 쓰인다 (`lib/services/monetization.dart:90-92`). 릴리즈는 RevenueCat
- 릴리즈 merged manifest 권한: INTERNET, RECEIVE_BOOT_COMPLETED, ACCESS_NETWORK_STATE, AD_ID, ACCESS_ADSERVICES_*, VIBRATE, POST_NOTIFICATIONS, BILLING, WAKE_LOCK, FOREGROUND_SERVICE. 모두 광고·결제·알림 플러그인 사유
- iOS: `PrivacyInfo.xcprivacy` 있음, SKAdNetworkItems 50개, ATT 문구 없음 (IDFA 미사용, 방침과 일치)

### localization coverage results

- 하드코딩 sink 스캔 (Runbook 4단계 6개 패턴 + `TextPainter`/알림/한글 리터럴): 사용자 노출 하드코딩 0건
  - 한글 리터럴은 주석, 조사 처리(`lib/game/josa.dart`), 승무원 이름 저장용 원본(`lib/game/crew.dart:44-48`, 화면 표시는 `tr.g_crewName*`)뿐
  - 알림 채널명·제목·본문은 `tr.*` (`lib/services/notifications.dart:57-85`)
- ARB 커버리지: 템플릿 `app_ko.arb` 820키. 10개 언어 모두 누락 0, 추가 0
  - 빈 값: `nickGenders` 1개 (성별 변화 없는 언어의 의도된 빈 값)
  - 플레이스홀더 차이로 보이는 항목은 ICU plural/select 확장 (예: `m_giftBody`, `nickAdj*`). 변수 이름은 같다. `flutter analyze`(gen-l10n 포함) 통과
- 네이티브: iOS `InfoPlist.strings` 10개 언어(`*.lproj`), `CFBundleLocalizations` 선언

### screenshots/videos

- 스토어 이미지: `docs/release_assets/final/locales/<언어>/` (10개 언어, `d32bf4c`에서 재생성)
- 결제 실기기 캡처: 리드 세션 보관분. 이 문서에는 첨부하지 않았다

## Required Actions Before Release

| # | 조치 | 담당 | 시점 |
|---|---|---|---|
| 1 | ~~iOS 재설치 → 구매 복원~~ 완료 (빌드 4). 빌드 5의 복원 직후 화면 갱신은 실기기 재확인 권장 | 리드 | 완료 / 권장 |
| 2 | ~~Android 실기기 Play 테스트 구매~~ 완료: `gems_100` +100, 재실행 후 유지 (스타터 팩은 iOS에서 확인) | 리드 | 완료 |
| 3 | iPad 가로 실화면 확인 (타이틀·HUD·정거장·상점) + 캡처 | 리드 | 심사 제출 전 (권장) |
| 4 | ASC 버전 1.0 제출 시 IAP 5개를 같은 묶음에 포함. 제출 직전 ASC 웹에서 10개 언어 이름/부제 재확인 | 소유자 | 심사 제출 시 |
| 5 | ASC 한국 세금 정보 수정 (사업자등록번호/국세청) | 소유자 | 대금 지급 전 |
| 6 | Google RTDN 연결 (RevenueCat ↔ Play Pub/Sub) | 리드 | 출시 후 |
| 7 | ~~`docs/STORE_LISTING.md` 문구 최신화~~ 완료. `docs/PRIVACY_POLICY.md` frontmatter 추가 | 리드 | 다음 문서 정리 때 |

1~2가 실기기 증적과 함께 끝나 판정을 GO로 올렸다 (2026-10-11).
