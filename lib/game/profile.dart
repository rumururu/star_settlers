import 'dart:math';

import '../l10n/l.dart';
import 'home.dart';
import 'ships.dart';
import 'weekly_score.dart';

/// 새 게임을 시작해도 유지되는 계정 단위 데이터
/// (젬, 구매 내역, 꾸미기, 업적, 출석, 일일 퀘스트, 함선, 은하 명예, 설정)
class Achievement {
  const Achievement(this.id, this.stat, this.target, this.gems);
  final String id;
  String get title => _achievementText(id).$1;
  String get desc => _achievementText(id).$2;
  final String stat;
  final int target;
  final int gems;
}

const achievements = [
  Achievement('first_blood', 'kills', 1, 5),
  Achievement('hunter', 'kills', 100, 20),
  Achievement('legend', 'kills', 1000, 50),
  Achievement('miner', 'ore', 1000, 10),
  Achievement('miner2', 'ore', 10000, 30),
  Achievement('colonist', 'colonies', 5, 15),
  Achievement('metropolis', 'maxColony', 1, 15),
  Achievement('builder', 'stations', 3, 15),
  Achievement('boss1', 'bosses', 1, 10),
  Achievement('boss10', 'bosses', 10, 30),
  Achievement('explorer', 'sector', 3, 20),
  Achievement('voyager', 'sector', 6, 40),
  Achievement('rich', 'credits', 10000, 15),
  Achievement('crew6', 'crew', 6, 15),
  Achievement('crew3star', 'crew3', 1, 20),
  Achievement('missions', 'missions', 20, 20),
  Achievement('jelly', 'jelly', 10, 10),
  Achievement('fashion', 'cosmetics', 1, 5),
  Achievement('ascend', 'ascensions', 1, 30),
  Achievement('drone', 'drone', 1, 5),
  Achievement('home5', 'homeBuildings', 5, 15),
  Achievement('homeMax', 'homeLevel', 4, 30),
];

(String, String) _achievementText(String id) => switch (id) {
      'first_blood' => (tr.g_achFirstBloodTitle, tr.g_achFirstBloodDesc),
      'hunter' => (tr.g_achHunterTitle, tr.g_achHunterDesc),
      'legend' => (tr.g_achLegendTitle, tr.g_achLegendDesc),
      'miner' => (tr.g_achMinerTitle, tr.g_achMinerDesc),
      'miner2' => (tr.g_achMiner2Title, tr.g_achMiner2Desc),
      'colonist' => (tr.g_achColonistTitle, tr.g_achColonistDesc),
      'metropolis' => (tr.g_achMetropolisTitle, tr.g_achMetropolisDesc),
      'builder' => (tr.g_achBuilderTitle, tr.g_achBuilderDesc),
      'boss1' => (tr.g_achBoss1Title, tr.g_achBoss1Desc),
      'boss10' => (tr.g_achBoss10Title, tr.g_achBoss10Desc),
      'explorer' => (tr.g_achExplorerTitle, tr.g_achExplorerDesc),
      'voyager' => (tr.g_achVoyagerTitle, tr.g_achVoyagerDesc),
      'rich' => (tr.g_achRichTitle, tr.g_achRichDesc),
      'crew6' => (tr.g_achCrew6Title, tr.g_achCrew6Desc),
      'crew3star' => (tr.g_achCrew3starTitle, tr.g_achCrew3starDesc),
      'missions' => (tr.g_achMissionsTitle, tr.g_achMissionsDesc),
      'jelly' => (tr.g_achJellyTitle, tr.g_achJellyDesc),
      'fashion' => (tr.g_achFashionTitle, tr.g_achFashionDesc),
      'ascend' => (tr.g_achAscendTitle, tr.g_achAscendDesc),
      'drone' => (tr.g_achDroneTitle, tr.g_achDroneDesc),
      'home5' => (tr.g_achHome5Title, tr.g_achHome5Desc),
      'homeMax' => (tr.g_achHomeMaxTitle, tr.g_achHomeMaxDesc),
      _ => (id, ''),
    };

const loginRewards = [5, 5, 10, 10, 15, 20, 50];

class DailyQuestDef {
  const DailyQuestDef(this.id, this.stat, this.target, this.gems);
  final String id;
  String get title => switch (id) {
        'kill' => tr.g_dailyKill,
        'ore' => tr.g_dailyOre,
        'mission' => tr.g_dailyMission,
        'colony' => tr.g_dailyColony,
        'boss' => tr.g_dailyBoss,
        'power' => tr.g_dailyPower,
        'play' => tr.g_dailyPlay,
        'jelly' => tr.g_dailyJelly,
        _ => id,
      };
  final String stat;
  final int target;
  final int gems;
}

const dailyPool = [
  DailyQuestDef('kill', 'kills', 30, 5),
  DailyQuestDef('ore', 'ore', 300, 5),
  DailyQuestDef('mission', 'missions', 2, 10),
  DailyQuestDef('colony', 'colonyUps', 2, 5),
  DailyQuestDef('boss', 'bosses', 1, 10),
  DailyQuestDef('power', 'powerups', 3, 5),
  DailyQuestDef('play', 'playMin', 10, 5),
  DailyQuestDef('jelly', 'jelly', 3, 5),
];

const dailyBonusGems = 10;

class Profile {
  int gems = 0;
  bool premium = false;
  bool starterBought = false;

  /// 이미 지급한 스토어 거래 ID (같은 결제를 두 번 지급하지 않게)
  Set<String> grantedTx = {};

  /// 이 기기 저장이 처음 생긴 시각. 이보다 이전에 산 소모성 상품은 다시 지급하지 않는다
  /// (재설치·데이터 삭제 후 젬을 또 받는 것 방지. 비소모성은 언제든 복원)
  DateTime txSince = DateTime.now();

  /// 젬으로 산 추가 배치 슬롯 수 (0..[crewSlotPrices].length)
  int extraCrewSlots = 0;

  /// 젬으로 산 승무원 정원 확장 횟수 (1회당 +[rosterPackSize])
  int rosterPacks = 0;

  /// 배치 슬롯 +1 가격 (단계별로 비싸짐)
  static const crewSlotPrices = [100, 200, 350];
  static const rosterPackPrice = 80;
  static const rosterPackSize = 4;
  static const maxRosterPacks = 3;

  /// 다음 배치 슬롯 가격. 다 샀으면 null
  int? get nextCrewSlotPrice =>
      extraCrewSlots < crewSlotPrices.length ? crewSlotPrices[extraCrewSlots] : null;

  bool buyCrewSlot() {
    final price = nextCrewSlotPrice;
    if (price == null || !spendGems(price)) return false;
    extraCrewSlots++;
    return true;
  }

  bool buyRosterPack() {
    if (rosterPacks >= maxRosterPacks || !spendGems(rosterPackPrice)) return false;
    rosterPacks++;
    return true;
  }
  final ownedSkins = <String>{'default'};
  final ownedOutfits = <String>{'default'};
  String skin = 'default';
  String outfit = 'default';
  final claimed = <String>{};
  final stats = <String, int>{};

  int lastLoginDay = 0; // yyyymmdd
  int loginStreak = 0;
  int adGemDay = 0;
  int adGemsToday = 0;

  bool sound = true;
  bool music = true;
  bool haptics = true;
  bool tutorialDone = false;

  /// 식민지 안내(첫 정착 튜토리얼)를 봤는지
  bool colonyTutorialSeen = false;

  /// 결제로 받았지만 아직 월드에 지급하지 않은 ★3 승무원 수
  int pendingStarCrew = 0;

  // 격납고
  String shipType = 'scout';
  final ownedShips = <String>{};

  // 은하 명예 (환생)
  int honor = 0;
  int ascensions = 0;

  // 일일 퀘스트
  int dailyDay = 0;
  final dailyIds = <String>[];
  final dailyBase = <String, int>{};
  final dailyClaimed = <String>{};

  bool notifications = true;

  /// 언어 설정. null = 기기 언어 따라감
  String? language;

  // 내 행성
  HomePlanet home = HomePlanet();

  // 주간 순위표 (services/leaderboard.dart). 참여는 기본 꺼짐.
  /// 순위표용 무작위 설치 ID (UUID v4). 참여할 때 처음 만든다.
  String? installId;

  /// 별명 코드 "형용사-동물-4자리" (자유 입력 없음)
  String? nicknameCode;
  bool leaderboardOptIn = false;
  int nicknameRerolls = 0;

  /// 이번 주 개척 점수
  WeeklyScore weeklyScore = WeeklyScore.now();

  /// 저장 필요 표시
  bool dirty = false;

  static const adGemsPerDay = 3;
  static const adGemAmount = 5;

  int stat(String k) => stats[k] ?? 0;

  void addStat(String k, [int n = 1]) {
    stats[k] = stat(k) + n;
    dirty = true;
  }

  void maxStat(String k, int v) {
    if (v > stat(k)) {
      stats[k] = v;
      dirty = true;
    }
  }

  bool isComplete(Achievement a) => stat(a.stat) >= a.target;

  Iterable<Achievement> get claimable =>
      achievements.where((a) => isComplete(a) && !claimed.contains(a.id));

  bool claim(Achievement a) {
    if (!isComplete(a) || claimed.contains(a.id)) return false;
    claimed.add(a.id);
    gems += a.gems;
    dirty = true;
    return true;
  }

  static int dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  /// 오늘 출석 보상을 받을 수 있으면 보상량, 아니면 null
  int? pendingLogin(DateTime now) {
    // 시계를 되돌려 같은 날/과거 날짜로 다시 받는 것 방지
    if (dayKey(now) <= lastLoginDay) return null;
    return loginRewards[(_nextStreak(now) - 1) % 7];
  }

  int _nextStreak(DateTime now) {
    final y = now.subtract(const Duration(days: 1));
    return dayKey(y) == lastLoginDay ? loginStreak + 1 : 1;
  }

  /// 출석 보상 수령, 받은 젬 반환
  int claimLogin(DateTime now) {
    final r = pendingLogin(now);
    if (r == null) return 0;
    loginStreak = _nextStreak(now);
    lastLoginDay = dayKey(now);
    gems += r;
    dirty = true;
    return r;
  }

  int adGemsLeft(DateTime now) {
    final key = dayKey(now);
    if (key < adGemDay) return 0; // 시계 되돌리기 방지
    return key == adGemDay ? adGemsPerDay - adGemsToday : adGemsPerDay;
  }

  bool claimAdGems(DateTime now) {
    if (adGemsLeft(now) <= 0) return false;
    if (dayKey(now) != adGemDay) {
      adGemDay = dayKey(now);
      adGemsToday = 0;
    }
    adGemsToday++;
    gems += adGemAmount;
    dirty = true;
    return true;
  }

  // ---------- 광고 부활 ----------
  /// 광고 보고 제자리 부활은 하루 [adRevivesPerDay]번 (사령관 패스는 무제한).
  /// 무제한이면 격추가 아무 손해가 없어 ⭐10 부활·함선 강화의 의미가 사라진다.
  static const adRevivesPerDay = 3;
  int adReviveDay = 0;
  int adRevivesToday = 0;

  int adRevivesLeft(DateTime now) {
    if (premium) return adRevivesPerDay;
    final key = dayKey(now);
    if (key < adReviveDay) return 0; // 시계 되돌리기 방지
    return key == adReviveDay ? max(0, adRevivesPerDay - adRevivesToday) : adRevivesPerDay;
  }

  bool useAdRevive(DateTime now) {
    if (adRevivesLeft(now) <= 0) return false;
    if (premium) return true;
    if (dayKey(now) != adReviveDay) {
      adReviveDay = dayKey(now);
      adRevivesToday = 0;
    }
    adRevivesToday++;
    dirty = true;
    return true;
  }

  // ---------- 격납고 ----------
  bool shipUnlocked(ShipType t) =>
      ownedShips.contains(t.id) ||
      (!t.premium && (t.unlockStat == null || stat(t.unlockStat!) >= t.unlockTarget));

  bool buyShip(ShipType t) {
    if (shipUnlocked(t) || !spendGems(t.gemPrice)) return false;
    ownedShips.add(t.id);
    return true;
  }

  // ---------- 은하 명예 ----------
  /// 명예 1점당 수입 +5%, 공격력 +3%
  double get honorIncomeMul => 1 + honor * 0.05;
  double get honorDamageMul => 1 + honor * 0.03;

  // ---------- 일일 퀘스트 ----------
  /// 날짜가 바뀌었으면 오늘의 퀘스트 3개를 새로 뽑는다
  void refreshDaily(DateTime now) {
    final key = dayKey(now);
    if (key == dailyDay && dailyIds.isNotEmpty) return;
    dailyDay = key;
    dailyIds
      ..clear()
      ..addAll(([...dailyPool]..shuffle(Random(key))).take(3).map((q) => q.id));
    dailyBase.clear();
    for (final q in dailyQuests) {
      dailyBase[q.stat] = stat(q.stat);
    }
    dailyClaimed.clear();
    dirty = true;
  }

  List<DailyQuestDef> get dailyQuests =>
      [for (final id in dailyIds) dailyPool.firstWhere((q) => q.id == id)];

  int dailyProgress(DailyQuestDef q) =>
      min(q.target, stat(q.stat) - (dailyBase[q.stat] ?? stat(q.stat)));

  bool dailyDone(DailyQuestDef q) => dailyProgress(q) >= q.target;

  bool get dailyBonusReady =>
      dailyIds.isNotEmpty &&
      dailyIds.every(dailyClaimed.contains) &&
      !dailyClaimed.contains('bonus');

  int get dailyClaimable =>
      dailyQuests.where((q) => dailyDone(q) && !dailyClaimed.contains(q.id)).length +
      (dailyBonusReady ? 1 : 0);

  bool claimDaily(String id) {
    if (dailyClaimed.contains(id)) return false;
    if (id == 'bonus') {
      if (!dailyBonusReady) return false;
      gems += dailyBonusGems;
    } else {
      final q = dailyQuests.where((q) => q.id == id).firstOrNull;
      if (q == null || !dailyDone(q)) return false;
      gems += q.gems;
    }
    dailyClaimed.add(id);
    dirty = true;
    return true;
  }

  bool spendGems(int n) {
    if (gems < n) return false;
    gems -= n;
    dirty = true;
    return true;
  }

  Map<String, dynamic> toJson() => {
        'gems': gems,
        'premium': premium,
        'starter': starterBought,
        'tx': grantedTx.toList(),
        'txSince': txSince.millisecondsSinceEpoch,
        'slots': extraCrewSlots,
        'rosterPacks': rosterPacks,
        'skins': ownedSkins.toList(),
        'outfits': ownedOutfits.toList(),
        'skin': skin,
        'outfit': outfit,
        'claimed': claimed.toList(),
        'stats': stats,
        'loginDay': lastLoginDay,
        'streak': loginStreak,
        'adDay': adGemDay,
        'adCount': adGemsToday,
        'revDay': adReviveDay,
        'revCount': adRevivesToday,
        'sound': sound,
        'music': music,
        'haptics': haptics,
        'tutorial': tutorialDone,
        'colonyTut': colonyTutorialSeen,
        'pendingCrew': pendingStarCrew,
        'ship': shipType,
        'ships': ownedShips.toList(),
        'honor': honor,
        'ascensions': ascensions,
        'dailyDay': dailyDay,
        'dailyIds': dailyIds,
        'dailyBase': dailyBase,
        'dailyClaimed': dailyClaimed.toList(),
        'notifications': notifications,
        'lang': language,
        'home': home.toJson(),
        'lbId': installId,
        'lbNick': nicknameCode,
        'lbOptIn': leaderboardOptIn,
        'lbRerolls': nicknameRerolls,
        'weekly': weeklyScore.toJson(),
      };

  static Profile fromJson(Map<String, dynamic> j) {
    final p = Profile()
      ..gems = j['gems'] as int? ?? 0
      ..premium = j['premium'] as bool? ?? false
      ..starterBought = j['starter'] as bool? ?? false
      ..grantedTx = {...((j['tx'] as List?)?.cast<String>() ?? const <String>[])}
      ..txSince = j['txSince'] is int ? DateTime.fromMillisecondsSinceEpoch(j['txSince'] as int) : DateTime.now()
      // 예전 저장: 'slot'(bool) 하나 → 슬롯 1개
      ..extraCrewSlots = (j['slots'] as int? ?? ((j['slot'] as bool? ?? false) ? 1 : 0))
          .clamp(0, crewSlotPrices.length)
      ..rosterPacks = (j['rosterPacks'] as int? ?? 0).clamp(0, maxRosterPacks)
      ..skin = j['skin'] as String? ?? 'default'
      ..outfit = j['outfit'] as String? ?? 'default'
      ..lastLoginDay = j['loginDay'] as int? ?? 0
      ..loginStreak = j['streak'] as int? ?? 0
      ..adGemDay = j['adDay'] as int? ?? 0
      ..adGemsToday = j['adCount'] as int? ?? 0
      ..adReviveDay = j['revDay'] as int? ?? 0
      ..adRevivesToday = j['revCount'] as int? ?? 0
      ..sound = j['sound'] as bool? ?? true
      ..music = j['music'] as bool? ?? true
      ..haptics = j['haptics'] as bool? ?? true
      ..tutorialDone = j['tutorial'] as bool? ?? false
      ..colonyTutorialSeen = j['colonyTut'] as bool? ?? false
      ..pendingStarCrew = j['pendingCrew'] as int? ?? 0
      ..shipType = j['ship'] as String? ?? 'scout'
      ..honor = j['honor'] as int? ?? 0
      ..ascensions = j['ascensions'] as int? ?? 0
      ..dailyDay = j['dailyDay'] as int? ?? 0
      ..notifications = j['notifications'] as bool? ?? true
      ..language = j['lang'] as String?
      ..installId = j['lbId'] as String?
      ..nicknameCode = j['lbNick'] as String?
      ..leaderboardOptIn = j['lbOptIn'] as bool? ?? false
      ..nicknameRerolls = j['lbRerolls'] as int? ?? 0
      ..weeklyScore = WeeklyScore.fromJson(j['weekly'] is Map ? (j['weekly'] as Map).cast<String, dynamic>() : null);
    if (j['home'] is Map) {
      p.home = HomePlanet.fromJson((j['home'] as Map).cast<String, dynamic>());
    }
    p.ownedShips.addAll(((j['ships'] as List?) ?? []).cast<String>());
    p.dailyIds.addAll(((j['dailyIds'] as List?) ?? []).cast<String>());
    p.dailyClaimed.addAll(((j['dailyClaimed'] as List?) ?? []).cast<String>());
    ((j['dailyBase'] as Map?) ?? {}).forEach((k, v) => p.dailyBase[k as String] = v as int);
    p.ownedSkins.addAll(((j['skins'] as List?) ?? []).cast<String>());
    p.ownedOutfits.addAll(((j['outfits'] as List?) ?? []).cast<String>());
    p.claimed.addAll(((j['claimed'] as List?) ?? []).cast<String>());
    final s = (j['stats'] as Map?) ?? {};
    s.forEach((k, v) => p.stats[k as String] = v as int);
    return p;
  }
}
