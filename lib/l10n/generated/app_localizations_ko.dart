// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class L10nKo extends L10n {
  L10nKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '우주 개척단';

  @override
  String get languageName => '한국어';

  @override
  String get u_tabShip => '함선';

  @override
  String get u_tabStation => '정거장';

  @override
  String get u_tabCrew => '승무원';

  @override
  String get u_tabMission => '임무';

  @override
  String get u_tabMarket => '시장';

  @override
  String u_upWeapon(int dmg) {
    return '공격력 $dmg · Lv.3 2연발 · Lv.6 3연발';
  }

  @override
  String u_upHull(int hp) {
    return '최대 체력 $hp';
  }

  @override
  String u_upEngine(int speed) {
    return '최고 속도 $speed';
  }

  @override
  String get u_upMissileIntro => '적을 추적하는 미사일 (Q키 / 🚀 버튼)';

  @override
  String u_upMissile(int count, String cooldown) {
    return '$count발 · 쿨타임 $cooldown초';
  }

  @override
  String get u_upShieldIntro => '모든 피해를 막는 실드 (F키 / 🛡 버튼)';

  @override
  String u_upShield(String duration, String cooldown) {
    return '$duration초 · 쿨타임 $cooldown초';
  }

  @override
  String get u_upDroneIntro => '곁을 돌며 자동으로 쏘고 아이템을 끌어와요';

  @override
  String u_upDrone(int dmg, String interval) {
    return '피해 $dmg · $interval초마다 발사';
  }

  @override
  String u_upMagnet(int range, String power) {
    return '크레딧·광석을 끌어오는 범위 $range · 힘 x$power';
  }

  @override
  String get u_equip => '장착';

  @override
  String get u_hangarSection => '🛸 격납고';

  @override
  String get u_viewLarge => '크게 보기';

  @override
  String get u_hp => '체력';

  @override
  String get u_speed => '속도';

  @override
  String get u_attack => '공격';

  @override
  String get u_fireRate => '연사';

  @override
  String get u_ore => '광석';

  @override
  String get u_crit => '치명타';

  @override
  String get u_boarded => '탑승 중';

  @override
  String get u_board => '탑승';

  @override
  String get u_boardNow => '탑승하기';

  @override
  String get u_gemsOnly => '젬으로만 구매할 수 있어요';

  @override
  String u_unlockOrGems(String condition) {
    return '해금: $condition 또는 젬';
  }

  @override
  String u_unlock(String condition) {
    return '해금: $condition';
  }

  @override
  String u_durability(int hp, int max) {
    return '내구도 $hp / $max';
  }

  @override
  String get u_habitat => '거주구역';

  @override
  String u_habitatDesc(String rate, int hp) {
    return '수입 💰$rate/s · 내구도 $hp';
  }

  @override
  String get u_turret => '방어포탑';

  @override
  String get u_turretIntro => '해적을 자동으로 요격해요';

  @override
  String u_turretDesc(int dmg, int range) {
    return '피해 $dmg · 사거리 $range';
  }

  @override
  String get u_baseUpgrade => '본거지 강화';

  @override
  String u_baseDesc(int dmg, int range, int hp) {
    return '레이저 $dmg · 사거리 $range · 내구도 $hp';
  }

  @override
  String u_disabledSec(int sec) {
    return '기능 정지 $sec초';
  }

  @override
  String u_sectorStatus(String sector) {
    return '$sector 현황';
  }

  @override
  String u_sectorStats(
    int colonies,
    int planets,
    int stations,
    String mul,
    String other,
  ) {
    return '정착한 행성 $colonies / $planets\n정거장 $stations개\n항성계 보너스: 생산량 x$mul\n다른 항성계 수입: 💰$other/s';
  }

  @override
  String get u_legendaryGet => '🌟 전설 등급! 🌟';

  @override
  String get u_rareGet => '✨ 희귀한 동료! ✨';

  @override
  String get u_newCrew => '새 동료 합류!';

  @override
  String get u_great => '좋아!';

  @override
  String u_crewHeader(int count, int cap, int assigned, int slots) {
    return '승무원 $count/$cap · 배치 $assigned/$slots';
  }

  @override
  String u_recruit(int cost) {
    return '영입 💰$cost';
  }

  @override
  String u_recruitPremium(int cost) {
    return '고급 영입 ⭐$cost';
  }

  @override
  String u_recruitLegendary(int cost) {
    return '🌟 전설 확정 모집 ⭐$cost';
  }

  @override
  String u_recruitOdds(String normal, String premium) {
    return '확률 안내 · 일반 영입: $normal\n고급 영입: $premium\n전설 확정 모집: ★4 100%';
  }

  @override
  String u_slotMax(int n) {
    return '배치 슬롯 MAX ($n)';
  }

  @override
  String u_slotBuy(int price) {
    return '배치 슬롯 +1 ⭐$price';
  }

  @override
  String u_rosterMax(int n) {
    return '정원 MAX ($n)';
  }

  @override
  String u_rosterBuy(int size, int price) {
    return '정원 +$size ⭐$price';
  }

  @override
  String get u_noCrew => '아직 동료가 없어요. 영입해서 함선에 배치해봐요!';

  @override
  String get u_unassign => '해제';

  @override
  String get u_assign => '배치';

  @override
  String get u_dismiss => '방출';

  @override
  String get u_dismissCrewTitle => '승무원 방출';

  @override
  String u_dismissCrewBody(String name) {
    return '$name 떠나보낼까요? 되돌릴 수 없어요.';
  }

  @override
  String get u_missionDeliverHint => '목적지로 이동하세요 (노란 화살표)';

  @override
  String get u_missionBountyHint => '목표를 찾아 처치하세요 (노란 화살표)';

  @override
  String u_reward(String rewards) {
    return '보상 $rewards';
  }

  @override
  String u_activeMissions(int n) {
    return '진행 중 ($n/3)';
  }

  @override
  String get u_noActiveMissions => '진행 중인 임무가 없어요.';

  @override
  String get u_abandon => '포기';

  @override
  String u_missionBoard(int sec) {
    return '임무 게시판 · 새 임무까지 $sec초';
  }

  @override
  String get u_accept => '수락';

  @override
  String get u_priceHigh => '📈 비싸요! 팔 때예요';

  @override
  String get u_priceLow => '📉 싸요… 기다려봐요';

  @override
  String get u_priceNormal => '➡ 보통';

  @override
  String get u_orePrice => '광석 시세';

  @override
  String get u_sell100 => '100개 판매';

  @override
  String get u_sellHalf => '절반 판매';

  @override
  String get u_sellAll => '전부 판매';

  @override
  String get u_marketTip => '시세는 시간에 따라 오르내려요. 비쌀 때 팔면 이득!';

  @override
  String get u_gemExchange => '⭐ 스타젬 교환';

  @override
  String get u_creditPack => '크레딧 꾸러미';

  @override
  String get u_exchange => '교환';

  @override
  String get u_openShop => '⭐ 상점 열기';

  @override
  String u_achievementDone(String title, int gems) {
    return '🏆 업적 달성: $title! 메뉴의 업적에서 ⭐$gems를 받으세요.';
  }

  @override
  String get u_cannotDo => '자원이 부족하거나 지금은 할 수 없어요.';

  @override
  String get u_welcomeBack => '어서 오세요, 선장님!';

  @override
  String u_offlineHm(int h, int m) {
    return '자리를 비운 $h시간 $m분 동안\n식민지가 열심히 일했어요!';
  }

  @override
  String u_offlineM(int m) {
    return '자리를 비운 $m분 동안\n식민지가 열심히 일했어요!';
  }

  @override
  String get u_passOfflineHint => '사령관 패스: 최대 8시간 + 자동 2배';

  @override
  String get u_collect => '받기';

  @override
  String get u_adLoading => '광고를 불러오는 중이에요. 잠시 후 다시 시도해 주세요.';

  @override
  String get u_adLoadingRetry => '광고를 불러오는 중이에요. 잠시 후 다시 눌러주세요.';

  @override
  String get u_collectDouble => '2배로 받기 👑';

  @override
  String get u_adDouble => '📺 광고 보고 2배';

  @override
  String get u_galaxyHonor => '🌌 은하 명예';

  @override
  String u_honorStatus(int honor, int ascensions) {
    return '현재 명예 $honor점 (환생 $ascensions회)';
  }

  @override
  String u_honorBonus(int income, int attack) {
    return '수입 +$income% · 공격력 +$attack%';
  }

  @override
  String get u_ascendExplain =>
      '환생하면 지금 우주(항성계, 식민지, 정거장, 함선 강화, 승무원, 크레딧)가 초기화되고\n대신 영구 보너스인 명예 점수를 받아요.\n젬, 꾸미기, 함선, 업적은 유지돼요.';

  @override
  String u_ascendGain(int gain) {
    return '지금 환생하면 명예 +$gain점!\n(제국 가치가 클수록 많이 받아요)';
  }

  @override
  String get u_ascendLocked => '항성계 4에 도달하면 환생할 수 있어요.';

  @override
  String get u_close => '닫기';

  @override
  String u_ascendBtn(int gain) {
    return '환생 (+$gain)';
  }

  @override
  String get u_ascendConfirmTitle => '정말 환생할까요?';

  @override
  String get u_ascendConfirmBody => '현재 우주가 초기화돼요. 되돌릴 수 없어요.';

  @override
  String get u_ascend => '환생';

  @override
  String u_shieldBroken(String name) {
    return '$name 깨짐';
  }

  @override
  String u_hudSector(String sector, int dev, String threat, String value) {
    return '$sector · 발전 $dev%\n⚠ 위협 $threat  🏛 $value';
  }

  @override
  String u_baseDisabled(int sec) {
    return '본거지 정지 ${sec}s';
  }

  @override
  String u_baseHp(int pct) {
    return '본거지 $pct%';
  }

  @override
  String get u_merchantE => '상인 (E)';

  @override
  String get u_nextSectorE => '다음 항성계 (E)';

  @override
  String get u_prevSectorE => '이전 항성계 (E)';

  @override
  String u_gateLocked(int pct) {
    return '🔒 발전도 100%에서 열려요 ($pct%)';
  }

  @override
  String u_settle(String name) {
    return '$name 정착';
  }

  @override
  String u_manageE(String name) {
    return '$name 관리 (E)';
  }

  @override
  String get u_buildStation => '정거장 건설';

  @override
  String get u_fire => '발사';

  @override
  String get u_equipAtStation => '정거장 함선 개조에서 장착할 수 있어요!';

  @override
  String get u_shotDown => '💥 격추당했습니다!';

  @override
  String u_autoRespawn(int sec) {
    return '$sec초 뒤 기지에서 자동 재출격';
  }

  @override
  String get u_reviveFree => '👑 이 자리에서 부활 (무료)';

  @override
  String get u_reviveAd => '📺 광고 보고 이 자리에서 부활';

  @override
  String get u_reviveGems => '⭐10 으로 이 자리에서 부활';

  @override
  String u_respawnBase(int pct) {
    return '🏠 기지에서 재출격 (크레딧 $pct% 손실)';
  }

  @override
  String get u_spkCaptain => '선장';

  @override
  String get u_spkPirate => '해적';

  @override
  String get u_spkAdvisor => '부관 미나';

  @override
  String get u_spkMerchant => '상인 냥냥';

  @override
  String get u_paused => '일시정지';

  @override
  String u_pauseStats(
    String sector,
    int kills,
    int crew,
    int colonies,
    int stations,
    int missions,
  ) {
    return '$sector · 격추 $kills · 승무원 $crew\n정착 $colonies · 정거장 $stations · 임무 완료 $missions';
  }

  @override
  String get u_resume => '▶︎ 계속하기';

  @override
  String get u_shop => '⭐ 상점';

  @override
  String get u_achievements => '🏆 업적';

  @override
  String get u_dailyQuests => '📅 일일 퀘스트';

  @override
  String get u_myPlanet => '🌍 내 행성';

  @override
  String get u_ascendMenu => '🌌 은하 명예 (환생)';

  @override
  String get u_settings => '⚙ 설정';

  @override
  String get u_saveAndQuit => '💾 저장하고 타이틀로';

  @override
  String get u_keyboardHelp =>
      '키보드: WASD 이동 · Space 사격 · Q 미사일 · F 실드 · Shift 부스트\nE 상호작용 · B 정거장 건설 · Esc 메뉴';

  @override
  String get u_recharging => '재충전 중';

  @override
  String get u_tutDome => '방어막\n안에 있으면 안전';

  @override
  String get u_tutLevelUp => '레벨업\n수입·건물↑';

  @override
  String get u_tutTurret => '포탑';

  @override
  String get u_tutRepair => '수리';

  @override
  String get u_tutRaid => '습격 막기';

  @override
  String get u_gotIt => '알겠어요';

  @override
  String u_damage(int dmg) {
    return '피해 $dmg';
  }

  @override
  String u_oreRate(String rate) {
    return '광석 +$rate/s';
  }

  @override
  String u_incomePct(int pct) {
    return '수입 +$pct%';
  }

  @override
  String u_repairRate(int hp) {
    return '체력 +$hp/s';
  }

  @override
  String u_shieldPlus(int amount) {
    return '방어막 +$amount';
  }

  @override
  String u_systemTitle(String sector, int n) {
    return '$sector · 항성계 $n';
  }

  @override
  String u_systemInfo(String threat, String mul) {
    return '위협 $threat · 자원 배율 x$mul';
  }

  @override
  String u_development(int pct) {
    return '발전도 $pct%';
  }

  @override
  String get u_nextSystemOpen => '다음 항성계 열림';

  @override
  String get u_opensAt100 => '100%에서 열림';

  @override
  String get u_devHint => '모든 행성을 Lv.3까지 키우면 100%';

  @override
  String get u_conqueredSystems => '점령한 항성계 (계속 생산 중)';

  @override
  String get u_unsettled => '미정착';

  @override
  String get u_underRaid => '습격 중';

  @override
  String u_unknownSector(int n) {
    return '미지의 항성계 $n';
  }

  @override
  String u_sectorDev(String name, int pct) {
    return '$name · 발전 $pct%';
  }

  @override
  String get u_buildStationTitle => '정거장 건설 · 역할 고르기';

  @override
  String get u_cost => '비용';

  @override
  String get u_build => '건설';

  @override
  String get u_toNextSector => '🌀 다음 항성계로';

  @override
  String get u_bossLocked => '🔒 두목을 쓰러뜨리면 열림';

  @override
  String get u_toPrevSector => '🌀 이전 항성계로';

  @override
  String get u_raidAlert => '⚠ 습격 중!';

  @override
  String u_rechargePct(int pct) {
    return '재충전 $pct%';
  }

  @override
  String u_merchantLabel(int sec) {
    return '🛒 떠돌이 상인 ($sec초)';
  }

  @override
  String get u_supplyPod => '📦 보급 캡슐';

  @override
  String u_sectorBoss(String sector) {
    return '☠ $sector 두목';
  }

  @override
  String get u_pirateBoss => '☠ 해적 두목';

  @override
  String get u_merchantName => '떠돌이 상인 냥냥';

  @override
  String u_merchantLeaves(int sec, String credits) {
    return '$sec초 뒤에 떠나요 · 💰$credits';
  }

  @override
  String get u_rareCrewOffer => '희귀 동료 소개';

  @override
  String get u_crewSoldOut => '오늘의 동료는 이미 팔렸다냥!';

  @override
  String get u_gemTrade => '젬 환전 (3회 한정)';

  @override
  String u_gemTradeRow(int price, int left) {
    return '💰$price → ⭐5  ($left회 남음)';
  }

  @override
  String get u_convert => '환전';

  @override
  String get u_potions => '강화 물약 (효과 시간 2배)';

  @override
  String get u_notEnoughGems => '젬이 부족해요';

  @override
  String get u_buyConfirmTitle => '구매 확인';

  @override
  String u_buyShipConfirm(String ship, String price) {
    return '$ship에 $price 사용할까요?';
  }

  @override
  String u_shipBought(String ship) {
    return '$ship 획득! 바로 탑승했어요';
  }

  @override
  String get u_premiumShips => '프리미엄 함선';

  @override
  String get u_hangarTitle => '격납고';

  @override
  String u_buyGems(int price) {
    return '⭐$price 구매';
  }

  @override
  String get u_premium => '프리미엄';

  @override
  String get u_ok => '확인';

  @override
  String get u_cancel => '취소';

  @override
  String get m_ok => '확인';

  @override
  String get m_cancel => '취소';

  @override
  String get m_close => '닫기';

  @override
  String get m_claim => '받기';

  @override
  String m_claimGems(int gems) {
    return '⭐$gems 받기';
  }

  @override
  String get m_done => '✅ 완료';

  @override
  String get m_notEnoughGems => '젬이 부족해요';

  @override
  String get m_restorePurchases => '구매 복원';

  @override
  String get m_restoreDone => '구매 내역을 확인했어요';

  @override
  String get m_buyConfirmTitle => '구매 확인';

  @override
  String m_spendGemsConfirm(String price) {
    return '$price 사용할까요?';
  }

  @override
  String get m_loginTitle => '📅 출석 보상';

  @override
  String get m_loginWelcome => '오늘도 와주셨네요, 선장님!';

  @override
  String get m_loginFirst => '어서 오세요, 선장님! 첫 출석 보상이에요.';

  @override
  String get m_loginStreakHint => '7일 연속 출석하면 ⭐50!';

  @override
  String get m_newGameTitle => '새 게임';

  @override
  String get m_newGameBody =>
      '기존 진행 상황이 지워져요.\n(젬, 꾸미기, 업적, 구매 상품은 유지돼요) 계속할까요?';

  @override
  String get m_start => '시작';

  @override
  String get m_loadFailed => '저장 데이터를 불러오지 못했어요.';

  @override
  String m_honorLine(int honor, int income, int attack) {
    return '🌌 은하 명예 $honor점 · 수입 +$income% · 공격 +$attack%';
  }

  @override
  String get m_continue => '이어하기';

  @override
  String get m_newGame => '✨ 새 게임';

  @override
  String get m_menuHome => '내 행성';

  @override
  String get m_menuShop => '상점';

  @override
  String get m_menuQuest => '퀘스트';

  @override
  String get m_menuAchievements => '업적';

  @override
  String get m_menuSettings => '설정';

  @override
  String m_achievementsTitle(int done, int total) {
    return '🏆 업적 ($done/$total)';
  }

  @override
  String get m_dailyTitle => '📅 일일 퀘스트';

  @override
  String m_dailyReset(int hours, int minutes) {
    return '초기화까지 $hours시간 $minutes분';
  }

  @override
  String get m_dailyBonusTitle => '🎁 모두 완료 보너스';

  @override
  String get m_dailyBonusDesc => '오늘의 퀘스트 3개를 모두 받으면';

  @override
  String get m_settingsTitle => '⚙ 설정';

  @override
  String get m_settingsSound => '효과음';

  @override
  String get m_settingsMusic => '배경음악';

  @override
  String get m_settingsNotify => '복귀 알림';

  @override
  String get m_settingsNotifyDesc => '식민지 창고가 가득 차면 알려드려요';

  @override
  String get m_settingsHaptics => '진동';

  @override
  String get m_settingsLanguage => '언어';

  @override
  String get m_languageSystem => '기기 언어 따라가기';

  @override
  String get m_privacyTitle => '개인정보처리방침';

  @override
  String m_privacyBody(String email) {
    return '우주 개척단은 회원가입이 없고 개인을 식별하는 정보를 수집하지 않습니다. 게임 데이터(진행 상황, 재화, 구매 기록, 설정)는 기기 안에만 저장됩니다. 단, 주간 순위표에 직접 참여하면 아래 순위표 정보만 서버로 보냅니다.\n\n결제: Google Play / App Store가 처리하며 결제 수단 정보는 개발자에게 전달되지 않습니다. 구매 확인과 복원에 RevenueCat을 사용하며, 익명 사용자 ID와 구매 내역이 처리됩니다.\n\n광고: 직접 선택할 때만 Google AdMob 보상형 광고가 나옵니다. AdMob은 광고 제공, 허용되는 경우의 맞춤형 광고, 광고 측정을 위해 광고 ID, IP 주소, 기기 정보를 사용할 수 있습니다. 유럽 경제 지역·영국·스위스에서는 처음 실행할 때 동의를 묻고, 설정 → 광고 개인정보 설정에서 바꿀 수 있습니다.\n\n알림: 기기 안에서 예약하는 로컬 알림이며 외부로 전송되지 않습니다.\n\n피드백: 직접 메일을 보낼 때만 내용과 앱 버전·기기 정보가 개발자에게 전달됩니다.\n\n주간 순위표(선택): 설정이나 순위 화면에서 직접 켤 때만 참여하며 기본은 꺼져 있습니다. 보내는 것은 무작위 설치 ID, 게임이 정해진 단어 목록으로 만든 별명, 주간 점수뿐입니다. 이름이나 직접 입력한 글자는 보내지 않고 채팅도 없습니다. 다른 플레이어에게는 별명과 점수만 보입니다. 서버는 Supabase(서울 리전)입니다.\n\n삭제: 설정 → 모든 데이터 초기화로 기기의 데이터를 지울 수 있습니다. 순위표에 참여했다면 초기화할 때 서버의 순위표 기록(설치 ID·별명·점수)도 함께 삭제되며, 메일로 삭제를 요청할 수도 있습니다.\n\n전체 방침: https://rumururu.github.io/mkideabox/star_settlers/privacy.html\n문의: $email';
  }

  @override
  String get m_wipeTitle => '모든 데이터 초기화';

  @override
  String get m_wipeDesc => '진행 상황, 젬, 꾸미기와 순위표 기록이 모두 삭제돼요';

  @override
  String get m_wipeConfirmTitle => '정말 초기화할까요?';

  @override
  String get m_wipeConfirmBody =>
      '되돌릴 수 없어요. 젬과 진행 상황은 영구히 삭제돼요. 스타터 팩과 함대 사령관 패스는 \"구매 복원\"으로 되찾을 수 있어요.';

  @override
  String get m_wipeOk => '초기화';

  @override
  String get m_feedbackTitle => '개발자에게 피드백 보내기';

  @override
  String get m_feedbackDesc => '버그·건의 뭐든 좋아요. 기기와 앱 버전이 자동으로 적혀요.';

  @override
  String m_noMailApp(String email) {
    return '메일 앱이 없어요. $email 으로 보내주세요.';
  }

  @override
  String get m_aboutTitle => 'STAR SETTLERS · 우주 개척단';

  @override
  String m_version(String version) {
    return '버전 $version';
  }

  @override
  String get m_shopTitle => '⭐ 상점';

  @override
  String get m_buyThanks => '구매 완료! 감사합니다 💜';

  @override
  String get m_adLoading => '광고를 불러오는 중이에요. 잠시 후 다시 시도해 주세요.';

  @override
  String m_buyShipConfirm(String ship, String price) {
    return '$ship에 $price 사용할까요?';
  }

  @override
  String m_shipAcquired(String ship) {
    return '$ship 획득! 바로 탑승했어요';
  }

  @override
  String get m_tabGems => '젬 충전';

  @override
  String get m_tabPacks => '패키지';

  @override
  String get m_tabPremiumShips => '프리미엄 함선';

  @override
  String get m_tabSkins => '함선 스킨';

  @override
  String get m_tabOutfits => '선장 의상';

  @override
  String get m_tabFree => '무료 젬';

  @override
  String get m_testMode => '🧪 테스트 모드: 실제 결제 없음 · 광고는 Google 테스트 광고';

  @override
  String get m_owned => '보유 중';

  @override
  String get m_boarded => '탑승 중';

  @override
  String get m_gemsInfo =>
      '젬은 꾸미기, 고급 영입, 즉시 부활, 크레딧 교환에 쓸 수 있어요.\n게임 플레이(업적·출석·두목·보급 캡슐)로도 모을 수 있어요.';

  @override
  String get m_crewSection => '👩‍🚀 승무원 (젬)';

  @override
  String get m_premiumSection => '🛸 프리미엄 함선';

  @override
  String get m_premiumDesc => '젬으로만 얻을 수 있는 특별한 전투기예요. 고유 능력이 있어요.';

  @override
  String get m_viewLarge => '한 장씩 크게 보기';

  @override
  String get m_premiumHangarHint => '격납고(정거장 → 함선 탭)에서도 구매·교체할 수 있어요.';

  @override
  String get m_legendTitle => '전설 승무원 확정 모집';

  @override
  String get m_legendDescNoGame =>
      '★4 전설 승무원 1명 (보너스 20%~ + 모든 생산 +40%, 칭호·금빛 오라)\n게임을 시작한 뒤 구매할 수 있어요';

  @override
  String m_legendDesc(int count, int cap) {
    return '★4 전설 승무원 1명 (보너스 20%~ + 모든 생산 +40%, 칭호·금빛 오라)\n승무원 $count/$cap';
  }

  @override
  String m_crewJoined(String stars, String name) {
    return '$stars $name 합류!';
  }

  @override
  String get m_slotTitle => '배치 슬롯 +1';

  @override
  String m_slotDesc(int slots) {
    return '함선에 동시에 배치할 수 있는 승무원 수 · 현재 $slots';
  }

  @override
  String m_rosterTitle(int n) {
    return '승무원 정원 +$n';
  }

  @override
  String m_rosterDesc(int cap, int max) {
    return '보유할 수 있는 승무원 수 · 현재 $cap (최대 $max)';
  }

  @override
  String m_crewOdds(String odds) {
    return '고급 영입 확률: $odds · 전설 확정 모집: ★4 100%';
  }

  @override
  String get m_equipped => '장착 중';

  @override
  String get m_equip => '장착';

  @override
  String get m_passOnly => '사령관 패스 전용';

  @override
  String get m_starterOnly => '스타터 팩 전용';

  @override
  String get m_adSection => '📺 광고 보고 무료 젬';

  @override
  String m_adInfo(int perDay, int left) {
    return '하루 $perDay회, 1회에 ⭐5 · 오늘 $left회 남음';
  }

  @override
  String get m_adClaimPremium => '⭐5 받기 (사령관 패스: 광고 없음)';

  @override
  String get m_adWatch => '광고 보고 ⭐5 받기';

  @override
  String m_loginStreak(int days) {
    return '연속 출석 $days일째';
  }

  @override
  String m_dayN(int day) {
    return '$day일';
  }

  @override
  String get m_notEnoughResources => '자원이 부족해요';

  @override
  String m_emptyLot(int n) {
    return '빈 땅 #$n · 건물 짓기';
  }

  @override
  String get m_buildInGameOnly =>
      '건설은 게임 중(메뉴 → 내 행성)에 할 수 있어요. 크레딧과 광석은 현재 우주에서 써요.';

  @override
  String m_heldAll(String credits, String ore, int gems) {
    return '보유 💰$credits  💎$ore  ⭐$gems';
  }

  @override
  String m_held(String credits, String ore) {
    return '보유 💰$credits  💎$ore';
  }

  @override
  String m_currentEffect(String effect) {
    return '현재 효과: $effect';
  }

  @override
  String m_nextLevel(String effect) {
    return '다음 레벨: $effect';
  }

  @override
  String m_upgrade(String cost) {
    return '업그레이드 $cost';
  }

  @override
  String get m_maxLevel => '🌟 최대 레벨';

  @override
  String get m_planetName => '행성 이름';

  @override
  String get m_decorateTitle => '🎨 행성 꾸미기';

  @override
  String get m_planetRing => '행성 고리';

  @override
  String get m_giftInGameOnly => '선물은 게임 중에 받을 수 있어요';

  @override
  String get m_giftTitle => '🎁 행성 선물';

  @override
  String m_giftBody(int count) {
    return '주민 $count명이 모은 선물이에요!';
  }

  @override
  String get m_giftThanks => '고마워!';

  @override
  String m_planetStatus(int level, int residents, int built, int slots) {
    return '행성 Lv.$level · 주민 $residents명 · 건물 $built/$slots';
  }

  @override
  String m_permBonus(
    int income,
    int ore,
    int attack,
    int hp,
    int cooldown,
    int offline,
  ) {
    return '영구 보너스 · 수입 +$income%  광석 +$ore%  공격 +$attack%  체력 +$hp%  쿨타임 -$cooldown%  오프라인 $offline%';
  }

  @override
  String get m_planetHint => '행성을 좌우로 밀어 돌리고, 칸을 눌러 건물을 지어요';

  @override
  String get m_giftClaim => '🎁 행성 선물 받기';

  @override
  String m_giftWait(int hours, int minutes) {
    return '🎁 $hours시간 $minutes분 후 선물';
  }

  @override
  String m_planetLevelUp(int level, String cost) {
    return '🌍 행성 Lv.$level (칸 +2) $cost';
  }

  @override
  String get g_shipScoutName => '스카우트';

  @override
  String get g_shipInterceptorName => '인터셉터';

  @override
  String get g_shipFortressName => '포트리스';

  @override
  String get g_shipProspectorName => '프로스펙터';

  @override
  String get g_shipPhantomName => '팬텀';

  @override
  String get g_shipNovaName => '노바 드래곤';

  @override
  String get g_shipAuroraName => '오로라';

  @override
  String get g_shipScoutDesc => '균형 잡힌 기본 함선';

  @override
  String get g_shipInterceptorDesc => '빠르고 연사가 빠르지만 장갑이 얇아요';

  @override
  String get g_shipFortressDesc => '느리지만 단단하고 한 방이 세요';

  @override
  String get g_shipProspectorDesc => '광석 +50%, 아이템을 멀리서 끌어당겨요';

  @override
  String get g_shipPhantomDesc => '25% 확률로 2.5배 치명타';

  @override
  String get g_shipNovaDesc => '탄환이 적을 꿰뚫는 프리미엄 전투기';

  @override
  String get g_shipAuroraDesc => '스스로 고치고 보호막을 두르는 프리미엄 수호선';

  @override
  String get g_shipNovaAbility => '관통탄: 탄환 하나가 적 2기까지 꿰뚫어요';

  @override
  String get g_shipAuroraAbility =>
      '자가 수리: 3초간 피격이 없으면 초당 체력 3% 회복\n수호막: 8초마다 피격 1회 방어';

  @override
  String g_crewLegendPerk(int pct) {
    return '👑 전설 지휘: 모든 생산(크레딧·광석) +$pct% (여러 명이어도 한 번만)';
  }

  @override
  String g_shipCreditBonus(int pct) {
    return '💰 사냥꾼 보너스: 직접 버는 크레딧 +$pct% (현상금·소행성·임무·습격 방어)';
  }

  @override
  String g_unlockSector(int n) {
    return '항성계 $n 도달';
  }

  @override
  String g_unlockBosses(int n) {
    return '해적 두목 $n회 격파';
  }

  @override
  String g_unlockOre(int n) {
    return '광석 $n개 수집';
  }

  @override
  String get g_skinDefault => '기본 스카우트';

  @override
  String get g_skinCrimson => '레드 코멧';

  @override
  String get g_skinMint => '민트 초코';

  @override
  String get g_skinStealth => '스텔스 블랙';

  @override
  String get g_skinNeon => '네온 핑크';

  @override
  String get g_skinRainbow => '무지개 드림';

  @override
  String get g_skinGalaxy => '갤럭시';

  @override
  String get g_skinGold => '골드 로열';

  @override
  String get g_outfitDefault => '기본 우주복';

  @override
  String get g_outfitCat => '냥냥 헬멧';

  @override
  String get g_outfitBunny => '토끼 귀';

  @override
  String get g_outfitAlien => '외계인 더듬이';

  @override
  String get g_outfitFlower => '꽃 핀';

  @override
  String get g_outfitHat => '함장 모자';

  @override
  String get g_outfitCrown => '은하 왕관';

  @override
  String get g_crewRoleGunner => '포수';

  @override
  String get g_crewEffectGunner => '공격력';

  @override
  String get g_crewRoleEngineer => '기관사';

  @override
  String get g_crewEffectEngineer => '최대 체력·수리';

  @override
  String get g_crewRolePilot => '조종사';

  @override
  String get g_crewEffectPilot => '속도';

  @override
  String get g_crewRoleTrader => '상인';

  @override
  String get g_crewEffectTrader => '크레딧 수입';

  @override
  String get g_crewRoleMiner => '광부';

  @override
  String get g_crewEffectMiner => '광석 획득';

  @override
  String get g_crewRoleScientist => '과학자';

  @override
  String get g_crewEffectScientist => '스킬 쿨타임 감소';

  @override
  String get g_crewName0 => '뭉치';

  @override
  String get g_crewName1 => '코코';

  @override
  String get g_crewName2 => '별이';

  @override
  String get g_crewName3 => '두부';

  @override
  String get g_crewName4 => '콩이';

  @override
  String get g_crewName5 => '루루';

  @override
  String get g_crewName6 => '하루';

  @override
  String get g_crewName7 => '포포';

  @override
  String get g_crewName8 => '미미';

  @override
  String get g_crewName9 => '도리';

  @override
  String get g_crewName10 => '몽실';

  @override
  String get g_crewName11 => '나비';

  @override
  String get g_crewName12 => '초코';

  @override
  String get g_crewName13 => '보리';

  @override
  String get g_crewName14 => '구름';

  @override
  String get g_crewName15 => '단비';

  @override
  String get g_crewName16 => '토리';

  @override
  String get g_crewName17 => '해피';

  @override
  String get g_crewName18 => '찹쌀';

  @override
  String get g_crewName19 => '모찌';

  @override
  String get g_crewName20 => '라떼';

  @override
  String get g_crewName21 => '쿠키';

  @override
  String get g_crewName22 => '젤리';

  @override
  String get g_crewName23 => '솜이';

  @override
  String get g_crewName24 => '망고';

  @override
  String get g_crewName25 => '자두';

  @override
  String get g_crewName26 => '호두';

  @override
  String get g_crewName27 => '깜이';

  @override
  String get g_crewName28 => '밤비';

  @override
  String get g_crewName29 => '치즈';

  @override
  String get g_crewLegend0 => '은하수호자';

  @override
  String get g_crewLegend1 => '별의 영웅';

  @override
  String get g_crewLegend2 => '성운의 현자';

  @override
  String get g_crewLegend3 => '혜성 기사';

  @override
  String get g_crewLegend4 => '초신성';

  @override
  String g_crewLegendName(String title, String name) {
    return '$title $name';
  }

  @override
  String get g_bldHouse => '주택';

  @override
  String g_bldHouseEffect(int n) {
    return '주민 +$n명 (선물 증가)';
  }

  @override
  String get g_bldFarm => '우주 농장';

  @override
  String g_bldFarmEffect(int n) {
    return '크레딧 수입 +$n%';
  }

  @override
  String get g_bldMine => '광산';

  @override
  String g_bldMineEffect(int n) {
    return '광석 획득 +$n%';
  }

  @override
  String get g_bldLab => '연구소';

  @override
  String g_bldLabEffect(int n) {
    return '스킬 쿨타임 -$n%';
  }

  @override
  String get g_bldTower => '방어탑';

  @override
  String g_bldTowerEffect(int n) {
    return '최대 체력 +$n%';
  }

  @override
  String get g_bldShipyard => '조선소';

  @override
  String g_bldShipyardEffect(int n) {
    return '공격력 +$n%';
  }

  @override
  String get g_bldPark => '놀이공원';

  @override
  String g_bldParkEffect(int n) {
    return '오프라인 수입 +$n%p';
  }

  @override
  String get g_bldStatue => '선장 동상';

  @override
  String g_bldStatueEffect(int n) {
    return '행성 선물 젬 +$n';
  }

  @override
  String get g_homePalette0 => '초록 정원';

  @override
  String get g_homePalette1 => '모래 사막';

  @override
  String get g_homePalette2 => '얼음 왕국';

  @override
  String get g_homePalette3 => '용암 섬';

  @override
  String get g_homePalette4 => '보라 가스';

  @override
  String get g_homePalette5 => '벚꽃';

  @override
  String get g_homePalette6 => '오로라';

  @override
  String get g_homePalette7 => '황금';

  @override
  String get g_homeDefaultName => '나의 작은 별';

  @override
  String get g_achFirstBloodTitle => '첫 격추';

  @override
  String get g_achFirstBloodDesc => '해적 1척 격추';

  @override
  String get g_achHunterTitle => '해적 사냥꾼';

  @override
  String get g_achHunterDesc => '해적 100척 격추';

  @override
  String get g_achLegendTitle => '전설의 선장';

  @override
  String get g_achLegendDesc => '해적 1000척 격추';

  @override
  String get g_achMinerTitle => '광산왕';

  @override
  String get g_achMinerDesc => '광석 1000개 수집';

  @override
  String get g_achMiner2Title => '광석 부자';

  @override
  String get g_achMiner2Desc => '광석 10000개 수집';

  @override
  String get g_achColonistTitle => '개척자';

  @override
  String get g_achColonistDesc => '행성 5곳 정착';

  @override
  String get g_achMetropolisTitle => '메트로폴리스';

  @override
  String get g_achMetropolisDesc => '식민지 Lv.5 달성';

  @override
  String get g_achBuilderTitle => '건축가';

  @override
  String get g_achBuilderDesc => '정거장 3개 건설';

  @override
  String get g_achBoss1Title => '두목 사냥';

  @override
  String get g_achBoss1Desc => '해적 두목 격파';

  @override
  String get g_achBoss10Title => '두목 킬러';

  @override
  String get g_achBoss10Desc => '해적 두목 10회 격파';

  @override
  String get g_achExplorerTitle => '탐험가';

  @override
  String get g_achExplorerDesc => '항성계 3 도달';

  @override
  String get g_achVoyagerTitle => '항해자';

  @override
  String get g_achVoyagerDesc => '항성계 6 도달';

  @override
  String get g_achRichTitle => '부자 선장';

  @override
  String get g_achRichDesc => '크레딧 10000 보유';

  @override
  String get g_achCrew6Title => '든든한 동료';

  @override
  String get g_achCrew6Desc => '승무원 6명 영입';

  @override
  String get g_achCrew3starTitle => '전설의 동료';

  @override
  String get g_achCrew3starDesc => '★3 승무원 영입';

  @override
  String get g_achMissionsTitle => '해결사';

  @override
  String get g_achMissionsDesc => '임무 20개 완료';

  @override
  String get g_achJellyTitle => '해파리 박사';

  @override
  String get g_achJellyDesc => '우주 해파리 10마리 처치';

  @override
  String get g_achFashionTitle => '패셔니스타';

  @override
  String get g_achFashionDesc => '꾸미기 아이템 구매';

  @override
  String get g_achAscendTitle => '새로운 시작';

  @override
  String get g_achAscendDesc => '은하 명예로 환생';

  @override
  String get g_achDroneTitle => '든든한 드론';

  @override
  String get g_achDroneDesc => '전투 드론 장착';

  @override
  String get g_achHome5Title => '행성 건축가';

  @override
  String get g_achHome5Desc => '내 행성에 건물 5개';

  @override
  String get g_achHomeMaxTitle => '꿈의 행성';

  @override
  String get g_achHomeMaxDesc => '내 행성 최대 레벨';

  @override
  String get g_dailyKill => '해적 30척 격추';

  @override
  String get g_dailyOre => '광석 300개 수집';

  @override
  String get g_dailyMission => '임무 2개 완료';

  @override
  String get g_dailyColony => '식민지 2번 성장';

  @override
  String get g_dailyBoss => '해적 두목 격파';

  @override
  String get g_dailyPower => '파워업 3개 획득';

  @override
  String get g_dailyPlay => '10분 플레이';

  @override
  String get g_dailyJelly => '우주 해파리 3마리 처치';

  @override
  String g_missionKill(int n) {
    return '해적 $n척 소탕';
  }

  @override
  String g_missionMine(int n) {
    return '광석 $n개 수집';
  }

  @override
  String g_missionDeliver(String planet) {
    return '$planet 화물 운송';
  }

  @override
  String g_missionBounty(String name) {
    return '현상수배: $name';
  }

  @override
  String get g_bounty0 => '외눈 잭';

  @override
  String get g_bounty1 => '번개 몰리';

  @override
  String get g_bounty2 => '고철왕 바르크';

  @override
  String get g_bounty3 => '붉은 수염 토토';

  @override
  String get g_bounty4 => '그림자 레나';

  @override
  String get g_bounty5 => '뚱보 포크';

  @override
  String get g_bounty6 => '쌍칼 지지';

  @override
  String get g_bounty7 => '미친 망치 버드';

  @override
  String get g_bounty8 => '은하 여우 루시';

  @override
  String get g_bounty9 => '해골 선장 본즈';

  @override
  String get g_storyAsteroidsTitle => '소행성 3개 부수기';

  @override
  String get g_storyAsteroidsLine0 => '선장님! 먼저 소행성을 부숴서 광석을 모아봐요.';

  @override
  String get g_storyAsteroidsLine1 => '조이스틱으로 이동하고, 발사 버튼으로 쏘면 돼요!';

  @override
  String get g_storyKillsTitle => '해적 3척 격추';

  @override
  String get g_storyKillsLine0 => '레이더에 해적이 잡혀요! 빨간 화살표 방향이에요.';

  @override
  String get g_storyKillsLine1 => '해적 따위, 내 함선 앞에선 고철이지!';

  @override
  String get g_storyColoniesTitle => '화성에 정착하기';

  @override
  String get g_storyColoniesLine0 =>
      '지구 바로 옆 붉은 행성, 화성에 첫 식민지를 세워봐요. 가까이 가면 정착 버튼이 떠요.';

  @override
  String get g_storyColoniesLine1 => '식민지는 가만히 있어도 크레딧을 벌어줘요!';

  @override
  String get g_storyShipLevelsTitle => '정거장에서 함선 개조';

  @override
  String get g_storyShipLevelsLine0 =>
      '헤이븐 기지로 돌아가서 함선을 개조해봐요. 정거장 근처에선 수리도 돼요.';

  @override
  String get g_storyCrewTitle => '승무원 1명 영입';

  @override
  String get g_storyCrewLine0 => '혼자는 외롭잖아요? 정거장 메뉴의 승무원 탭에서 동료를 영입해봐요!';

  @override
  String get g_storyMissionsTitle => '임무 1개 완료';

  @override
  String get g_storyMissionsLine0 => '정거장 임무 게시판에서 의뢰를 받아보세요. 보상이 짭짤해요.';

  @override
  String get g_storyStationsTitle => '새 정거장 건설';

  @override
  String get g_storyStationsLine0 => '이제 영역을 넓힐 때예요! 행성에서 떨어진 빈 우주에 정거장을 지어봐요.';

  @override
  String get g_storyDevPercentTitle => '항성계 발전도 100%';

  @override
  String get g_storyDevPercentLine0 =>
      '모든 행성을 Lv.3까지 키우면 다음 항성계가 열려요. 오른쪽 위 항성계 버튼에서 확인해요!';

  @override
  String get g_storySectorTitle => '워프 게이트로 다음 항성계 이동';

  @override
  String get g_storySectorLine0 => '워프 게이트가 열렸어요! 미니맵의 보라색 게이트로 가봐요.';

  @override
  String get g_storySectorLine1 => '새로운 우주가 기다리고 있어!';

  @override
  String g_storyDevNTitle(int n) {
    return '항성계 $n 발전도 100%';
  }

  @override
  String get g_storyDevNLine => '새 항성계의 행성들을 모두 Lv.3까지 키워요!';

  @override
  String g_systemN(int n) {
    return '항성계 $n';
  }

  @override
  String g_storyWarpNTitle(String system) {
    return '$system 워프';
  }

  @override
  String get g_storyWarpNLine => '게이트가 열렸어요. 더 깊은 우주로 가볼까요?';

  @override
  String get g_powerUpRapid => '연사';

  @override
  String get g_powerUpShield => '실드';

  @override
  String get g_powerUpMagnet => '자석';

  @override
  String get g_powerUpDoubleCredits => '크레딧 2배';

  @override
  String get g_planetKindGarden => '정원 행성';

  @override
  String get g_planetKindDesert => '사막 행성';

  @override
  String get g_planetKindIce => '얼음 행성';

  @override
  String get g_planetKindLava => '용암 행성';

  @override
  String get g_planetKindGas => '가스 행성';

  @override
  String get g_colonyBldTurret => '방어포탑';

  @override
  String get g_colonyBldMine => '채굴 시설';

  @override
  String get g_colonyBldTrade => '교역소';

  @override
  String get g_colonyBldDock => '수리 도크';

  @override
  String get g_colonyBldShieldGen => '방어막 발생기';

  @override
  String get g_colonyBldBlurbTurret => '식민지 근처 해적을 자동으로 요격해요. 습격 방어에 필수!';

  @override
  String get g_colonyBldBlurbMine => '광석을 캐서 매초 💎를 보내줘요.';

  @override
  String get g_colonyBldBlurbTrade => '이 식민지의 크레딧 수입을 25%씩 늘려요.';

  @override
  String get g_colonyBldBlurbDock => '근처에 있으면 함선 체력을 회복해요.';

  @override
  String get g_colonyBldBlurbShieldGen => '방어막 용량과 충전 속도를 늘려요.';

  @override
  String get g_stationRoleHome => '본거지';

  @override
  String get g_stationRoleDefense => '방어 기지';

  @override
  String get g_stationRoleRepair => '수리 기지';

  @override
  String get g_stationRoleSupport => '보급 기지';

  @override
  String get g_stationRoleBlurbHome => '레이저 포대와 안전 구역';

  @override
  String get g_stationRoleBlurbDefense => '강한 포탑 · 내구도 2배 · 주변 적 탄환 차단';

  @override
  String get g_stationRoleBlurbRepair =>
      '넓은 범위 빠른 수리 · 재출격 비용 10% · 근처 식민지 방어막 충전 2배';

  @override
  String get g_stationRoleBlurbSupport => '근처 식민지 생산 +25% (거주구역 레벨마다 +5%)';

  @override
  String g_eventRaid(String planet) {
    return '$planet 습격';
  }

  @override
  String get g_eventMeteor => '유성우';

  @override
  String get g_eventMerchant => '떠돌이 상인';

  @override
  String get g_eventSupply => '보급 캡슐';

  @override
  String get g_productGems100Title => '젬 한 줌';

  @override
  String get g_productGems550Title => '젬 주머니';

  @override
  String get g_productGems1200Title => '젬 상자';

  @override
  String get g_productStarterTitle => '스타터 팩';

  @override
  String get g_productPassTitle => '함대 사령관 패스';

  @override
  String get g_productGems550Desc => '⭐550 (+10% 보너스)';

  @override
  String get g_productGems1200Desc => '⭐1200 (+20% 보너스)';

  @override
  String get g_productStarterDesc => '⭐300 + 전용 스킨 \"갤럭시\" + ★3 승무원 (1회 한정)';

  @override
  String get g_productPassDesc =>
      '크레딧 수입 +25%, 오프라인 수입 8시간, 광고 없이 보상, 전용 스킨 \"골드 로열\"';

  @override
  String g_testPurchaseTitle(String product) {
    return '[테스트 결제] $product';
  }

  @override
  String g_testPurchaseBody(String desc, String price) {
    return '실제 결제는 일어나지 않아요.\n$desc\n가격: $price';
  }

  @override
  String get g_testAdTitle => '[테스트 광고]';

  @override
  String get g_testAdBody => '광고를 끝까지 본 것으로 처리할까요?';

  @override
  String get g_webDemoTitle => '웹 데모';

  @override
  String get g_webDemoBody => '구매와 광고 보상은 모바일 앱에서 이용할 수 있어요.';

  @override
  String get g_notifChannelName => '복귀 알림';

  @override
  String get g_notifChannelDesc => '식민지 수입, 출석 보상 알림';

  @override
  String get g_notifStorageTitle => '식민지 창고가 가득 찼어요!';

  @override
  String get g_notifStorageBody => '선장님, 쌓인 크레딧을 받으러 오세요. 더 늦으면 수입이 멈춰요.';

  @override
  String get g_notifPiratesTitle => '해적들이 다시 날뛰고 있어요!';

  @override
  String get g_notifPiratesBody => '오늘의 출석 보상과 일일 퀘스트가 기다리고 있어요.';

  @override
  String get g_upgradeWeapon => '무기';

  @override
  String get g_upgradeHull => '장갑';

  @override
  String get g_upgradeEngine => '엔진';

  @override
  String get g_upgradeMissile => '유도 미사일';

  @override
  String get g_upgradeShield => '에너지 실드';

  @override
  String get g_upgradeDrone => '전투 드론';

  @override
  String get g_upgradeMagnet => '자석';

  @override
  String g_unknownSector(int n) {
    return '미지의 항성계 $n';
  }

  @override
  String get g_stationHaven => '헤이븐 기지';

  @override
  String g_stationOutpost(String sector) {
    return '$sector 전진기지';
  }

  @override
  String g_stationNumbered(String role, int n) {
    return '$role $n호';
  }

  @override
  String get g_dlgWelcome => '선장님, 환영합니다! 저는 부관 미나예요.';

  @override
  String get g_dlgMissionsCancelled => '이전 항성계의 운송·현상수배 임무는 취소됐어요.';

  @override
  String get g_floatDisabled => '기능 정지!';

  @override
  String get g_floatRebooted => '재가동!';

  @override
  String get g_dlgBaseRebooted => '본거지 재가동! 내구도 30%로 복구됐어요.';

  @override
  String get g_dlgUpWeapon => '무기 강화! 해적들 각오해라!';

  @override
  String get g_dlgUpHull => '장갑 강화! 이제 좀 든든하군.';

  @override
  String get g_dlgUpEngine => '엔진 강화! 더 빠르게!';

  @override
  String get g_dlgMissileNew => '유도 미사일 장착! (Q)';

  @override
  String get g_dlgMissileUp => '미사일 강화!';

  @override
  String get g_dlgShieldNew => '에너지 실드 장착! (F)';

  @override
  String get g_dlgShieldUp => '실드 강화!';

  @override
  String get g_dlgDroneNew => '전투 드론 출격! 든든한 친구가 생겼다.';

  @override
  String get g_dlgDroneUp => '드론 강화!';

  @override
  String get g_dlgUpMagnet => '자석 강화! 크레딧이 알아서 붙는다!';

  @override
  String get g_dlgNotOver => '아직 끝나지 않았다!';

  @override
  String get g_floatBlocked => '막음!';

  @override
  String get g_floatGuard => '수호막!';

  @override
  String get g_pirateBossLose => '으아악! 이 항성계는… 네 것이다…';

  @override
  String get g_pirateBossFlee => '으아악! 기억해 두겠다, 선장!';

  @override
  String get g_dlgSupplyCollected => '보급 캡슐 회수 완료!';

  @override
  String get g_merchantBye => '그럼 다음에 또 봐요~ 냥!';

  @override
  String get g_pirateRaidTaunt => '이 식민지는 이제 우리 거다! 크하하!';

  @override
  String get g_dlgMeteor => '유성우 발견! 크리스탈이 잔뜩 섞여 있어요. 광석 대박 기회!';

  @override
  String get g_merchantHello => '떠돌이 상인 냥냥이 왔어요~ 좋은 물건 많다냥!';

  @override
  String get g_dlgSupplySignal => '젬이 든 보급 캡슐 신호가 잡혔어요! 해적이 지키고 있으니 조심하세요.';

  @override
  String get g_dlgBossWarning => '경고! 항성계 두목 함선이 접근 중입니다!';

  @override
  String get g_pirateRevenge => '복수하러 왔다! 각오해라!';

  @override
  String get g_floatShieldBroken => '파괴!';

  @override
  String get g_floatShieldBack => '재가동';

  @override
  String get g_floatGoalDone => '목표 달성!';

  @override
  String g_dlgArrived(String sector) {
    return '$sector에 도착했어요!';
  }

  @override
  String get g_dlgNewFrontier => '새로운 개척지예요.';

  @override
  String g_dlgBaseUpgraded(String station, int level) {
    return '$station 강화 Lv.$level! 레이저가 더 세졌어요.';
  }

  @override
  String g_dlgBaseDisabled(int sec) {
    return '본거지 기능 정지! $sec초간 보호가 꺼져요!';
  }

  @override
  String g_dlgSettled(String planet) {
    return '$planet에 깃발을 꽂았다! 정착 완료!';
  }

  @override
  String g_dlgStationBuilt(String station, String blurb) {
    return '$station 건설 완료! $blurb';
  }

  @override
  String g_dlgHabitatUp(String station, int level) {
    return '$station 거주구역 Lv.$level!';
  }

  @override
  String g_dlgTurretUp(String station, int level) {
    return '$station 방어포탑 Lv.$level!';
  }

  @override
  String g_dlgShipSwitched(String ship) {
    return '$ship 갈아탔다! 느낌 좋은데?';
  }

  @override
  String g_dlgOreSold(int n, int credits) {
    return '광석 $n개를 💰$credits에 팔았어요.';
  }

  @override
  String g_dlgCrewJoined(String stars, String role, String name) {
    return '$stars $role $name 합류했어요!';
  }

  @override
  String g_dlgCrewLevel(String name, int level) {
    return '$name Lv.$level! 실력이 늘었어요.';
  }

  @override
  String g_dlgCargoLoaded(String mission) {
    return '화물을 실었어요! $mission';
  }

  @override
  String g_dlgBountyTaunt(String name) {
    return '$name 잡겠다고? 어디 한번 와봐라!';
  }

  @override
  String get g_floatMissionDone => '임무 완료!';

  @override
  String g_dlgMissionDone(String mission) {
    return '임무 완료: $mission!';
  }

  @override
  String g_dlgRepairCost(int credits) {
    return '선장님 무사하시군요! 수리비로 💰$credits 썼어요.';
  }

  @override
  String g_dlgSectorDeveloped(String sector) {
    return '$sector 발전 완료! 다음 항성계로 가는 워프 게이트가 열렸어요.';
  }

  @override
  String g_floatCrit(int dmg) {
    return '치명타! $dmg';
  }

  @override
  String g_dlgStationDestroyed(String station) {
    return '$station 파괴됐어요! 방어포탑이 필요해요!';
  }

  @override
  String g_dlgBossDefeated(int credits) {
    return '항성계 두목 격파! 보상 💰$credits';
  }

  @override
  String g_dlgBountyCaught(String name) {
    return '현상수배범 $name 체포 완료!';
  }

  @override
  String g_dlgRaidDefended(String planet, int credits) {
    return '$planet 방어 성공! 주민들이 감사의 뜻으로 💰$credits ⭐2를 보냈어요.';
  }

  @override
  String g_dlgRaidLooted(String planet, String level) {
    return '$planet 약탈당해 $level 떨어졌어요… 😢';
  }

  @override
  String g_dlgRaidLeft(String planet) {
    return '해적들이 $planet 약탈하고 떠났어요.';
  }

  @override
  String g_dlgRaidAlert(String planet) {
    return '긴급! 해적이 $planet 습격하고 있어요! 생산이 멈췄어요!';
  }

  @override
  String g_pirateBossArrive(String sector) {
    return '$sector의 주인은 나다! 덤벼라, 꼬마 선장!';
  }

  @override
  String g_dlgWelcomeBack(String goal) {
    return '다시 오신 걸 환영해요, 선장님! 현재 목표: $goal';
  }

  @override
  String get g_pirateWin0 => '크하하! 별것 아니군!';

  @override
  String get g_pirateWin1 => '다음엔 더 강해져서 와라, 꼬마!';

  @override
  String get g_pirateWin2 => '네 함선은 고철이 됐다!';

  @override
  String get g_pirateRage0 => '얘들아, 나와라! 본때를 보여줘!';

  @override
  String get g_pirateRage1 => '이제부터 진짜다!';

  @override
  String get g_pirateRage2 => '화나게 했겠다?!';

  @override
  String get g_captainKill0 => '한 놈 처리!';

  @override
  String get g_captainKill1 => '어딜 도망가!';

  @override
  String get g_captainKill2 => '이 구역은 내 거야!';

  @override
  String get g_captainKill3 => '다음!';

  @override
  String get g_pirateAmbush0 => '크하하! 짐 내려놔!';

  @override
  String get g_pirateAmbush1 => '여긴 우리 해적단 구역이다!';

  @override
  String get g_pirateAmbush2 => '그 반짝이는 크레딧 내놔!';

  @override
  String get g_pirateAmbush3 => '오늘 운이 나쁘구나, 꼬마!';

  @override
  String get cat_sysSol => '태양계';

  @override
  String get cat_sysAlphaCen => '알파 센타우리';

  @override
  String get cat_sysBarnard => '버나드 별';

  @override
  String get cat_sysWolf359 => '울프 359';

  @override
  String get cat_sysLalande => '랄랑드 21185';

  @override
  String get cat_sysSirius => '시리우스';

  @override
  String get cat_sysEpsEri => '에리다누스자리 엡실론';

  @override
  String get cat_sysRoss128 => '로스 128';

  @override
  String get cat_sysTauCeti => '고래자리 타우';

  @override
  String get cat_sysTeegarden => '티가든 별';

  @override
  String get cat_sysGliese581 => '글리제 581';

  @override
  String get cat_sysGliese667C => '글리제 667 C';

  @override
  String get cat_sysTrappist1 => '트라피스트-1';

  @override
  String get cat_sys55Cnc => '게자리 55';

  @override
  String get cat_sys51Peg => '페가수스자리 51';

  @override
  String cat_sysKepler(int n) {
    return '케플러-$n';
  }

  @override
  String get cat_sysOmegaCen => '오메가 센타우리 성단';

  @override
  String get cat_sysSgrA => '은하 중심 (궁수자리 A*)';

  @override
  String get cat_sysLMC => '대마젤란 은하';

  @override
  String get cat_sysSMC => '소마젤란 은하';

  @override
  String get cat_sysAndromeda => '안드로메다 은하';

  @override
  String get cat_sysTriangulum => '삼각형자리 은하';

  @override
  String get cat_pfxProxima => '프록시마';

  @override
  String get cat_pfxBarnard => '버나드';

  @override
  String get cat_pfxSirius => '시리우스 A';

  @override
  String get cat_pfxEpsEri => '엡실론 에리다니';

  @override
  String get cat_pfxTauCeti => '타우 세티';

  @override
  String get cat_pfxTeegarden => '티가든';

  @override
  String get cat_mars => '화성';

  @override
  String get cat_moon => '달';

  @override
  String get cat_venus => '금성';

  @override
  String get cat_mercury => '수성';

  @override
  String get cat_ceres => '세레스';

  @override
  String get cat_vesta => '베스타';

  @override
  String get cat_jupiter => '목성';

  @override
  String get cat_io => '이오';

  @override
  String get cat_europa => '유로파';

  @override
  String get cat_ganymede => '가니메데';

  @override
  String get cat_callisto => '칼리스토';

  @override
  String get cat_saturn => '토성';

  @override
  String get cat_enceladus => '엔셀라두스';

  @override
  String get cat_titan => '타이탄';

  @override
  String get cat_uranus => '천왕성';

  @override
  String get cat_miranda => '미란다';

  @override
  String get cat_titania => '티타니아';

  @override
  String get cat_neptune => '해왕성';

  @override
  String get cat_triton => '트리톤';

  @override
  String get cat_pluto => '명왕성';

  @override
  String get cat_charon => '카론';

  @override
  String get cat_haumea => '하우메아';

  @override
  String get cat_makemake => '마케마케';

  @override
  String get cat_eris => '에리스';

  @override
  String get cat_sedna => '세드나';

  @override
  String get cat_planetNine => '제9행성';

  @override
  String get u_topUpTitle => '크레딧 부족';

  @override
  String u_topUpBody(int credits, int gems) {
    return '💰$credits 부족해요. ⭐$gems로 채우고 진행할까요?';
  }

  @override
  String u_topUpNoGems(int gems) {
    return '⭐$gems 필요해요. 상점에서 젬을 살까요?';
  }

  @override
  String get u_topUpOk => '채우고 진행';

  @override
  String get u_goShop => '상점으로';

  @override
  String get u_exchangeTitle => '💰 크레딧 교환';

  @override
  String u_exchangeBody(int gems, int credits) {
    return '⭐$gems → 💰$credits로 교환할까요?';
  }

  @override
  String get m_purchaseFailed => '스토어에 연결하지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  String get m_adWatchToEnd => '광고를 끝까지 봐야 보상을 받을 수 있어요.';

  @override
  String get u_autoFireOn => '켬';

  @override
  String get u_autoFireOff => '끔';

  @override
  String u_recruitRoleOdds(int count, String pct) {
    return '직책(모든 모집 공통): $count종 중 무작위, 각 $pct';
  }

  @override
  String m_feedbackSubject(String app) {
    return '$app 피드백';
  }

  @override
  String get lb_menu => '🏅 주간 순위';

  @override
  String get lb_menuShort => '순위';

  @override
  String get lb_title => '🏅 주간 개척 순위';

  @override
  String get lb_join => '순위표 참여하기';

  @override
  String get lb_joinDesc =>
      '익명 ID, 게임이 만든 별명, 이번 주 점수만 보내요. 이름·채팅·직접 입력한 글자는 보내지 않아요. 언제든 끌 수 있어요.';

  @override
  String get lb_yourNick => '내 별명';

  @override
  String lb_reroll(int count) {
    return '새 별명 ($count)';
  }

  @override
  String lb_weekPoints(String points) {
    return '이번 주 개척 점수 $points점';
  }

  @override
  String lb_rank(int rank, int total) {
    return '$rank위 / $total명';
  }

  @override
  String lb_rankOnly(int rank) {
    return '$rank위';
  }

  @override
  String get lb_top50 => '이번 주 상위 50';

  @override
  String get lb_empty => '아직 이번 주 기록이 없어요. 첫 번째가 되어 보세요!';

  @override
  String get lb_retry => '다시 시도';

  @override
  String get lb_refresh => '새로고침';

  @override
  String get lb_offline => '연결이 없어요. 게임은 그대로 할 수 있어요. 나중에 다시 해 보세요.';

  @override
  String get lb_rateLimited => '너무 자주 보냈어요. 1분 뒤에 다시 해 보세요.';

  @override
  String get lb_rejected => '이 점수는 보낼 수 없어요.';

  @override
  String get lb_serverError => '순위표가 바빠요. 나중에 다시 해 보세요.';

  @override
  String get lb_unavailable => '순위표를 사용할 수 없어요.';

  @override
  String get lb_optedOut => '‘순위표 참여하기’를 켜면 내 점수가 올라가요.';

  @override
  String get lb_howTo => '식민지 레벨 +100 · 새 항성계 +500 · 해적 격추 +5 · 두목 +200';

  @override
  String get lb_resets => '매주 월요일 0시(UTC)에 새 주가 시작돼요.';

  @override
  String nickFormat(String adj, String animal, String number) {
    return '$adj $animal $number';
  }

  @override
  String get nickGenders => '';

  @override
  String nickAdj0(String g) {
    return '용감한';
  }

  @override
  String get nickAnimal0 => '수달';

  @override
  String nickAdj1(String g) {
    return '밝은';
  }

  @override
  String get nickAnimal1 => '판다';

  @override
  String nickAdj2(String g) {
    return '차분한';
  }

  @override
  String get nickAnimal2 => '여우';

  @override
  String nickAdj3(String g) {
    return '영리한';
  }

  @override
  String get nickAnimal3 => '토끼';

  @override
  String nickAdj4(String g) {
    return '우주의';
  }

  @override
  String get nickAnimal4 => '부엉이';

  @override
  String nickAdj5(String g) {
    return '호기심 많은';
  }

  @override
  String get nickAnimal5 => '펭귄';

  @override
  String nickAdj6(String g) {
    return '통통 튀는';
  }

  @override
  String get nickAnimal6 => '코알라';

  @override
  String nickAdj7(String g) {
    return '꿈꾸는';
  }

  @override
  String get nickAnimal7 => '돌고래';

  @override
  String nickAdj8(String g) {
    return '포근한';
  }

  @override
  String get nickAnimal8 => '거북이';

  @override
  String nickAdj9(String g) {
    return '빠른';
  }

  @override
  String get nickAnimal9 => '고슴도치';

  @override
  String nickAdj10(String g) {
    return '복슬복슬한';
  }

  @override
  String get nickAnimal10 => '청설모';

  @override
  String nickAdj11(String g) {
    return '다정한';
  }

  @override
  String get nickAnimal11 => '아기 고양이';

  @override
  String nickAdj12(String g) {
    return '상냥한';
  }

  @override
  String get nickAnimal12 => '강아지';

  @override
  String nickAdj13(String g) {
    return '빛나는';
  }

  @override
  String get nickAnimal13 => '아기 오리';

  @override
  String nickAdj14(String g) {
    return '황금빛';
  }

  @override
  String get nickAnimal14 => '아기 양';

  @override
  String nickAdj15(String g) {
    return '행복한';
  }

  @override
  String get nickAnimal15 => '물범';

  @override
  String nickAdj16(String g) {
    return '재미있는';
  }

  @override
  String get nickAnimal16 => '고래';

  @override
  String nickAdj17(String g) {
    return '착한';
  }

  @override
  String get nickAnimal17 => '햄스터';

  @override
  String nickAdj18(String g) {
    return '행운의';
  }

  @override
  String get nickAnimal18 => '비버';

  @override
  String nickAdj19(String g) {
    return '노래하는';
  }

  @override
  String get nickAnimal19 => '너구리';

  @override
  String nickAdj20(String g) {
    return '힘센';
  }

  @override
  String get nickAnimal20 => '앵무새';

  @override
  String nickAdj21(String g) {
    return '알록달록한';
  }

  @override
  String get nickAnimal21 => '무당벌레';

  @override
  String nickAdj22(String g) {
    return '달콤한';
  }

  @override
  String get nickAnimal22 => '참새';

  @override
  String nickAdj23(String g) {
    return '예의 바른';
  }

  @override
  String get nickAnimal23 => '아기 사슴';

  @override
  String nickAdj24(String g) {
    return '장난스러운';
  }

  @override
  String get nickAnimal24 => '조랑말';

  @override
  String nickAdj25(String g) {
    return '조용한';
  }

  @override
  String get nickAnimal25 => '아기 곰';

  @override
  String nickAdj26(String g) {
    return '반짝이는';
  }

  @override
  String get nickAnimal26 => '아기 사자';

  @override
  String nickAdj27(String g) {
    return '은빛';
  }

  @override
  String get nickAnimal27 => '아기 호랑이';

  @override
  String nickAdj28(String g) {
    return '졸린';
  }

  @override
  String get nickAnimal28 => '기린';

  @override
  String nickAdj29(String g) {
    return '달빛';
  }

  @override
  String get nickAnimal29 => '얼룩말';

  @override
  String nickAdj30(String g) {
    return '태양의';
  }

  @override
  String get nickAnimal30 => '코끼리';

  @override
  String nickAdj31(String g) {
    return '마법의';
  }

  @override
  String get nickAnimal31 => '하마';

  @override
  String nickAdj32(String g) {
    return '슈퍼';
  }

  @override
  String get nickAnimal32 => '라마';

  @override
  String nickAdj33(String g) {
    return '별빛';
  }

  @override
  String get nickAnimal33 => '알파카';

  @override
  String nickAdj34(String g) {
    return '해맑은';
  }

  @override
  String get nickAnimal34 => '미어캣';

  @override
  String nickAdj35(String g) {
    return '고귀한';
  }

  @override
  String get nickAnimal35 => '불가사리';

  @override
  String nickAdj36(String g) {
    return '조그만';
  }

  @override
  String get nickAnimal36 => '해마';

  @override
  String nickAdj37(String g) {
    return '지혜로운';
  }

  @override
  String get nickAnimal37 => '다람쥐';

  @override
  String nickAdj38(String g) {
    return '눈꽃';
  }

  @override
  String get nickAnimal38 => '금붕어';

  @override
  String nickAdj39(String g) {
    return '든든한';
  }

  @override
  String get nickAnimal39 => '반딧불이';

  @override
  String get m_adPrivacy => '광고 개인정보 설정';
}
