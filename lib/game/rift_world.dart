part of 'world.dart';

/// 균열 런 진행 단계
enum RiftPhase {
  /// 다음 파도까지 카운트다운
  countdown,

  /// 파도 전투 중
  fighting,

  /// 파도를 넘겨 카드를 고르는 중 (게임 멈춤)
  choosing,

  /// 끝 (정복·격추·포기)
  done,
}

/// 균열 런 결과
class RiftOutcome {
  const RiftOutcome({
    required this.score,
    required this.reached,
    required this.cleared,
    required this.conquered,
    required this.seconds,
    required this.kills,
    required this.gaveUp,
  });

  final int score;

  /// 도달한 파도 (1..10)
  final int reached;

  /// 돌파한 파도 수 (0..10)
  final int cleared;

  /// 10파 두목까지 정복
  final bool conquered;

  /// 전투 시간 (카드 고르는 시간 제외)
  final double seconds;
  final int kills;
  final bool gaveUp;
}

/// 균열 런 아레나. 기존 전투 엔진([GameWorld]의 플레이어·해적·탄·미사일·두목 패턴)을 그대로 쓰고,
/// 식민지·정거장·경제·스토리·이벤트·침공은 돌리지 않는다.
///
/// 메인 게임과 완전히 분리된다: 런 전용 [Profile](외형만 복사)을 쓰고, 런 상태는 저장하지 않는다.
/// 같은 라이브러리(part)라서 엔진의 비공개 갱신 함수를 그대로 부르고, 피해·격추·줍기만 런 규칙으로 바꾼다.
class RiftWorld extends GameWorld {
  RiftWorld({required this.plan, required Profile mainProfile})
    : super(seed: plan.seed, profile: riftProfile(mainProfile)) {
    _setupArena();
  }

  /// 런 전용 프로필: 외형(함선 종류·스킨·복장)과 순항 설정만 가져온다.
  /// 강화·명예·내 행성 보너스·젬은 없다 (공정성). 이 프로필은 저장하지 않는다.
  static Profile riftProfile(Profile main) => Profile()
    ..skin = main.skin
    ..outfit = main.outfit
    ..shipType = main.shipType
    ..cruise = main.cruise
    ..ownedSkins.addAll(main.ownedSkins)
    ..ownedShips.addAll(main.ownedShips);

  final RiftPlan plan;
  final loadout = RiftLoadout();

  /// 아레나 중심과 반경 (항성·본거지에서 멀리 떨어진 빈 공간)
  static const arenaCenter = Offset(2200, 2200);
  static const arenaRadius = 1300.0;

  /// 파도 사이 카운트다운
  static const countdownSeconds = 3.0;

  /// 파도를 넘기면 최대 체력의 이만큼 회복
  static const waveHeal = 0.3;

  /// 파도가 이 시간(초)을 넘기면 균열 붕괴: 남은 적이 초당 최대 체력의 [collapseRate]씩(10초마다 더 빨리) 깎인다
  static const collapseAfter = 50.0;
  static const collapseRate = 0.04;

  /// 붕괴 중인지 (화면 표시용)
  bool get collapsing => phase == RiftPhase.fighting && _waveTime > collapseAfter && _queue.isEmpty;

  RiftPhase phase = RiftPhase.countdown;
  double phaseTimer = countdownSeconds;

  /// 현재(또는 다음) 파도 1..10
  int wave = 1;
  int score = 0;
  int kills = 0;

  /// 전투 시간 (카운트다운 포함, 카드 고르는 시간 제외)
  double runTime = 0;

  /// 파도별 걸린 시간 (봇 측정·결과 표시)
  final waveTimes = <double>[];
  double _waveTime = 0;

  /// 지금 고를 수 있는 카드 3장
  List<RiftCard> offers = const [];
  RiftOutcome? outcome;

  final _queue = <PirateKind>[];
  double _spawnTimer = 0;

  /// 이번 파도에 균열이 직접 내보낸 적. 점수는 이 적에게만 준다 (모함 드론·두목 호위는 점수 없음 → 서버 상한 보장).
  final _planned = <Pirate>{};

  double bladeAngle = 0;
  final _bladeHit = <Pirate, double>{};
  double _homingTimer = 0;
  double _shockTimer = 0;

  /// 화면 효과용: 마지막 충격파가 터진 뒤 지난 시간
  double shockAge = 99;

  late ShipType _ship = _buildShip();

  void _setupArena() {
    planets.clear();
    gates.clear();
    asteroids.clear();
    events.clear();
    dialogs.clear();
    missionOffers.clear();
    activeMissions.clear();
    sectors.clear();
    // 그리기 코드가 본거지를 늘 찾으므로 하나만 남겨 아레나 밖 먼 구석에 둔다 (아레나 안 적은 닿지 않는다)
    final home = stations.first;
    stations
      ..clear()
      ..add(Station.named(home.label, const Offset(-3800, -3800)));
    sector = plan.backdropSector;
    // 기본 장비: 미사일·방어막 Lv.1 (모두 같다)
    levels[UpgradeKind.missile] = 1;
    levels[UpgradeKind.shield] = 1;
    credits = 0;
    ore = 0;
    player
      ..pos = arenaCenter + const Offset(0, 420)
      ..vel = Offset.zero
      ..angle = -pi / 2
      ..hp = playerMaxHp;
  }

  ShipType _buildShip() {
    final real = shipTypeById(profile.shipType);
    return ShipType(
      real.id,
      crit: loadout.crit,
      pierce: loadout.pierce,
      guardInterval: loadout.guardInterval,
      wing: real.wing,
      length: real.length,
    );
  }

  RiftWave get currentWave => plan.wave(wave);

  /// 이번 파도 남은 적 (아직 안 나온 적 포함)
  int get enemiesLeft => _queue.length + _planned.length;

  bool get over => phase == RiftPhase.done;

  // ---------- 런 전용 능력치 (메인 게임 강화·승무원·명예·특성 무시) ----------
  @override
  ShipType get ship => _ship;
  @override
  double get playerMaxHp => loadout.maxHp;
  @override
  double get playerSpeed => RiftLoadout.baseSpeed * loadout.speedMul;
  @override
  double get playerDamage => RiftLoadout.baseDamage * loadout.damageMul;
  @override
  double get playerFireInterval =>
      RiftLoadout.baseFireInterval *
      loadout.fireIntervalMul *
      (buffs.containsKey(PowerUpKind.rapid) ? 0.45 : 1);
  @override
  int get playerShots => loadout.shots;
  @override
  double get magnetRadius =>
      (buffs.containsKey(PowerUpKind.magnet) ? 450.0 : 170.0) + loadout.magnetBonus;
  @override
  double get magnetPull => 1400;
  @override
  int get droneLevel => loadout.droneLevel;
  @override
  double get droneDamage => (5 + droneLevel * 4) * loadout.damageMul;
  @override
  double get droneInterval => max(0.35, 1.2 - droneLevel * 0.15);
  @override
  double get missileCooldownMax => 8;
  @override
  double get shieldCooldownMax => 18;
  @override
  double get boostCooldownMax => 4;
  @override
  double get enemyHpMul => 1;
  @override
  double get enemyDamageMul => 1;
  @override
  double get _newbieMul => 1;
  @override
  Offset? get storyTarget => null;

  // 배경으로 빌린 항성계의 캠페인 임무는 아레나에 없다
  @override
  bool get campaignMissionActive => false;
  @override
  Offset? get campaignTarget => null;

  // ---------- 진행 ----------
  @override
  void update(double dt, InputState input) {
    if (paused || phase == RiftPhase.choosing || phase == RiftPhase.done) return;
    dt = dt.clamp(0, 0.05);
    totalTime += dt;
    sectorElapsed += dt;
    runTime += dt;
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
    _keepInArena(player.pos, (p) => player.pos = p, (v) => player.vel = v, player.vel);
    _updateDrone(dt);
    _updatePirates(dt);
    for (final e in pirates) {
      // 엔진은 멀리 있는 적을 배회시킨다. 아레나에서는 멀어도 선장을 향해 다가온다.
      if (player.alive && e.isPirate) {
        final to = player.pos - e.pos;
        if (to.distance > 1200) e.pos += to / to.distance * e.speed * 0.7 * dt;
      }
      _keepInArena(e.pos, (p) => e.pos = p, (v) => e.vel = v, e.vel);
    }
    _updateMissiles(dt);
    _updateHostileOrdnance(dt);
    _updateBullets(dt);
    _updateCards(dt);
    _updatePickups(dt);
    _updateParticles(dt);
    _updateRift(dt);

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

  void _keepInArena(Offset pos, void Function(Offset) setPos, void Function(Offset) setVel, Offset vel) {
    final rel = pos - arenaCenter;
    final d = rel.distance;
    if (d <= arenaRadius) return;
    final n = rel / d;
    setPos(arenaCenter + n * arenaRadius);
    final out = vel.dx * n.dx + vel.dy * n.dy;
    if (out > 0) setVel(vel - n * out);
  }

  void _updateRift(double dt) {
    if (!player.alive) {
      _finish(gaveUp: false);
      return;
    }
    switch (phase) {
      case RiftPhase.countdown:
        phaseTimer -= dt;
        if (phaseTimer <= 0) _startWave();
      case RiftPhase.fighting:
        _waveTime += dt;
        _spawnTimer -= dt;
        if (_queue.isNotEmpty && _spawnTimer <= 0) {
          _spawnTimer = 0.7;
          final group = min(_queue.length, 1 + _rng.nextInt(3));
          final base = _rng.nextDouble() * 2 * pi;
          for (var i = 0; i < group; i++) {
            _spawnPlanned(_queue.removeAt(0), base + i * 0.18);
          }
        }
        _planned.removeWhere((e) => !pirates.contains(e));
        // 오래 끄는 파도(숨는 유령·수리선·도망 다니는 저격선)는 균열이 무너지며 남은 적을 갉아먹는다
        if (_waveTime > collapseAfter) {
          for (final e in _planned) {
            // 수리선이 서로 고쳐도 끝나도록 붕괴는 10초마다 한 단계씩 빨라진다
            if (_queue.isEmpty) e.hp -= e.maxHp * collapseRate * (1 + (_waveTime - collapseAfter) / 10) * dt;
          }
        }
        if (_queue.isEmpty && _planned.isEmpty) _clearWave();
      case RiftPhase.choosing:
      case RiftPhase.done:
        break;
    }
  }

  void _startWave() {
    phase = RiftPhase.fighting;
    _waveTime = 0;
    _spawnTimer = 0;
    _queue
      ..clear()
      ..addAll(currentWave.kinds);
    sfx.add(currentWave.boss ? Sfx.alarm : Sfx.warp);
  }

  /// 선장에게서 화면 밖 [spawnDistance]쯤 떨어진 아레나 안쪽 지점에서 들어온다
  static const spawnDistance = 950.0;

  void _spawnPlanned(PirateKind kind, double angle) {
    var pos = arenaCenter;
    for (var i = 0; i < 12; i++) {
      final p = player.pos + OffsetX.fromAngle(angle + i * 0.55, spawnDistance);
      if ((p - arenaCenter).distance < arenaRadius - 60) {
        pos = p;
        break;
      }
    }
    final boss = kind == PirateKind.boss;
    final e = _makePirate(kind, pos, hpMul: boss ? 1.6 : 1);
    if (boss) {
      final archetype = plan.bossArchetype;
      e
        ..sectorBoss = true
        ..archetype = archetype
        ..archetypeTimer = switch (archetype) {
          BossArchetype.fleet => BossArchetype.escortInterval,
          BossArchetype.devourer => BossArchetype.mineInterval,
          BossArchetype.flare => BossArchetype.flareInterval,
          BossArchetype.wraith => BossArchetype.wraithPhase,
          _ => 0,
        };
    }
    pirates.add(e);
    _planned.add(e);
  }

  void _clearWave() {
    waveTimes.add(_waveTime);
    score += RiftScore.waveClear(wave);
    // 남은 부하(모함 드론·두목 호위)는 균열로 사라진다
    for (final e in pirates.where((e) => e.isPirate).toList()) {
      _burst(e.pos, const Color(0xFFB388FF), 14);
      pirates.remove(e);
    }
    bullets.removeWhere((b) => !b.fromPlayer);
    enemyMissiles.clear();
    mines.clear();
    if (wave >= RiftPlan.waveCount) {
      _finish(gaveUp: false, conquered: true);
      return;
    }
    player.hp = min(playerMaxHp, player.hp + playerMaxHp * waveHeal);
    sfx.add(Sfx.upgrade);
    offers = plan.offers(wave, loadout);
    if (offers.isEmpty) {
      _nextWave();
    } else {
      phase = RiftPhase.choosing;
    }
  }

  /// 카드 고르기. 고를 수 없는 카드면 false.
  bool chooseCard(RiftCard c) {
    if (phase != RiftPhase.choosing || !offers.contains(c) || !loadout.take(c)) return false;
    if (c == RiftCard.hull) player.hp = playerMaxHp;
    _ship = _buildShip();
    sfx.add(Sfx.upgrade);
    _nextWave();
    return true;
  }

  void _nextWave() {
    offers = const [];
    wave++;
    phase = RiftPhase.countdown;
    phaseTimer = countdownSeconds;
  }

  /// 런 도중 나가기 = 포기 (도달한 파도까지의 점수·보상은 그대로)
  void giveUp() => _finish(gaveUp: true);

  void _finish({required bool gaveUp, bool conquered = false}) {
    if (phase == RiftPhase.done) return;
    if (conquered) {
      score += RiftScore.clearBonus + RiftScore.timeBonus(runTime);
    }
    score = min(score, RiftScore.maxForWave(wave));
    phase = RiftPhase.done;
    outcome = RiftOutcome(
      score: score,
      reached: wave,
      cleared: conquered ? RiftPlan.waveCount : wave - 1,
      conquered: conquered,
      seconds: runTime,
      kills: kills,
      gaveUp: gaveUp,
    );
  }

  // ---------- 카드 효과 ----------
  /// 회전 칼날의 월드 좌표들
  List<Offset> get bladePositions => [
    for (var i = 0; i < loadout.blades; i++)
      player.pos + OffsetX.fromAngle(bladeAngle + i * 2 * pi / loadout.blades, RiftLoadout.bladeRadius),
  ];

  void _updateCards(double dt) {
    if (!player.alive) return;
    // 실드 재생
    if (loadout.regenPerSec > 0 && player.hp < playerMaxHp) {
      player.hp = min(playerMaxHp, player.hp + loadout.regenPerSec * dt);
    }
    // 회전 칼날
    if (loadout.blades > 0) {
      bladeAngle += dt * 3.2;
      _bladeHit.updateAll((_, t) => t - dt);
      _bladeHit.removeWhere((e, t) => t <= 0 || !pirates.contains(e));
      for (final b in bladePositions) {
        for (final e in pirates) {
          if (!e.isPirate || e.cloaked || _bladeHit.containsKey(e)) continue;
          if ((e.pos - b).distance < e.radius + 16) {
            _bladeHit[e] = RiftLoadout.bladeHitInterval;
            _hitPirate(e, loadout.bladeDamage, b);
            _spark(b, const Color(0xFFB388FF));
          }
        }
      }
    }
    // 유도 미사일
    if (loadout.homingInterval > 0 && phase == RiftPhase.fighting) {
      _homingTimer -= dt;
      if (_homingTimer <= 0 && pirates.any((e) => e.isPirate && !e.cloaked)) {
        _homingTimer = loadout.homingInterval;
        final n = loadout.homingCount;
        for (var i = 0; i < n; i++) {
          final a = player.angle + pi + (i - (n - 1) / 2) * 0.6;
          missiles.add(Missile(player.pos, OffsetX.fromAngle(a, 260), loadout.homingDamage));
        }
        sfx.add(Sfx.missile);
      }
    }
    // 충격파
    shockAge += dt;
    if (loadout.shockInterval > 0 && phase == RiftPhase.fighting) {
      _shockTimer -= dt;
      if (_shockTimer <= 0) {
        _shockTimer = loadout.shockInterval;
        var hit = false;
        for (final e in pirates) {
          if (!e.isPirate || e.cloaked) continue;
          if ((e.pos - player.pos).distance < RiftLoadout.shockRadius + e.radius) {
            _hitPirate(e, loadout.shockDamage, e.pos);
            hit = true;
          }
        }
        if (hit) {
          shockAge = 0;
          shake = min(10, shake + 4);
          sfx.add(Sfx.explode);
        }
      }
    }
    final killed = pirates.where((e) => e.hp <= 0).toList();
    for (final e in killed) {
      pirates.remove(e);
      _onKilled(e);
    }
  }

  // ---------- 엔진 동작 바꾸기 ----------
  @override
  Pirate _makePirate(
    PirateKind kind,
    Offset pos, {
    double hpMul = 1,
    double dmgMul = 1,
  }) {
    final w = currentWave;
    return Pirate(
      kind,
      pos,
      Pirate.baseHp(kind) * w.hpMul * hpMul,
      dmgScale: w.dmgMul * dmgMul,
    )..wanderAngle = _rng.nextDouble() * 2 * pi;
  }

  /// 메인 게임의 피해 처리에서 본거지 안전 구역·최종 임무·통계 이벤트·대사를 뺀 것
  @override
  bool _damagePlayer(double dmg) {
    final p = player;
    if (!p.alive || p.invulnerable > 0 || phase == RiftPhase.done) return false;
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
        ..hp = 0
        ..alive = false
        ..deadTime = 0
        ..deathPos = p.pos;
      shake = 20;
      sfx.add(Sfx.bigExplode);
      _burst(p.pos, const Color(0xFFFF7043), 70);
    }
    return true;
  }

  /// 격추: 균열 점수와 조각만 (크레딧·통계·임무·젬 없음)
  @override
  void _onKilled(Pirate e) {
    final boss = e.kind == PirateKind.boss;
    _burst(e.pos, const Color(0xFFB388FF), boss ? 100 : 30);
    sfx.add(boss ? Sfx.bigExplode : Sfx.explode);
    shake = min(20, shake + (boss ? 16 : 3));
    if (loadout.healPerKill > 0 && player.alive) {
      player.hp = min(playerMaxHp, player.hp + loadout.healPerKill);
    }
    if (!_planned.remove(e)) return;
    kills++;
    final pts = RiftScore.kill(e.kind, wave);
    score += pts;
    _float(e.pos + const Offset(0, -24), '+$pts', const Color(0xFFE1BEE7), big: boss);
    final shards = RiftScore.shards(pts);
    if (shards > 0) _dropPickups(e.pos, PickupKind.ore, shards, boss ? 10 : 2);
    if (_rng.nextDouble() < (boss ? 0 : 0.05)) {
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

  /// 조각 = 점수, 파워업은 그대로. 크레딧·젬·통계는 없다 (런 전용 프로필에도 아무것도 쌓지 않는다).
  @override
  void _collect(Pickup k) {
    switch (k.kind) {
      case PickupKind.ore:
        score += k.amount;
        sfx.add(Sfx.pickup);
        _float(k.pos, '+${k.amount}', const Color(0xFF4DD0E1));
      case PickupKind.power:
        final pk = k.power!;
        buffs[pk] = pk.duration;
        sfx.add(Sfx.upgrade);
        _float(k.pos, '${pk.icon} ${pk.label}!', const Color(0xFFB9F6CA), big: true);
      case PickupKind.credits:
      case PickupKind.gem:
        break;
    }
  }
}

/// 런 결과를 메인 게임에 반영한 내역
class RiftSettlement {
  const RiftSettlement({required this.reward, required this.newBest, required this.best, required this.mainApplied});
  final RiftReward reward;
  final bool newBest;
  final int best;

  /// 메인 게임 월드에 크레딧·광석을 넣었는지 (세이브가 없으면 false)
  final bool mainApplied;
}

extension RiftSettle on RiftOutcome {
  /// 결과를 기록하고 보상을 준다: [profile]의 균열 기록·젬('play'), [main]의 크레딧·광석(현재 항성계 배율).
  /// 런에서 생긴 다른 변화는 메인 게임에 닿지 않는다 (런은 자기 프로필·월드만 썼다).
  RiftSettlement settle({required Profile profile, GameWorld? main, required DateTime now}) {
    final rec = RiftRecords(profile.stats, onChanged: () => profile.dirty = true);
    final reward = RiftRewards.compute(
      cleared: cleared,
      rewardMul: main?.rewardMul ?? 1,
      sectorMul: main?.sectorMul ?? 1,
      runsBefore: rec.runsToday(now),
    );
    final newBest = rec.record(score: score, reached: reached, now: now);
    if (main != null) {
      main.credits += reward.credits;
      main.ore += reward.ore;
    }
    if (reward.gems > 0) profile.earnGems('play', '', reward.gems);
    GameTelemetry.emit(TelemetryEvent.riftEnd, reached);
    return RiftSettlement(reward: reward, newBest: newBest, best: rec.best, mainApplied: main != null);
  }
}
