import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/attendance.dart';
import 'package:star_settlers/game/expedition.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart' show tr;
import 'package:star_settlers/main.dart' show TitleScreen;
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/ui/calendar_panel.dart';
import 'package:star_settlers/ui/crew_reveal.dart';
import 'package:star_settlers/ui/game_screen.dart';
import 'package:star_settlers/ui/pause_menu.dart';
import 'package:star_settlers/ui/station_panel.dart';

import 'support/snap.dart';

/// 렌더 게이트 (TASK 003 승무원 카드 · TASK 004 출석 달력·원정·내일 미리보기):
/// ko/en/de × 세로 390×844 · 가로 800×360 × 글자 배율 1.0·1.3 에서 넘침(그리기 오류) 0.
/// `OUT_DIR=<폴더>`를 주면 같은 화면을 PNG로 남긴다 (증거용).
final _out = Platform.environment['OUT_DIR'];

const _screens = [
  ('portrait', Size(390, 844), EdgeInsets.only(top: 47, bottom: 34)),
  ('landscape', Size(800, 360), EdgeInsets.only(left: 24)),
];

Widget _overlay(Widget panel) => Scaffold(
  backgroundColor: const Color(0xFF070614),
  body: Stack(children: [Positioned.fill(child: panel)]),
);

final _now = DateTime(2026, 11, 8, 10);

/// 연속 2일 받은 프로필 (오늘 3일째)
Profile _calendarProfile() {
  final p = Profile();
  Attendance.claim(p, _now.subtract(const Duration(days: 2)));
  Attendance.claim(p, _now.subtract(const Duration(days: 1)));
  return p;
}

/// 원정 하나 진행 중(+ [doneToo]면 귀환한 원정 하나) + 쉬는 승무원. 원정 패널은 실제 시계를 쓴다
GameWorld _expeditionWorld({bool doneToo = false}) {
  final w = GameWorld(seed: 3, profile: AppState.profile);
  for (var i = 0; i < 5; i++) {
    w.grantCrew(1 + i % 3).assigned = false;
  }
  w.toggleAssign(w.roster[4]);
  final then = DateTime.now().subtract(const Duration(hours: 5));
  w.startExpedition(w.roster[1], 8, then);
  if (doneToo) w.startExpedition(w.roster[0], 4, then);
  return w;
}

void main() {
  setUpAll(loadAppFont);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppState.profile = Profile();
    AudioService.instance
      ..soundOn = false
      ..musicOn = false;
  });

  Future<void> gate(
    WidgetTester tester,
    String name,
    Widget Function() build, {
    Future<void> Function()? after,
  }) async {
    for (final lang in ['ko', 'en', 'de']) {
      for (final (screen, size, pad) in _screens) {
        for (final scale in [1.0, 1.3]) {
          final errors = await pumpScreen(
            tester,
            build(),
            size: size,
            padding: pad,
            textScale: scale,
            lang: lang,
          );
          if (after != null) await after();
          await tester.pump(const Duration(seconds: 2));
          expect(errors, isEmpty, reason: '$name $lang $screen x$scale');
          final err = tester.takeException();
          expect(err, isNull, reason: '$name $lang $screen x$scale');
          if (_out != null) {
            await savePng(tester, '$_out/${name}_${lang}_${screen}_x$scale.png');
          }
          await tester.pumpWidget(const SizedBox());
        }
      }
    }
  }

  testWidgets('승무원 카드 공개', (tester) async {
    addTearDown(() => resetScreen(tester));
    final w = GameWorld(seed: 4);
    final c = w.grantCrew(3);
    await gate(
      tester,
      'reveal',
      () => _overlay(CrewRevealCard(crew: c, assigned: true, onClose: () {})),
    );
  });

  testWidgets('출석 달력: 오늘 받기 전', (tester) async {
    addTearDown(() => resetScreen(tester));
    await gate(
      tester,
      'calendar',
      () => _overlay(
        CalendarPanel(profile: _calendarProfile(), now: _now, onClose: () {}),
      ),
    );
  });

  testWidgets('출석 달력: 받은 뒤 (내일 미리보기)', (tester) async {
    addTearDown(() => resetScreen(tester));
    await gate(tester, 'calendar_claimed', () {
      final p = _calendarProfile();
      Attendance.claim(p, _now);
      return _overlay(CalendarPanel(profile: p, now: _now, onClose: () {}));
    });
  });

  testWidgets('출석 달력: 받기 버튼을 누르면 받은 화면으로 바뀐다', (tester) async {
    addTearDown(() => resetScreen(tester));
    final p = _calendarProfile();
    var claimed = 0;
    await pumpScreen(
      tester,
      _overlay(
        CalendarPanel(
          profile: p,
          now: _now,
          onClose: () {},
          onClaimed: () => claimed++,
        ),
      ),
      size: const Size(360, 740),
      textScale: 1.3,
      lang: 'de',
    );
    await tester.tap(find.byKey(const ValueKey('calendar-claim')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(claimed, 1);
    expect(p.loginStreak, 3);
    expect(p.pendingCrew2, 1, reason: '3일째 ★2');
    expect(find.text(tr.r4_calendarClaimed), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('tomorrow-card')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  for (final doneToo in [false, true]) {
    testWidgets('승무원 원정 (정거장 승무원 탭) ${doneToo ? '귀환' : '보내기'}', (tester) async {
      addTearDown(() => resetScreen(tester));
      await gate(
        tester,
        doneToo ? 'expedition_done' : 'expedition',
        () {
          final w = _expeditionWorld(doneToo: doneToo);
          AppState.world = w;
          return _overlay(
            StationPanel(
              world: w,
              station: w.stations.first,
              frame: ValueNotifier(0),
              act: (a) => a(),
              onClose: () {},
              onOpenShop: () {},
            ),
          );
        },
        after: () async {
          await tester.tap(find.text(tr.u_tabCrew));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('expedition-panel')), findsOneWidget);
          final active = find.byWidgetPredicate(
            (wd) => wd.key is ValueKey<String> && (wd.key! as ValueKey<String>).value.startsWith('exp-active-'),
          );
          expect(active, findsNWidgets(doneToo ? 2 : 1));
        },
      );
      AppState.world = null;
    });
  }

  testWidgets('타이틀: 내일 출석 보상 카드 (저장이 있고 오늘 받음)', (tester) async {
    addTearDown(() => resetScreen(tester));
    await gate(
      tester,
      'title',
      () {
        SharedPreferences.setMockInitialValues({'star_settlers_world_v2': '{}'});
        AppState.profile = Profile();
        Attendance.claim(AppState.profile, DateTime.now());
        return const TitleScreen();
      },
      after: () async {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump();
        await tester.pump();
        expect(find.byKey(const ValueKey('tomorrow-card')), findsOneWidget);
      },
    );
  });

  testWidgets('타이틀: 받을 보상이 있으면 달력이 뜬다', (tester) async {
    addTearDown(() => resetScreen(tester));
    SharedPreferences.setMockInitialValues({'star_settlers_world_v2': '{}'});
    AppState.profile = Profile();
    await pumpScreen(tester, const TitleScreen(), size: const Size(390, 844));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('calendar-panel')), findsOneWidget);
    if (_out != null) await savePng(tester, '$_out/title_calendar_ko.png');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('게임 첫 세션: 해적 단계 뒤 ★3 카드 → 닫으면 출석 달력 (한 번에 하나)', (tester) async {
    addTearDown(() => resetScreen(tester));
    final w = GameWorld(seed: 2, profile: AppState.profile)..storyIndex = 1;
    await pumpScreen(tester, GameScreen(world: w), size: const Size(390, 844));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('calendar-panel')), findsNothing, reason: '해적 단계 전에는 안 뜬다');
    w.storyIndex = 2;
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const ValueKey('crew-reveal')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-panel')), findsNothing);
    if (_out != null) await savePng(tester, '$_out/game_reveal_ko.png');
    await tester.tap(
      find.descendant(of: find.byKey(const ValueKey('crew-reveal')), matching: find.byType(ElevatedButton)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('calendar-panel')), findsOneWidget);
    if (_out != null) await savePng(tester, '$_out/game_calendar_ko.png');
    await tester.tap(find.byKey(const ValueKey('calendar-claim')));
    await tester.pump();
    expect(AppState.profile.loginStreak, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('일시정지 메뉴: 내일 출석 보상 카드', (tester) async {
    addTearDown(() => resetScreen(tester));
    await gate(
      tester,
      'pause',
      () => _overlay(
        PauseMenu(
          title: tr.u_paused,
          stats: 'stats',
          resumeLabel: tr.u_resume,
          onResume: () {},
          tiles: [
            for (var i = 0; i < 6; i++) MenuTile(tr.u_shop, 'menu_shop', () {}),
          ],
          quitLabel: tr.u_saveAndQuit,
          onQuit: () {},
          onClose: () {},
          banner: TomorrowCard(profile: _calendarProfile(), now: _now, onTap: () {}),
        ),
      ),
    );
  });

  test('원정 패널 시간 표시', () {
    expect(Expeditions.durations, [1, 4, 8]);
  });
}
