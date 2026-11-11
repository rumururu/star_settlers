---

## 2026-11-11 Android 프로덕션 출시 신청 완료 — 1.0.9(16)

- 내용(surface-exploration, `docs/agent-collaboration/surface-exploration/`): 행성 지표 탐험(착륙 탐사 — 정원·사막·얼음·용암 지형, 지점 5곳, 산소 150초, 귀환 100%/산소·격추 50%, 행성 영구 발견 광맥·둥지 소탕·완전 탐사, 하루 온전 보상 3회), 도감 유물 탭(8종), Gemini 그림 25장+아이콘 2개, 작은 폰 세로 HUD 위쪽 묶음 넘침 수정(1.0.8부터, 339×697dp ×1.3에서 24px).
- 서버: `20261111000000_starset_events_v3.sql`(허용 28종, surface_start/surface_end) — 배포 스크립트 `supabase/tests/deploy_events_v3.sh`, 사용자 실행 대기(자동 권한 검사가 운영 배포를 막음). 배포 전에는 두 이벤트만 서버가 버리고 앱 동작은 같다.
- 공개 문서: 개인정보처리방침은 이벤트 이름을 나열하지 않고 '게임 개선 통계' 범위 안이라 변경 없음.
- 사전 조회: production `[15]` → 1.0.9+16. 10개 언어 changelog `16.txt`(기능·지점·발견 이름은 게임 번역과 일치), 모두 500자 이하.
- `fastlane production` EXIT=0, 13:04:55 KST 업로드 성공(AAB 95.8MB). 재조회 production `[16]`. 검토 승인·공개 여부는 별도 미확인.
- 검증: `dart analyze lib test` 0, `flutter test --no-pub` 693 통과. 봇 48판 평균 105.7초·격추 15%. 실기기 SM-G525N(디버그 빌드, 세로, 테스트 저장 후 원래 저장 md5 일치 복구): 착륙 버튼·소개·사막 탐사·유적 발굴·둥지 파괴·귀환·결과·식민지 배지. **제품 미확인**: 유물 획득·도감 유물 탭, 광맥·완전 탐사 정산, 산소 0·격추 결과, 가로 화면, 정원·얼음·용암 지형, 릴리스 빌드 통계 전송.
- iOS: 4.3 거절 대응 전이라 제출하지 않음.
- 커밋: `5570b46`, 이어서 기록 커밋.

## 2026-11-08 Android 프로덕션 출시 신청 완료 — 1.0.8(15)

- 내용(retention-update, `docs/agent-collaboration/retention-update/`): 이탈 지점 측정(`starset_events`, 릴리스 빌드만 전송), 식민지 건물 외형(Gemini 21장), 첫 5분(★3 승무원 확정·해적 부두목·다음 목표 칩), 7일 출석 달력·내일 보상·승무원 원정, 균열 런(주간 균열 순위), 도감(별지도 탐험가 의상·초상화), Gemini 아이콘(도감·균열 런), 크레딧 팩 12000→13500, 세로 HUD 겹침(TASK 007).
- 서버(먼저 배포): `mkideabox-games`에 `20261108000000_starset_events.sql`(events_live 13/13), `…010000_starset_events_v2.sql`(허용 26종), `…020000_starset_rift.sql`(rift_live 20/20, 기존 live.sh 17/17 — 사용자가 `deploy_rift.sh` 직접 실행, 자동 권한 검사가 운영 배포를 막아서).
- 공개 문서: 개인정보처리방침 10개 언어 '게임 개선 통계'·균열 순위·삭제 안내, 시행일 2026-11-08(mkideabox `16d9ac8`, `e4ba8d4`). Play 데이터 보안·App Store 개인정보 라벨은 이미 '앱 상호작용/제품 상호 작용'·'기기 ID' 애널리틱스 목적으로 신고돼 있어 변경 없음(콘솔에서 확인, 수정 안 함).
- 사전 조회: production `[14]` → 1.0.8+15. 10개 언어 changelog `15.txt`(게임 번역 용어와 일치), 모두 500자 이하.
- `fastlane production` EXIT=0, 23:03:24 KST 업로드 성공(AAB 92.3MB). 재조회 production `[15]`. 검토 승인·공개 여부는 별도 미확인.
- 검증: `dart analyze lib test` 0, `flutter test --no-pub` 639 통과. 실기기 SM-N960N(디버그 빌드, 가로): 출석 달력·받기, 균열 런·도감 아이콘, ★3 공개, 부두목 등장·격파, 다음 목표 칩, 화성 Lv.5 건물 6종, 일시정지 메뉴, 도감, 균열 런 소개→전투→카드→포기→결과(테스트 저장 후 원래 저장 바이트 단위 복구). **제품 미확인**: 승무원 원정 패널, 출석 전용 스킨 색, 알림, 세로 방향 실기기, 균열 아이콘 불꽃 버전의 실기기 표시, 릴리스 빌드의 통계 실제 전송.
- iOS: 1.0.0 Apple 4.3 거절 대응(소유자 답변) 전이라 제출하지 않음.
- 커밋: `522c443`, 이어서 버전·기록 커밋.

## 2026-10-25 Android 프로덕션 출시 신청 완료 — 1.0.7(14)

- 내용: 대규모 침공(식민지 3개+, 5분 뒤 첫 침공·이후 6~8분, 경보 20초 → 파도 3번 → 침공 지휘함, 승리 크레딧+젬 5, 퇴각 시 처치 비율 보상·레벨 손실 없음), ru 가로 화면 행동 버튼 38px 넘침 수정(`actionBtn` 라벨 Flexible, Codex).
- 사전 조회: production `[13]` → 1.0.7+14. 10개 언어 changelog `14.txt`(지휘함·젬 용어는 게임 번역과 일치, ru 젬=кристаллы), 모두 500자 이하.
- `fastlane production` EXIT=0, 01:16:02 KST 업로드 성공. 재조회 production `[14]`. 검토 승인·공개 여부는 별도 미확인.
- 검증: `flutter test --no-pub` 481건 통과, `dart analyze` 0. 실기기 M205N: 침공 경보·카운트다운·방향 표시·파도 1/3→3/3(테스트 저장 후 원복), 수정 후 HUD 행동 버튼("화성 관리") 표시 이상 없음. 승리/퇴각 결과 배너·지휘함 근접·ru 실기기 표시는 **제품 미확인**.
- 운영 메모: 확인 중 M205N 임대가 다른 세션(codex)에 있어 `busy`였는데 명령을 이어 붙여 탭 2회가 그 기기로 갔다(가로 화면 범위 밖 좌표, 화면 변화 없음). 이후 임대 결과 확인 후에만 입력한다.
- 커밋: `acb9b17`, 이어서 버전·기록 커밋.

## 2026-10-24 Android 프로덕션 출시 신청 완료 — 1.0.6(13)

- 내용: 특화 전환 UI — 고른 뒤에는 현재 특화와 [✓ 전환]만 보이고, 전환을 눌러야 다른 특화(유료)가 펼쳐진다(사용자가 번갈아 누르다 크레딧을 다 쓴 문제). 식민지 패널·내 식민지 둘 다. ARB `u_specSwitch` 10개 언어.
- 사전 조회: production `[12]` → 1.0.6+13. changelog `13.txt`는 12의 내용 + 전환 안내 한 줄(12가 심사 중일 수 있어 내용 유지). 모두 500자 이하.
- `fastlane production` EXIT=0, 08:04:44 KST 업로드 성공. 재조회 production `[13]`. 검토 승인·공개 여부는 별도 미확인.
- 검증: `flutter test --no-pub` 456건 통과(colony_spec_test 위젯 테스트를 새 동작으로 갱신), `dart analyze` 0. 실기기 M205N(테스트 저장 후 원복): 채굴 선택 → 채굴+[✓ 전환]만 표시 → 전환 시 산업·요새 비용과 함께 펼침·[취소] → 취소 시 접힘.
- 커밋: `8d6ff41`(UI), 이어서 버전·changelog 커밋.

## 2026-10-21 Android 프로덕션 출시 신청 완료 — 1.0.5(12)

- 내용: 진척 기반 레벨 상한(식민지 `min(4 + 최고 도달 항성계, 12)`, 함선 무기·장갑·엔진 4+·스킬 2+), 항성계 특성 6종, 식민지 특화(Lv.5 산업·채굴·요새), 특성별 항성계 두목 6종(원형 두목은 헤이븐 레이저 한 발 0.6% 상한, 태양계 두목은 기존 4%). 작업 기록 `docs/agent-collaboration/gameplay-depth/`.
- 사전 조회: production `[11]` → 1.0.5+12. 10개 언어 changelog `12.txt` 신규(특성·특화 이름은 게임 내 번역과 일치, 기존 사용자용 상한 안내 포함).
- `fastlane production` EXIT=0, 23:39:32 KST 업로드 성공. 재조회 production `[12]`. 검토 승인·공개 여부는 별도 미확인.
- 검증: `flutter test --no-pub` 456건 통과, `dart analyze` 이슈 0. 진행 봇: S1 19.1/20.4/21.2분 사망·본거지 정지 0, S3~S6 무료 8.11일. 실기기(M205N, 테스트 저장 후 원복): 레벨 잠금·해금, 교역로 특성 안내·패널, 약탈 상선 두목(색조·링·이름표), 특화 선택. 나머지 두목 5종·9개 언어는 **제품 미확인**(렌더 하네스·테스트만).
- 로그: 스크래치패드 `fastlane_12.log`(세션 임시). iOS 제출과 커밋은 하지 않았다.

## 2026-10-17 Android 프로덕션 출시 신청 완료 — 1.0.4(11)

- 내용: 후반 적 8종(유도탄 포격선·레이저 함·방패선·드론 모함·유령선·기뢰 부설선·수리선·중장갑 돌격함, 첫 조우 안내 10개 언어), 프리미엄 함선(노바·오로라) 상향, 떠나온 항성계 수입 100%와 비용 배율 재조정(×42, ×1.85), 내 식민지 메뉴(모든 항성계 식민지·정박기 원격 레벨업), 일시정지 메뉴 개편, 블랙홀 스프라이트 교체.
- 사전 조회: production `[10]` → 1.0.4+11. 10개 언어 changelog `11.txt` 신규(함선·메뉴 이름은 게임 내 번역과 일치시킴).
- `fastlane production` EXIT=0, 09:57:41 KST 업로드 성공. 재조회 production `[11]`, `release_status=completed`, `changes_not_sent_for_review=false`. 검토 승인·공개 여부는 별도 미확인.
- 검증: `flutter test` 369건 통과, `dart analyze` 이슈 0. 진행 봇: 첫 4개 항성계 무료 5.0일(이전 4.8), S6 사망 기본 9·오로라 1. 실기기: M205N에서 내 식민지(현재 항성계)·정박기 효과 줄, F966N에서 새 일시정지 메뉴 확인. 후반 적·원격 식민지 행은 **제품 미확인**(렌더 하네스·테스트만).
- 로그: 스크래치패드 `play-production11.log`(세션 임시). iOS 제출은 진행하지 않았다.

## 2026-10-17 Android 프로덕션 출시 신청 완료 — 1.0.3(10)

- 내용: 항성계별 하늘(의인화 항성 10종, 쌍성 공전, 항성계별 배경·성운·별 배치), 위상 정박기 레벨당 식민지 수입 +10%와 식민지 패널의 다음 레벨 효과 표시, 반물질 접근 감속(정박기 레벨 연동) 제거.
- 사전 조회: production `[9]`, internal `[7]` → 1.0.3+10으로 올림. 10개 언어 changelog `10.txt` 신규 작성(9번은 수정하지 않음).
- `fastlane production` EXIT=0, 08:17:35 KST "Successfully finished the upload to Google Play". 재조회 production versionCodes `[10]`, `release_status=completed`, `changes_not_sent_for_review=false`. 검토 승인·공개 여부는 별도 미확인.
- 검증: `flutter test` 344건 통과, `dart analyze` 이슈 0. 항성계 연출은 렌더 하네스로 30개 섹터 검수(도구 통과). 실기기 M205N은 태양계 태양만 확인 — 다른 항성계·식민지 패널 정박기 효과 줄은 **제품 미확인**.
- 로그: 스크래치패드 `play-production10.log`(세션 임시). iOS 제출은 진행하지 않았다.

## 2026-10-16 Android 프로덕션 출시 신청 완료

- 사용자 지시에 따라 기존 Fastlane `android production`으로 최신 스토리·캠페인·공유 방어막을 포함한 서명 AAB **1.0.2(9)**를 `com.mkideabox.starsettlers`의 production 트랙에 제출했다. 00:38:40 KST Google Play 커밋 성공. `changes_not_sent_for_review=false`, 검토 미전송 재시도 없음.
- 재조회: production 릴리스 `1.0.2`, versionCodes `[9]`, status `completed`. 10개 언어 전체 설명과 버전 9 업데이트 노트를 로컬 원본과 비교해 모두 일치했다. 이 API 상태는 트랙 배포 설정이며 Google 검토 승인이나 모든 사용자에게 공개됐다는 확인과 구분한다.
- 기존 Fastlane의 릴리스 서명·RevenueCat 빌드 설정 유지, AAB 서명 검증 성공. 소스 기준 `d81e054`와 미커밋 변경 포함. 코드 검사는 앞선 전체 338건·추가 대상 검사, N960N 검증 기록 참조. 이번 변경은 버전·마켓 텍스트·production의 텍스트 동시 업로드 설정이다.
- 증거: `evidence/2026-10-16/android-production-9-result.json`, `play-production-9.json`, `android-1.0.2-9-source-hashes.json`. 빌드/업로드 로그 `/tmp/star-play-production9.log`. iOS 제출은 진행하지 않았다.


## 2026-10-16 N960N 공유 방어막 기기 검사

- SM-N960N(Android 10/API 29, 2220×1080 가로), 최신 debug 앱. frun 임대·설치·실행 후 기존 SharedPreferences를 백업하고 별도 테스트 저장으로 일반 이어하기 경로를 사용했다. 테스트 후 원본 바이트 일치 확인 및 임대 해제.
- 디버그 VM에서 실제 실행 중인 월드에 적 탄환을 주입해 자체 방어막 소진 → 공유 방어막 650→550(정박기 300 유지) → 공유 방어막 소진·30초 대기 → 후속 160 피해로 정박기 Lv.2→1, HP140을 확인했다. 게임 루프에서 자연 회복 후 HP150/Lv.1 및 자체 방어막 재가동을 확인했다.
- 헤이븐 피해 후 기능 정지와 자체 방어막 유지, 지원 차단을 확인했다. 정지 중 수리 검사는 테스트 타이머를 120초로 유지한 상태에서 HP140 유지, 이후 타이머 만료를 유도해 연결 재개 및 HP150/Lv.1을 확인했다. 일반 25초 정지 전체를 연속 촬영한 검증은 아니다.
- 첫 디버거 화면 전환 시도는 프레임 오류 때문에 폐기했다. 정상 재실행 뒤 위 검사를 수행했으며 해당 실행 로그에서 Flutter 예외·FATAL EXCEPTION 패턴은 검출되지 않았다. 초기 설치 실패와 느린 ADB 캡처는 재시도로 해결했다. 전체 캠페인·릴리스 성능·iOS 검증으로 확대 해석하지 않는다.
- 증거: `build/relay-review/n960-{combat,damage,recovered,offline-hold,resume-check,final-state}-result.json`, `n960-damage.png`, `n960-offline.png`, `n960-final.png`. 앱 소스 변경 없음. iOS 최신 배포 빌드와 Apple 거절 대응 검토는 여전히 별도다.


## 2026-10-15 헤이븐 공유 방어막

- 정박기 설치 행성과 현지 헤이븐 사이의 에너지선, 행성별 예비 방어막, 양쪽 레벨에 따른 지원 강화, 헤이븐 정지 시 지원 중단을 구현했다. 자체 방어막과 방어막 생성기 효과는 유지한다. 정박기의 잔존 레벨 내 HP만 회복하며 파괴된 레벨은 유료 재건한다.
- 전체 테스트 338건 통과(`/tmp/relay-full-tests.log`). 이후 추가한 폭격·재사용 대기 우회 방지 검사 포함 대상 13건 통과(`/tmp/relay-targeted-final.log`). 건물 설명을 갱신한 뒤 10개 언어의 세로·가로 패널 검사 10건 통과(`/tmp/relay-ui-final.log`).
- 실제 WorldPainter를 사용하는 테스트 하네스에서 연결·지원·지원 중단 상태를 렌더링했다(`build/relay-review/`). 실기기 화면 검증과 구분한다.
- 다른 기기 확인: Android 15(API 35) `emulator-5554`, 2400×1080 가로 화면에서 최신 앱 실행, 테스트 저장 이어하기, 청록색 공유 방어막·헤이븐 연결선·HUD 표시를 확인했다. 식민지 메뉴를 터치해 식민지 Lv.2 및 정박기 Lv.2로 업그레이드하고 공유 방어막 500→650, 정박기 내구도 150→300을 확인했다. 증거: `build/relay-review/device-support.png`, `device-panel.png`, `device-upgraded.png`. 실기기가 아닌 에뮬레이터 검증이며 적 공격·헤이븐 정지의 기기 시나리오는 이번에 실행하지 않았다. 테스트 저장을 제거해 기존 저장이 없던 상태로 돌리고 앱 종료·임대 해제했다.
- F966N 재실행은 연결 목록에 기기가 없어 실패했다(`/tmp/relay-device.log`). 이번 변경의 F966N 설치·플레이 검증은 미완료다. 업로드·제출 없음.

slug: pre-release-audit
status: active
owner: mkideabox
updated: 2026-10-14
---

# Release Pre-Audit Result - v1.0.0 (5) - 2026-10-11

우주 개척단 (Star Settlers) 첫 출시 사전점검 결과다.
기준 문서: `~/.claude/flutter-release-guides/Flutter_Codex_Pre_Release_Audit_Runbook.md`, `~/.claude/APP_REVIEW_REJECTIONS.md`.
항목별 체크 상태는 `docs/release_procedure/test_checklist.md`에 있다.

## 2026-10-15 캠페인 추가 검증

- 오파츠 헤이븐 코어의 외계 제작자·에너지 유출 설정을 기존 항성계 순서에 배치했다. 주요 도착 장면은 1·5·8·12·16·20·22·25·26구역이며 기존 장면 뒤에 한 번씩 저장·표시된다. 최종 구역 26에서 정박기망 완성, 20초 함선 동기화, 전용 수호체 격파, 중계기 역송신을 직접 수행한다. 기존 방문 항로는 소급 잠그지 않는다.
- 캠페인 통합 전체 테스트 325건 통과(`/tmp/haven-campaign-fulltests.log`). 이후 최종전 보호·강화와 피격 검증을 추가했으므로 최신 전체 테스트 결과로 혼동하지 않는다. 최종 캠페인·UI·스토리 대상 64건 통과(`/tmp/haven-campaign-final-tests.log`), 최종전 변경 포함 캠페인·기존 진행 밸런스 22건 통과(`/tmp/haven-campaign-combat-tests.log`). 최종 정적 분석 문제 없음(`/tmp/haven-campaign-final-analyze.log`).
- 실제 Flutter 웹 빌드에서 별도 준비한 후반 QA 저장으로 Kepler-90 도착, 동기화 33%와 완료 후 수호체 단계, 역송신 파동, 엔딩을 확인했다. `build/campaign-qa/`에 원본 화면·녹화·오류 목록이 있다. 초기 QA 저장의 낮은 장비로 격추된 뒤 합법적 최대 장비 저장과 동기화 보호 구현으로 다시 확인했다. 이 기록은 태양계부터 26구역까지 자연 진행하거나 최종 수호체를 수동 전투로 격파한 기록이 아니다. 전용 수호체 격파 판정은 실제 탄환 충돌을 포함한 모델 테스트로 검증했다.
- 최신 캠페인의 네이티브 기기 여정, 26구역 전체 자연 진행의 난이도, 새 IPA 빌드/업로드/제출은 미확인·미실행이다. 기존 빌드 7 심사 답변과 배포 상태는 아래 기록을 유지한다.

## 2026-10-14 현재 상태 (이전 감사 기록과 구분)

- App Store Connect API 읽기 전용 확인: 앱 `6821474077`, 버전 1.0.0 **REJECTED**, 심사 `ee05f8ff-27ee-4965-9f06-d1fc3d5d38eb`의 최신 빌드 7은 **UNRESOLVED_ISSUES**. Apple은 [Guideline 4.3](https://developer.apple.com/app-store/review/guidelines/#spam) 및 4.2.6 관련 질문 9개에 먼저 답하고 재제출하지 말라고 안내했다. 답변 초안은 `evidence/2026-10-14/apple_reply_4.3_draft.txt`; 소유자 확인 전 제출 불가. 답변이나 새 빌드 제출·업로드는 하지 않았다.
- 새 헤이븐 서사와 첫 송신은 **로컬 미제출 변경**이다. 거절된 빌드 7의 기능으로 설명하지 않는다. 첫 정착은 어느 행성에서나 한 번 발생한다. 첫 안정화 기기 건설 후 `firstTransmission` 2페이지(기기 성공 → 지구 학교 재개 서사), `OpeningCinematic`의 첫 정착 3페이지·첫 송신 4/5페이지를 사용한다. 기존 저장·원격 섹터 이력은 사건을 소급 재생하지 않으며, 마지막 기기 건설로 즉시 완료되면 첫 송신 뒤 첫 워프를 대기열에 둔다. 지구 상태 수치 시뮬레이션은 없다.
- 2026-10-15 반물질 접근 모델 포함 전체 테스트 298건 통과(`/tmp/haven-approach-fulltests.log`). 이후 4장면·과학자 미나·위상 정박기·단절단 변경의 대상 테스트 56건 통과(`/tmp/haven-phase-tests.log`), 지구 학회 대사 변경 이야기 테스트 35건 통과(`/tmp/haven-conference-tests.log`). 전체 테스트 이후 변경을 구분한다. 정적 분석 문제 없음(`/tmp/haven-phase-analyze.log`).
- Android SM M205N에서 이전 오프닝과 게임플레이를 확인하고 저장을 복원·기기 임대를 해제했다. 현재 지구 학회 4장면과 방향 전환은 최신 실기기 미검증이다. iPhone 17 Pro Max 시뮬레이터에서는 앱 실행만 확인했다. 현재 웹 게임의 1280×720 및 844×390에서 태양계 천체·지도·상태창을 확인했으며 브라우저 오류는 없었다.
- 로컬 `1.0.1+8` IPA Fastlane 빌드는 프로비저닝 수정 뒤 성공했다(`/tmp/star-haven-ipa-build-final.log`). 이 IPA는 최신 오프닝·접근 모델 변경 전 산출물이므로 현재 배포 후보로 보지 않는다. 업로드·제출 없음. 아래 과거 **GO** 판정은 이번 거절 건의 출시 판정이 아니다.

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
> **1.0.1 (8) — 클라우드 백업**
> - 2026-10-14: Android 1.0.0(7) 공개 확인 후 1.0.1(8)을 Play 프로덕션에 올림(검토 중). 업데이트 안내 10개 언어 `android/fastlane/metadata/android/*/changelogs/8.txt`.
> - iOS 1.0.1은 1.0.0 심사 통과 뒤에: ASC 1.0.1 버전 생성 + Game Center 버전 연결 + 업데이트 문구 + `fastlane release` + 심사 신청.
> - `lib/services/cloud_backup.dart`: Play 게임즈 저장 게임 / Game Center 저장 게임(iCloud)에 프로필+월드+설치 ID 백업. 복원하면 설치 ID가 돌아와 서버 지갑·RevenueCat 사용자가 따라온다. 자동 백업은 그 기기에서 백업·복원을 한 번 한 뒤에만(새 기기에서 연결만 하고 덮어쓰기 방지), 10분 간격.
> - Play Games 서비스(2026-10-13 게시 완료): 프로젝트 ID `1080311738151`(GCP `star-settlers`), 저장된 게임 사용, Android OAuth 클라이언트 2개(Play 앱 서명 SHA-1 `FF:76:A5:…:E6:F8`, 디버그 키 `6E:82:25:…:2E:12`), 테스터 = 내부 테스트 트랙 + ru***. 설명(en-US)·아이콘·그래픽·카테고리(시뮬레이션) 입력.
> - iOS: App ID에 GAME_CENTER·ICLOUD 켬, iCloud 컨테이너 `iCloud.com.mkideabox.starsettlers` 등록·App ID에 연결, `ios/Runner/Runner.entitlements`. ASC Game Center 사용 설정(gameCenterDetail) 완료 — 1.0.1 버전을 만들 때 그 버전에도 Game Center를 붙인다. 디버그 빌드(xcodebuild, 자동 서명) 통과. 배포 프로필은 App ID 변경으로 무효가 되어 다음 `fastlane release`에서 sigh가 새로 만든다.
> - GCP OAuth 동의 화면을 프로덕션으로 게시(테스트 상태에서는 403 access_denied — 저장된 게임이 Drive 앱 데이터 범위를 쓰기 때문). 홈페이지·개인정보처리방침 링크 = privacy.html, 승인된 도메인 rumururu.github.io, 로고 없음(로고를 넣으면 인증 심사 필요).
> - 실기기 Android (2026-10-13, SM M205N, 디버그 빌드, rumururu 계정): 앱 시작 때 Play 게임즈 프로필 선택 → 권한 동의(Play 게임즈 활동, Drive 앱 데이터) → 새 게임(크레딧 155.87) → 설정 '지금 백업' → 앱 삭제·재설치(진행 없음) → '백업에서 복원' 확인창(10:21 백업) → 복원 → 이어하기 활성, 크레딧 155·광석 20 그대로, 오프라인 수입 2분. 고친 것: 실패한 백업이 시각을 바꾸던 문제, 자동 로그인 때 플레이어 이름 미표시.
> - 실기기 iOS 클라우드 백업 (2026-10-13, iPad Pro 11 M4, 개발 서명 release 빌드, 공용 XCUITest 드라이버로 조작): 새 게임(크레딧 137) → 설정 '클라우드 백업' 탭 → Game Center 연결('밝은 렌즈3') → 지금 백업(23:13) → 앱 삭제·재설치 → 연결하자 '23:13에 저장한 백업이 있어요' 확인창 → 복원 → 이어하기 활성 → 게임: 크레딧 162(137+2분 수입)·광석 20, 오프라인 수입 창.
> - 실기기 iOS 결제 (같은 날, TestFlight 빌드 7): `gems_100` 거래 `2000001250547108`(SANDBOX) → 서버 지갑 5→105, 앱 105 / 배치 슬롯 100젬 → 서버 105→5, 슬롯 3→4 / 앱 삭제 → TestFlight 재설치 → 구매 복원 → 새 지갑 10(옮겨 온 5 + 출석 5), 이전 지갑 0.
> - iOS 스타터 팩·패스는 이 샌드박스 계정이 10/11(서버 지갑 전 빌드)에 이미 사서 새로 살 수 없음 — 비소모품이라 App Store가 결제창 없이 성공을 돌려주고, RevenueCat이 옛 익명 고객을 새 설치 ID와 묶음. 서버 지갑 이전 구매라 서버에는 기록 없음(출시 전 테스터만 해당). 스타터 팩·패스의 서버 지급은 Android 실결제로 확인됨.
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


### 시나리오 기반 지역 작전 연결

- 주요 지역 1·5·8·12·16·20·22·25는 도착 대사 대신 실제 송신 시험, 전용 습격대 방어, 현장 측정과 기지 대조, 지휘선 처치 및 잔해 회수, 유적 조사, 경로 관측, 자동제어 분리 시험을 요구한다.
- 작업 6초, 이탈·사망·일시정지·필수 장치 손상 시 정지. 단계·진행률·전용 적 처치 수·잔해 위치 저장. 새 항로는 망 100% 및 작전 완료 필요. 기존 방문 항로 보존.
- 최종 역송신 파동 후 전용 역공 그림 → 엔딩 연결. 완료 전 HUD에는 반전 제목 대신 지역명과 현재 행동을 표시한다.
- 전체 테스트 334개 통과 (`/tmp/haven-play-fulltests-final.log`). 조사·전투·저장·이행·기존 경제·무료/유료 6지역 진행 포함. 일반 전투 비교 fixture는 이미 정복한 지역으로 설정해 캠페인 습격과 구분하며, 실제 진행 봇은 지역 작전을 수행한다.
- `flutter analyze --no-pub` 통과. 웹 빌드 성공. 준비된 QA 저장으로 844×390 웹에서 시리우스 전용 적, 케플러-90 조사 버튼/진행/결과, 안드로메다 분리 시험/결과, 역공 그림/엔딩 확인. 캡처 `build/campaign-play-qa/`, 브라우저 오류 없음.
- 전체 테스트 중 드러난 타이틀 세로 Column 높이 초과는 로고의 유연한 높이 제한으로 수정했다.
- 한계: 실제 휴대폰 실행 및 신규 저장부터 최종 지역까지 자연 플레이 완주는 미검증. 위 QA 저장은 장비·정박기망을 갖춘 상태이며 실제 플레이 시간의 증거가 아니다.


### 반물질 지구 위치·초반 적 정체 수정
- 화면에 고정된 패럴랙스 배치를 제거하고 반물질 지구를 행성과 같은 월드 좌표 변환으로 표시. 시야 밖 본체는 표시하지 않고 미니맵 표식 유지.
- 전투 화자 이름은 명령 기록 확보 전 ‘발신자 불명’, 이후 ‘단절단’. 매복·습격·초반 전투 안내를 송신망 공격 설정에 맞춰 10개 언어 수정.
- 실제 WorldPainter 래스터 결과에서 카메라가 400 이동하면 천체 픽셀이 반대 방향으로 400 이동하는 회귀 검사 포함, 관련 48개 테스트 통과 (`/tmp/haven-follow-tests.log`).
- frun으로 F966N 수정본 재실행. 실제 게임 화면에서 기존 화면 고정 천체가 사라지고 미니맵 위치가 유지되는 상태 확인 (`build/f966n-review/after-fix-gameplay.png`).
