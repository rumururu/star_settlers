import 'dart:math';
import 'dart:ui';

import '../l10n/l.dart';

import 'crew.dart';
import 'expedition.dart';
import 'game_telemetry.dart';
import 'campaign.dart';
import 'home.dart';
import 'missions.dart';
import 'models.dart';
import 'next_goal.dart';
import 'profile.dart';
import 'rift.dart';
import 'ships.dart';
import 'star_catalog.dart';
import 'surface.dart';
import 'system_traits.dart';

/// 균열 런 아레나 (TASK 005). 같은 라이브러리라 엔진의 비공개 갱신 함수를 그대로 쓴다.
part 'rift_world.dart';

/// 행성 지표 탐험 (surface-exploration). 균열 런처럼 엔진을 다시 쓴다.
part 'surface_world.dart';

class InputState {
  Offset move = Offset.zero; // 길이 0..1
  bool fire = false;

  /// true면 360° 가장 가까운 적을 자동 조준 (자동 사격 모드)
  bool autoAim = false;

  /// 순항: 조이스틱을 놓아도 함선이 바라보는 방향으로 계속 날아간다 (조이스틱으로 방향만 바꾼다)
  bool cruise = false;
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
    UpgradeKind.missile ||
    UpgradeKind.shield ||
    UpgradeKind.drone ||
    UpgradeKind.magnet => 5,
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
    this.defenses = const [],
    this.specs = const [],
    this.discoveries = const [],
  });
  final List<int> colonyLevels;

  /// 행성별 지표 탐험 영구 발견 비트 ([Planet.discoveries]). 지표 탐험 도입 전 저장은 빈 목록
  final List<int> discoveries;

  int discAt(int index) => index < discoveries.length ? discoveries[index] : 0;

  /// 행성별 특화 이름 (특화 없음은 ''). 특화 도입 전 저장은 빈 목록
  final List<String> specs;

  ColonySpec? specAt(int index) =>
      index < specs.length ? ColonySpec.fromName(specs[index]) : null;

  /// 행성별 식민지 건물 레벨 (ColonyBuilding.index 순서)
  final List<List<int>> buildings;

  /// 안정화 내구도, 방어막 내구도, 파괴 여부, 마지막 피격 경과 시간.
  final List<List<num>> defenses;

  double get development => GameWorld.developmentOf([
    for (var i = 0; i < colonyLevels.length; i++)
      i < buildings.length &&
              buildings[i].length > ColonyBuilding.stabilizer.index
          ? buildings[i][ColonyBuilding.stabilizer.index]
          : min(colonyLevels[i], GameWorld.devLevelCap),
  ]);

  final List<Map<String, dynamic>> stations;
  final double elapsed;
  final bool bossDefeated;
  final int bossesSpawned;
  final double idleCredits;
  final double idleOre;

  // 저장값 ic/io는 특성 적용 전 기초 수입을 유지한다. 기존 저장도 같은 규칙으로 읽는다.
  // 정거장 부분만 캐시해 식민지 크레딧 특성이 정거장에 적용되지 않게 한다.
  late final double _stationCredits = stations.indexed.fold(
    0.0,
    (sum, entry) =>
        sum +
        GameWorld._stationFromJson(
          entry.$2,
          sector: 0,
          order: entry.$1,
        ).baseCreditRate,
  );

  double creditRateAt(int sector) {
    final bonus = systemTrait(sector).colonyCreditMul - 1;
    if (bonus == 0) return idleCredits;
    final colonyCredits =
        idleCredits -
        _stationCredits * (1 + sector * GameWorld.sectorIncomeStep);
    return idleCredits + colonyCredits * bonus;
  }

  double oreRateAt(int sector) => idleOre * systemTrait(sector).colonyOreMul;

  Map<String, dynamic> toJson() => {
    'colonies': colonyLevels,
    'stations': stations,
    'elapsed': elapsed,
    'boss': bossDefeated,
    'bosses': bossesSpawned,
    'ic': idleCredits,
    'io': idleOre,
    'bld': buildings,
    'defenses': defenses,
    'spec': specs,
    if (discoveries.any((d) => d != 0)) 'disc': discoveries,
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
    defenses: [
      for (final d in (j['defenses'] as List?) ?? const [])
        (d as List).cast<num>(),
    ],
    specs: [for (final x in (j['spec'] as List?) ?? const []) '${x ?? ''}'],
    discoveries: [
      for (final x in (j['disc'] as List?) ?? const []) x is int ? x : 0,
    ],
  );
}

/// 게임 전체 상태와 규칙. 렌더링/위젯과 분리되어 있어 테스트 가능.
class GameWorld {
  GameWorld({int? seed, Profile? profile, bool showOpening = false})
    : seed = seed ?? Random().nextInt(1 << 30),
      profile = profile ?? Profile() {
    _rng = Random(this.seed);
    counters['campaignGameplayVersion'] = 1;
    _loadSector(0, null);
    player.pos = homePos + const Offset(0, 160);
    player.hp = playerMaxHp;
    say(Speaker.advisor, tr.g_dlgWelcome);
    _startStoryStep();
    if (showOpening) _queueStoryScene(StoryScene.opening);
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
  final enemyMissiles = <EnemyMissile>[];
  final mines = <SpaceMine>[];
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

  /// 크레딧으로 모집한 횟수 (크레딧 모집 가격 계산용. 세이브 키는 예전 그대로 'recruits')
  int recruitCount = 0;
  int _nextId = 1;
  final missionOffers = <Mission>[];
  final activeMissions = <Mission>[];
  double offerTimer = 0;
  int storyIndex = 0;
  int storyBase = 0;
  double storyTimer = 0;

  // ---------- 첫 5분 (TASK 003) ----------
  /// 첫 항성계 미니 두목 상태 카운터: 0 아직 / 1 등장 / 2 처치
  static const miniBossKey = 'r3MiniBoss';

  /// ★3 승무원 확정 지급 여부 카운터 (한 월드에 한 번)
  static const star3GiftKey = 'r3Crew';

  /// ★3 확정 지급 시각(초) — 해적 단계를 이보다 늦게 마쳐도 이때 준다
  static const star3GiftSeconds = 180.0;

  /// 미니 두목 등장 시각(초) — 첫 정착이 이보다 늦어도 이때 나온다
  static const miniBossSeconds = 240.0;

  NextGoal? _goal;

  /// HUD '다음 목표' (0.5초마다 다시 고른다)
  NextGoal get goal => _goal ??= nextGoal(this);

  /// 방금 이룬 목표와 완료 연출 남은 시간
  NextGoal? goalDone;
  double goalFlash = 0;

  /// 목표 칩을 누르면 잠깐 그 목표 쪽으로 안내 화살표를 보여 준다
  double goalPing = 0;

  /// 카드로 공개할 새 승무원 (화면이 보여 주고 비운다)
  CrewMember? crewReveal;

  // ---------- 승무원 원정 (TASK 004) ----------
  final expeditions = <Expedition>[];

  /// 되돌릴 수 없는 원정 시계 (저장된다)
  final expeditionClock = ExpeditionClock();

  double totalTime = 0;
  double antimatterExposure = 0;
  double _finalSyncSeconds = 0;
  double finalCounterattackSeconds = 0;
  double spawnTimer = 25;
  double eventTimer = 70;

  /// 다음 대규모 침공까지 (항성계에 들어오면 [invasionFirstDelay]부터 새로 센다)
  double invasionTimer = invasionFirstDelay;

  /// 진행 중이거나 결과를 보여 주는 대규모 침공. 저장하지 않는다.
  Invasion? invasion;
  double jellyTimer = 20;
  double _secondTimer = 0;
  double _playAcc = 0;
  double shake = 0;
  double boostTime = 0;
  bool paused = false;

  double get antimatterApproach =>
      finalMissionStage == FinalMissionStage.complete
      ? 0
      : (1 - exp(-antimatterExposure / 7200)).clamp(0.0, 1.0);
  Offset get antimatterPosition =>
      Offset.fromDirection(-pi / 4, 5400 - 800 * antimatterApproach);
  double get antimatterDistance => antimatterPosition.distance;

  bool get enemyIdentityKnown =>
      counter('campaignDone_16') > 0 || counter('campaignSector_16') == 2;
  String get enemySpeakerName =>
      enemyIdentityKnown ? tr.c_severanceName : tr.n_enemyCommander;

  // 떠돌이 상인
  CrewMember? merchantCrew;
  int merchantGemTrades = 0;
  Pickup? _supplyCapsule;
  Pickup? get supplyCapsule => _supplyCapsule;

  // ---------- 파생 스탯 ----------
  int level(UpgradeKind k) => levels[k]!;

  /// 최고 도달 항성계에 따라 모든 항성계에 함께 적용되는 식민지 상한.
  int get colonyLevelCap => min(4 + counter('maxSector'), Planet.maxLevel);

  /// 이미 보유한 레벨은 유지하고, 추가 강화에만 적용한다.
  int upgradeCap(UpgradeKind k) {
    final initialCap = switch (k) {
      UpgradeKind.weapon || UpgradeKind.hull || UpgradeKind.engine => 4,
      _ => 2,
    };
    return min(k.maxLevel, initialCap + counter('maxSector'));
  }

  int get weaponLevel => level(UpgradeKind.weapon);

  double crewBonus(CrewRole r) =>
      roster
          .where((c) => c.assigned && c.role == r)
          .fold(0, (s, c) => s + c.bonusPct) /
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
      (260 + level(UpgradeKind.engine) * 40.0) *
      (1 + crewBonus(CrewRole.pilot)) *
      ship.speedMul *
      trait.speedMul;
  double get playerDamage =>
      (10 + weaponLevel * 5.0) *
      (1 + crewBonus(CrewRole.gunner)) *
      ship.dmgMul *
      profile.honorDamageMul *
      profile.home.damageMul *
      (finalPhaseLinked ? 2.5 : 1);
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
  double get droneDamage =>
      (5 + droneLevel * 4) *
      (1 + crewBonus(CrewRole.gunner)) *
      profile.honorDamageMul;
  double get droneInterval => 1.2 - droneLevel * 0.15;
  int get playerShots => weaponLevel >= 6 ? 3 : (weaponLevel >= 3 ? 2 : 1);
  double get cooldownMul =>
      trait.skillCooldownMul *
      max(
        0.4,
        (1 - min(0.5, crewBonus(CrewRole.scientist))) *
            profile.home.cooldownMul,
      );
  double get missileCooldownMax => 8 * cooldownMul;
  double get shieldCooldownMax => 18 * cooldownMul;
  double get boostCooldownMax => 4 * cooldownMul;
  bool get shielded =>
      player.shieldTime > 0 || buffs.containsKey(PowerUpKind.shield);

  /// 함선 고유 수호막(오로라)이 충전되어 있는가
  bool get guardReady => ship.guardInterval > 0 && player.guardCooldown <= 0;

  // ---------- 항성계 밸런스 ----------
  /// 생산·현상금·보상(그리고 해적 체력) 배율: 항성계마다 +[sectorIncomeStep]
  static const sectorIncomeStep = 0.5;
  double get sectorMul => 1 + sector * sectorIncomeStep;
  SystemTrait? get trait => systemTrait(sector);

  /// 비용 배율: 첫 항성계 1, 두 번째 ×[sectorCostJump], 그 뒤로 항성계마다 ×[sectorCostGrowth].
  /// 생산(+50%씩)보다 훨씬 빨리 올라서 첫 항성계는 한 번에(20~40분), 두 번째는 하루쯤,
  /// 그 뒤로는 며칠씩 걸린다. 무료로도 끝까지 갈 수는 있다.
  /// (예전 1 + 0.3×섹터는 생산이 비용보다 빨리 늘어 뒤로 갈수록 오히려 쉬워졌다)
  /// 떠나온 항성계 수입은 100% 들어오므로 그만큼 비용을 높였다 (예전 50% 수입일 때 ×34, ×1.8).
  static const sectorCostJump = 42.0;
  static const sectorCostGrowth = 1.85;
  static double costMulAt(int sector) =>
      sector <= 0 ? 1 : sectorCostJump * pow(sectorCostGrowth, sector - 1);
  double get costMul => costMulAt(sector);

  /// 전투·임무 보상 배율: 생산 배율 × 비용 배율^[rewardCostExponent].
  /// 생산 배율만 따르면 뒤 항성계에서 사냥·임무가 의미 없어지고(비용만 수백 배),
  /// 비용 배율을 그대로 따르면 사냥만으로 진행된다. 직접 플레이가 수입의 한 축이 되게 중간.
  static const rewardCostExponent = 0.4;
  double get baseRewardMul => sectorMul * pow(costMul, rewardCostExponent);
  double get rewardMul => baseRewardMul * trait.rewardMul;

  /// 해적 공격력 배율: 항성계마다 +[enemyDamageStep], 세 번째 항성계부터 [lateEnemyDamageStep]씩 더.
  /// 체력은 [enemyHpMul]. 뒤 항성계는 함선 강화가 만렙(Lv.8)에 닿은 뒤라 해적만 계속 세지고,
  /// 기본 함선은 버티기 힘들어진다 → 프리미엄 함선(체력·수리·수호막·관통)이 차이를 만든다.
  static const enemyDamageStep = 0.3;
  static const lateEnemyDamageStep = 0.25;
  static const lateEnemyHpStep = 0.2;

  /// 세 번째 항성계(인덱스 2)부터 1, 2, 3…
  int get lateSystems => max(0, sector - 1);
  double get enemyDamageMul =>
      1 + sector * enemyDamageStep + lateSystems * lateEnemyDamageStep;

  /// 해적 체력 배율: [sectorMul] × (1 + [lateEnemyHpStep] × [lateSystems])
  double get enemyHpMul => sectorMul * (1 + lateSystems * lateEnemyHpStep);

  /// 함선이 직접 번 크레딧 배율 (프리미엄 함선 보너스)
  double get shipCreditMul => ship.creditMul;

  /// 본거지 레이저가 잡은 해적은 현상금을 이 비율만 떨군다
  /// (안전 구역에 숨어 레이저로 무한 사냥하는 파밍 방지)
  static const laserBountyRatio = 0.25;

  /// 실제 항성계 이름 (태양계 → 알파 센타우리 → … → 우리 은하 중심 → 이웃 은하)
  String get sectorName => systemName(sector);

  int get colonyCount => planets.where((p) => p.colonyLevel > 0).length;

  /// 시간이 올리는 위협도 상한: 항성계에 9분 머물면 +6에서 멈춘다 (안 그러면 끝없이 오른다)
  static const threatTimeCap = 6.0;

  /// 첫 항성계에서 소행성·해적 목표를 하는 동안 (스토리 2단계 = 식민지 목표 전).
  /// 적 수는 줄이지 않고(초반에 많이 나와야 재미있다) 적 공격과 적이 떨어뜨리는 크레딧만 줄인다 — [_newbieMul].
  bool get _tutorialCalm => sector == 0 && storyIndex < 2;

  /// 이 스토리 단계에 들어설 때 순항을 켜고 안내한다 (= 첫 튜토리얼 [_tutorialCalm]이 끝날 때)
  static const cruiseTipStep = 2;

  double get threat =>
      1 +
      sector * 1.0 +
      min(sectorElapsed / 90, threatTimeCap) +
      colonyCount * 0.3 +
      stations.fold<int>(0, (s, st) => s + st.habitatLevel - 1) * 0.15;

  /// 전체 수입 배율 (승무원·프리미엄·명예·내 행성)
  double get incomeMul => _incomeMul;

  /// ★4 전설 승무원 지휘 보너스 (생산 배율, 크레딧·광석 공통).
  /// 한 명이라도 배치되어 있으면 적용되고, 여러 명이어도 겹치지 않는다 (전설 여럿을 사서 무한히 쌓지 않게).
  double get legendIncomeMul => roster.any((c) => c.assigned && c.legendary)
      ? 1 + CrewMember.legendPerkPct / 100
      : 1.0;

  double get _incomeMul =>
      (1 + crewBonus(CrewRole.trader)) *
      (profile.premium ? 1.25 : 1) *
      legendIncomeMul *
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
      if (s.supportBonus > best &&
          (s.pos - p.pos).distance < Station.supportRange) {
        best = s.supportBonus;
      }
    }
    return best;
  }

  double planetCreditRate(Planet p) => p.raided
      ? 0
      : p.baseCreditRate *
            sectorMul *
            _incomeMul *
            (1 + supportBonusAt(p)) *
            trait.colonyCreditMul;
  double planetOreRate(Planet p) => p.raided
      ? 0
      : p.baseOreRate *
            (1 + supportBonusAt(p)) *
            sectorMul *
            (1 + crewBonus(CrewRole.miner)) *
            legendIncomeMul *
            profile.home.oreMul *
            trait.colonyOreMul;
  double stationCreditRate(Station s) =>
      s.baseCreditRate * sectorMul * _incomeMul;

  double get otherSectorCredits =>
      sectors.entries.fold(0.0, (s, e) => s + e.value.creditRateAt(e.key)) *
      _incomeMul;
  double get otherSectorOre =>
      sectors.entries.fold(0.0, (s, e) => s + e.value.oreRateAt(e.key)) *
      legendIncomeMul;

  double get creditIncome =>
      planets.fold(0.0, (s, p) => s + planetCreditRate(p)) +
      stations.fold(0.0, (s, st) => s + stationCreditRate(st)) +
      otherSectorCredits;
  double get oreIncome =>
      planets.fold(0.0, (s, p) => s + planetOreRate(p)) + otherSectorOre;

  /// 제국 가치 (진행도 점수)
  int get empireValue =>
      planets.fold<int>(
        0,
        (s, p) =>
            s +
            p.colonyLevel * 100 +
            p.buildings.values.fold<int>(0, (a, b) => a + b) * 60,
      ) +
      stations.fold<int>(
        0,
        (s, st) => s + (st.habitatLevel + st.turretLevel) * 120,
      ) +
      sectors.values.fold<int>(
        0,
        (s, e) =>
            s +
            e.colonyLevels.fold<int>(0, (a, b) => a + b) * 100 +
            e.buildings.fold<int>(
                  0,
                  (a, l) => a + l.fold<int>(0, (x, y) => x + y),
                ) *
                60,
      ) +
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
      UpgradeKind.missile ||
      UpgradeKind.shield ||
      UpgradeKind.drone => ((250 * pow(1.8, lv)).round(), 50 * (lv + 1)),
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

  /// 광석 기본 시세 (시장 시세는 이 값의 0.65~1.35배로 출렁인다)
  double get oreBasePrice => 2 + sector * 0.6;

  double get orePrice =>
      oreBasePrice * (1 + 0.35 * sin(totalTime / 40)) * trait.orePriceMul;

  // ---------- 섹터 생성 / 이동 ----------
  void _loadSector(int index, SectorSave? save) {
    final oldSpawnMul = trait.spawnIntervalMul;
    sector = index;
    spawnTimer *= trait.spawnIntervalMul / oldSpawnMul;
    planets.clear();
    stations.clear();
    gates.clear();
    asteroids.clear();
    pirates.clear();
    bullets.clear();
    missiles.clear();
    enemyMissiles.clear();
    mines.clear();
    pickups.clear();
    events.clear();
    // 항성계를 옮기면 진행 중 침공은 보상 없이 취소, 타이머는 새로 시작
    invasion = null;
    invasionTimer = invasionFirstDelay;
    merchantCrew = null;
    _supplyCapsule = null;

    // 행성: 첫 행성은 본거지 근처 안쪽 궤도, 나머지는 바깥 궤도들에 돌아가며 고르게 나눠 놓는다.
    // 같은 궤도의 행성은 같은 속도로 돌아서 처음 간격이 유지되고, 궤도 사이는 400 이상이라
    // 가장 큰 가스 행성 둘(반지름 200 미만)도 겹치지 않는다.
    final r = Random(seed + index * 7919);
    final orbitRng = Random(seed + index * 31 + 7);
    final count = planetCountFor(index);
    final others = count - 1;
    final perOrbit = [
      for (var o = 0; o < outerOrbits.length; o++)
        others ~/ outerOrbits.length +
            (o < others % outerOrbits.length ? 1 : 0),
    ];
    final orbitStart = [
      for (final _ in outerOrbits) orbitRng.nextDouble() * 2 * pi,
    ];
    final placed = List.filled(outerOrbits.length, 0);
    for (var i = 0; i < count; i++) {
      final (name, kind) = _planetIdentity(index, i, count, r);
      final radius = i == 0
          ? 110.0
          : kind == PlanetKind.gas
          ? randRange(r, 150, 200)
          : randRange(r, 90, 140);
      final double orbit;
      final double phase;
      if (i == 0) {
        orbit = innerOrbit;
        phase = pi / 2 - 0.55;
      } else {
        final o = (i - 1) % outerOrbits.length;
        final n = perOrbit[o];
        final k = placed[o]++;
        orbit = outerOrbits[o];
        // 같은 궤도에 n개를 고르게, 조금씩 흔들어서
        phase =
            orbitStart[o] +
            k * 2 * pi / n +
            randRange(orbitRng, -0.25, 0.25) / n;
      }
      final at = i;
      planets.add(
        Planet(
          name,
          radius,
          kind,
          orbitRadius: orbit,
          orbitPhase: phase,
          nameOf: () => planetIdentity(index, at, count).name,
        ),
      );
    }

    // 워프 게이트: 앞으로 가는 게이트는 모든 궤도 바깥 모서리, 돌아가는 게이트는 본거지 옆
    final corner = orbitRng.nextInt(4);
    final gatePos = Offset(
      corner.isEven ? 3550 : -3550,
      corner < 2 ? -3550 : 3550,
    );
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
      for (var i = 0; i < planets.length; i++) {
        planets[i].spec = save.specAt(i);
        planets[i].discoveries = save.discAt(i);
      }
      for (var i = 0; i < planets.length; i++) {
        final p = planets[i];
        // 안정화 기기 도입 이전 저장은 기존 완성도만큼 한 번 보정한다.
        // 새 형식의 명시적인 Lv.0(파괴됨)은 절대 복구하지 않는다.
        if (i >= save.buildings.length ||
            save.buildings[i].length <= ColonyBuilding.stabilizer.index) {
          p.buildings[ColonyBuilding.stabilizer] = min(
            p.colonyLevel,
            devLevelCap,
          );
        }
        p.stabilizerHp = p.stabilizerMaxHp(sectorMul);
        if (p.colonyLevel > 0) p.shieldHp = p.shieldMax(sectorMul);
        if (i < save.defenses.length && save.defenses[i].length >= 4) {
          final d = save.defenses[i];
          p.stabilizerHp = d[0].toDouble().clamp(
            0,
            p.stabilizerMaxHp(sectorMul),
          );
          p.shieldHp = d[1].toDouble().clamp(0, p.shieldMax(sectorMul));
          p.shieldBroken = d[2] != 0;
          p.sinceShieldHit = d[3].toDouble();
          if (d.length >= 6) {
            p.relayShieldHp = d[4].isFinite ? max(0, d[4].toDouble()) : 0;
            p.relayShieldCooldown = d[5].isFinite
                ? d[5].toDouble().clamp(0, 30)
                : 0;
          }
        }
      }
      for (final s in save.stations) {
        stations.add(
          _stationFromJson(s, sector: index, order: stations.length),
        );
      }
      sectorElapsed = save.elapsed;
      bossDefeated = save.bossDefeated;
      bossesSpawned = save.bossesSpawned;
    } else {
      final home = Station.named(
        index == 0 ? const StationName.haven() : StationName.outpost(index),
        homePos,
        role: StationRole.home,
      )..turretLevel = 1;
      stations.add(home..hp = home.maxHp);
      sectorElapsed = 0;
      bossDefeated = false;
      bossesSpawned = 0;
    }
    if (stations.isEmpty) {
      final home = Station.named(
        StationName.outpost(index),
        homePos,
        role: StationRole.home,
      );
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
      for (final p in planets)
        [for (final b in ColonyBuilding.values) p.building(b)],
    ],
    defenses: [
      for (final p in planets)
        [
          p.stabilizerHp,
          p.shieldHp,
          p.shieldBroken ? 1 : 0,
          p.sinceShieldHit,
          p.relayShieldHp,
          p.relayShieldCooldown,
        ],
    ],
    specs: [for (final p in planets) p.spec?.name ?? ''],
    discoveries: [for (final p in planets) p.discoveries],
    stations: stations.map(_stationToJson).toList(),
    elapsed: sectorElapsed,
    bossDefeated: bossDefeated,
    bossesSpawned: bossesSpawned,
    idleCredits:
        planets.fold(0.0, (s, p) => s + p.baseCreditRate * sectorMul) +
        stations.fold(0.0, (s, st) => s + st.baseCreditRate * sectorMul),
    idleOre: planets.fold(0.0, (s, p) => s + p.baseOreRate * sectorMul),
  );

  WarpGate? get nearbyGate {
    for (final g in gates) {
      if ((g.pos - player.pos).distance < 160) return g;
    }
    return null;
  }

  // ---------- 항성계 구성 ----------
  /// 항성계의 행성 수: 첫 항성계 [firstSystemPlanets]개, 항성계마다 +[planetsPerSystem], 최대 [maxPlanets].
  /// 완성도 목표는 행성 수 × 안정화 기기 3레벨이다.
  static const firstSystemPlanets = 9;
  static const planetsPerSystem = 2;
  static const maxPlanets = 21;
  static int planetCountFor(int sector) =>
      min(maxPlanets, firstSystemPlanets + planetsPerSystem * max(0, sector));

  /// 행성 이름·종류: 실제 항성계 카탈로그(star_catalog.dart). 실제 행성이 먼저, 모자라면
  /// 실제 명명 규칙을 이은 가상 행성. 태양계 첫 행성(튜토리얼 식민지)은 화성.
  /// 배치 난수 순서를 예전과 같게 두려고 [r]을 한 번 소비한다.
  (String, PlanetKind) _planetIdentity(int sector, int i, int count, Random r) {
    r.nextInt(PlanetKind.values.length);
    final id = planetIdentity(sector, i, count);
    return (id.name, id.kind);
  }

  // ---------- 항성계 발전도 ----------
  /// 행성 수당 안정화 기기 목표 레벨 (개별 기기의 기여 상한은 아님)
  static const devLevelCap = 3;

  /// 안정화 기기 레벨 합계 / (행성 수 × 3). Lv.4·5도 모두 기여한다.
  static double developmentOf(List<int> levels) => levels.isEmpty
      ? 0
      : (levels.fold<int>(0, (s, l) => s + max(0, l)) /
                (levels.length * devLevelCap))
            .clamp(0.0, 1.0);

  /// 현재 항성계 발전도
  double get development => developmentOf([
    for (final p in planets) p.building(ColonyBuilding.stabilizer),
  ]);

  /// 발전도 100%가 되면 다음 항성계로 가는 게이트가 열린다 (한 번 가 본 곳은 계속 열림)
  bool gateOpen(WarpGate g) =>
      !g.forward ||
      counter('maxSector') > sector ||
      (sector == campaignFinalSector &&
              finalMissionStage != FinalMissionStage.complete
          ? false
          : development >= 1 && !campaignMissionActive);

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
        .where(
          (m) => m.type == MissionType.deliver || m.type == MissionType.bounty,
        )
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
    GameTelemetry.emit(TelemetryEvent.firstWarp);
    if (to > counter('maxSector')) {
      counters['maxSector'] = to;
      GameTelemetry.emit(TelemetryEvent.systemReached, to + 1);
      // 주간 개척 점수: 처음 가 보는 항성계 (환생 뒤 다시 도착해도 센다)
      profile.weeklyScore.addNewSystem();
      profile.dirty = true;
    }
    profile.maxStat('sector', to + 1);
    profile.codex.recordSystem(to); // 도감 (TASK 006)
    if (to == campaignFinalSector) _queueCampaignSector(to);
    sfx.add(Sfx.warp);
    shake = 12;
    _burst(player.pos, const Color(0xFFB388FF), 80);
    say(
      Speaker.advisor,
      '${tr.g_dlgArrived(sectorName)}${save == null ? ' ${tr.g_dlgNewFrontier}' : ''}',
    );
    if (cancelled.isNotEmpty) {
      say(Speaker.advisor, tr.g_dlgMissionsCancelled);
    }
    final arrivalTrait = trait;
    if (arrivalTrait != null && counter('traitSeen_$to') == 0) {
      counters['traitSeen_$to'] = 1;
      say(Speaker.advisor, tr.g_traitIntro(arrivalTrait.name));
    }
    return true;
  }

  void _spawnAsteroid({required Offset awayFrom, double minDist = 900}) {
    for (var t = 0; t < 50; t++) {
      final pos = Offset(
        randRange(_rng, -worldHalf, worldHalf),
        randRange(_rng, -worldHalf, worldHalf),
      );
      if ((pos - awayFrom).distance < minDist) continue;
      if (pos.distance < starRadius + 250) continue;
      if (planets.any((p) => (p.pos - pos).distance < p.radius + 120)) continue;
      if (stations.any((s) => (s.pos - pos).distance < 250)) continue;
      if (gates.any((g) => (g.pos - pos).distance < 200)) continue;
      asteroids.add(
        Asteroid(pos, randRange(_rng, 18, 55), _rng.nextInt(99999)),
      );
      return;
    }
  }

  void say(Speaker s, String text) {
    if (dialogs.any((d) => d.text == text)) return;
    dialogs.add(DialogLine(s, text));
    if (dialogs.length > 5) dialogs.removeAt(0);
  }

  void _float(Offset pos, String text, Color c, {bool big = false}) {
    floats.add(
      FloatText(pos + Offset(randRange(_rng, -10, 10), -10), text, c, big: big),
    );
    if (floats.length > 60) floats.removeAt(0);
  }

  /// 초록 안내 화살표가 가리키는 곳. 목표 칩을 누른 직후에는 그 목표 쪽
  Offset? get storyTarget {
    if (goalPing > 0) {
      final t = _goal?.target2;
      if (t != null) return t;
    }
    return storyGuideTarget;
  }

  /// 스토리(튜토리얼) 단계가 가리키는 위치
  Offset? get storyGuideTarget {
    if (sector == campaignFinalSector &&
        finalMissionStage != FinalMissionStage.complete) {
      if (development < 1) {
        final todo = planets.where(
          (p) => p.building(ColonyBuilding.stabilizer) < devLevelCap,
        );
        if (todo.isNotEmpty) return todo.first.pos;
      }
      if (finalMissionStage == FinalMissionStage.guardian) {
        final guardian = pirates.where((p) => p.finalGuardian).firstOrNull;
        if (guardian != null) return guardian.pos;
      }
      return homePos;
    }
    if (campaignMissionActive) return campaignTarget;
    switch (story.key) {
      case 'colonies':
        final p = planets.where((p) => p.colonyLevel == 0).toList();
        if (p.isEmpty) return null;
        p.sort(
          (a, b) => (a.pos - player.pos).distance.compareTo(
            (b.pos - player.pos).distance,
          ),
        );
        return p.first.pos;
      case 'shipLevels':
      case 'crew':
      case 'missions':
        if (nearbyStation != null) return null;
        return stations
            .reduce(
              (a, b) =>
                  (a.pos - player.pos).distance < (b.pos - player.pos).distance
                  ? a
                  : b,
            )
            .pos;
      case 'sector':
        final g = gates.where((g) => g.forward && gateOpen(g));
        return g.isEmpty ? null : g.first.pos;
      case 'devPercent':
        // 평균 목표보다 낮은 안정화 기기로 유도한다. 고레벨 집중 투자도 가능하다.
        if (development >= 1) return null;
        final todo = planets
            .where((p) => p.building(ColonyBuilding.stabilizer) < devLevelCap)
            .toList();
        if (todo.isEmpty) return null;
        todo.sort(
          (a, b) => (a.pos - player.pos).distance.compareTo(
            (b.pos - player.pos).distance,
          ),
        );
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

  // ---------- 행성 지표 탐험 (surface-exploration) ----------
  /// 해금: 식민지가 하나라도 있으면 (어느 항성계든) 또는 두 번째 항성계부터
  bool get landUnlocked =>
      sector > 0 ||
      planets.any((p) => p.colonyLevel > 0) ||
      sectors.values.any((s) => s.colonyLevels.any((l) => l > 0));

  /// 이 행성에 착륙할 수 있는지 (가스 행성은 안 된다)
  bool canLand(Planet p) => landUnlocked && p.kind != PlanetKind.gas;

  /// 해금 뒤 처음 착륙할 수 있는 행성 곁에 가면 미나가 한 번 알려 준다 (프로필 플래그 — 새 게임에서도 다시 안 한다)
  void _checkLandHint() {
    if (!player.alive || !landUnlocked) return;
    final p = nearbyPlanet;
    if (p == null || !canLand(p)) return;
    final rec = SurfaceRecords(profile.stats, onChanged: () => profile.dirty = true);
    if (rec.hinted) return;
    rec.markHinted();
    say(Speaker.advisor, tr.srf_dlgUnlock(p.name));
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

  /// 원형이 있는 항성계 두목은 더 적게 (초당 약 2.7%): 원형 패턴이 핵심 콘텐츠라 본거지 옆에서도 선장이 싸울 시간을 남긴다.
  /// 태양계 두목(원형 없음)은 튜토리얼이라 기존 비율 그대로
  static const havenSectorBossDamageRatio = 0.006;
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
      final guarded = stations.any(
        (s) => s.guardRange > 0 && (s.pos - b.pos).distance < s.guardRange,
      );
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
      if (e.cloaked) continue;
      final d = (e.pos - base).distance;
      if (d < bestD) {
        bestD = d;
        best = e;
      }
    }
    if (best == null) return;
    _havenLaserCooldown = hb.laserInterval;
    beams.add(LaserBeam(base, best.pos));
    // 두목급(미니 두목 포함)은 레이저 한 발 피해에 상한: 본거지 옆에서 레이저가 대신 잡지 않게
    final dmg = best.kind == PirateKind.boss || best.miniBoss
        ? min(
            hb.laserDamage,
            best.maxHp *
                ((best.sectorBoss && best.archetype != null) || best.miniBoss
                    ? havenSectorBossDamageRatio
                    : havenBossDamageRatio),
          )
        : hb.laserDamage;
    _hitPirate(best, dmg, best.pos, byBase: true);
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
      if (e.kind == EventKind.merchant && (e.pos - player.pos).distance < 200) {
        return e;
      }
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
    if (p.colonyLevel >= colonyLevelCap) return false;
    if (!_pay(planetCost(p))) return false;
    p.colonyLevel++;
    profile.codex.recordColony(sector, planets.indexOf(p), planets.length, p.kind, p.colonyLevel); // 도감
    profile.addStat('colonyUps');
    profile.weeklyScore.addColonyLevel();
    if (p.colonyLevel == 1) {
      _count('colonies');
      GameTelemetry.emit(TelemetryEvent.firstColony);
      profile.addStat('colonies');
      say(Speaker.captain, tr.g_dlgSettled(p.name));
      _raiseDome(p);
      if (counter('colonies') == 1) {
        _queueStoryScene(StoryScene.mars);
      }
      if (!profile.colonyTutorialSeen) colonyTutorialPending = true;
    } else {
      _float(
        p.pos + Offset(0, -p.radius - 30),
        'Lv.${p.colonyLevel}!',
        const Color(0xFF7CFFB2),
        big: true,
      );
    }
    if (p.colonyLevel == 5) profile.maxStat('maxColony', 1);
    _specHint(p);
    sfx.add(Sfx.upgrade);
    _burst(p.pos + Offset(0, -p.radius), const Color(0xFF7CFFB2), 30);
    return true;
  }

  // ---------- 식민지 특화 ----------
  /// 처음으로 식민지가 특화 레벨에 오르면 미나가 한 번 안내한다
  void _specHint(Planet p) {
    if (p.colonyLevel < ColonySpec.minLevel || counter('specHint') > 0) return;
    counters['specHint'] = 1;
    say(Speaker.advisor, tr.g_dlgSpecUnlocked(p.name));
  }

  /// 특화를 고를 수 있는지 (레벨만 본다. 비용은 [specCost])
  static bool canSpecialize(Planet p) => p.colonyLevel >= ColonySpec.minLevel;

  /// 특화 비용: 처음 고르기는 무료, 바꾸기는 그 식민지의 현재 레벨업 비용과 같다
  /// (상한에 막혀 레벨업할 수 없어도 같은 공식).
  Cost specCost(Planet p) => p.spec == null ? (0, 0) : planetCost(p);

  bool setColonySpec(Planet p, ColonySpec spec) {
    if (!canSpecialize(p) || p.spec == spec) return false;
    if (!_pay(specCost(p))) return false;
    p.spec = spec;
    // 요새를 그만두면 줄어든 최대치에 맞춘다 (요새가 되면 재충전으로 찬다)
    p.shieldHp = min(p.shieldHp, p.shieldMax(sectorMul));
    sfx.add(Sfx.upgrade);
    _burst(p.pos + Offset(0, -p.radius), const Color(0xFF7CFFB2), 30);
    return true;
  }

  // ---------- 내 식민지 (다른 항성계 원격 관리) ----------
  /// 떠나온 항성계 [sector]의 [index]번 행성을 저장 상태로 만든 사본.
  /// 비용·수입 계산용이며, 바꿔도 저장에는 반영되지 않는다 ([upgradeRemotePlanet] 사용).
  Planet remotePlanet(int sector, int index) {
    final save = sectors[sector]!;
    final count = save.colonyLevels.length;
    final id = planetIdentity(sector, index, count);
    final p = Planet(
      id.name,
      100,
      id.kind,
      orbitRadius: 0,
      orbitPhase: 0,
      nameOf: () => planetIdentity(sector, index, count).name,
    )..colonyLevel = save.colonyLevels[index];
    p.spec = save.specAt(index);
    p.discoveries = save.discAt(index);
    final lv = index < save.buildings.length ? save.buildings[index] : null;
    for (final b in ColonyBuilding.values) {
      p.buildings[b] = lv != null && b.index < lv.length
          ? lv[b.index]
          // 정박기 도입 전 저장: 불러올 때와 같은 보정
          : b == ColonyBuilding.stabilizer
          ? min(p.colonyLevel, devLevelCap)
          : 0;
    }
    return p;
  }

  /// 원격 행성 비용은 그 항성계에 가서 올릴 때와 같다
  Cost remotePlanetCost(int sector, Planet p) {
    final c = p.baseCost();
    final m = costMulAt(sector);
    return ((c.$1 * m).round(), (c.$2 * m).round());
  }

  Cost remoteBuildingCost(int sector, Planet p, ColonyBuilding b) {
    final c = p.buildingBaseCost(b);
    final m = costMulAt(sector);
    return ((c.$1 * m).round(), (c.$2 * m).round());
  }

  /// 원격 식민지 레벨업 ([building]이 null) 또는 건물 레벨업.
  /// 저장 상태와 그 항성계의 원격 수입을 바로 고친다.
  bool upgradeRemotePlanet(int sector, int index, {ColonyBuilding? building}) {
    final save = sectors[sector];
    if (save == null || index >= save.colonyLevels.length) return false;
    final p = remotePlanet(sector, index);
    if (p.colonyLevel == 0) return false;
    final mul = 1 + sector * sectorIncomeStep;
    final credits0 = p.baseCreditRate, ore0 = p.baseOreRate;
    var stabilizerHpBonus = 0.0;
    if (building == null) {
      if (p.colonyLevel >= colonyLevelCap) return false;
      if (!_pay(remotePlanetCost(sector, p))) return false;
      p.colonyLevel++;
      profile.codex.recordColony(sector, index, save.colonyLevels.length, p.kind, p.colonyLevel); // 도감
      profile.addStat('colonyUps');
      profile.weeklyScore.addColonyLevel();
      if (p.colonyLevel == 5) profile.maxStat('maxColony', 1);
      _specHint(p);
    } else {
      if (p.building(building) >= p.buildingCap) return false;
      if (!_pay(remoteBuildingCost(sector, p, building))) return false;
      p.buildings[building] = p.building(building) + 1;
      profile.addStat('colonyBuilds');
      if (building == ColonyBuilding.stabilizer &&
          index < save.defenses.length &&
          save.defenses[index].isNotEmpty) {
        stabilizerHpBonus = Planet.stabilizerHpPerLevel * mul;
      }
    }
    _storeRemote(
      sector,
      index,
      p,
      credits0: credits0,
      ore0: ore0,
      stabilizerHpBonus: stabilizerHpBonus,
    );
    sfx.add(Sfx.upgrade);
    return true;
  }

  /// 원격 특화 비용 ([specCost]와 같은 규칙, 그 항성계 배율)
  Cost remoteSpecCost(int sector, Planet p) =>
      p.spec == null ? (0, 0) : remotePlanetCost(sector, p);

  /// 떠나온 항성계 식민지의 특화를 고르거나 바꾼다. 원격 수입도 바로 고친다.
  bool setRemoteColonySpec(int sector, int index, ColonySpec spec) {
    final save = sectors[sector];
    if (save == null || index >= save.colonyLevels.length) return false;
    final p = remotePlanet(sector, index);
    if (!canSpecialize(p) || p.spec == spec) return false;
    if (!_pay(remoteSpecCost(sector, p))) return false;
    final credits0 = p.baseCreditRate, ore0 = p.baseOreRate;
    p.spec = spec;
    _storeRemote(sector, index, p, credits0: credits0, ore0: ore0);
    sfx.add(Sfx.upgrade);
    return true;
  }

  /// 원격 행성 사본 [p]를 저장 상태로 되돌린다. 수입은 바뀌기 전 값과의 차이만큼 고친다.
  void _storeRemote(
    int sector,
    int index,
    Planet p, {
    required double credits0,
    required double ore0,
    double stabilizerHpBonus = 0,
  }) {
    final save = sectors[sector]!;
    final mul = 1 + sector * sectorIncomeStep;
    // 저장 형식으로 되돌린다 (옛 저장은 건물 목록이 없거나 짧다)
    final row = [for (final b in ColonyBuilding.values) p.building(b)];
    final grown = [for (final b in save.buildings) List<int>.from(b)];
    for (var i = grown.length; i < save.colonyLevels.length; i++) {
      final q = remotePlanet(sector, i);
      grown.add([for (final b in ColonyBuilding.values) q.building(b)]);
    }
    grown[index] = row;
    final specs = [
      for (var i = 0; i < save.colonyLevels.length; i++)
        save.specAt(i)?.name ?? '',
    ]..[index] = p.spec?.name ?? '';
    sectors[sector] = SectorSave(
      colonyLevels: List<int>.from(save.colonyLevels)..[index] = p.colonyLevel,
      specs: specs,
      discoveries: save.discoveries,
      stations: save.stations,
      elapsed: save.elapsed,
      bossDefeated: save.bossDefeated,
      bossesSpawned: save.bossesSpawned,
      idleCredits: save.idleCredits + (p.baseCreditRate - credits0) * mul,
      idleOre: save.idleOre + (p.baseOreRate - ore0) * mul,
      buildings: grown,
      defenses: [
        for (var i = 0; i < save.defenses.length; i++)
          i == index && save.defenses[i].isNotEmpty
              ? [
                  save.defenses[i][0] + stabilizerHpBonus,
                  ...save.defenses[i].skip(1),
                ]
              : save.defenses[i],
      ],
    );
  }

  bool buildColony(Planet p, ColonyBuilding b) {
    if (p.colonyLevel == 0 || p.building(b) >= p.buildingCap) return false;
    if (!_pay(colonyBuildingCost(p, b))) return false;
    final oldRelayCapacity = relayShieldMax(p);
    p.buildings[b] = p.building(b) + 1;
    if (b == ColonyBuilding.stabilizer) {
      if (relayConnected(p) && p.relayShieldCooldown <= 0) {
        p.relayShieldHp = min(
          relayShieldMax(p),
          p.relayShieldHp + relayShieldMax(p) - oldRelayCapacity,
        );
      }
      _queueStoryScene(StoryScene.firstTransmission);
      _queueFirstWarpScene();
      p.stabilizerHp = min(
        p.stabilizerMaxHp(sectorMul),
        p.stabilizerHp + Planet.stabilizerHpPerLevel * sectorMul,
      );
    }
    profile.addStat('colonyBuilds');
    GameTelemetry.emit(TelemetryEvent.firstBuilding);
    sfx.add(Sfx.upgrade);
    _float(
      p.pos + Offset(0, -p.radius - 30),
      '${b.icon} Lv.${p.building(b)}',
      const Color(0xFF8AD8FF),
      big: true,
    );
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

  bool relayConnected(Planet p) =>
      p.colonyLevel > 0 &&
      p.building(ColonyBuilding.stabilizer) > 0 &&
      !homeBase.disabled;

  double relayShieldMax(Planet p) => p.colonyLevel == 0
      ? 0
      : relayShieldMaxAt(p, p.building(ColonyBuilding.stabilizer));

  /// 정박기 [level]에서의 공유 방어막 최대치 (레벨업 미리보기에도 쓴다)
  double relayShieldMaxAt(Planet p, int level) => level <= 0
      ? 0
      : (250 + 100 * homeBase.baseLevel + 150 * level) * sectorMul;

  bool relayShieldActive(Planet p) =>
      relayConnected(p) &&
      !p.domeUp &&
      p.relayShieldHp > 0 &&
      p.relayShieldCooldown <= 0;

  /// 식민지 포탑이 지금 쏠 표적 (사거리 안 가장 가까운 해적). 발사 판정과 화면의 포신 조준이 같이 쓴다.
  Pirate? colonyTurretTarget(Planet p) {
    if (p.colonyLevel == 0 || p.building(ColonyBuilding.turret) == 0) {
      return null;
    }
    Pirate? best;
    var bestD = p.turretRange;
    for (final e in pirates) {
      if (!e.isPirate || e.cloaked) continue;
      final d = (e.pos - p.pos).distance;
      if (d < bestD) {
        bestD = d;
        best = e;
      }
    }
    return best;
  }

  /// 식민지 포탑이 방금 쐈으면 0→1로 줄어드는 섬광 세기 (발사 때 냉각이 [Planet.turretInterval]로 다시 찬다)
  double colonyTurretFlash(Planet p) {
    if (p.building(ColonyBuilding.turret) == 0) return 0;
    const flashTime = 0.12;
    final since = p.turretInterval - p.turretCooldown;
    return since < 0 || since >= flashTime ? 0 : 1 - since / flashTime;
  }

  static const relayRegenPerLevel = .12;

  double relayRegenMultiplier(Planet p) => relayConnected(p)
      ? 1 +
            homeBase.baseLevel * .08 +
            p.building(ColonyBuilding.stabilizer) * relayRegenPerLevel
      : 1;

  void _hitRelayShield(Planet p, double damage) {
    p.sinceShieldHit = 0;
    p.relayShieldHp = max(0, p.relayShieldHp - damage);
    if (p.relayShieldHp == 0) p.relayShieldCooldown = 30;
    _spark(p.pos, const Color(0xFF64FFDA));
  }

  Planet? domeAt(Offset pos) {
    for (final p in planets) {
      if ((p.domeUp || relayShieldActive(p)) &&
          (pos - p.pos).distance < p.domeRadius) {
        return p;
      }
    }
    return null;
  }

  void _raiseDome(Planet p) {
    p
      ..shieldHp = p.shieldMax(sectorMul)
      ..shieldBroken = false
      ..sinceShieldHit = 99;
    bullets.removeWhere(
      (b) => !b.fromPlayer && (b.pos - p.pos).distance < p.domeRadius,
    );
    sfx.add(Sfx.shield);
  }

  void _hitDome(Planet p, double dmg) {
    if (!p.domeUp && relayShieldActive(p)) {
      _hitRelayShield(p, dmg);
      return;
    }
    p
      ..shieldHp = max(0, p.shieldHp - dmg)
      ..sinceShieldHit = 0;
    if (p.shieldHp == 0) {
      p.shieldBroken = true;
      _burst(p.pos + Offset(0, -p.domeRadius), const Color(0xFF80D8FF), 40);
      _float(
        p.pos + Offset(0, -p.radius - 60),
        '🛡 ${tr.g_floatShieldBroken}',
        const Color(0xFFFF5252),
        big: true,
      );
      sfx.add(Sfx.bigExplode);
      shake = min(16, shake + 8);
    }
  }

  void _hitStabilizer(Planet p, double damage) {
    if (p.domeUp || damage <= 0 || p.building(ColonyBuilding.stabilizer) == 0) {
      return;
    }
    if (relayShieldActive(p)) {
      _hitRelayShield(p, damage);
      return;
    }
    final before = p.building(ColonyBuilding.stabilizer);
    p.sinceShieldHit = 0;
    p.stabilizerHp = max(0, p.stabilizerHp - damage);
    final remaining =
        (p.stabilizerHp / (Planet.stabilizerHpPerLevel * sectorMul)).ceil();
    p.buildings[ColonyBuilding.stabilizer] = min(before, remaining);
    _spark(p.pos, const Color(0xFFFF8A80));
    if (remaining < before) {
      _burst(p.pos, const Color(0xFFFF7043), 24);
      sfx.add(Sfx.bigExplode);
      say(Speaker.advisor, tr.g_stabilizerDamaged(p.name, remaining));
      _float(
        p.pos + Offset(0, p.radius + 60),
        '${ColonyBuilding.stabilizer.icon} Lv.$remaining',
        const Color(0xFFFF5252),
        big: true,
      );
    }
  }

  // ---------- 공전 ----------
  /// 행성 곁(관리 범위 [nearbyPlanet])에 있는 함선은 그 행성과 함께 궤도를 돈다
  /// — 행성에 머무는 동안 행성이 빠져나가지 않게.
  void _updateOrbits() {
    final carrier = player.alive ? nearbyPlanet : null;
    for (final p in planets) {
      final before = p.pos;
      p.placeOnOrbit(sectorElapsed);
      if (p == carrier) {
        player.pos = _clampWorld(
          player.pos + (p.pos - before),
          (v) => player.vel = v,
        );
      }
      // 지나가는 행성이 소행성을 밀어낸다
      for (final a in asteroids) {
        final d = a.pos - p.pos;
        final minD = p.radius + a.radius + 10;
        if (d.distance < minD) {
          a.pos =
              p.pos +
              (d.distance == 0 ? const Offset(1, 0) : d.normalized()) * minD;
        }
      }
    }
    // 항성은 단단하다: 함선·해적을 밀어내고 탄환을 삼킨다
    Offset outOfStar(Offset pos, double r) {
      final minD = starRadius + r;
      return pos.distance < minD
          ? (pos.distance == 0 ? const Offset(1, 0) : pos.normalized()) * minD
          : pos;
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
      p.relayShieldCooldown = max(0, p.relayShieldCooldown - dt);
      p.relayShieldHp = p.relayShieldHp.clamp(0, relayShieldMax(p));
      if (relayConnected(p)) {
        if (p.sinceShieldHit >= 6 && p.relayShieldCooldown <= 0) {
          p.relayShieldHp = min(
            relayShieldMax(p),
            p.relayShieldHp +
                relayShieldMax(p) *
                    .06 *
                    relayRegenMultiplier(p) *
                    trait.shieldRegenMul *
                    dt,
          );
        }
        if (p.sinceShieldHit >= 8) {
          p.stabilizerHp = min(
            p.stabilizerMaxHp(sectorMul),
            p.stabilizerHp + p.stabilizerMaxHp(sectorMul) * .02 * dt,
          );
        }
      }
      final cap = p.shieldMax(sectorMul);
      if (p.shieldHp > cap) p.shieldHp = cap;
      final delay = p.shieldBroken && !relayConnected(p)
          ? shieldBrokenDelay
          : Planet.shieldRegenDelay;
      if (p.sinceShieldHit < delay || p.shieldHp >= cap) continue;
      final assisted = stations.any(
        (s) =>
            s.role == StationRole.repair &&
            (s.pos - p.pos).distance < Station.shieldAssistRange,
      );
      p.shieldHp = min(
        cap,
        p.shieldHp +
            p.shieldRegen(sectorMul) *
                trait.shieldRegenMul *
                relayRegenMultiplier(p) *
                (assisted ? 2 : 1) *
                dt,
      );
      if (p.shieldBroken && p.shieldHp >= cap * Planet.shieldRebootRatio) {
        p.shieldBroken = false;
        sfx.add(Sfx.shield);
        _float(
          p.pos + Offset(0, -p.radius - 60),
          '🛡 ${tr.g_floatShieldBack}',
          const Color(0xFF80D8FF),
          big: true,
        );
      }
    }
  }

  bool buildStation(StationRole role) {
    if (role == StationRole.home || !canBuildStationHere) return false;
    if (!_pay(stationBuildCost)) return false;
    final st = Station.named(
      StationName.numbered(role, stations.length + 1),
      player.pos + const Offset(0, -140),
      role: role,
    );
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
    if (level(k) >= upgradeCap(k)) return false;
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
        say(
          Speaker.captain,
          level(k) == 1 ? keyHint(tr.g_dlgMissileNew) : tr.g_dlgMissileUp,
        );
      case UpgradeKind.shield:
        say(
          Speaker.captain,
          level(k) == 1 ? keyHint(tr.g_dlgShieldNew) : tr.g_dlgShieldUp,
        );
      case UpgradeKind.drone:
        profile.maxStat('drone', 1);
        say(
          Speaker.captain,
          level(k) == 1 ? tr.g_dlgDroneNew : tr.g_dlgDroneUp,
        );
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

  /// 내 행성 비용 배율: 이번 게임에서 가장 멀리 간 항성계의 비용 배율.
  /// (지금 있는 항성계 기준이면 첫 항성계로 돌아가 싸게 짓는다)
  double get homeCostMul => costMulAt(max(sector, counter('maxSector')));

  bool buildHome(int slot, BuildingType t) {
    if (slot < 0 || slot >= home.slots.length || home.slots[slot] != null) {
      return false;
    }
    if (t.gemOnly) {
      if (!profile.spendGems(home.statueGemCost(0))) return false;
    } else if (!_pay(home.buildCost(t, homeCostMul))) {
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
    } else if (!_pay(home.upgradeCost(s, homeCostMul))) {
      return false;
    }
    s.level++;
    profile.dirty = true;
    sfx.add(Sfx.upgrade);
    return true;
  }

  bool levelUpHome() {
    if (home.level >= HomePlanet.maxLevel) return false;
    if (!_pay(home.levelUpCostAt(homeCostMul))) return false;
    home.levelUp();
    profile.maxStat('homeLevel', home.level);
    profile.dirty = true;
    sfx.add(Sfx.warp);
    return true;
  }

  /// 8시간마다 받는 행성 선물. 받은 (크레딧, 젬) 반환
  (int, int)? harvestHome(DateTime now) {
    if (!home.harvestReady(now)) return null;
    final r = home.harvestReward(baseRewardMul);
    home.lastHarvestMs = now.millisecondsSinceEpoch;
    credits += r.$1;
    profile.earnGems('play', '', r.$2);
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

  /// 크레딧 팩: 기초 보상 배율([baseRewardMul])을 따라간다 = 직접 플레이로 버는 돈과 같은 속도로 커진다.
  /// 비용 배율을 따르면 뒤 항성계에서 무료 젬 환전이 진행의 70%를 넘고,
  /// 생산 배율만 따르면 뒤로 갈수록 쓸모가 없어진다.
  /// 1.0.8: 12000 → 13500. 첫 5분 보상(★3 승무원·미니 두목 무기+1)과 도감·원정으로 무료 진행이 빨라져
  /// (S3~S6 8.18일 → 7.22일) 팩 이점이 22% → 17%로 줄었다. 13500에서 무료 7.04일·팩 5.45일(22.6%)로 원래 차이 회복.
  static const creditPackBase = 13500;

  /// 첫 항성계는 발전 비용 자체가 작아서(4만대) 팩 하나가 20%나 된다 → 이 비율만.
  /// 튜토리얼 젬으로 첫 항성계를 건너뛰지 않게.
  static const firstSystemPackRatio = 0.25;
  int get creditPackAmount =>
      (creditPackBase *
              baseRewardMul *
              (sector == 0 ? firstSystemPackRatio : 1))
          .round();

  bool buyCreditsWithGems() {
    if (!profile.spendGems(creditPackGems)) return false;
    credits += creditPackAmount;
    sfx.add(Sfx.coin);
    return true;
  }

  // ---------- 부족한 크레딧을 젬으로 채우기 ----------
  /// 크레딧 [shortfall]을 채우는 데 드는 젬 (크레딧 꾸러미와 같은 환율, 1젬 단위 올림)
  int gemsForCredits(num shortfall) {
    if (shortfall <= 0) return 0;
    return max(1, (shortfall * creditPackGems / creditPackAmount).ceil());
  }

  /// 젬으로 사는 광석의 할증: 시장 최고 시세(기본가 1.35배)보다 비싸서
  /// 젬 → 광석 → 시장 판매로 크레딧을 불릴 수 없다
  static const oreGemMarkup = 2.0;

  /// 광석 [shortfall]을 채우는 데 드는 젬 (기본 시세 × [oreGemMarkup] 를 크레딧 환율로, 1젬 단위 올림)
  int gemsForOre(num shortfall) {
    if (shortfall <= 0) return 0;
    return max(
      1,
      (shortfall *
              oreBasePrice *
              oreGemMarkup *
              creditPackGems /
              creditPackAmount)
          .ceil(),
    );
  }

  /// [cost]에서 모자란 크레딧·광석을 채우는 데 필요한 젬. 이미 살 수 있으면 0.
  int? topUpGemsFor(Cost cost) {
    if (canAfford(cost)) return 0;
    return gemsForCredits(cost.$1 - credits) + gemsForOre(cost.$2 - ore);
  }

  /// 모자란 크레딧·광석을 젬으로 채운다 (크레딧은 딱 필요한 만큼 이상, 광석은 모자란 만큼)
  bool topUpCost(Cost cost) {
    if (canAfford(cost)) return true;
    final oreShort = max(0.0, cost.$2 - ore).ceil();
    final creditGems = gemsForCredits(cost.$1 - credits);
    final oreGems = gemsForOre(oreShort);
    if (!profile.spendGems(creditGems + oreGems)) return false;
    credits += creditGems * creditPackAmount / creditPackGems;
    ore += oreShort;
    sfx.add(Sfx.coin);
    return true;
  }

  // ---------- 승무원 ----------
  CrewMember? recruitWithCredits() {
    if (roster.length >= rosterCap) return null;
    if (!_pay((recruitCost, 0))) return null;
    // 크레딧 모집 가격은 크레딧 모집 횟수로만 오른다 (젬·결제 상품 승무원은 세지 않는다)
    recruitCount++;
    return _addCrew(
      CrewMember.random(_rng, _nextId++, odds: CrewMember.creditOdds),
    );
  }

  CrewMember? recruitWithGems() {
    if (roster.length >= rosterCap) return null;
    if (!profile.spendGems(recruitGemCost)) return null;
    return _addCrew(
      CrewMember.random(_rng, _nextId++, odds: CrewMember.gemOdds),
    );
  }

  /// ★4 전설 확정 모집 (젬)
  CrewMember? recruitLegendary() {
    if (roster.length >= rosterCap) return null;
    if (!profile.spendGems(legendaryGemCost)) return null;
    return grantCrew(4);
  }

  CrewMember _addCrew(CrewMember c) {
    if (assignedCount < crewSlots) c.assigned = true;
    roster.add(c);
    profile.codex.recordCrew(c.role, c.rarity); // 도감
    profile.addStat('crew');
    GameTelemetry.emit(TelemetryEvent.firstCrew);
    if (c.rarity >= 3) profile.addStat('crew3');
    sfx.add(Sfx.gem);
    say(
      Speaker.advisor,
      tr.g_dlgCrewJoined(c.stars, c.role.label, iGa(c.displayName)),
    );
    if (c.role == CrewRole.engineer) player.hp = min(player.hp, playerMaxHp);
    return c;
  }

  /// 결제 상품 등으로 지급되는 승무원
  CrewMember grantCrew(int rarity) =>
      _addCrew(CrewMember.random(_rng, _nextId++, odds: {rarity: 100}));

  bool toggleAssign(CrewMember c) {
    if (crewAway(c)) return false; // 원정 중에는 배치할 수 없다
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

  /// 원정 중인 승무원은 해고할 수 없다
  void dismissCrew(CrewMember c) {
    if (crewAway(c)) return;
    roster.remove(c);
  }

  // ---------- 승무원 원정 ----------
  int get expeditionSlots => Expeditions.slots(premium: profile.premium);

  bool crewAway(CrewMember c) => expeditions.any((e) => e.crewId == c.id);

  /// 원정 보낼 수 있는 승무원: 배치되지 않았고 원정 중이 아닌
  Iterable<CrewMember> get idleCrew =>
      roster.where((c) => !c.assigned && !crewAway(c));

  /// [c]를 [hours]시간 원정에 보낸다. 슬롯이 없거나 배치·원정 중이면 null
  Expedition? startExpedition(CrewMember c, int hours, DateTime now) {
    if (!Expeditions.durations.contains(hours)) return null;
    if (expeditions.length >= expeditionSlots) return null;
    if (c.assigned || crewAway(c) || !roster.contains(c)) return null;
    final e = Expeditions.plan(
      crewId: c.id,
      rarity: c.rarity,
      hours: hours,
      startMs: expeditionClock.now(now),
      creditIncome: creditIncome,
      oreIncome: oreIncome,
      sectorMul: sectorMul,
      rng: _rng,
    );
    expeditions.add(e);
    GameTelemetry.emit(TelemetryEvent.expeditionStart, hours);
    return e;
  }

  /// 돌아온 원정 보상을 받는다. 아직이면 null
  ExpeditionReward? claimExpedition(Expedition e, DateTime now) {
    if (!expeditions.contains(e) || !e.isDone(expeditionClock.now(now))) {
      return null;
    }
    expeditions.remove(e);
    credits += e.credits;
    ore += e.ore;
    final c = roster.where((m) => m.id == e.crewId).firstOrNull;
    final ups = c?.gainXp(e.xp) ?? 0;
    if (e.gems > 0) profile.earnGems('play', '', e.gems);
    var rare = false;
    if (e.rareCrew && roster.length < rosterCap) {
      crewReveal = grantCrew(3);
      rare = true;
    }
    sfx.add(Sfx.coin);
    GameTelemetry.emit(TelemetryEvent.expeditionClaim, e.hours);
    return ExpeditionReward(
      credits: e.credits,
      ore: e.ore,
      xp: e.xp,
      gems: e.gems,
      levelUps: ups,
      rareCrew: rare,
    );
  }

  /// 출석 달력의 월드 보상(광석·크레딧·★2 승무원)을 넣는다 (프로필에 쌓인 것, 보상 배율 적용)
  void deliverCalendarRewards() {
    final p = profile;
    if (p.pendingOre > 0) {
      ore += p.pendingOre * baseRewardMul;
      p.pendingOre = 0;
      p.dirty = true;
    }
    if (p.pendingCredits > 0) {
      credits += p.pendingCredits * baseRewardMul;
      p.pendingCredits = 0;
      p.dirty = true;
    }
    while (p.pendingCrew2 > 0 && roster.length < rosterCap) {
      p.pendingCrew2--;
      crewReveal = grantCrew(2);
      p.dirty = true;
    }
  }

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
          id: _nextId++,
          type: MissionType.kill,
          target: n,
          rewardCredits: (35 * n * rewardMul).round(),
          rewardGems: gemBonus,
        );
      case 1:
        final n = 40 + _rng.nextInt(9) * 10;
        return Mission(
          id: _nextId++,
          type: MissionType.mine,
          target: n,
          rewardCredits: (3 * n * rewardMul).round(),
          rewardGems: gemBonus,
        );
      case 2:
        final idx = _rng.nextInt(planets.length);
        final d = (planets[idx].pos - player.pos).distance;
        return Mission(
          id: _nextId++,
          type: MissionType.deliver,
          target: 1,
          planetIndex: idx,
          rewardCredits: ((150 + d / 8) * rewardMul).round(),
          rewardGems: gemBonus,
        );
      default:
        return Mission(
          id: _nextId++,
          type: MissionType.bounty,
          target: 1,
          bountyId:
              ([for (var i = 0; i < bountyCount; i++) i]
                      .where((i) => !activeMissions.any((m) => m.bountyId == i))
                      .toList()
                    ..shuffle(_rng))
                  .first,
          rewardCredits: (450 * rewardMul).round(),
          rewardGems: 5,
        );
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
    final pos = _clampWorld(
      player.pos + OffsetX.fromAngle(a, randRange(_rng, 1500, 2400)),
      (_) {},
    );
    final e =
        Pirate(
            PirateKind.raider,
            pos,
            Pirate.baseHp(PirateKind.raider) * 5 * enemyHpMul,
            bountyId: m.bountyId,
            dmgScale: 1.5 * enemyDamageMul,
          )
          ..missionId = m.id
          ..wanderAngle = a;
    pirates.add(e);
    m.bountySpawned = true;
    say(Speaker.pirate, tr.g_dlgBountyTaunt(eul(m.bountyName!)));
  }

  void _completeMission(Mission m) {
    activeMissions.remove(m);
    final c =
        (m.rewardCredits * (1 + crewBonus(CrewRole.trader)) * shipCreditMul)
            .round();
    credits += c;
    profile.earnGems('play', '', m.rewardGems);
    _count('missions');
    profile.addStat('missions');
    sfx.add(Sfx.coin);
    _float(
      player.pos + const Offset(0, -40),
      '${tr.g_floatMissionDone} +💰$c',
      const Color(0xFFFFD54F),
      big: true,
    );
    say(
      Speaker.advisor,
      '${tr.g_dlgMissionDone(m.title(planets))} 💰$c${m.rewardGems > 0 ? ' ⭐${m.rewardGems}' : ''}',
    );
  }

  // ---------- 스토리 ----------
  static const _storyLineSeconds = 8.0;

  // 기존 월드 counters에 1=대기, 2=읽음/건너뜀으로 저장한다.
  // 옛 저장에 키가 없으면 오프닝은 소급해서 띄우지 않는다.
  StoryScene? get pendingStoryScene =>
      const [
            StoryScene.opening,
            StoryScene.mars,
            StoryScene.firstTransmission,
            StoryScene.firstWarp,
          ]
          .where((scene) => counter('storyScene_${scene.name}') == 1)
          .firstOrNull ??
      (pendingCampaignSector != null ? StoryScene.campaign : null) ??
      (counter('storyScene_counterattack') == 1
          ? StoryScene.counterattack
          : null) ??
      (counter('storyScene_ending') == 1 ? StoryScene.ending : null);

  int? get pendingCampaignSector => campaignSectors
      .where((s) => counter('campaignSector_$s') == 1)
      .firstOrNull;

  void _queueCampaignSector(int chapter) {
    final key = 'campaignSector_$chapter';
    if (counter(key) == 0) counters[key] = 1;
  }

  // Chapter results are earned through play, never by arrival or dismissing text.
  bool get campaignMissionActive =>
      campaignSectors.contains(sector) &&
      sector != campaignFinalSector &&
      counter('campaignDone_$sector') == 0;
  int get campaignStep => counter('campaignStep_$sector');
  int get campaignKills => counter('campaignKills_$sector');
  int get campaignKillTarget => sector == 5 ? 4 : (sector == 16 ? 1 : 0);
  Planet? get campaignAnchor {
    final saved = counters['campaignAnchor_$sector'];
    if (saved != null && saved >= 0 && saved < planets.length) {
      return planets[saved];
    }
    return planets
        .where((p) => p.building(ColonyBuilding.stabilizer) > 0)
        .firstOrNull;
  }

  bool get campaignNeedsAnchor =>
      const [1, 5, 8].contains(sector) &&
      (campaignAnchor == null ||
          campaignAnchor!.building(ColonyBuilding.stabilizer) == 0);
  bool get campaignCombat =>
      campaignMissionActive &&
      campaignKillTarget > 0 &&
      campaignKills < campaignKillTarget;
  Offset? get campaignTarget {
    if (!campaignMissionActive) return null;
    if (campaignNeedsAnchor) return (campaignAnchor ?? planets.first).pos;
    if (campaignCombat) {
      final enemy = pirates
          .where((p) => p.campaignChapter == sector)
          .firstOrNull;
      return enemy?.pos ??
          (sector == 5 ? campaignAnchor!.pos : const Offset(1100, 1700));
    }
    return switch (sector) {
      1 || 5 => campaignAnchor!.pos,
      8 => campaignStep == 0 ? campaignAnchor!.pos : homePos,
      12 || 25 => homePos,
      16 => Offset(
        counter('campaignWreckX').toDouble(),
        counter('campaignWreckY').toDouble(),
      ),
      20 => const Offset(-1800, 1400),
      22 => campaignStep == 0 ? const Offset(1700, -1500) : homePos,
      _ => homePos,
    };
  }

  String get campaignObjective {
    if (campaignNeedsAnchor) return tr.c_task('anchor');
    if (sector == 25 && development < 1) return tr.c_stabilize;
    if (campaignCombat) {
      return '${tr.c_task('s$sector')} · $campaignKills/$campaignKillTarget';
    }
    return tr.c_task('s${sector}_$campaignStep');
  }

  bool get campaignWorking => counter('campaignWork_$sector') == 1;
  double get campaignWorkProgress =>
      (counter('campaignMs_$sector') / 6000).clamp(0, 1);
  bool get canWorkCampaign =>
      campaignMissionActive &&
      player.alive &&
      !campaignNeedsAnchor &&
      !campaignCombat &&
      (sector != 25 || development >= 1) &&
      (player.pos - campaignTarget!).distance <=
          ((const [1, 5].contains(sector) || (sector == 8 && campaignStep == 0))
              ? campaignAnchor!.radius + 170
              : 240);

  bool startCampaignWork() {
    if (!canWorkCampaign || campaignWorking) return false;
    counters['campaignWork_$sector'] = 1;
    player.vel = Offset.zero;
    profile
      ..cruise = false
      ..dirty = true;
    return true;
  }

  void _updateCampaignMission(double dt) {
    if (!campaignMissionActive || !player.alive) return;
    if (campaignAnchor != null) {
      counters.putIfAbsent(
        'campaignAnchor_$sector',
        () => planets.indexOf(campaignAnchor!),
      );
    }
    if (campaignCombat && !campaignNeedsAnchor) {
      final remaining = campaignKillTarget - campaignKills;
      final present = pirates.where((p) => p.campaignChapter == sector).length;
      for (var i = present; i < min(2, remaining); i++) {
        final center = sector == 5
            ? campaignAnchor!.pos
            : const Offset(1100, 1700);
        final enemy = _makePirate(
          sector == 16 ? PirateKind.boss : PirateKind.raider,
          _clampWorld(center + OffsetX.fromAngle(i * pi / 2, 550), (_) {}),
        );
        enemy.campaignChapter = sector;
        pirates.add(enemy);
      }
    }
    if (!campaignWorking || !canWorkCampaign) return;
    counters['campaignMs_$sector'] =
        counter('campaignMs_$sector') + (dt * 1000).round();
    if (counter('campaignMs_$sector') < 6000) return;
    counters['campaignMs_$sector'] = 0;
    counters['campaignWork_$sector'] = 0;
    if ((sector == 8 || sector == 22) && campaignStep == 0) {
      counters['campaignStep_$sector'] = 1;
    } else {
      counters['campaignDone_$sector'] = 1;
      _queueCampaignSector(sector);
    }
  }

  FinalMissionStage get finalMissionStage {
    final index = counter('finalMissionStage');
    if (index > 0 && index < FinalMissionStage.values.length) {
      return FinalMissionStage.values[index];
    }
    return sector >= campaignFinalSector ||
            counter('maxSector') >= campaignFinalSector
        ? FinalMissionStage.stabilize
        : FinalMissionStage.dormant;
  }

  double get finalSyncProgress => (_finalSyncSeconds / 20).clamp(0.0, 1.0);
  bool get _nearFinalRelay =>
      sector == campaignFinalSector &&
      player.alive &&
      (player.pos - homePos).distance <= 260;
  bool get finalPhaseLinked =>
      sector == campaignFinalSector &&
      development >= 1 &&
      (finalMissionStage == FinalMissionStage.guardian ||
          finalMissionStage == FinalMissionStage.counterattack);
  bool get finalSyncProtected =>
      finalMissionStage == FinalMissionStage.synchronize &&
      _nearFinalRelay &&
      development >= 1;
  bool get atFinalRelay => _nearFinalRelay;
  bool get canStartFinalSync =>
      finalMissionStage == FinalMissionStage.stabilize &&
      _nearFinalRelay &&
      development >= 1;
  bool get canCounterattack =>
      finalMissionStage == FinalMissionStage.counterattack &&
      _nearFinalRelay &&
      development >= 1;

  bool startFinalSync() {
    if (!canStartFinalSync) return false;
    counters['finalMissionStage'] = FinalMissionStage.synchronize.index;
    player.vel = Offset.zero;
    profile
      ..cruise = false
      ..dirty = true;
    return true;
  }

  bool launchCounterattack() {
    if (!canCounterattack) return false;
    counters['finalMissionStage'] = FinalMissionStage.complete.index;
    finalCounterattackSeconds = 3;
    player.vel = Offset.zero;
    sfx.add(Sfx.warp);
    return true;
  }

  void _updateFinalMission(double dt) {
    if (finalMissionStage == FinalMissionStage.synchronize &&
        _nearFinalRelay &&
        development >= 1) {
      _finalSyncSeconds = min(20, _finalSyncSeconds + dt);
      if (_finalSyncSeconds >= 20) {
        counters['finalMissionStage'] = FinalMissionStage.guardian.index;
      }
    }
    if (sector == campaignFinalSector &&
        player.alive &&
        finalMissionStage == FinalMissionStage.guardian &&
        !pirates.any((p) => p.finalGuardian)) {
      pirates.add(
        _makePirate(PirateKind.boss, _spawnPos(), hpMul: 2)
          ..finalGuardian = true,
      );
    }
  }

  void _queueStoryScene(StoryScene scene) {
    final key = 'storyScene_${scene.name}';
    if (counter(key) == 0) counters[key] = 1;
  }

  void _queueFirstWarpScene() {
    if (sector == 0 && counter('maxSector') == 0 && development >= 1) {
      _queueStoryScene(StoryScene.firstWarp);
    }
  }

  void finishStoryScene() {
    final scene = pendingStoryScene;
    if (scene == StoryScene.campaign) {
      final chapter = pendingCampaignSector;
      if (chapter != null) counters['campaignSector_$chapter'] = 2;
    } else if (scene != null) {
      counters['storyScene_${scene.name}'] = 2;
    }
  }

  StoryStep get story => storyStepAt(storyIndex);

  int storyValue(String key) => switch (key) {
    // 발전 목표는 그 단계가 가리키는 항성계에서만 센다 (이미 발전한 옛 항성계로 돌아가 깨는 것 방지)
    'devPercent' =>
      sector == storySectorAt(storyIndex) ? (development * 100).floor() : 0,
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
    // HUD는 마지막 대사를 표시하므로 역순으로 쌓고 만료 시각을 나눈다.
    // 모든 줄을 같은 수명으로 넣으면 마지막 줄 외에는 한 번도 보이지 않는다.
    for (var i = s.lines.length - 1; i >= 0; i--) {
      final (sp, line) = s.lines[i];
      say(sp, line);
      final dialog = dialogs.where((d) => d.text == line).firstOrNull;
      if (dialog != null) dialog.time = (i + 1) * _storyLineSeconds;
    }
  }

  void _checkStory() {
    final (v, t) = storyProgress;
    if (v < t) return;
    final s = story;
    credits += s.credits;
    profile.earnGems('play', '', s.gems);
    sfx.add(Sfx.upgrade);
    _float(
      player.pos + const Offset(0, -50),
      '${tr.g_floatGoalDone} +💰${s.credits} ⭐${s.gems}',
      const Color(0xFF7CFFB2),
      big: true,
    );
    storyIndex++;
    GameTelemetry.emit(TelemetryEvent.tutorialStep, storyIndex);
    if (storyIndex == storySteps.length) profile.tutorialDone = true;
    if (storyIndex == storySteps.length) GameTelemetry.emit(TelemetryEvent.tutorialDone);
    // 첫 튜토리얼(소행성·해적)을 마치면 순항을 켜고 버튼을 알려 준다. 처음부터 켜 두면 조작을 익히기 전에 흘러가 버린다
    if (storyIndex == cruiseTipStep && !profile.cruiseTipShown) {
      profile
        ..cruiseTipShown = true
        ..cruise = true
        ..dirty = true;
      say(Speaker.advisor, tr.g_dlgCruiseOn);
      // 다음 단계의 모든 대사 뒤에도 순항 안내를 읽을 시간이 남아야 한다.
      if (dialogs.isNotEmpty && dialogs.last.text == tr.g_dlgCruiseOn) {
        dialogs.last.time = (story.lines.length + 1) * _storyLineSeconds;
      }
    }
    _startStoryStep();
  }

  // ---------- 첫 5분: ★3 승무원 · 미니 두목 · 다음 목표 ----------
  /// ★3 확정 지급 때가 됐는데 아직 안 줬다 (다음 0.5초 판정에서 준다 — 화면은 이걸 보고 다른 창을 미룬다)
  bool get star3GiftDue =>
      counter(star3GiftKey) == 0 &&
      !profile.tutorialDone &&
      sector == 0 &&
      (storyIndex >= 2 || totalTime >= star3GiftSeconds);

  void _checkFirstMinutes() {
    if (!player.alive) return;
    // ★3 승무원: 해적 단계를 마치거나 3분이 지나면 한 번 (튜토리얼 중인 새 월드만)
    if (star3GiftDue && roster.length < rosterCap) {
      counters[star3GiftKey] = 1;
      final c = grantCrew(3);
      if (assignedCount < crewSlots) c.assigned = true;
      say(Speaker.advisor, tr.r3_star3Line(c.displayName));
      crewReveal = c;
    }
    // 미니 두목: 첫 정착 직후 또는 4분, 첫 항성계에서 한 번
    final bossState = counter(miniBossKey);
    if (bossState == 1 && !pirates.any((e) => e.miniBoss)) {
      counters[miniBossKey] = 0; // 저장·불러오기로 사라졌으면 다시 나온다
    }
    if (counter(miniBossKey) == 0 &&
        sector == 0 &&
        counter('maxSector') == 0 &&
        !invasionActive &&
        (counter('colonies') >= 1 || totalTime >= miniBossSeconds)) {
      counters[miniBossKey] = 1;
      // 본거지 레이저 사거리 밖에서 나온다 (레이저가 대신 잡으면 싸움이 없다)
      final home = homeBase;
      final away = player.pos - home.pos;
      final dir = away.distance < 1
          ? OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, 1)
          : away / away.distance;
      var pos = player.pos + dir * 650;
      final minFromHome = home.safeRadius + 600;
      if ((pos - home.pos).distance < minFromHome) {
        pos = home.pos + dir * minFromHome;
      }
      pos = _clampWorld(pos, (_) {});
      pirates.add(
        _makePirate(PirateKind.raider, pos, hpMul: miniBossHpMul, dmgMul: 0.8)
          ..miniBoss = true,
      );
      sfx.add(Sfx.alarm);
      say(Speaker.pirate, tr.r3_miniBossArrive);
      say(Speaker.advisor, tr.r3_miniBossHint);
    }
  }

  /// 미니 두목 체력 배수 (습격선 기준). 시작 함선이 20~30초에 잡는다 — tool/fight_sim_test.dart
  static const miniBossHpMul = 10.0;

  /// 미니 두목 처치 보상 크레딧 (현상금과 별도)
  static const miniBossCredits = 300;

  void _miniBossDown(Pirate e) {
    counters[miniBossKey] = 2;
    _count('miniBossKills');
    GameTelemetry.emit(TelemetryEvent.miniBossKill);
    credits += miniBossCredits;
    _dropPickups(e.pos, PickupKind.ore, 60, 4);
    // 함선 무기 +1 무료 (상한이면 크레딧으로)
    final k = UpgradeKind.weapon;
    if (level(k) < upgradeCap(k)) {
      levels[k] = level(k) + 1;
      _float(
        player.pos + const Offset(0, -70),
        tr.r3_weaponUp(level(k)),
        const Color(0xFFFFD54F),
        big: true,
      );
    } else {
      credits += upgradeCost(k).$1;
    }
    _float(
      e.pos + const Offset(0, -40),
      '+💰$miniBossCredits',
      const Color(0xFF7CFFB2),
      big: true,
    );
    sfx.add(Sfx.upgrade);
    shake = min(20, shake + 10);
    say(Speaker.pirate, tr.r3_miniBossLose);
    say(Speaker.advisor, tr.r3_miniBossDown);
  }

  /// 다음 목표를 다시 고른다. 목표가 바뀌는 순간 이전 목표를 이뤘으면 완료 연출과 통계
  void _updateGoal() {
    final next = nextGoal(this);
    final prev = _goal;
    if (prev != null && prev.signature != next.signature && prev.isDone(this)) {
      goalDone = prev;
      goalFlash = goalFlashSeconds;
      GameTelemetry.emit(TelemetryEvent.goalDone, prev.kind.index);
      // 스토리 단계는 [_checkStory]가 보상과 함께 이미 띄운다
      if (prev.kind != GoalKind.story) {
        _float(
          player.pos + const Offset(0, -50),
          '✔ ${tr.g_floatGoalDone}',
          const Color(0xFF7CFFB2),
          big: true,
        );
      }
    }
    _goal = next;
  }

  static const goalFlashSeconds = 1.6;

  /// 목표 칩을 눌렀다: 안내 화살표를 잠깐 그 목표 쪽으로
  void pingGoal() {
    _goal = nextGoal(this);
    goalPing = 6;
  }

  // ---------- 스킬 ----------
  bool fireMissiles() {
    final lv = level(UpgradeKind.missile);
    if (lv == 0 || player.missileCooldown > 0 || !player.alive) return false;
    player.missileCooldown = missileCooldownMax;
    final n = 2 + lv ~/ 2;
    final dmg = 22 * (1 + 0.3 * (lv - 1)) * (1 + crewBonus(CrewRole.gunner));
    final targets = [...pirates]
      ..sort(
        (a, b) => (a.pos - player.pos).distance.compareTo(
          (b.pos - player.pos).distance,
        ),
      );
    for (var i = 0; i < n; i++) {
      final a = player.angle + (i - (n - 1) / 2) * 0.5;
      final m = Missile(
        player.pos,
        OffsetX.fromAngle(a, 300) + player.vel * 0.5,
        dmg,
      );
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
      particles.add(
        Particle(
          player.pos,
          -OffsetX.fromAngle(player.angle + randRange(_rng, -0.6, 0.6), 200),
          0.4,
          const Color(0xFF80D8FF),
          3,
        ),
      );
    }
    return true;
  }

  // ---------- 부활 ----------
  /// 재출격 비용 비율: 수리 기지에서 나오면 싸다
  static double respawnCostRatio(Station s) =>
      s.role == StationRole.repair ? 0.10 : 0.25;

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
    enemyMissiles.clear();
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
      (a, b) =>
          (a.pos - player.pos).distance < (b.pos - player.pos).distance ? a : b,
    );
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

  /// 오프라인 수입 상한: 기본 2시간, 사령관 패스 8시간
  static const offlineCapHours = 2;
  static const premiumOfflineCapHours = 8;

  /// 처음 [offlineCapHours]시간은 그대로 쌓이고, 그 뒤(패스의 나머지 6시간)는 이 비율로 쌓인다.
  /// 그대로 쌓이면 패스가 오프라인 수입만 4배라 진행이 3배 넘게 빨라진다.
  static const offlineLateRatio = 0.25;

  /// 오프라인 시간(초)과 그동안의 수입
  (int seconds, double credits, double ore) offlineEarnings(DateTime now) {
    if (savedAt == null) return (0, 0, 0);
    final cap =
        (profile.premium ? premiumOfflineCapHours : offlineCapHours) * 3600;
    final sec = now.difference(savedAt!).inSeconds.clamp(0, cap);
    if (sec < 60) return (0, 0, 0);
    const full = offlineCapHours * 3600;
    final paid = min(sec, full) + max(0, sec - full) * offlineLateRatio;
    final eff = profile.home.offlineEfficiency;
    return (sec, creditIncome * paid * eff, oreIncome * paid * eff);
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
    if (finalCounterattackSeconds > 0) {
      finalCounterattackSeconds = max(0, finalCounterattackSeconds - dt);
      totalTime += dt;
      if (finalCounterattackSeconds == 0) {
        _queueStoryScene(StoryScene.counterattack);
        _queueStoryScene(StoryScene.ending);
      }
      return;
    }
    if (finalMissionStage != FinalMissionStage.complete) {
      antimatterExposure += dt;
    }
    _updateCampaignMission(dt);
    _updateFinalMission(dt);
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
    goalFlash = max(0, goalFlash - dt);
    goalPing = max(0, goalPing - dt);
    _updateShields(dt);
    _updateOrbits();

    _updatePlayer(dt, input);
    _updateDrone(dt);
    _updatePirates(dt);
    _updateStations(dt);
    _updateHaven(dt);
    _updateColonies(dt);
    _updateMissiles(dt);
    _updateHostileOrdnance(dt);
    _updateBullets(dt);
    _updateAsteroids(dt);
    _updatePickups(dt);
    _updateParticles(dt);
    _updateEvents(dt);
    _updateInvasion(dt);
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
      if (!_devAnnounced && development >= 1 && !campaignMissionActive) {
        _devAnnounced = true;
        sfx.add(Sfx.warp);
        say(Speaker.advisor, tr.g_dlgSectorDeveloped(sectorName));
        _queueFirstWarpScene();
      }
      _checkStory();
      _checkFirstMinutes();
      _checkLandHint();
      _updateGoal();
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
    if (ship.regenRate > 0 &&
        p.sinceHit >= ShipType.regenDelay &&
        p.hp < playerMaxHp) {
      p.hp = min(playerMaxHp, p.hp + playerMaxHp * ship.regenRate * dt);
    }
    var move = input.move.clampLength(1);
    if (input.cruise && move.distance <= 0.1) {
      move = OffsetX.fromAngle(p.angle, 1);
    }
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
      particles.add(
        Particle(
          p.pos - OffsetX.fromAngle(p.angle, 20),
          -OffsetX.fromAngle(p.angle + randRange(_rng, -0.3, 0.3), 120) +
              p.vel * 0.3,
          0.35,
          const Color(0xFFFFB347),
          randRange(_rng, 2, 4),
        ),
      );
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
        if (s.repairRate > rate && (s.pos - p.pos).distance < s.repairRange) {
          rate = s.repairRate;
        }
      }
      if (rate > 0) {
        p.hp = min(
          playerMaxHp,
          p.hp + rate * (1 + crewBonus(CrewRole.engineer)) * dt,
        );
      }
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
        bullets.add(
          Bullet(
            p.pos + dir * 22,
            dir * 760 + p.vel * 0.5,
            playerDamage * (crit ? 2.5 : 1),
            true,
            big: crit,
            pierce: ship.pierce,
          ),
        );
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
      if (e.cloaked) continue;
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

  /// 첫 항성계 초반 난이도 배율: 적 공격력과 적이 떨어뜨리는 크레딧에 같이 곱한다
  double get _newbieMul =>
      sector == 0 && (threat < 2 || _tutorialCalm) ? 0.6 : 1.0;

  void _updateDrone(double dt) {
    if (droneLevel == 0 || !player.alive) return;
    droneAngle += dt * 2.2;
    _droneCooldown -= dt;
    if (_droneCooldown > 0) return;
    final from = dronePos;
    Pirate? best;
    var bestD = 450.0;
    for (final e in pirates) {
      if (e.cloaked) continue;
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

  /// 선체가 실제로 피해를 입었으면 true (방어막·수호막·보호 구역에서 막히면 false)
  bool _damagePlayer(double dmg) {
    final p = player;
    if (!p.alive || p.invulnerable > 0) return false;
    if (inHaven(p.pos) || finalSyncProtected) return false; // 중계망 동기화 보호
    if (finalPhaseLinked) dmg *= 0.35;
    if (shielded) {
      _float(p.pos, tr.g_floatBlocked, const Color(0xFF80D8FF));
      return false;
    }
    if (guardReady) {
      p.guardCooldown = ship.guardInterval;
      _float(p.pos, tr.g_floatGuard, const Color(0xFF80D8FF));
      sfx.add(Sfx.shield);
      return false;
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
      GameTelemetry.emit(TelemetryEvent.firstDeath);
      shake = 20;
      sfx.add(Sfx.bigExplode);
      _burst(p.pos, const Color(0xFFFF7043), 70);
      say(
        Speaker.pirate,
        [tr.g_pirateWin0, tr.g_pirateWin1, tr.g_pirateWin2][_rng.nextInt(3)],
      );
    }
    return true;
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
          : events
                .where((ev) => ev.id == e.eventId && ev.kind == EventKind.raid)
                .firstOrNull;
      if (raid != null && raid.planet != null && targetDist > 450) {
        target = raid.planet!.pos;
        targetDist = (target - e.pos).distance;
      }
      // 침공 적은 선장이 가까이 없으면 본거지로 곧장 온다 (가는 길의 정거장은 아래에서 고른다)
      final invader = invasion != null && e.eventId == invasion!.id;
      if (invader && targetDist > 450) {
        target = homeBase.pos;
        targetDist = (target - e.pos).distance;
      }
      if (e.campaignChapter == 5 &&
          campaignAnchor != null &&
          targetDist > 450) {
        target = campaignAnchor!.pos;
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
      if (target == null ||
          (targetDist > _aggroRange(e) &&
              raid == null &&
              !invader &&
              e.name == null)) {
        e.wanderAngle += randRange(_rng, -1, 1) * dt;
        desired = OffsetX.fromAngle(e.wanderAngle, e.speed * 0.4);
      } else {
        final to = (target - e.pos).normalized();
        if (e.name != null && !invader && targetDist > 1100) {
          // 현상수배범은 멀리서는 배회
          e.wanderAngle += randRange(_rng, -1, 1) * dt;
          desired = OffsetX.fromAngle(e.wanderAngle, e.speed * 0.3);
        } else if (e.kind == PirateKind.bomber) {
          desired = to * e.speed;
        } else if (e.kind == PirateKind.juggernaut) {
          // 돌진 중에는 뱃머리 방향으로 곧장
          desired = e.dash > 0
              ? OffsetX.fromAngle(e.angle) * e.speed * 3.4
              : to * e.speed;
        } else if (e.kind == PirateKind.phantom && e.cloaked) {
          desired = to * e.speed * 1.2; // 숨은 채로 파고든다
        } else if (_kiteRange(e.kind) case (final near, final far)) {
          // 거리를 두는 적: 멀면 다가오고, 가까우면 물러나고, 사이에서는 옆으로 돈다
          desired = targetDist > far
              ? to * e.speed
              : targetDist < near
              ? to * -e.speed
              : Offset(-to.dy, to.dx) * e.speed * 0.5;
          if (e.charge > 0) desired *= 0.15; // 레이저 충전 중엔 거의 멈춘다
        } else if (e.kind == PirateKind.sniper) {
          if (targetDist > 750) {
            desired = to * e.speed;
          } else if (targetDist < 520) {
            desired = to * -e.speed;
          } else {
            desired = Offset(-to.dy, to.dx) * e.speed * 0.5;
          }
        } else if (raid != null &&
            target == raid.planet?.pos &&
            targetDist < raid.planet!.radius + 200) {
          desired = Offset(-to.dy, to.dx) * e.speed * 0.7;
        } else if (targetDist > 260) {
          desired = to * e.speed;
        } else {
          desired = Offset(-to.dy, to.dx) * e.speed * 0.8 + to * -40;
        }
      }
      if (e.kind == PirateKind.boss && e.charge > 0) {
        desired *= 0.15; // 플레어 포격함도 충전 중엔 거의 멈춘다
      }
      e.vel += (desired - e.vel) * min(1, 2.5 * dt);
      e.pos += e.vel * dt;
      e.pos = _clampWorld(e.pos, (v) => e.vel = v);

      if (e.kind == PirateKind.boss) _bossPattern(e, dt, target, targetDist);

      if (target == null) continue;
      final aim = atan2(target.dy - e.pos.dy, target.dx - e.pos.dx);
      if (e.dash <= 0) {
        final turn = e.kind == PirateKind.juggernaut ? 1.2 : 4.0;
        e.angle += angleDiff(e.angle, aim).clamp(-turn * dt, turn * dt);
      }

      if (e.kind == PirateKind.bomber) {
        if (targetDist < e.radius + 40) exploded.add(e);
        continue;
      }
      if (e.kind.isLate && _lateFoeAct(e, dt, target, targetDist)) continue;
      if (e.cloaked || e.charge > 0) continue; // 이온 유령 은신·포격 충전 중엔 쏘지 않는다
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
          bullets.add(
            Bullet(
              e.pos + dir * e.radius,
              dir * speed,
              e.damage * _newbieMul,
              false,
              life: e.kind == PirateKind.sniper ? 1.4 : 1.6,
              big: e.kind == PirateKind.sniper || e.kind == PirateKind.boss,
              source: e,
            ),
          );
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
        if (p.domeUp || relayShieldActive(p)) {
          if ((p.pos - e.pos).distance < p.domeRadius + 100) {
            _hitDome(p, e.damage);
          }
        } else if ((p.pos - e.pos).distance < p.radius + 100) {
          _hitStabilizer(p, e.damage);
        }
      }
      if (player.alive &&
          (player.pos - e.pos).distance < 100 &&
          domeAt(player.pos) == null) {
        _damagePlayer(e.damage);
      }
      for (final s in stations) {
        // 본거지는 안전 구역 안의 폭발을 대신 맞는다
        if ((s.pos - e.pos).distance < 120 ||
            (s == homeBase && inHaven(e.pos))) {
          s.takeHit(e.damage);
        }
      }
    }
  }

  final _spawnQueue = <Pirate>[];

  /// 이 거리 밖의 적은 선장을 쫓지 않고 배회한다 (지표 탐험 생물은 더 짧다)
  double _aggroRange(Pirate e) => 1600;

  // ---------- 후반 적 ----------
  /// 거리를 두고 싸우는 후반 적의 (가까운 한계, 먼 한계)
  static (double, double)? _kiteRange(PirateKind k) => switch (k) {
    PirateKind.missile => (480.0, 760.0),
    PirateKind.laser => (560.0, 800.0),
    PirateKind.carrier => (520.0, 820.0),
    PirateKind.medic => (620.0, 880.0),
    PirateKind.mine => (260.0, 460.0), // 앞을 가로지르며 기뢰를 깐다
    _ => null,
  };

  /// 방패선 효과 범위
  static const wardenRange = 280.0;

  bool _wardenNear(Pirate e) => pirates.any(
    (w) =>
        w.kind == PirateKind.warden &&
        !identical(w, e) &&
        (w.pos - e.pos).distance < wardenRange,
  );

  /// 후반 적 고유 행동. true를 돌려주면 일반 사격을 하지 않는다.
  bool _lateFoeAct(Pirate e, double dt, Offset target, double targetDist) {
    e.pulse = max(0, e.pulse - dt);
    e.abilityTimer -= dt;
    switch (e.kind) {
      case PirateKind.missile:
        // 양쪽 포드에서 유도탄 한 발씩
        if (e.abilityTimer <= 0 && targetDist < 900) {
          e.abilityTimer = 3.4 * randRange(_rng, 0.85, 1.2);
          for (final side in const [-1, 1]) {
            final dir = OffsetX.fromAngle(e.angle + side * 1.1);
            enemyMissiles.add(
              EnemyMissile(
                e.pos + dir * e.radius,
                dir * EnemyMissile.speed,
                e.damage * _newbieMul,
              ),
            );
          }
          sfx.add(Sfx.missile);
        }
        return true;
      case PirateKind.laser:
        if (e.charge > 0) {
          e.charge -= dt;
          // 충전 앞부분만 조준을 따라온다. 막판에는 고정되어 옆으로 피할 수 있다
          if (e.charge > 0.45) {
            final aim = atan2(target.dy - e.pos.dy, target.dx - e.pos.dx);
            e.aimAngle += angleDiff(e.aimAngle, aim).clamp(-1.5 * dt, 1.5 * dt);
          }
          e.angle = e.aimAngle;
          if (e.charge <= 0) _fireEnemyLaser(e);
        } else if (e.abilityTimer <= 0 && targetDist < 820) {
          e.charge = 1.2;
          e.aimAngle = atan2(target.dy - e.pos.dy, target.dx - e.pos.dx);
          e.abilityTimer = 4.2 * randRange(_rng, 0.85, 1.2);
        }
        return true;
      case PirateKind.carrier:
        // 9초마다 드론 2기 (모함 하나당 최대 4기)
        if (e.abilityTimer <= 0) {
          e.abilityTimer = 9;
          final alive =
              pirates.where((o) => identical(o.parent, e)).length +
              _spawnQueue.where((o) => identical(o.parent, e)).length;
          for (var i = alive; i < min(4, alive + 2); i++) {
            _spawnQueue.add(
              _makePirate(
                PirateKind.scout,
                e.pos +
                    OffsetX.fromAngle(
                      e.angle + pi / 2 * (i.isEven ? 1 : -1),
                      e.radius + 10,
                    ),
                hpMul: 0.6,
              )..parent = e,
            );
          }
          e.pulse = 1;
        }
        return false;
      case PirateKind.phantom:
        if (e.abilityTimer <= 0) {
          e.cloaked = !e.cloaked;
          e.abilityTimer = e.cloaked ? 3.5 : 2.8;
          _burst(e.pos, const Color(0xFFB388FF), 16);
          if (!e.cloaked) e.fireCooldown = 0.15; // 드러나자마자 쏜다
        }
        return e.cloaked;
      case PirateKind.mine:
        if (e.abilityTimer <= 0) {
          e.abilityTimer = 2.4;
          if (mines.length < 18) {
            mines.add(
              SpaceMine(
                e.pos - OffsetX.fromAngle(e.angle) * e.radius,
                e.damage * _newbieMul,
              ),
            );
          }
        }
        return true;
      case PirateKind.medic:
        // 2초마다 주변 아군 체력 12% 수리
        if (e.abilityTimer <= 0) {
          e.abilityTimer = 2;
          for (final o in pirates) {
            if (identical(o, e) || !o.isPirate || o.hp >= o.maxHp) continue;
            if ((o.pos - e.pos).distance > 300) continue;
            o.hp = min(o.maxHp, o.hp + o.maxHp * 0.12);
            _spark(o.pos, const Color(0xFF69F0AE));
            e.pulse = 1;
          }
        }
        return false;
      case PirateKind.juggernaut:
        if (e.dash > 0) {
          e.dash -= dt;
          if (player.alive &&
              (player.pos - e.pos).distance < e.radius + 20 &&
              e.contactCooldown <= 0) {
            e.contactCooldown = 1;
            e.dash = 0;
            _damagePlayer(e.damage * _newbieMul);
            player.vel = (player.pos - e.pos).normalized() * 700;
          }
        } else if (e.abilityTimer <= 0 && targetDist < 700) {
          e.dash = 1.1;
          e.abilityTimer = 6;
          e.angle = atan2(target.dy - e.pos.dy, target.dx - e.pos.dx);
          sfx.add(Sfx.alarm);
        }
        return false;
      default:
        return false;
    }
  }

  void _fireEnemyLaser(Pirate e, {double? angle}) {
    final dir = OffsetX.fromAngle(angle ?? e.aimAngle);
    final from = e.pos + dir * e.radius;
    final to = from + dir * 950;
    beams.add(LaserBeam(from, to, hostile: true));
    shake = min(14, shake + 3);
    final dmg = e.damage * _newbieMul;
    if (player.alive && _segmentDistance(player.pos, from, to) < 24) {
      final dome = domeAt(player.pos);
      if (dome != null) {
        _hitDome(dome, dmg);
      } else {
        _damagePlayer(dmg);
      }
    }
    for (final st in stations) {
      if (_segmentDistance(st.pos, from, to) < 60) st.takeHit(dmg);
    }
  }

  static double _segmentDistance(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return (p - a).distance;
    final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(
      0.0,
      1.0,
    );
    return (p - (a + ab * t)).distance;
  }

  /// 유도탄·기뢰: 선장에게 피해, 선장의 탄에 맞으면 사라진다
  void _updateHostileOrdnance(double dt) {
    if (enemyMissiles.isEmpty && mines.isEmpty) return;
    final usedBullets = <Bullet>{};
    Bullet? shotBy(Offset pos, double r) {
      for (final b in bullets) {
        if (b.fromPlayer &&
            !usedBullets.contains(b) &&
            (b.pos - pos).distance < r) {
          usedBullets.add(b);
          return b;
        }
      }
      return null;
    }

    final deadMissiles = <EnemyMissile>{};
    for (final m in enemyMissiles) {
      m.life -= dt;
      if (player.alive) {
        final want = atan2(player.pos.dy - m.pos.dy, player.pos.dx - m.pos.dx);
        final now = atan2(m.vel.dy, m.vel.dx);
        final turn = angleDiff(
          now,
          want,
        ).clamp(-EnemyMissile.turnRate * dt, EnemyMissile.turnRate * dt);
        m.vel = OffsetX.fromAngle(now + turn, EnemyMissile.speed);
      }
      m.pos += m.vel * dt;
      if (_rng.nextDouble() < 0.7) {
        particles.add(
          Particle(m.pos, -m.vel * 0.1, 0.35, const Color(0xFFFF8A65), 2.5),
        );
      }
      final dome = domeAt(m.pos);
      if (m.life <= 0 || shotBy(m.pos, 18) != null) {
        deadMissiles.add(m);
        _burst(m.pos, const Color(0xFFFFAB40), 10);
      } else if (dome != null) {
        _hitDome(dome, m.damage);
        deadMissiles.add(m);
        _burst(m.pos, const Color(0xFF80D8FF), 10);
      } else if (player.alive && (player.pos - m.pos).distance < 22) {
        _damagePlayer(m.damage);
        deadMissiles.add(m);
        _burst(m.pos, const Color(0xFFFF7043), 16);
        sfx.add(Sfx.explode);
      }
    }
    enemyMissiles.removeWhere(deadMissiles.contains);

    final deadMines = <SpaceMine>{};
    for (final m in mines) {
      m.life -= dt;
      m.arm -= dt;
      if (m.life <= 0) {
        deadMines.add(m);
      } else if (shotBy(m.pos, 22) != null) {
        deadMines.add(m);
        _burst(m.pos, const Color(0xFFFFEB3B), 14);
      } else if (m.arm <= 0 &&
          player.alive &&
          (player.pos - m.pos).distance < SpaceMine.trigger) {
        deadMines.add(m);
        _burst(m.pos, const Color(0xFFFFEB3B), 40);
        sfx.add(Sfx.explode);
        shake = min(16, shake + 6);
        if ((player.pos - m.pos).distance < SpaceMine.blast &&
            domeAt(player.pos) == null) {
          _damagePlayer(m.damage);
        }
      }
    }
    mines.removeWhere(deadMines.contains);
    if (usedBullets.isNotEmpty) bullets.removeWhere(usedBullets.contains);
  }

  void _bossPattern(Pirate e, double dt, Offset? target, double targetDist) {
    final archetype = e.archetype;
    if (archetype != null) {
      _archetypePattern(e, archetype, dt, target, targetDist);
    }
    // 2페이즈: 체력 절반 이하에서 부하 소환 + 공격 강화
    if (!e.enraged && e.hp < e.maxHp * 0.5) {
      e.enraged = true;
      for (var i = 0; i < 3 + sector; i++) {
        _spawnQueue.add(
          _makePirate(
            i.isEven ? PirateKind.scout : PirateKind.bomber,
            e.pos + OffsetX.fromAngle(i * 2.1, 90),
          ),
        );
      }
      shake = min(20, shake + 10);
      sfx.add(Sfx.alarm);
      say(
        Speaker.pirate,
        [tr.g_pirateRage0, tr.g_pirateRage1, tr.g_pirateRage2][_rng.nextInt(3)],
      );
    }
    // 특수 공격: 원형 탄막
    e.specialTimer -= dt;
    if (e.specialTimer <= 0 && targetDist < 900 && !e.cloaked) {
      e.specialTimer = e.enraged ? 3.5 : 6;
      final n = e.enraged ? 16 : 10;
      final off = _rng.nextDouble();
      for (var i = 0; i < n; i++) {
        final dir = OffsetX.fromAngle(off + i * 2 * pi / n);
        bullets.add(
          Bullet(
            e.pos + dir * e.radius,
            dir * 300,
            e.damage * 0.8 * _newbieMul,
            false,
            life: 2.5,
            big: true,
            source: e,
          ),
        );
      }
      _burst(e.pos, const Color(0xFFCE93D8), 20);
    }
  }

  /// 항성계 두목 원형별 고유 패턴 (원형 탄막·분노 소환은 [_bossPattern]이 그대로 한다)
  void _archetypePattern(
    Pirate e,
    BossArchetype a,
    double dt,
    Offset? target,
    double targetDist,
  ) {
    e.archetypeTimer -= dt;
    switch (a) {
      case BossArchetype.fleet:
        // 10초마다 습격선 호위 2기, 맵 위 호위는 최대 6기
        if (e.archetypeTimer <= 0) {
          e.archetypeTimer = BossArchetype.escortInterval;
          final alive =
              pirates.where((o) => identical(o.parent, e)).length +
              _spawnQueue.where((o) => identical(o.parent, e)).length;
          final n = min(
            BossArchetype.escortBatch,
            BossArchetype.escortMax - alive,
          );
          for (var i = 0; i < n; i++) {
            _spawnQueue.add(
              _makePirate(
                PirateKind.raider,
                e.pos +
                    OffsetX.fromAngle(
                      e.angle + pi / 2 * (i.isEven ? 1 : -1),
                      e.radius + 30,
                    ),
              )..parent = e,
            );
          }
          if (n > 0) _burst(e.pos, const Color(0xFFFF8A65), 18);
        }
      case BossArchetype.devourer:
        // 5초마다 자기 주위에 기뢰 3개 (기뢰 부설선과 같은 맵 최대 18개)
        if (e.archetypeTimer <= 0) {
          e.archetypeTimer = BossArchetype.mineInterval;
          final off = _rng.nextDouble() * 2 * pi;
          for (var i = 0; i < BossArchetype.mineBatch; i++) {
            if (mines.length >= 18) break;
            mines.add(
              SpaceMine(
                e.pos +
                    OffsetX.fromAngle(
                      off + i * 2 * pi / BossArchetype.mineBatch,
                      e.radius + 50,
                    ),
                e.damage * _newbieMul,
              ),
            );
          }
        }
      case BossArchetype.flare:
        if (e.charge > 0) {
          e.charge -= dt;
          // 레이저 함처럼 충전 앞부분만 조준을 따라오고 막판엔 고정된다
          if (e.charge > 0.45 && target != null) {
            final aim = atan2(target.dy - e.pos.dy, target.dx - e.pos.dx);
            e.aimAngle += angleDiff(e.aimAngle, aim).clamp(-1.5 * dt, 1.5 * dt);
          }
          e.angle = e.aimAngle;
          if (e.charge <= 0) {
            e.charge = 0;
            for (final side in const [-1, 0, 1]) {
              _fireEnemyLaser(
                e,
                angle: e.aimAngle + side * BossArchetype.flareSpread,
              );
            }
          }
        } else if (e.archetypeTimer <= 0 &&
            target != null &&
            targetDist < 900) {
          e.archetypeTimer = BossArchetype.flareInterval;
          e.charge = BossArchetype.flareCharge;
          e.aimAngle = atan2(target.dy - e.pos.dy, target.dx - e.pos.dx);
          sfx.add(Sfx.alarm);
        }
      case BossArchetype.wraith:
        // 4초 은신 ↔ 4초 노출 (유령선 규칙: 은신 중엔 맞지 않고 표적이 되지 않는다)
        if (e.archetypeTimer <= 0) {
          e.archetypeTimer = BossArchetype.wraithPhase;
          e.cloaked = !e.cloaked;
          _burst(e.pos, const Color(0xFFB388FF), 24);
          if (!e.cloaked) e.fireCooldown = 0.15;
        }
      case BossArchetype.gravity:
        // 반경 안의 선장을 두목 쪽으로 끌어당긴다. 부스트 중엔 벗어날 수 있다
        final p = player;
        final d = (e.pos - p.pos).distance;
        if (p.alive &&
            boostTime <= 0 &&
            d < BossArchetype.gravityRange &&
            d > e.radius) {
          p.pos += (e.pos - p.pos) / d * BossArchetype.gravityPull * dt;
        }
      case BossArchetype.plunder:
        break; // 속도 ×1.4는 [Pirate.speed], 약탈은 [_plunder]
    }
  }

  /// 항성계 두목 첫 격파 보상 (약탈 상한의 기준)
  int get sectorBossReward => (1000 * rewardMul * shipCreditMul).round();

  /// 약탈 상선의 탄이 선장에게 맞았다: 크레딧 1%를 빼앗아 쌓는다 (보상의 50%까지)
  void _plunder(Pirate e) {
    final room = sectorBossReward * BossArchetype.plunderCapRatio - e.plundered;
    final take = min(room, credits * BossArchetype.plunderRate);
    if (take <= 0) return;
    credits -= take;
    e.plundered += take;
    _float(
      player.pos + const Offset(0, -24),
      '-${take.round()}',
      const Color(0xFFFFD54F),
    );
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
    if (d < e.radius + 16 &&
        e.contactCooldown <= 0 &&
        domeAt(player.pos) == null) {
      e.contactCooldown = 0.8;
      _damagePlayer(e.damage * enemyDamageMul);
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
        if (!e.isPirate || e.cloaked) continue;
        final d = (e.pos - s.pos).distance;
        if (d < bestD) {
          bestD = d;
          best = e;
        }
      }
      if (best != null) {
        s.turretCooldown = s.turretInterval;
        final dir = (best.pos - s.pos).normalized();
        bullets.add(
          Bullet(
            s.pos + dir * 50,
            dir * 700,
            s.turretDamage * sectorMul * trait.turretDamageMul,
            true,
          ),
        );
      }
    }
  }

  void _updateColonies(double dt) {
    for (final p in planets) {
      if (p.colonyLevel == 0) continue;
      if (p.domeUp || relayShieldActive(p)) {
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
      final best = colonyTurretTarget(p);
      if (best != null) {
        p.turretCooldown = p.turretInterval;
        final dir = (best.pos - p.pos).normalized();
        bullets.add(
          Bullet(
            p.pos + dir * (p.radius + 10),
            dir * 700,
            p.turretDamage * sectorMul * trait.turretDamageMul,
            true,
          ),
        );
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
          if (e.cloaked) continue;
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
        particles.add(
          Particle(m.pos, -m.vel * 0.1, 0.3, const Color(0xFFFFCC80), 2.5),
        );
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

  void _hitPirate(
    Pirate e,
    double dmg,
    Offset at, {
    bool crit = false,
    bool byBase = false,
    Offset? from,
  }) {
    if (e.cloaked) return;
    // 중장갑 돌격함: 정면(뱃머리)에서 오는 탄은 60% 막는다
    if (e.kind == PirateKind.juggernaut &&
        from != null &&
        from != Offset.zero) {
      final facing = OffsetX.fromAngle(e.angle);
      final incoming = from.normalized();
      if (facing.dx * -incoming.dx + facing.dy * -incoming.dy > 0.5) {
        dmg *= 0.4;
        _spark(at, const Color(0xFFB0BEC5));
      }
    }
    // 방패선 근처의 아군은 피해 절반 (방패선 자신은 제외)
    if (e.kind != PirateKind.warden && _wardenNear(e)) {
      dmg *= 0.5;
      _spark(at, const Color(0xFF64B5F6));
    }
    e.hp -= dmg;
    e.lastHitByBase = byBase;
    e.hitFlash = 0.1;
    if (crit) {
      _float(
        at,
        tr.g_floatCrit(dmg.round()),
        const Color(0xFFFF9100),
        big: true,
      );
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
          if (e.cloaked || (b.hits?.contains(e) ?? false)) continue;
          if ((e.pos - b.pos).distance < e.radius) {
            _hitPirate(e, b.damage, b.pos, crit: b.big, from: b.vel);
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
        final exposed = planets
            .where(
              (p) =>
                  !p.domeUp &&
                  p.building(ColonyBuilding.stabilizer) > 0 &&
                  (p.pos - b.pos).distance < p.radius + 35,
            )
            .firstOrNull;
        if (exposed != null) {
          _hitStabilizer(exposed, b.damage);
          dead.add(b);
          continue;
        }
        if (player.alive &&
            (player.pos - b.pos).distance < (shielded ? 30 : 18)) {
          if (_damagePlayer(b.damage) &&
              b.source?.archetype == BossArchetype.plunder) {
            _plunder(b.source!);
          }
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
    profile.codex.recordKill(e); // 도감 (TASK 006)
    if (e.campaignChapter == sector && campaignMissionActive) {
      counters['campaignKills_$sector'] = campaignKills + 1;
      if (sector == 16) {
        counters['campaignWreckX'] = e.pos.dx.round();
        counters['campaignWreckY'] = e.pos.dy.round();
      }
    }
    if (e.finalGuardian && finalMissionStage == FinalMissionStage.guardian) {
      counters['finalMissionStage'] = FinalMissionStage.counterattack.index;
    }
    final boss = e.kind == PirateKind.boss;
    _burst(
      e.pos,
      e.kind == PirateKind.jelly
          ? const Color(0xFFE040FB)
          : const Color(0xFFFF7043),
      boss ? 100 : 35,
    );
    sfx.add(boss ? Sfx.bigExplode : Sfx.explode);
    shake = min(20, shake + (boss ? 16 : 3));
    final bounty =
        (e.bounty *
                rewardMul *
                trait.bountyMul *
                (1 + crewBonus(CrewRole.trader)) *
                (e.name != null ? 4 : 1) *
                (e.lastHitByBase ? laserBountyRatio : shipCreditMul) *
                _newbieMul) // 적이 약한 초반에는 떨어뜨리는 크레딧도 같은 비율로
            .round();
    _dropPickups(e.pos, PickupKind.credits, bounty, boss ? 10 : 3);

    if (e.kind == PirateKind.jelly) {
      profile.addStat('jelly');
      _dropPickups(e.pos, PickupKind.ore, 30, 3);
      if (_rng.nextDouble() < 0.35) {
        pickups.add(
          Pickup(
            PickupKind.gem,
            e.pos,
            1,
            OffsetX.fromAngle(_rng.nextDouble() * 6, 80),
          ),
        );
      }
      return;
    }

    _count('kills');
    // 튜토리얼 '해적 3척 격추'는 내 함선(총알·미사일·드론)이 잡은 것만 센다 (본거지 레이저 제외)
    if (!e.lastHitByBase) {
      _count('shipKills');
      profile.weeklyScore.addPirateKill();
    }
    profile.addStat('kills');
    GameTelemetry.emit(TelemetryEvent.firstKill);
    for (final m in activeMissions) {
      if (m.type == MissionType.kill) m.progress++;
      if (m.type == MissionType.bounty && e.missionId == m.id) m.progress = 1;
    }

    if (_rng.nextDouble() < (boss ? 1 : 0.08)) {
      final pk = PowerUpKind.values[_rng.nextInt(PowerUpKind.values.length)];
      pickups.add(
        Pickup(
          PickupKind.power,
          e.pos,
          1,
          OffsetX.fromAngle(_rng.nextDouble() * 6, 60),
          power: pk,
        ),
      );
    }

    if (e.miniBoss) {
      _miniBossDown(e);
    } else if (boss) {
      profile.addStat('bosses');
      GameTelemetry.emit(TelemetryEvent.firstBoss);
      profile.weeklyScore.addBossDefeated();
      _dropPickups(e.pos, PickupKind.ore, (120 * sectorMul).round(), 6);
      _dropPickups(e.pos, PickupKind.gem, 5, 5);
      if (e.sectorBoss) {
        // 약탈 상선이 빼앗아 간 크레딧은 처치하면 모두 돌려받는다
        final stolen = e.plundered.round();
        credits += e.plundered;
        if (!bossDefeated) {
          _count('sectorBosses');
          // 게이트는 발전도로 열린다. 두목은 큰 보상을 주는 도전 과제.
          final reward = sectorBossReward;
          credits += reward;
          say(Speaker.advisor, tr.g_dlgBossDefeated(reward + stolen));
        }
        bossDefeated = true;
        say(Speaker.pirate, tr.g_pirateBossLose);
      } else {
        say(Speaker.pirate, tr.g_pirateBossFlee);
      }
    } else if (e.name != null && !e.invasionCommander) {
      say(Speaker.captain, tr.g_dlgBountyCaught(e.name ?? ''));
    } else if (_rng.nextDouble() < 0.12) {
      say(
        Speaker.captain,
        [
          tr.g_captainKill0,
          tr.g_captainKill1,
          tr.g_captainKill2,
          tr.g_captainKill3,
        ][_rng.nextInt(4)],
      );
    }
  }

  void _updateAsteroids(double dt) {
    for (final a in asteroids) {
      a.rotation += a.spin * dt;
      a.hitFlash = max(0, a.hitFlash - dt);
      if (a.drift != Offset.zero) a.pos += a.drift * dt;
    }
    // 떠다니는 유성우 소행성이 맵 밖으로 나가면 제거
    asteroids.removeWhere(
      (a) =>
          a.drift != Offset.zero &&
          (a.pos.dx.abs() > worldHalf + 100 ||
              a.pos.dy.abs() > worldHalf + 100),
    );
    final broken = asteroids.where((a) => a.hp <= 0).toList();
    for (final a in broken) {
      asteroids.remove(a);
      _count('asteroids');
      sfx.add(Sfx.hit);
      _burst(
        a.pos,
        a.crystal ? const Color(0xFF4DD0E1) : const Color(0xFFA1887F),
        20,
      );
      _dropPickups(
        a.pos,
        PickupKind.ore,
        (a.radius / 3 * (a.crystal ? 3 : 1) * sectorMul * trait.miningOreMul)
            .round(),
        3,
      );
      if (_rng.nextDouble() < 0.3) {
        _dropPickups(
          a.pos,
          PickupKind.credits,
          (10 * baseRewardMul * shipCreditMul).round(),
          1,
        );
      }
    }
    while (asteroids.length < maxAsteroids) {
      _spawnAsteroid(awayFrom: player.pos);
    }
  }

  void _dropPickups(Offset pos, PickupKind kind, int total, int pieces) {
    final each = max(1, total ~/ pieces);
    for (var i = 0; i < pieces; i++) {
      pickups.add(
        Pickup(
          kind,
          pos,
          each,
          OffsetX.fromAngle(
            _rng.nextDouble() * 2 * pi,
            randRange(_rng, 40, 140),
          ),
        ),
      );
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
        final n =
            k.amount * (buffs.containsKey(PowerUpKind.doubleCredits) ? 2 : 1);
        credits += n;
        sfx.add(Sfx.coin);
        _float(k.pos, '+$n', const Color(0xFFFFD54F));
      case PickupKind.ore:
        final n =
            (k.amount *
                    (1 + crewBonus(CrewRole.miner)) *
                    ship.oreMul *
                    profile.home.oreMul)
                .round();
        ore += n;
        profile.addStat('ore', n);
        for (final m in activeMissions) {
          if (m.type == MissionType.mine) m.progress += n;
        }
        sfx.add(Sfx.pickup);
        _float(k.pos, '+$n💎', const Color(0xFF4DD0E1));
      case PickupKind.gem:
        profile.earnGems('play', '', k.amount);
        sfx.add(Sfx.gem);
        _float(k.pos, '+${k.amount}⭐', const Color(0xFFFF80AB), big: true);
      case PickupKind.power:
        final pk = k.power!;
        buffs[pk] = pk.duration;
        profile.addStat('powerups');
        sfx.add(Sfx.upgrade);
        _float(
          k.pos,
          '${pk.icon} ${pk.label}!',
          const Color(0xFFB9F6CA),
          big: true,
        );
    }
  }

  void _updateParticles(double dt) {
    for (final p in particles) {
      p.life -= dt;
      p.pos += p.vel * dt;
      p.vel = p.vel * pow(0.1, dt).toDouble();
    }
    particles.removeWhere((p) => p.life <= 0);
    if (particles.length > 600) {
      particles.removeRange(0, particles.length - 600);
    }
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
          planet.raided =
              !planet.domeUp &&
              !relayShieldActive(planet) &&
              attackers.any(
                (e) => (e.pos - planet.pos).distance < planet.radius + 450,
              );
          if (attackers.isEmpty) {
            ev.finished = true;
            planet.raided = false;
            final reward = (200 * rewardMul * shipCreditMul).round();
            credits += reward;
            profile.earnGems('play', '', 2);
            sfx.add(Sfx.coin);
            say(Speaker.advisor, tr.g_dlgRaidDefended(planet.name, reward));
          } else if (ev.timeLeft <= 0) {
            ev.finished = true;
            planet.raided = false;
            pirates.removeWhere((e) => e.eventId == ev.id);
            if (planet.domeUp || relayShieldActive(planet)) {
              // 방어막 또는 중계 보호막이 끝까지 버텼다
            } else if (planet.activeSpec == ColonySpec.fortress) {
              // 요새 특화(Lv.5 이상)는 습격으로 레벨을 잃지 않는다
              say(Speaker.advisor, tr.g_dlgRaidFortress(planet.name));
            } else if (planet.colonyLevel > 1) {
              planet.colonyLevel--;
              say(
                Speaker.advisor,
                tr.g_dlgRaidLooted(
                  iGa(planet.name),
                  euro('Lv.${planet.colonyLevel}'),
                ),
              );
            } else {
              say(Speaker.advisor, tr.g_dlgRaidLeft(eul(planet.name)));
            }
          }
        case EventKind.supply:
          if (_supplyCapsule == null || !pickups.contains(_supplyCapsule)) {
            ev.finished = true;
            if (_supplyCapsule != null &&
                _supplyCapsule!.life <= 0 &&
                ev.timeLeft > 0) {
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
      // 대규모 침공 중(경보 포함)엔 습격을 새로 시작하지 않는다
      if (colonies.isNotEmpty &&
          !invasionActive &&
          !events.any((e) => e.kind == EventKind.raid)) ...[
        EventKind.raid,
        EventKind.raid,
      ],
    ];
    final raidCount = options.where((kind) => kind == EventKind.raid).length;
    if (raidCount > 0 && trait.raidFrequencyMul != 1) {
      // 기존 확률(보통 2/5)에 ×1.3. 가중치만 ×1.3 하면 정규화되어 요구 빈도보다 낮아진다.
      final raidChance = raidCount / options.length * trait.raidFrequencyMul;
      if (_rng.nextDouble() < raidChance) {
        startEvent(EventKind.raid);
        return;
      }
      options.removeWhere((kind) => kind == EventKind.raid);
    }
    startEvent(options[_rng.nextInt(options.length)]);
  }

  /// 테스트/디버그용으로도 사용
  WorldEvent? startEvent(EventKind kind) {
    final id = _nextId++;
    final away =
        player.pos +
        OffsetX.fromAngle(
          _rng.nextDouble() * 2 * pi,
          randRange(_rng, 900, 1300),
        );
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
          final e = _makePirate(
            k,
            planet.pos +
                OffsetX.fromAngle(
                  _rng.nextDouble() * 2 * pi,
                  planet.radius + 500,
                ),
          );
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
          final a = Asteroid(
            pos +
                OffsetX.fromAngle(
                  _rng.nextDouble() * 2 * pi,
                  randRange(_rng, 0, 420),
                ),
            randRange(_rng, 14, 26),
            _rng.nextInt(99999),
            crystal: true,
          )..drift = drift;
          asteroids.add(a);
        }
        say(Speaker.advisor, tr.g_dlgMeteor);
        return ev;
      case EventKind.merchant:
        final ev = WorldEvent(id, kind, pos, 120);
        events.add(ev);
        merchantCrew = CrewMember.random(
          _rng,
          _nextId++,
          odds: const {2: 70, 3: 30},
        );
        merchantGemTrades = 0;
        say(Speaker.merchant, tr.g_merchantHello);
        return ev;
      case EventKind.supply:
        final ev = WorldEvent(id, kind, pos, 120);
        events.add(ev);
        _supplyCapsule = Pickup(
          PickupKind.gem,
          pos,
          5 + _rng.nextInt(6),
          Offset.zero,
        )..life = 120;
        pickups.add(_supplyCapsule!);
        for (var i = 0; i < 2 + sector; i++) {
          pirates.add(
            _makePirate(
              PirateKind.raider,
              pos + OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, 200),
            ),
          );
        }
        say(Speaker.advisor, tr.g_dlgSupplySignal);
        return ev;
    }
  }

  // 상인 거래
  int get merchantCrewPrice => (1500 * sectorMul).round();

  /// 상인 젬 환전 (⭐5). 크레딧 팩(⭐20)보다 젬당 [merchantGemMarkup]배 비싸서
  /// 크레딧→젬→크레딧 무한 순환이 안 된다
  static const merchantGemMarkup = 2.0;
  int get merchantGemPrice =>
      (creditPackAmount * 5 / creditPackGems * merchantGemMarkup).round();
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
    profile.earnGems('play', '', 5);
    sfx.add(Sfx.gem);
    return true;
  }

  bool buyPowerUp(PowerUpKind k) {
    if (!_pay((merchantPowerPrice, 0))) return false;
    buffs[k] = k.duration * 2;
    sfx.add(Sfx.upgrade);
    return true;
  }

  // ---------- 대규모 침공 ----------
  /// 해금: 현재 항성계 식민지 수
  static const invasionColonies = 3;

  /// 항성계에 들어와 첫 침공까지 / 끝난 뒤 다음 침공까지 (초)
  static const invasionFirstDelay = 300.0;
  static const invasionGapMin = 360.0;
  static const invasionGapMax = 480.0;
  static const invasionWarning = 20.0;
  static const invasionWaves = 3;
  static const invasionWaveGap = 25.0;

  /// 마지막 파도 등장 뒤 전멸시켜야 하는 시간
  static const invasionJudge = 90.0;

  /// 결과 한 줄을 HUD에 보여 주는 시간
  static const invasionResultTime = 8.0;
  static const invasionReward = 600.0;
  static const invasionGems = 5;

  /// 침공 함대가 나타나는 거리 (본거지 기준, 맵 가장자리 쪽)
  static const invasionMinDist = 1600.0;
  static const invasionMaxDist = 2000.0;

  /// 파도 크기: min(18, round(6 + 위협도×1.5)), 태양계는 ×0.6, 최소 4
  static int invasionWaveSize(double threat, int sector) {
    final n = min(18, (6 + threat * 1.5).round());
    return max(4, sector == 0 ? (n * 0.6).round() : n);
  }

  /// 경보 또는 파도 진행 중 (결과 표시만 남았으면 false)
  bool get invasionActive =>
      invasion != null && invasion!.phase != InvasionPhase.done;

  /// 맵에 남은 침공 적
  int get invasionEnemiesLeft {
    final inv = invasion;
    if (inv == null) return 0;
    return pirates.where((e) => e.eventId == inv.id).length;
  }

  /// 승리 크레딧 (퇴각은 여기에 처치 비율을 곱한다)
  int get invasionVictoryCredits =>
      (invasionReward * rewardMul * shipCreditMul).round();

  void _updateInvasion(double dt) {
    final inv = invasion;
    if (inv != null) {
      inv.timer -= dt;
      switch (inv.phase) {
        case InvasionPhase.warning:
          if (inv.timer <= 0) {
            inv.phase = InvasionPhase.waves;
            _spawnInvasionWave(inv);
          }
        case InvasionPhase.waves:
          if (inv.wave < invasionWaves) {
            if (inv.timer <= 0) _spawnInvasionWave(inv);
          } else if (invasionEnemiesLeft == 0) {
            _endInvasion(inv, won: true);
          } else if (inv.timer <= 0) {
            _endInvasion(inv, won: false);
          }
        case InvasionPhase.done:
          if (inv.timer <= 0) invasion = null;
      }
    }
    // 다음 침공 타이머는 끝난 시점부터 센다 (결과 표시 중에도)
    if (invasionActive) return;
    invasionTimer -= dt;
    // 선장이 격추돼 있으면 살아날 때까지 미룬다
    if (invasionTimer <= 0 && colonyCount >= invasionColonies && player.alive) {
      startInvasion();
    }
  }

  /// 경보를 울리고 20초 카운트다운을 시작한다. 테스트/디버그용으로도 사용
  Invasion startInvasion() {
    final a = _rng.nextDouble() * 2 * pi;
    final from = _clampWorld(
      homeBase.pos +
          OffsetX.fromAngle(a, (invasionMinDist + invasionMaxDist) / 2),
      (_) {},
    );
    final inv = Invasion(_nextId++, from, invasionWarning);
    invasion = inv;
    sfx.add(Sfx.alarm);
    say(Speaker.advisor, tr.g_dlgInvasionWarning(invasionWarning.round()));
    return inv;
  }

  void _spawnInvasionWave(Invasion inv) {
    inv.wave++;
    final last = inv.wave >= invasionWaves;
    inv.timer = last ? invasionJudge : invasionWaveGap;
    final t = threat;
    final dir = (inv.from - homeBase.pos).direction;
    Offset spot() => _clampWorld(
      homeBase.pos +
          OffsetX.fromAngle(
            dir + randRange(_rng, -0.35, 0.35),
            randRange(_rng, invasionMinDist, invasionMaxDist),
          ),
      (_) {},
    );
    final n = invasionWaveSize(t, sector);
    for (var i = 0; i < n; i++) {
      final e = _makePirate(_randomKind(t), spot())..eventId = inv.id;
      pirates.add(e);
    }
    inv.spawned += n;
    if (last) {
      // 침공 지휘함: 습격선 기반 엘리트 (체력 ×6, 공격 ×1.5). 두목 원형은 붙이지 않는다
      final boss = _makePirate(PirateKind.raider, spot(), hpMul: 6, dmgMul: 1.5)
        ..invasionCommander = true
        ..eventId = inv.id;
      pirates.add(boss);
      inv.spawned++;
    }
    sfx.add(Sfx.alarm);
  }

  void _endInvasion(Invasion inv, {required bool won}) {
    inv.phase = InvasionPhase.done;
    inv.timer = invasionResultTime;
    inv.won = won;
    invasionTimer = randRange(_rng, invasionGapMin, invasionGapMax);
    final full = invasionVictoryCredits;
    if (won) {
      inv.killRatio = 1;
      inv.reward = full;
      credits += full;
      profile.earnGems('play', '', invasionGems);
      profile.addStat('invasions');
      sfx.add(Sfx.coin);
      say(Speaker.advisor, tr.g_dlgInvasionWon(full));
    } else {
      // 퇴각: 남은 침공 적은 물러난다. 식민지 레벨은 잃지 않는다
      final left = invasionEnemiesLeft;
      pirates.removeWhere((e) => e.eventId == inv.id);
      inv.killRatio = inv.spawned == 0
          ? 0
          : ((inv.spawned - left) / inv.spawned).clamp(0.0, 1.0);
      inv.reward = (full * inv.killRatio).round();
      credits += inv.reward;
      say(
        Speaker.advisor,
        tr.g_dlgInvasionRetreat((inv.killRatio * 100).round(), inv.reward),
      );
    }
  }

  // ---------- 스폰 ----------
  void _updateSpawning(double dt) {
    spawnTimer -= dt;
    jellyTimer -= dt;
    final t = threat;
    final normal = pirates
        .where((e) => e.isPirate && e.eventId == null && e.name == null)
        .length;
    final maxPirates = min(18, (2 + (t - sector) * 1.5 + sector).floor());

    // 섹터 두목: 스토리 단계이거나 위협도가 충분히 오르면 등장
    final storyWantsBoss = story.key == 'sectorBosses' && storyTimer > 12;
    if (!bossDefeated &&
        !sectorBossSpawned &&
        player.alive &&
        (storyWantsBoss || t >= 1 + sector + 3)) {
      sectorBossSpawned = true;
      final archetype = trait.bossArchetype;
      final e = _makePirate(PirateKind.boss, _spawnPos(), hpMul: 1.6)
        ..sectorBoss = true
        ..archetype = archetype
        ..archetypeTimer = switch (archetype) {
          BossArchetype.fleet => BossArchetype.escortInterval,
          BossArchetype.devourer => BossArchetype.mineInterval,
          BossArchetype.flare => BossArchetype.flareInterval,
          BossArchetype.wraith => BossArchetype.wraithPhase,
          _ => 0,
        };
      pirates.add(e);
      sfx.add(Sfx.alarm);
      say(Speaker.pirate, tr.g_pirateBossArrive(sectorName));
      say(
        Speaker.advisor,
        archetype == null
            ? tr.g_dlgBossWarning
            : tr.g_dlgBossArchetype(archetype.name),
      );
    }
    // 두목이 사라졌으면(예: 다른 곳으로 이동) 다시 등장할 수 있게
    if (sectorBossSpawned &&
        !bossDefeated &&
        !pirates.any((e) => e.sectorBoss)) {
      sectorBossSpawned = false;
    }

    // 일반 두목: 섹터 두목 격파 후 위협도 3마다
    if (bossDefeated &&
        t >= 1 + sector + (bossesSpawned + 1) * 3 &&
        player.alive) {
      bossesSpawned++;
      pirates.add(_makePirate(PirateKind.boss, _spawnPos()));
      sfx.add(Sfx.alarm);
      say(Speaker.pirate, tr.g_pirateRevenge);
    }

    // 대규모 침공 중(경보 포함)엔 일반 스폰을 멈춘다 (맵 위 과부하 방지)
    if (spawnTimer <= 0 &&
        normal < maxPirates &&
        player.alive &&
        !invasionActive) {
      spawnTimer = max(3.0, 13 - (t - sector) * 1.2) * trait.spawnIntervalMul;
      final group = 1 + _rng.nextInt(min(4, max(1, t.floor())));
      for (var i = 0; i < group; i++) {
        pirates.add(_makePirate(_randomKind(t), _spawnPos()));
      }
      if (_rng.nextDouble() < 0.3) {
        say(
          Speaker.pirate,
          [
            tr.g_pirateAmbush0,
            tr.g_pirateAmbush1,
            tr.g_pirateAmbush2,
            tr.g_pirateAmbush3,
          ][_rng.nextInt(4)],
        );
      }
    }

    if (jellyTimer <= 0) {
      jellyTimer = 40;
      if (pirates.where((e) => e.kind == PirateKind.jelly).length < 3) {
        pirates.add(
          _makePirate(PirateKind.jelly, _spawnPos())
            ..wanderAngle = _rng.nextDouble() * 2 * pi,
        );
      }
    }
  }

  PirateKind _randomKind(double t) {
    final late = lateFoeKinds(sector);
    // 후반 항성계: 항성계마다 8%씩 (최대 45%) 후반 적이 섞인다. 큰 적(모함·돌격함)은 덜 나온다
    if (late.isNotEmpty && _rng.nextDouble() < min(0.45, 0.08 * (sector - 1))) {
      final pool = [
        for (final k in late)
          ...List.filled(
            k == PirateKind.carrier || k == PirateKind.juggernaut ? 1 : 2,
            k,
          ),
      ];
      return pool[_rng.nextInt(pool.length)];
    }
    final r = _rng.nextDouble();
    if (t >= 2.5 && r < 0.15) return PirateKind.bomber;
    if (t >= 3.5 && r < 0.27) return PirateKind.sniper;
    if (r < min(0.55, 0.1 * t)) return PirateKind.raider;
    return PirateKind.scout;
  }

  Offset _spawnPos() => _clampWorld(
    player.pos +
        OffsetX.fromAngle(
          _rng.nextDouble() * 2 * pi,
          randRange(_rng, 900, 1200),
        ),
    (_) {},
  );

  /// [sector]에서 일반 스폰에 섞이는 후반 적
  static List<PirateKind> lateFoeKinds(int sector) => [
    for (final k in PirateKind.values)
      if (k.isLate && sector >= k.unlockSector) k,
  ];

  Pirate _makePirate(
    PirateKind kind,
    Offset pos, {
    double hpMul = 1,
    double dmgMul = 1,
  }) {
    if (kind.isLate && counter('foeSeen_${kind.name}') == 0) {
      // 처음 만나는 후반 적은 미나가 특징과 공략을 알려 준다
      counters['foeSeen_${kind.name}'] = 1;
      say(Speaker.advisor, tr.g_foeIntro(kind.name));
    }
    final scale = (1 + (threat - 1 - sector) * 0.15) * enemyHpMul * hpMul;
    return Pirate(
      kind,
      pos,
      Pirate.baseHp(kind) * scale,
      dmgScale: enemyDamageMul * dmgMul,
    )..wanderAngle = _rng.nextDouble() * 2 * pi;
  }

  void _updateMissions(double dt) {
    offerTimer -= dt;
    if (offerTimer <= 0) _refreshOffers();
    for (final m in [...activeMissions]) {
      if (m.type == MissionType.deliver) {
        final idx = m.planetIndex;
        if (idx != null &&
            idx < planets.length &&
            (planets[idx].pos - player.pos).distance <
                planets[idx].radius + 140 &&
            player.alive) {
          m.progress = 1;
        }
      }
      if (m.type == MissionType.bounty &&
          m.bountySpawned &&
          !m.done &&
          !pirates.any((e) => e.missionId == m.id)) {
        _spawnBounty(m);
      }
      if (m.done) _completeMission(m);
    }
  }

  void _spark(Offset pos, Color c) {
    for (var i = 0; i < 4; i++) {
      particles.add(
        Particle(
          pos,
          OffsetX.fromAngle(
            _rng.nextDouble() * 2 * pi,
            randRange(_rng, 60, 160),
          ),
          0.25,
          c,
          2,
        ),
      );
    }
  }

  void _burst(Offset pos, Color c, int n) {
    for (var i = 0; i < n; i++) {
      particles.add(
        Particle(
          pos,
          OffsetX.fromAngle(
            _rng.nextDouble() * 2 * pi,
            randRange(_rng, 40, 320),
          ),
          randRange(_rng, 0.4, 1.0),
          i.isEven ? c : const Color(0xFFFFF176),
          randRange(_rng, 2, 5),
        ),
      );
    }
  }

  // ---------- 저장/불러오기 ----------
  static Map<String, dynamic> _stationToJson(Station s) => {
    // 언어 중립 이름 키. 'name'은 예전 버전 앱 호환용 표시 이름 (불러올 때는 'nk'가 우선)
    'nk': s.label.toJson(),
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

  /// [sector]: 정거장이 있는 항성계, [order]: 목록 안 순서 (예전 저장 이름에 번호가 없을 때 쓴다)
  static Station _stationFromJson(
    Map<String, dynamic> s, {
    required int sector,
    required int order,
  }) {
    var pos = Offset((s['x'] as num).toDouble(), (s['y'] as num).toDouble());
    // 예전 저장: 본거지가 원점(지금은 항성 자리)에 있었다
    if (pos == Offset.zero) pos = homePos;
    // 예전 저장: 역할이 없으면 본거지 자리는 본거지, 나머지는 보급 기지
    final role =
        StationRole.values.where((r) => r.name == s['role']).firstOrNull ??
        (pos == homePos ? StationRole.home : StationRole.support);
    // 예전 저장은 이름이 저장 당시 언어의 문자열 → 어느 언어 기본 이름인지 찾아 키로 되돌린다
    final label =
        StationName.fromJson(s['nk']) ??
        StationName.fromLegacy(
          s['name'] as String?,
          role: role,
          sector: sector,
          fallbackNumber: order + 1,
        );
    final st = Station.named(label, pos, role: role)
      ..habitatLevel = s['hab'] as int
      ..turretLevel = s['tur'] as int
      ..baseLevel = (s['base'] as int?) ?? 1
      // 기능 정지 남은 시간도 저장한다 (불러오기로 정지를 풀 수 없게)
      ..disabledTime = (s['off'] as num?)?.toDouble() ?? 0;
    st.hp = min(st.maxHp, (s['hp'] as num?)?.toDouble() ?? st.maxHp);
    return st;
  }

  Map<String, dynamic> toJson() => {
    'v': 3,
    'seed': seed,
    'credits': credits,
    'ore': ore,
    'levels': {for (final e in levels.entries) e.key.name: e.value},
    'counters': counters,
    'sector': sector,
    'current': _saveCurrentSector().toJson(),
    'sectors': {for (final e in sectors.entries) '${e.key}': e.value.toJson()},
    'roster': roster.map((c) => c.toJson()).toList(),
    'expeditions': expeditions.map((e) => e.toJson()).toList(),
    'expClock': expeditionClock.latestMs,
    'recruits': recruitCount,
    'nextId': _nextId,
    'missions': activeMissions.map((m) => m.toJson()).toList(),
    'story': storyIndex,
    'storyBase': storyBase,
    'total': totalTime,
    'antimatterExposure': antimatterExposure.isFinite && antimatterExposure >= 0
        ? antimatterExposure
        : 0,
    'finalCounterattackSeconds': finalCounterattackSeconds,
    'finalSyncSeconds': _finalSyncSeconds.isFinite && _finalSyncSeconds >= 0
        ? _finalSyncSeconds.clamp(0.0, 20.0)
        : 0,
    'px': player.pos.dx,
    'py': player.pos.dy,
    'hp': player.hp,
    'dead': !player.alive,
    'savedAt': DateTime.now().millisecondsSinceEpoch,
  };

  static GameWorld fromJson(Map<String, dynamic> j, Profile profile) {
    final w = GameWorld(seed: j['seed'] as int, profile: profile);
    final exposure = j['antimatterExposure'];
    if (exposure is num && exposure.isFinite && exposure >= 0) {
      w.antimatterExposure = exposure.toDouble();
    }
    final sync = j['finalSyncSeconds'];
    if (sync is num && sync.isFinite && sync >= 0) {
      w._finalSyncSeconds = sync.toDouble().clamp(0.0, 20.0);
    }
    w.dialogs.clear();
    w.credits = (j['credits'] as num).toDouble();
    w.ore = (j['ore'] as num).toDouble();
    (j['levels'] as Map).forEach((k, v) {
      final kind = UpgradeKind.values.where((u) => u.name == k).firstOrNull;
      if (kind != null) w.levels[kind] = v as int;
    });
    (j['counters'] as Map).forEach(
      (k, v) => w.counters[k as String] = v as int,
    );
    (j['sectors'] as Map).forEach(
      (k, v) => w.sectors[int.parse(k as String)] = SectorSave.fromJson(
        v as Map<String, dynamic>,
      ),
    );
    w._loadSector(
      j['sector'] as int,
      SectorSave.fromJson(j['current'] as Map<String, dynamic>),
    );
    if (!(j['counters'] as Map).containsKey('campaignGameplayVersion')) {
      final highest = max(w.sector, w.counter('maxSector'));
      for (final chapter in campaignSectors.where(
        (s) => s < campaignFinalSector,
      )) {
        if (chapter < highest || w.counter('campaignSector_$chapter') == 2) {
          w.counters['campaignDone_$chapter'] = 1;
        } else {
          w.counters.remove('campaignSector_$chapter');
        }
      }
    }
    if (!w.counters.containsKey('finalMissionStage') &&
        (w.sector >= campaignFinalSector ||
            w.counter('maxSector') >= campaignFinalSector)) {
      w.counters['finalMissionStage'] = FinalMissionStage.stabilize.index;
    }
    if (!w.counters.keys.any((k) => k.startsWith('campaignSector_'))) {
      final highest = max(w.sector, w.counter('maxSector'));
      for (final chapter in campaignSectors) {
        if (chapter < highest) w.counters['campaignSector_$chapter'] = 2;
      }
      if (w.sector == campaignFinalSector &&
          w.counter('campaignSector_${w.sector}') == 0) {
        w._queueCampaignSector(w.sector);
      }
    }
    if (w.finalMissionStage == FinalMissionStage.complete) {
      final remaining = j['finalCounterattackSeconds'];
      if (remaining is num && remaining.isFinite && remaining > 0) {
        w.finalCounterattackSeconds = remaining.toDouble().clamp(0, 3);
      } else if (w.counter('storyScene_ending') == 0) {
        w._queueStoryScene(StoryScene.ending);
      }
    }
    // 이전 저장에는 장면 키가 없다. 이미 이룬 첫 사건은 다시 재생하지 않는다.
    if (!w.counters.containsKey('storyScene_mars') &&
        (w.counter('colonies') > 0 ||
            w.planets.any((p) => p.colonyLevel > 0) ||
            w.sectors.values.any(
              (s) => s.colonyLevels.any((level) => level > 0),
            ))) {
      w.counters['storyScene_mars'] = 2;
    }
    if (!w.counters.containsKey('storyScene_firstTransmission') &&
        (w.planets.any((p) => p.building(ColonyBuilding.stabilizer) > 0) ||
            w.sectors.values.any((s) => s.development > 0))) {
      w.counters['storyScene_firstTransmission'] = 2;
    }
    for (final c in (j['roster'] as List).cast<Map<String, dynamic>>()) {
      w.roster.add(CrewMember.fromJson(c));
    }
    w.recruitCount = j['recruits'] as int;
    w._nextId = j['nextId'] as int;
    // 원정 (없으면 빈 목록). 명단에 없는 승무원의 원정은 버린다
    final clock = j['expClock'];
    if (clock is int) w.expeditionClock.latestMs = clock;
    for (final e in (j['expeditions'] as List?) ?? const []) {
      final x = Expedition.fromJson(e);
      if (x != null && w.roster.any((c) => c.id == x.crewId && !c.assigned)) {
        w.expeditions.add(x);
      }
    }
    w.player.pos = Offset(
      (j['px'] as num).toDouble(),
      (j['py'] as num).toDouble(),
    );
    for (final m in (j['missions'] as List).cast<Map<String, dynamic>>()) {
      final mission = Mission.fromJson(m);
      w.activeMissions.add(mission);
      if (mission.type == MissionType.bounty) w._spawnBounty(mission);
    }
    w.storyIndex = j['story'] as int;
    w.storyBase = j['storyBase'] as int;
    // 예전 저장 호환: 진행 중인 단계의 측정 키가 바뀌었으면(kills → shipKills) 기준점이 현재값보다 클 수 있다
    final cur = w.storyValue(w.story.key);
    if (w.story.relative && w.storyBase > cur) w.storyBase = cur;
    w.totalTime = (j['total'] as num).toDouble();
    w.player.pos = Offset(
      (j['px'] as num).toDouble(),
      (j['py'] as num).toDouble(),
    );
    w.player.hp = min(
      w.playerMaxHp,
      (j['hp'] as num?)?.toDouble() ?? w.playerMaxHp,
    );
    if (j['dead'] == true) {
      // 격추된 채 저장했으면 부활 선택부터 (저장/불러오기로 공짜 부활 방지)
      w.player
        ..alive = false
        ..awaitingRevive = true
        ..deadTime = 0
        ..deathPos = w.player.pos;
    }
    // 예전 저장 호환: 이미 쓰러뜨린 섹터 두목 수
    final defeated =
        (w.bossDefeated ? 1 : 0) +
        w.sectors.values.where((e) => e.bossDefeated).length;
    if (w.counter('sectorBosses') < defeated) {
      w.counters['sectorBosses'] = defeated;
    }
    w.savedAt = DateTime.fromMillisecondsSinceEpoch(j['savedAt'] as int);
    if (w.pendingStoryScene == StoryScene.mars && !profile.colonyTutorialSeen) {
      w.colonyTutorialPending = true;
    }
    w.say(Speaker.advisor, tr.g_dlgWelcomeBack(w.story.title));
    return w;
  }
}
