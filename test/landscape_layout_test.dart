import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart' show Lang, L10n;
import 'package:star_settlers/main.dart' show TitleScreen;
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/services/orientation.dart';
import 'package:star_settlers/ui/colony_panel.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;
import 'package:star_settlers/ui/game_screen.dart';
import 'package:star_settlers/ui/hangar_screen.dart';
import 'package:star_settlers/ui/home_screen.dart';
import 'package:star_settlers/ui/merchant_panel.dart';
import 'package:star_settlers/ui/meta_screens.dart';
import 'package:star_settlers/ui/shop_screen.dart';
import 'package:star_settlers/ui/station_panel.dart';
import 'package:star_settlers/ui/system_panel.dart';
import 'package:star_settlers/ui/tokens.dart';

/// 화면 크기 (논리 픽셀) + 안전 영역 (가로 폰은 옆에 노치)
class Screen {
  const Screen(this.name, this.size, [this.padding = EdgeInsets.zero]);
  final String name;
  final Size size;
  final EdgeInsets padding;
  @override
  String toString() => name;
}

const screens = [
  Screen('portrait phone 390x844', Size(390, 844), EdgeInsets.only(top: 47, bottom: 34)),
  Screen('landscape phone 844x390', Size(844, 390), EdgeInsets.only(left: 47, right: 47, bottom: 21)),
  Screen('landscape phone 932x430', Size(932, 430), EdgeInsets.only(left: 59, right: 59, bottom: 21)),
  Screen('landscape android 800x360', Size(800, 360), EdgeInsets.only(left: 24)),
  Screen('landscape iPad 1366x1024', Size(1366, 1024), EdgeInsets.only(top: 24, bottom: 20)),
];

Future<void> setScreen(WidgetTester tester, Screen s) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = s.size;
  tester.view.padding = FakeViewPadding(
      left: s.padding.left, top: s.padding.top, right: s.padding.right, bottom: s.padding.bottom);
  tester.view.viewPadding = tester.view.padding;
}

Widget app(Widget home) => MaterialApp(
      locale: Lang.changed.value,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,
      theme: ThemeData(brightness: Brightness.dark, fontFamily: Ts.family, useMaterial3: true),
      home: home,
    );

/// 오버레이 패널은 게임 화면처럼 전체 화면 Stack 위에 띄운다
Widget overlay(Widget panel) => Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [Positioned.fill(child: panel)]),
    );

/// 화면이 그려지는 동안 넘침(RenderFlex overflow 등) 예외가 없어야 한다.
/// 한 화면이 실패해도 나머지 화면을 계속 검사하도록 실패를 [failures]에 모은다.
final failures = <String>[];

Future<void> expectNoOverflow(WidgetTester tester, Screen s, Widget home, {String what = ''}) async {
  await setScreen(tester, s);
  final errors = <FlutterErrorDetails>[];
  final old = FlutterError.onError;
  FlutterError.onError = errors.add;
  try {
    await tester.pumpWidget(app(home));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  } finally {
    FlutterError.onError = old;
  }
  for (final e in errors) {
    if (Platform.environment['LAYOUT_DEBUG'] != null) debugPrint(e.toString());
    failures.add('$what @ $s: ${e.exceptionAsString().split('\n').first}');
  }
  final pending = tester.takeException();
  if (pending != null) failures.add('$what @ $s: $pending');
}

void expectNoFailures() {
  final f = [...failures];
  failures.clear();
  expect(f, isEmpty);
}

/// 대사·근처 정거장·행성·이벤트가 모두 떠 있는 붐비는 HUD
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

/// HUD 조작·정보 위젯이 화면에서 차지하는 사각형들 (보이는 영역 기준)
Map<String, Rect> hudRects(WidgetTester tester) {
  final out = <String, Rect>{};
  Rect? rectOf(String key) {
    final f = find.byKey(ValueKey(key));
    return f.evaluate().isEmpty ? null : tester.getRect(f);
  }

  for (final k in ['hud-captain', 'hud-info', 'hud-joystick', 'hud-cruise', 'hud-combat', 'hud-autofire']) {
    final r = rectOf(k);
    if (r != null) out[k] = r;
  }
  // 세로 HUD의 자동 사격 토글은 전투 묶음 안에 있다 (같은 묶음이므로 따로 비교하지 않는다)
  if (out.containsKey('hud-autofire') && out['hud-combat']!.contains(out['hud-autofire']!.center)) {
    out.remove('hud-autofire');
  }
  var dialog = rectOf('hud-dialog');
  final zone = rectOf('hud-dialog-zone');
  if (dialog != null && zone != null) dialog = dialog.intersect(zone);
  if (dialog != null) out['hud-dialog'] = dialog;
  // 상황 버튼은 Wrap 전체가 아니라 버튼 하나하나
  final wrap = find.byKey(const ValueKey('hud-actions'));
  if (wrap.evaluate().isNotEmpty) {
    var i = 0;
    tester.renderObject<RenderWrap>(wrap).visitChildren((c) {
      final box = c as RenderBox;
      out['action${i++}'] = MatrixUtils.transformRect(box.getTransformTo(null), Offset.zero & box.size);
    });
  }
  return out;
}

/// 겹치는 쌍 (1px 미만 접촉은 무시)
List<String> overlaps(Map<String, Rect> rects) {
  final keys = rects.keys.toList();
  final out = <String>[];
  for (var i = 0; i < keys.length; i++) {
    for (var j = i + 1; j < keys.length; j++) {
      if (keys[i].startsWith('action') && keys[j].startsWith('action')) continue;
      final r = rects[keys[i]]!.intersect(rects[keys[j]]!);
      if (r.width > 1 && r.height > 1) out.add('${keys[i]} × ${keys[j]} ${rects[keys[i]]} ${rects[keys[j]]}');
    }
  }
  return out;
}

/// 화면 밖이나 안전 영역(노치) 밖으로 나간 위젯
List<String> outsideSafeArea(Map<String, Rect> rects, Screen s) {
  final safe = s.padding.deflateRect(Offset.zero & s.size);
  return [
    for (final e in rects.entries)
      if (e.value.left < safe.left - 0.5 ||
          e.value.top < safe.top - 0.5 ||
          e.value.right > safe.right + 0.5 ||
          e.value.bottom > safe.bottom + 0.5)
        '${e.key} ${e.value} outside $safe',
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
    AppState.profile = Profile();
    AudioService.instance
      ..soundOn = false
      ..musicOn = false;
  });

  testWidgets('상점의 구매 복원을 누르면 복원된 패키지가 바로 보유 중으로 바뀐다', (tester) async {
    Lang.set(const Locale('ko'));
    // 패키지 탭 전체(맨 아래 복원 버튼까지)가 한 화면에 그려지게 길게
    await setScreen(tester, const Screen('tall', Size(430, 2400), EdgeInsets.zero));
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(const ShopScreen(initialTab: 1)));
    await tester.pumpAndSettle();
    expect(find.text(L10n.of(tester.element(find.byType(ShopScreen))).m_owned), findsNothing);
    // 복원이 지급한 상태 (실제 앱에서는 RevenueCat 복원이 AppState.grant 로 바꾼다)
    AppState.profile
      ..starterBought = true
      ..premium = true;
    final restore = find.text(keepAll('구매 복원'), findRichText: true);
    await tester.tap(restore);
    await tester.pumpAndSettle();
    expect(find.text(L10n.of(tester.element(find.byType(ShopScreen))).m_owned), findsNWidgets(2));
  });

  group('화면 방향 설정', () {
    test('기본은 세로, 저장하고 다시 읽어도 같다', () {
      expect(Profile().orientation, ScreenOrient.portrait);
      for (final o in ScreenOrient.values) {
        final back = Profile.fromJson(jsonRoundTrip((Profile()..orientation = o).toJson()));
        expect(back.orientation, o);
      }
    });

    test('예전 저장(값 없음)이나 모르는 값은 세로', () {
      final j = Profile().toJson()..remove('orient');
      expect(Profile.fromJson(j).orientation, ScreenOrient.portrait);
      expect(Profile.fromJson(Profile().toJson()..['orient'] = 'sideways').orientation, ScreenOrient.portrait);
      expect(Profile.fromJson(Profile().toJson()..['orient'] = 3).orientation, ScreenOrient.portrait);
    });

    test('설정 → 기기 방향', () {
      expect(deviceOrientationsFor(ScreenOrient.portrait),
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      expect(deviceOrientationsFor(ScreenOrient.landscape),
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      // 자동 = 시스템 기본 (기기 회전 잠금 설정을 따른다)
      expect(deviceOrientationsFor(ScreenOrient.auto), isEmpty);
    });
  });

  testWidgets('설정에서 가로를 고르면 저장되고 기기 방향이 바뀐다', (tester) async {
    Lang.set(const Locale('ko'));
    final calls = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemChrome.setPreferredOrientations') calls.add(call.arguments);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(app(const SettingsScreen()));
    await tester.scrollUntilVisible(find.text('화면 방향'), 100);
    expect(find.text('세로'), findsOneWidget); // 기본값
    await tester.tap(find.text('화면 방향'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가로'));
    await tester.pumpAndSettle();
    expect(AppState.profile.orientation, ScreenOrient.landscape);
    expect(calls.last, ['DeviceOrientation.landscapeLeft', 'DeviceOrientation.landscapeRight']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isNotEmpty); // 프로필이 저장됐다
    expect(find.text('가로'), findsOneWidget); // 부제가 바뀐다
  });

  for (final lang in ['ko', 'en', 'de']) {
    group('넘침 없음 ($lang)', () {
      setUp(() => Lang.set(Locale(lang)));
      tearDown(() => Lang.set(const Locale('ko')));

      for (final s in screens) {
        testWidgets('게임 HUD @ $s', (tester) async {
          addTearDown(tester.view.reset);
          final w = busyWorld();
          await expectNoOverflow(tester, s, GameScreen(world: w), what: 'HUD');
          // 가로 HUD와 iPad: 조작·정보 위젯끼리 겹치지 않고 안전 영역 안에 있다
          if (s.size.width > s.size.height) {
            final rects = hudRects(tester);
            if (Platform.environment['LAYOUT_DEBUG'] != null) {
              debugPrint('$s\n${rects.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}');
            }
            expect(rects.keys, containsAll(['hud-captain', 'hud-info', 'hud-joystick', 'hud-cruise', 'hud-combat', 'hud-dialog']));
            expect(rects.keys.where((k) => k.startsWith('action')), isNotEmpty);
            expect(overlaps(rects), isEmpty, reason: '$s');
            expect(outsideSafeArea(rects, s), isEmpty, reason: '$s');
          }
          // 사라지기 전에 정리 (dispose가 저장한다)
          await tester.pumpWidget(const SizedBox());
          expectNoFailures();
        });

        testWidgets('패널 @ $s', (tester) async {
          addTearDown(tester.view.reset);
          final w = busyWorld();
          AppState.world = w;
          final frame = ValueNotifier(0);
          void act(bool Function() a) => a();
          final planet = w.planets.first;
          w.upgradePlanet(planet);
          await expectNoOverflow(
              tester,
              s,
              overlay(StationPanel(
                  world: w, station: w.stations.first, frame: frame, act: act, onClose: () {}, onOpenShop: () {})),
              what: 'station');
          await expectNoOverflow(
              tester,
              s,
              overlay(ColonyPanel(
                  world: w, planet: planet, frame: frame, act: act, onClose: () {}, onTutorialDone: () {})),
              what: 'colony');
          await expectNoOverflow(tester, s, overlay(SystemPanel(world: w, frame: frame, onClose: () {})),
              what: 'system');
          await expectNoOverflow(tester, s, overlay(StationBuildPanel(world: w, act: act, onClose: () {})),
              what: 'build station');
          final merchant = WorldEvent(90, EventKind.merchant, w.player.pos, 60);
          await expectNoOverflow(
              tester,
              s,
              overlay(MerchantPanel(world: w, event: merchant, frame: frame, act: act, onClose: () {})),
              what: 'merchant');
          AppState.world = null;
          expectNoFailures();
        });

        testWidgets('메뉴 화면 @ $s', (tester) async {
          addTearDown(tester.view.reset);
          await expectNoOverflow(tester, s, const TitleScreen(), what: 'title');
          await expectNoOverflow(tester, s, const SettingsScreen(), what: 'settings');
          for (var tab = 0; tab < 6; tab++) {
            await expectNoOverflow(tester, s, ShopScreen(initialTab: tab), what: 'shop tab $tab');
          }
          await expectNoOverflow(tester, s, const HangarScreen(), what: 'hangar');
          await expectNoOverflow(tester, s, const HomePlanetScreen(), what: 'home planet');
          await expectNoOverflow(tester, s, const AchievementsScreen(), what: 'achievements');
          await expectNoOverflow(tester, s, const DailyQuestScreen(), what: 'daily');
          await tester.pumpWidget(const SizedBox());
          expectNoFailures();
        });
      }
    });
  }
}

Map<String, dynamic> jsonRoundTrip(Map<String, dynamic> j) =>
    (jsonDecode(jsonEncode(j)) as Map).cast<String, dynamic>();
