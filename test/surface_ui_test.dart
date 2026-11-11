import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/codex.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/surface.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart' show Lang, L10n, tr;
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/ui/codex_screen.dart';
import 'package:star_settlers/ui/colony_panel.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;
import 'package:star_settlers/ui/game_screen.dart';
import 'package:star_settlers/ui/sprites.dart';
import 'package:star_settlers/ui/surface_painter.dart';
import 'package:star_settlers/ui/surface_screen.dart';
import 'package:star_settlers/ui/tokens.dart';

/// 지표 탐험 화면 게이트 (surface-exploration TASK 002): 소개·탐사 HUD·결과·일시정지·식민지 발견 배지·도감 유물 탭을
/// ko/en/de × 세로 390×844·360×740·가로 800×360 × 글자 1.3배로 그려 넘침 0, HUD 위젯끼리 겹침 0·안전 영역 안.
/// SNAP_DIR=<폴더> 를 주면 각 화면 PNG를 저장한다 (증거 그림, 행성 종류별 탐사 화면 포함).
class _Screen {
  const _Screen(this.name, this.size, this.padding);
  final String name;
  final Size size;
  final EdgeInsets padding;
  @override
  String toString() => name;
}

const _screens = [
  _Screen('portrait', Size(390, 844), EdgeInsets.only(top: 47, bottom: 34)),
  _Screen('portrait360', Size(360, 740), EdgeInsets.only(top: 24)),
  _Screen('landscape', Size(800, 360), EdgeInsets.only(left: 24)),
];

final _snapDir = Platform.environment['SNAP_DIR'];
final _boundary = GlobalKey();

Future<List<String>> _pump(WidgetTester tester, _Screen s, Widget home, {double scale = 1.3}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = s.size;
  tester.view.padding = FakeViewPadding(left: s.padding.left, top: s.padding.top, right: s.padding.right, bottom: s.padding.bottom);
  tester.view.viewPadding = tester.view.padding;
  final errors = <String>[];
  final old = FlutterError.onError;
  FlutterError.onError = (e) {
    errors.add(e.exceptionAsString().split('\n').first);
    if (Platform.environment['LAYOUT_DEBUG'] != null) debugPrint(e.toString());
  };
  try {
    await tester.pumpWidget(RepaintBoundary(
      key: _boundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Lang.changed.value,
        supportedLocales: L10n.supportedLocales,
        localizationsDelegates: L10n.localizationsDelegates,
        theme: ThemeData(brightness: Brightness.dark, fontFamily: Ts.family, useMaterial3: true),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: home,
      ),
    ));
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump(const Duration(milliseconds: 16));
  } finally {
    FlutterError.onError = old;
  }
  final pending = tester.takeException();
  if (pending != null) errors.add('$pending');
  return errors;
}

Future<void> _snap(WidgetTester tester, String name) async {
  final dir = _snapDir;
  if (dir == null) return;
  await tester.runAsync(() async {
    final ro = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await ro.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    Directory(dir).createSync(recursive: true);
    File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Widget _layer(Widget panel) => Scaffold(
  backgroundColor: const Color(0xFF0D0B26),
  body: Stack(children: [Positioned.fill(child: panel)]),
);

/// 첫 식민지가 있는 메인 월드 (AppState.profile)
GameWorld _main() {
  final w = GameWorld(seed: 7, profile: AppState.profile)
    ..credits = 1000
    ..ore = 100
    ..spawnTimer = 1e9
    ..eventTimer = 1e9;
  w.planets.first.colonyLevel = 1;
  w.levels[UpgradeKind.missile] = 1;
  w.levels[UpgradeKind.shield] = 1;
  return w;
}

Planet _planetOf(GameWorld main, PlanetKind kind) =>
    main.planets.where((p) => p.kind == kind).firstOrNull ??
    Planet('Kepler-22b', 120, kind, orbitRadius: 1850, orbitPhase: 0);

/// 붐비는 탐사 장면: 유적 발굴 중(진행 막대), 생물이 화면 안, 산소 경고 직후
SurfaceWorld _busy(GameWorld main, PlanetKind kind, {bool atLander = false}) {
  final w = SurfaceWorld(main: main, planet: _planetOf(main, kind), runSeed: 5);
  final ruin = w.sites.firstWhere((s) => s.kind == SurfaceSiteKind.ruin);
  w.player.invulnerable = 1e9;
  final input = InputState();
  // 유적에 머물러 진행 막대가 보이게 (생물은 몰려온다)
  for (var t = 0.0; t < 2.2; t += 0.05) {
    w.player
      ..pos = ruin.pos + const Offset(30, 40)
      ..vel = Offset.zero;
    w.update(0.05, input);
  }
  w.lootCredits = 1234;
  w.lootOre = 56;
  // 산소 경고 직전으로 돌려 경고·압박을 띄운다
  w.oxygen = SurfaceRules.oxygenWarn + 0.02;
  w.update(0.05, input);
  final at = atLander ? w.map.lander + const Offset(40, 30) : ruin.pos + const Offset(30, 40);
  w.player.pos = at;
  var i = 0;
  for (final e in w.pirates) {
    e.pos = at + Offset.fromDirection(i * 0.9, 170.0 + (i % 4) * 60);
    i++;
  }
  w.player.invulnerable = 0;
  return w;
}

SurfaceSettlement _settlement({bool full = true}) => SurfaceSettlement(
  credits: 12345,
  ore: 678,
  gems: full ? 3 : 0,
  full: full,
  keepRatio: full ? 1 : 0.5,
  newVein: true,
  newNest: true,
  newSurveyed: full,
  relics: const ['crystal_core', 'compass'],
  fullRunsLeft: full ? 2 : 0,
  applied: true,
);

SurfaceOutcome _outcome(SurfaceEnd reason) => SurfaceOutcome(
  sector: 0,
  planetIndex: 1,
  planetKind: PlanetKind.desert,
  reason: reason,
  credits: 12345,
  ore: 678,
  sitesDone: reason == SurfaceEnd.returned ? 5 : 3,
  sitesTotal: 5,
  veinFound: true,
  nestCleared: true,
  relics: const ['crystal_core', 'compass'],
  relicDry: 0,
  seconds: 140,
);

List<String> _overlaps(Map<String, Rect> rects) {
  final keys = rects.keys.toList();
  return [
    for (var i = 0; i < keys.length; i++)
      for (var j = i + 1; j < keys.length; j++)
        if (rects[keys[i]]!.intersect(rects[keys[j]]!) case final r when r.width > 1 && r.height > 1) '${keys[i]} × ${keys[j]}',
  ];
}

void main() {
  setUpAll(() async {
    final font = FontLoader(Ts.family)
      ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Jua-Regular.ttf').readAsBytesSync())));
    await font.load();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppState.profile = Profile()..shipType = 'scout';
    AudioService.instance
      ..soundOn = false
      ..musicOn = false;
  });

  Future<void> loadSprites(WidgetTester tester) => tester.runAsync(() => Sprites.load([
    ...surfaceSpriteNames,
    for (final k in PlanetKind.values) 'planet_${k.name}',
  ]));

  for (final lang in ['ko', 'en', 'de']) {
    group('지표 탐험 화면 ($lang)', () {
      setUp(() => Lang.set(Locale(lang)));
      tearDown(() => Lang.set(const Locale('ko')));

      for (final s in _screens) {
        testWidgets('패널 넘침 없음 @ $s', (tester) async {
          addTearDown(tester.view.reset);
          await loadSprites(tester);
          final failures = <String>[];
          final main = _main();
          final planet = main.planets[1]
            ..vein = true
            ..nest = true
            ..surveyed = true;
          final w = SurfaceWorld(main: main, planet: planet, runSeed: 1);

          failures.addAll((await _pump(tester, s, _layer(SurfaceIntroPanel(world: w, fullLeft: 2, onStart: () {}, onExit: () {}))))
              .map((e) => 'intro: $e'));
          expect(find.byKey(const ValueKey('srf-disc-surveyed')), findsOneWidget);
          await _snap(tester, 'intro_${lang}_${s.name}');
          failures.addAll((await _pump(tester, s, _layer(SurfaceIntroPanel(world: w, fullLeft: 0, onStart: () {}, onExit: () {}))))
              .map((e) => 'intro reduced: $e'));
          expect(find.text(keepAll(tr.srf_reduced)), findsOneWidget);

          failures.addAll((await _pump(tester, s,
                  _layer(SurfaceResultPanel(outcome: _outcome(SurfaceEnd.returned), settlement: _settlement(), onExit: () {}))))
              .map((e) => 'result: $e'));
          expect(find.byKey(const ValueKey('srf-relic-compass')), findsOneWidget);
          expect(find.byKey(const ValueKey('srf-disc-surveyed')), findsOneWidget);
          await _snap(tester, 'result_${lang}_${s.name}');
          failures.addAll((await _pump(tester, s,
                  _layer(SurfaceResultPanel(outcome: _outcome(SurfaceEnd.destroyed), settlement: _settlement(full: false), onExit: () {}))))
              .map((e) => 'result lost: $e'));
          expect(find.text(tr.srf_kept(50)), findsOneWidget);
          await _snap(tester, 'result_lost_${lang}_${s.name}');

          // 식민지 패널 헤더: 발견 배지 + 효과 한 줄
          main.upgradePlanet(planet);
          final frame = ValueNotifier(0);
          failures.addAll((await _pump(
                  tester,
                  s,
                  _layer(ColonyPanel(world: main, planet: planet, frame: frame, act: (a) => a(), onClose: () {}, onTutorialDone: () {}))))
              .map((e) => 'colony: $e'));
          expect(find.byKey(const ValueKey('colony-discoveries')), findsOneWidget);
          await _snap(tester, 'colony_${lang}_${s.name}');

          // 도감 유물 탭: 찾은 것 셋 + 못 찾은 실루엣
          for (final id in ['star_map', 'idol', 'compass']) {
            AppState.profile.codex.recordRelic(id);
          }
          failures.addAll((await _pump(tester, s, CodexScreen(initialTab: CodexTab.relics.index))).map((e) => 'codex: $e'));
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
          await tester.pump();
          expect(find.byKey(const ValueKey('codex-relics-idol')), findsOneWidget);
          expect(find.text(keepAll(tr.srf_relicHint)), findsWidgets);
          await _snap(tester, 'codex_${lang}_${s.name}');

          await tester.pumpWidget(const SizedBox());
          expect(failures, isEmpty);
        });

        testWidgets('탐사 HUD 겹침·넘침 없음 @ $s', (tester) async {
          addTearDown(tester.view.reset);
          await loadSprites(tester);
          final main = _main();
          for (final atLander in [false, true]) {
            final w = _busy(main, PlanetKind.desert, atLander: atLander);
            final errors = await _pump(tester, s, SurfaceScreen(mainWorld: main, planet: main.planets[1], world: w, launched: true));
            expect(errors, isEmpty);
            final keys = ['srf-info', 'srf-pause', 'srf-joystick', 'srf-combat', 'srf-status', if (atLander) 'srf-return'];
            final rects = <String, Rect>{for (final k in keys) k: tester.getRect(find.byKey(ValueKey(k)))};
            expect(_overlaps(rects), isEmpty, reason: '$s $rects');
            final safe = s.padding.deflateRect(Offset.zero & s.size);
            for (final e in rects.entries) {
              expect(safe.inflate(0.5).contains(e.value.topLeft) && safe.inflate(0.5).contains(e.value.bottomRight), isTrue,
                  reason: '${e.key} ${e.value} outside $safe');
            }
            expect(rects['srf-pause']!.width, greaterThanOrEqualTo(Tap.min));
            if (atLander) expect(rects['srf-return']!.height, greaterThanOrEqualTo(Tap.min));
            await _snap(tester, 'hud${atLander ? '_lander' : ''}_${lang}_${s.name}');
            // 일시정지 → 비상 귀환 확인 (모달은 하나만)
            await tester.tap(find.byKey(const ValueKey('srf-pause')));
            await tester.pump();
            expect(find.byKey(const ValueKey('srf-pause-panel')), findsOneWidget);
            expect(tester.takeException(), isNull);
            if (!atLander) await _snap(tester, 'pause_${lang}_${s.name}');
            await tester.tap(find.text(keepAll(tr.srf_leaveYes)));
            await tester.pump();
            expect(find.byKey(const ValueKey('srf-leave')), findsOneWidget);
            expect(find.byKey(const ValueKey('srf-pause-panel')), findsNothing);
            expect(tester.takeException(), isNull);
            if (!atLander) await _snap(tester, 'leave_${lang}_${s.name}');
            await tester.pumpWidget(const SizedBox());
          }
        });
      }
    });
  }

  testWidgets('행성 종류별 탐사 화면 (증거 그림)', (tester) async {
    addTearDown(tester.view.reset);
    Lang.set(const Locale('ko'));
    await loadSprites(tester);
    final main = _main();
    for (final kind in surfaceKinds) {
      final w = _busy(main, kind);
      final errors = await _pump(tester, _screens.first,
          SurfaceScreen(mainWorld: main, planet: _planetOf(main, kind), world: w, launched: true), scale: 1);
      expect(errors, isEmpty, reason: kind.name);
      await _snap(tester, 'explore_${kind.name}');
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('끝까지: 비상 귀환하면 전리품 절반이 메인 월드에 들어가고 결과 화면이 뜬다', (tester) async {
    addTearDown(tester.view.reset);
    Lang.set(const Locale('ko'));
    final main = _main();
    final w = SurfaceWorld(main: main, planet: main.planets[1], runSeed: 2)
      ..lootCredits = 800
      ..lootOre = 40;
    final c0 = main.credits;
    await _pump(tester, _screens.first,
        SurfaceScreen(mainWorld: main, planet: main.planets[1], world: w, launched: true, clock: () => DateTime(2026, 11, 11, 12)),
        scale: 1);
    await tester.tap(find.byKey(const ValueKey('srf-pause')));
    await tester.pump();
    await tester.tap(find.text(keepAll(tr.srf_leaveYes)));
    await tester.pump();
    await tester.tap(find.descendant(of: find.byKey(const ValueKey('srf-leave')), matching: find.text(keepAll(tr.srf_leaveYes))));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const ValueKey('srf-result')), findsOneWidget);
    expect(main.credits, c0 + 400);
    expect(SurfaceRecords(AppState.profile.stats).runsToday(DateTime(2026, 11, 11, 12)), 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('게임 화면: 해금 뒤 행성 곁에 「착륙 탐사」, 가스 행성은 비활성', (tester) async {
    addTearDown(tester.view.reset);
    Lang.set(const Locale('ko'));
    final main = _main();
    final rock = main.planets.firstWhere((p) => p.kind != PlanetKind.gas && p.colonyLevel == 0);
    main.player.pos = rock.pos + Offset(0, rock.radius + 60);
    var errors = await _pump(tester, _screens.first, GameScreen(world: main), scale: 1.3);
    expect(errors, isEmpty);
    expect(find.byKey(const ValueKey('act-land')), findsOneWidget);
    expect(find.text(keepAll(tr.srf_land)), findsOneWidget);
    await _snap(tester, 'game_land_button');
    final gas = main.planets.firstWhere((p) => p.kind == PlanetKind.gas);
    main.player.pos = gas.pos + Offset(0, gas.radius + 60);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(keepAll(tr.srf_gasNoLand)), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    // 해금 전에는 버튼이 없다
    final fresh = GameWorld(seed: 7, profile: AppState.profile);
    fresh.player.pos = rock.pos + Offset(0, rock.radius + 60);
    errors = await _pump(tester, _screens.first, GameScreen(world: fresh), scale: 1);
    expect(find.byKey(const ValueKey('act-land')), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
