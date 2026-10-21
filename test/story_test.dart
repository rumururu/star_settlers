import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/missions.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/save.dart';
import 'package:star_settlers/main.dart' show TitleScreen;
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart';
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/ui/game_screen.dart';
import 'package:star_settlers/ui/story_panel.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;

GameWorld roundTrip(GameWorld w) => GameWorld.fromJson(
  jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>,
  w.profile,
);

Widget app(Widget child) => MaterialApp(
  locale: Lang.changed.value,
  supportedLocales: L10n.supportedLocales,
  localizationsDelegates: L10n.localizationsDelegates,
  home: child,
);

void main() {
  setUp(() {
    Lang.set(const Locale('ko'));
    SharedPreferences.setMockInitialValues({});
    AppState.profile = Profile()..notifications = false;
    AudioService.instance
      ..soundOn = false
      ..musicOn = false;
  });

  test('새 게임 오프닝은 저장 후 재개되며 완료 뒤에는 다시 나오지 않는다', () {
    final original = GameWorld(seed: 1, showOpening: true);
    final restored = roundTrip(original);
    expect(restored.pendingStoryScene, StoryScene.opening);
    final credits = restored.credits;
    final gems = restored.profile.gems;
    restored.finishStoryScene();
    expect(roundTrip(restored).pendingStoryScene, isNull);
    expect(restored.credits, credits);
    expect(restored.profile.gems, gems);
    expect(restored.storyIndex, 0);
    // 기존 저장에는 새 장면 상태가 없으며 오프닝을 소급 표시하지 않는다.
    expect(roundTrip(GameWorld(seed: 2)).pendingStoryScene, isNull);
  });

  test('첫 정착 장면은 화성이 아닌 행성에서도 한 번만 표시된다', () {
    var w = GameWorld(seed: 2)
      ..credits = 1e8
      ..ore = 1e8;
    expect(w.upgradePlanet(w.planets[1]), isTrue);
    expect(w.pendingStoryScene, StoryScene.mars);
    expect(w.upgradePlanet(w.planets.first), isTrue);
    expect(w.pendingStoryScene, StoryScene.mars);
    w = roundTrip(w);
    expect(w.pendingStoryScene, StoryScene.mars);
    expect(w.colonyTutorialPending, isTrue);
    w.finishStoryScene();
    expect(w.upgradePlanet(w.planets.first), isTrue);
    expect(roundTrip(w).pendingStoryScene, isNull);
  });

  test('첫 안정화 장치는 결제 성공 뒤에만 장면을 예약하고 재건해도 반복하지 않는다', () {
    var w = GameWorld(seed: 12)
      ..credits = 1e8
      ..ore = 1e8;
    final p = w.planets[1];
    expect(w.upgradePlanet(p), isTrue);
    w.finishStoryScene();
    w.credits = 0;
    w.ore = 0;
    expect(w.buildColony(p, ColonyBuilding.stabilizer), isFalse);
    expect(w.pendingStoryScene, isNull);
    w.credits = 1e8;
    w.ore = 1e8;
    expect(w.buildColony(p, ColonyBuilding.stabilizer), isTrue);
    expect(w.pendingStoryScene, StoryScene.firstTransmission);
    w = roundTrip(w);
    expect(w.pendingStoryScene, StoryScene.firstTransmission);
    w.finishStoryScene();
    final restored = roundTrip(w);
    restored.planets[1].buildings[ColonyBuilding.stabilizer] = 0;
    expect(
      restored.buildColony(restored.planets[1], ColonyBuilding.stabilizer),
      isTrue,
    );
    expect(roundTrip(restored).pendingStoryScene, isNull);
  });

  test('기존 저장의 정착과 안정화 장치는 첫 장면을 소급 예약하지 않는다', () {
    final w = GameWorld(seed: 13)
      ..credits = 1e8
      ..ore = 1e8;
    expect(w.upgradePlanet(w.planets[1]), isTrue);
    expect(w.buildColony(w.planets[1], ColonyBuilding.stabilizer), isTrue);
    final legacy = jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>;
    (legacy['counters'] as Map).remove('storyScene_mars');
    (legacy['counters'] as Map).remove('storyScene_firstTransmission');
    final restored = GameWorld.fromJson(legacy, w.profile);
    expect(restored.pendingStoryScene, isNull);
    expect(restored.counter('storyScene_mars'), 2);
    expect(restored.counter('storyScene_firstTransmission'), 2);
    expect(restored.upgradePlanet(restored.planets.first), isTrue);
    expect(
      restored.buildColony(restored.planets.first, ColonyBuilding.stabilizer),
      isTrue,
    );
    expect(roundTrip(restored).pendingStoryScene, isNull);
  });

  test('원격 섹터의 옛 식민지는 첫 송신을 이미 마친 것으로 복원한다', () {
    final w = GameWorld(seed: 14)..credits = 1e8;
    final legacy = jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>;
    final remote = Map<String, dynamic>.from(legacy['current'] as Map);
    remote['colonies'] = [1, 0, 0];
    remote.remove('bld');
    (legacy['sectors'] as Map)['0'] = remote;
    legacy['sector'] = 1;
    (legacy['counters'] as Map).remove('storyScene_firstTransmission');
    final restored = GameWorld.fromJson(legacy, w.profile);
    expect(restored.counter('storyScene_firstTransmission'), 2);
    expect(restored.pendingStoryScene, isNull);
    expect(restored.campaignMissionActive, isTrue);
    restored.finishStoryScene();
    expect(restored.warp(restored.gates.firstWhere((g) => !g.forward)), isTrue);
    expect(restored.planets.first.building(ColonyBuilding.stabilizer), 1);
    expect(restored.pendingStoryScene, isNull);
  });

  test('튜토리얼의 사연과 조작 안내가 순서대로 표시된다', () {
    final w = GameWorld(seed: 6);
    expect(w.dialogs.last.text, tr.g_storyAsteroidsLine0);
    for (var i = 0; i < 162; i++) {
      w.update(0.05, InputState());
    }
    expect(w.dialogs.last.text, tr.g_storyAsteroidsLine1);
  });

  test('순항 안내는 길어진 정착 대사 뒤에도 사라지지 않는다', () {
    final w = GameWorld(seed: 8)..storyIndex = GameWorld.cruiseTipStep - 1;
    w.counters['shipKills'] = 3;
    for (var i = 0; i < 12; i++) {
      w.update(0.05, InputState());
    }
    expect(w.storyIndex, GameWorld.cruiseTipStep);
    for (var i = 0; i < 322; i++) {
      w.update(0.05, InputState());
    }
    expect(w.dialogs.last.text, tr.g_dlgCruiseOn);
  });

  test('첫 게이트 장면은 발전 완료에서 한 번만 발생하고 실제 워프는 별도로 한다', () {
    var w = GameWorld(seed: 3)
      ..credits = 1e8
      ..ore = 1e8;
    for (final p in w.planets) {
      while (p.colonyLevel < 3) {
        expect(w.upgradePlanet(p), isTrue);
      }
      while (p.building(ColonyBuilding.stabilizer) < 3) {
        expect(w.buildColony(p, ColonyBuilding.stabilizer), isTrue);
      }
    }
    w = roundTrip(w);
    expect(w.pendingStoryScene, StoryScene.mars);
    expect(w.counter('storyScene_firstWarp'), 1);
    for (var i = 0; i < 12; i++) {
      w.update(0.05, InputState());
    }
    // 장면이 같은 시기에 발생해도 앞 장면을 덮어쓰지 않는다.
    expect(w.pendingStoryScene, StoryScene.mars);
    w.finishStoryScene();
    expect(w.pendingStoryScene, StoryScene.firstTransmission);
    w.finishStoryScene();
    expect(w.pendingStoryScene, StoryScene.firstWarp);
    w = roundTrip(w);
    expect(w.pendingStoryScene, StoryScene.firstWarp);
    w.finishStoryScene();
    expect(w.sector, 0);
    expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
    expect(w.sector, 1);
    expect(w.pendingStoryScene, isNull);
    expect(w.campaignMissionActive, isTrue);
    w.finishStoryScene();
    expect(w.warp(w.gates.firstWhere((g) => !g.forward)), isTrue);
    for (var i = 0; i < 12; i++) {
      w.update(0.05, InputState());
    }
    expect(roundTrip(w).pendingStoryScene, isNull);
  });

  testWidgets('오프닝 동안 시간과 전투 키 입력이 멈추고 건너뛰면 튜토리얼로 이어진다', (tester) async {
    final w = GameWorld(seed: 4, profile: AppState.profile, showOpening: true);
    await tester.pumpWidget(app(GameScreen(world: w)));
    final time = w.totalTime;
    await tester.pump(const Duration(seconds: 10));
    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    expect(w.totalTime, time);
    expect(w.boostTime, 0);
    expect(w.storyIndex, 0);
    expect(find.byType(StoryPanel), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('story-skip')));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(StoryPanel), findsNothing);
    expect(w.totalTime, greaterThan(time));
    expect(w.storyIndex, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('화성 이야기가 끝나야 첫 시설 안내가 열린다', (tester) async {
    final w = GameWorld(seed: 5, profile: AppState.profile)
      ..credits = 1e8
      ..ore = 1e8;
    w.player.pos = w.planets.first.pos;
    w.upgradePlanet(w.planets.first);
    await tester.pumpWidget(app(GameScreen(world: w)));
    await tester.pump(const Duration(milliseconds: 50));
    expect(w.colonyTutorialPending, isTrue);
    expect(find.byType(StoryPanel), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('story-skip')));
    await tester.pump(const Duration(milliseconds: 50));
    expect(w.colonyTutorialPending, isFalse);
    expect(find.byType(StoryPanel), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('첫 실행 타이틀에는 출석 보상 팝업이 없다', (tester) async {
    await tester.pumpWidget(app(const TitleScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(tr.m_loginTitle), findsNothing);
    expect(AppState.profile.lastLoginDay, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('플레이 저장이 있는 다음 접속에는 출석 보상을 표시한다', (tester) async {
    await SaveService.save(GameWorld(seed: 3, profile: AppState.profile));
    await tester.pumpWidget(app(const TitleScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(tr.m_loginTitle), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('오프닝은 가로 방향을 요청하고 종료하면 사용자 설정을 복원한다', (tester) async {
    final requests = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemChrome.setPreferredOrientations') {
          requests.add(call.arguments);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    AppState.profile.orientation = ScreenOrient.portrait;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(StoryPanel(scene: StoryScene.opening, onDone: () {})),
    );
    expect(requests.last, [
      'DeviceOrientation.landscapeLeft',
      'DeviceOrientation.landscapeRight',
    ]);
    expect(find.byType(RotatedBox), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(requests.last, [
      'DeviceOrientation.portraitUp',
      'DeviceOrientation.portraitDown',
    ]);
  });

  testWidgets('오프닝 컷은 자동 진행하되 마지막 조종권은 직접 넘긴다', (tester) async {
    var finished = 0;
    await tester.pumpWidget(
      app(StoryPanel(scene: StoryScene.opening, onDone: () => finished++)),
    );
    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(find.text(keepAll(tr.n_open1)), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(find.text(keepAll(tr.n_open2)), findsOneWidget);
    expect(find.text(tr.u_spkCaptain), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(find.text(keepAll(tr.n_open3)), findsOneWidget);
    expect(find.text(tr.n_enemyCommander), findsOneWidget);
    await tester.pump(const Duration(seconds: 15));
    expect(finished, 0);
    await tester.tap(find.byKey(const ValueKey('story-next')));
    expect(finished, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('동작 줄이기에서는 컷을 자동으로 넘기지 않는다', (tester) async {
    await tester.pumpWidget(
      app(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(800, 600),
            disableAnimations: true,
          ),
          child: StoryPanel(scene: StoryScene.opening, onDone: () {}),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 30));
    expect(find.text(keepAll(tr.n_open0)), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('story-next')));
    await tester.pump();
    expect(find.text(keepAll(tr.n_open1)), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final locale in L10n.supportedLocales) {
    for (final size in [const Size(390, 844), const Size(800, 360)]) {
      testWidgets('이야기 전 페이지: ${locale.languageCode} / $size / 글자 1.3배', (
        tester,
      ) async {
        Lang.set(locale);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);
        for (final scene in StoryScene.values) {
          var finished = 0;
          await tester.pumpWidget(
            app(
              MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: StoryPanel(
                  key: ValueKey(scene),
                  scene: scene,
                  onDone: () => finished++,
                ),
              ),
            ),
          );
          final count = switch (scene) {
            StoryScene.opening => 4,
            StoryScene.mars => 3,
            StoryScene.campaign ||
            StoryScene.ending ||
            StoryScene.counterattack => 1,
            _ => 2,
          };
          for (var i = 0; i < count; i++) {
            expect(tester.takeException(), isNull);
            final next = find.byKey(const ValueKey('story-next'));
            expect(next.hitTestable(), findsOneWidget);
            await tester.tap(next);
            await tester.pump();
          }
          expect(finished, 1);
        }
      });
    }
  }
}
