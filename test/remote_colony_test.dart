import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';

GameWorld setup() => GameWorld(seed: 151)
  ..credits = 1e9
  ..ore = 1e9
  ..spawnTimer = 1e9
  ..eventTimer = 1e9;

/// 태양계 행성 하나를 Lv.2·정박기 Lv.1로 만들고 다음 항성계로 떠난다
(GameWorld, int) leaveSol() {
  final w = setup();
  final p = w.planets[2];
  w.upgradePlanet(p);
  w.upgradePlanet(p);
  w.buildColony(p, ColonyBuilding.stabilizer);
  w.counters['maxSector'] = 1;
  expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
  expect(w.sector, 1);
  return (w, 2);
}

void main() {
  test('remote copy matches what was left behind', () {
    final (w, i) = leaveSol();
    final p = w.remotePlanet(0, i);
    expect(p.colonyLevel, 2);
    expect(p.building(ColonyBuilding.stabilizer), 1);
  });

  test(
    'remote colony level-up costs the same as at home and raises remote income',
    () {
      final (w, i) = leaveSol();
      final before = w.otherSectorCredits;
      final p = w.remotePlanet(0, i);
      final cost = w.remotePlanetCost(0, p);
      expect(cost, (
        (p.baseCost().$1 * GameWorld.costMulAt(0)).round(),
        (p.baseCost().$2 * GameWorld.costMulAt(0)).round(),
      ));
      final credits = w.credits;
      expect(w.upgradeRemotePlanet(0, i), isTrue);
      expect(w.credits, credits - cost.$1);
      expect(w.remotePlanet(0, i).colonyLevel, 3);
      expect(w.otherSectorCredits, greaterThan(before));
      // 남은 수입 = 저장 상태로 다시 계산한 값과 같다
      final expected = [
        for (var k = 0; k < w.sectors[0]!.colonyLevels.length; k++)
          w.remotePlanet(0, k).baseCreditRate,
      ].fold(0.0, (a, b) => a + b);
      final stationIncome = w.sectors[0]!.idleCredits - expected;
      expect(stationIncome, greaterThanOrEqualTo(-1e-9));
    },
  );

  test(
    'remote anchor level-up respects the colony cap and survives warping back and saving',
    () {
      final (w, i) = leaveSol();
      expect(
        w.upgradeRemotePlanet(0, i, building: ColonyBuilding.stabilizer),
        isTrue,
      );
      // 식민지 Lv.2 → 정박기도 Lv.2가 상한
      expect(
        w.upgradeRemotePlanet(0, i, building: ColonyBuilding.stabilizer),
        isFalse,
      );
      final restored = GameWorld.fromJson(
        jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>,
        w.profile,
      );
      expect(
        restored.remotePlanet(0, i).building(ColonyBuilding.stabilizer),
        2,
      );
      expect(w.warp(w.gates.firstWhere((g) => !g.forward)), isTrue);
      final p = w.planets[i];
      expect(p.colonyLevel, 2);
      expect(p.building(ColonyBuilding.stabilizer), 2);
      expect(p.stabilizerHp, p.stabilizerMaxHp(w.sectorMul));
    },
  );

  test('cannot upgrade an unsettled remote planet or without money', () {
    final (w, i) = leaveSol();
    expect(w.upgradeRemotePlanet(0, 5), isFalse);
    w.credits = 0;
    expect(w.upgradeRemotePlanet(0, i), isFalse);
    expect(w.remotePlanet(0, i).colonyLevel, 2);
  });

  test(
    'legacy saves without buildings get the same anchor migration remotely',
    () {
      final (w, i) = leaveSol();
      final j = w.sectors[0]!.toJson()..remove('bld');
      w.sectors[0] = SectorSave.fromJson(
        jsonDecode(jsonEncode(j)) as Map<String, dynamic>,
      );
      expect(w.remotePlanet(0, i).building(ColonyBuilding.stabilizer), 2);
      expect(w.upgradeRemotePlanet(0, i), isTrue);
      expect(w.sectors[0]!.buildings.length, w.sectors[0]!.colonyLevels.length);
      expect(w.remotePlanet(0, i).building(ColonyBuilding.stabilizer), 2);
    },
  );
}
