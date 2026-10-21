import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/campaign.dart';
import 'package:star_settlers/game/star_catalog.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/ui/star_systems.dart';

void main() {
  test('every named system has its own sky', () {
    expect(starSystemLookCount, catalogSystemCount);
    expect(catalogSystemCount, campaignFinalSector + 1);
  });

  test('stars stay clear of the home station and the first planet orbit', () {
    for (var sector = 0; sector < 60; sector++) {
      final look = starSystemLook(sector);
      expect(look.bodies, isNotEmpty);
      for (var t = 0.0; t < 120; t += 0.5) {
        for (final b in look.bodies) {
          final reach = b.posAt(t).distance + GameWorld.starRadius * b.size;
          expect(
            reach,
            lessThan(GameWorld.homePos.distance - 150),
            reason: 'sector $sector',
          );
        }
      }
    }
  });

  test('twins point at a partner that points back', () {
    for (var sector = 0; sector < 60; sector++) {
      final bodies = starSystemLook(sector).bodies;
      for (var i = 0; i < bodies.length; i++) {
        final p = bodies[i].partner;
        if (p == null) continue;
        expect(bodies[p].partner, i, reason: 'sector $sector');
        // 짝은 늘 반대편에 있어 마주 볼 수 있다
        expect(
          (bodies[i].posAt(3) - bodies[p].posAt(3)).distance,
          greaterThan(100),
        );
      }
    }
  });

  test('unnamed systems are stable and not all alike', () {
    final faces = <String>{};
    for (var s = catalogSystemCount; s < catalogSystemCount + 30; s++) {
      final a = starSystemLook(s), b = starSystemLook(s);
      expect(identical(a, b), isTrue);
      faces.add(a.bodies.map((x) => x.face.name).join('+'));
    }
    expect(faces.length, greaterThan(min(4, 30)));
  });
}
