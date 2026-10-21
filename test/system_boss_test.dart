import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/system_traits.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart';

/// [sector]까지 실제로 워프한 세계 (항성계 특성·두목 원형은 실제 경로로 정해진다)
GameWorld warpedTo(int sector) {
  final w = GameWorld(seed: 151)
    ..credits = 1e12
    ..ore = 1e12
    ..counters['maxSector'] = 99;
  for (var i = 0; i < sector; i++) {
    expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
  }
  w.spawnTimer = w.eventTimer = w.jellyTimer = w.offerTimer = 1e9;
  return w;
}

/// 위협도를 올려 실제 스폰 경로로 두목을 부른다
Pirate summonBoss(GameWorld w, {bool sectorBoss = true}) {
  w.pirates.clear();
  w.sectorElapsed = 90 * GameWorld.threatTimeCap;
  for (var i = 0; i < 10; i++) {
    w.update(1 / 60, InputState());
    final found = w.pirates.where(
      (e) => e.kind == PirateKind.boss && e.sectorBoss == sectorBoss,
    );
    if (found.isNotEmpty) return found.first;
  }
  fail('boss did not spawn in sector ${w.sector}');
}

/// 빈 전장. 선장은 본거지·식민지 포탑에서 먼 [captain]에 멈춰 있고 피해를 받아도 죽지 않는다.
const captain = Offset(-2200, 2200);

GameWorld arena(int sector) {
  final w = GameWorld(seed: 3)
    ..spawnTimer = 1e9
    ..eventTimer = 1e9
    ..jellyTimer = 1e9
    ..offerTimer = 1e9
    ..sector = sector;
  w.pirates.clear();
  w.asteroids.clear();
  w.mines.clear();
  w.player
    ..pos = captain
    ..vel = Offset.zero
    ..invulnerable = 0
    ..hp = 1e6;
  return w;
}

/// 원형 두목 하나. 기존 원형 탄막·일반 사격은 꺼서 원형 기제만 본다.
Pirate boss(GameWorld w, BossArchetype a, Offset pos, {double hp = 5000}) {
  final e = Pirate(PirateKind.boss, pos, hp)
    ..sectorBoss = true
    ..archetype = a
    ..archetypeTimer = 0
    ..specialTimer = 1e9
    ..fireCooldown = 1e9
    ..angle = -pi / 2;
  w.pirates.add(e);
  return e;
}

void step(GameWorld w, double seconds, {double dt = 1 / 60}) {
  for (var t = 0.0; t < seconds - 1e-9; t += dt) {
    w.player
      ..vel = Offset.zero
      ..invulnerable = 0
      ..guardCooldown = 1e9;
    w.update(dt, InputState());
  }
}

int escorts(GameWorld w, Pirate e) =>
    w.pirates.where((o) => identical(o.parent, e)).length;

void main() {
  group('archetype assignment', () {
    test('trait table maps every trait to its own archetype', () {
      expect(null.bossArchetype, isNull);
      expect(SystemTrait.pirateNest.bossArchetype, BossArchetype.fleet);
      expect(SystemTrait.richVeins.bossArchetype, BossArchetype.devourer);
      expect(SystemTrait.solarFlare.bossArchetype, BossArchetype.flare);
      expect(SystemTrait.ionNebula.bossArchetype, BossArchetype.wraith);
      expect(SystemTrait.gravityWell.bossArchetype, BossArchetype.gravity);
      expect(SystemTrait.tradeLane.bossArchetype, BossArchetype.plunder);
      expect(
        SystemTrait.values.map((t) => t.bossArchetype).toSet().length,
        SystemTrait.values.length,
      );
    });

    test('Sol sector boss keeps the original pattern (no archetype)', () {
      final w = warpedTo(0);
      final e = summonBoss(w);
      expect(e.archetype, isNull);
      expect(e.speed, 150);
      expect(w.dialogs.map((d) => d.text), contains(tr.g_dlgBossWarning));
    });

    for (final (sector, archetype) in const [
      (1, BossArchetype.plunder),
      (2, BossArchetype.devourer),
      (3, BossArchetype.flare),
      (4, BossArchetype.fleet),
      (5, BossArchetype.wraith),
      (6, BossArchetype.gravity),
    ]) {
      test('sector $sector boss is ${archetype.name} with a named warning', () {
        final w = warpedTo(sector);
        expect(w.trait!.bossArchetype, archetype);
        final e = summonBoss(w);
        expect(e.archetype, archetype);
        // 체력은 기존 항성계 두목과 같다 (hpMul 1.6)
        expect(e.kind, PirateKind.boss);
        final warning = tr.g_dlgBossArchetype(archetype.name);
        expect(warning, isNotEmpty);
        expect(warning, contains(tr.u_bossName(archetype.name).substring(2)));
        expect(w.dialogs.map((d) => d.text), contains(warning));
        expect(
          w.dialogs.map((d) => d.text),
          isNot(contains(tr.g_dlgBossWarning)),
        );
      });
    }

    test('respawning boss after the sector boss has no archetype', () {
      final w = warpedTo(4);
      w.bossDefeated = true;
      final e = summonBoss(w, sectorBoss: false);
      expect(e.sectorBoss, isFalse);
      expect(e.archetype, isNull);
      expect(e.speed, 150);
    });

    test('every locale names all six archetypes and warnings', () {
      for (final locale in L10n.supportedLocales) {
        final t = lookupL10n(locale);
        for (final a in BossArchetype.values) {
          final name = t.u_bossName(a.name);
          expect(name.length, greaterThan(3), reason: '$locale ${a.name}');
          // 경고 문장에는 두목 이름이 들어간다 (이름표의 ☠ 접두 제외)
          expect(
            t.g_dlgBossArchetype(a.name),
            contains(name.substring(2)),
            reason: '$locale ${a.name}',
          );
        }
      }
    });
  });

  group('fleet (pirate nest)', () {
    test('calls 2 raider escorts every 10 s, at most 6 on the map', () {
      final w = arena(4);
      final e = boss(w, BossArchetype.fleet, captain + const Offset(0, -700));
      step(w, 1 / 60);
      expect(escorts(w, e), 2);
      expect(
        w.pirates.where((o) => identical(o.parent, e)).map((o) => o.kind),
        everyElement(PirateKind.raider),
      );
      step(w, 9.8);
      expect(escorts(w, e), 2, reason: 'no new escort before 10 s');
      step(w, 0.4);
      expect(escorts(w, e), 4);
      for (var i = 0; i < 3; i++) {
        e.archetypeTimer = 0;
        step(w, 1 / 60);
      }
      expect(escorts(w, e), BossArchetype.escortMax);
      // 하나가 격추되면 다음 소환에서 상한까지만 채운다
      w.pirates.remove(w.pirates.firstWhere((o) => identical(o.parent, e)));
      e.archetypeTimer = 0;
      step(w, 1 / 60);
      expect(escorts(w, e), BossArchetype.escortMax);
    });
  });

  group('devourer (rich veins)', () {
    test('scatters 3 mines around itself every 5 s, sharing the map cap', () {
      final w = arena(2);
      final e = boss(
        w,
        BossArchetype.devourer,
        captain + const Offset(0, -1000),
      );
      step(w, 1 / 60);
      expect(w.mines.length, 3);
      for (final m in w.mines) {
        expect((m.pos - e.pos).distance, lessThan(e.radius + 60));
      }
      step(w, 4.8);
      expect(w.mines.length, 3);
      step(w, 0.4);
      expect(w.mines.length, 6);
      // 맵 최대치 18은 기뢰 부설선과 같이 쓴다
      while (w.mines.length < 17) {
        w.mines.add(SpaceMine(const Offset(-3000, -3000), 10));
      }
      e.archetypeTimer = 0;
      step(w, 1 / 60);
      expect(w.mines.length, 18);
    });
  });

  group('flare (solar flare)', () {
    test('charges 1.5 s with aim lines, then fires a 3-way laser (±20°)', () {
      final w = arena(3);
      final e = boss(w, BossArchetype.flare, captain + const Offset(700, 0));
      step(w, 1 / 60);
      expect(e.charge, greaterThan(1.4));
      expect(w.beams.where((b) => b.hostile), isEmpty);
      final hp = w.player.hp;
      var fired = <LaserBeam>[];
      for (var i = 0; i < 120 && fired.isEmpty; i++) {
        step(w, 1 / 60);
        fired = w.beams.where((b) => b.hostile).toList();
      }
      expect(fired.length, 3);
      expect(e.charge, 0);
      // 조준 방향 기준 상대 각도 (−π~π로 정규화)
      final rel = fired.map((b) {
        final a = atan2(b.to.dy - b.from.dy, b.to.dx - b.from.dx) - e.aimAngle;
        return atan2(sin(a), cos(a));
      }).toList()..sort();
      expect(rel[0], closeTo(-BossArchetype.flareSpread, 1e-6));
      expect(rel[1], closeTo(0, 1e-6));
      expect(rel[2], closeTo(BossArchetype.flareSpread, 1e-6));
      // 가운데 줄기는 멈춰 있는 선장을 맞힌다
      expect(w.player.hp, lessThan(hp));
      // 다음 발사는 7초 뒤
      expect(e.archetypeTimer, greaterThan(5));
    });
  });

  group('wraith (ion nebula)', () {
    test('cloaks 4 s / reveals 4 s and ignores hits while cloaked', () {
      final w = arena(5);
      final e = boss(w, BossArchetype.wraith, captain + const Offset(0, -800));
      step(w, 1 / 60);
      expect(e.cloaked, isTrue);
      w.bullets.add(Bullet(e.pos, Offset.zero, 100, true));
      step(w, 1 / 60);
      expect(e.hp, e.maxHp, reason: 'cloaked boss takes no damage');
      step(w, 3.8);
      expect(e.cloaked, isTrue);
      step(w, 0.4);
      expect(e.cloaked, isFalse);
      w.bullets.add(Bullet(e.pos, Offset.zero, 100, true));
      step(w, 1 / 60);
      expect(e.hp, lessThan(e.maxHp));
      step(w, 4);
      expect(e.cloaked, isTrue);
    });
  });

  group('gravity (gravity well)', () {
    test('pulls the captain 120/s within 700, not while boosting', () {
      final w = arena(6);
      final e = boss(w, BossArchetype.gravity, captain + const Offset(0, -500));
      final start = w.player.pos;
      step(w, 1);
      final pulled = w.player.pos - start;
      expect(pulled.distance, closeTo(BossArchetype.gravityPull, 6));
      expect(pulled.dy, lessThan(0), reason: 'toward the boss');

      final before = w.player.pos;
      for (var i = 0; i < 60; i++) {
        w.boostTime = 1;
        step(w, 1 / 60);
      }
      expect((w.player.pos - before).distance, lessThan(1));

      w.boostTime = 0;
      e.pos =
          w.player.pos + const Offset(0, -(BossArchetype.gravityRange + 400));
      e.vel = Offset.zero;
      final far = w.player.pos;
      step(w, 0.5);
      expect(
        (w.player.pos - far).distance,
        lessThan(1),
        reason: 'out of range',
      );
    });
  });

  group('plunder (trade lane)', () {
    test('moves 1.4x faster than the plain boss', () {
      final w = arena(1);
      final e = boss(w, BossArchetype.plunder, const Offset(0, 0));
      final plain = Pirate(PirateKind.boss, Offset.zero, 100);
      expect(e.speed, closeTo(plain.speed * 1.4, 1e-9));
      expect(w.pirates, contains(e));
    });

    test('steals 1% per hit up to half the kill reward, returned on kill', () {
      final w = arena(1)..credits = 10000;
      final e = boss(
        w,
        BossArchetype.plunder,
        captain + const Offset(0, -1500),
      );
      e.archetypeTimer = 1e9;
      void hitPlayer() {
        w.bullets.add(Bullet(w.player.pos, Offset.zero, 5, false, source: e));
        final b = w.player.pos;
        step(w, 1 / 60);
        w.player.pos = b;
      }

      hitPlayer();
      expect(e.plundered, closeTo(100, 1));
      expect(w.credits, lessThan(9901));

      // 다른 적의 탄은 훔치지 않는다
      final other = Pirate(PirateKind.raider, const Offset(0, -2500), 100);
      w.bullets.add(Bullet(w.player.pos, Offset.zero, 5, false, source: other));
      step(w, 1 / 60);
      expect(e.plundered, closeTo(100, 1));

      // 무적(막힌 피격)이면 훔치지 않는다
      w.player.invulnerable = 5;
      w.bullets.add(Bullet(w.player.pos, Offset.zero, 5, false, source: e));
      w.update(1 / 60, InputState());
      expect(e.plundered, closeTo(100, 1));

      // 상한: 항성계 두목 처치 보상의 50%
      w.credits = 1e9;
      final cap = w.sectorBossReward * BossArchetype.plunderCapRatio;
      for (var i = 0; i < 5; i++) {
        hitPlayer();
      }
      expect(e.plundered, closeTo(cap, 1e-6));

      // 처치하면 빼앗긴 만큼 + 기존 보상
      final before = w.credits;
      final reward = w.sectorBossReward;
      w.bullets.add(Bullet(e.pos, Offset.zero, 1e9, true));
      step(w, 1 / 60);
      expect(w.pirates, isNot(contains(e)));
      expect(w.bossDefeated, isTrue);
      final income = w.creditIncome / 60 + 1;
      expect(w.credits - before, closeTo(cap + reward, income));
      expect(
        w.dialogs.map((d) => d.text),
        contains(tr.g_dlgBossDefeated(reward + cap.round())),
      );
    });
  });

  group('Haven laser vs bosses', () {
    test('a sector boss spawned 650 from the base survives 20 s untouched', () {
      // 실기기 재현과 같은 조건: 섹터 1(교역로), 선장은 본거지 옆, 입력 없음
      final w = warpedTo(1);
      final e = summonBoss(w);
      expect(e.archetype, BossArchetype.plunder);
      final base = w.homeBase.pos;
      w.player
        ..pos = base + const Offset(40, 0)
        ..vel = Offset.zero;
      e
        ..pos = base + const Offset(650, 0)
        ..vel = Offset.zero;
      expect((e.pos - base).distance, lessThan(w.homeBase.laserRange));
      for (var t = 0.0; t < 20; t += 1 / 60) {
        w.update(1 / 60, InputState());
      }
      expect(w.pirates, contains(e));
      expect(e.hp, greaterThan(0));
      expect(w.bossDefeated, isFalse);
      // 한 발 0.6% → 20초 동안 많아야 약 55%
      final shots = (20 / w.homeBase.laserInterval).ceil() + 1;
      expect(
        e.hp,
        greaterThanOrEqualTo(
          e.maxHp * (1 - GameWorld.havenSectorBossDamageRatio * shots),
        ),
      );
    });

    double firstLaserHit(Pirate e) {
      final w = arena(1);
      final base = w.homeBase.pos;
      w.player.pos = base;
      e
        ..pos = base + const Offset(650, 0)
        ..specialTimer = 1e9
        ..fireCooldown = 1e9;
      w.pirates.add(e);
      for (var i = 0; i < 120 && e.hp == e.maxHp; i++) {
        w.player.pos = base;
        w.update(1 / 60, InputState());
      }
      expect(w.beams.where((b) => !b.hostile), isNotEmpty);
      return e.maxHp - e.hp;
    }

    test('per-shot cap: sector boss 0.6% of max HP, plain boss keeps 4%', () {
      final sectorBoss = Pirate(PirateKind.boss, Offset.zero, 2000)
        ..sectorBoss = true
        ..archetype = BossArchetype.plunder;
      expect(
        firstLaserHit(sectorBoss),
        closeTo(2000 * GameWorld.havenSectorBossDamageRatio, 1e-6),
      );
      final plain = Pirate(PirateKind.boss, Offset.zero, 2000);
      expect(
        firstLaserHit(plain),
        closeTo(2000 * GameWorld.havenBossDamageRatio, 1e-6),
      );
      // 잡몹은 상한 없이 레이저 피해 그대로
      final raider = Pirate(PirateKind.raider, Offset.zero, 2000);
      expect(firstLaserHit(raider), greaterThan(2000 * 0.04));
    });
  });
}
