import 'dart:math';
import 'dart:ui';

extension OffsetX on Offset {
  Offset normalized() {
    final d = distance;
    return d == 0 ? Offset.zero : this / d;
  }

  Offset clampLength(double max) {
    final d = distance;
    return d > max ? this * (max / d) : this;
  }

  static Offset fromAngle(double a, [double len = 1]) =>
      Offset(cos(a) * len, sin(a) * len);
}

double randRange(Random r, double a, double b) => a + r.nextDouble() * (b - a);

/// 각도 차이를 -pi..pi 로 정규화
double angleDiff(double a, double b) {
  var d = (b - a) % (2 * pi);
  if (d > pi) d -= 2 * pi;
  if (d < -pi) d += 2 * pi;
  return d;
}

typedef Cost = (int credits, int ore);

class PlayerShip {
  Offset pos = Offset.zero;
  Offset vel = Offset.zero;
  double angle = -pi / 2;
  double hp = 100;
  double fireCooldown = 0;
  double invulnerable = 0;
  bool thrusting = false;
  bool alive = true;

  /// 격추 후 부활 방식 선택 대기 중
  bool awaitingRevive = false;
  double deadTime = 0;
  Offset deathPos = Offset.zero;

  double missileCooldown = 0;
  double shieldCooldown = 0;
  double boostCooldown = 0;
  double shieldTime = 0;

  /// 마지막 피격 후 지난 시간 (자가 수리 함선용)
  double sinceHit = 0;

  /// 함선 수호막 재충전까지 남은 시간 (0이면 준비됨)
  double guardCooldown = 0;
}

enum PirateKind { scout, raider, bomber, sniper, boss, jelly }

class Pirate {
  Pirate(this.kind, this.pos, this.hp, {this.name, this.dmgScale = 1})
      : maxHp = hp;

  final PirateKind kind;
  Offset pos;
  Offset vel = Offset.zero;
  double angle = 0;
  double hp;
  final double maxHp;
  final double dmgScale;
  double fireCooldown = 1.5;
  double wanderAngle = 0;
  double hitFlash = 0;
  double contactCooldown = 0;

  /// 현상수배범 / 섹터 두목 이름
  final String? name;
  bool sectorBoss = false;

  /// 두목 패턴: 체력 절반 이하 2페이즈, 특수 공격 타이머
  bool enraged = false;
  double specialTimer = 5;
  int? missionId;
  int? eventId;

  bool get isPirate => kind != PirateKind.jelly;
  bool get isBossLike => kind == PirateKind.boss;

  double get radius => switch (kind) {
        PirateKind.scout => 18,
        PirateKind.raider => 24,
        PirateKind.bomber => 20,
        PirateKind.sniper => 20,
        PirateKind.boss => 46,
        PirateKind.jelly => 34,
      } *
      (name != null && kind != PirateKind.boss ? 1.3 : 1);

  double get speed => switch (kind) {
        PirateKind.scout => 290,
        PirateKind.raider => 210,
        PirateKind.bomber => 330,
        PirateKind.sniper => 190,
        PirateKind.boss => 150,
        PirateKind.jelly => 60,
      };

  double get damage =>
      dmgScale *
      switch (kind) {
        PirateKind.scout => 6,
        PirateKind.raider => 10,
        PirateKind.bomber => 34,
        PirateKind.sniper => 22,
        PirateKind.boss => 16,
        PirateKind.jelly => 9,
      };

  double get fireInterval => switch (kind) {
        PirateKind.scout => 1.1,
        PirateKind.raider => 1.4,
        PirateKind.bomber => 99,
        PirateKind.sniper => 2.6,
        PirateKind.boss => 0.9,
        PirateKind.jelly => 99,
      };

  int get bounty => switch (kind) {
        PirateKind.scout => 25,
        PirateKind.raider => 50,
        PirateKind.bomber => 40,
        PirateKind.sniper => 60,
        PirateKind.boss => 400,
        PirateKind.jelly => 30,
      };

  static double baseHp(PirateKind k) => switch (k) {
        PirateKind.scout => 30,
        PirateKind.raider => 70,
        PirateKind.bomber => 35,
        PirateKind.sniper => 45,
        PirateKind.boss => 450,
        PirateKind.jelly => 120,
      };
}

class Bullet {
  Bullet(this.pos, this.vel, this.damage, this.fromPlayer,
      {this.life = 1.2, this.big = false, this.pierce = 0});
  Offset pos;
  final Offset vel;
  final double damage;
  final bool fromPlayer;
  final bool big;
  double life;

  /// 남은 관통 횟수. 관통한 적은 [hits]에 기록해 같은 적을 두 번 맞히지 않는다.
  int pierce;
  Set<Pirate>? hits;
}

class Missile {
  Missile(this.pos, this.vel, this.damage);
  Offset pos;
  Offset vel;
  final double damage;
  double life = 3.5;
  Pirate? target;
}

class Asteroid {
  Asteroid(this.pos, this.radius, int seed, {this.crystal = false})
      : hp = radius * 1.5,
        rotation = 0,
        spin = (Random(seed).nextDouble() - 0.5) * 0.8,
        shape = List.generate(
            9, (i) => 0.75 + Random(seed + i * 31).nextDouble() * 0.35);
  Offset pos;
  Offset drift = Offset.zero;
  final double radius;
  final bool crystal;
  double hp;
  double rotation;
  final double spin;
  final List<double> shape;
  double hitFlash = 0;
}

enum PickupKind { credits, ore, gem, power }

enum PowerUpKind { rapid, shield, magnet, doubleCredits }

extension PowerUpInfo on PowerUpKind {
  String get icon => switch (this) {
        PowerUpKind.rapid => '⚡',
        PowerUpKind.shield => '🛡',
        PowerUpKind.magnet => '🧲',
        PowerUpKind.doubleCredits => '💰',
      };
  String get label => switch (this) {
        PowerUpKind.rapid => '연사',
        PowerUpKind.shield => '실드',
        PowerUpKind.magnet => '자석',
        PowerUpKind.doubleCredits => '크레딧 2배',
      };
  double get duration => switch (this) {
        PowerUpKind.rapid => 8,
        PowerUpKind.shield => 6,
        PowerUpKind.magnet => 15,
        PowerUpKind.doubleCredits => 20,
      };
}

class Pickup {
  Pickup(this.kind, this.pos, this.amount, this.vel, {this.power});
  final PickupKind kind;
  final PowerUpKind? power;
  Offset pos;
  Offset vel;
  final int amount;
  double life = lifetime;

  /// 떨어진 아이템은 이 시간 뒤 사라지고, 마지막 [blinkTime]초는 깜빡인다
  static const lifetime = 15.0;
  static const blinkTime = 4.0;
}

class Particle {
  Particle(this.pos, this.vel, this.life, this.color, this.size)
      : maxLife = life;
  Offset pos;
  Offset vel;
  double life;
  final double maxLife;
  final Color color;
  final double size;
}

class FloatText {
  FloatText(this.pos, this.text, this.color, {this.big = false});
  Offset pos;
  final String text;
  final Color color;
  final bool big;
  double life = 1.0;
}

enum PlanetKind { garden, desert, ice, lava, gas }

/// 항성(섹터 중심, 원점)을 도는 행성
class Planet {
  Planet(this.name, this.radius, this.kind, {required this.orbitRadius, required this.orbitPhase});
  final String name;
  final double radius;
  final PlanetKind kind;

  /// 공전 궤도 반지름과 t=0일 때의 각도
  final double orbitRadius;
  final double orbitPhase;

  /// 현재 위치 ([placeOnOrbit]이 갱신)
  Offset pos = Offset.zero;

  /// 가장 안쪽 궤도(1350)가 한 바퀴 15분, 바깥일수록 느리다 (케플러 법칙 비슷하게)
  double get orbitSpeed => 2 * pi / (900 * pow(orbitRadius / 1350, 1.5));

  /// 섹터 경과 시간 [t]초일 때 궤도 위치로 옮긴다
  void placeOnOrbit(double t) => pos = OffsetX.fromAngle(orbitPhase + orbitSpeed * t, orbitRadius);

  int colonyLevel = 0;

  /// 해적 습격 중이면 생산 중단
  bool raided = false;

  // ---------- 방어막 돔 (모든 식민지 기본 장비) ----------
  /// 남은 방어막 내구도. 탄을 막을 때마다 깎이고, 안 맞으면 다시 찬다.
  double shieldHp = 0;

  /// 마지막 피격 후 지난 시간
  double sinceShieldHit = 99;

  /// 깨진 뒤 재가동 대기 중
  bool shieldBroken = false;

  double shieldMax(double sectorMul) =>
      (200 + 100 * colonyLevel + 250 * building(ColonyBuilding.shieldGen)) * sectorMul;

  /// 초당 재충전량 (안 맞은 지 [shieldRegenDelay]초 뒤부터)
  double shieldRegen(double sectorMul) =>
      shieldMax(sectorMul) * (0.08 + 0.03 * building(ColonyBuilding.shieldGen));
  static const shieldRegenDelay = 4.0;

  /// 깨진 방어막은 이 비율까지 차야 다시 켜진다
  static const shieldRebootRatio = 0.5;

  bool get domeUp => colonyLevel > 0 && !shieldBroken && shieldHp > 0;
  double get domeRadius => radius + 220;

  static const maxLevel = 5;

  String get kindLabel => switch (kind) {
        PlanetKind.garden => '정원 행성',
        PlanetKind.desert => '사막 행성',
        PlanetKind.ice => '얼음 행성',
        PlanetKind.lava => '용암 행성',
        PlanetKind.gas => '가스 행성',
      };

  /// 레벨당 초당 생산량
  (double credits, double ore) get ratePerLevel => switch (kind) {
        PlanetKind.garden => (3.0, 0.0),
        PlanetKind.desert => (2.0, 0.6),
        PlanetKind.ice => (1.5, 1.0),
        PlanetKind.lava => (0.5, 2.0),
        PlanetKind.gas => (4.0, 0.0),
      };

  Cost baseCost() {
    final base = kind == PlanetKind.gas ? 220 : 150;
    return (
      (base * pow(1.8, colonyLevel)).round(),
      colonyLevel == 0 ? 0 : 40 * colonyLevel,
    );
  }

  // ---------- 식민지 건물 ----------
  final buildings = {for (final b in ColonyBuilding.values) b: 0};
  double turretCooldown = 0;

  int building(ColonyBuilding b) => buildings[b]!;

  /// 건물 레벨은 식민지 레벨을 넘을 수 없다
  int get buildingCap => colonyLevel;

  double get turretRange => radius + 320 + building(ColonyBuilding.turret) * 30;
  double get turretDamage => 5 + building(ColonyBuilding.turret) * 4;
  double get turretInterval => 1.0 / (1 + building(ColonyBuilding.turret) * 0.2);
  double get dockRange => radius + 240;
  double get dockHealRate => 6 + building(ColonyBuilding.dock) * 6;

  /// 섹터 배율·보너스 적용 전 초당 생산량
  double get baseCreditRate =>
      ratePerLevel.$1 * colonyLevel * (1 + 0.25 * building(ColonyBuilding.trade));
  double get baseOreRate =>
      ratePerLevel.$2 * colonyLevel + 0.8 * building(ColonyBuilding.mine);

  Cost buildingBaseCost(ColonyBuilding b) {
    final lv = building(b);
    final (credits, ore) = switch (b) {
      ColonyBuilding.turret => (180, 50),
      ColonyBuilding.mine => (140, 20),
      ColonyBuilding.trade => (200, 40),
      ColonyBuilding.dock => (160, 30),
      ColonyBuilding.shieldGen => (220, 60),
    };
    return ((credits * pow(1.7, lv)).round(), ore * (lv + 1));
  }
}

/// 저장 형식이 index 순서라 새 건물은 끝에만 추가한다
enum ColonyBuilding { turret, mine, trade, dock, shieldGen }

extension ColonyBuildingInfo on ColonyBuilding {
  String get label => switch (this) {
        ColonyBuilding.turret => '방어포탑',
        ColonyBuilding.mine => '채굴 시설',
        ColonyBuilding.trade => '교역소',
        ColonyBuilding.dock => '수리 도크',
        ColonyBuilding.shieldGen => '방어막 발생기',
      };
  String get icon => switch (this) {
        ColonyBuilding.turret => '🔫',
        ColonyBuilding.mine => '⛏',
        ColonyBuilding.trade => '🏪',
        ColonyBuilding.dock => '🔧',
        ColonyBuilding.shieldGen => '🛡',
      };
  String get blurb => switch (this) {
        ColonyBuilding.turret => '식민지 근처 해적을 자동으로 요격해요. 습격 방어에 필수!',
        ColonyBuilding.mine => '광석을 캐서 매초 💎를 보내줘요.',
        ColonyBuilding.trade => '이 식민지의 크레딧 수입을 25%씩 늘려요.',
        ColonyBuilding.dock => '근처에 있으면 함선 체력을 회복해요.',
        ColonyBuilding.shieldGen => '방어막 용량과 충전 속도를 늘려요.',
      };
}

/// 정거장 역할. 본거지는 섹터마다 하나(레이저·안전 구역), 나머지는 지을 때 고른다.
enum StationRole { home, defense, repair, support }

extension StationRoleInfo on StationRole {
  String get label => switch (this) {
        StationRole.home => '본거지',
        StationRole.defense => '방어 기지',
        StationRole.repair => '수리 기지',
        StationRole.support => '보급 기지',
      };
  String get iconAsset => switch (this) {
        StationRole.home => 'act_station',
        StationRole.defense => 'st_turret',
        StationRole.repair => 'b_dock',
        StationRole.support => 'b_trade',
      };
  String get blurb => switch (this) {
        StationRole.home => '레이저 포대와 안전 구역',
        StationRole.defense => '강한 포탑 · 내구도 2배 · 주변 적 탄환 차단',
        StationRole.repair => '넓은 범위 빠른 수리 · 재출격 비용 10% · 근처 식민지 방어막 충전 2배',
        StationRole.support => '근처 식민지 생산 +25% (거주구역 레벨마다 +5%)',
      };
}

class Station {
  Station(this.name, this.pos, {this.role = StationRole.support});
  final String name;
  final Offset pos;
  final StationRole role;
  int habitatLevel = 1;
  int turretLevel = 0;
  double hp = 300;
  double turretCooldown = 0;
  double spin = 0;

  /// 본거지 강화 단계 (본거지만 쓴다, 1..[maxBaseLevel]). 저장 키 'base'
  int baseLevel = 1;

  /// >0 이면 본거지 기능 정지 남은 시간(초): 레이저·안전 구역 꺼짐
  double disabledTime = 0;

  /// 마지막 피격 뒤 지난 시간(초) — 본거지 재생 대기용
  double sinceHit = 99;

  static const maxLevel = 6;
  static const maxBaseLevel = 10;
  bool get isDefense => role == StationRole.defense;
  bool get isHome => role == StationRole.home;
  bool get disabled => disabledTime > 0;

  /// 본거지는 기본 +500, 강화 단계마다 +400 (Lv.1 거주1 = 800 → Lv.10 = 4400)
  double get maxHp =>
      (200 + habitatLevel * 100) * (isDefense ? 2 : 1) + (isHome ? 500 + (baseLevel - 1) * 400 : 0);

  // ---- 본거지 강화 효과 (Lv.1 → Lv.10) ----
  /// 레이저 한 발 피해 150 → 690 (+40%/단계). 섹터 배율이 없어서
  /// 알파 성역 Lv.1은 정찰기·약탈선을 한 방에, 후반 섹터는 강화해야 한 방이 된다
  double get laserDamage => 150 * (1 + 0.4 * (baseLevel - 1));

  /// 레이저 발사 간격 0.22초 → 0.141초 (-4%/단계)
  double get laserInterval => 0.22 * (1 - 0.04 * (baseLevel - 1));

  /// 레이저 사거리 900 → 1260 (+40/단계)
  double get laserRange => 900 + 40.0 * (baseLevel - 1);

  /// 안전 구역 반경 520 → 655 (+15/단계)
  double get safeRadius => 520 + 15.0 * (baseLevel - 1);

  /// 피격 없이 [regenDelay]초 지나면 초당 최대 체력의 1% → 2.8% 재생
  double get baseRegenRatio => 0.01 + 0.002 * (baseLevel - 1);
  static const regenDelay = 4.0;

  /// 강화 비용: 💰1200×1.9^(Lv-1), 광석 200×1.7^(Lv-1) (Lv.9→10 💰≈204k)
  Cost get baseUpgradeCost =>
      ((1200 * pow(1.9, baseLevel - 1)).round(), (200 * pow(1.7, baseLevel - 1)).round());

  void takeHit(double dmg) {
    hp -= dmg;
    sinceHit = 0;
  }

  double get baseCreditRate => habitatLevel * 2.0;
  double get turretRange => 380 + turretLevel * 30 + (isDefense ? 150 : 0);
  double get turretDamage => (6 + turretLevel * 4) * (isDefense ? 1.6 : 1);
  double get turretInterval => 0.9 / (1 + turretLevel * 0.2) * (isDefense ? 0.7 : 1);

  /// 방어 기지: 이 반경에 들어온 적 탄환을 없앤다
  double get guardRange => isDefense ? 320 : 0;

  /// 이 반경 안에서 함선 체력이 [repairRate]/초씩 찬다
  double get repairRange => role == StationRole.repair ? 650 : 220;
  double get repairRate => role == StationRole.repair ? 45 : 20;

  /// 수리 기지: 이 반경 안 식민지 방어막이 두 배로 빨리 찬다
  static const shieldAssistRange = 1500.0;

  /// 보급 기지: 이 반경 안 식민지 생산 보너스
  static const supportRange = 1800.0;
  double get supportBonus => role == StationRole.support ? 0.25 + 0.05 * (habitatLevel - 1) : 0;

  Cost get habitatCost =>
      ((250 * pow(1.7, habitatLevel - 1)).round(), 60 * habitatLevel);
  Cost get turretCost =>
      ((200 * pow(1.7, turretLevel)).round(), 80 * (turretLevel + 1));
}

/// 본거지 레이저 한 줄기 (그리기용)
class LaserBeam {
  LaserBeam(this.from, this.to);
  final Offset from;
  final Offset to;
  double life = LaserBeam.duration;
  static const duration = 0.18;
}

class WarpGate {
  WarpGate(this.pos, this.forward);
  final Offset pos;
  final bool forward;
}

enum EventKind { raid, meteor, merchant, supply }

class WorldEvent {
  WorldEvent(this.id, this.kind, this.pos, this.timeLeft, {this.planet});
  final int id;
  final EventKind kind;
  Offset pos;
  double timeLeft;
  final Planet? planet;
  bool finished = false;

  String get title => switch (kind) {
        EventKind.raid => '🏴‍☠️ ${planet?.name ?? ''} 습격',
        EventKind.meteor => '☄ 유성우',
        EventKind.merchant => '🛒 떠돌이 상인',
        EventKind.supply => '📦 보급 캡슐',
      };
}

enum Speaker { captain, pirate, advisor, merchant }

class DialogLine {
  DialogLine(this.speaker, this.text);
  final Speaker speaker;
  final String text;
  double time = 4;
}

enum Sfx { shoot, hit, explode, bigExplode, pickup, coin, gem, upgrade, alarm, warp, missile, shield, boost, hurt }
