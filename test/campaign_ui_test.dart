import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/campaign.dart';
import 'package:star_settlers/game/missions.dart';
import 'package:star_settlers/l10n/l.dart';
import 'package:star_settlers/ui/story_panel.dart';

void main() {
  for (final locale in L10n.supportedLocales) {
    for (final size in [const Size(844, 390), const Size(390, 844)]) {
      testWidgets('campaign chapters ${locale.languageCode} $size', (
        tester,
      ) async {
        Lang.set(locale);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);
        for (final sector in campaignSectors) {
          var finished = false;
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              supportedLocales: L10n.supportedLocales,
              localizationsDelegates: L10n.localizationsDelegates,
              home: MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: StoryPanel(
                  key: ValueKey(sector),
                  scene: StoryScene.campaign,
                  campaignSector: sector,
                  onDone: () => finished = true,
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          final next = find.byKey(const ValueKey('story-next'));
          expect(next.hitTestable(), findsOneWidget);
          await tester.tap(next);
          expect(finished, isTrue);
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
