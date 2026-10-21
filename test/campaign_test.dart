import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/campaign.dart';
import 'package:star_settlers/game/missions.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';

GameWorld reload(GameWorld w) => GameWorld.fromJson(
  jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>,
  w.profile,
);

GameWorld atFinal() {
  final w = GameWorld(seed: 9);
  final json = w.toJson();
  json['sector'] = campaignFinalSector;
  json['counters'] = {'maxSector': campaignFinalSector};
  return GameWorld.fromJson(json, w.profile);
}

void develop(GameWorld w) {
  for (final p in w.planets) {
    p.buildings[ColonyBuilding.stabilizer] = GameWorld.devLevelCap;
    p.stabilizerHp = p.stabilizerMaxHp(w.sectorMul);
  }
}

void main() {
  test('final actions stay unavailable outside final sector', () {
    final w = GameWorld(seed: 3);
    develop(w);
    w.player.pos = GameWorld.homePos;
    expect(w.startFinalSync(), isFalse);
    expect(w.launchCounterattack(), isFalse);
  });

  test(
    'campaign arrivals queue once in chapter order after original scenes',
    () {
      final w = GameWorld(seed: 1, showOpening: true);
      w.counters['campaignSector_1'] = 1;
      w.counters['campaignSector_5'] = 1;
      expect(w.pendingStoryScene, StoryScene.opening);
      w.finishStoryScene();
      expect(w.pendingCampaignSector, 1);
      w.finishStoryScene();
      expect(reload(w).pendingCampaignSector, 5);
      w.finishStoryScene();
      expect(reload(w).pendingCampaignSector, isNull);
    },
  );

  test(
    'real warps reserve only final briefing; discoveries require gameplay',
    () {
      final w = GameWorld(seed: 99);
      w.counters['maxSector'] = 27;
      final seen = <int>[];
      for (var sector = 1; sector <= campaignFinalSector; sector++) {
        expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
        if (sector == campaignFinalSector) {
          expect(w.pendingCampaignSector, sector);
          seen.add(sector);
          w.finishStoryScene();
        }
        expect(w.pendingCampaignSector, isNull);
      }
      expect(seen, [campaignFinalSector]);
      expect(w.warp(w.gates.firstWhere((g) => !g.forward)), isTrue);
      expect(w.pendingCampaignSector, isNull);
      expect(reload(w).pendingCampaignSector, isNull);
    },
  );

  test(
    'final link depends on completed grid and only boosts the final battle',
    () {
      final w = atFinal();
      develop(w);
      w.player.pos = GameWorld.homePos;
      final normalDamage = w.playerDamage;
      expect(w.startFinalSync(), isTrue);
      expect(w.finalSyncProtected, isTrue);
      w.player.pos = const Offset(3000, 3000);
      expect(w.finalSyncProtected, isFalse);
      w.counters['finalMissionStage'] = FinalMissionStage.guardian.index;
      expect(w.finalPhaseLinked, isTrue);
      expect(w.playerDamage, closeTo(normalDamage * 2.5, 1e-9));
      w.planets.first.buildings[ColonyBuilding.stabilizer] = 0;
      expect(w.finalPhaseLinked, isFalse);
      expect(w.playerDamage, normalDamage);
      develop(w);
      w.counters['finalMissionStage'] = FinalMissionStage.complete.index;
      expect(w.finalPhaseLinked, isFalse);
      expect(w.playerDamage, normalDamage);
    },
  );

  test('synchronization blocks fire only inside a powered relay link', () {
    final w = atFinal();
    develop(w);
    w.player.pos = GameWorld.homePos;
    w.player.invulnerable = 0;
    w.homeBase.disabledTime = 100;
    expect(w.startFinalSync(), isTrue);
    final hp = w.player.hp;
    w.bullets.add(Bullet(w.player.pos, Offset.zero, 10, false));
    w.update(.01, InputState());
    expect(w.player.hp, hp);
    w.player.pos = const Offset(3000, 3000);
    w.bullets.add(Bullet(w.player.pos, Offset.zero, 10, false));
    w.update(.01, InputState());
    expect(w.player.hp, lessThan(hp));
  });

  test('legacy save skips old chapters and keeps current arrival', () {
    final w = atFinal();
    expect(w.pendingCampaignSector, campaignFinalSector);
    expect(w.counter('campaignSector_25'), 2);
    expect(w.finalMissionStage, FinalMissionStage.stabilize);
    expect(reload(w).pendingCampaignSector, campaignFinalSector);
  });

  test('new final route requires victory but visited routes stay open', () {
    final w = atFinal();
    develop(w);
    expect(w.gateOpen(w.gates.firstWhere((g) => g.forward)), isFalse);
    expect(w.gateOpen(w.gates.firstWhere((g) => !g.forward)), isTrue);
    w.counters['maxSector'] = 27;
    expect(w.gateOpen(w.gates.firstWhere((g) => g.forward)), isTrue);
    w.counters['maxSector'] = 26;
    w.counters['finalMissionStage'] = FinalMissionStage.complete.index;
    expect(w.gateOpen(w.gates.firstWhere((g) => g.forward)), isTrue);
  });

  test('sync requires live ship, relay range, and intact development', () {
    var w = atFinal();
    expect(w.startFinalSync(), isFalse);
    develop(w);
    w.player.pos = GameWorld.homePos;
    expect(w.startFinalSync(), isTrue);
    w = reload(w);
    expect(w.finalMissionStage, FinalMissionStage.synchronize);
    w.paused = true;
    w.update(0.05, InputState());
    expect(w.finalSyncProgress, 0);
    w.paused = false;
    w.player.pos = const Offset(1000, 1000);
    w.update(0.05, InputState());
    expect(w.finalSyncProgress, 0);
    w.player.pos = GameWorld.homePos;
    w.player.alive = false;
    w.update(0.05, InputState());
    expect(w.finalSyncProgress, 0);
    w.player.alive = true;
    w.planets.first.buildings[ColonyBuilding.stabilizer] = 0;
    w.update(0.05, InputState());
    expect(w.finalSyncProgress, 0);
    develop(w);
    w.update(0.05, InputState());
    expect(w.finalSyncProgress, greaterThan(0));
    expect(reload(w).finalSyncProgress, greaterThan(0));
  });

  test(
    'only unique guardian kill opens counterattack and completion is once',
    () {
      var w = atFinal();
      develop(w);
      w.player.pos = GameWorld.homePos;
      expect(w.startFinalSync(), isTrue);
      final nearlySynced = w.toJson()..['finalSyncSeconds'] = 19.99;
      w = GameWorld.fromJson(nearlySynced, w.profile);
      w.update(0.05, InputState());
      expect(w.finalMissionStage, FinalMissionStage.guardian);
      expect(w.pirates.where((p) => p.finalGuardian), hasLength(1));
      w = reload(w);
      w.update(0.05, InputState());
      expect(w.pirates.where((p) => p.finalGuardian), hasLength(1));
      expect(w.canCounterattack, isFalse);
      w.pirates.add(Pirate(PirateKind.boss, const Offset(1200, 1200), 0));
      w.update(0.05, InputState());
      expect(w.finalMissionStage, FinalMissionStage.guardian);
      final guardian = w.pirates.singleWhere((p) => p.finalGuardian);
      w.bullets.add(Bullet(guardian.pos, Offset.zero, guardian.hp + 1, true));
      w.update(0.05, InputState());
      expect(w.finalMissionStage, FinalMissionStage.counterattack);
      w = reload(w);
      w.player.pos = GameWorld.homePos;
      expect(w.launchCounterattack(), isTrue);
      expect(w.launchCounterattack(), isFalse);
      expect(reload(w).pendingStoryScene, StoryScene.campaign);
      w.finishStoryScene();
      expect(w.pendingStoryScene, isNull);
      expect(w.finalCounterattackSeconds, greaterThan(0));
      w = reload(w);
      for (var i = 0; i < 61; i++) {
        w.update(0.05, InputState());
      }
      expect(w.pendingStoryScene, StoryScene.counterattack);
      w.finishStoryScene();
      expect(w.pendingStoryScene, StoryScene.ending);
      w.finishStoryScene();
      expect(reload(w).pendingStoryScene, isNull);
    },
  );
}
