import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/missions.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/system_traits.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart';
import 'package:star_settlers/ui/colonies_panel.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;
import 'package:star_settlers/ui/system_panel.dart';
import 'package:star_settlers/ui/tokens.dart';

GameWorld at(int sector) {
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

GameWorld reload(GameWorld w) => GameWorld.fromJson(
  jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>,
  w.profile,
);

void main() {
  test('Sol has no trait and preserves neutral multipliers', () {
    expect(systemTrait(0), isNull);
    final w = at(0);
    expect(w.playerSpeed, 260);
    expect(w.cooldownMul, 1);
    expect(w.rewardMul, 1);
    expect(w.orePrice, 2);
    expect(w.counters.keys.where((k) => k.startsWith('traitSeen_')), isEmpty);
  });

  test(
    'fixed table: every trait at least three times, no adjacent repeats',
    () {
      final counts = <SystemTrait, int>{};
      for (var s = 1; s <= 26; s++) {
        final trait = systemTrait(s)!;
        counts[trait] = (counts[trait] ?? 0) + 1;
        expect(trait, isNot(systemTrait(s - 1)), reason: 'sector $s');
      }
      for (final trait in SystemTrait.values) {
        expect(counts[trait], greaterThanOrEqualTo(3));
      }
      expect(systemTrait(3), SystemTrait.solarFlare);
      expect(systemTrait(22), SystemTrait.gravityWell);
      expect(systemTrait(26), SystemTrait.gravityWell);
    },
  );

  test(
    '27+ is deterministic, balanced and never repeats across the boundary',
    () {
      final forward = [for (var s = 27; s < 1027; s++) systemTrait(s)];
      for (var s = 1026; s >= 27; s--) {
        expect(systemTrait(s), forward[s - 27]);
        expect(systemTrait(s), isNot(systemTrait(s - 1)));
      }
      for (var start = 27; start < 1020; start += 6) {
        expect({
          for (var s = start; s < start + 6; s++) systemTrait(s),
        }, SystemTrait.values.toSet());
      }
    },
  );

  test(
    'pirate nest actually reduces initial and recurring spawn intervals',
    () {
      final w = at(3)..spawnTimer = 10;
      w.warp(w.gates.firstWhere((g) => g.forward));
      expect(w.trait, SystemTrait.pirateNest);
      expect(w.spawnTimer, 7);
      w.spawnTimer = 0;
      w.update(0, InputState());
      expect(w.pirates, isNotEmpty);
      expect(
        w.spawnTimer,
        closeTo(max(3, 13 - (w.threat - w.sector) * 1.2) * .7, 1e-9),
      );
      expect(reload(w).spawnTimer, 25 * .7);
      w.spawnTimer = 7;
      w.warp(w.gates.firstWhere((g) => !g.forward));
      expect(w.spawnTimer, 10);
    },
  );

  for (final sector in [4, 6]) {
    test(
      'actual bounty drops include ${sector == 4 ? 'pirate nest' : 'gravity well'} bonus',
      () {
        final w = at(sector);
        final e = Pirate(PirateKind.scout, const Offset(3000, 3000), 0);
        w.pirates.add(e);
        w.update(0, InputState());
        final base = w.sectorMul * pow(w.costMul, GameWorld.rewardCostExponent);
        final total = (e.bounty * base * (sector == 4 ? 1.5 : 1.3)).round();
        // Existing pickups split into three equal integer pieces.
        expect(
          w.pickups
              .where((p) => p.kind == PickupKind.credits)
              .fold(0, (sum, p) => sum + p.amount),
          (total ~/ 3) * 3,
        );
      },
    );
  }

  test(
    'rich veins doubles colony ore and increases actual asteroid drops 1.5x',
    () {
      final w = at(2);
      final p = w.planets.first..colonyLevel = 2;
      expect(w.planetOreRate(p), p.baseOreRate * w.sectorMul * 2);
      final before = w.ore;
      w.update(.05, InputState());
      expect(w.ore - before, closeTo(w.planetOreRate(p) * .05, .001));
      w.asteroids.add(Asteroid(const Offset(3000, 3000), 36, 8)..hp = 0);
      w.update(0, InputState());
      expect(
        w.pickups
            .where((p) => p.kind == PickupKind.ore)
            .fold(0, (sum, p) => sum + p.amount),
        36,
      );
    },
  );

  test(
    'solar flare increases colony credits only and halves both colony shield regens',
    () {
      final w = at(3);
      final p = w.planets.first..colonyLevel = 2;
      p.buildings[ColonyBuilding.stabilizer] = 1;
      p.shieldHp = p.relayShieldHp = 0;
      p.sinceShieldHit = 20;
      expect(w.planetCreditRate(p), p.baseCreditRate * w.sectorMul * 1.25);
      expect(
        w.stationCreditRate(w.homeBase),
        w.homeBase.baseCreditRate * w.sectorMul,
      );
      final shieldRate = p.shieldRegen(w.sectorMul) * w.relayRegenMultiplier(p);
      final relayRate = w.relayShieldMax(p) * .06 * w.relayRegenMultiplier(p);
      final before = w.credits;
      final income = w.creditIncome;
      w.update(.05, InputState());
      expect(w.credits - before, closeTo(income * .05, .001));
      expect(p.shieldHp, closeTo(shieldRate * .5 * .05, 1e-9));
      expect(p.relayShieldHp, closeTo(relayRate * .5 * .05, 1e-9));
    },
  );

  test(
    'ion nebula changes all three skill activations and both turret bullets',
    () {
      final w = at(5);
      w.levels[UpgradeKind.missile] = w.levels[UpgradeKind.shield] = 1;
      expect(w.fireMissiles(), isTrue);
      expect(w.activateShield(), isTrue);
      expect(w.boost(), isTrue);
      expect(w.player.missileCooldown, closeTo(8 * .7, 1e-9));
      expect(w.player.shieldCooldown, closeTo(18 * .7, 1e-9));
      expect(w.player.boostCooldown, closeTo(4 * .7, 1e-9));
      final st = w.homeBase..turretLevel = 1;
      final p = w.planets.first..colonyLevel = 1;
      p.buildings[ColonyBuilding.turret] = 1;
      w.pirates.addAll([
        Pirate(PirateKind.scout, st.pos + const Offset(200, 0), 1000),
        Pirate(PirateKind.scout, p.pos + const Offset(300, 0), 1000),
      ]);
      w.update(0, InputState());
      final damages = w.bullets.where((b) => b.fromPlayer).map((b) => b.damage);
      expect(
        damages,
        contains(closeTo(st.turretDamage * w.sectorMul * .7, 1e-9)),
      );
      expect(
        damages,
        contains(closeTo(p.turretDamage * w.sectorMul * .7, 1e-9)),
      );
    },
  );

  test(
    'gravity well caps movement and increases generated and paid mission rewards, not packs',
    () {
      final w = at(6);
      expect(w.playerSpeed, 260 * .85);
      w.player.vel = const Offset(2000, 0);
      w.update(0, InputState());
      expect(w.player.vel.distance, closeTo(260 * .85, 1e-9));
      final base = w.sectorMul * pow(w.costMul, GameWorld.rewardCostExponent);
      expect(w.rewardMul, closeTo(base * 1.3, 1e-9));
      expect(w.creditPackAmount, (GameWorld.creditPackBase * base).round());
      w.offerTimer = 0;
      w.update(0, InputState());
      for (final m in w.missionOffers) {
        if (m.type == MissionType.kill) {
          expect(m.rewardCredits, (35 * m.target * base * 1.3).round());
        } else if (m.type == MissionType.mine) {
          expect(m.rewardCredits, (3 * m.target * base * 1.3).round());
        } else if (m.type == MissionType.bounty) {
          expect(m.rewardCredits, (450 * base * 1.3).round());
        }
      }
      final m = w.missionOffers.first;
      expect(w.acceptMission(m), isTrue);
      m.progress = m.target;
      final before = w.credits;
      w.update(0, InputState());
      expect(w.credits - before, m.rewardCredits);
    },
  );

  test(
    'trade lane applies sale multiplier to both displayed price and payment',
    () {
      final w = at(1)..ore = 100;
      w.totalTime = 40;
      final price = (2 + .6) * (1 + .35 * sin(1)) * 1.3;
      expect(w.orePrice, closeTo(price, 1e-9));
      final before = w.credits;
      expect(w.sellOre(30), isTrue);
      expect(w.credits - before, closeTo(price * 30, .001));
      expect(w.ore, 70);
    },
  );

  test(
    'trade lane random event raid probability is 1.3x, without shortening event timer',
    () {
      double raidFraction(int sector) {
        final w = at(sector);
        w.planets.first.colonyLevel = 1;
        var raids = 0;
        const trials = 6000;
        for (var i = 0; i < trials; i++) {
          w.events.clear();
          w.pirates.clear();
          w.pickups.clear();
          w.eventTimer = 0;
          w.update(0, InputState());
          if (w.events.any((e) => e.kind == EventKind.raid)) raids++;
          expect(w.eventTimer, inInclusiveRange(90, 150));
        }
        // ignore: avoid_print
        print(
          'raid sector=$sector trials=$trials raids=$raids probability=${raids / trials}',
        );
        return raids / trials;
      }

      expect(raidFraction(2), closeTo(.4, .025));
      expect(raidFraction(1), closeTo(.4 * 1.3, .025));
    },
  );

  for (final sector in [2, 3]) {
    test(
      'sector $sector production remains correct remotely, after upgrades, reload and offline income',
      () {
        final w = at(sector);
        final p = w.planets.first;
        expect(w.upgradePlanet(p), isTrue);
        expect(w.upgradePlanet(p), isTrue);
        final credits = w.planetCreditRate(p) + w.stationCreditRate(w.homeBase);
        final ore = w.planetOreRate(p);
        w.warp(w.gates.firstWhere((g) => g.forward));
        final save = w.sectors[sector]!;
        expect(save.creditRateAt(sector), closeTo(credits, 1e-9));
        expect(save.oreRateAt(sector), closeTo(ore, 1e-9));
        final oldCredits = w.otherSectorCredits, oldOre = w.otherSectorOre;
        final prior = w.remotePlanet(sector, 0);
        expect(w.upgradeRemotePlanet(sector, 0), isTrue);
        final next = w.remotePlanet(sector, 0);
        final mul = 1 + sector * GameWorld.sectorIncomeStep;
        expect(
          w.otherSectorCredits - oldCredits,
          closeTo(
            (next.baseCreditRate - prior.baseCreditRate) *
                mul *
                systemTrait(sector).colonyCreditMul,
            1e-9,
          ),
        );
        expect(
          w.otherSectorOre - oldOre,
          closeTo(
            (next.baseOreRate - prior.baseOreRate) *
                mul *
                systemTrait(sector).colonyOreMul,
            1e-9,
          ),
        );
        expect(
          w.upgradeRemotePlanet(sector, 0, building: ColonyBuilding.stabilizer),
          isTrue,
        );
        final loaded = reload(w);
        expect(loaded.otherSectorCredits, closeTo(w.otherSectorCredits, 1e-9));
        expect(loaded.otherSectorOre, closeTo(w.otherSectorOre, 1e-9));
        final c = loaded.creditIncome, o = loaded.oreIncome;
        final now = DateTime.now();
        loaded.savedAt = now.subtract(const Duration(hours: 1));
        final offline = loaded.offlineEarnings(now);
        expect(
          offline.$2,
          closeTo(c * offline.$1 * loaded.profile.home.offlineEfficiency, .01),
        );
        expect(
          offline.$3,
          closeTo(o * offline.$1 * loaded.profile.home.offlineEfficiency, .01),
        );
        loaded.warp(loaded.gates.firstWhere((g) => !g.forward));
        expect(
          loaded.planetCreditRate(loaded.planets.first),
          closeTo(
            w.sectors[sector]!.creditRateAt(sector) -
                w.homeBase.baseCreditRate * mul,
            1e-9,
          ),
        );
      },
    );
  }

  test(
    'advisor introduces each system once, including identical traits and save/revisit',
    () {
      final w = at(0);
      for (var sector = 1; sector <= 8; sector++) {
        w.dialogs.clear();
        w.warp(w.gates.firstWhere((g) => g.forward));
        expect(w.counter('traitSeen_$sector'), 1);
        expect(
          w.dialogs.where((d) => d.text == tr.g_traitIntro(w.trait!.name)),
          hasLength(1),
        );
      }
      final loaded = reload(w)..dialogs.clear();
      loaded.warp(loaded.gates.firstWhere((g) => !g.forward));
      loaded.warp(loaded.gates.firstWhere((g) => g.forward));
      expect(
        loaded.dialogs.where(
          (d) => d.text == tr.g_traitIntro(loaded.trait!.name),
        ),
        isEmpty,
      );
      expect(loaded.counter('traitSeen_8'), 1);
    },
  );

  for (final locale in L10n.supportedLocales) {
    testWidgets(
      'trait UI ${locale.languageCode}: all effects, portrait/landscape and remote income',
      (tester) async {
        final font = FontLoader(Ts.family)
          ..addFont(rootBundle.load('assets/fonts/Jua-Regular.ttf'));
        await font.load();
        Lang.set(locale);
        final frame = ValueNotifier(0);
        addTearDown(frame.dispose);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        tester.view.devicePixelRatio = 1;
        Widget app(Widget panel) => MaterialApp(
          theme: ThemeData(fontFamily: Ts.family),
          locale: locale,
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: L10n.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.3)),
            child: child!,
          ),
          home: Scaffold(body: panel),
        );
        for (final size in [const Size(360, 740), const Size(800, 360)]) {
          tester.view.physicalSize = size;
          for (final sector in [0, 1, 2, 3, 4, 5, 6, 22, 26, 27]) {
            final w = at(sector);
            await tester.pumpWidget(
              app(
                SystemPanel(
                  world: w,
                  frame: frame,
                  onClose: () {},
                  onOpenColonies: () {},
                ),
              ),
            );
            await tester.pump();
            if (sector > 0) {
              final text = keepAll(tr.u_systemTrait(w.trait!.name));
              expect(text, isNotEmpty);
              expect(find.textContaining(text), findsOneWidget);
            } else {
              for (final trait in SystemTrait.values) {
                expect(
                  find.textContaining(keepAll(tr.u_systemTrait(trait.name))),
                  findsNothing,
                );
              }
            }
            expect(
              tester.takeException(),
              isNull,
              reason: 'sector $sector $size',
            );
          }
        }
        final w = at(3);
        w.upgradePlanet(w.planets.first);
        final income = w.planetCreditRate(w.planets.first);
        w.warp(w.gates.firstWhere((g) => g.forward));
        // Keep this fixture focused on the one remotely owned colony.
        w.sectors.removeWhere((sector, _) => sector != 3);
        tester.view.physicalSize = const Size(360, 740);
        await tester.pumpWidget(
          app(
            ColoniesPanel(
              world: w,
              frame: frame,
              act: (f) => f(),
              onClose: () {},
            ),
          ),
        );
        await tester.pump();
        expect(find.text('+${income.toStringAsFixed(1)}/s'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
