---
slug: release-test-checklist
status: canonical
updated: 2026-10-11
---

# 출시 테스트 체크리스트 — 우주 개척단 (Star Settlers)

- 공통 기준: [중앙 출시 체크리스트 골격](../../../../mkideabox-corp-process/processes/release/test-checklist-baseline.md), [실행·판정·증거 기록](../../../../mkideabox-corp-process/processes/release/test-execution.md). 아래 게임별 Gate·영구 예외를 함께 적용한다. 기존 전역 템플릿·Runbook 표기는 작성 당시 출처다.
- 릴리즈: **First Release** v1.0.0+1 (`com.mkideabox.starsettlers`)
- 현재 점검 대상: 1.0.0 (4), 커밋 `053ebe0`. 2026-10-11 판정 **CONDITIONAL_GO** (상세 `PRE_RELEASE_AUDIT.md`). 표기: `[x]` 증적 있음, `[ ]` 미확인
- 판정·증적 기록: `docs/release_procedure/PRE_RELEASE_AUDIT.md`

## 앱 기능 프로필

| 항목 | 값 | 근거 |
|---|---|---|
| 대상 연령 | 13세 이상 (아동 대상 아님). 13세 미만 개인정보를 알면서 수집하지 않음 | 개인정보처리방침 7절, Play 타겟 연령 13+ |
| 광고 | 있음 — AdMob 보상형만 (사용자가 직접 선택, 사령관 패스 보유 시 없음). 아동 태그 없음, 최대 광고 등급 T. 맞춤형 광고는 UMP 동의에 따름 (EEA·영국·스위스는 첫 실행 시 동의, 설정 → "광고 개인정보 설정"에서 변경·철회). Android 광고 ID(AD_ID 권한) 사용, iOS IDFA·ATT 미사용 | `lib/services/ads.dart`, `lib/ui/meta_screens.dart` |
| 인앱결제 | 있음 — 젬 소모성 3종, 스타터팩·사령관 패스 비소모성 | `lib/services/monetization.dart` |
| 확률형 아이템 | 있음 — 젬(유료 재화 포함)으로 무작위 승무원 영입. 항목별 확률 게임 내 상시 공개 | 정거장 → 승무원 탭 확률 표기 |
| 배포 국가 | 벨기에 제외 (유료 확률형 아이템 불법). 그 외 전체 | Play Console 국가/지역, App Store Connect 판매 가능 국가 |
| 콘텐츠 등급 | 유료 무작위 아이템 때문에 호주 Adult·브라질 18+ 로 나옴 — 수용함 | IARC 설문 결과 |
| 계정/로그인 | 없음 (기기 내 저장). 선택형 주간 순위표만 익명 설치 ID로 서버 사용 | 계정 삭제 시나리오 → "데이터 초기화"로 대체 |
| 커뮤니티 | 없음 | — |
| 다국어 | 10개 (ko en ja zh es fr de pt ru id) | `lib/l10n/app_*.arb` |
| 테마 | 다크 고정 게임 UI | — |

## A. UI / Theme / 가독성
- [ ] 시스템 라이트/다크 모드 어느 쪽에서도 다이얼로그·스낵바·패널 텍스트 식별 가능
- [ ] 글꼴 크기 1.3x / 1.6x 에서 타이틀·HUD·정거장·상점·다이얼로그 깨짐 없음 (또는 의도된 상한)
- [x] 하드코딩 색상은 디자인 토큰(`lib/ui/tokens.dart`, `common.dart`) 경유 — 다크 고정 ThemeData `lib/main.dart:86`
- [x] 글자 배율 상한 1.3배 `lib/main.dart:101-103` (1.6x는 의도된 상한으로 1.3x에 고정)

## B. 반응형 / 태블릿
- [ ] 폰 / 태블릿(>=600dp, iPad 13") 핵심 플로우 수행 가능
- [x] 방향 정책(세로 고정 여부)과 iPad 멀티태스킹 설정(`UIRequiresFullScreen`) 일치 — 설정에서 자동/세로/가로, `UIRequiresFullScreen=true`, iPad 4방향 (2026-10-11)
- [ ] 가로 모드: Android Note9 실기기 확인됨. **iPad 가로 실화면 미확인** (`test/landscape_layout_test.dart` 1366x1024만 통과)
- [ ] 노치/홈 인디케이터 안전 영역 침범 없음

## C. 사용자 여정 (실기기/시뮬레이터)
- [ ] C1 첫 실행: 데이터 초기화 상태 → 새 게임 → 오프닝 → 튜토리얼 → 첫 목표
- [ ] C2 핵심 루프: 소행성/해적 → 화성 정착 → 건물 → 함선 강화 → 다음 항성계
- [ ] C3 세션 복구: 강제 종료 후 이어하기 — 크레딧/식민지/젬 유지, 오프라인 수익 정상
- [ ] C4 결제(테스트 모드): 젬 구매, 부족 크레딧 젬 충전, HUD 교환, 스타터팩 1회 한정, 구매 복원
  - iOS 빌드 4 (iPad TestFlight 샌드박스): `gems_100` 493→593, `starter_pack` +300·보유, `premium_pass` 보유 — 재실행 후 유지 ✅
  - iOS 재설치 후 복원: 진행 중 / Android Play 테스트 구매: **미확인**
- [ ] C5 광고: 보상형 광고 로드/시청/보상, 실패 시 안내
- [ ] C6 설정: 언어 전환 즉시 반영, 사운드/알림 토글, 개인정보 요약, 피드백 보내기
- [ ] C7 데이터 초기화(계정 삭제 대체): 확인 후 전부 삭제
- [ ] Android + iOS 각각 결과 기록
- [ ] 실패 시 재현 절차 + 로그 + 스크린샷

## D. 보안
- [x] 토큰/개인정보 로그 노출 없음 (`debugPrint` 는 오류 메시지만) — 15곳 전수 확인 2026-10-11
- [x] secret/API key 하드코딩 없음 (AdMob ID 는 공개값) — RevenueCat 키 `--dart-define`, Supabase anon 키는 공개용. `.env`·`.p8`·`.jks`·`key.properties`·`play-store-key.json` 모두 `git check-ignore` 확인
- [x] `http://` 평문 / TLS 우회 / 위험 WebView 없음 — `lib/` 0건
- [x] 릴리즈 빌드에서 디버그 전용 기능(치트·DevMonetization) 접근 불가 — `lib/services/monetization.dart:90-92`

## E. 결제 / 가격 / 광고 정책
- [x] **영수증 서버 검증** — 현재 클라이언트 지급(`monetization.dart` TODO). 표준: RevenueCat (`~/.claude/IN_APP_PURCHASE.md`) — `454aae3`에서 RevenueCat 적용, 검증 후 거래 ID 단위 1회 지급
- [x] 복원 시 중복 지급 없음 (스타터팩 `starterBought` 가드, 소모성은 복원 대상 아님) — 빌드 3 이중 지급 `053ebe0`에서 수정, `test/purchase_grant_test.dart` 7건
- [ ] pending 결제 처리, `completePurchase` 호출
- [ ] 스토어 가격 = 앱 표기 = `docs/STORE_RELEASE.md` 표 (₩1,200 / ₩5,900 / ₩12,000 / ₩3,900 / ₩6,500)
- [x] **광고 동의(UMP/GDPR)** 수집 및 철회 경로 (설정 화면) — `lib/ui/meta_screens.dart:234`
- [ ] iOS ATT / SKAdNetwork / PrivacyInfo.xcprivacy
- [ ] 대상 연령 13세 이상(아동 대상 아님) 결정과 일치: AdMob 아동 태그 없음, 최대 광고 등급 T, 릴리즈 APK에 `com.google.android.gms.permission.AD_ID` 포함, 개인정보처리방침·앱 내 요약·Play 데이터 보안 양식 일치
- [x] 확률형 아이템: 항목별 확률 게임 내 상시 공개 (한국 게임산업법) — `lib/ui/station_panel.dart:378`, `lib/ui/shop_screen.dart:325`
- [ ] 오인 클릭 유도 UI 없음 (보상형 광고는 사용자 선택으로만)
- [x] App Store IAP metadata: 심사용 스크린샷 ≠ 프로모션 이미지, 앱 아이콘 재사용 금지, promotion 안 하면 프로모션 이미지 삭제 — IAP 5개 READY_TO_SUBMIT + 심사 스크린샷
- [ ] **첫 IAP 5개를 버전 1.0 심사 제출 묶음에 포함** (`APP_REVIEW_REJECTIONS.md` 2.1(b))
- [ ] Google RTDN 연결 (선택, 출시 후)

## F. 다국어 완전성
- [x] 사용자 노출 문자열 sink 전수 스캔 (Text/TextSpan/라벨/툴팁/스낵바/다이얼로그/알림/CustomPainter TextPainter) — 하드코딩 0건 (2026-10-11)
- [x] ARB 키 커버리지: ko 기준 10개 언어 키·플레이스홀더 일치, 빈 값 없음 — 820키 누락 0 (`nickGenders` 빈 값은 의도)
- [ ] 결제·확률·개인정보 문구 번역 정확
- [ ] 네이티브 문자열(앱 이름, iOS 권한 설명 InfoPlist.strings, 알림 채널명)

## G. 플랫폼 공통 출시 준비
- [x] Android + iOS 릴리즈 빌드 성공 — 1.0.0 (4) TestFlight / Play 내부 테스트
- [ ] 버전/빌드 번호 (최초 1.0.0+1)
- [ ] targetSdk 최신 요건, 권한 목록(INTERNET, POST_NOTIFICATIONS, AD_ID) 사유 확인
- [x] 업로드 키(keystore) 생성·백업, `key.properties` git 제외 — `git check-ignore` 확인
- [ ] Fastlane 설정 (Android internal draft / iOS TestFlight) — 직접 `flutter build ipa` 업로드 금지
- [ ] 릴리즈 노트 / 롤백 계획 / 크래시 모니터링

## H. First Release (APP_STORE_AUTOMATION.md)
- [ ] `docs/release_info/star_settlers.yaml`
- [ ] 개인정보처리방침 URL: `https://rumururu.github.io/mkideabox/star_settlers/privacy.html` (계정 없음 → 계정삭제 URL 불필요, 데이터 삭제 안내 포함)
- [ ] Play Console: 앱 생성, 접근성, 광고 Yes, 콘텐츠 등급, 타겟 연령, 데이터 보안, 카테고리/연락처, 정부/금융/건강 No
- [ ] App Store Connect: 앱 생성, 설명/키워드/지원 URL/마케팅 URL/저작권/심사 연락처, IAP 등록
- [x] 인앱 상품 5종 양 스토어 등록 (ID 일치) — ASC 5개 READY_TO_SUBMIT, Play 5개 활성, RevenueCat offering 5개
- [ ] 스토어 에셋: `docs/release_assets/final/locales/<locale>/` (10개 언어 폰·태블릿·그래픽 이미지)
- [ ] AdMob: 스토어 연결, `app-ads.txt` 게시

## 스토어 캡처 규칙 (프로젝트)
- 폰 1320x2868, 태블릿 2064x2752 세로. 생성기 `docs/release_assets/tools/generate_store_assets.py`
- 한국어 세트는 HTML 검수 후 승인, 다른 언어는 자체 점검
