import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';
import 'stabilizer_test.dart' as helper;

void main() {
  test(
    'bomber hits reserve; upgrades and reload cannot bypass depleted cooldown',
    () {
      final w = helper.setup();
      final p = w.planets.first;
      helper.install(w, p, 1);
      p.shieldHp = 0;
      p.shieldBroken = true;
      p.sinceShieldHit = 0;
      final before = p.relayShieldHp;
      w.player.pos = p.pos + const Offset(20, 0);
      w.pirates.add(
        Pirate(PirateKind.bomber, p.pos + const Offset(10, 0), 100),
      );
      w.update(.001, InputState());
      expect(p.relayShieldHp, lessThan(before));
      expect(p.stabilizerHp, 150);
      helper.shoot(w, p, 10000);
      final cooldown = p.relayShieldCooldown;
      helper.install(w, p, 2);
      expect(p.relayShieldHp, 0);
      expect(p.relayShieldCooldown, cooldown);
      final loaded = helper.reload(w);
      expect(loaded.planets.first.relayShieldHp, 0);
      expect(loaded.planets.first.relayShieldCooldown, cooldown);
    },
  );

  test('reserve absorbs real bullets independently and persists cooldown', () {
    final w = helper.setup();
    final p = w.planets.first;
    final other = w.planets[1];
    helper.install(w, p, 2);
    helper.install(w, other, 1);
    final otherHp = other.relayShieldHp;
    helper.shoot(w, p, p.shieldHp + 10000);
    expect(w.relayShieldActive(p), isTrue);
    helper.shoot(w, p, 100);
    expect(p.stabilizerHp, 300);
    expect(other.relayShieldHp, otherHp);
    helper.shoot(w, p, p.relayShieldHp + 10000);
    expect(p.stabilizerHp, 300);
    expect(p.relayShieldCooldown, greaterThan(29));
    helper.shoot(w, p, 160);
    expect(p.stabilizerHp, 140);
    expect(p.building(ColonyBuilding.stabilizer), 1);
    final loaded = helper.reload(w);
    expect(loaded.planets.first.relayShieldCooldown, p.relayShieldCooldown);
    for (var i = 0; i < 700; i++) {
      w.update(.05, InputState());
    }
    expect(p.stabilizerHp, 150);
    expect(p.building(ColonyBuilding.stabilizer), 1);
    expect(p.relayShieldHp, greaterThan(0));
  });

  test(
    'both levels strengthen support; disabled Haven preserves local defense',
    () {
      final w = helper.setup();
      final p = w.planets.first;
      helper.install(w, p, 1);
      final initial = w.relayShieldMax(p);
      final regen = w.relayRegenMultiplier(p);
      w.homeBase.baseLevel++;
      expect(w.relayShieldMax(p), greaterThan(initial));
      expect(w.relayRegenMultiplier(p), greaterThan(regen));
      final upgraded = w.relayShieldMax(p);
      helper.install(w, p, 2);
      expect(w.relayShieldMax(p), greaterThan(upgraded));
      final reserve = p.relayShieldHp;
      w.homeBase.disabledTime = 100;
      expect(w.relayConnected(p), isFalse);
      expect(p.domeUp, isTrue);
      helper.shoot(w, p, p.shieldHp + 1);
      expect(w.relayShieldActive(p), isFalse);
      helper.shoot(w, p, 10);
      expect(p.stabilizerHp, 290);
      for (var i = 0; i < 200; i++) {
        w.update(.05, InputState());
      }
      expect(p.stabilizerHp, 290);
      expect(p.relayShieldHp, reserve);
    },
  );
}
