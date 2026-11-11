part of 'world.dart';

/// 지표 탐험이 끝난 이유. 값의 index가 통계 `surface_end` 값이다 (0 귀환, 1 산소·비상 귀환, 2 격추).
enum SurfaceEnd { returned, oxygen, destroyed }

/// 지표 탐험 한 판의 결과 (정산 전)
class SurfaceOutcome {
  const SurfaceOutcome({
    required this.sector,
    required this.planetIndex,
    required this.planetKind,
    required this.reason,
    required this.credits,
    required this.ore,
    required this.sitesDone,
    required this.sitesTotal,
    required this.veinFound,
    required this.nestCleared,
    required this.relics,
    required this.relicDry,
    required this.seconds,
  });

  /// 탐사한 행성 (메인 월드의 항성계·행성 번호)
  final int sector;
  final int planetIndex;
  final PlanetKind planetKind;
  final SurfaceEnd reason;

  /// 이번 판 전리품 (배율 적용, 남긴 비율·하루 횟수 적용 전)
  final int credits;
  final int ore;
  final int sitesDone;
  final int sitesTotal;
  final bool veinFound;
  final bool nestCleared;

  /// 이번 판에 발굴한 유물 (모두 새 유물)
  final List<String> relics;

  /// 판이 끝났을 때 유적 연속 꽝 수
  final int relicDry;
  final double seconds;

  bool get returned => reason == SurfaceEnd.returned;

  /// 남긴 비율: 귀환 100%, 비상 귀환·격추 50%
  double get keepRatio => returned ? 1 : SurfaceRules.partialKeep;

  /// 모든 지점을 끝내고 스스로 귀환 (완전 탐사 조건)
  bool get complete => returned && sitesDone >= sitesTotal;
}

/// 정산 내역 (결과 화면)
class SurfaceSettlement {
  const SurfaceSettlement({
    required this.credits,
    required this.ore,
    required this.gems,
    required this.full,
    required this.keepRatio,
    required this.newVein,
    required this.newNest,
    required this.newSurveyed,
    required this.relics,
    required this.fullRunsLeft,
    required this.applied,
  });

  /// 실제로 받은 크레딧·광석 (남긴 비율 × 하루 비율 적용)
  final int credits;
  final int ore;
  final int gems;

  /// 오늘 온전 보상 판이었는지 (아니면 [SurfaceRules.reducedRatio])
  final bool full;
  final double keepRatio;
  final bool newVein;
  final bool newNest;
  final bool newSurveyed;

  /// 이번에 도감에 새로 들어간 유물
  final List<String> relics;

  /// 정산 뒤 오늘 남은 온전 보상 횟수
  final int fullRunsLeft;

  /// 행성 영구 발견을 메인 월드에 적용했는지 (항성계가 바뀌었으면 false)
  final bool applied;
}

extension SurfaceSettle on SurfaceOutcome {
  /// 결과를 메인 월드·프로필에 넣는다: 크레딧·광석(남긴 비율 × 하루 비율), 행성 영구 발견, 완전 탐사 젬('play'),
  /// 유물 도감, 하루 횟수·유물 연속 꽝 기록, 통계 `surface_end`. 저장은 부르는 쪽(화면)이 한다.
  SurfaceSettlement settle({required Profile profile, required GameWorld main, required DateTime now}) {
    final rec = SurfaceRecords(profile.stats, onChanged: () => profile.dirty = true);
    final full = rec.record(now);
    final ratio = keepRatio * (full ? 1 : SurfaceRules.reducedRatio);
    final c = (credits * ratio).round(), o = (ore * ratio).round();
    main.credits += c;
    main.ore += o;
    rec.dry = relicDry;
    final newRelics = [for (final id in relics) if (profile.codex.recordRelic(id)) id];

    var newVein = false, newNest = false, newSurveyed = false, gems = 0;
    final applied = main.sector == sector && planetIndex >= 0 && planetIndex < main.planets.length;
    if (applied) {
      final p = main.planets[planetIndex];
      if (veinFound && !p.vein) newVein = p.vein = true;
      if (nestCleared && !p.nest) newNest = p.nest = true;
      if (complete && !p.surveyed) {
        newSurveyed = p.surveyed = true;
        gems = SurfaceRules.surveyGems;
        profile.earnGems('play', '', gems);
      }
    }
    profile.dirty = true;
    GameTelemetry.emit(TelemetryEvent.surfaceEnd, reason.index);
    return SurfaceSettlement(
      credits: c,
      ore: o,
      gems: gems,
      full: full,
      keepRatio: keepRatio,
      newVein: newVein,
      newNest: newNest,
      newSurveyed: newSurveyed,
      relics: newRelics,
      fullRunsLeft: rec.fullRunsLeft(now),
      applied: applied,
    );
  }
}

/// 행성 지표 탐험. 기존 전투 엔진([GameWorld]의 플레이어·적·탄·미사일)을 그대로 쓰고,
/// 우주(행성·정거장·경제·스토리·이벤트·침공)는 돌리지 않는다.
///
/// 균열 런과 반대로 선장의 실제 강화·함선·승무원·명예 능력치를 쓴다 (메인 프로필을 함께 쓰고, 강화 레벨·배치 승무원은 진입 때 복사).
/// 메인 월드는 정산([SurfaceSettle.settle]) 말고는 바꾸지 않는다. 격추 통계·업적·젬·임무·도감 적 항목은 쌓지 않는다.
class SurfaceWorld extends GameWorld {
  SurfaceWorld({required GameWorld main, required Planet planet, int? runSeed})
    : hostSector = main.sector,
      planetIndex = main.planets.indexOf(planet),
      planetKind = planet.kind,
      planetName = planet.name,
      hadVein = planet.vein,
      hadNest = planet.nest,
      hadSurveyed = planet.surveyed,
      lootCreditMul = main.rewardMul,
      lootOreMul = main.sectorMul,
      _hpMul = main.enemyHpMul,
      _dmgMul = main.enemyDamageMul * SurfaceRules.creatureDamageMul,
      map = SurfaceMap.generate(
        surfaceSeed(main.seed, main.sector, main.planets.indexOf(planet)),
        planet.kind,
      ),
      super(seed: runSeed ?? Random().nextInt(1 << 30), profile: main.profile) {
    _copyCaptain(main);
    _setup();
  }

  final int hostSector;
  final int planetIndex;
  final PlanetKind planetKind;
  final String planetName;
  final SurfaceMap map;

  /// 진입 전 이미 있던 영구 발견 (소개 카드)
  final bool hadVein;
  final bool hadNest;
  final bool hadSurveyed;

  /// 전리품 배율 (진입 때 메인 월드 rewardMul·sectorMul)
  final double lootCreditMul;
  final double lootOreMul;
  final double _hpMul;
  final double _dmgMul;

  double oxygen = SurfaceRules.oxygenSeconds;
  double runTime = 0;
  bool warned = false;
  double lootCredits = 0;
  double lootOre = 0;
  int kills = 0;

  /// 이번 판에 나온 유물
  final relicsFound = <String>[];
  late final Set<String> _owned = {...profile.codex.relics};
  late int _dry = SurfaceRecords(profile.stats).dry;

  SurfaceOutcome? outcome;
  bool get over => outcome != null;

  final _brood = <Pirate>{};

  /// 선장을 알아챈 생물 (몰려온 생물·맞은 생물). 나머지는 [SurfaceRules.aggroRange] 안에 들어와야 쫓는다
  final _alert = <Pirate>{};
  double _nestTimer = SurfaceRules.nestInterval;
  double _pressureTimer = SurfaceRules.pressureInterval;

  List<SurfaceSite> get sites => map.sites;
  int get sitesDone => sites.where((s) => s.done).length;
  int get sitesLeft => sites.length - sitesDone;
  SurfaceSite? get nest => sites.where((s) => s.kind == SurfaceSiteKind.nest).firstOrNull;

  /// 착륙선 반경 안 (귀환 가능)
  bool get atLander => player.alive && (player.pos - map.lander).distance < SurfaceRules.landerRadius;

  /// 지금 머물러 진행 중인 지점 (HUD 진행 막대)
  SurfaceSite? get activeSite {
    if (!player.alive) return null;
    for (final s in sites) {
      if (!s.done && s.kind != SurfaceSiteKind.nest && (player.pos - s.pos).distance < s.radius) return s;
    }
    return null;
  }

  bool get inHazard => map.inHazard(player.pos);
  HazardEffect get hazard => map.hazardEffect;

  void _copyCaptain(GameWorld main) {
    levels.addAll(main.levels);
    for (final c in main.roster) {
      if (c.assigned) roster.add(CrewMember.fromJson(c.toJson()));
    }
  }

  void _setup() {
    planets.clear();
    gates.clear();
    asteroids.clear();
    events.clear();
    dialogs.clear();
    missionOffers.clear();
    activeMissions.clear();
    sectors.clear();
    // 그리기·적 엔진이 본거지를 늘 찾으므로 하나만 지도 밖 먼 곳에 둔다 (생물은 900 안의 정거장만 노린다)
    final home = stations.first;
    stations
      ..clear()
      ..add(Station.named(home.label, const Offset(-3800, -3800)));
    sector = hostSector;
    credits = 0;
    ore = 0;
    player
      ..pos = map.lander + const Offset(0, 120)
      ..vel = Offset.zero
      ..angle = -pi / 2
      ..hp = playerMaxHp;
    final n =
        SurfaceRules.startCreaturesMin + _rng.nextInt(SurfaceRules.startCreaturesMax - SurfaceRules.startCreaturesMin + 1);
    for (var i = 0; i < n; i++) {
      final pos = _freeSpot(map.center, 0, SurfaceMap.size, awayFrom: map.lander, minAway: SurfaceRules.startCreatureDistance);
      if (pos != null) _spawnCreature(randomCreature(_rng), pos);
    }
    final ns = nest;
    if (ns != null) ns.hp = ns.maxHp = SurfaceRules.nestHp * _hpMul;
  }

  /// [around]에서 [minR]..[maxR] 떨어진 빈 자리 (지도 안, 장애물 밖, [awayFrom]에서 [minAway] 이상)
  Offset? _freeSpot(Offset around, double minR, double maxR, {Offset? awayFrom, double minAway = 0}) {
    for (var t = 0; t < 40; t++) {
      final p = minR == 0
          ? Offset(randRange(_rng, 120, SurfaceMap.size - 120), randRange(_rng, 120, SurfaceMap.size - 120))
          : around + OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, randRange(_rng, minR, maxR));
      if (p.dx < 80 || p.dy < 80 || p.dx > SurfaceMap.size - 80 || p.dy > SurfaceMap.size - 80) continue;
      if (map.obstacleAt(p, 40) != null) continue;
      if (awayFrom != null && (p - awayFrom).distance < minAway) continue;
      return p;
    }
    return null;
  }

  Pirate _spawnCreature(CreatureKind c, Offset pos) {
    var kind = pirateKindOf(c, planetKind);
    // 용암 덩치(돌격함 동작)는 원래 후반 적이라 체력·공격을 덜어 내고, 한 번에 [SurfaceRules.maxHeavy]마리까지만 (나머지 덩치는 습격선 동작)
    if (kind == PirateKind.juggernaut &&
        pirates.where((e) => e.kind == PirateKind.juggernaut).length >= SurfaceRules.maxHeavy) {
      kind = PirateKind.raider;
    }
    final heavy = kind == PirateKind.juggernaut;
    final e = _makePirate(kind, pos, hpMul: heavy ? 0.2 : 1, dmgMul: heavy ? 0.4 : 1);
    pirates.add(e);
    return e;
  }

  int get _creatureCount => pirates.where((e) => e.isPirate).length;

  void _ambush(Offset around, int n, double minR, double maxR) {
    for (var i = 0; i < n && _creatureCount < SurfaceRules.maxCreatures; i++) {
      final p = _freeSpot(around, minR, maxR);
      if (p != null) _alert.add(_spawnCreature(randomCreature(_rng), p));
    }
  }

  // ---------- 실제 능력치 (차량은 함선보다 느리다), 적 배율은 진입 때 값 ----------
  @override
  double get playerSpeed =>
      super.playerSpeed * SurfaceRules.roverSpeedMul * (map.inHazard(player.pos) ? map.hazardEffect.slow : 1);
  @override
  double get enemyHpMul => _hpMul;
  @override
  double get enemyDamageMul => _dmgMul;
  @override
  double get _newbieMul => 1;
  @override
  Offset? get storyTarget => null;
  @override
  bool get campaignMissionActive => false;
  @override
  Offset? get campaignTarget => null;

  // ---------- 진행 ----------
  @override
  void update(double dt, InputState input) {
    if (paused || over) return;
    dt = dt.clamp(0, 0.05);
    totalTime += dt;
    runTime += dt;
    oxygen = max(0, oxygen - dt);
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
    for (final b in beams) {
      b.life -= dt;
    }
    beams.removeWhere((b) => b.life <= 0);

    if (player.alive) _updatePlayer(dt, input);
    _collide(player.pos, 18, (p) => player.pos = p, (v) => player.vel = v, player.vel);
    _updateHazard(dt);
    if (atLander && player.hp < playerMaxHp) {
      player.hp = min(playerMaxHp, player.hp + playerMaxHp * SurfaceRules.landerRepair * dt);
    }
    _updateDrone(dt);
    _updatePirates(dt);
    for (final e in pirates) {
      // 산소 경고 뒤에는 멀리 있는 생물도 차량 쪽으로 몰려온다
      if (warned && player.alive && e.isPirate) {
        _alert.add(e);
        final to = player.pos - e.pos;
        if (to.distance > 900) e.pos += to / to.distance * e.speed * 0.6 * dt;
      }
      _collide(e.pos, e.radius * 0.8, (p) => e.pos = p, (v) => e.vel = v, e.vel);
    }
    _updateMissiles(dt);
    _terrainHits();
    _updateHostileOrdnance(dt);
    _updateBullets(dt);
    _updatePickups(dt);
    _updateParticles(dt);
    _updateSites(dt);
    _updatePressure(dt);

    if (!player.alive) {
      _finish(SurfaceEnd.destroyed);
    } else if (oxygen <= 0) {
      _finish(SurfaceEnd.oxygen);
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

  /// 사각 경계와 장애물에서 밀어낸다
  void _collide(Offset pos, double r, void Function(Offset) setPos, void Function(Offset) setVel, Offset vel) {
    var p = pos;
    var v = vel;
    const s = SurfaceMap.size;
    final cx = p.dx.clamp(r, s - r), cy = p.dy.clamp(r, s - r);
    if (cx != p.dx) v = Offset(0, v.dy);
    if (cy != p.dy) v = Offset(v.dx, 0);
    p = Offset(cx, cy);
    for (final o in map.obstacles) {
      final d = p - o.pos;
      final minD = o.radius + r;
      final dist = d.distance;
      if (dist < minD) {
        final n = dist == 0 ? const Offset(1, 0) : d / dist;
        p = o.pos + n * minD;
        final into = v.dx * n.dx + v.dy * n.dy;
        if (into < 0) v -= n * into;
      }
    }
    if (p != pos) setPos(p);
    if (v != vel) setVel(v);
  }

  void _updateHazard(double dt) {
    final h = map.hazardEffect;
    if (!player.alive || h.dps <= 0 || !map.inHazard(player.pos) || shielded) return;
    player.hp -= h.dps * dt;
    player.sinceHit = 0;
    if (_rng.nextDouble() < dt * 4) _spark(player.pos, const Color(0xFFFF8A65));
    if (player.hp <= 0) _destroyPlayer();
  }

  /// 탄·미사일은 장애물에 맞으면 사라지고, 선장의 탄·미사일은 둥지를 깎는다
  void _terrainHits() {
    final n = nest;
    final ns = n != null && !n.done ? n : null;
    bullets.removeWhere((b) {
      if (b.fromPlayer && ns != null && (b.pos - ns.pos).distance < ns.radius) {
        _hitNest(ns, b.damage, b.pos);
        return true;
      }
      if (map.obstacleAt(b.pos) != null) {
        _spark(b.pos, const Color(0xFFBCAAA4));
        return true;
      }
      return false;
    });
    missiles.removeWhere((m) {
      if (ns != null && (m.pos - ns.pos).distance < ns.radius + 6) {
        _hitNest(ns, m.damage, m.pos);
        _burst(m.pos, const Color(0xFFFFAB40), 14);
        sfx.add(Sfx.explode);
        return true;
      }
      return map.obstacleAt(m.pos) != null;
    });
    enemyMissiles.removeWhere((m) => map.obstacleAt(m.pos) != null);
  }

  void _hitNest(SurfaceSite s, double dmg, Offset at) {
    if (s.done) return;
    s.hp -= dmg;
    _spark(at, const Color(0xFFCE93D8));
    if (_rng.nextDouble() < 0.5) _float(at, dmg.round().toString(), const Color(0xFFFFF59D));
    if (s.hp <= 0) {
      s.hp = 0;
      _burst(s.pos, const Color(0xFFCE93D8), 60);
      shake = min(20, shake + 8);
      sfx.add(Sfx.bigExplode);
      _complete(s);
    }
  }

  void _updateSites(double dt) {
    for (final s in sites) {
      if (s.done) continue;
      if (s.kind == SurfaceSiteKind.nest) {
        _updateNest(s, dt);
        continue;
      }
      if (!player.alive || (player.pos - s.pos).distance >= s.radius) continue;
      if (s.progress == 0 && s.kind == SurfaceSiteKind.ruin) {
        // 발굴을 시작하면 생물이 몰려온다
        _ambush(
          s.pos,
          SurfaceRules.ruinAmbushMin + _rng.nextInt(SurfaceRules.ruinAmbushMax - SurfaceRules.ruinAmbushMin + 1),
          550,
          750,
        );
        sfx.add(Sfx.alarm);
      }
      s.progress += dt;
      if (s.progress >= s.need) _complete(s);
    }
  }

  void _updateNest(SurfaceSite s, double dt) {
    _brood.removeWhere((e) => !pirates.contains(e));
    if (!player.alive || (player.pos - s.pos).distance > SurfaceRules.nestWakeDistance) return;
    _nestTimer -= dt;
    if (_nestTimer > 0) return;
    _nestTimer = SurfaceRules.nestInterval;
    for (var i = 0; i < SurfaceRules.nestBrood && _brood.length < SurfaceRules.nestMaxBrood; i++) {
      final e = _spawnCreature(
        CreatureKind.crawler,
        s.pos + OffsetX.fromAngle(_rng.nextDouble() * 2 * pi, s.radius + 30),
      );
      _brood.add(e);
      _alert.add(e);
    }
  }

  void _complete(SurfaceSite s) {
    s.done = true;
    s.progress = s.need;
    final (c, o) = SurfaceLoot.site(s.kind);
    lootCredits += c * lootCreditMul;
    lootOre += o * lootOreMul;
    sfx.add(Sfx.upgrade);
    _float(s.pos + const Offset(0, -40), tr.srf_floatSite(s.kind.name), const Color(0xFF7CFFB2), big: true);
    _burst(s.pos, const Color(0xFF7CFFB2), 24);
    if (s.kind == SurfaceSiteKind.ruin) {
      final (relic, dry) = rollRelic(_rng, _owned, _dry);
      _dry = dry;
      if (relic != null) {
        _owned.add(relic);
        relicsFound.add(relic);
        sfx.add(Sfx.gem);
        _float(s.pos + const Offset(0, -80), tr.srf_floatRelic, const Color(0xFFFFD54F), big: true);
      }
    }
  }

  void _updatePressure(double dt) {
    if (!player.alive) return;
    if (!warned) {
      if (oxygen > SurfaceRules.oxygenWarn) return;
      warned = true;
      sfx.add(Sfx.alarm);
      say(Speaker.advisor, tr.srf_dlgOxygen);
      _ambush(player.pos, SurfaceRules.warnAmbush, 700, 900);
      return;
    }
    _pressureTimer -= dt;
    if (_pressureTimer <= 0) {
      _pressureTimer = SurfaceRules.pressureInterval;
      _ambush(player.pos, SurfaceRules.pressureCount, 700, 900);
    }
  }

  /// 착륙선 반경 안에서 귀환 (전리품 100%). 반경 밖이면 false
  bool returnToLander() {
    if (!atLander || over) return false;
    sfx.add(Sfx.warp);
    _finish(SurfaceEnd.returned);
    return true;
  }

  /// 중간에 나가기 = 비상 귀환 (전리품 50%)
  void abandon() => _finish(SurfaceEnd.oxygen);

  void _finish(SurfaceEnd reason) {
    if (over) return;
    outcome = SurfaceOutcome(
      sector: hostSector,
      planetIndex: planetIndex,
      planetKind: planetKind,
      reason: reason,
      credits: lootCredits.round(),
      ore: lootOre.round(),
      sitesDone: sitesDone,
      sitesTotal: sites.length,
      veinFound: sites.any((s) => s.kind == SurfaceSiteKind.vein && s.done),
      nestCleared: sites.any((s) => s.kind == SurfaceSiteKind.nest && s.done),
      relics: List.unmodifiable(relicsFound),
      relicDry: _dry,
      seconds: runTime,
    );
  }

  // ---------- 엔진 동작 바꾸기 ----------
  @override
  double _aggroRange(Pirate e) => _alert.contains(e) ? 1600 : SurfaceRules.aggroRange;

  @override
  void _hitPirate(Pirate e, double dmg, Offset at, {bool crit = false, bool byBase = false, Offset? from}) {
    _alert.add(e);
    super._hitPirate(e, dmg, at, crit: crit, byBase: byBase, from: from);
  }

  @override
  Pirate _makePirate(PirateKind kind, Offset pos, {double hpMul = 1, double dmgMul = 1}) => Pirate(
    kind,
    pos,
    Pirate.baseHp(kind) * _hpMul * hpMul,
    dmgScale: _dmgMul * dmgMul,
  )..wanderAngle = _rng.nextDouble() * 2 * pi;

  /// 가까이 생물이 없으면 살아 있는 둥지를 조준한다
  @override
  double _aimAngle(bool allAround) {
    final ns = nest;
    if (ns != null && !ns.done) {
      // 둥지 곁(420 안)에서는 바로 붙은 생물(200 안)이 없으면 둥지를, 멀리서는 생물이 없을 때만 둥지를 쏜다
      final to = ns.pos - player.pos;
      final d = to.distance;
      final a = atan2(to.dy, to.dx);
      bool within(double r) => pirates.any((e) => !e.cloaked && (e.pos - player.pos).distance < r);
      final inView = allAround || angleDiff(player.angle, a).abs() < 0.6;
      if (inView && ((d < 420 && !within(200)) || (d < 600 && !within(600)))) return a;
    }
    return super._aimAngle(allAround);
  }

  /// 메인 게임의 피해 처리에서 본거지 안전 구역·최종 임무·통계 이벤트·대사를 뺀 것
  @override
  bool _damagePlayer(double dmg) {
    final p = player;
    if (!p.alive || p.invulnerable > 0 || over) return false;
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
    if (p.hp <= 0) _destroyPlayer();
    return true;
  }

  void _destroyPlayer() {
    final p = player;
    p
      ..hp = 0
      ..alive = false
      ..deadTime = 0
      ..deathPos = p.pos;
    shake = 20;
    sfx.add(Sfx.bigExplode);
    _burst(p.pos, const Color(0xFFFF7043), 70);
  }

  /// 처치: 이번 판 전리품용 크레딧만 떨군다 (메인 크레딧·통계·임무·도감·젬 없음)
  @override
  void _onKilled(Pirate e) {
    _burst(e.pos, const Color(0xFF9CCC65), 30);
    sfx.add(Sfx.explode);
    shake = min(20, shake + 3);
    _brood.remove(e);
    _alert.remove(e);
    if (!e.isPirate) return;
    kills++;
    final c = creatureOf(e.kind) ?? CreatureKind.crawler;
    final v = (SurfaceLoot.killCredits(c) * lootCreditMul).round();
    if (v > 0) _dropPickups(e.pos, PickupKind.credits, v, 2);
    if (_rng.nextDouble() < 0.05) {
      const kinds = [PowerUpKind.rapid, PowerUpKind.shield, PowerUpKind.magnet];
      pickups.add(
        Pickup(
          PickupKind.power,
          e.pos,
          1,
          OffsetX.fromAngle(_rng.nextDouble() * 6, 60),
          power: kinds[_rng.nextInt(kinds.length)],
        ),
      );
    }
  }

  /// 크레딧·광석은 이번 판 전리품으로, 파워업은 그대로. 젬·통계·임무는 없다.
  @override
  void _collect(Pickup k) {
    switch (k.kind) {
      case PickupKind.credits:
        lootCredits += k.amount;
        sfx.add(Sfx.coin);
        _float(k.pos, '+${k.amount}', const Color(0xFFFFD54F));
      case PickupKind.ore:
        lootOre += k.amount;
        sfx.add(Sfx.pickup);
        _float(k.pos, '+${k.amount}', const Color(0xFF4DD0E1));
      case PickupKind.power:
        final pk = k.power!;
        buffs[pk] = pk.duration;
        sfx.add(Sfx.upgrade);
        _float(k.pos, '${pk.icon} ${pk.label}!', const Color(0xFFB9F6CA), big: true);
      case PickupKind.gem:
        break;
    }
  }
}
