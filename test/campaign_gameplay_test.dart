import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/campaign.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';

GameWorld load(GameWorld w) => GameWorld.fromJson(
  jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>,
  w.profile,
);
GameWorld region(int sector) {
  final w = GameWorld(seed: 91);
  w.counters['maxSector'] = 27;
  for (var i = 0; i < sector; i++) {
    w.warp(w.gates.firstWhere((g) => g.forward));
  }
  w.counters['maxSector'] = sector;
  w.dialogs.clear();
  w.player.invulnerable = 10000;
  return w;
}

void anchor(GameWorld w) {
  final p = w.planets.first;
  p.colonyLevel = 3;
  p.buildings[ColonyBuilding.stabilizer] = 3;
  p.stabilizerHp = p.stabilizerMaxHp(w.sectorMul);
}

void grid(GameWorld w) {
  for (final p in w.planets) {
    p.colonyLevel = 3;
    p.buildings[ColonyBuilding.stabilizer] = 3;
    p.stabilizerHp = p.stabilizerMaxHp(w.sectorMul);
  }
}

void tick(GameWorld w, [int count = 1]) {
  for (var i = 0; i < count; i++) {
    w.update(.05, InputState());
  }
}

void work(GameWorld w) {
  w.player.pos = w.campaignTarget!;
  expect(w.startCampaignWork(), isTrue);
  for (var i = 0; i < 121 && w.campaignWorking; i++) {
    w.player.pos = w.campaignTarget!;
    tick(w);
  }
}

void main() {
  test(
    'arrival does not reveal discoveries, and grid alone cannot bypass chapter',
    () {
      for (final sector in campaignSectors.where((s) => s < 26)) {
        final w = region(sector);
        grid(w);
        expect(w.pendingCampaignSector, isNull);
        expect(w.campaignMissionActive, isTrue);
        expect(w.gateOpen(w.gates.firstWhere((g) => g.forward)), isFalse);
        expect(w.gateOpen(w.gates.firstWhere((g) => !g.forward)), isTrue);
        w.counters['maxSector'] = sector + 1;
        expect(w.gateOpen(w.gates.firstWhere((g) => g.forward)), isTrue);
      }
    },
  );
  test('field measurement then reception comparison survives reload', () {
    var w = region(8);
    anchor(w);
    work(w);
    expect(w.campaignStep, 1);
    expect(w.pendingCampaignSector, isNull);
    w = load(w);
    w.player.invulnerable = 10000;
    expect(w.campaignTarget, GameWorld.homePos);
    work(w);
    expect(w.pendingCampaignSector, 8);
    expect(w.campaignMissionActive, isFalse);
    w.finishStoryScene();
    expect(load(w).pendingCampaignSector, isNull);
  });
  test(
    'scan needs explicit action, pauses away, dead or paused and resumes saved progress',
    () {
      var w = region(20);
      w.player.pos = w.campaignTarget!;
      tick(w, 125);
      expect(w.campaignWorkProgress, 0);
      expect(w.startCampaignWork(), isTrue);
      tick(w, 20);
      final progress = w.campaignWorkProgress;
      expect(progress, greaterThan(0));
      w.player.pos = GameWorld.homePos;
      tick(w, 20);
      expect(w.campaignWorkProgress, progress);
      w.player.pos = w.campaignTarget!;
      w.player.alive = false;
      tick(w, 20);
      expect(w.campaignWorkProgress, progress);
      w.player.alive = true;
      w.paused = true;
      tick(w, 20);
      expect(w.campaignWorkProgress, progress);
      w.paused = false;
      w = load(w);
      expect(w.campaignWorkProgress, progress);
      w.player.pos = w.campaignTarget!;
      w.player.invulnerable = 10000;
      tick(w, 125);
      expect(w.pendingCampaignSector, 20);
    },
  );
  test(
    'raiders must actually die; normal boss is not evidence; wreck must be recovered',
    () {
      for (final sector in [5, 16]) {
        var w = region(sector);
        anchor(w);
        tick(w);
        expect(
          w.pirates.where((p) => p.campaignChapter == sector),
          hasLength(sector == 5 ? 2 : 1),
        );
        expect(w.startCampaignWork(), isFalse);
        w.pirates.add(Pirate(PirateKind.boss, const Offset(2500, 2500), 0));
        tick(w);
        expect(w.campaignKills, 0);
        final target = w.pirates.firstWhere((p) => p.campaignChapter == sector);
        w.bullets.add(Bullet(target.pos, Offset.zero, target.hp + 1, true));
        tick(w);
        expect(w.campaignKills, 1);
        w = load(w);
        w.player.invulnerable = 10000;
        tick(w);
        expect(
          w.pirates.where((p) => p.campaignChapter == sector),
          hasLength(sector == 5 ? 2 : 0),
        );
        while (w.campaignKills < w.campaignKillTarget) {
          for (final p
              in w.pirates.where((p) => p.campaignChapter == sector).toList()) {
            w.bullets.add(Bullet(p.pos, Offset.zero, p.hp + 1, true));
          }
          tick(w);
        }
        expect(w.campaignKills, w.campaignKillTarget);
        expect(w.pendingCampaignSector, isNull);
        work(w);
        expect(w.pendingCampaignSector, sector);
      }
    },
  );
  test(
    'anchor damage interrupts measurement and control isolation needs full grid',
    () {
      final w = region(1);
      expect(w.campaignNeedsAnchor, isTrue);
      anchor(w);
      w.player.pos = w.campaignTarget!;
      expect(w.startCampaignWork(), isTrue);
      tick(w, 10);
      final progress = w.campaignWorkProgress;
      w.planets.first.buildings[ColonyBuilding.stabilizer] = 0;
      tick(w, 20);
      expect(w.campaignWorkProgress, progress);
      expect(w.pendingCampaignSector, isNull);
      anchor(w);
      w.player.pos = w.campaignTarget!;
      tick(w, 125);
      expect(w.pendingCampaignSector, 1);
      final v = region(25);
      v.player.pos = GameWorld.homePos;
      expect(v.startCampaignWork(), isFalse);
      grid(v);
      work(v);
      expect(v.pendingCampaignSector, 25);
    },
  );
  test(
    'legacy passed chapters preserved; unread current discovery becomes playable',
    () {
      final w = region(20);
      final j = w.toJson();
      final counters = Map<String, dynamic>.from(j['counters'] as Map);
      counters.remove('campaignGameplayVersion');
      counters['campaignSector_20'] = 1;
      j['counters'] = counters;
      final restored = GameWorld.fromJson(j, w.profile);
      expect(restored.counter('campaignDone_16'), 1);
      expect(restored.campaignMissionActive, isTrue);
      expect(restored.pendingCampaignSector, isNull);
      expect(load(restored).campaignMissionActive, isTrue);
    },
  );
  test('trace needs field evidence before Haven comparison', () {
    final w = region(22);
    work(w);
    expect(w.campaignStep, 1);
    expect(w.pendingCampaignSector, isNull);
    work(w);
    expect(w.pendingCampaignSector, 22);
  });
}
