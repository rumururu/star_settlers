import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';

GameWorld setup() => GameWorld(seed: 151)
  ..credits = 1e8
  ..ore = 1e8
  ..spawnTimer = 1e9
  ..eventTimer = 1e9;

void install(GameWorld w, Planet p, int level) {
  while (p.colonyLevel < level) {
    expect(w.upgradePlanet(p), isTrue);
  }
  while (p.building(ColonyBuilding.stabilizer) < level) {
    expect(w.buildColony(p, ColonyBuilding.stabilizer), isTrue);
  }
}

void shoot(GameWorld w, Planet p, double damage, {bool friendly = false}) {
  w.bullets.add(Bullet(p.pos, Offset.zero, damage, friendly));
  w.update(0.001, InputState());
}

void expose(Planet p) {
  p.relayShieldHp = 0;
  p.relayShieldCooldown = 30;
  p.shieldHp = 0;
  p.shieldBroken = true;
  p.sinceShieldHit = 0;
}

GameWorld reload(GameWorld w) => GameWorld.fromJson(
  jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>,
  w.profile,
);

void main() {
  test(
    'colony upgrades alone give no completion; device obeys colony capacity and charges resources',
    () {
      final w = setup();
      final p = w.planets.first;
      expect(w.buildColony(p, ColonyBuilding.stabilizer), isFalse);
      w.upgradePlanet(p);
      expect(w.development, 0);
      final cost = w.colonyBuildingCost(p, ColonyBuilding.stabilizer);
      final before = (w.credits, w.ore);
      expect(w.buildColony(p, ColonyBuilding.stabilizer), isTrue);
      expect(w.credits, before.$1 - cost.$1);
      expect(w.ore, before.$2 - cost.$2);
      expect(p.stabilizerHp, 150);
      expect(w.buildColony(p, ColonyBuilding.stabilizer), isFalse);
      expect(w.development, closeTo(1 / 27, 1e-9));
    },
  );

  test(
    'higher device levels compensate for other planets; total is capped at 100%',
    () {
      final w = setup();
      // 4+4+4+4+4+4+3 = 27. Two planets remain uncolonized.
      for (var i = 0; i < 6; i++) {
        install(w, w.planets[i], 4);
      }
      install(w, w.planets[6], 3);
      expect(w.planets.last.colonyLevel, 0);
      expect(w.development, 1);
      expect(w.gateOpen(w.gates.first), isTrue);
      install(w, w.planets[6], 4);
      expect(w.development, 1);
    },
  );

  test(
    'shield-breaking hit does not spill; later hits remove device levels and lock unvisited gate',
    () {
      final w = setup();
      for (final p in w.planets) {
        install(w, p, 3);
      }
      final p = w.planets.first;
      shoot(w, p, p.shieldHp + 1000);
      expect(p.shieldBroken, isTrue);
      expect(p.stabilizerHp, 450);
      expect(w.development, 1);
      shoot(w, p, p.relayShieldHp + 1000);
      expect(p.stabilizerHp, 450);
      shoot(w, p, 149);
      expect(p.stabilizerHp, 301);
      expect(p.building(ColonyBuilding.stabilizer), 3);
      shoot(w, p, 1);
      expect(p.building(ColonyBuilding.stabilizer), 2);
      expect(w.development, closeTo(26 / 27, 1e-9));
      expect(w.gateOpen(w.gates.first), isFalse);
      expect(p.colonyLevel, 3);
      shoot(w, p, 1000);
      expect(p.building(ColonyBuilding.stabilizer), 0);
      expect(p.stabilizerHp, 0);
      expect(w.buildColony(p, ColonyBuilding.stabilizer), isTrue);
      expect(p.building(ColonyBuilding.stabilizer), 1);
      expect(p.stabilizerHp, 150);
    },
  );

  test(
    'friendly shots do not damage exposed device and surviving partial damage recovers after combat',
    () {
      final w = setup();
      final p = w.planets.first;
      install(w, p, 2);
      expose(p);
      shoot(w, p, 500, friendly: true);
      expect(p.stabilizerHp, 300);
      shoot(w, p, 10);
      expect(p.stabilizerHp, 290);
      for (var i = 0; i < 400; i++) {
        w.update(0.05, InputState());
      }
      expect(p.stabilizerHp, 300);
      expect(p.domeUp, isTrue);
      shoot(w, p, 10);
      expect(p.stabilizerHp, 300);
    },
  );

  test(
    'partial damage and shield state survive save/load and sector round trip',
    () {
      var w = setup();
      final p = w.planets.first;
      install(w, p, 3);
      expose(p);
      shoot(w, p, 185);
      expect(p.stabilizerHp, 265);
      w = reload(w);
      expect(w.planets.first.stabilizerHp, 265);
      expect(w.planets.first.building(ColonyBuilding.stabilizer), 2);
      expect(w.planets.first.shieldBroken, isTrue);
      w.counters['maxSector'] = 1;
      expect(w.warp(w.gates.first), isTrue);
      final saved = w.sectors[0]!;
      expect(saved.development, closeTo(2 / 27, 1e-9));
      expect(w.warp(w.gates.firstWhere((g) => !g.forward)), isTrue);
      expect(w.planets.first.stabilizerHp, 265);
      expect(w.planets.first.shieldBroken, isTrue);
    },
  );

  test(
    'old saves migrate current AND remote progress once; destroyed zero never resurrects',
    () {
      var w = setup();
      w.counters['maxSector'] = 1;
      install(w, w.planets.first, 5);
      w.warp(w.gates.first);
      install(w, w.planets.first, 2);
      final json = jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>;
      final saves = [json['current'], ...(json['sectors'] as Map).values];
      for (final dynamic s in saves) {
        s.remove('defenses');
        for (final dynamic row in s['bld']) {
          row.removeLast();
        }
      }
      w = GameWorld.fromJson(json, w.profile);
      expect(w.planets.first.building(ColonyBuilding.stabilizer), 2);
      expect(w.sectors[0]!.development, closeTo(3 / 27, 1e-9));
      w.warp(w.gates.firstWhere((g) => !g.forward));
      expect(w.planets.first.building(ColonyBuilding.stabilizer), 3);
      final p = w.planets.first;
      expose(p);
      shoot(w, p, 10000);
      w = reload(w);
      expect(w.planets.first.building(ColonyBuilding.stabilizer), 0);
      expect(w.planets.first.stabilizerHp, 0);
      expect(w.development, 0);
    },
  );

  test('a bomber explosion damages an exposed device', () {
    final w = setup();
    final p = w.planets.first;
    install(w, p, 2);
    expose(p);
    w.player.pos = p.pos + const Offset(20, 0);
    final enemy = Pirate(PirateKind.bomber, p.pos + const Offset(10, 0), 100);
    w.pirates.add(enemy);
    w.update(0.001, InputState());
    expect(w.pirates, isNot(contains(enemy)));
    expect(p.stabilizerHp, lessThan(300));
  });

  test(
    'Lv.1 anchors on every planet keep the gate closed until the level sum reaches planets × 3',
    () {
      final w = setup();
      final forward = w.gates.firstWhere((g) => g.forward);
      for (final p in w.planets) {
        install(w, p, 1);
      }
      expect(w.development, closeTo(1 / 3, 1e-9));
      expect(w.gateOpen(forward), isFalse);
      // 태양계 상한 Lv.4까지 일부 행성을 올려도 합계가 모자라면 닫혀 있다
      for (final p in w.planets.take(3)) {
        install(w, p, 4);
      }
      expect(w.gateOpen(forward), isFalse);
      for (final p in w.planets) {
        install(w, p, 3);
      }
      expect(w.development, 1);
      expect(w.gateOpen(forward), isTrue);
    },
  );

  test('anchor levels raise colony credit income by 10% each', () {
    final w = setup();
    final p = w.planets.first;
    install(w, p, 1);
    p.buildings[ColonyBuilding.stabilizer] = 0;
    final base = p.baseCreditRate;
    for (var lv = 1; lv <= 3; lv++) {
      p.buildings[ColonyBuilding.stabilizer] = lv;
      expect(p.baseCreditRate, closeTo(base * (1 + .1 * lv), 1e-9));
    }
  });
}
