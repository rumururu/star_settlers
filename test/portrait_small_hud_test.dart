// 작은 폰(SM-G525N: 339×697dp, 상태바 24·내비 48) + 큰 글자에서 세로 HUD 위쪽 묶음(정보·선장·목표)이 넘치지 않는다.
// 1.0.9 실기기 확인에서 '해적 부두목 격파' 목표 + 행성 곁 행동 버튼 두 줄일 때 넘침을 잡은 게이트 (1.0.8부터 있던 문제).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/ui/game_screen.dart';

import 'support/snap.dart';

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

  for (final lang in ['ko', 'de']) {
    for (final scale in [1.0, 1.1, 1.3]) {
      testWidgets('작은 세로 화면 HUD 넘침 없음 $lang ×$scale', (tester) async {
        addTearDown(() => resetScreen(tester));
        final w = GameWorld(seed: 3, profile: AppState.profile);
        w.planets[0].colonyLevel = 5;
        w.planets[1].colonyLevel = 3;
        w.totalTime = GameWorld.miniBossSeconds;
        final mars = w.planets.first;
        w.player.pos = mars.pos + Offset(0, -(mars.radius + 120));
        for (var i = 0; i < 5; i++) {
          w.update(0.02, InputState());
        }
        w.dialogs.clear();
        w.crewReveal = null;
        expect(w.nearbyPlanet, mars);
        expect(w.landUnlocked, isTrue);
        final errors = await pumpScreen(tester, GameScreen(world: w),
            size: const Size(339, 697),
            padding: const EdgeInsets.only(top: 24, bottom: 48),
            textScale: scale,
            lang: lang);
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byKey(const ValueKey('act-land')), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        expect(errors, isEmpty);
      });
    }
  }
}
