import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/rift.dart';
import 'package:star_settlers/game/ships.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart' show Lang, L10n, tr;
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/services/leaderboard.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;
import 'package:star_settlers/ui/leaderboard_screen.dart';
import 'package:star_settlers/ui/rift_cards.dart';
import 'package:star_settlers/ui/rift_screen.dart';
import 'package:star_settlers/ui/sprites.dart';
import 'package:star_settlers/ui/tokens.dart';

/// 균열 런 화면 게이트 (TASK 005): 소개·카드 고르기·결과·일시정지·순위 '균열' 탭·런 HUD를
/// ko/en/de, 세로 390×844·가로 800×360, 글자 1.3배로 그려 넘침 0, HUD 위젯끼리 겹침 0·안전 영역 안.
/// RIFT_SNAP_DIR=<폴더> 를 주면 각 화면 PNG를 저장한다 (증거 그림).
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
  _Screen('landscape', Size(800, 360), EdgeInsets.only(left: 24)),
];

final _snapDir = Platform.environment['RIFT_SNAP_DIR'];
final _boundary = GlobalKey();

Future<List<String>> _pump(WidgetTester tester, _Screen s, Widget home, {double scale = 1.3}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = s.size;
  tester.view.padding = FakeViewPadding(
      left: s.padding.left, top: s.padding.top, right: s.padding.right, bottom: s.padding.bottom);
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
    // 아이콘 이미지 디코딩은 실제 시간이 걸린다
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 120)));
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

/// 붐비는 런: 6파 전투 중, 적이 화면 가득, 카드 몇 장 (칼날·드론 보이게)
RiftWorld _busyRun() {
  final w = RiftWorld(plan: RiftPlan(20261108), mainProfile: AppState.profile);
  for (final c in [RiftCard.blades, RiftCard.blades, RiftCard.drone, RiftCard.multishot]) {
    w.loadout.take(c);
  }
  w.wave = 6;
  final input = InputState()
    ..fire = true
    ..autoAim = true;
  w.player.invulnerable = 1e9;
  for (var t = 0.0; t < RiftWorld.countdownSeconds + 5; t += 1 / 20) {
    w.update(1 / 20, input);
  }
  // 적을 화면 안으로 끌어온다
  var i = 0;
  for (final e in w.pirates) {
    e.pos = w.player.pos + Offset.fromDirection(i * 0.9, 180.0 + (i % 4) * 70);
    i++;
  }
  w.player.invulnerable = 0;
  return w;
}

Widget _layer(Widget panel) => Scaffold(
      backgroundColor: const Color(0xFF0D0B26),
      body: Stack(children: [Positioned.fill(child: panel)]),
    );

/// 순위표 가짜 서버: 긴 별명·큰 점수로 채운다
LeaderboardService _fakeBoard() {
  final store = MemoryLeaderboardStore()
    ..leaderboardOptIn = true
    ..installId = '0f8fad5b-d9cb-469f-a165-70867728950e'
    ..nicknameCode = '12-7-0427';
  return LeaderboardService(
    store: store,
    post: (rpc, body) async {
      if (rpc == 'starset_rift_board') {
        return (
          200,
          jsonEncode([
            for (var i = 1; i <= 12; i++)
              {'rank': i, 'nickname': '${(i * 7) % 40}-${(i * 11) % 40}-${1000 + i}', 'score': 95700 - i * 3100, 'waves': 10 - i % 4, 'me': i == 4},
          ]),
        );
      }
      if (rpc == 'starset_submit_rift') return (200, '{"rank":4,"total":12}');
      return (200, '[]');
    },
  );
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

  for (final lang in ['ko', 'en', 'de']) {
    group('균열 화면 ($lang)', () {
      setUp(() => Lang.set(Locale(lang)));
      tearDown(() => Lang.set(const Locale('ko')));

      for (final s in _screens) {
        testWidgets('패널 넘침 없음 @ $s', (tester) async {
          addTearDown(tester.view.reset);
          final failures = <String>[];
          final rec = RiftRecords(AppState.profile.stats);
          final now = DateTime.utc(2026, 11, 8, 12);
          rec.record(score: 23456, reached: 8, now: now);

          failures.addAll((await _pump(tester, s,
                  _layer(RiftIntroPanel(records: rec, now: now, onStart: () {}, onExit: () {}))))
              .map((e) => 'intro: $e'));
          expect(find.text(keepAll(tr.rift_start)), findsOneWidget);
          await _snap(tester, 'intro_${lang}_${s.name}');

          // 글자가 가장 긴 카드들 (레벨 표시가 붙도록 하나는 이미 1장)
          final l = RiftLoadout()..take(RiftCard.homing);
          var picked = <RiftCard>[];
          failures.addAll((await _pump(
                  tester,
                  s,
                  _layer(RiftCardPicker(
                    wave: 5,
                    offers: const [RiftCard.homing, RiftCard.drone, RiftCard.shockwave],
                    loadout: l,
                    onPick: (c) => picked = [...picked, c],
                  ))))
              .map((e) => 'picker: $e'));
          for (final c in const [RiftCard.homing, RiftCard.drone, RiftCard.shockwave]) {
            final f = find.byKey(ValueKey('rift-card-${c.name}'));
            expect(f, findsOneWidget);
            final r = tester.getRect(f);
            expect(r.height, greaterThanOrEqualTo(Tap.min), reason: '$c 터치 크기');
            expect(Offset.zero & s.size, isA<Rect>().having((x) => x.contains(r.center), 'on screen', isTrue));
          }
          await tester.tap(find.byKey(const ValueKey('rift-card-drone')));
          expect(picked, [RiftCard.drone]);
          await _snap(tester, 'picker_${lang}_${s.name}');

          const won = RiftOutcome(score: 41230, reached: 10, cleared: 10, conquered: true, seconds: 270, kills: 120, gaveUp: false);
          const reward = RiftReward(credits: 12345, ore: 678, gems: 3, full: true);
          failures.addAll((await _pump(
                  tester,
                  s,
                  _layer(RiftResultPanel(
                    outcome: won,
                    settlement: const RiftSettlement(reward: reward, newBest: true, best: 41230, mainApplied: true),
                    bestWave: 10,
                    onAgain: () {},
                    onExit: () {},
                  ))))
              .map((e) => 'result: $e'));
          expect(find.text(tr.rift_newBest), findsOneWidget);
          await _snap(tester, 'result_win_${lang}_${s.name}');

          const lost = RiftOutcome(score: 6150, reached: 6, cleared: 5, conquered: false, seconds: 160, kills: 40, gaveUp: true);
          failures.addAll((await _pump(
                  tester,
                  s,
                  _layer(RiftResultPanel(
                    outcome: lost,
                    settlement: const RiftSettlement(
                        reward: RiftReward(credits: 70, ore: 8, gems: 0, full: false),
                        newBest: false,
                        best: 41230,
                        mainApplied: false),
                    bestWave: 10,
                    onAgain: () {},
                    onExit: () {},
                  ))))
              .map((e) => 'result lose: $e'));
          expect(find.text(keepAll(tr.rift_rewardReduced)), findsOneWidget);
          await _snap(tester, 'result_reduced_${lang}_${s.name}');

          failures.addAll((await _pump(tester, s, _layer(RiftPausePanel(onResume: () {}, onGiveUp: () {}))))
              .map((e) => 'pause: $e'));
          await _snap(tester, 'pause_${lang}_${s.name}');

          // 순위표 '균열' 탭
          final svc = _fakeBoard();
          failures.addAll((await _pump(
                  tester,
                  s,
                  LeaderboardScreen(service: svc, score: WeeklyScore.now(), rift: RiftRecords(AppState.profile.stats))))
              .map((e) => 'board weekly: $e'));
          await tester.tap(find.byKey(const ValueKey('lb_tab_rift')));
          await tester.pumpAndSettle();
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
          await tester.pumpAndSettle();
          final pending = tester.takeException();
          if (pending != null) failures.add('board rift: $pending');
          expect(find.byKey(const ValueKey('rift-board')), findsOneWidget);
          // 내 줄(4위)은 세로 화면에서 바로 보인다 (가로는 스크롤 아래)
          if (s.size.height > s.size.width) expect(find.byKey(const ValueKey('rift_my_row')), findsOneWidget);
          await _snap(tester, 'board_${lang}_${s.name}');

          await tester.pumpWidget(const SizedBox());
          expect(failures, isEmpty);
        });

        testWidgets('런 HUD 겹침·넘침 없음 @ $s', (tester) async {
          addTearDown(tester.view.reset);
          await tester.runAsync(() => Sprites.load([
                for (final k in PirateKind.values) k == PirateKind.jelly ? 'jelly' : 'pirate_${k.name}',
                'ship_${shipTypes.first.id}_default',
                'station',
              ]));
          final w = _busyRun();
          expect(w.phase, RiftPhase.fighting);
          final errors = await _pump(tester, s, RiftScreen(world: w, launched: true));
          expect(errors, isEmpty);
          final rects = <String, Rect>{
            for (final k in ['rift-info', 'rift-pause', 'rift-joystick', 'rift-combat'])
              k: tester.getRect(find.byKey(ValueKey(k))),
          };
          final status = find.byKey(const ValueKey('rift-status'));
          expect(status, findsOneWidget);
          rects['rift-status'] = tester.getRect(status);
          final keys = rects.keys.toList();
          final overlaps = <String>[];
          for (var i = 0; i < keys.length; i++) {
            for (var j = i + 1; j < keys.length; j++) {
              final r = rects[keys[i]]!.intersect(rects[keys[j]]!);
              if (r.width > 1 && r.height > 1) overlaps.add('${keys[i]} × ${keys[j]}');
            }
          }
          expect(overlaps, isEmpty, reason: '$s $rects');
          final safe = s.padding.deflateRect(Offset.zero & s.size);
          for (final e in rects.entries) {
            expect(safe.inflate(0.5).contains(e.value.topLeft) && safe.inflate(0.5).contains(e.value.bottomRight), isTrue,
                reason: '${e.key} ${e.value} outside $safe');
          }
          // 일시정지 버튼은 48dp 이상
          expect(rects['rift-pause']!.width, greaterThanOrEqualTo(Tap.min));
          await _snap(tester, 'hud_${lang}_${s.name}');
          // 카드 고르기 화면 (실제 런에서): 남은 적이 다 나올 때까지 계속 격추
          w.player.invulnerable = 1e9;
          for (var i = 0; i < 200 && w.phase != RiftPhase.choosing; i++) {
            for (final e in w.pirates) {
              e.hp = 0;
            }
            await tester.pump(const Duration(milliseconds: 50));
          }
          expect(w.phase, RiftPhase.choosing);
          await tester.pump(const Duration(milliseconds: 50));
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
          await tester.pump(const Duration(milliseconds: 16));
          expect(find.byKey(const ValueKey('rift-picker')), findsOneWidget);
          expect(tester.takeException(), isNull);
          await _snap(tester, 'hud_picker_${lang}_${s.name}');
          await tester.pumpWidget(const SizedBox());
        });
      }
    });
  }

  testWidgets('결과까지: 포기하면 보상·기록이 메인 프로필에 들어가고 결과 화면이 뜬다', (tester) async {
    addTearDown(tester.view.reset);
    Lang.set(const Locale('ko'));
    final w = RiftWorld(plan: RiftPlan(20261108), mainProfile: AppState.profile);
    await _pump(tester, _screens.first, RiftScreen(world: w, launched: true, clock: () => DateTime.utc(2026, 11, 8, 12)),
        scale: 1);
    await tester.tap(find.byKey(const ValueKey('rift-pause')));
    await tester.pump();
    expect(find.byKey(const ValueKey('rift-pause-panel')), findsOneWidget);
    await tester.tap(find.text(keepAll(tr.rift_giveUp)));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const ValueKey('rift-result')), findsOneWidget);
    expect(RiftRecords(AppState.profile.stats).totalRuns, 1);
    // 세이브가 없으므로 크레딧·광석 없음 안내
    expect(find.text(keepAll(tr.rift_noSave)), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
