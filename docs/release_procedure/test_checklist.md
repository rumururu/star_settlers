---
slug: release-test-checklist
status: canonical
---

# 출시 테스트 체크리스트 — 우주 개척단 (Star Settlers)

- 기준: `~/.claude/flutter-release-guides/test_checklist.md`(베이스) + `Flutter_Codex_Pre_Release_Audit_Runbook.md`(Gate 오버레이)
- 릴리즈: **First Release** v1.0.0+1 (`com.newpl.star_settlers`)
- 판정·증적 기록: `docs/release_procedure/PRE_RELEASE_AUDIT.md`
- 테스트는 사용자 여정 단위. 증적(로그/스크린샷/재현절차) 없는 통과 금지.

## 앱 기능 프로필

| 항목 | 값 | 근거 |
|---|---|---|
| 광고 | 있음 — AdMob 보상형만 (사용자가 직접 선택) | `lib/services/ads.dart` |
| 인앱결제 | 있음 — 젬 소모성 3종, 스타터팩·사령관 패스 비소모성 | `lib/services/monetization.dart` |
| 확률형 아이템 | 있음 — 승무원 영입 | 정거장 → 승무원 탭 확률 표기 |
| 계정/로그인 | 없음 (오프라인, 기기 내 저장) | 계정 삭제 시나리오 → "데이터 초기화"로 대체 |
| 커뮤니티 | 없음 | — |
| 다국어 | 10개 (ko en ja zh es fr de pt ru id) | `lib/l10n/app_*.arb` |
| 테마 | 다크 고정 게임 UI | — |

## A. UI / Theme / 가독성
- [ ] 시스템 라이트/다크 모드 어느 쪽에서도 다이얼로그·스낵바·패널 텍스트 식별 가능
- [ ] 글꼴 크기 1.3x / 1.6x 에서 타이틀·HUD·정거장·상점·다이얼로그 깨짐 없음 (또는 의도된 상한)
- [ ] 하드코딩 색상은 디자인 토큰(`lib/ui/tokens.dart`, `common.dart`) 경유

## B. 반응형 / 태블릿
- [ ] 폰 / 태블릿(>=600dp, iPad 13") 핵심 플로우 수행 가능
- [ ] 방향 정책(세로 고정 여부)과 iPad 멀티태스킹 설정(`UIRequiresFullScreen`) 일치
- [ ] 노치/홈 인디케이터 안전 영역 침범 없음

## C. 사용자 여정 (실기기/시뮬레이터)
- [ ] C1 첫 실행: 데이터 초기화 상태 → 새 게임 → 오프닝 → 튜토리얼 → 첫 목표
- [ ] C2 핵심 루프: 소행성/해적 → 화성 정착 → 건물 → 함선 강화 → 다음 항성계
- [ ] C3 세션 복구: 강제 종료 후 이어하기 — 크레딧/식민지/젬 유지, 오프라인 수익 정상
- [ ] C4 결제(테스트 모드): 젬 구매, 부족 크레딧 젬 충전, HUD 교환, 스타터팩 1회 한정, 구매 복원
- [ ] C5 광고: 보상형 광고 로드/시청/보상, 실패 시 안내
- [ ] C6 설정: 언어 전환 즉시 반영, 사운드/알림 토글, 개인정보 요약, 피드백 보내기
- [ ] C7 데이터 초기화(계정 삭제 대체): 확인 후 전부 삭제
- [ ] Android + iOS 각각 결과 기록
- [ ] 실패 시 재현 절차 + 로그 + 스크린샷

## D. 보안
- [ ] 토큰/개인정보 로그 노출 없음 (`debugPrint` 는 오류 메시지만)
- [ ] secret/API key 하드코딩 없음 (AdMob ID 는 공개값)
- [ ] `http://` 평문 / TLS 우회 / 위험 WebView 없음
- [ ] 릴리즈 빌드에서 디버그 전용 기능(치트·DevMonetization) 접근 불가

## E. 결제 / 가격 / 광고 정책
- [ ] **영수증 서버 검증** — 현재 클라이언트 지급(`monetization.dart` TODO). 표준: RevenueCat (`~/.claude/IN_APP_PURCHASE.md`)
- [ ] 복원 시 중복 지급 없음 (스타터팩 `starterBought` 가드, 소모성은 복원 대상 아님)
- [ ] pending 결제 처리, `completePurchase` 호출
- [ ] 스토어 가격 = 앱 표기 = `docs/STORE_RELEASE.md` 표 (₩1,200 / ₩5,900 / ₩12,000 / ₩3,900 / ₩6,500)
- [ ] **광고 동의(UMP/GDPR)** 수집 및 철회 경로 (설정 화면)
- [ ] iOS ATT / SKAdNetwork / PrivacyInfo.xcprivacy
- [ ] 아동 대상 여부 결정 → AdMob 아동 태그·최대 광고 등급 설정과 일치
- [ ] 확률형 아이템: 항목별 확률 게임 내 상시 공개 (한국 게임산업법)
- [ ] 오인 클릭 유도 UI 없음 (보상형 광고는 사용자 선택으로만)
- [ ] App Store IAP metadata: 심사용 스크린샷 ≠ 프로모션 이미지, 앱 아이콘 재사용 금지, promotion 안 하면 프로모션 이미지 삭제

## F. 다국어 완전성
- [ ] 사용자 노출 문자열 sink 전수 스캔 (Text/TextSpan/라벨/툴팁/스낵바/다이얼로그/알림/CustomPainter TextPainter)
- [ ] ARB 키 커버리지: ko 기준 10개 언어 키·플레이스홀더 일치, 빈 값 없음
- [ ] 결제·확률·개인정보 문구 번역 정확
- [ ] 네이티브 문자열(앱 이름, iOS 권한 설명 InfoPlist.strings, 알림 채널명)

## G. 플랫폼 공통 출시 준비
- [ ] Android + iOS 릴리즈 빌드 성공
- [ ] 버전/빌드 번호 (최초 1.0.0+1)
- [ ] targetSdk 최신 요건, 권한 목록(INTERNET, POST_NOTIFICATIONS, AD_ID) 사유 확인
- [ ] 업로드 키(keystore) 생성·백업, `key.properties` git 제외
- [ ] Fastlane 설정 (Android internal draft / iOS TestFlight) — 직접 `flutter build ipa` 업로드 금지
- [ ] 릴리즈 노트 / 롤백 계획 / 크래시 모니터링

## H. First Release (APP_STORE_AUTOMATION.md)
- [ ] `docs/release_info/star_settlers.yaml`
- [ ] 개인정보처리방침 URL: `https://rumururu.github.io/mkideabox/star_settlers/privacy.html` (계정 없음 → 계정삭제 URL 불필요, 데이터 삭제 안내 포함)
- [ ] Play Console: 앱 생성, 접근성, 광고 Yes, 콘텐츠 등급, 타겟 연령, 데이터 보안, 카테고리/연락처, 정부/금융/건강 No
- [ ] App Store Connect: 앱 생성, 설명/키워드/지원 URL/마케팅 URL/저작권/심사 연락처, IAP 등록
- [ ] 인앱 상품 5종 양 스토어 등록 (ID 일치)
- [ ] 스토어 에셋: `docs/release_assets/final/locales/<locale>/` (10개 언어 폰·태블릿·그래픽 이미지)
- [ ] AdMob: 스토어 연결, `app-ads.txt` 게시

## 스토어 캡처 규칙 (프로젝트)
- 폰 1320x2868, 태블릿 2064x2752 세로. 생성기 `docs/release_assets/tools/generate_store_assets.py`
- 한국어 세트는 HTML 검수 후 승인, 다른 언어는 자체 점검
