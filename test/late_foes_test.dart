import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';

/// 세 번째 이후 항성계처럼 꾸민 빈 전장. 선장은 (0, 2000)에 멈춰 있다.
GameWorld arena({int sector = 6}) {
  final w = GameWorld(seed: 3)
    ..spawnTimer = 1e9
    ..eventTimer = 1e9
    ..jellyTimer = 1e9
    ..sector = sector;
  w.pirates.clear();
  w.asteroids.clear();
  w.player
    ..pos = const Offset(0, 2000)
    ..vel = Offset.zero
    ..invulnerable = 0
    ..hp = 1e6;
  return w;
}

Pirate foe(GameWorld w, PirateKind k, Offset pos, {double hp = 1000}) {
  final e = Pirate(k, pos, hp)..angle = -pi / 2;
  w.pirates.add(e);
  return e;
}

void step(GameWorld w, double seconds, {double dt = 1 / 60}) {
  for (var t = 0.0; t < seconds; t += dt) {
    w.player
      ..vel = Offset.zero
      ..invulnerable = 0;
    w.update(dt, InputState());
  }
}

void main() {
  test('late foes unlock by star system', () {
    expect(GameWorld.lateFoeKinds(1), isEmpty);
    expect(GameWorld.lateFoeKinds(2), {PirateKind.missile, PirateKind.mine});
    expect(GameWorld.lateFoeKinds(6).length, 8);
  });

  test('missile carrier fires homing missiles that chase the captain', () {
    final w = arena();
    final e = foe(w, PirateKind.missile, const Offset(600, 2000))
      ..abilityTimer = 0;
    step(w, 0.05);
    expect(w.enemyMissiles.length, 2);
    final hp = w.player.hp;
    e.abilityTimer = 99;
    step(w, 5);
    expect(w.player.hp, lessThan(hp));
  });

  test('a player bullet shoots a homing missile down', () {
    final w = arena();
    w.enemyMissiles.add(
      EnemyMissile(const Offset(300, 2000), const Offset(-250, 0), 10),
    );
    w.bullets.add(Bullet(const Offset(305, 2000), Offset.zero, 5, true));
    step(w, 1 / 60);
    expect(w.enemyMissiles, isEmpty);
  });

  test(
    'laser charges, then hits along its line; dodging after lock avoids it',
    () {
      final w = arena();
      final e = foe(w, PirateKind.laser, const Offset(700, 2000))
        ..abilityTimer = 0;
      step(w, 0.05);
      expect(e.charge, greaterThan(0));
      final hp = w.player.hp;
      step(w, 1.3);
      expect(w.player.hp, lessThan(hp));
      expect(w.beams.any((b) => b.hostile), isTrue);

      final w2 = arena();
      final e2 = foe(w2, PirateKind.laser, const Offset(700, 2000))
        ..abilityTimer = 0;
      step(w2, 0.9); // 조준이 고정된 뒤
      expect(e2.charge, lessThan(0.45));
      w2.player.pos = const Offset(0, 2300); // 옆으로 피함
      final hp2 = w2.player.hp;
      step(w2, 0.5);
      expect(w2.player.hp, hp2);
    },
  );

  test('warden halves damage to nearby allies but not to itself', () {
    final w = arena();
    final ally = foe(w, PirateKind.raider, const Offset(1500, 2000));
    final warden = foe(w, PirateKind.warden, const Offset(1600, 2000));
    w.bullets.add(Bullet(ally.pos, Offset.zero, 100, true));
    w.bullets.add(Bullet(warden.pos, Offset.zero, 100, true));
    step(w, 1 / 60);
    expect(ally.hp, closeTo(950, 1e-6));
    expect(warden.hp, closeTo(900, 1e-6));
  });

  test('cloaked phantom cannot be hit', () {
    final w = arena();
    final e = foe(w, PirateKind.phantom, const Offset(1500, 2000))
      ..cloaked = true
      ..abilityTimer = 99;
    w.bullets.add(Bullet(e.pos, Offset.zero, 100, true));
    step(w, 1 / 60);
    expect(e.hp, 1000);
    e.cloaked = false;
    w.bullets.add(Bullet(e.pos, Offset.zero, 100, true));
    step(w, 1 / 60);
    expect(e.hp, lessThan(1000));
  });

  test(
    'mine layer drops mines; armed mines explode near the captain; shot mines vanish',
    () {
      final w = arena();
      foe(w, PirateKind.mine, const Offset(1500, 2000)).abilityTimer = 0;
      step(w, 0.05);
      expect(w.mines.length, 1);
      w.mines
        ..clear()
        ..add(SpaceMine(const Offset(40, 2000), 20)..arm = 0);
      final hp = w.player.hp;
      step(w, 1 / 60);
      expect(w.mines, isEmpty);
      expect(w.player.hp, hp - 20);
      w.mines.add(SpaceMine(const Offset(900, 2000), 20));
      w.bullets.add(Bullet(const Offset(905, 2000), Offset.zero, 5, true));
      step(w, 1 / 60);
      expect(w.mines, isEmpty);
    },
  );

  test('repair tender heals wounded allies nearby', () {
    final w = arena();
    final ally = foe(w, PirateKind.raider, const Offset(1500, 2000), hp: 100)
      ..hp = 50;
    foe(w, PirateKind.medic, const Offset(1600, 2000)).abilityTimer = 0;
    step(w, 0.05);
    expect(ally.hp, closeTo(62, 1e-6));
  });

  test('juggernaut front armor blocks 60%; rear hits do full damage', () {
    final w = arena();
    final j = foe(w, PirateKind.juggernaut, const Offset(1500, 1000))
      ..abilityTimer = 99
      ..angle = pi / 2; // 아래(선장 쪽)를 본다
    // 정면(아래)에서 위로 날아오는 탄
    w.bullets.add(Bullet(j.pos, const Offset(0, -900), 100, true));
    step(w, 1 / 60);
    expect(j.hp, closeTo(960, 1e-6));
    // 뒤(위)에서 아래로 날아오는 탄
    w.bullets.add(Bullet(j.pos, const Offset(0, 900), 100, true));
    step(w, 1 / 60);
    expect(j.hp, closeTo(860, 1e-6));
  });

  test('carrier launches at most four drones', () {
    final w = arena();
    final c = foe(w, PirateKind.carrier, const Offset(1500, 2000));
    for (var i = 0; i < 4; i++) {
      c.abilityTimer = 0;
      step(w, 0.05);
    }
    expect(w.pirates.where((p) => identical(p.parent, c)).length, 4);
  });

  test('ordnance is cleared when changing star system', () {
    final w = arena(sector: 0);
    w.enemyMissiles.add(EnemyMissile(Offset.zero, Offset.zero, 1));
    w.mines.add(SpaceMine(Offset.zero, 1));
    w.counters['maxSector'] = 1;
    w.warp(w.gates.firstWhere((g) => g.forward));
    expect(w.enemyMissiles, isEmpty);
    expect(w.mines, isEmpty);
  });
}
