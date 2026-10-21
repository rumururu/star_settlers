import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:star_settlers/ui/tokens.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart';
import 'package:star_settlers/ui/colony_panel.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;
import 'package:star_settlers/ui/system_panel.dart';

void main() {
  for (final locale in L10n.supportedLocales) {
    testWidgets(
      'stabilizer panel ${locale.languageCode}: damaged HP and all buildings fit',
      (tester) async {
        final font = FontLoader(Ts.family)
          ..addFont(rootBundle.load('assets/fonts/Jua-Regular.ttf'));
        await font.load();
        Lang.set(locale);
        final w = GameWorld(seed: 4)
          ..credits = 1e8
          ..ore = 1e8
          ..counters['maxSector'] = 1;
        w.profile.colonyTutorialSeen = true;
        final p = w.planets.first;
        for (var i = 0; i < 5; i++) {
          expect(w.upgradePlanet(p), isTrue);
        }
        for (final b in ColonyBuilding.values) {
          w.buildColony(p, b);
        }
        p.stabilizerHp = 70;
        final frame = ValueNotifier(0);
        addTearDown(frame.dispose);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        tester.view.devicePixelRatio = 1;
        for (final size in [const Size(390, 844), const Size(800, 360)]) {
          tester.view.physicalSize = size;
          p.buildings[ColonyBuilding.stabilizer] = 1;
          Widget app(Widget child) => MaterialApp(
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
            home: Scaffold(body: child),
          );
          await tester.pumpWidget(
            app(
              ColonyPanel(
                world: w,
                planet: p,
                frame: frame,
                act: (action) {
                  action();
                  frame.value++;
                },
                onClose: () {},
                onTutorialDone: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text(keepAll(tr.u_levelUnlockAtSystem(6, 3))),
            findsOneWidget,
          );
          expect(find.text('🔒'), findsOneWidget);
          expect(find.text('MAX'), findsNothing);
          await tester.scrollUntilVisible(
            find.text('${ColonyBuilding.stabilizer.label}  Lv.1'),
            160,
          );
          await tester.pumpAndSettle();
          expect(find.text(tr.u_stabilizerHealth(70, 150)), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(
            app(SystemPanel(world: w, frame: frame, onClose: () {})),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (locale.languageCode == 'ko') {
            final meter = find.byKey(ValueKey('stabilizer-progress-${p.name}'));
            p.buildings[ColonyBuilding.stabilizer] = 3;
            frame.value++;
            await tester.pump();
            await tester.scrollUntilVisible(meter, 160);
            expect(tester.widget<LinearProgressIndicator>(meter).value, 0.6);
            p.buildings[ColonyBuilding.stabilizer] = 5;
            frame.value++;
            await tester.pump();
            expect(tester.widget<LinearProgressIndicator>(meter).value, 1);
          }
          await tester.pumpWidget(const SizedBox.shrink());
        }
      },
    );
  }
}
