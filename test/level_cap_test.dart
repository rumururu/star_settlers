import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart';
import 'package:star_settlers/ui/colony_panel.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;
import 'package:star_settlers/ui/station_panel.dart';
import 'package:star_settlers/ui/tokens.dart';

GameWorld fundedWorld() => GameWorld(seed: 151)
  ..credits = 1e12
  ..ore = 1e12;

GameWorld reload(GameWorld w) => GameWorld.fromJson(
  jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>,
  w.profile,
);

void reachFirstGate(GameWorld w) {
  for (final p in w.planets) {
    for (var lv = 0; lv < GameWorld.devLevelCap; lv++) {
      expect(w.upgradePlanet(p), isTrue);
      expect(w.buildColony(p, ColonyBuilding.stabilizer), isTrue);
    }
  }
}

void main() {
  testWidgets(
    'colony and ship buttons distinguish progress, legacy locks and MAX',
    (tester) async {
      final font = FontLoader(Ts.family)
        ..addFont(rootBundle.load('assets/fonts/Jua-Regular.ttf'));
      await font.load();
      Lang.set(const Locale('ko'));
      final w = fundedWorld();
      w.profile.colonyTutorialSeen = true;
      for (final k in UpgradeKind.values) {
        w.levels[k] = k.maxLevel;
      }
      final frame = ValueNotifier(0);
      addTearDown(frame.dispose);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      for (final size in [const Size(360, 740), const Size(800, 360)]) {
        tester.view.physicalSize = size;
        for (final colonyLevel in [4, 7, 12]) {
          w.planets.first.colonyLevel = colonyLevel;
          w.levels[UpgradeKind.weapon] = min(colonyLevel, 8);
          for (final panel in <Widget>[
            ColonyPanel(
              world: w,
              planet: w.planets.first,
              frame: frame,
              act: (f) => f(),
              onClose: () {},
              onTutorialDone: () {},
            ),
            StationPanel(
              world: w,
              station: w.homeBase,
              frame: frame,
              act: (f) => f(),
              onClose: () {},
              onOpenShop: () {},
            ),
          ]) {
            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(fontFamily: Ts.family),
                locale: const Locale('ko'),
                supportedLocales: L10n.supportedLocales,
                localizationsDelegates: L10n.localizationsDelegates,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.3)),
                  child: child!,
                ),
                home: Scaffold(body: panel),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$size / $colonyLevel / ${panel.runtimeType}',
            );
            if (colonyLevel < 12) {
              final hint = keepAll(
                tr.u_levelUnlockAtSystem(colonyLevel + 1, colonyLevel - 2),
              );
              expect(find.textContaining(hint), findsOneWidget);
              final lock = find.ancestor(
                of: find.text('🔒'),
                matching: find.byType(ElevatedButton),
              );
              expect(lock, findsOneWidget);
              expect(tester.widget<ElevatedButton>(lock).onPressed, isNull);
              final lockSize =
                  tester.getBottomRight(lock) - tester.getTopLeft(lock);
              expect(lockSize.dx, greaterThanOrEqualTo(Tap.min));
              expect(lockSize.dy, greaterThanOrEqualTo(Tap.min));
            } else {
              expect(find.text('🔒'), findsNothing);
              final maxButtons = find.ancestor(
                of: find.text('MAX'),
                matching: find.byType(ElevatedButton),
              );
              expect(maxButtons, findsAtLeastNWidgets(1));
              for (final button in tester.widgetList<ElevatedButton>(
                maxButtons,
              )) {
                expect(button.onPressed, isNull);
              }
            }
            await tester.pumpWidget(const SizedBox.shrink());
          }
        }
      }
    },
  );

  test(
    'Sol caps colonies at 4; arriving in the next system unlocks 5 globally',
    () {
      final w = fundedWorld();
      reachFirstGate(w);
      final p = w.planets.first;
      expect(w.colonyLevelCap, 4);
      expect(w.upgradePlanet(p), isTrue);
      expect(p.colonyLevel, 4);
      final money = (w.credits, w.ore);
      expect(w.upgradePlanet(p), isFalse);
      expect((w.credits, w.ore), money);
      expect(w.profile.stat('maxColony'), 0);
      expect(w.development, 1);
      expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
      expect(w.counter('maxSector'), 1);
      expect(w.colonyLevelCap, 5);

      final remote = w.remotePlanet(0, 0);
      final cost = w.remotePlanetCost(0, remote);
      expect(
        cost,
        remote.baseCost(),
        reason: 'Sol keeps its own cost multiplier',
      );
      final credits = w.credits;
      final income = w.otherSectorCredits;
      final expectedIncomeGain =
          remote.ratePerLevel.$1 *
          (1 +
              remote.building(ColonyBuilding.stabilizer) *
                  Planet.anchorIncomePerLevel);
      expect(w.upgradeRemotePlanet(0, 0), isTrue);
      expect(w.credits, credits - cost.$1);
      expect(w.otherSectorCredits, closeTo(income + expectedIncomeGain, 1e-9));
      expect(w.remotePlanet(0, 0).colonyLevel, 5);
      expect(w.profile.stat('maxColony'), 1);
      expect(w.upgradeRemotePlanet(0, 0), isFalse);
      expect(w.warp(w.gates.firstWhere((g) => !g.forward)), isTrue);
      expect(w.colonyLevelCap, 5, reason: 'returning does not lower the cap');
      expect(w.planets.first.colonyLevel, 5);
      expect(w.upgradePlanet(w.planets.first), isFalse);
      expect(w.upgradePlanet(w.planets[1]), isTrue);
      expect(w.upgradePlanet(w.planets[1]), isTrue);
      expect(w.planets[1].colonyLevel, 5);
    },
  );

  test(
    'all colony caps and the absolute 12 cap apply locally and remotely',
    () {
      final w = fundedWorld();
      reachFirstGate(w);
      expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
      for (var highest = 1; highest <= 10; highest++) {
        w.counters['maxSector'] = highest;
        final cap = min(4 + highest, 12);
        expect(w.colonyLevelCap, cap);
        final p = w.planets.first;
        while (p.colonyLevel < cap) {
          expect(w.upgradePlanet(p), isTrue);
        }
        while (w.remotePlanet(0, 0).colonyLevel < cap) {
          expect(w.upgradeRemotePlanet(0, 0), isTrue);
        }
        final money = (w.credits, w.ore);
        expect(w.upgradePlanet(p), isFalse);
        expect(w.upgradeRemotePlanet(0, 0), isFalse);
        expect((w.credits, w.ore), money);
      }
    },
  );

  test(
    'local and remote Lv.5 achievements do not move to the progress cap',
    () {
      final local = fundedWorld()..counters['maxSector'] = 8;
      final p = local.planets.first;
      for (var lv = 1; lv <= 5; lv++) {
        expect(local.upgradePlanet(p), isTrue);
        expect(local.profile.stat('maxColony'), lv < 5 ? 0 : 1);
      }
      final remote = fundedWorld();
      reachFirstGate(remote);
      expect(remote.warp(remote.gates.firstWhere((g) => g.forward)), isTrue);
      remote.counters['maxSector'] = 8;
      expect(remote.upgradeRemotePlanet(0, 0), isTrue);
      expect(remote.profile.stat('maxColony'), 0);
      expect(remote.upgradeRemotePlanet(0, 0), isTrue);
      expect(remote.profile.stat('maxColony'), 1);
    },
  );

  test('loading legacy levels above progress caps never lowers them', () {
    final old = fundedWorld();
    old.planets.first.colonyLevel = 5;
    old.levels[UpgradeKind.weapon] = 7;
    old.levels[UpgradeKind.missile] = 4;
    final w = reload(old);
    expect(w.colonyLevelCap, 4);
    expect(w.planets.first.colonyLevel, 5);
    expect(w.level(UpgradeKind.weapon), 7);
    expect(w.level(UpgradeKind.missile), 4);
    final money = (w.credits, w.ore);
    expect(w.upgradePlanet(w.planets.first), isFalse);
    expect(w.upgradeShip(UpgradeKind.weapon), isFalse);
    expect(w.upgradeShip(UpgradeKind.missile), isFalse);
    expect((w.credits, w.ore), money);
    w.counters['maxSector'] = 4;
    expect(w.upgradePlanet(w.planets.first), isTrue);
    expect(w.upgradeShip(UpgradeKind.weapon), isTrue);
    expect(w.upgradeShip(UpgradeKind.missile), isTrue);
  });

  test('over-cap remote saves survive reload and a return trip', () {
    final old = fundedWorld();
    reachFirstGate(old);
    old.planets.first.colonyLevel = 7;
    expect(old.warp(old.gates.firstWhere((g) => g.forward)), isTrue);
    final w = reload(old);
    expect(w.colonyLevelCap, 5);
    expect(w.remotePlanet(0, 0).colonyLevel, 7);
    final money = (w.credits, w.ore);
    expect(w.upgradeRemotePlanet(0, 0), isFalse);
    expect((w.credits, w.ore), money);
    expect(w.warp(w.gates.firstWhere((g) => !g.forward)), isTrue);
    expect(w.planets.first.colonyLevel, 7);
    expect(w.upgradePlanet(w.planets.first), isFalse);
  });

  test(
    'ship caps follow progress for all kinds and stop at absolute maxima',
    () {
      final w = fundedWorld();
      for (var highest = 0; highest <= 8; highest++) {
        w.counters['maxSector'] = highest;
        for (final k in UpgradeKind.values) {
          final basic = [
            UpgradeKind.weapon,
            UpgradeKind.hull,
            UpgradeKind.engine,
          ].contains(k);
          final cap = min(basic ? 8 : 5, (basic ? 4 : 2) + highest);
          expect(w.upgradeCap(k), cap, reason: '$k at maxSector $highest');
          while (w.level(k) < cap) {
            expect(w.upgradeShip(k), isTrue);
          }
          final money = (w.credits, w.ore);
          expect(w.upgradeShip(k), isFalse);
          expect((w.credits, w.ore), money);
        }
      }
    },
  );

  test(
    'buildings keep colony capacity including legacy above-cap colonies',
    () {
      final w = fundedWorld();
      final p = w.planets.first..colonyLevel = 5;
      for (var i = 0; i < p.buildingCap; i++) {
        expect(w.buildColony(p, ColonyBuilding.stabilizer), isTrue);
      }
      expect(p.building(ColonyBuilding.stabilizer), 5);
      expect(w.buildColony(p, ColonyBuilding.stabilizer), isFalse);
      for (final other in w.planets.skip(1)) {
        for (var lv = 0; lv < 3; lv++) {
          expect(w.upgradePlanet(other), isTrue);
          expect(w.buildColony(other, ColonyBuilding.stabilizer), isTrue);
        }
      }
      expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
      expect(
        w.upgradeRemotePlanet(0, 0, building: ColonyBuilding.stabilizer),
        isFalse,
      );
      w.counters['maxSector'] = 2;
      expect(w.upgradeRemotePlanet(0, 0), isTrue);
      expect(
        w.upgradeRemotePlanet(0, 0, building: ColonyBuilding.stabilizer),
        isTrue,
      );
      expect(w.remotePlanet(0, 0).building(ColonyBuilding.stabilizer), 6);
    },
  );
}
