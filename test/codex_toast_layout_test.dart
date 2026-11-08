// 도감 "새 항목" 토스트가 HUD(다음 목표 칩·선장 카드·대사·조작 버튼 등)를 가리지 않는다.
// 1.0.8 통합 검토에서 세로 화면 토스트가 '다음 목표' 칩을 덮은 것을 잡은 게이트.
// 토스트는 대사와 같은 칸(hud-dialog)에 나오고, 대사가 떠 있으면 끝날 때까지 기다린다.
// 증거 PNG: SNAP_DIR=<폴더> flutter test --no-pub test/codex_toast_layout_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/codex.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/ui/game_screen.dart';

import 'support/snap.dart';

final _snapDir = Platform.environment['SNAP_DIR'];

/// 토스트가 피해야 하는 HUD 요소 (화면 구역 컨테이너 hud-left/right/dialog-zone 는 제외)
const _hudKeys = [
  'hud-captain', 'hud-info', 'hud-map', 'hud-minimap', 'hud-goal',
  'hud-joystick', 'hud-cruise', 'hud-combat', 'hud-actions', 'hud-autofire', 'hud-invasion',
];

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
      testWidgets('도감 토스트가 HUD를 가리지 않음 $lang $name', (tester) async {
        addTearDown(() => resetScreen(tester));
        // 다음 목표 칩 + 미나 대사가 함께 떠 있는 바쁜 장면 (미니 두목 등장 직후)
        final w = GameWorld(seed: 5, profile: AppState.profile)..totalTime = GameWorld.miniBossSeconds;
        for (var i = 0; i < 12; i++) {
          w.update(0.05, InputState());
        }
        w.crewReveal = null;
        AppState.profile.codex.toasts.add((tab: CodexTab.crew, id: 'scientist_3'));
        final errors = await pumpScreen(tester, GameScreen(world: w),
            size: size, padding: pad, textScale: 1.3, lang: lang);
        final toast = find.byWidgetPredicate(
            (wd) => wd.key is ValueKey<String> && (wd.key! as ValueKey<String>).value.startsWith('codex-toast-'));
        await tester.pump(const Duration(milliseconds: 400));
        expect(w.dialogs, isNotEmpty);
        expect(toast, findsNothing, reason: '$lang $name 대사가 떠 있는 동안은 기다린다');
        w.dialogs.clear();
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(toast, findsOneWidget, reason: '$lang $name 대사가 끝나면 토스트 표시');
        expect(find.descendant(of: find.byKey(const ValueKey('hud-dialog')), matching: toast), findsOneWidget,
            reason: '대사 칸에 나온다');
        final t = tester.getRect(toast);
        final hits = <String>[];
        for (final k in _hudKeys) {
          for (final e in find.byKey(ValueKey(k)).evaluate()) {
            final r = tester.getRect(find.byWidget(e.widget));
            if (r.isEmpty) continue;
            final o = t.intersect(r);
            if (o.width > 0.5 && o.height > 0.5) hits.add('$k $r');
          }
        }
        if (_snapDir != null) await savePng(tester, '$_snapDir/codex_toast_hud_${lang}_$name.png');
        expect(hits, isEmpty, reason: '$lang $name 토스트 $t 가 덮음');
        await tester.pumpWidget(const SizedBox());
        expect(errors, isEmpty);
      });
    }
  }
}
