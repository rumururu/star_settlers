import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';

GameWorld world() => GameWorld(seed: 151)
  ..spawnTimer = 1e9
  ..eventTimer = 1e9;

void main() {
  test('enemy identity is revealed only by recovered command records', () {
    final w = world();
    final unknown = w.enemySpeakerName;
    w.counters['maxSector'] = 16;
    expect(w.enemyIdentityKnown, isFalse);
    expect(w.enemySpeakerName, unknown);
    w.counters['campaignDone_16'] = 1;
    expect(w.enemyIdentityKnown, isTrue);
    expect(w.enemySpeakerName, isNot(unknown));
    final restored = GameWorld.fromJson(
      jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>,
      w.profile,
    );
    expect(restored.enemySpeakerName, w.enemySpeakerName);
  });
  test('approach is monotonic and stays at least 4600 away', () {
    final w = world();
    expect(w.antimatterApproach, 0);
    expect(w.antimatterDistance, closeTo(5400, 1e-9));
    w.update(0.05, InputState());
    expect(w.antimatterApproach, greaterThan(0));
    w.antimatterExposure = 1e9;
    expect(w.antimatterApproach, inInclusiveRange(0, 1));
    expect(w.antimatterDistance, closeTo(4600, 1e-9));
  });

  test(
    'anchor levels do not change approach; pause does not advance exposure',
    () {
      final w = world();
      w.planets.first.buildings[ColonyBuilding.stabilizer] = 3;
      w.paused = true;
      w.update(0.05, InputState());
      expect(w.antimatterExposure, 0);
      w.paused = false;
      w.update(0.05, InputState());
      expect(w.antimatterExposure, closeTo(0.05, 1e-12));
    },
  );

  test('save restores exposure; missing or corrupt values default to zero', () {
    final w = world()..antimatterExposure = 123.5;
    final json = jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>;
    expect(GameWorld.fromJson(json, w.profile).antimatterExposure, 123.5);
    for (final value in [null, -1, double.nan, double.infinity, 'bad']) {
      final changed = Map<String, dynamic>.from(json);
      if (value == null) {
        changed.remove('antimatterExposure');
      } else {
        changed['antimatterExposure'] = value;
      }
      expect(GameWorld.fromJson(changed, w.profile).antimatterExposure, 0);
    }
    w.antimatterExposure = double.infinity;
    expect(w.toJson()['antimatterExposure'], 0);
  });
}
