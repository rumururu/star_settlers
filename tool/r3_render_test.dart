// TASK 003 렌더 증거: flutter test --no-pub tool/r3_render_test.dart
// 세로·가로 HUD를 ko/en/de, 글자 배율 1·1.3으로 그려 OUT_DIR(기본 /tmp/r3)에 PNG로 남긴다.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/game/next_goal.dart';
import 'package:star_settlers/ui/crew_reveal.dart';
import 'package:star_settlers/ui/game_screen.dart';

import '../test/support/snap.dart';

final out = Platform.environment['OUT_DIR'] ?? '/tmp/r3';

GameWorld busyWorld() {
  final w = GameWorld(seed: 1, profile: AppState.profile)
    ..credits = 5000
    ..ore = 900;
  w.player.pos = w.stations.first.pos;
  w.events
    ..add(WorldEvent(91, EventKind.raid, w.planets[1].pos, 45, planet: w.planets[1]))
    ..add(WorldEvent(92, EventKind.meteor, w.planets[2].pos, 30))
    ..add(WorldEvent(93, EventKind.supply, w.planets[2].pos, 20));
  w.say(Speaker.advisor, '정거장에 오면 함선을 강화하고 승무원을 고용할 수 있어요. 해적이 몰려오기 전에 준비해요!');
  return w;
}

void main() {
  setUpAll(loadAppFont);
  setUp(() {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    AppState.profile = Profile();
    AudioService.instance
      ..soundOn = false
      ..musicOn = false;
  });

  const shots = [
    ('portrait', Size(390, 844), EdgeInsets.only(top: 47, bottom: 34)),
    ('portrait360', Size(360, 740), EdgeInsets.only(top: 24)),
    ('landscape', Size(800, 360), EdgeInsets.only(left: 24)),
  ];
  for (final lang in ['ko', 'en', 'de']) {
    for (final (name, size, pad) in shots) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('HUD $lang $name x$scale', (tester) async {
          addTearDown(() => resetScreen(tester));
          final w = busyWorld();
          final errors = await pumpScreen(
            tester,
            GameScreen(world: w),
            size: size,
            padding: pad,
            textScale: scale,
            lang: lang,
          );
          await savePng(tester, '$out/hud_${lang}_${name}_x$scale.png');
          await tester.pumpWidget(const SizedBox());
          expect(errors, isEmpty);
        });
      }
      testWidgets('crew reveal $lang $name', (tester) async {
        addTearDown(() => resetScreen(tester));
        final w = GameWorld(seed: 4);
        final c = w.grantCrew(3)..assigned = true;
        final errors = await pumpScreen(
          tester,
          Scaffold(
            backgroundColor: Colors.black,
            body: Stack(children: [
              Positioned.fill(child: CrewRevealCard(crew: c, assigned: true, onClose: () {})),
            ]),
          ),
          size: size,
          padding: pad,
          textScale: 1.3,
          lang: lang,
        );
        await tester.pump(const Duration(seconds: 2));
        await savePng(tester, '$out/reveal_${lang}_$name.png');
        await tester.pumpWidget(const SizedBox());
        expect(errors, isEmpty);
      });
      testWidgets('mini boss goal $lang $name', (tester) async {
        addTearDown(() => resetScreen(tester));
        final w = GameWorld(seed: 5, profile: AppState.profile)..totalTime = GameWorld.miniBossSeconds;
        for (var i = 0; i < 12; i++) {
          w.update(0.05, InputState());
        }
        w.crewReveal = null;
        w.pirates.where((e) => e.miniBoss).first
          ..hp *= 0.4
          ..pos = w.player.pos + const Offset(160, -60);
        final errors = await pumpScreen(tester, GameScreen(world: w),
            size: size, padding: pad, textScale: 1.3, lang: lang);
        await savePng(tester, '$out/miniboss_${lang}_$name.png');
        await tester.pumpWidget(const SizedBox());
        expect(errors, isEmpty);
      });
      testWidgets('goal done flash $lang $name', (tester) async {
        addTearDown(() => resetScreen(tester));
        final w = GameWorld(seed: 5, profile: AppState.profile)
          ..goalDone = const NextGoal(GoalKind.settle, 'act_settle', '')
          ..goalFlash = GameWorld.goalFlashSeconds / 2;
        final errors = await pumpScreen(tester, GameScreen(world: w),
            size: size, padding: pad, textScale: 1.3, lang: lang);
        await savePng(tester, '$out/goalflash_${lang}_$name.png');
        await tester.pumpWidget(const SizedBox());
        expect(errors, isEmpty);
      });
    }
  }
}
