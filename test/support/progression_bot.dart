import 'dart:math';
import 'dart:ui';

import 'package:star_settlers/game/crew.dart';
import 'package:star_settlers/game/missions.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/ships.dart';
import 'package:star_settlers/game/world.dart';

/// 하루에 받는 무료 젬 (실시간 기준, 게임 밖에서 생기는 것만)
/// - 출석: 7일 주기 [loginRewards] 평균
/// - 광고: [Profile.adGemsPerDay] × [Profile.adGemAmount]
/// - 일일 퀘스트: 3개 평균 보상 + 완료 보너스 (매일 다 깬다고 가정)
/// - 내 행성 선물: 8시간마다 1개
double freeGemsPerDay() {
  final login = loginRewards.reduce((a, b) => a + b) / loginRewards.length;
  const ads = Profile.adGemsPerDay * Profile.adGemAmount;
  final quest = dailyPool.map((q) => q.gems).reduce((a, b) => a + b) / dailyPool.length * 3 +
      dailyBonusGems;
  const harvest = 24 / 8 * 1;
  return login + ads + quest + harvest;
}

/// 항성계 하나의 기록
class SectorLog {
  SectorLog(this.sector);
  final int sector;
  double playMinutes = 0;
  int sessions = 0;
  double days = 0;
  int deaths = 0;
  int baseDisables = 0;
  int baseRespawns = 0;

  /// 습격으로 잃은 식민지 레벨
  int raidLosses = 0;

  /// 생산 말고 직접 번 크레딧 (현상금·임무·보상), 오프라인 수입, 생산 수입
  double activeCredits = 0;
  double offlineCredits = 0;
  double incomeCredits = 0;
  double packCredits = 0;
  int gemsAtEnd = 0;
  int gemsSpent = 0;
  bool done = false;

  /// 아무것도 못 산 세션 수 (진행 정체)
  int stallSessions = 0;
  final bottleneck = <String, int>{};

  /// 목표별로 쓴 시간(초)
  final goalTime = <String, double>{};
  double incomeAtEnd = 0;
  int shipLevels = 0;
  int baseLevel = 1;

  @override
  String toString() =>
      'S${sector + 1}: ${done ? '' : '(미완) '}${playMinutes.toStringAsFixed(1)}분 '
      '세션$sessions ${days.toStringAsFixed(1)}일 사망$deaths(기지$baseRespawns) 본거지정지$baseDisables 약탈$raidLosses '
      '젬$gemsAtEnd(소비$gemsSpent) 정체세션$stallSessions 병목$bottleneck '
      '벌이(생산${_k(incomeCredits)} 직접${_k(activeCredits)} 오프${_k(offlineCredits)} 팩${_k(packCredits)}) '
      '수입${incomeAtEnd.toStringAsFixed(0)}/s 함선Lv$shipLevels 본거지Lv$baseLevel '
      '${goalTime.map((k, v) => MapEntry(k, (v / 60).toStringAsFixed(1)))}';
}

String _k(double v) => v >= 1e6 ? '${(v / 1e6).toStringAsFixed(1)}M' : '${(v / 1e3).toStringAsFixed(0)}k';

class BotRun {
  BotRun(this.seed, this.logs, this.world);
  final int seed;
  final List<SectorLog> logs;
  final GameWorld world;
}

/// 현실적인 플레이어 봇.
/// - 하루 [sessionsPerDay]번, 한 번에 [sessionMinutes]분 플레이
/// - 세션 사이에는 오프라인 수입 (광고 2배를 본다고 가정), 내 행성 선물, 하루치 무료 젬
/// - 크레딧은 발전도(모든 행성 Lv.3) → 함선 강화 → 본거지 강화 순으로 저렴한 것부터
/// - 무료 젬은 막혔을 때 크레딧 팩으로 바꾼다
/// - [paying]이면 [payAtSector] 항성계에 도착하자마자 ⭐[payGems]를 사서
///   프리미엄 함선·전설 승무원·배치 슬롯에 쓴다
class ProgressionBot {
  ProgressionBot(
    this.seed, {
    this.paying = false,
    this.payAtSector = 2,
    this.payGems = 1200,
    this.payWithPacks = false,
    this.buyPass = false,
    this.passAndGear = false,
    this.sessionMinutes = 12.5,
    this.sessionsPerDay = 3,
    this.dt = 1 / 20,
    this.useOffline = true,
    this.dailyGems = true,
  });

  final int seed;
  final bool paying;
  final int payAtSector;
  final int payGems;

  /// true면 산 젬을 전부 크레딧 팩으로 (막힐 때마다 바꿔 쓴다)
  final bool payWithPacks;

  /// true면 젬 대신 사령관 패스(₩6,500)를 산다
  final bool buyPass;

  /// true면 사령관 패스도 사고 ⭐[payGems]도 사서 장비(함선·전설·슬롯)에 쓴다
  final bool passAndGear;
  final double sessionMinutes;
  final int sessionsPerDay;
  final double dt;
  final bool useOffline;
  final bool dailyGems;

  late final GameWorld w = GameWorld(seed: seed);
  final input = InputState()
    ..fire = true
    ..autoAim = true;
  bool _retreating = false;
  bool _paid = false;
  double _decide = 0;
  Offset? _goal;
  String _goalWhy = '';
  int _boughtThisSession = 0;
  int _gemsSpent = 0;
  final _stationTried = <int>{};

  /// 시뮬레이션 날짜 (광고 부활 횟수 등 하루 단위 제한용)
  DateTime now = DateTime(2026, 1, 1, 9);

  late SectorLog _log;
  final logs = <SectorLog>[];

  /// [lastSector](0부터)를 100%로 만들 때까지, 또는 [maxDays]일까지 돈다
  BotRun run({int lastSector = 5, double maxDays = 60}) {
    _log = SectorLog(0);
    logs.add(_log);
    var day = 0.0;
    var session = 0;
    var finished = false;
    final end = sessionMinutes * 60;
    while (day < maxDays && !finished) {
      _boughtThisSession = 0;
      _log.sessions++;
      var t = 0.0;
      while (t < end) {
        final dev = _tick();
        t += dt;
        _log.playMinutes += dt / 60;
        if (dev && !_log.done) {
          _log
            ..done = true
            ..days = day + (session % sessionsPerDay + t / end) / sessionsPerDay
            ..gemsAtEnd = w.profile.gems
            ..gemsSpent = _gemsSpent
            ..incomeAtEnd = w.creditIncome
            ..shipLevels = w.levels.values.fold(0, (a, b) => a + b)
            ..baseLevel = w.homeBase.baseLevel;
          if (w.sector >= lastSector) {
            finished = true;
            break;
          }
        }
        if (_warped()) {
          _log = SectorLog(w.sector)..sessions = 1;
          logs.add(_log);
        }
      }
      if (finished) break;
      if (_boughtThisSession == 0) _log.stallSessions++;
      session++;
      // 세션 사이 (오프라인)
      if (useOffline) {
        // 세션 사이 시간만큼 자리 비움 → 오프라인 수입 (광고 2배 / 패스 자동 2배)
        final gap = ((24 * 60 / sessionsPerDay - sessionMinutes) * 60).round();
        final t0 = DateTime(2026, 1, 1);
        w.savedAt = t0;
        final (_, c, o) = w.offlineEarnings(t0.add(Duration(seconds: gap)));
        w.applyOffline(c * 2, o * 2);
        _log.offlineCredits += c * 2;
        // 내 행성 선물 (8시간마다)
        if (session % max(1, (sessionsPerDay * 8 / 24).round()) == 0) {
          final r = w.home.harvestReward(w.rewardMul);
          w.credits += r.$1;
          w.profile.gems += r.$2;
        }
      }
      if (session % sessionsPerDay == 0) {
        day++;
        now = now.add(const Duration(days: 1));
        if (dailyGems) w.profile.gems += (freeGemsPerDay() - 3).round(); // 선물 젬은 위에서
      }
    }
    if (!_log.done) {
      _log
        ..days = day
        ..gemsAtEnd = w.profile.gems
        ..gemsSpent = _gemsSpent;
    }
    return BotRun(seed, logs, w);
  }

  int _lastSectorSeen = 0;
  bool _warped() {
    if (w.sector != _lastSectorSeen) {
      _lastSectorSeen = w.sector;
      _stationTried.clear();
      return true;
    }
    return false;
  }

  /// 한 틱. 발전도 100%면 true
  bool _tick() {
    final p = w.player;
    if (!p.alive) {
      _log.deaths++;
      // 광고 부활(하루 제한) → 유료면 ⭐10 부활 → 기지 재출격(크레딧 손실)
      if (w.profile.useAdRevive(now)) {
        w.reviveHere();
      } else if (paying && w.profile.spendGems(10)) {
        _gemsSpent += 10;
        w.reviveHere();
      } else {
        _log.baseRespawns++;
        w.respawnAtBase();
      }
      _retreating = true;
    }
    if (paying && !_paid && w.sector >= payAtSector) _pay();
    final wasDisabled = w.homeBase.disabled;
    final sec0 = w.sector;
    final lv0 = w.planets.fold<int>(0, (a, pl) => a + pl.colonyLevel);
    _decide -= dt;
    if (_decide <= 0) {
      _decide = 0.5;
      _think();
    }
    final g = _goal ?? p.pos;
    final to = _avoidStar(p.pos, g) - p.pos;
    input.move = to.distance > 30 ? to.normalized() : Offset.zero;
    if (w.pirates.any((e) => e.isPirate && (e.pos - p.pos).distance < 500)) {
      w.fireMissiles();
      if (p.hp < w.playerMaxHp * 0.5) w.activateShield();
    }
    final c0 = w.credits;
    final inc = w.creditIncome * dt;
    w.update(dt, input);
    final gain = w.credits - c0 - inc;
    _log.incomeCredits += inc;
    if (gain > 0) _log.activeCredits += gain;
    _log.goalTime[_goalWhy] = (_log.goalTime[_goalWhy] ?? 0) + dt;
    if (!wasDisabled && w.homeBase.disabled) _log.baseDisables++;
    if (w.sector == sec0) {
      final lv1 = w.planets.fold<int>(0, (a, pl) => a + pl.colonyLevel);
      // 같은 틱에 산 것은 _act에서 일어나므로 여기서 줄었다면 약탈
      if (lv1 < lv0) _log.raidLosses += lv0 - lv1;
    }
    _act();
    return w.development >= 1;
  }

  /// 항성 쪽으로 곧장 날아가면 막히니 옆으로 비켜 간다
  Offset _avoidStar(Offset from, Offset to) {
    final d = to - from;
    final len = d.distance;
    if (len < 1) return to;
    final u = d / len;
    final tProj = -(from.dx * u.dx + from.dy * u.dy);
    if (tProj <= 0 || tProj >= len) return to;
    final closest = from + u * tProj;
    if (closest.distance > GameWorld.starRadius + 120) return to;
    final side = closest.distance < 1 ? Offset(-u.dy, u.dx) : closest.normalized();
    return closest + side * (GameWorld.starRadius + 300);
  }

  // ---------- 무엇을 살까 ----------
  int get _shipTarget => min(8, 2 + w.sector * 2);

  /// 다음에 살 것: (비용, 어디서, 무엇, 실행)
  (Cost, Offset, String, bool Function())? _nextBuy() {
    final options = <(Cost, Offset, String, bool Function())>[];
    final todo = w.planets.where((pl) => pl.colonyLevel < GameWorld.devLevelCap).toList();
    for (final pl in todo) {
      options.add((w.planetCost(pl), pl.pos, 'planet', () => w.upgradePlanet(pl)));
    }
    final home = w.homeBase.pos;
    for (final k in [UpgradeKind.weapon, UpgradeKind.hull]) {
      if (w.level(k) < _shipTarget) {
        options.add((w.upgradeCost(k), home, 'ship', () => w.upgradeShip(k)));
      }
    }
    if (w.level(UpgradeKind.engine) < min(5, 1 + w.sector)) {
      options.add((w.upgradeCost(UpgradeKind.engine), home, 'ship',
          () => w.upgradeShip(UpgradeKind.engine)));
    }
    if (w.sector >= 1 && w.level(UpgradeKind.missile) < min(5, w.sector)) {
      options.add((w.upgradeCost(UpgradeKind.missile), home, 'ship',
          () => w.upgradeShip(UpgradeKind.missile)));
    }
    if (w.sector >= 1 && w.level(UpgradeKind.drone) < min(5, w.sector)) {
      options.add((w.upgradeCost(UpgradeKind.drone), home, 'ship',
          () => w.upgradeShip(UpgradeKind.drone)));
    }
    if (w.homeBase.baseLevel < 1 + w.sector) {
      options.add((w.baseUpgradeCost(w.homeBase), home, 'base', () => w.upgradeBase(w.homeBase)));
    }
    if (w.roster.length < w.crewSlots && w.roster.length < 3) {
      options.add(((w.recruitCost, 0), home, 'crew', () => w.recruitWithCredits() != null));
    }
    if (options.isEmpty) return null;
    // 크레딧+광석을 같이 따진 '부족분'이 가장 작은 것부터
    double need((Cost, Offset, String, bool Function()) o) =>
        o.$1.$1 + o.$1.$2 * 3.0 + (o.$2 - w.player.pos).distance * 0.05;
    options.sort((a, b) => need(a).compareTo(need(b)));
    return options.first;
  }

  void _think() {
    final p = w.player;
    if (_retreating || p.hp < w.playerMaxHp * 0.35) {
      _retreating = p.hp < w.playerMaxHp * 0.9;
      final st = w.stations.reduce(
          (a, b) => (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b);
      _goal = st.pos;
      _goalWhy = 'repair';
      if (_retreating) return;
    }
    // 발전 완료 → 앞 게이트
    if (w.development >= 1) {
      _goal = w.gates.firstWhere((g) => g.forward).pos;
      _goalWhy = 'gate';
      return;
    }
    // 습격 받은 식민지 지키기
    final raid = w.events.where((e) => e.kind == EventKind.raid && e.planet != null).firstOrNull;
    if (raid != null && w.pirates.any((e) => e.eventId == raid.id)) {
      final attackers = w.pirates.where((e) => e.eventId == raid.id).toList();
      final e = attackers.reduce(
          (a, b) => (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b);
      final d = (e.pos - p.pos).distance;
      _goal = d > 300 ? e.pos : p.pos + (p.pos - e.pos);
      _goalWhy = 'raid';
      return;
    }
    // 살 수 있는 것이 있으면 바로 사러 간다 (가는 길에 자동 사격)
    final buy = _nextBuy();
    var lackOre = false;
    if (buy != null) {
      final (cost, where, why, _) = buy;
      if (w.canAfford(cost)) {
        _goal = where;
        _goalWhy = why;
        return;
      }
      lackOre = w.ore < cost.$2;
      final key = lackOre ? 'ore' : 'credits';
      _log.bottleneck[key] = (_log.bottleneck[key] ?? 0) + 1;
      // 젬은 모자란 크레딧을 크레딧 팩으로 메우는 데 쓴다
      if (!lackOre &&
          w.profile.gems >= GameWorld.creditPackGems &&
          w.buyCreditsWithGems()) {
        _gemsSpent += GameWorld.creditPackGems;
        _log.packCredits += w.creditPackAmount;
        _decide = 0;
        return;
      }
    }
    // 보급 캡슐(젬)은 가까우면 줍는다
    final cap = w.supplyCapsule;
    if (cap != null && (cap.pos - p.pos).distance < 2500) {
      _goal = cap.pos;
      _goalWhy = 'capsule';
      return;
    }
    // 가까운 해적과 싸운다
    final near = w.pirates
        .where((e) => e.isPirate && (e.pos - p.pos).distance < 700)
        .toList();
    if (near.isNotEmpty) {
      final e = near.reduce(
          (a, b) => (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b);
      final d = (e.pos - p.pos).distance;
      _goal = d > 300 ? e.pos : p.pos + (p.pos - e.pos);
      _goalWhy = 'fight';
      return;
    }
    // 가까운 아이템
    if (w.pickups.isNotEmpty) {
      final k = w.pickups.reduce(
          (a, b) => (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b);
      if ((k.pos - p.pos).distance < 450) {
        _goal = k.pos;
        _goalWhy = 'pickup';
        return;
      }
    }
    if (lackOre) {
      _goal = _nearestAsteroid();
      _goalWhy = 'mine';
      return;
    }
    // 보급 기지 하나 (스토리·생산 보너스)
    if (w.stations.length < 2 && w.colonyCount >= 3 && w.canAfford(w.stationBuildCost)) {
      _goal = _stationSpot();
      _goalWhy = 'station';
      return;
    }
    // 그 밖엔 해적 사냥 → 없으면 채굴
    final far = w.pirates.where((e) => e.isPirate).toList();
    if (far.isNotEmpty) {
      final e = far.reduce(
          (a, b) => (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b);
      if ((e.pos - p.pos).distance < 1800) {
        _goal = e.pos;
        _goalWhy = 'hunt';
        return;
      }
    }
    _goal = _nearestAsteroid();
    _goalWhy = 'mine';
  }

  Offset _nearestAsteroid() {
    final p = w.player;
    if (w.asteroids.isEmpty) return p.pos;
    return w.asteroids
        .reduce((a, b) => (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b)
        .pos;
  }

  Offset _stationSpot() {
    // 본거지에서 1000 떨어진 후보들
    for (var i = 0; i < 8; i++) {
      if (_stationTried.contains(i)) continue;
      final c = GameWorld.homePos + OffsetX.fromAngle(i * pi / 4, 1050);
      if (c.distance < GameWorld.starRadius + 450) continue;
      return c;
    }
    return GameWorld.homePos + const Offset(0, 1050);
  }

  /// 목표 근처에 오면 실제로 산다
  void _act() {
    final p = w.player;
    if (!p.alive) return;
    // 정거장: 임무 수락 (처치·채굴), 강화
    final st = w.nearbyStation;
    if (st != null) {
      for (final m in [...w.missionOffers]) {
        if (m.type == MissionType.kill || m.type == MissionType.mine) w.acceptMission(m);
      }
    }
    if (_goalWhy == 'station' && w.canBuildStationHere) {
      if (w.buildStation(StationRole.support)) _boughtThisSession++;
      return;
    }
    if (_goalWhy == 'station' && _goal != null && (p.pos - _goal!).distance < 60) {
      // 이 자리가 안 되면 다음 후보
      for (var i = 0; i < 8; i++) {
        final c = GameWorld.homePos + OffsetX.fromAngle(i * pi / 4, 1050);
        if ((c - _goal!).distance < 1) _stationTried.add(i);
      }
      _decide = 0;
    }
    if (w.development >= 1) {
      final g = w.nearbyGate;
      if (g != null && g.forward) w.warp(g);
      return;
    }
    // 가까이 있는 것만 산다 (행성은 행성 옆, 나머지는 정거장 옆)
    for (var i = 0; i < 6; i++) {
      final buy = _nextBuy();
      if (buy == null || !w.canAfford(buy.$1)) return;
      final near = buy.$3 == 'planet'
          ? w.nearbyPlanet != null && (w.nearbyPlanet!.pos - buy.$2).distance < 1
          : st != null;
      if (!near) return;
      if (!buy.$4()) return;
      _boughtThisSession++;
      _decide = 0;
    }
  }

  void _pay() {
    _paid = true;
    final prof = w.profile;
    if (buyPass || passAndGear) {
      prof.premium = true;
      if (!passAndGear) return;
    }
    prof.gems += payGems;
    if (payWithPacks) return; // 크레딧 팩은 _think에서 모자랄 때마다
    // 프리미엄 함선 (오로라 ⭐600) + 전설 승무원 (⭐500) + 배치 슬롯 (⭐100)
    final aurora = shipTypes.firstWhere((s) => s.id == 'aurora');
    final g0 = prof.gems;
    w.buyShip(aurora);
    w.recruitLegendary();
    prof.buyCrewSlot();
    _gemsSpent += g0 - prof.gems;
    // 전설 승무원 배치 (슬롯이 꽉 찼으면 가장 약한 승무원을 뺀다)
    final legend = w.roster.where((c) => c.rarity == 4).firstOrNull;
    if (legend != null && !legend.assigned) {
      final weakest = w.roster.where((c) => c.assigned).fold<CrewMember?>(
          null, (a, c) => a == null || c.bonusPct < a.bonusPct ? c : a);
      if (weakest != null) w.toggleAssign(weakest);
      w.toggleAssign(legend);
    }
  }
}

/// [sector] 항성계로 바로 보낸 월드 (모든 행성 Lv.3, 위협도 최대)
GameWorld worldAtSector(int seed, int sector, {int weapon = 8, int hull = 8}) {
  final w = GameWorld(seed: seed);
  w.counters['maxSector'] = 99;
  for (var i = 0; i < sector; i++) {
    w.warp(w.gates.firstWhere((g) => g.forward));
  }
  for (final p in w.planets) {
    p.colonyLevel = GameWorld.devLevelCap;
    p.shieldHp = p.shieldMax(w.sectorMul);
  }
  w.levels[UpgradeKind.weapon] = weapon;
  w.levels[UpgradeKind.hull] = hull;
  w.sectorElapsed = 9 * 60;
  w.player.hp = w.playerMaxHp;
  return w;
}

/// 본거지 안전 구역에서 버티며 레이저가 잡은 해적 현상금만 줍는 '파밍'.
/// 반환: 분당 현상금 크레딧(생산 수입 제외), 사망, 본거지 정지 횟수
Map<String, double> baseFarm(GameWorld w, double minutes, {double dt = 1 / 20, bool shoot = true}) {
  final input = InputState()
    ..fire = shoot
    ..autoAim = true;
  final home = w.homeBase.pos;
  var bounty = 0.0;
  var deaths = 0;
  var disables = 0;
  final lv0 = w.planets.fold<int>(0, (a, p) => a + p.colonyLevel);
  w.player.pos = home + const Offset(0, 100);
  for (var t = 0.0; t < minutes * 60; t += dt) {
    if (!w.player.alive) {
      deaths++;
      w.respawnAtBase();
    }
    // 안전 구역 안에서 가장 가까운 아이템만 줍고, 없으면 본거지 옆에 머문다
    final p = w.player;
    var goal = home + const Offset(0, 100);
    final items = w.pickups.where((k) => (k.pos - home).distance < w.homeBase.safeRadius - 40).toList();
    if (items.isNotEmpty) {
      goal = items.reduce((a, b) => (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b).pos;
    }
    final to = goal - p.pos;
    input.move = to.distance > 20 ? to.normalized() : Offset.zero;
    final c0 = w.credits;
    final wasDisabled = w.homeBase.disabled;
    w.update(dt, input);
    if (!wasDisabled && w.homeBase.disabled) disables++;
    final gain = w.credits - c0 - w.creditIncome * dt;
    if (gain > 0) bounty += gain;
  }
  return {'bountyPerMin': bounty / minutes, 'colonyLevelsLost': (lv0 - w.planets.fold<int>(0, (a, p) => a + p.colonyLevel)).toDouble(), 'deaths': deaths.toDouble(), 'disables': disables.toDouble(),
    'incomePerMin': w.creditIncome * 60};
}

/// 전투만 재는 봇: 가까운 해적을 쫓아 자동 사격하고 체력 35% 아래면 본거지로 물러나 수리한다.
/// 반환: 사망, 받은 피해(최대 체력 대비 배수), 처치 수, 직접 번 크레딧/분
Map<String, double> huntFight(GameWorld w, double minutes, {double dt = 1 / 20}) {
  final input = InputState()
    ..fire = true
    ..autoAim = true;
  var deaths = 0;
  var taken = 0.0;
  var earned = 0.0;
  var retreat = false;
  final kills0 = w.counter('kills');
  for (var t = 0.0; t < minutes * 60; t += dt) {
    final p = w.player;
    if (!p.alive) {
      deaths++;
      w.respawnAtBase();
    }
    if (p.hp < w.playerMaxHp * 0.35) retreat = true;
    if (retreat && p.hp >= w.playerMaxHp * 0.9) retreat = false;
    var goal = w.homeBase.pos;
    if (!retreat) {
      final foes = w.pirates.where((e) => e.isPirate).toList();
      if (foes.isNotEmpty) {
        final e = foes.reduce((a, b) => (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b);
        final d = (e.pos - p.pos).distance;
        goal = d > 300 ? e.pos : p.pos + (p.pos - e.pos);
      }
    }
    final to = goal - p.pos;
    input.move = to.distance > 30 ? to.normalized() : Offset.zero;
    if (w.pirates.any((e) => e.isPirate && (e.pos - p.pos).distance < 500)) {
      w.fireMissiles();
      if (p.hp < w.playerMaxHp * 0.5) w.activateShield();
    }
    final hp0 = p.alive ? p.hp : 0.0;
    final c0 = w.credits;
    w.update(dt, input);
    if (p.alive && p.hp < hp0) taken += hp0 - p.hp;
    if (!p.alive) taken += hp0;
    final gain = w.credits - c0 - w.creditIncome * dt;
    if (gain > 0) earned += gain;
  }
  return {
    'deaths': deaths.toDouble(),
    'damageTaken': taken / w.playerMaxHp,
    'kills': (w.counter('kills') - kills0).toDouble(),
    'creditsPerMin': earned / minutes,
  };
}
