import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart';
import 'package:star_settlers/ui/colonies_panel.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;
import 'package:star_settlers/ui/game_icons.dart';
import 'package:star_settlers/ui/tokens.dart';

/// 태양계 화성 Lv.2 + 다음 항성계에 새 식민지 하나
GameWorld twoSystems() {
  final w = GameWorld(seed: 151)
    ..credits = 1e12
    ..ore = 1e12
    ..spawnTimer = 1e9
    ..eventTimer = 1e9;
  final mars = w.planets.first;
  w.upgradePlanet(mars);
  w.upgradePlanet(mars);
  w.buildColony(mars, ColonyBuilding.stabilizer);
  w.counters['maxSector'] = 1;
  w.warp(w.gates.firstWhere((g) => g.forward));
  w.upgradePlanet(w.planets.first);
  return w;
}

void main() {
  for (final locale in L10n.supportedLocales) {
    testWidgets(
      'colonies panel ${locale.languageCode}: both systems listed, fits phone and landscape',
      (tester) async {
        final font = FontLoader(Ts.family)
          ..addFont(rootBundle.load('assets/fonts/Jua-Regular.ttf'));
        await font.load();
        Lang.set(locale);
        final w = twoSystems();
        while (w.planets.first.colonyLevel < w.colonyLevelCap) {
          expect(w.upgradePlanet(w.planets.first), isTrue);
        }
        while (w.remotePlanet(0, 0).colonyLevel < w.colonyLevelCap) {
          expect(w.upgradeRemotePlanet(0, 0), isTrue);
        }
        final frame = ValueNotifier(0);
        addTearDown(frame.dispose);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        tester.view.devicePixelRatio = 1;
        for (final size in [const Size(360, 740), const Size(800, 360)]) {
          w.counters['maxSector'] = 1;
          tester.view.physicalSize = size;
          await tester.pumpWidget(
            MaterialApp(
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
              home: Scaffold(
                body: ColoniesPanel(
                  world: w,
                  frame: frame,
                  act: (f) => f(),
                  onClose: () {},
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$size');
          expect(find.text(tr.u_myColonies), findsOneWidget);
          expect(find.text(tr.u_currentHere), findsOneWidget);
          expect(
            tester.getTopLeft(find.text(tr.u_currentHere)).dy,
            greaterThanOrEqualTo(
              tester.getTopLeft(find.byType(Scrollable).last).dy,
            ),
            reason: 'current system header stays visible after resizing',
          );
          expect(find.textContaining(w.planets.first.name), findsOneWidget);
          expect(
            find.text(keepAll(tr.u_levelUnlockAtSystem(6, 3))),
            findsAtLeastNWidgets(1),
          );
          final locks = find.ancestor(
            of: find.text('🔒'),
            matching: find.byType(ElevatedButton),
          );
          expect(locks, findsAtLeastNWidgets(1));
          for (final button in tester.widgetList<ElevatedButton>(locks)) {
            expect(button.onPressed, isNull);
          }
          for (var i = 0; i < locks.evaluate().length; i++) {
            final size =
                tester.getBottomRight(locks.at(i)) -
                tester.getTopLeft(locks.at(i));
            expect(size.dx, greaterThanOrEqualTo(Tap.min));
            expect(size.dy, greaterThanOrEqualTo(Tap.min));
          }
          expect(find.text('MAX'), findsNothing);
          await tester.scrollUntilVisible(
            find.textContaining(w.remotePlanet(0, 0).name),
            100,
            scrollable: find.byType(Scrollable).last,
          );
          expect(tester.takeException(), isNull, reason: '$size');
          expect(
            find.text(keepAll(tr.u_levelUnlockAtSystem(6, 3))),
            findsAtLeastNWidgets(1),
          );
          w.counters['maxSector'] = 2;
          frame.value++;
          await tester.pump();
          expect(find.text('🔒'), findsNothing);
          expect(
            find.text(keepAll(tr.u_levelUnlockAtSystem(6, 3))),
            findsNothing,
          );
        }
      },
    );
  }

  testWidgets('tapping buttons upgrades the current and a remote colony', (
    tester,
  ) async {
    Lang.set(const Locale('ko'));
    final w = twoSystems();
    final frame = ValueNotifier(0);
    addTearDown(frame.dispose);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('ko'),
        home: Scaffold(
          body: ColoniesPanel(
            world: w,
            frame: frame,
            act: (f) {
              f();
              frame.value++;
            },
            onClose: () {},
          ),
        ),
      ),
    );
    // 줄 순서: [현재 항성계 Lv버튼, 정박기버튼], [화성 Lv버튼, 정박기버튼]
    Finder btn(String icon) => find.ancestor(
      of: find.byWidgetPredicate((x) => x is GameIcon && x.name == icon),
      matching: find.byType(ElevatedButton),
    );
    final level = btn('colony_levelup');
    final anchor = btn(ColonyBuilding.stabilizer.iconAsset);
    expect(level, findsAtLeastNWidgets(2));
    await tester.tap(anchor.at(0));
    await tester.pump();
    expect(w.planets.first.building(ColonyBuilding.stabilizer), 1);
    await tester.tap(anchor.at(1));
    await tester.pump();
    expect(w.remotePlanet(0, 0).building(ColonyBuilding.stabilizer), 2);
    await tester.tap(level.at(1));
    await tester.pump();
    expect(w.remotePlanet(0, 0).colonyLevel, 3);
  });
}
