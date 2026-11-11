/// 행성 지표 탐험 (surface-exploration): 행성에 내려 2~3분 동안 탐사 차량으로 지점을 돌고 착륙선으로 돌아온다.
///
/// 이 파일은 화면·월드와 무관한 순수 규칙만 둔다 — 지도 생성(시드 결정), 지점, 위험 지대, 생물 종류, 보상 기준값, 기록, 유물.
/// 전투는 기존 엔진을 그대로 쓴다 ([SurfaceWorld], world.dart의 part 파일 surface_world.dart).
library;

import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'models.dart' show OffsetX, PirateKind, PlanetKind, randRange;

// ---------------------------------------------------------------- 시드

/// 같은 행성 = 같은 지형. (게임 시드, 항성계, 행성 번호) → 0..2^31-1
int surfaceSeed(int worldSeed, int sector, int planetIndex) {
  var x = (worldSeed * 0x9E3779B1 + sector * 0x85EBCA77 + planetIndex * 0xC2B2AE3D + 0x27d4eb2f) & 0xffffffff;
  x ^= x >> 16;
  x = (x * 0x7feb352d) & 0xffffffff;
  x ^= x >> 15;
  x = (x * 0x846ca68b) & 0xffffffff;
  x ^= x >> 16;
  return x & 0x7fffffff;
}

/// 로컬 날짜 yyyymmdd (하루 온전 보상 횟수용). [now]는 기기 시각(DateTime.now())을 넘긴다.
int surfaceDayKey(DateTime now) => now.year * 10000 + now.month * 100 + now.day;

// ---------------------------------------------------------------- 지점

enum SurfaceSiteKind {
  /// 유적: 반경 안에 [SurfaceRules.ruinSeconds]초 머물면 발굴 (유물 확률)
  ruin,

  /// 추락선 잔해: 닿아서 [SurfaceRules.wreckSeconds]초 — 화물 상자
  wreck,

  /// 에일리언 둥지: 체력이 있는 고정 구조물. 살아 있는 동안 기는 것을 낳는다
  nest,

  /// 희귀 광맥: 반경 안에 [SurfaceRules.veinSeconds]초 머물면 채굴
  vein,
}

/// 탐사 지점 하나 (판 진행 상태 포함)
class SurfaceSite {
  SurfaceSite(this.kind, this.pos) : hp = 0, maxHp = 0;

  final SurfaceSiteKind kind;
  final Offset pos;

  /// 머물기 진행(초). 벗어나면 멈추고 (되돌아가지 않는다) 다시 들어오면 이어진다.
  double progress = 0;
  bool done = false;

  /// 둥지 체력 (둥지만)
  double hp;
  double maxHp;

  /// 머물기 판정 반경 (둥지는 구조물 반경)
  double get radius => switch (kind) {
    SurfaceSiteKind.ruin => 120,
    SurfaceSiteKind.wreck => 90,
    SurfaceSiteKind.nest => 62,
    SurfaceSiteKind.vein => 110,
  };

  /// 끝내는 데 필요한 머물기 시간 (둥지는 0 — 부숴야 끝)
  double get need => switch (kind) {
    SurfaceSiteKind.ruin => SurfaceRules.ruinSeconds,
    SurfaceSiteKind.wreck => SurfaceRules.wreckSeconds,
    SurfaceSiteKind.vein => SurfaceRules.veinSeconds,
    SurfaceSiteKind.nest => 0,
  };

  /// 0..1 (둥지는 깎인 체력 비율)
  double get ratio => done
      ? 1.0
      : kind == SurfaceSiteKind.nest
      ? (maxHp <= 0 ? 0.0 : (1 - hp / maxHp).clamp(0.0, 1.0))
      : (progress / need).clamp(0.0, 1.0);

  /// assets/sprites 그림 이름
  String get sprite => 'srf_${kind.name}';
}

/// 원형 장애물 (차량·생물·탄을 모두 막는다)
class SurfaceObstacle {
  const SurfaceObstacle(this.pos, this.radius, this.variant);
  final Offset pos;
  final double radius;

  /// 그림 변형 (회전·모양 흔들기용)
  final int variant;
}

/// 원형 위험 지대
class SurfaceHazard {
  const SurfaceHazard(this.pos, this.radius);
  final Offset pos;
  final double radius;
}

/// 행성 종류별 위험 지대 효과
class HazardEffect {
  const HazardEffect({required this.dps, required this.slow});

  /// 초당 피해 (방어막이면 막힌다)
  final double dps;

  /// 속도 배율 (1이면 감속 없음)
  final double slow;
}

HazardEffect hazardEffectOf(PlanetKind kind) => switch (kind) {
  PlanetKind.garden => const HazardEffect(dps: 3, slow: 0.7), // 포자 늪
  PlanetKind.desert => const HazardEffect(dps: 0, slow: 0.45), // 유사
  PlanetKind.ice => const HazardEffect(dps: 2, slow: 0.6), // 냉기 분출구
  PlanetKind.lava => const HazardEffect(dps: 8, slow: 1), // 용암 웅덩이
  PlanetKind.gas => const HazardEffect(dps: 0, slow: 1),
};

// ---------------------------------------------------------------- 생물

/// 지표 생물. 기존 적 엔진([PirateKind] 동작)을 그대로 쓰고 그림만 바꾼다.
enum CreatureKind {
  /// 기는 것: 빠른 근접 (정찰기 동작)
  crawler,

  /// 침 뱉는 것: 원거리 (저격선 동작)
  spitter,

  /// 덩치: 느리고 단단함 (습격선 동작, 용암 행성은 돌격함)
  brute,
}

PirateKind pirateKindOf(CreatureKind c, PlanetKind planet) => switch (c) {
  CreatureKind.crawler => PirateKind.scout,
  CreatureKind.spitter => PirateKind.sniper,
  CreatureKind.brute => planet == PlanetKind.lava ? PirateKind.juggernaut : PirateKind.raider,
};

/// 엔진 적 종류 → 생물 종류 (그리기용). 생물이 아닌 종류는 null
CreatureKind? creatureOf(PirateKind k) => switch (k) {
  PirateKind.scout => CreatureKind.crawler,
  PirateKind.sniper => CreatureKind.spitter,
  PirateKind.raider || PirateKind.juggernaut => CreatureKind.brute,
  _ => null,
};

/// 무작위 생물 (기는 것 50%, 침 25%, 덩치 25%)
CreatureKind randomCreature(Random r) {
  final x = r.nextDouble();
  return x < 0.5
      ? CreatureKind.crawler
      : x < 0.75
      ? CreatureKind.spitter
      : CreatureKind.brute;
}

// ---------------------------------------------------------------- 규칙 상수

abstract final class SurfaceRules {
  /// 지도 한 변
  static const mapSize = 2600.0;

  /// 산소 (초)와 경고 시점
  static const oxygenSeconds = 150.0;
  static const oxygenWarn = 30.0;

  static const ruinSeconds = 4.0;
  static const wreckSeconds = 1.0;
  static const veinSeconds = 3.0;

  /// 착륙선 귀환 반경
  static const landerRadius = 170.0;

  /// 지점·착륙선 주변 장애물 금지 반경
  static const clearRadius = 260.0;

  /// 둥지: 체력(× 적 체력 배율), 생물 낳기 간격·수·상한, 낳기 시작하는 거리
  static const nestHp = 700.0;
  static const nestInterval = 6.0;
  static const nestBrood = 2;
  static const nestMaxBrood = 8;
  static const nestWakeDistance = 1500.0;

  /// 유적 발굴을 시작하면 몰려오는 생물 수 (3~4)
  static const ruinAmbushMin = 3;
  static const ruinAmbushMax = 4;

  /// 산소 경고 때 몰려오는 생물, 그 뒤 [pressureInterval]초마다 [pressureCount]마리, 지도 위 생물 상한
  static const warnAmbush = 4;
  static const pressureInterval = 8.0;
  static const pressureCount = 2;
  static const maxCreatures = 18;

  /// 생물 공격력은 같은 항성계 해적의 이 비율 (해적 함선보다 약하고, 차량은 기지 수리를 못 받는다)
  static const creatureDamageMul = 0.45;

  /// 용암 행성 돌격함 동작 덩치의 동시 상한
  static const maxHeavy = 1;

  /// 착륙선 반경 안에서 차량 수리 (초당 최대 체력 비율)
  static const landerRepair = 0.12;

  /// 시작 때 생물은 착륙선에서 이만큼 떨어져 있다
  static const startCreatureDistance = 900.0;

  /// 배회하는 생물이 차량을 알아채는 거리 (몰려온 생물·맞은 생물은 멀리서도 쫓는다)
  static const aggroRange = 550.0;

  /// 시작 때 배회하는 생물 수 (8~12)
  static const startCreaturesMin = 8;
  static const startCreaturesMax = 12;

  /// 지표에서는 차량이 함선보다 느리다 (지도 한 변을 건너는 데 약 20초, 강화 비율은 그대로)
  static const roverSpeedMul = 0.5;

  /// 비상 귀환(산소 소진·중간에 나가기)·격추 때 남기는 전리품 비율
  static const partialKeep = 0.5;

  /// 하루 온전 보상 횟수, 그 뒤 비율
  static const fullRunsPerDay = 3;
  static const reducedRatio = 0.3;

  /// 완전 탐사(행성당 처음 한 번) 젬
  static const surveyGems = 3;

  /// 유물: 유적 하나당 확률, 연속 꽝 [relicPity]번이면 다음은 확정
  static const relicChance = 0.35;
  static const relicPity = 3;
}

/// 전리품 기준값 (크레딧은 메인 월드 rewardMul, 광석은 sectorMul을 곱한다).
/// 한 판 모두 끝내고 귀환하면 첫 항성계 기준 약 1,500💰 + 440광석 — 같은 항성계 본 게임 약 2분 수입 (test/surface_test.dart).
abstract final class SurfaceLoot {
  static const ruinCredits = 300;
  static const wreckCredits = 260;
  static const wreckOre = 60;
  static const nestCredits = 220;
  static const nestOre = 160;
  static const veinCredits = 60;
  static const veinOre = 220;

  static int killCredits(CreatureKind c) => switch (c) {
    CreatureKind.crawler => 8,
    CreatureKind.spitter => 12,
    CreatureKind.brute => 20,
  };

  /// 지점 하나의 (크레딧, 광석) 기준값
  static (int, int) site(SurfaceSiteKind k) => switch (k) {
    SurfaceSiteKind.ruin => (ruinCredits, 0),
    SurfaceSiteKind.wreck => (wreckCredits, wreckOre),
    SurfaceSiteKind.nest => (nestCredits, nestOre),
    SurfaceSiteKind.vein => (veinCredits, veinOre),
  };
}

// ---------------------------------------------------------------- 지도

/// 한 행성의 지표 지도. 같은 시드면 늘 같다. 지점 진행 상태는 [SurfaceSite]에 담기므로 판마다 새로 만든다.
class SurfaceMap {
  SurfaceMap._(this.seed, this.kind, this.lander, this.sites, this.obstacles, this.hazards);

  final int seed;
  final PlanetKind kind;
  final Offset lander;
  final List<SurfaceSite> sites;
  final List<SurfaceObstacle> obstacles;
  final List<SurfaceHazard> hazards;

  static const size = SurfaceRules.mapSize;
  static const _edge = 200.0;

  Offset get center => const Offset(size / 2, size / 2);

  HazardEffect get hazardEffect => hazardEffectOf(kind);

  factory SurfaceMap.generate(int seed, PlanetKind kind) {
    final r = Random(seed);
    const c = Offset(size / 2, size / 2);
    final lander = c + OffsetX.fromAngle(r.nextDouble() * 2 * pi, randRange(r, 420, 720));

    bool inside(Offset p, double m) => p.dx >= m && p.dy >= m && p.dx <= size - m && p.dy <= size - m;

    // 지점: 착륙선에서 700~1500, 서로 650 이상
    const kinds = [
      SurfaceSiteKind.ruin,
      SurfaceSiteKind.ruin,
      SurfaceSiteKind.wreck,
      SurfaceSiteKind.nest,
      SurfaceSiteKind.vein,
    ];
    final sites = <SurfaceSite>[];
    for (final k in kinds) {
      Offset? pos;
      for (var t = 0; t < 400 && pos == null; t++) {
        final relax = t ~/ 100; // 못 찾으면 조건을 조금씩 푼다
        final p = lander + OffsetX.fromAngle(r.nextDouble() * 2 * pi, randRange(r, 700 - relax * 80, 1500 + relax * 60));
        if (!inside(p, _edge)) continue;
        if (sites.any((s) => (s.pos - p).distance < 650 - relax * 70)) continue;
        pos = p;
      }
      pos ??= Offset(randRange(r, _edge, size - _edge), randRange(r, _edge, size - _edge));
      sites.add(SurfaceSite(k, pos));
    }

    // 장애물 25~40개: 지점·착륙선 주변 [clearRadius] 밖, 서로 겹치지 않게 (사이로 지나갈 틈)
    final clear = [lander, for (final s in sites) s.pos];
    final obstacles = <SurfaceObstacle>[];
    final want = 25 + r.nextInt(16);
    for (var t = 0; t < 3000 && obstacles.length < want; t++) {
      final rad = randRange(r, 40, 100);
      final p = Offset(randRange(r, 80, size - 80), randRange(r, 80, size - 80));
      if (clear.any((q) => (q - p).distance < SurfaceRules.clearRadius + rad)) continue;
      if (obstacles.any((o) => (o.pos - p).distance < o.radius + rad + 60)) continue;
      obstacles.add(SurfaceObstacle(p, rad, r.nextInt(1 << 16)));
    }

    // 위험 지대 6~10개: 착륙선·지점은 덮지 않는다
    final hazards = <SurfaceHazard>[];
    final wantH = 6 + r.nextInt(5);
    for (var t = 0; t < 2000 && hazards.length < wantH; t++) {
      final rad = randRange(r, 110, 200);
      final p = Offset(randRange(r, 150, size - 150), randRange(r, 150, size - 150));
      if ((p - lander).distance < SurfaceRules.landerRadius + rad + 120) continue;
      if (sites.any((s) => (s.pos - p).distance < s.radius + rad + 60)) continue;
      if (hazards.any((h) => (h.pos - p).distance < h.radius + rad)) continue;
      hazards.add(SurfaceHazard(p, rad));
    }

    final map = SurfaceMap._(seed, kind, lander, sites, obstacles, hazards);
    // 모든 지점이 착륙선에서 갈 수 있어야 한다. 막힌 지점이 있으면 그 지점에 가장 가까운 장애물부터 치운다.
    for (final s in sites) {
      var guard = 0;
      while (map.path(lander, s.pos) == null && obstacles.isNotEmpty && guard++ < 60) {
        obstacles.remove(
          obstacles.reduce((a, b) => (a.pos - s.pos).distance - a.radius < (b.pos - s.pos).distance - b.radius ? a : b),
        );
      }
    }
    return map;
  }

  /// 장애물에 닿는지 ([clearance]만큼 여유를 둔다)
  SurfaceObstacle? obstacleAt(Offset p, [double clearance = 0]) {
    for (final o in obstacles) {
      if ((o.pos - p).distance < o.radius + clearance) return o;
    }
    return null;
  }

  /// 위험 지대 안인지
  bool inHazard(Offset p) => hazards.any((h) => (h.pos - p).distance < h.radius);

  // ---------- 길 찾기 (격자 BFS) ----------
  static const cell = 40.0;
  static int get _n => (size / cell).ceil();

  /// 차량 반경
  static const roverRadius = 20.0;

  bool _open(int x, int y, [bool avoidHazards = false]) {
    if (x < 0 || y < 0 || x >= _n || y >= _n) return false;
    final p = Offset((x + 0.5) * cell, (y + 0.5) * cell);
    return obstacleAt(p, roverRadius) == null && !(avoidHazards && inHazard(p));
  }

  (int, int) _cellOf(Offset p) =>
      ((p.dx / cell).floor().clamp(0, _n - 1), (p.dy / cell).floor().clamp(0, _n - 1));

  /// [from] → [to] 격자 경로 (칸 중심 좌표들, 끝은 [to]). 갈 수 없으면 null.
  /// [avoidHazards]면 위험 지대도 피한다 (돌아갈 길이 없으면 null).
  List<Offset>? path(Offset from, Offset to, {bool avoidHazards = false}) {
    final n = _n;
    final (sx, sy) = _cellOf(from);
    final (tx, ty) = _cellOf(to);
    final prev = List<int>.filled(n * n, -2);
    final q = Queue<int>();
    final start = sy * n + sx;
    prev[start] = -1;
    q.add(start);
    const dirs = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)];
    while (q.isNotEmpty) {
      final i = q.removeFirst();
      final x = i % n, y = i ~/ n;
      if (x == tx && y == ty) {
        final out = <Offset>[to];
        var k = prev[i];
        while (k >= 0) {
          out.add(Offset((k % n + 0.5) * cell, (k ~/ n + 0.5) * cell));
          k = prev[k];
        }
        return out.reversed.toList();
      }
      for (final (dx, dy) in dirs) {
        final nx = x + dx, ny = y + dy;
        if (nx < 0 || ny < 0 || nx >= n || ny >= n) continue;
        final j = ny * n + nx;
        if (prev[j] != -2) continue;
        // 출발·도착 칸은 장애물 여유와 상관없이 연다 (지점·착륙선 주변은 비어 있다)
        final isEnd = nx == tx && ny == ty;
        if (!isEnd && !_open(nx, ny, avoidHazards)) continue;
        // 대각선은 양옆이 열려 있어야 (모서리 끼기 방지)
        if (dx != 0 && dy != 0 && (!_open(x + dx, y, avoidHazards) || !_open(x, y + dy, avoidHazards))) continue;
        prev[j] = i;
        q.add(j);
      }
    }
    return null;
  }
}

// ---------------------------------------------------------------- 유물

/// 유물 8종 (도감 유물 탭, 그림 `relic_<id>`)
const relicIds = ['star_map', 'crystal_core', 'idol', 'gear', 'seed', 'mask', 'tablet', 'compass'];

/// 유적 하나를 발굴했을 때 유물 뽑기. [owned]에 없는 유물 중에서, [dry]번 연속 꽝이면 확정.
/// 돌려주는 값: (유물 id 또는 null, 새 연속 꽝 수). 모두 모았으면 (null, [dry]).
(String?, int) rollRelic(Random r, Set<String> owned, int dry) {
  final left = [for (final id in relicIds) if (!owned.contains(id)) id];
  if (left.isEmpty) return (null, dry);
  if (dry >= SurfaceRules.relicPity || r.nextDouble() < SurfaceRules.relicChance) {
    return (left[r.nextInt(left.length)], 0);
  }
  return (null, dry + 1);
}

// ---------------------------------------------------------------- 기록 (Profile.stats)

/// 지표 탐험 기록. 프로필 통계 맵(`stats`)에 'srf' 접두사 정수로 둔다 (하위 호환, 없으면 0).
class SurfaceRecords {
  SurfaceRecords(this.stats, {this.onChanged});
  final Map<String, int> stats;
  final void Function()? onChanged;

  static const kDay = 'srfDay';
  static const kRuns = 'srfRuns';
  static const kTotal = 'srfTotal';

  /// 유적 연속 꽝 수 (유물 확정용)
  static const kDry = 'srfDry';

  /// 해금 안내(미나)를 했는지
  static const kHint = 'srfHint';

  int _g(String k) => stats[k] ?? 0;
  void _s(String k, int v) {
    if (_g(k) == v) return;
    stats[k] = v;
    onChanged?.call();
  }

  int runsToday(DateTime now) => _g(kDay) == surfaceDayKey(now) ? _g(kRuns) : 0;
  int fullRunsLeft(DateTime now) => max(0, SurfaceRules.fullRunsPerDay - runsToday(now));
  int get totalRuns => _g(kTotal);
  int get dry => _g(kDry);
  set dry(int v) => _s(kDry, max(0, v));
  bool get hinted => _g(kHint) > 0;
  void markHinted() => _s(kHint, 1);

  /// 한 판을 센다. 이 판이 온전 보상이면 true
  bool record(DateTime now) {
    final full = runsToday(now) < SurfaceRules.fullRunsPerDay;
    final day = surfaceDayKey(now);
    if (_g(kDay) != day) {
      _s(kDay, day);
      _s(kRuns, 0);
    }
    _s(kRuns, _g(kRuns) + 1);
    _s(kTotal, _g(kTotal) + 1);
    return full;
  }
}
