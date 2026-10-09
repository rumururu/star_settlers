import 'dart:math';
import 'dart:ui';

import '../l10n/l.dart';

import 'crew.dart';
import 'home.dart';
import 'missions.dart';
import 'models.dart';
import 'profile.dart';
import 'ships.dart';

class InputState {
  Offset move = Offset.zero; // 길이 0..1
  bool fire = false;

  /// true면 360° 가장 가까운 적을 자동 조준 (자동 사격 모드)
  bool autoAim = false;
}

enum UpgradeKind { weapon, hull, engine, missile, shield, drone, magnet }

extension UpgradeInfo on UpgradeKind {
  String get label => switch (this) {
        UpgradeKind.weapon => tr.g_upgradeWeapon,
        UpgradeKind.hull => tr.g_upgradeHull,
        UpgradeKind.engine => tr.g_upgradeEngine,
        UpgradeKind.missile => tr.g_upgradeMissile,
        UpgradeKind.shield => tr.g_upgradeShield,
        UpgradeKind.drone => tr.g_upgradeDrone,
        UpgradeKind.magnet => tr.g_upgradeMagnet,
      };
  int get maxLevel => switch (this) {
        UpgradeKind.missile || UpgradeKind.shield || UpgradeKind.drone || UpgradeKind.magnet => 5,
        _ => 8,
      };
}

/// 다른 섹터에 두고 온 개척 상태
class SectorSave {
  SectorSave({
    required this.colonyLevels,
    required this.stations,
    required this.elapsed,
    required this.bossDefeated,
    required this.bossesSpawned,
    required this.idleCredits,
    required this.idleOre,
    this.buildings = const [],
  });
  final List<int> colonyLevels;

  /// 행성별 식민지 건물 레벨 (ColonyBuilding.index 순서)
  final List<List<int>> buildings;
  final List<Map<String, dynamic>> stations;
  final double elapsed;
  final bool bossDefeated;
  final int bossesSpawned;
  final double idleCredits;
  final double idleOre;

  Map<String, dynamic> toJson() => {
        'colonies': colonyLevels,
        'stations': stations,
        'elapsed': elapsed,
        'boss': bossDefeated,
        'bosses': bossesSpawned,
        'ic': idleCredits,
        'io': idleOre,
        'bld': buildings,
      };

  static SectorSave fromJson(Map<String, dynamic> j) => SectorSave(
        colonyLevels: (j['colonies'] as List).cast<int>(),
        stations: (j['stations'] as List).cast<Map<String, dynamic>>(),
        elapsed: (j['elapsed'] as num).toDouble(),
        bossDefeated: j['boss'] as bool,
        bossesSpawned: j['bosses'] as int,
        idleCredits: (j['ic'] as num).toDouble(),
        idleOre: (j['io'] as num).toDouble(),
        buildings: [
          for (final b in (j['bld'] as List?) ?? const []) (b as List).cast<int>(),
        ],
      );
}

List<String> get sectorNames => [
      tr.g_sector0,
      tr.g_sector1,
      tr.g_sector2,
      tr.g_sector3,
      tr.g_sector4,
      tr.g_sector5,
      tr.g_sector6,
      tr.g_sector7,
      tr.g_sector8,
      tr.g_sector9,
    ];

/// 행성 이름 풀. 순서와 개수가 월드 생성 난수에 묶여 있으니 바꾸지 않는다.
List<String> get _planetPool => [
      tr.g_planet0,
      tr.g_planet1,
      tr.g_planet2,
      tr.g_planet3,
      tr.g_planet4,
      tr.g_planet5,
      tr.g_planet6,
      tr.g_planet7,
      tr.g_planet8,
      tr.g_planet9,
      tr.g_planet10,
      tr.g_planet11,
      tr.g_planet12,
      tr.g_planet13,
      tr.g_planet14,
      tr.g_planet15,
      tr.g_planet16,
      tr.g_planet17,
      tr.g_planet18,
      tr.g_planet19,
      tr.g_planet20,
      tr.g_planet21,
      tr.g_planet22,
      tr.g_planet23,
      tr.g_planet24,
      tr.g_planet25,
      tr.g_planet26,
      tr.g_planet27,
      tr.g_planet28,
      tr.g_planet29,
      tr.g_planet30,
      tr.g_planet31,
      tr.g_planet32,
      tr.g_planet33,
      tr.g_planet34,
      tr.g_planet35,
      tr.g_planet36,
      tr.g_planet37,
      tr.g_planet38,
    ];

/// 게임 전체 상태와 규칙. 렌더링/위젯과 분리되어 있어 테스트 가능.
class GameWorld {
  GameWorld({int? seed, Profile? profile})
      : seed = seed ?? Random().nextInt(1 << 30),
        profile = profile ?? Profile() {
    _rng = Random(this.seed);
    _loadSector(0, null);
    player.pos = homePos + const Offset(0, 160);
    player.hp = playerMaxHp;
    say(Speaker.advisor, tr.g_dlgWelcome);
    _startStoryStep();
  }

  static const double worldHalf = 4000;

  /// 항성은 원점, 본거지는 그 아래쪽
  static const homePos = Offset(0, 900);
  static const starRadius = 140.0;

  /// 공전 궤도: 테라노바(첫 행성) 전용 안쪽 궤도 + 나머지 두 개씩
  static const innerOrbit = 1350.0;
  static const outerOrbits = [1850.0, 2350.0, 2850.0, 3350.0, 3750.0];
  static const backGatePos = Offset(-520, 900);
  static const int maxAsteroids = 110;
  /// 기본 승무원 정원. 실제 정원은 [rosterCap]
  static const int maxRoster = 12;

  final int seed;
  final Profile profile;
  late Random _rng;

  // ---------- 현재 섹터 ----------
  int sector = 0;
  double sectorElapsed = 0;
  bool bossDefeated = false;
  bool sectorBossSpawned = false;
  int bossesSpawned = 0;
  final planets = <Planet>[];
  final stations = <Station>[];
  final gates = <WarpGate>[];
  final sectors = <int, SectorSave>{};

  // ---------- 엔티티 ----------
  final player = PlayerShip();
  final pirates = <Pirate>[];
  final bullets = <Bullet>[];
  final missiles = <Missile>[];
  final asteroids = <Asteroid>[];
  final pickups = <Pickup>[];
  final particles = <Particle>[];
  final floats = <FloatText>[];
  final dialogs = <DialogLine>[];
  final events = <WorldEvent>[];
  final buffs = <PowerUpKind, double>{};

  /// UI에서 꺼내 재생하는 효과음 큐
  final sfx = <Sfx>[];

  // ---------- 진행 ----------
  double credits = 120;
  double ore = 20;
  final levels = {for (final k in UpgradeKind.values) k: 0};
  final counters = <String, int>{};
  final roster = <CrewMember>[];
  int recruitCount = 0;
  int _nextId = 1;
  final missionOffers = <Mission>[];
  final activeMissions = <Mission>[];
  double offerTimer = 0;
  int storyIndex = 0;
  int storyBase = 0;
  double storyTimer = 0;

  double totalTime = 0;
  double spawnTimer = 25;
  double eventTimer = 70;
  double jellyTimer = 20;
  double _secondTimer = 0;
  double _playAcc = 0;
  double shake = 0;
  double boostTime = 0;
  bool paused = false;

  // 떠돌이 상인
  CrewMember? merchantCrew;
  int merchantGemTrades = 0;
  Pickup? _supplyCapsule;
  Pickup? get supplyCapsule => _supplyCapsule;

  // ---------- 파생 스탯 ----------
  int level(UpgradeKind k) => levels[k]!;
  int get weaponLevel => level(UpgradeKind.weapon);

  double crewBonus(CrewRole r) =>
      roster.where((c) => c.assigned && c.role == r).fold(0, (s, c) => s + c.bonusPct) /
      100;

  int get crewSlots => 3 + profile.extraCrewSlots;

  /// 승무원 정원 (기본 12, 젬으로 +4씩 최대 24)
  int get rosterCap => maxRoster + profile.rosterPacks * Profile.rosterPackSize;
  int get assignedCount => roster.where((c) => c.assigned).length;

  ShipType get ship => shipTypeById(profile.shipType);

  double get playerMaxHp =>
      (100 + level(UpgradeKind.hull) * 40.0) *
      (1 + crewBonus(CrewRole.engineer)) *
      ship.hpMul *
      profile.home.hpMul;
  double get playerSpeed =>
      (260 + level(UpgradeKind.engine) * 40.0) * (1 + crewBonus(CrewRole.pilot)) * ship.speedMul;
  double get playerDamage =>
      (10 + weaponLevel * 5.0) *
      (1 + crewBonus(CrewRole.gunner)) *
      ship.dmgMul *
      profile.honorDamageMul *
      profile.home.damageMul;
  double get playerFireInterval =>
      0.25 *
      pow(0.9, weaponLevel) *
      ship.fireMul *
      (buffs.containsKey(PowerUpKind.rapid) ? 0.45 : 1);
  double get magnetRadius =>
      (buffs.containsKey(PowerUpKind.magnet) ? 450.0 : 170.0) * ship.magnetMul +
      level(UpgradeKind.drone) * 30 +
      magnetLevel * magnetRangePerLevel;

  // 자석: 레벨마다 끌어오는 범위 +60, 끌어오는 힘 +30%
  int get magnetLevel => level(UpgradeKind.magnet);
  static const magnetRangePerLevel = 60.0;
  double get magnetPull => 1400 * (1 + 0.3 * magnetLevel);

  // 전투 드론
  int get droneLevel => level(UpgradeKind.drone);
  double droneAngle = 0;
  double _droneCooldown = 0;
  Offset get dronePos => player.pos + OffsetX.fromAngle(droneAngle, 48);
  double get droneDamage => (5 + droneLevel * 4) * (1 + crewBonus(CrewRole.gunner)) * profile.honorDamageMul;
  double get droneInterval => 1.2 - droneLevel * 0.15;
  int get playerShots => weaponLevel >= 6 ? 3 : (weaponLevel >= 3 ? 2 : 1);
  double get cooldownMul =>
      max(0.4, (1 - min(0.5, crewBonus(CrewRole.scientist))) * profile.home.cooldownMul);
  double get missileCooldownMax => 8 * cooldownMul;
  double get shieldCooldownMax => 18 * cooldownMul;
  double get boostCooldownMax => 4 * cooldownMul;
  bool get shielded =>
      player.shieldTime > 0 || buffs.containsKey(PowerUpKind.shield);

  /// 함선 고유 수호막(오로라)이 충전되어 있는가
  bool get guardReady => ship.guardInterval > 0 && player.guardCooldown <= 0;

  double get sectorMul => 1 + sector * 0.5;
  double get costMul => 1 + sector * 0.3;
  String get sectorName =>
      sector < sectorNames.length ? sectorNames[sector] : tr.g_unknownSector(sector + 1);

  int get colonyCount => planets.where((p) => p.colonyLevel > 0).length;

  /// 시간이 올리는 위협도 상한: 항성계에 9분 머물면 +6에서 멈춘다 (안 그러면 끝없이 오른다)
  static const threatTimeCap = 6.0;

  double get threat =>
      1 +
      sector * 1.0 +
      min(sectorElapsed / 90, threatTimeCap) +
      colonyCount * 0.3 +
      stations.fold<int>(0, (s, st) => s + st.habitatLevel - 1) * 0.15;

  /// 전체 수입 배율 (승무원·프리미엄·명예·내 행성)
  double get incomeMul => _incomeMul;

  double get _incomeMul =>
      (1 + crewBonus(CrewRole.trader)) * (profile.premium ? 1.25 : 1) *
      profile.honorIncomeMul *
      profile.home.incomeMul;

  // ---------- 은하 명예 ----------
  /// 섹터 4(인덱스 3)에 도달하면 환생 가능
  bool get canAscend => counter('maxSector') >= 3;

  /// 환생 시 얻는 명예 점수
  int get honorGain => max(1, sqrt(empireValue / 500).floor());

  /// 보급 기지 보너스: 가장 센 보급 기지 하나만 적용
  double supportBonusAt(Planet p) {
    var best = 0.0;
    for (final s in stations) {
      if (s.supportBonus > best && (s.pos - p.pos).distance < Station.supportRange) best = s.supportBonus;
    }
    return best;
  }

  double planetCreditRate(Planet p) =>
      p.raided ? 0 : p.baseCreditRate * sectorMul * _incomeMul * (1 + supportBonusAt(p));
  double planetOreRate(Planet p) => p.raided
      ? 0
      : p.baseOreRate *
          (1 + supportBonusAt(p)) *
          sectorMul *
          (1 + crewBonus(CrewRole.miner)) *
          profile.home.oreMul;
  double stationCreditRate(Station s) => s.baseCreditRate * sectorMul * _incomeMul;

  double get otherSectorCredits =>
      sectors.values.fold(0.0, (s, e) => s + e.idleCredits) * _incomeMul;
  double get otherSectorOre => sectors.values.fold(0.0, (s, e) => s + e.idleOre);

  double get creditIncome =>
      planets.fold(0.0, (s, p) => s + planetCreditRate(p)) +
      stations.fold(0.0, (s, st) => s + stationCreditRate(st)) +
      otherSectorCredits;
  double get oreIncome =>
      planets.fold(0.0, (s, p) => s + planetOreRate(p)) + otherSectorOre;

  /// 제국 가치 (진행도 점수)
  int get empireValue =>
      planets.fold<int>(0, (s, p) => s + p.colonyLevel * 100 +
          p.buildings.values.fold<int>(0, (a, b) => a + b) * 60) +
      stations.fold<int>(0, (s, st) => s + (st.habitatLevel + st.turretLevel) * 120) +
      sectors.values.fold<int>(
          0, (s, e) => s + e.colonyLevels.fold<int>(0, (a, b) => a + b) * 100 +
              e.buildings.fold<int>(0, (a, l) => a + l.fold<int>(0, (x, y) => x + y)) * 60) +
      levels.values.fold<int>(0, (s, l) => s + l) * 80 +
      roster.fold<int>(0, (s, c) => s + c.rarity * c.level * 30) +
      sector * 1000 +
      counter('kills') * 5;

  int counter(String k) => counters[k] ?? 0;
  void _count(String k, [int n = 1]) => counters[k] = counter(k) + n;

  // ---------- 비용 ----------
  Cost planetCost(Planet p) {
    final c = p.baseCost();
    return ((c.$1 * costMul).round(), (c.$2 * costMul).round());
  }

  Cost upgradeCost(UpgradeKind k) {
    final lv = level(k);
    return switch (k) {
      UpgradeKind.missile || UpgradeKind.shield || UpgradeKind.drone => (
          (250 * pow(1.8, lv)).round(),
          50 * (lv + 1)
        ),
      UpgradeKind.magnet => ((150 * pow(1.7, lv)).round(), 20 * (lv + 1)),
      _ => ((100 * pow(1.6, lv)).round(), 30 * lv),
    };
  }

  Cost colonyBuildingCost(Planet p, ColonyBuilding b) {
    final c = p.buildingBaseCost(b);
    return ((c.$1 * costMul).round(), (c.$2 * costMul).round());
  }

  Cost get stationBuildCost =>
      (((400 + (stations.length - 1) * 200) * costMul).round(), 150);
  Cost habitatCost(Station s) {
    final c = s.habitatCost;
    return ((c.$1 * costMul).round(), (c.$2 * costMul).round());
  }

  Cost turretCost(Station s) {
    final c = s.turretCost;
    return ((c.$1 * costMul).round(), (c.$2 * costMul).round());
  }

  int get recruitCost => 300 + recruitCount * 150;
  static const recruitGemCost = 30;

  /// ★4 전설 확정 모집 가격
  static const legendaryGemCost = 500;

  double get orePrice =>
      (2 + sector * 0.6) * (1 + 0.35 * sin(totalTime / 40));

  // ---------- 섹터 생성 / 이동 ----------
  void _loadSector(int index, SectorSave? save) {
    sector = index;
    planets.clear();
    stations.clear();
    gates.clear();
    asteroids.clear();
    pirates.clear();
    bullets.clear();
    missiles.clear();
    pickups.clear();
    events.clear();
    merchantCrew = null;
    _supplyCapsule = null;

    final r = Random(seed + index * 7919);
    final kinds = PlanetKind.values;
    final names = [..._planetPool]..shuffle(r);
    // 이름·종류·크기는 예전과 같은 난수 순서로 뽑는다 (저장된 식민지가 행성 번호로 묶여 있음).
    // 예전 배치 좌표는 간격 검사에만 쓰고 버린다.
    final drafts = <(String, double, PlanetKind)>[
      (index == 0 ? tr.g_planetTerraNova : names.removeLast(), 110,
          index == 0 ? PlanetKind.garden : kinds[r.nextInt(kinds.length)]),
    ];
    final legacyPos = <Offset>[const Offset(900, -350)];
    var tries = 0;
    while (drafts.length < 1 + outerOrbits.length * 2 && tries < 2000) {
      tries++;
      final pos = Offset(randRange(r, -worldHalf + 400, worldHalf - 400),
          randRange(r, -worldHalf + 400, worldHalf - 400));
      if (pos.distance < 700) continue;
      if (legacyPos.any((p) => (p - pos).distance < 1100)) continue;
      final kind = kinds[r.nextInt(kinds.length)];
      final radius =
          kind == PlanetKind.gas ? randRange(r, 150, 200) : randRange(r, 90, 140);
      legacyPos.add(pos);
      drafts.add((names.removeLast(), radius, kind));
    }
    // 궤도 배치: 첫 행성은 본거지 근처에서 출발, 나머지는 한 궤도에 두 개씩 마주 보게
    final orbitRng = Random(seed + index * 31 + 7);
    for (var i = 0; i < drafts.length; i++) {
      final (name, radius, kind) = drafts[i];
      final double orbit;
      final double phase;
      if (i == 0) {
        orbit = innerOrbit;
        phase = pi / 2 - 0.55;
      } else {
        orbit = outerOrbits[(i - 1) ~/ 2];
        phase = (i - 1).isEven
            ? orbitRng.nextDouble() * 2 * pi
            : planets.last.orbitPhase + pi + randRange(orbitRng, -0.4, 0.4);
      }
      planets.add(Planet(name, radius, kind, orbitRadius: orbit, orbitPhase: phase));
    }

    // 워프 게이트: 앞으로 가는 게이트는 모든 궤도 바깥 모서리, 돌아가는 게이트는 본거지 옆
    final corner = orbitRng.nextInt(4);
    final gatePos = Offset(corner.isEven ? 3550 : -3550, corner < 2 ? -3550 : 3550);
    gates.add(WarpGate(gatePos, true));
    if (index > 0) gates.add(WarpGate(backGatePos, false));

    if (save != null) {
      for (var i = 0; i < save.colonyLevels.length && i < planets.length; i++) {
        planets[i].colonyLevel = save.colonyLevels[i];
      }
      for (var i = 0; i < save.buildings.length && i < planets.length; i++) {
        final lv = save.buildings[i];
        for (final b in ColonyBuilding.values) {
          if (b.index < lv.length) planets[i].buildings[b] = lv[b.index];
        }
      }
      // 방어막은 저장하지 않는다: 불러오면 가득 찬 상태
      for (final p in planets) {
        if (p.colonyLevel > 0) p.shieldHp = p.shieldMax(sectorMul);
      }
      for (final s in save.stations) {
        stations.add(_stationFromJson(s));
      }
      sectorElapsed = save.elapsed;
      bossDefeated = save.bossDefeated;
      bossesSpawned = save.bossesSpawned;
    } else {
      final home = Station(index == 0 ? tr.g_stationHaven : tr.g_stationOutpost(sectorName), homePos,
          role: StationRole.home)
        ..turretLevel = 1;
      stations.add(home..hp = home.maxHp);
      sectorElapsed = 0;
      bossDefeated = false;
      bossesSpawned = 0;
    }
    if (stations.isEmpty) {
      final home = Station(tr.g_stationOutpost(sectorName), homePos, role: StationRole.home);
      stations.add(home..hp = home.maxHp);
    }
    sectorBossSpawned = false;
    for (final p in planets) {
      p.placeOnOrbit(sectorElapsed);
    }
    _devAnnounced = development >= 1;
    for (var i = 0; i < maxAsteroids; i++) {
      _spawnAsteroid(awayFrom: homePos, minDist: 500);
    }
  }

  SectorSave _saveCurrentSector() => SectorSave(
        colonyLevels: planets.map((p) => p.colonyLevel).toList(),
        buildings: [
          for (final p in planets) [for (final b in ColonyBuilding.values) p.building(b)],
        ],
        stations: stations.map(_stationToJson).toList(),
        elapsed: sectorElapsed,
        bossDefeated: bossDefeated,
        bossesSpawned: bossesSpawned,
        idleCredits: planets.fold(0.0, (s, p) => s + p.baseCreditRate * sectorMul) +
            stations.fold(0.0, (s, st) => s + st.baseCreditRate * sectorMul),
        idleOre: planets.fold(0.0, (s, p) => s + p.baseOreRate * sectorMul),
      );

  WarpGate? get nearbyGate {
    for (final g in gates) {
      if ((g.pos - player.pos).distance < 160) return g;
    }
    return null;
  }

  // ---------- 항성계 발전도 ----------
  /// 행성 하나가 발전도에 기여하는 최대 식민지 레벨
  static const devLevelCap = 3;

  /// 행성 레벨 목록으로 발전도(0~1). 모든 행성이 Lv.3 이상이면 1.
  static double developmentOf(List<int> levels) => levels.isEmpty
      ? 0
      : levels.fold<int>(0, (s, l) => s + min(l, devLevelCap)) / (levels.length * devLevelCap);

  /// 현재 항성계 발전도
  double get development => developmentOf([for (final p in planets) p.colonyLevel]);

  /// 발전도 100%가 되면 다음 항성계로 가는 게이트가 열린다 (한 번 가 본 곳은 계속 열림)
  bool gateOpen(WarpGate g) => !g.forward || development >= 1 || counter('maxSector') > sector;

  /// 발전 완료 알림을 이미 했는지 (섹터를 불러올 때 현재 상태로 맞춘다)
  bool _devAnnounced = false;

  bool warp(WarpGate g) {
    if (!gateOpen(g) || !player.alive) return false;
    final from = sector;
    final to = g.forward ? sector + 1 : sector - 1;
    sectors[from] = _saveCurrentSector();
    final save = sectors.remove(to);
    _loadSector(to, save);
    // 섹터에 묶인 임무는 취소
    final cancelled = activeMissions
        .where((m) => m.type == MissionType.deliver || m.type == MissionType.bounty)
        .toList();
    activeMissions.removeWhere(cancelled.contains);
    missionOffers.clear();
    offerTimer = 0;
    // 도착 위치
    final arrive = g.forward
        ? (to > 0 ? backGatePos : homePos)
        : gates.firstWhere((x) => x.forward).pos;
    player
      ..pos = arrive + const Offset(0, 180)
      ..vel = Offset.zero
      ..invulnerable = 2;
    if (to > counter('maxSector')) counters['maxSector'] = to;
    profile.maxStat('sector', to + 1);
    sfx.add(Sfx.warp);
    shake = 12;
    _burst(player.pos, const Color(0xFFB388FF), 80);
    say(Speaker.advisor, '${tr.g_dlgArrived(sectorName)}${save == null ? ' ${tr.g_dlgNewFrontier}' : ''}');
    if (cancelled.isNotEmpty) {
      say(Speaker.advisor, tr.g_dlgMissionsCancelled);
    }
    return true;
  }

  void _spawnAsteroid({required Offset awayFrom, double minDist = 900}) {
    for (var t = 0; t < 50; t++) {
      final pos = Offset(randRange(_rng, -worldHalf, worldHalf),
          randRange(_rng, -worldHalf, worldHalf));
      if ((pos - awayFrom).distance < minDist) continue;
      if (pos.distance < starRadius + 250) continue;
      if (planets.any((p) => (p.pos - pos).distance < p.radius + 120)) continue;
      if (stations.any((s) => (s.pos - pos).distance < 250)) continue;
      if (gates.any((g) => (g.pos - pos).distance < 200)) continue;
      asteroids.add(Asteroid(pos, randRange(_rng, 18, 55), _rng.nextInt(99999)));
      return;
    }
  }

  void say(Speaker s, String text) {
    if (dialogs.any((d) => d.text == text)) return;
    dialogs.add(DialogLine(s, text));
    if (dialogs.length > 5) dialogs.removeAt(0);
  }

  void _float(Offset pos, String text, Color c, {bool big = false}) {
    floats.add(FloatText(pos + Offset(randRange(_rng, -10, 10), -10), text, c, big: big));
    if (floats.length > 60) floats.removeAt(0);
  }

  /// 스토리(튜토리얼) 단계가 가리키는 위치 (초록 화살표)
  Offset? get storyTarget {
    switch (story.key) {
      case 'colonies':
        final p = planets.where((p) => p.colonyLevel == 0).toList();
        if (p.isEmpty) return null;
        p.sort((a, b) =>
            (a.pos - player.pos).distance.compareTo((b.pos - player.pos).distance));
        return p.first.pos;
      case 'shipLevels':
      case 'crew':
      case 'missions':
        if (nearbyStation != null) return null;
        return stations
            .reduce((a, b) =>
                (a.pos - player.pos).distance < (b.pos - player.pos).distance ? a : b)
            .pos;
      case 'sector':
        final g = gates.where((g) => g.forward && gateOpen(g));
        return g.isEmpty ? null : g.first.pos;
      case 'devPercent':
        // 아직 Lv.3이 안 된 가장 가까운 행성
        final todo = planets.where((p) => p.colonyLevel < devLevelCap).toList();
        if (todo.isEmpty) return null;
        todo.sort((a, b) =>
            (a.pos - player.pos).distance.compareTo((b.pos - player.pos).distance));
        return todo.first.pos;
      default:
        return null;
    }
  }

  /// 현재 임무 목표 위치들 (화살표/미니맵 표시용)
  List<Offset> get missionTargets => [
        for (final m in activeMissions)
          if (m.type == MissionType.deliver &&
              m.planetIndex != null &&
              m.planetIndex! < planets.length)
            planets[m.planetIndex!].pos,
        for (final e in pirates)
          if (e.name != null || e.sectorBoss) e.pos,
      ];

  // ---------- 상호작용 ----------
  Planet? get nearbyPlanet {
    for (final p in planets) {
      if ((p.pos - player.pos).distance < p.radius + 130) return p;
    }
    return null;
  }

  // ---------- 본거지 방어 ----------
  /// 섹터의 첫 정거장(알파 성역에서는 헤이븐 기지)이 본거지다.
  /// 안전 구역 안으로 들어온 해적 탄은 본거지가 대신 맞고(함선은 무사), 레이저 포대가 해적을 쏜다.
  /// 내구도가 0이 되면 [baseDisableTime]초 기능 정지(레이저·안전 구역 꺼짐) 후 30%로 재가동한다.
  /// 수치는 [Station.baseLevel] 강화 단계에 따른다 (models.dart Station 참고).
  Station get homeBase => stations.first;

  /// Lv.1 안전 구역 반경 (실제 값은 homeBase.safeRadius)
  static const havenSafeRadius = 520.0;

  /// 두목은 한 발에 최대 체력의 이 비율까지만 깎인다
  static const havenBossDamageRatio = 0.04;
  static const baseDisableTime = 25.0;
  static const baseRebootRatio = 0.3;

  final beams = <LaserBeam>[];
  double _havenLaserCooldown = 0;

  bool inHaven(Offset pos) =>
      !homeBase.disabled && (pos - homeBase.pos).distance < homeBase.safeRadius;

  Cost baseUpgradeCost(Station s) {
    final c = s.baseUpgradeCost;
    return ((c.$1 * costMul).round(), (c.$2 * costMul).round());
  }

  bool upgradeBase(Station s) {
    if (!s.isHome || s.baseLevel >= Station.maxBaseLevel) return false;
    if (!_pay(baseUpgradeCost(s))) return false;
    s.baseLevel++;
    if (!s.disabled) s.hp = s.maxHp;
    sfx.add(Sfx.upgrade);
    say(Speaker.advisor, tr.g_dlgBaseUpgraded(s.name, s.baseLevel));
    _burst(s.pos, const Color(0xFFFFD54F), 40);
    return true;
  }

  void _disableBase(Station s) {
    s.hp = 0;
    if (s.disabled) return;
    s.disabledTime = baseDisableTime;
    _burst(s.pos, const Color(0xFFFF5252), 80);
    sfx.add(Sfx.alarm);
    shake = min(20, shake + 10);
    _float(s.pos, tr.g_floatDisabled, const Color(0xFFFF5252), big: true);
    say(Speaker.advisor, tr.g_dlgBaseDisabled(baseDisableTime.toInt()));
  }

  void _updateHaven(double dt) {
    for (final b in beams) {
      b.life -= dt;
    }
    beams.removeWhere((b) => b.life <= 0);
    final hb = homeBase;
    final base = hb.pos;
    hb.sinceHit += dt;
    if (hb.disabled) {
      hb.disabledTime -= dt;
      hb.hp = 0;
      if (hb.disabledTime <= 0) {
        hb
          ..disabledTime = 0
          ..hp = hb.maxHp * baseRebootRatio;
        sfx.add(Sfx.upgrade);
        _float(base, tr.g_floatRebooted, const Color(0xFF69F0AE), big: true);
        say(Speaker.advisor, tr.g_dlgBaseRebooted);
      }
    } else if (hb.hp <= 0) {
      _disableBase(hb);
    } else if (hb.sinceHit >= Station.regenDelay && hb.hp < hb.maxHp) {
      hb.hp = min(hb.maxHp, hb.hp + hb.maxHp * hb.baseRegenRatio * dt);
    }
    // 안전 구역에 들어온 해적 탄은 본거지가 대신 맞는다. 방어 기지 근처 탄은 소멸
    bullets.removeWhere((b) {
      if (b.fromPlayer) return false;
      if (!hb.disabled && (b.pos - base).distance < hb.safeRadius) {
        hb.takeHit(b.damage);
        _spark(b.pos, const Color(0xFFFF8A80));
        return true;
      }
      final guarded =
          stations.any((s) => s.guardRange > 0 && (s.pos - b.pos).distance < s.guardRange);
      if (!guarded) return false;
      _spark(b.pos, const Color(0xFFFFE082));
      return true;
    });
    if (hb.hp <= 0) _disableBase(hb);
    if (hb.disabled) return;
    _havenLaserCooldown -= dt;
    if (_havenLaserCooldown > 0) return;
    Pirate? best;
    var bestD = hb.laserRange;
    for (final e in pirates) {
      final d = (e.pos - base).distance;
      if (d < bestD) {
        bestD = d;
        best = e;
      }
    }
    if (best == null) return;
    _havenLaserCooldown = hb.laserInterval;
    beams.add(LaserBeam(base, best.pos));
    final dmg = best.kind == PirateKind.boss
        ? min(hb.laserDamage, best.maxHp * havenBossDamageRatio)
        : hb.laserDamage;
    _hitPirate(best, dmg, best.pos);
    _burst(best.pos, const Color(0xFFFFE082), 10);
    sfx.add(Sfx.shoot);
  }

  Station? get nearbyStation {
    for (final s in stations) {
      if ((s.pos - player.pos).distance < 220) return s;
    }
    return null;
  }

  WorldEvent? get nearbyMerchant {
    for (final e in events) {
      if (e.kind == EventKind.merchant && (e.pos - player.pos).distance < 200) return e;
    }
    return null;
  }

  bool get canBuildStationHere =>
      player.alive &&
      nearbyStation == null &&
      planets.every((p) => (p.pos - player.pos).distance > p.radius + 300) &&
      player.pos.distance > starRadius + 400 &&
      stations.every((s) => (s.pos - player.pos).distance > 900) &&
      gates.every((g) => (g.pos - player.pos).distance > 400);

  bool canAfford(Cost cost) => credits >= cost.$1 && ore >= cost.$2;

  bool _pay(Cost cost) {
    if (!canAfford(cost)) return false;
    credits -= cost.$1;
    ore -= cost.$2;
    return true;
  }

  bool upgradePlanet(Planet p) {
    if (p.colonyLevel >= Planet.maxLevel) return false;
    if (!_pay(planetCost(p))) return false;
    p.colonyLevel++;
    profile.addStat('colonyUps');
    if (p.colonyLevel == 1) {
      _count('colonies');
      profile.addStat('colonies');
      say(Speaker.captain, tr.g_dlgSettled(p.name));
      _raiseDome(p);
      if (!profile.colonyTutorialSeen) colonyTutorialPending = true;
    } else {
      _float(p.pos + Offset(0, -p.radius - 30), 'Lv.${p.colonyLevel}!', const Color(0xFF7CFFB2), big: true);
    }
    if (p.colonyLevel == Planet.maxLevel) profile.maxStat('maxColony', 1);
    sfx.add(Sfx.upgrade);
    _burst(p.pos + Offset(0, -p.radius), const Color(0xFF7CFFB2), 30);
    return true;
  }

  bool buildColony(Planet p, ColonyBuilding b) {
    if (p.colonyLevel == 0 || p.building(b) >= p.buildingCap) return false;
    if (!_pay(colonyBuildingCost(p, b))) return false;
    p.buildings[b] = p.building(b) + 1;
    profile.addStat('colonyBuilds');
    sfx.add(Sfx.upgrade);
    _float(p.pos + Offset(0, -p.radius - 30), '${b.icon} Lv.${p.building(b)}', const Color(0xFF8AD8FF), big: true);
    _burst(p.pos + Offset(0, -p.radius), const Color(0xFF8AD8FF), 24);
    return true;
  }

  // ---------- 행성 방어막 ----------
  /// 모든 식민지는 방어막 돔을 두른다. 돔은 해적 탄환을 대신 맞아 내구도가 깎이고,
  /// 해적을 밀어낸다. 0이 되면 깨졌다가 재충전되어 다시 켜진다.
  /// 함선은 돔 안에 있을 때만 보호받는다.

  /// 첫 정착 직후 UI가 식민지 안내를 띄워야 함
  bool colonyTutorialPending = false;

  /// 깨진 방어막이 재충전을 시작하기까지
  static const shieldBrokenDelay = 10.0;

  Planet? domeAt(Offset pos) {
    for (final p in planets) {
      if (p.domeUp && (pos - p.pos).distance < p.domeRadius) return p;
    }
    return null;
  }

  void _raiseDome(Planet p) {
    p
      ..shieldHp = p.shieldMax(sectorMul)
      ..shieldBroken = false
      ..sinceShieldHit = 99;
    bullets.removeWhere((b) => !b.fromPlayer && (b.pos - p.pos).distance < p.domeRadius);
    sfx.add(Sfx.shield);
  }

  void _hitDome(Planet p, double dmg) {
    p
      ..shieldHp = max(0, p.shieldHp - dmg)
      ..sinceShieldHit = 0;
    if (p.shieldHp == 0) {
      p.shieldBroken = true;
      _burst(p.pos + Offset(0, -p.domeRadius), const Color(0xFF80D8FF), 40);
      _float(p.pos + Offset(0, -p.radius - 60), '🛡 ${tr.g_floatShieldBroken}', const Color(0xFFFF5252), big: true);
      sfx.add(Sfx.bigExplode);
      shake = min(16, shake + 8);
    }
  }

  // ---------- 공전 ----------
  void _updateOrbits() {
    for (final p in planets) {
      p.placeOnOrbit(sectorElapsed);
      // 지나가는 행성이 소행성을 밀어낸다
      for (final a in asteroids) {
        final d = a.pos - p.pos;
        final minD = p.radius + a.radius + 10;
        if (d.distance < minD) a.pos = p.pos + (d.distance == 0 ? const Offset(1, 0) : d.normalized()) * minD;
      }
    }
    // 항성은 단단하다: 함선·해적을 밀어내고 탄환을 삼킨다
    Offset outOfStar(Offset pos, double r) {
      final minD = starRadius + r;
      return pos.distance < minD ? (pos.distance == 0 ? const Offset(1, 0) : pos.normalized()) * minD : pos;
    }

    player.pos = outOfStar(player.pos, 16);
    for (final e in pirates) {
      e.pos = outOfStar(e.pos, e.radius);
    }
    bullets.removeWhere((b) => b.pos.distance < starRadius);
  }

  void _updateShields(double dt) {
    for (final p in planets) {
      if (p.colonyLevel == 0) continue;
      p.sinceShieldHit += dt;
      final cap = p.shieldMax(sectorMul);
      if (p.shieldHp > cap) p.shieldHp = cap;
      final delay = p.shieldBroken ? shieldBrokenDelay : Planet.shieldRegenDelay;
      if (p.sinceShieldHit < delay || p.shieldHp >= cap) continue;
      final assisted = stations.any((s) =>
          s.role == StationRole.repair && (s.pos - p.pos).distance < Station.shieldAssistRange);
      p.shieldHp = min(cap, p.shieldHp + p.shieldRegen(sectorMul) * (assisted ? 2 : 1) * dt);
      if (p.shieldBroken && p.shieldHp >= cap * Planet.shieldRebootRatio) {
        p.shieldBroken = false;
        sfx.add(Sfx.shield);
        _float(p.pos + Offset(0, -p.radius - 60), '🛡 ${tr.g_floatShieldBack}', const Color(0xFF80D8FF), big: true);
      }
    }
  }

  bool buildStation(StationRole role) {
    if (role == StationRole.home || !canBuildStationHere) return false;
    if (!_pay(stationBuildCost)) return false;
    final st = Station(tr.g_stationNumbered(role.label, stations.length + 1), player.pos + const Offset(0, -140),
        role: role);
    if (role == StationRole.defense) st.turretLevel = 1;
    st.hp = st.maxHp;
    stations.add(st);
    profile.addStat('stations');
    sfx.add(Sfx.upgrade);
    say(Speaker.advisor, tr.g_dlgStationBuilt(st.name, role.blurb));
    _burst(st.pos, const Color(0xFF8AD8FF), 40);
    return true;
  }

  bool upgradeHabitat(Station s) {
    if (s.habitatLevel >= Station.maxLevel) return false;
    if (!_pay(habitatCost(s))) return false;
    s.habitatLevel++;
    s.hp = s.maxHp;
    sfx.add(Sfx.upgrade);
    say(Speaker.advisor, tr.g_dlgHabitatUp(s.name, s.habitatLevel));
    return true;
  }

  bool upgradeTurret(Station s) {
    if (s.turretLevel >= Station.maxLevel) return false;
    if (!_pay(turretCost(s))) return false;
    s.turretLevel++;
    sfx.add(Sfx.upgrade);
    say(Speaker.advisor, tr.g_dlgTurretUp(s.name, s.turretLevel));
    return true;
  }

  bool upgradeShip(UpgradeKind k) {
    if (level(k) >= k.maxLevel) return false;
    if (!_pay(upgradeCost(k))) return false;
    levels[k] = level(k) + 1;
    sfx.add(Sfx.upgrade);
    switch (k) {
      case UpgradeKind.weapon:
        say(Speaker.captain, tr.g_dlgUpWeapon);
      case UpgradeKind.hull:
        player.hp = playerMaxHp;
        say(Speaker.captain, tr.g_dlgUpHull);
      case UpgradeKind.engine:
        say(Speaker.captain, tr.g_dlgUpEngine);
      case UpgradeKind.missile:
        say(Speaker.captain, level(k) == 1 ? tr.g_dlgMissileNew : tr.g_dlgMissileUp);
      case UpgradeKind.shield:
        say(Speaker.captain, level(k) == 1 ? tr.g_dlgShieldNew : tr.g_dlgShieldUp);
      case UpgradeKind.drone:
        profile.maxStat('drone', 1);
        say(Speaker.captain, level(k) == 1 ? tr.g_dlgDroneNew : tr.g_dlgDroneUp);
      case UpgradeKind.magnet:
        say(Speaker.captain, tr.g_dlgUpMagnet);
    }
    return true;
  }

  /// 격납고에서 함선 교체 (정거장에서만)
  bool switchShip(ShipType t) {
    if (!profile.shipUnlocked(t) || profile.shipType == t.id) return false;
    final ratio = player.hp / playerMaxHp;
    profile.shipType = t.id;
    profile.dirty = true;
    player.hp = playerMaxHp * ratio;
    sfx.add(Sfx.upgrade);
    say(Speaker.captain, tr.g_dlgShipSwitched(euro(t.name)));
    return true;
  }

  bool buyShip(ShipType t) {
    if (!profile.buyShip(t)) return false;
    sfx.add(Sfx.gem);
    switchShip(t);
    return true;
  }

  // ---------- 내 행성 ----------
  HomePlanet get home => profile.home;

  bool buildHome(int slot, BuildingType t) {
    if (slot < 0 || slot >= home.slots.length || home.slots[slot] != null) return false;
    if (t.gemOnly) {
      if (!profile.spendGems(home.statueGemCost(0))) return false;
    } else if (!_pay(home.buildCost(t))) {
      return false;
    }
    home.slots[slot] = HomeSlot(t);
    profile.maxStat('homeBuildings', home.buildingCount);
    profile.dirty = true;
    sfx.add(Sfx.upgrade);
    return true;
  }

  bool upgradeHome(int slot) {
    final s = home.slots[slot];
    if (s == null || s.level >= HomeSlot.maxLevel) return false;
    if (s.type.gemOnly) {
      if (!profile.spendGems(home.statueGemCost(s.level))) return false;
    } else if (!_pay(home.upgradeCost(s))) {
      return false;
    }
    s.level++;
    profile.dirty = true;
    sfx.add(Sfx.upgrade);
    return true;
  }

  bool levelUpHome() {
    if (home.level >= HomePlanet.maxLevel) return false;
    if (!_pay(home.levelUpCost)) return false;
    home.levelUp();
    profile.maxStat('homeLevel', home.level);
    profile.dirty = true;
    sfx.add(Sfx.warp);
    return true;
  }

  /// 8시간마다 받는 행성 선물. 받은 (크레딧, 젬) 반환
  (int, int)? harvestHome(DateTime now) {
    if (!home.harvestReady(now)) return null;
    final r = home.harvestReward(sectorMul);
    home.lastHarvestMs = now.millisecondsSinceEpoch;
    credits += r.$1;
    profile.gems += r.$2;
    profile.dirty = true;
    sfx.add(Sfx.gem);
    return r;
  }

  bool sellOre(int amount) {
    final n = min(amount, ore.floor());
    if (n <= 0) return false;
    ore -= n;
    final gain = n * orePrice;
    credits += gain;
    sfx.add(Sfx.coin);
    say(Speaker.advisor, tr.g_dlgOreSold(n, gain.round()));
    return true;
  }

  static const creditPackGems = 20;
  int get creditPackAmount => (1500 * sectorMul).round();

  bool buyCreditsWithGems() {
    if (!profile.spendGems(creditPackGems)) return false;
    credits += creditPackAmount;
    sfx.add(Sfx.coin);
    return true;
  }

  // ---------- 승무원 ----------
  CrewMember? recruitWithCredits() {
    if (roster.length >= rosterCap) return null;
    if (!_pay((recruitCost, 0))) return null;
    return _addCrew(CrewMember.random(_rng, _nextId++, odds: CrewMember.creditOdds));
  }

  CrewMember? recruitWithGems() {
    if (roster.length >= rosterCap) return null;
    if (!profile.spendGems(recruitGemCost)) return null;
    return _addCrew(CrewMember.random(_rng, _nextId++, odds: CrewMember.gemOdds));
  }

  /// ★4 전설 확정 모집 (젬)
  CrewMember? recruitLegendary() {
    if (roster.length >= rosterCap) return null;
    if (!profile.spendGems(legendaryGemCost)) return null;
    return grantCrew(4);
  }

  CrewMember _addCrew(CrewMember c) {
    recruitCount++;
    if (assignedCount < crewSlots) c.assigned = true;
    roster.add(c);
    profile.addStat('crew');
    if (c.rarity >= 3) profile.addStat('crew3');
    sfx.add(Sfx.gem);
    say(Speaker.advisor, tr.g_dlgCrewJoined(c.stars, c.role.label, iGa(c.displayName)));
    if (c.role == CrewRole.engineer) player.hp = min(player.hp, playerMaxHp);
    return c;
  }

  /// 결제 상품 등으로 지급되는 승무원
  CrewMember grantCrew(int rarity) =>
      _addCrew(CrewMember.random(_rng, _nextId++, odds: {rarity: 100}));

  bool toggleAssign(CrewMember c) {
    if (c.assigned) {
      c.assigned = false;
    } else {
      if (assignedCount >= crewSlots) return false;
      c.assigned = true;
    }
    player.hp = min(player.hp, playerMaxHp);
    return true;
  }

  bool levelUpCrew(CrewMember c) {
    if (c.level >= CrewMember.maxLevel) return false;
    if (!_pay((c.levelUpCost, 0))) return false;
    c.level++;
    sfx.add(Sfx.upgrade);
    say(Speaker.advisor, tr.g_dlgCrewLevel(c.name, c.level));
    return true;
  }

  void dismissCrew(CrewMember c) => roster.remove(c);

  // ---------- 임무 ----------
  void _refreshOffers() {
    missionOffers.clear();
    // 같은 종류가 겹치지 않게 4종 중 3종을 고른다
    final types = [...MissionType.values]..shuffle(_rng);
    for (final type in types.take(3)) {
      missionOffers.add(_randomMission(type));
    }
    offerTimer = 180;
  }

  Mission _randomMission(MissionType type) {
    final t = threat;
    final gemBonus = _rng.nextDouble() < 0.15 ? 2 : 0;
    switch (type.index) {
      case 0:
        final n = 5 + (t * 2).round();
        return Mission(
            id: _nextId++, type: MissionType.kill, target: n,
            rewardCredits: (35 * n * sectorMul).round(), rewardGems: gemBonus);
      case 1:
        final n = 40 + _rng.nextInt(9) * 10;
        return Mission(
            id: _nextId++, type: MissionType.mine, target: n,
            rewardCredits: (3 * n * sectorMul).round(), rewardGems: gemBonus);
      case 2:
        final idx = _rng.nextInt(planets.length);
        final d = (planets[idx].pos - player.pos).distance;
        return Mission(
            id: _nextId++, type: MissionType.deliver, target: 1, planetIndex: idx,
            rewardCredits: ((150 + d / 8) * sectorMul).round(), rewardGems: gemBonus);
      default:
        return Mission(
            id: _nextId++, type: MissionType.bounty, target: 1,
            bountyName: (bountyNames
                    .where((n) => !activeMissions.any((m) => m.bountyName == n))
                    .toList()
                  ..shuffle(_rng))
                .first,
            rewardCredits: (450 * sectorMul).round(), rewardGems: 5);
    }
  }

  bool acceptMission(Mission m) {
    if (activeMissions.length >= 3 || !missionOffers.contains(m)) return false;
    missionOffers.remove(m);
    activeMissions.add(m);
    if (m.type == MissionType.bounty) _spawnBounty(m);
    if (m.type == MissionType.deliver) {
      say(Speaker.advisor, tr.g_dlgCargoLoaded(m.title(planets)));
    }
    return true;
  }

  void abandonMission(Mission m) {
    activeMissions.remove(m);
    pirates.removeWhere((e) => e.missionId == m.id);
  }

  void _spawnBounty(Mission m) {
    final a = _rng.nextDouble() * 2 * pi;
    final pos = _clampWorld(player.pos + OffsetX.fromAngle(a, randRange(_rng, 1500, 2400)), (_) {});
    final e = Pirate(PirateKind.raider, pos, Pirate.baseHp(PirateKind.raider) * 5 * sectorMul,
        name: m.bountyName, dmgScale: 1.5 * (1 + sector * 0.3))
      ..missionId = m.id
      ..wanderAngle = a;
    pirates.add(e);
    m.bountySpawned = true;
    say(Speaker.pirate, tr.g_dlgBountyTaunt(eul(m.bountyName!)));
  }

  void _completeMission(Mission m) {
    activeMissions.remove(m);
    final c = (m.rewardCredits * (1 + crewBonus(CrewRole.trader))).round();
    credits += c;
    if (m.rewardGems > 0) profile.gems += m.rewardGems;
    _count('missions');
    profile.addStat('missions');
    sfx.add(Sfx.coin);
    _float(player.pos + const Offset(0, -40), '${tr.g_floatMissionDone} +💰$c', const Color(0xFFFFD54F), big: true);
    say(Speaker.advisor,
        '${tr.g_dlgMissionDone(m.title(planets))} 💰$c${m.rewardGems > 0 ? ' ⭐${m.rewardGems}' : ''}');
  }

  // ---------- 스토리 ----------
  StoryStep get story => storyStepAt(storyIndex);

  int storyValue(String key) => switch (key) {
        // 발전 목표는 그 단계가 가리키는 항성계에서만 센다 (이미 발전한 옛 항성계로 돌아가 깨는 것 방지)
        'devPercent' => sector == storySectorAt(storyIndex) ? (development * 100).floor() : 0,
        'shipLevels' => levels.values.fold(0, (s, l) => s + l),
        'crew' => roster.length,
        'stations' => stations.length,
        'sector' => counter('maxSector'),
        _ => counter(key),
      };

  (int, int) get storyProgress {
    final s = story;
    final v = storyValue(s.key) - (s.relative ? storyBase : 0);
    return (min(v, s.target), s.target);
  }

  void _startStoryStep() {
    final s = story;
    storyBase = storyValue(s.key);
    storyTimer = 0;
    for (final (sp, line) in s.lines) {
      say(sp, line);
    }
  }

  void _checkStory() {
    final (v, t) = storyProgress;
    if (v < t) return;
    final s = story;
    credits += s.credits;
    profile.gems += s.gems;
    sfx.add(Sfx.upgrade);
    _float(player.pos + const Offset(0, -50), '${tr.g_floatGoalDone} +💰${s.credits} ⭐${s.gems}',
        const Color(0xFF7CFFB2), big: true);
    storyIndex++;
    if (storyIndex == storySteps.length) profile.tutorialDone = true;
    _startStoryStep();
  }

  // ---------- 스킬 ----------
  bool fireMissiles() {
    final lv = level(UpgradeKind.missile);
    if (lv == 0 || player.missileCooldown > 0 || !player.alive) return false;
    player.missileCooldown = missileCooldownMax;
    final n = 2 + lv ~/ 2;
    final dmg = 22 * (1 + 0.3 * (lv - 1)) * (1 + crewBonus(CrewRole.gunner));
    final targets = [...pirates]
      ..sort((a, b) =>
          (a.pos - player.pos).distance.compareTo((b.pos - player.pos).distance));
    for (var i = 0; i < n; i++) {
      final a = player.angle + (i - (n - 1) / 2) * 0.5;
      final m = Missile(player.pos, OffsetX.fromAngle(a, 300) + player.vel * 0.5, dmg);
      if (targets.isNotEmpty) m.target = targets[i % targets.length];
      missiles.add(m);
    }
    sfx.add(Sfx.missile);
    return true;
  }

  bool activateShield() {
    final lv = level(UpgradeKind.shield);
    if (lv == 0 || player.shieldCooldown > 0 || !player.alive) return false;
    player.shieldCooldown = shieldCooldownMax;
    player.shieldTime = 2.5 + lv * 0.5;
    sfx.add(Sfx.shield);
    return true;
  }

  bool boost() {
    if (player.boostCooldown > 0 || !player.alive) return false;
    player.boostCooldown = boostCooldownMax;
    player.vel += OffsetX.fromAngle(player.angle, 750);
    player.invulnerable = max(player.invulnerable, 0.35);
    boostTime = 0.4;
    sfx.add(Sfx.boost);
    for (var i = 0; i < 16; i++) {
      particles.add(Particle(player.pos, -OffsetX.fromAngle(player.angle + randRange(_rng, -0.6, 0.6), 200),
          0.4, const Color(0xFF80D8FF), 3));
    }
    return true;
  }

  // ---------- 부활 ----------
  /// 재출격 비용 비율: 수리 기지에서 나오면 싸다
  static double respawnCostRatio(Station s) => s.role == StationRole.repair ? 0.10 : 0.25;

  void reviveHere() {
    if (player.alive) return;
    player
      ..alive = true
      ..awaitingRevive = false
      ..pos = player.deathPos
      ..vel = Offset.zero
      ..hp = playerMaxHp
      ..invulnerable = 3;
    bullets.removeWhere((b) => !b.fromPlayer);
    for (final e in pirates) {
      if ((e.pos - player.pos).distance < 400) {
        e.vel = (e.pos - player.pos).normalized() * 500;
      }
    }
    sfx.add(Sfx.shield);
    say(Speaker.captain, tr.g_dlgNotOver);
  }

  void respawnAtBase() {
    if (player.alive) return;
    final base = stations.reduce(
        (a, b) => (a.pos - player.pos).distance < (b.pos - player.pos).distance ? a : b);
    final lost = (credits * respawnCostRatio(base)).floor();
    credits -= lost;
    final home = base.pos;
    player
      ..alive = true
      ..awaitingRevive = false
      ..pos = home + const Offset(0, 160)
      ..vel = Offset.zero
      ..hp = playerMaxHp
      ..invulnerable = 3;
    say(Speaker.advisor, tr.g_dlgRepairCost(lost));
  }

  // ---------- 오프라인 수입 ----------
  DateTime? savedAt;

  /// 오프라인 시간(초)과 그동안의 수입
  (int seconds, double credits, double ore) offlineEarnings(DateTime now) {
    if (savedAt == null) return (0, 0, 0);
    final cap = profile.premium ? 8 * 3600 : 2 * 3600;
    final sec = now.difference(savedAt!).inSeconds.clamp(0, cap);
    if (sec < 60) return (0, 0, 0);
    final eff = profile.home.offlineEfficiency;
    return (sec, creditIncome * sec * eff, oreIncome * sec * eff);
  }

  void applyOffline(double c, double o) {
    credits += c;
    ore += o;
    savedAt = null;
  }

  // ---------- 업데이트 ----------
  void update(double dt, InputState input) {
    if (paused) return;
    dt = dt.clamp(0, 0.05);
    totalTime += dt;
    sectorElapsed += dt;
    storyTimer += dt;

    credits += creditIncome * dt;
    ore += oreIncome * dt;

    for (final k in buffs.keys.toList()) {
      final t = buffs[k]! - dt;
      if (t <= 0) {
        buffs.remove(k);
      } else {
        buffs[k] = t;
      }
    }
    shake = max(0, shake - dt * 30);
    boostTime = max(0, boostTime - dt);
    _updateShields(dt);
    _updateOrbits();

    _updatePlayer(dt, input);
    _updateDrone(dt);
    _updatePirates(dt);
    _updateStations(dt);
    _updateHaven(dt);
    _updateColonies(dt);
    _updateMissiles(dt);
    _updateBullets(dt);
    _updateAsteroids(dt);
    _updatePickups(dt);
    _updateParticles(dt);
    _updateEvents(dt);
    _updateSpawning(dt);
    _updateMissions(dt);

    _playAcc += dt;
    if (_playAcc >= 60) {
      _playAcc -= 60;
      profile.addStat('playMin');
    }
    _secondTimer += dt;
    if (_secondTimer > 0.5) {
      _secondTimer = 0;
      if (!_devAnnounced && development >= 1) {
        _devAnnounced = true;
        sfx.add(Sfx.warp);
        say(Speaker.advisor, tr.g_dlgSectorDeveloped(sectorName));
      }
      _checkStory();
      profile.maxStat('credits', credits.floor());
    }

    for (final d in dialogs) {
      d.time -= dt;
    }
    dialogs.removeWhere((d) => d.time <= 0);
    for (final f in floats) {
      f.life -= dt;
      f.pos += Offset(0, -40 * dt);
    }
    floats.removeWhere((f) => f.life <= 0);
  }

  void _updatePlayer(double dt, InputState input) {
    final p = player;
    p.missileCooldown = max(0, p.missileCooldown - dt);
    p.shieldCooldown = max(0, p.shieldCooldown - dt);
    p.boostCooldown = max(0, p.boostCooldown - dt);
    p.shieldTime = max(0, p.shieldTime - dt);
    if (!p.alive) {
      p.deadTime += dt;
      // 오랫동안 선택이 없으면 기지에서 자동 재출격
      if (p.deadTime > 20) respawnAtBase();
      return;
    }
    p.invulnerable = max(0, p.invulnerable - dt);
    p.sinceHit += dt;
    p.guardCooldown = max(0, p.guardCooldown - dt);
    // 자가 수리 (오로라): 한동안 맞지 않으면 체력이 차오른다
    if (ship.regenRate > 0 && p.sinceHit >= ShipType.regenDelay && p.hp < playerMaxHp) {
      p.hp = min(playerMaxHp, p.hp + playerMaxHp * ship.regenRate * dt);
    }
    final move = input.move.clampLength(1);
    p.thrusting = move.distance > 0.1;
    if (p.thrusting) {
      final target = atan2(move.dy, move.dx);
      p.angle += angleDiff(p.angle, target).clamp(-8 * dt, 8 * dt);
      p.vel += OffsetX.fromAngle(p.angle, 900 * move.distance) * dt;
    }
    final cap = boostTime > 0 ? playerSpeed * 2.4 : playerSpeed;
    p.vel = (p.vel * pow(0.35, dt).toDouble()).clampLength(cap);
    p.pos += p.vel * dt;
    p.pos = _clampWorld(p.pos, (v) => p.vel = v);

    if (p.thrusting && _rng.nextDouble() < 0.7) {
      particles.add(Particle(
        p.pos - OffsetX.fromAngle(p.angle, 20),
        -OffsetX.fromAngle(p.angle + randRange(_rng, -0.3, 0.3), 120) + p.vel * 0.3,
        0.35,
        const Color(0xFFFFB347),
        randRange(_rng, 2, 4),
      ));
    }

    for (final a in asteroids) {
      final d = p.pos - a.pos;
      final minD = a.radius + 16;
      if (d.distance < minD && d.distance > 0) {
        final n = d.normalized();
        p.pos = a.pos + n * minD;
        p.vel = p.vel - n * (2 * (p.vel.dx * n.dx + p.vel.dy * n.dy)) * 0.6;
      }
    }

    if (p.hp < playerMaxHp) {
      var rate = 0.0;
      for (final s in stations) {
        if (s.repairRate > rate && (s.pos - p.pos).distance < s.repairRange) rate = s.repairRate;
      }
      if (rate > 0) p.hp = min(playerMaxHp, p.hp + rate * (1 + crewBonus(CrewRole.engineer)) * dt);
    }

    p.fireCooldown -= dt;
    if (input.fire && p.fireCooldown <= 0) {
      p.fireCooldown = playerFireInterval;
      final aim = _aimAngle(input.autoAim);
      final shots = playerShots;
      for (var i = 0; i < shots; i++) {
        final spread = shots == 1 ? 0.0 : (i - (shots - 1) / 2) * 0.12;
        final dir = OffsetX.fromAngle(aim + spread);
        final crit = ship.crit > 0 && _rng.nextDouble() < ship.crit;
        bullets.add(Bullet(p.pos + dir * 22, dir * 760 + p.vel * 0.5,
            playerDamage * (crit ? 2.5 : 1), true,
            big: crit, pierce: ship.pierce));
      }
      sfx.add(Sfx.shoot);
    }
  }

  /// 조준 보정: 앞쪽 원뿔 안(자동 모드면 전방위)의 가장 가까운 적을 향한다
  double _aimAngle(bool allAround) {
    final p = player;
    Pirate? best;
    var bestD = 600.0;
    for (final e in pirates) {
      final to = e.pos - p.pos;
      final d = to.distance;
      if (d >= bestD) continue;
      final a = atan2(to.dy, to.dx);
      if (!allAround && angleDiff(p.angle, a).abs() > 0.6) continue;
      bestD = d;
      best = e;
    }
    if (best == null) return p.angle;
    // 이동 예측 조준
    final lead = best.pos + best.vel * (bestD / 760);
    return atan2(lead.dy - p.pos.dy, lead.dx - p.pos.dx);
  }

  /// 첫 섹터 초반에는 해적 공격력을 낮춰 입문을 돕는다
  double get _newbieMul => sector == 0 && threat < 2 ? 0.6 : 1.0;

  void _updateDrone(double dt) {
    if (droneLevel == 0 || !player.alive) return;
    droneAngle += dt * 2.2;
    _droneCooldown -= dt;
    if (_droneCooldown > 0) return;
    final from = dronePos;
    Pirate? best;
    var bestD = 450.0;
    for (final e in pirates) {
      final d = (e.pos - from).distance;
      if (d < bestD) {
        bestD = d;
        best = e;
      }
    }
    if (best == null) return;
    _droneCooldown = droneInterval;
    final dir = (best.pos - from).normalized();
    bullets.add(Bullet(from + dir * 8, dir * 720, droneDamage, true));
  }

  Offset _clampWorld(Offset pos, void Function(Offset) setVel) {
    const h = worldHalf;
    if (pos.dx.abs() > h || pos.dy.abs() > h) {
      setVel(Offset.zero);
      return Offset(pos.dx.clamp(-h, h), pos.dy.clamp(-h, h));
    }
    return pos;
  }

  void _damagePlayer(double dmg) {
    final p = player;
    if (!p.alive || p.invulnerable > 0) return;
    if (inHaven(p.pos)) return; // 본거지 안전 구역
    if (shielded) {
      _float(p.pos, tr.g_floatBlocked, const Color(0xFF80D8FF));
      return;
    }
    if (guardReady) {
      p.guardCooldown = ship.guardInterval;
      _float(p.pos, tr.g_floatGuard, const Color(0xFF80D8FF));
      sfx.add(Sfx.shield);
      return;
    }
    p.sinceHit = 0;
    p.hp -= dmg;
    shake = min(14, shake + 4 + dmg * 0.2);
    sfx.add(Sfx.hurt);
    _float(p.pos, '-${dmg.round()}', const Color(0xFFFF5252));
    if (p.hp <= 0) {
      p
        ..alive = false
        ..awaitingRevive = true
        ..deadTime = 0
        ..deathPos = p.pos;
      shake = 20;
      sfx.add(Sfx.bigExplode);
      _burst(p.pos, const Color(0xFFFF7043), 70);
      say(Speaker.pirate, [tr.g_pirateWin0, tr.g_pirateWin1, tr.g_pirateWin2][_rng.nextInt(3)]);
    }
  }

  void _updatePirates(double dt) {
    final exploded = <Pirate>[];
    for (final e in pirates) {
      e.hitFlash = max(0, e.hitFlash - dt);
      e.contactCooldown = max(0, e.contactCooldown - dt);

      if (e.kind == PirateKind.jelly) {
        _updateJelly(e, dt);
        continue;
      }

      // 목표 선택
      Offset? target;
      var targetDist = double.infinity;
      if (player.alive) {
        target = player.pos;
        targetDist = (player.pos - e.pos).distance;
      }
      final raid = e.eventId == null
          ? null
          : events.where((ev) => ev.id == e.eventId && ev.kind == EventKind.raid).firstOrNull;
      if (raid != null && raid.planet != null && targetDist > 450) {
        target = raid.planet!.pos;
        targetDist = (target - e.pos).distance;
      }
      for (final s in stations) {
        final d = (s.pos - e.pos).distance;
        if (d < 900 && d < targetDist) {
          target = s.pos;
          targetDist = d;
        }
      }

      Offset desired;
      if (target == null || (targetDist > 1600 && raid == null && e.name == null)) {
        e.wanderAngle += randRange(_rng, -1, 1) * dt;
        desired = OffsetX.fromAngle(e.wanderAngle, e.speed * 0.4);
      } else {
        final to = (target - e.pos).normalized();
        if (e.name != null && targetDist > 1100) {
          // 현상수배범은 멀리서는 배회
          e.wanderAngle += randRange(_rng, -1, 1) * dt;
          desired = OffsetX.fromAngle(e.wanderAngle, e.speed * 0.3);
        } else if (e.kind == PirateKind.bomber) {
          desired = to * e.speed;
        } else if (e.kind == PirateKind.sniper) {
          if (targetDist > 750) {
            desired = to * e.speed;
          } else if (targetDist < 520) {
            desired = to * -e.speed;
          } else {
            desired = Offset(-to.dy, to.dx) * e.speed * 0.5;
          }
        } else if (raid != null && target == raid.planet?.pos && targetDist < raid.planet!.radius + 200) {
          desired = Offset(-to.dy, to.dx) * e.speed * 0.7;
        } else if (targetDist > 260) {
          desired = to * e.speed;
        } else {
          desired = Offset(-to.dy, to.dx) * e.speed * 0.8 + to * -40;
        }
      }
      e.vel += (desired - e.vel) * min(1, 2.5 * dt);
      e.pos += e.vel * dt;
      e.pos = _clampWorld(e.pos, (v) => e.vel = v);

      if (e.kind == PirateKind.boss) _bossPattern(e, dt, targetDist);

      if (target == null) continue;
      final aim = atan2(target.dy - e.pos.dy, target.dx - e.pos.dx);
      e.angle += angleDiff(e.angle, aim).clamp(-4 * dt, 4 * dt);

      if (e.kind == PirateKind.bomber) {
        if (targetDist < e.radius + 40) exploded.add(e);
        continue;
      }
      e.fireCooldown -= dt;
      final range = e.kind == PirateKind.sniper ? 950 : 560;
      if (targetDist < range &&
          e.fireCooldown <= 0 &&
          angleDiff(e.angle, aim).abs() < 0.35) {
        e.fireCooldown = e.fireInterval * randRange(_rng, 0.8, 1.3);
        final shots = e.kind == PirateKind.boss ? 3 : 1;
        final speed = e.kind == PirateKind.sniper ? 820.0 : 430.0;
        for (var i = 0; i < shots; i++) {
          final dir = OffsetX.fromAngle(e.angle + (i - (shots - 1) / 2) * 0.2);
          bullets.add(Bullet(e.pos + dir * e.radius, dir * speed, e.damage * _newbieMul, false,
              life: e.kind == PirateKind.sniper ? 1.4 : 1.6,
              big: e.kind == PirateKind.sniper || e.kind == PirateKind.boss));
        }
      }
    }
    if (_spawnQueue.isNotEmpty) {
      pirates.addAll(_spawnQueue);
      _spawnQueue.clear();
    }
    for (final e in exploded) {
      pirates.remove(e);
      _burst(e.pos, const Color(0xFFFFAB40), 50);
      sfx.add(Sfx.explode);
      shake = min(16, shake + 6);
      for (final p in planets) {
        if (p.domeUp && (p.pos - e.pos).distance < p.domeRadius + 100) _hitDome(p, e.damage);
      }
      if (player.alive && (player.pos - e.pos).distance < 100 && domeAt(player.pos) == null) {
        _damagePlayer(e.damage);
      }
      for (final s in stations) {
        // 본거지는 안전 구역 안의 폭발을 대신 맞는다
        if ((s.pos - e.pos).distance < 120 || (s == homeBase && inHaven(e.pos))) s.takeHit(e.damage);
      }
    }
  }

  final _spawnQueue = <Pirate>[];

  void _bossPattern(Pirate e, double dt, double targetDist) {
    // 2페이즈: 체력 절반 이하에서 부하 소환 + 공격 강화
    if (!e.enraged && e.hp < e.maxHp * 0.5) {
      e.enraged = true;
      for (var i = 0; i < 3 + sector; i++) {
        _spawnQueue.add(_makePirate(
            i.isEven ? PirateKind.scout : PirateKind.bomber,
            e.pos + OffsetX.fromAngle(i * 2.1, 90)));
      }
      shake = min(20, shake + 10);
      sfx.add(Sfx.alarm);
      say(Speaker.pirate, [tr.g_pirateRage0, tr.g_pirateRage1, tr.g_pirateRage2][_rng.nextInt(3)]);
    }
    // 특수 공격: 원형 탄막
    e.specialTimer -= dt;
    if (e.specialTimer <= 0 && targetDist < 900) {
      e.specialTimer = e.enraged ? 3.5 : 6;
      final n = e.enraged ? 16 : 10;
      final off = _rng.nextDouble();
      for (var i = 0; i < n; i++) {
        final dir = OffsetX.fromAngle(off + i * 2 * pi / n);
        bullets.add(Bullet(e.pos + dir * e.radius, dir * 300, e.damage * 0.8 * _newbieMul, false,
            life: 2.5, big: true));
      }
      _burst(e.pos, const Color(0xFFCE93D8), 20);
    }
  }

  void _updateJelly(Pirate e, double dt) {
    final d = player.alive ? (player.pos - e.pos).distance : double.infinity;
    Offset desired;
    if (d < 380) {
      desired = (player.pos - e.pos).normalized() * e.speed * 1.4;
    } else {
      e.wanderAngle += randRange(_rng, -0.6, 0.6) * dt;
      desired = OffsetX.fromAngle(e.wanderAngle, e.speed);
    }
    e.vel += (desired - e.vel) * min(1, 1.2 * dt);
    e.pos += e.vel * dt;
    e.pos = _clampWorld(e.pos, (v) {
      e.vel = v;
      e.wanderAngle += pi;
    });
    e.angle += dt;
    if (d < e.radius + 16 && e.contactCooldown <= 0 && domeAt(player.pos) == null) {
      e.contactCooldown = 0.8;
      _damagePlayer(e.damage * (1 + sector * 0.3));
    }
  }

  void _updateStations(double dt) {
    for (final s in stations) {
      s.spin += dt * 0.3;
      // 본거지 재생·정지는 _updateHaven에서
      if (!s.isHome && s.hp < s.maxHp) s.hp = min(s.maxHp, s.hp + 2 * dt);
      if (s.turretLevel == 0 || s.disabled) continue;
      s.turretCooldown -= dt;
      if (s.turretCooldown > 0) continue;
      Pirate? best;
      var bestD = s.turretRange;
      for (final e in pirates) {
        if (!e.isPirate) continue;
        final d = (e.pos - s.pos).distance;
        if (d < bestD) {
          bestD = d;
          best = e;
        }
      }
      if (best != null) {
        s.turretCooldown = s.turretInterval;
        final dir = (best.pos - s.pos).normalized();
        bullets.add(Bullet(s.pos + dir * 50, dir * 700, s.turretDamage * sectorMul, true));
      }
    }
  }

  void _updateColonies(double dt) {
    for (final p in planets) {
      if (p.colonyLevel == 0) continue;
      if (p.domeUp) {
        for (final e in pirates) {
          final d = e.pos - p.pos;
          final edge = p.domeRadius + e.radius;
          if (d.distance < edge) {
            final n = d.distance == 0 ? const Offset(1, 0) : d.normalized();
            e.pos = p.pos + n * edge;
            e.vel = n * 200;
          }
        }
      }
      if (p.building(ColonyBuilding.dock) > 0 &&
          player.alive &&
          player.hp < playerMaxHp &&
          (player.pos - p.pos).distance < p.dockRange) {
        player.hp = min(playerMaxHp, player.hp + p.dockHealRate * dt);
      }
      if (p.building(ColonyBuilding.turret) == 0) continue;
      p.turretCooldown -= dt;
      if (p.turretCooldown > 0) continue;
      Pirate? best;
      var bestD = p.turretRange;
      for (final e in pirates) {
        if (!e.isPirate) continue;
        final d = (e.pos - p.pos).distance;
        if (d < bestD) {
          bestD = d;
          best = e;
        }
      }
      if (best != null) {
        p.turretCooldown = p.turretInterval;
        final dir = (best.pos - p.pos).normalized();
        bullets.add(Bullet(p.pos + dir * (p.radius + 10), dir * 700, p.turretDamage * sectorMul, true));
      }
    }
  }

  void _updateMissiles(double dt) {
    final dead = <Missile>{};
    for (final m in missiles) {
      m.life -= dt;
      if (m.target == null || !pirates.contains(m.target)) {
        Pirate? best;
        var bd = 900.0;
        for (final e in pirates) {
          final d = (e.pos - m.pos).distance;
          if (d < bd) {
            bd = d;
            best = e;
          }
        }
        m.target = best;
      }
      final t = m.target;
      if (t != null) {
        final desired = (t.pos - m.pos).normalized() * 620;
        m.vel += (desired - m.vel) * min(1, 4 * dt);
      }
      m.pos += m.vel * dt;
      if (_rng.nextDouble() < 0.8) {
        particles.add(Particle(m.pos, -m.vel * 0.1, 0.3, const Color(0xFFFFCC80), 2.5));
      }
      if (t != null && (t.pos - m.pos).distance < t.radius + 6) {
        _hitPirate(t, m.damage, m.pos);
        _burst(m.pos, const Color(0xFFFFAB40), 14);
        sfx.add(Sfx.explode);
        dead.add(m);
      } else if (m.life <= 0) {
        dead.add(m);
      }
    }
    missiles.removeWhere(dead.contains);
  }

  void _hitPirate(Pirate e, double dmg, Offset at, {bool crit = false}) {
    e.hp -= dmg;
    e.hitFlash = 0.1;
    if (crit) {
      _float(at, tr.g_floatCrit(dmg.round()), const Color(0xFFFF9100), big: true);
    } else if (_rng.nextDouble() < 0.6) {
      _float(at, dmg.round().toString(), const Color(0xFFFFF59D));
    }
  }

  void _updateBullets(double dt) {
    final dead = <Bullet>{};
    for (final b in bullets) {
      b.pos += b.vel * dt;
      b.life -= dt;
      if (b.life <= 0) {
        dead.add(b);
        continue;
      }
      if (b.fromPlayer) {
        for (final e in pirates) {
          if (b.hits?.contains(e) ?? false) continue;
          if ((e.pos - b.pos).distance < e.radius) {
            _hitPirate(e, b.damage, b.pos, crit: b.big);
            _spark(b.pos, const Color(0xFFFFF59D));
            sfx.add(Sfx.hit);
            if (b.pierce > 0) {
              // 관통탄: 맞힌 적을 기억하고 계속 날아간다
              b.pierce--;
              (b.hits ??= {}).add(e);
            } else {
              dead.add(b);
            }
            break;
          }
        }
      } else {
        final dome = domeAt(b.pos);
        if (dome != null) {
          _hitDome(dome, b.damage);
          dead.add(b);
          _spark(b.pos, const Color(0xFF80D8FF));
          continue;
        }
        if (player.alive && (player.pos - b.pos).distance < (shielded ? 30 : 18)) {
          _damagePlayer(b.damage);
          dead.add(b);
          _spark(b.pos, const Color(0xFFFF8A80));
          continue;
        }
        for (final s in stations) {
          if ((s.pos - b.pos).distance < 60) {
            s.takeHit(b.damage);
            dead.add(b);
            _spark(b.pos, const Color(0xFFFF8A80));
            break;
          }
        }
      }
      if (dead.contains(b)) continue;
      for (final a in asteroids) {
        if ((a.pos - b.pos).distance < a.radius) {
          if (b.fromPlayer) {
            a.hp -= b.damage;
            a.hitFlash = 0.08;
          }
          dead.add(b);
          _spark(b.pos, const Color(0xFFBCAAA4));
          break;
        }
      }
    }
    bullets.removeWhere(dead.contains);

    final killed = pirates.where((e) => e.hp <= 0).toList();
    for (final e in killed) {
      pirates.remove(e);
      _onKilled(e);
    }

    final destroyed = stations.where((s) => s.hp <= 0).toList();
    for (final s in destroyed) {
      if (s == homeBase) {
        _disableBase(s);
        continue;
      }
      stations.remove(s);
      _burst(s.pos, const Color(0xFFFF5252), 100);
      sfx.add(Sfx.bigExplode);
      say(Speaker.advisor, tr.g_dlgStationDestroyed(iGa(s.name)));
    }
  }

  void _onKilled(Pirate e) {
    final boss = e.kind == PirateKind.boss;
    _burst(e.pos, e.kind == PirateKind.jelly ? const Color(0xFFE040FB) : const Color(0xFFFF7043),
        boss ? 100 : 35);
    sfx.add(boss ? Sfx.bigExplode : Sfx.explode);
    shake = min(20, shake + (boss ? 16 : 3));
    final bounty = (e.bounty * sectorMul * (1 + crewBonus(CrewRole.trader)) *
            (e.name != null ? 4 : 1))
        .round();
    _dropPickups(e.pos, PickupKind.credits, bounty, boss ? 10 : 3);

    if (e.kind == PirateKind.jelly) {
      profile.addStat('jelly');
      _dropPickups(e.pos, PickupKind.ore, 30, 3);
      if (_rng.nextDouble() < 0.35) {
        pickups.add(Pickup(PickupKind.gem, e.pos, 1, OffsetX.fromAngle(_rng.nextDouble() * 6, 80)));
      }
      return;
    }

    _count('kills');
    profile.addStat('kills');
    for (final m in activeMissions) {
      if (m.type == MissionType.kill) m.progress++;
      if (m.type == MissionType.bounty && e.missionId == m.id) m.progress = 1;
    }

    if (_rng.nextDouble() < (boss ? 1 : 0.08)) {
      final pk = PowerUpKind.values[_rng.nextInt(PowerUpKind.values.length)];
      pickups.add(Pickup(PickupKind.power, e.pos, 1,
          OffsetX.fromAngle(_rng.nextDouble() * 6, 60), power: pk));
    }

    if (boss) {
      profile.addStat('bosses');
      _dropPickups(e.pos, PickupKind.ore, (120 * sectorMul).round(), 6);
      _dropPickups(e.pos, PickupKind.gem, 5, 5);
      if (e.sectorBoss) {
        if (!bossDefeated) {
          _count('sectorBosses');
          // 게이트는 발전도로 열린다. 두목은 큰 보상을 주는 도전 과제.
          final reward = (1000 * sectorMul).round();
          credits += reward;
          say(Speaker.advisor, tr.g_dlgBossDefeated(reward));
        }
        bossDefeated = true;
        say(Speaker.pirate, tr.g_pirateBossLose);
      } else {
        say(Speaker.pirate, tr.g_pirateBossFlee);
      }
    } else if (e.name != null) {
      say(Speaker.captain, tr.g_dlgBountyCaught(e.name ?? ''));
    } else if (_rng.nextDouble() < 0.12) {
      say(Speaker.captain, [tr.g_captainKill0, tr.g_captainKill1, tr.g_captainKill2, tr.g_captainKill3][_rng.nextInt(4)]);
    }
  }

  void _updateAsteroids(double dt) {
    for (final a in asteroids) {
      a.rotation += a.spin * dt;
      a.hitFlash = max(0, a.hitFlash - dt);
      if (a.drift != Offset.zero) a.pos += a.drift * dt;
    }
    // 떠다니는 유성우 소행성이 맵 밖으로 나가면 제거
    asteroids.removeWhere((a) =>
        a.drift != Offset.zero &&
        (a.pos.dx.abs() > worldHalf + 100 || a.pos.dy.abs() > worldHalf + 100));
    final broken = asteroids.where((a) => a.hp <= 0).toList();
    for (final a in broken) {
      asteroids.remove(a);
      _count('asteroids');
      sfx.add(Sfx.hit);
      _burst(a.pos, a.crystal ? const Color(0xFF4DD0E1) : const Color(0xFFA1887F), 20);
      _dropPickups(a.pos, PickupKind.ore, (a.radius / 3 * (a.crystal ? 3 : 1) * sectorMul).round(), 3);
      if (_rng.nextDouble() < 0.3) {
        _dropPickups(a.pos, PickupKind.credits, (10 * sectorMul).round(), 1);
      }
    }
    while (asteroids.length < maxAsteroids) {
      _spawnAsteroid(awayFrom: player.pos);
    }
  }

  void _dropPickups(Offset pos, PickupKind kind, int total, int pieces) {
    final each = max(1, total ~/ pieces);
    for (var i = 0; i < pieces; i++) {
      pickups.add(Pickup(kind, pos, each,
          OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, randRange(_rng, 40, 140))));
    }
  }

  void _updatePickups(double dt) {
    final magnet = magnetRadius;
    for (final k in pickups) {
      k.life -= dt;
      final to = player.pos - k.pos;
      final d = to.distance;
      if (player.alive && d < magnet) {
        k.vel += to.normalized() * magnetPull * dt;
      }
      k.vel = k.vel * pow(0.2, dt).toDouble();
      k.pos += k.vel * dt;
      if (player.alive && d < 24) {
        k.life = 0;
        _collect(k);
      }
    }
    pickups.removeWhere((k) => k.life <= 0);
  }

  void _collect(Pickup k) {
    switch (k.kind) {
      case PickupKind.credits:
        final n = k.amount * (buffs.containsKey(PowerUpKind.doubleCredits) ? 2 : 1);
        credits += n;
        sfx.add(Sfx.coin);
        _float(k.pos, '+$n', const Color(0xFFFFD54F));
      case PickupKind.ore:
        final n =
            (k.amount * (1 + crewBonus(CrewRole.miner)) * ship.oreMul * profile.home.oreMul).round();
        ore += n;
        profile.addStat('ore', n);
        for (final m in activeMissions) {
          if (m.type == MissionType.mine) m.progress += n;
        }
        sfx.add(Sfx.pickup);
        _float(k.pos, '+$n💎', const Color(0xFF4DD0E1));
      case PickupKind.gem:
        profile.gems += k.amount;
        profile.dirty = true;
        sfx.add(Sfx.gem);
        _float(k.pos, '+${k.amount}⭐', const Color(0xFFFF80AB), big: true);
      case PickupKind.power:
        final pk = k.power!;
        buffs[pk] = pk.duration;
        profile.addStat('powerups');
        sfx.add(Sfx.upgrade);
        _float(k.pos, '${pk.icon} ${pk.label}!', const Color(0xFFB9F6CA), big: true);
    }
  }

  void _updateParticles(double dt) {
    for (final p in particles) {
      p.life -= dt;
      p.pos += p.vel * dt;
      p.vel = p.vel * pow(0.1, dt).toDouble();
    }
    particles.removeWhere((p) => p.life <= 0);
    if (particles.length > 600) particles.removeRange(0, particles.length - 600);
  }

  // ---------- 이벤트 ----------
  void _updateEvents(double dt) {
    eventTimer -= dt;
    if (eventTimer <= 0 && player.alive) {
      eventTimer = randRange(_rng, 90, 150);
      if (events.length < 2) _startRandomEvent();
    }
    for (final ev in events) {
      ev.timeLeft -= dt;
      switch (ev.kind) {
        case EventKind.raid:
          final attackers = pirates.where((e) => e.eventId == ev.id).toList();
          final planet = ev.planet!;
          // 방어막이 버티는 동안은 생산이 계속된다
          planet.raided = !planet.domeUp &&
              attackers.any((e) => (e.pos - planet.pos).distance < planet.radius + 450);
          if (attackers.isEmpty) {
            ev.finished = true;
            planet.raided = false;
            final reward = (200 * sectorMul).round();
            credits += reward;
            profile.gems += 2;
            sfx.add(Sfx.coin);
            say(Speaker.advisor, tr.g_dlgRaidDefended(planet.name, reward));
          } else if (ev.timeLeft <= 0) {
            ev.finished = true;
            planet.raided = false;
            pirates.removeWhere((e) => e.eventId == ev.id);
            if (planet.domeUp) {
              // 방어막이 끝까지 버텼다
            } else if (planet.colonyLevel > 1) {
              planet.colonyLevel--;
              say(Speaker.advisor, tr.g_dlgRaidLooted(iGa(planet.name), euro('Lv.${planet.colonyLevel}')));
            } else {
              say(Speaker.advisor, tr.g_dlgRaidLeft(eul(planet.name)));
            }
          }
        case EventKind.supply:
          if (_supplyCapsule == null || !pickups.contains(_supplyCapsule)) {
            ev.finished = true;
            if (_supplyCapsule != null && _supplyCapsule!.life <= 0 && ev.timeLeft > 0) {
              say(Speaker.advisor, tr.g_dlgSupplyCollected);
            }
            _supplyCapsule = null;
          } else if (ev.timeLeft <= 0) {
            ev.finished = true;
            pickups.remove(_supplyCapsule);
            _supplyCapsule = null;
          }
        case EventKind.meteor:
        case EventKind.merchant:
          if (ev.timeLeft <= 0) {
            ev.finished = true;
            if (ev.kind == EventKind.merchant) {
              merchantCrew = null;
              say(Speaker.merchant, tr.g_merchantBye);
            }
          }
      }
    }
    events.removeWhere((e) => e.finished);
  }

  void _startRandomEvent() {
    final colonies = planets.where((p) => p.colonyLevel > 0).toList();
    final options = <EventKind>[
      EventKind.meteor,
      EventKind.supply,
      if (!events.any((e) => e.kind == EventKind.merchant)) EventKind.merchant,
      if (colonies.isNotEmpty && !events.any((e) => e.kind == EventKind.raid)) ...[
        EventKind.raid,
        EventKind.raid,
      ],
    ];
    startEvent(options[_rng.nextInt(options.length)]);
  }

  /// 테스트/디버그용으로도 사용
  WorldEvent? startEvent(EventKind kind) {
    final id = _nextId++;
    final away = player.pos + OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, randRange(_rng, 900, 1300));
    final pos = _clampWorld(away, (_) {});
    sfx.add(Sfx.alarm);
    switch (kind) {
      case EventKind.raid:
        final colonies = planets.where((p) => p.colonyLevel > 0).toList();
        if (colonies.isEmpty) return null;
        final planet = colonies[_rng.nextInt(colonies.length)];
        final ev = WorldEvent(id, kind, planet.pos, 150, planet: planet);
        events.add(ev);
        final n = 3 + threat.floor().clamp(0, 6);
        for (var i = 0; i < n; i++) {
          final k = _rng.nextDouble() < 0.3
              ? PirateKind.bomber
              : (_rng.nextBool() ? PirateKind.raider : PirateKind.scout);
          final e = _makePirate(k,
              planet.pos + OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, planet.radius + 500));
          e.eventId = id;
          pirates.add(e);
        }
        say(Speaker.advisor, tr.g_dlgRaidAlert(eul(planet.name)));
        say(Speaker.pirate, tr.g_pirateRaidTaunt);
        return ev;
      case EventKind.meteor:
        final ev = WorldEvent(id, kind, pos, 60);
        events.add(ev);
        final drift = OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, 50);
        for (var i = 0; i < 22; i++) {
          final a = Asteroid(pos + OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, randRange(_rng, 0, 420)),
              randRange(_rng, 14, 26), _rng.nextInt(99999), crystal: true)
            ..drift = drift;
          asteroids.add(a);
        }
        say(Speaker.advisor, tr.g_dlgMeteor);
        return ev;
      case EventKind.merchant:
        final ev = WorldEvent(id, kind, pos, 120);
        events.add(ev);
        merchantCrew = CrewMember.random(_rng, _nextId++, odds: const {2: 70, 3: 30});
        merchantGemTrades = 0;
        say(Speaker.merchant, tr.g_merchantHello);
        return ev;
      case EventKind.supply:
        final ev = WorldEvent(id, kind, pos, 120);
        events.add(ev);
        _supplyCapsule = Pickup(PickupKind.gem, pos, 5 + _rng.nextInt(6), Offset.zero)..life = 120;
        pickups.add(_supplyCapsule!);
        for (var i = 0; i < 2 + sector; i++) {
          pirates.add(_makePirate(PirateKind.raider,
              pos + OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, 200)));
        }
        say(Speaker.advisor, tr.g_dlgSupplySignal);
        return ev;
    }
  }

  // 상인 거래
  int get merchantCrewPrice => (1500 * sectorMul).round();
  int get merchantGemPrice => (1000 * sectorMul).round();
  static const merchantPowerPrice = 150;

  bool buyMerchantCrew() {
    final c = merchantCrew;
    if (c == null || roster.length >= rosterCap) return false;
    if (!_pay((merchantCrewPrice, 0))) return false;
    merchantCrew = null;
    _addCrew(c);
    return true;
  }

  bool buyGemsFromMerchant() {
    if (merchantGemTrades >= 3) return false;
    if (!_pay((merchantGemPrice, 0))) return false;
    merchantGemTrades++;
    profile.gems += 5;
    profile.dirty = true;
    sfx.add(Sfx.gem);
    return true;
  }

  bool buyPowerUp(PowerUpKind k) {
    if (!_pay((merchantPowerPrice, 0))) return false;
    buffs[k] = k.duration * 2;
    sfx.add(Sfx.upgrade);
    return true;
  }

  // ---------- 스폰 ----------
  void _updateSpawning(double dt) {
    spawnTimer -= dt;
    jellyTimer -= dt;
    final t = threat;
    final normal = pirates.where((e) => e.isPirate && e.eventId == null && e.name == null).length;
    final maxPirates = min(18, (2 + (t - sector) * 1.5 + sector).floor());

    // 섹터 두목: 스토리 단계이거나 위협도가 충분히 오르면 등장
    final storyWantsBoss = story.key == 'sectorBosses' && storyTimer > 12;
    if (!bossDefeated &&
        !sectorBossSpawned &&
        player.alive &&
        (storyWantsBoss || t >= 1 + sector + 3)) {
      sectorBossSpawned = true;
      final e = _makePirate(PirateKind.boss, _spawnPos(), hpMul: 1.6)..sectorBoss = true;
      pirates.add(e);
      sfx.add(Sfx.alarm);
      say(Speaker.pirate, tr.g_pirateBossArrive(sectorName));
      say(Speaker.advisor, tr.g_dlgBossWarning);
    }
    // 두목이 사라졌으면(예: 다른 곳으로 이동) 다시 등장할 수 있게
    if (sectorBossSpawned && !bossDefeated && !pirates.any((e) => e.sectorBoss)) {
      sectorBossSpawned = false;
    }

    // 일반 두목: 섹터 두목 격파 후 위협도 3마다
    if (bossDefeated && t >= 1 + sector + (bossesSpawned + 1) * 3 && player.alive) {
      bossesSpawned++;
      pirates.add(_makePirate(PirateKind.boss, _spawnPos()));
      sfx.add(Sfx.alarm);
      say(Speaker.pirate, tr.g_pirateRevenge);
    }

    if (spawnTimer <= 0 && normal < maxPirates && player.alive) {
      spawnTimer = max(3.0, 13 - (t - sector) * 1.2);
      final group = 1 + _rng.nextInt(min(4, max(1, t.floor())));
      for (var i = 0; i < group; i++) {
        pirates.add(_makePirate(_randomKind(t), _spawnPos()));
      }
      if (_rng.nextDouble() < 0.3) {
        say(Speaker.pirate, [tr.g_pirateAmbush0, tr.g_pirateAmbush1, tr.g_pirateAmbush2, tr.g_pirateAmbush3][_rng.nextInt(4)]);
      }
    }

    if (jellyTimer <= 0) {
      jellyTimer = 40;
      if (pirates.where((e) => e.kind == PirateKind.jelly).length < 3) {
        pirates.add(_makePirate(PirateKind.jelly, _spawnPos())
          ..wanderAngle = _rng.nextDouble() * 2 * pi);
      }
    }
  }

  PirateKind _randomKind(double t) {
    final r = _rng.nextDouble();
    if (t >= 2.5 && r < 0.15) return PirateKind.bomber;
    if (t >= 3.5 && r < 0.27) return PirateKind.sniper;
    if (r < min(0.55, 0.1 * t)) return PirateKind.raider;
    return PirateKind.scout;
  }

  Offset _spawnPos() => _clampWorld(
      player.pos + OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, randRange(_rng, 900, 1200)),
      (_) {});

  Pirate _makePirate(PirateKind kind, Offset pos, {double hpMul = 1}) {
    final scale = (1 + (threat - 1 - sector) * 0.15) * sectorMul * hpMul;
    return Pirate(kind, pos, Pirate.baseHp(kind) * scale, dmgScale: 1 + sector * 0.3)
      ..wanderAngle = _rng.nextDouble() * 2 * pi;
  }

  void _updateMissions(double dt) {
    offerTimer -= dt;
    if (offerTimer <= 0) _refreshOffers();
    for (final m in [...activeMissions]) {
      if (m.type == MissionType.deliver) {
        final idx = m.planetIndex;
        if (idx != null && idx < planets.length &&
            (planets[idx].pos - player.pos).distance < planets[idx].radius + 140 &&
            player.alive) {
          m.progress = 1;
        }
      }
      if (m.type == MissionType.bounty && m.bountySpawned &&
          !m.done && !pirates.any((e) => e.missionId == m.id)) {
        _spawnBounty(m);
      }
      if (m.done) _completeMission(m);
    }
  }

  void _spark(Offset pos, Color c) {
    for (var i = 0; i < 4; i++) {
      particles.add(Particle(pos,
          OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, randRange(_rng, 60, 160)), 0.25, c, 2));
    }
  }

  void _burst(Offset pos, Color c, int n) {
    for (var i = 0; i < n; i++) {
      particles.add(Particle(
          pos,
          OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, randRange(_rng, 40, 320)),
          randRange(_rng, 0.4, 1.0),
          i.isEven ? c : const Color(0xFFFFF176),
          randRange(_rng, 2, 5)));
    }
  }

  // ---------- 저장/불러오기 ----------
  static Map<String, dynamic> _stationToJson(Station s) => {
        'name': s.name,
        'x': s.pos.dx,
        'y': s.pos.dy,
        'hab': s.habitatLevel,
        'tur': s.turretLevel,
        'base': s.baseLevel,
        'role': s.role.name,
        'hp': s.hp,
        'off': s.disabledTime,
      };

  static Station _stationFromJson(Map<String, dynamic> s) {
    var pos = Offset((s['x'] as num).toDouble(), (s['y'] as num).toDouble());
    // 예전 저장: 본거지가 원점(지금은 항성 자리)에 있었다
    if (pos == Offset.zero) pos = homePos;
    // 예전 저장: 역할이 없으면 본거지 자리는 본거지, 나머지는 보급 기지
    final role = StationRole.values.where((r) => r.name == s['role']).firstOrNull ??
        (pos == homePos ? StationRole.home : StationRole.support);
    final st = Station(s['name'] as String, pos, role: role)
      ..habitatLevel = s['hab'] as int
      ..turretLevel = s['tur'] as int
      ..baseLevel = (s['base'] as int?) ?? 1
      // 기능 정지 남은 시간도 저장한다 (불러오기로 정지를 풀 수 없게)
      ..disabledTime = (s['off'] as num?)?.toDouble() ?? 0;
    st.hp = min(st.maxHp, (s['hp'] as num?)?.toDouble() ?? st.maxHp);
    return st;
  }

  Map<String, dynamic> toJson() => {
        'v': 2,
        'seed': seed,
        'credits': credits,
        'ore': ore,
        'levels': {for (final e in levels.entries) e.key.name: e.value},
        'counters': counters,
        'sector': sector,
        'current': _saveCurrentSector().toJson(),
        'sectors': {for (final e in sectors.entries) '${e.key}': e.value.toJson()},
        'roster': roster.map((c) => c.toJson()).toList(),
        'recruits': recruitCount,
        'nextId': _nextId,
        'missions': activeMissions.map((m) => m.toJson()).toList(),
        'story': storyIndex,
        'storyBase': storyBase,
        'total': totalTime,
        'px': player.pos.dx,
        'py': player.pos.dy,
        'hp': player.hp,
        'dead': !player.alive,
        'savedAt': DateTime.now().millisecondsSinceEpoch,
      };

  static GameWorld fromJson(Map<String, dynamic> j, Profile profile) {
    final w = GameWorld(seed: j['seed'] as int, profile: profile);
    w.dialogs.clear();
    w.credits = (j['credits'] as num).toDouble();
    w.ore = (j['ore'] as num).toDouble();
    (j['levels'] as Map).forEach((k, v) {
      final kind = UpgradeKind.values.where((u) => u.name == k).firstOrNull;
      if (kind != null) w.levels[kind] = v as int;
    });
    (j['counters'] as Map).forEach((k, v) => w.counters[k as String] = v as int);
    (j['sectors'] as Map).forEach((k, v) =>
        w.sectors[int.parse(k as String)] = SectorSave.fromJson(v as Map<String, dynamic>));
    w._loadSector(j['sector'] as int, SectorSave.fromJson(j['current'] as Map<String, dynamic>));
    for (final c in (j['roster'] as List).cast<Map<String, dynamic>>()) {
      w.roster.add(CrewMember.fromJson(c));
    }
    w.recruitCount = j['recruits'] as int;
    w._nextId = j['nextId'] as int;
    w.player.pos = Offset((j['px'] as num).toDouble(), (j['py'] as num).toDouble());
    for (final m in (j['missions'] as List).cast<Map<String, dynamic>>()) {
      final mission = Mission.fromJson(m);
      w.activeMissions.add(mission);
      if (mission.type == MissionType.bounty) w._spawnBounty(mission);
    }
    w.storyIndex = j['story'] as int;
    w.storyBase = j['storyBase'] as int;
    w.totalTime = (j['total'] as num).toDouble();
    w.player.pos = Offset((j['px'] as num).toDouble(), (j['py'] as num).toDouble());
    w.player.hp = min(w.playerMaxHp, (j['hp'] as num?)?.toDouble() ?? w.playerMaxHp);
    if (j['dead'] == true) {
      // 격추된 채 저장했으면 부활 선택부터 (저장/불러오기로 공짜 부활 방지)
      w.player
        ..alive = false
        ..awaitingRevive = true
        ..deadTime = 0
        ..deathPos = w.player.pos;
    }
    // 예전 저장 호환: 이미 쓰러뜨린 섹터 두목 수
    final defeated = (w.bossDefeated ? 1 : 0) + w.sectors.values.where((e) => e.bossDefeated).length;
    if (w.counter('sectorBosses') < defeated) w.counters['sectorBosses'] = defeated;
    w.savedAt = DateTime.fromMillisecondsSinceEpoch(j['savedAt'] as int);
    w.say(Speaker.advisor, tr.g_dlgWelcomeBack(w.story.title));
    return w;
  }
}
