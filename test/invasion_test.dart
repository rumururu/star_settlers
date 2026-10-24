import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart';
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;
import 'package:star_settlers/ui/game_screen.dart';
import 'package:star_settlers/ui/tokens.dart';

/// 해적·이벤트·임무가 저절로 생기지 않는 세계. 앞 [colonies]개 행성이 식민지다.
/// 선장은 맞아도 죽지 않는다 ([step]이 매 프레임 체력을 채운다).
GameWorld calm({int colonies = 3, int seed = 7}) {
  final w = GameWorld(seed: seed)
    ..spawnTimer = 1e9
    ..eventTimer = 1e9
    ..jellyTimer = 1e9
    ..offerTimer = 1e9;
  for (var i = 0; i < colonies; i++) {
    w.planets[i].colonyLevel = 1;
  }
  w.pirates.clear();
  return w;
}

void step(GameWorld w, double seconds, {double dt = 1 / 20}) {
  for (var t = 0.0; t < seconds - 1e-9; t += dt) {
    if (w.player.alive) {
      w.player
        ..hp = 1e6
        ..invulnerable = 1;
    }
    w.update(dt, InputState());
  }
}

/// [inv]의 다음 파도가 나올 때까지 돌린다
void untilWave(GameWorld w, Invasion inv, int wave) {
  for (var i = 0; i < 4000 && inv.wave < wave; i++) {
    step(w, 1 / 20);
  }
  expect(inv.wave, wave);
}

Iterable<Pirate> invaders(GameWorld w) =>
    w.pirates.where((e) => e.eventId != null && e.eventId == w.invasion?.id);

/// 일반 스폰으로 나온 해적 (침공·습격·현상수배·두목 제외)
int normalPirates(GameWorld w) => w.pirates
    .where(
      (e) =>
          e.isPirate &&
          e.eventId == null &&
          e.name == null &&
          e.kind != PirateKind.boss,
    )
    .length;

void main() {
  setUp(() => Lang.set(const Locale('ko')));

  group('주기와 해금', () {
    test('식민지 2개면 침공이 오지 않는다', () {
      final w = calm(colonies: 2);
      step(w, 420);
      expect(w.invasion, isNull);
    });

    test('식민지 3개: 300초 뒤 경보, 20초 뒤 1파, 25초 간격으로 3파, 3파에 지휘함 1기', () {
      final w = calm();
      expect(w.invasionTimer, GameWorld.invasionFirstDelay);
      step(w, 299);
      expect(w.invasion, isNull);
      step(w, 1.5);
      final inv = w.invasion!;
      expect(inv.phase, InvasionPhase.warning);
      expect(inv.timer, closeTo(GameWorld.invasionWarning - 0.5, 0.11));
      expect(
        w.dialogs.map((d) => d.text),
        contains(tr.g_dlgInvasionWarning(20)),
      );
      // 방향 표시 지점은 본거지에서 1600~2000 (맵 안으로 잘릴 수는 있다)
      expect((inv.from - w.homeBase.pos).distance, lessThanOrEqualTo(2000.01));
      expect(invaders(w), isEmpty);

      // 파도가 나오는 순간을 한 틱씩 재서 간격을 본다
      final warnedAt =
          w.sectorElapsed - (GameWorld.invasionWarning - inv.timer);
      double waveAt(int wave) {
        for (var i = 0; i < 2000 && inv.wave < wave; i++) {
          step(w, 1 / 20);
        }
        expect(inv.wave, wave);
        return w.sectorElapsed;
      }

      final t1 = waveAt(1);
      expect(t1 - warnedAt, closeTo(GameWorld.invasionWarning, 0.06));
      expect(inv.phase, InvasionPhase.waves);
      final size1 = GameWorld.invasionWaveSize(w.threat, w.sector);
      expect(inv.spawned, size1);
      expect(invaders(w).length, size1);
      expect(invaders(w).where((e) => e.invasionCommander), isEmpty);
      // 침공 방향의 가장자리 부근 (본거지에서 1600~2000, 맵 밖은 안으로 잘린다)
      final dir = (inv.from - w.homeBase.pos).direction;
      for (final e in invaders(w)) {
        final rel = e.pos - w.homeBase.pos;
        expect(rel.distance, lessThanOrEqualTo(2000.0 + 300));
        final da = (rel.direction - dir + 3 * pi) % (2 * pi) - pi;
        expect(da.abs(), lessThan(0.5));
      }

      final t2 = waveAt(2);
      expect(t2 - t1, closeTo(GameWorld.invasionWaveGap, 0.06));
      final size2 = inv.spawned - size1;
      expect(size2, GameWorld.invasionWaveSize(w.threat, w.sector));

      final t3 = waveAt(3);
      expect(t3 - t2, closeTo(GameWorld.invasionWaveGap, 0.06));
      final size3 = inv.spawned - size1 - size2;
      expect(size3, GameWorld.invasionWaveSize(w.threat, w.sector) + 1);
      final commanders = w.pirates.where((e) => e.invasionCommander).toList();
      expect(commanders, hasLength(1));
      final c = commanders.single;
      expect(c.kind, PirateKind.raider);
      expect(c.eventId, inv.id);
      expect(c.archetype, isNull);
      expect(c.name, '침공 지휘함');
      expect(c.radius, closeTo(24 * 1.4, 1e-9));
      expect(c.dmgScale, closeTo(w.enemyDamageMul * 1.5, 1e-9));
      final scale = (1 + (w.threat - 1 - w.sector) * 0.15) * w.enemyHpMul;
      expect(c.maxHp, closeTo(Pirate.baseHp(PirateKind.raider) * scale * 6, 1));
      // 판정까지 90초
      expect(inv.timer, closeTo(GameWorld.invasionJudge, 0.06));
    });

    test('3파 뒤에는 더 나오지 않는다', () {
      final w = calm();
      final inv = w.startInvasion();
      untilWave(w, inv, 3);
      final spawned = inv.spawned;
      step(w, 60);
      expect(inv.spawned, spawned);
    });
  });

  group('파도 크기', () {
    test('min(18, round(6 + 위협도×1.5)), 태양계 ×0.6, 최소 4', () {
      expect(GameWorld.invasionWaveSize(2, 1), 9);
      expect(GameWorld.invasionWaveSize(5.3, 3), 14); // 13.95 → 14
      expect(GameWorld.invasionWaveSize(8, 4), 18);
      expect(GameWorld.invasionWaveSize(30, 9), 18);
      expect(GameWorld.invasionWaveSize(4, 0), 7); // 12 × 0.6 = 7.2
      expect(GameWorld.invasionWaveSize(30, 0), 11); // 18 × 0.6 = 10.8
      expect(GameWorld.invasionWaveSize(0, 0), 4); // 6 × 0.6 = 3.6 → 최소 4
      expect(GameWorld.invasionWaveSize(0, 2), 6);
    });

    test('태양계가 아니면 0.6을 곱하지 않는다 (실제 파도)', () {
      final w = calm()..sector = 3;
      final inv = w.startInvasion();
      untilWave(w, inv, 1);
      expect(inv.spawned, GameWorld.invasionWaveSize(w.threat, 3));
      expect(inv.spawned, greaterThanOrEqualTo(10));
    });
  });

  group('일반 스폰·습격 중지', () {
    test('경보·진행 중엔 일반 해적이 나오지 않고, 끝나면 다시 나온다', () {
      final w = calm();
      final inv = w.startInvasion();
      w.spawnTimer = 0;
      step(w, 10);
      expect(inv.phase, InvasionPhase.warning);
      expect(normalPirates(w), 0);
      untilWave(w, inv, 2);
      w.spawnTimer = 0;
      step(w, 5);
      expect(normalPirates(w), 0);
      // 전멸 → 결과 표시 중엔 다시 스폰
      untilWave(w, inv, 3);
      w.pirates.removeWhere((e) => e.eventId == inv.id);
      step(w, 0.1);
      expect(inv.phase, InvasionPhase.done);
      w.spawnTimer = 0;
      step(w, 0.1);
      expect(normalPirates(w), greaterThan(0));
    });

    test('침공 중엔 습격 이벤트를 새로 시작하지 않는다', () {
      int raids(GameWorld w, {required bool invading}) {
        var n = 0;
        for (var i = 0; i < 150; i++) {
          if (invading && !w.invasionActive) w.startInvasion();
          w.events.clear();
          w.eventTimer = 0;
          step(w, 1 / 20);
          if (w.events.any((e) => e.kind == EventKind.raid)) n++;
          w.pirates.removeWhere((e) => e.eventId != null);
          w.invasion = null;
        }
        return n;
      }

      expect(raids(calm(), invading: false), greaterThan(20));
      expect(raids(calm(), invading: true), 0);
    });
  });

  group('판정', () {
    test('마지막 파도 뒤 전멸 → 승리: 크레딧 600×보상 배율 + 젬 5, 통계', () {
      final w = calm();
      final inv = w.startInvasion();
      untilWave(w, inv, 3);
      final credits = w.credits;
      final gems = w.profile.gems;
      final stat = w.profile.stat('invasions');
      final full = (600 * w.rewardMul * w.shipCreditMul).round();
      w.pirates.removeWhere((e) => e.eventId == inv.id);
      step(w, 1 / 20);
      expect(inv.phase, InvasionPhase.done);
      expect(inv.won, isTrue);
      expect(inv.reward, full);
      expect(w.credits - credits, closeTo(full, w.creditIncome / 20 + 1));
      expect(w.profile.gems - gems, 5);
      expect(w.profile.stat('invasions'), stat + 1);
      expect(w.dialogs.map((d) => d.text), contains(tr.g_dlgInvasionWon(full)));
      // 결과 한 줄은 잠깐 보여 주고 사라진다
      step(w, GameWorld.invasionResultTime + 0.2);
      expect(w.invasion, isNull);
    });

    test('파도가 다 나오기 전에 다 잡아도 판정은 마지막 파도 뒤', () {
      final w = calm();
      final inv = w.startInvasion();
      untilWave(w, inv, 1);
      w.pirates.removeWhere((e) => e.eventId == inv.id);
      step(w, 2);
      expect(inv.phase, InvasionPhase.waves);
      expect(inv.won, isFalse);
    });

    test('90초 초과 → 퇴각: 남은 적 제거, 처치 비율만큼 크레딧, 젬 없음, 식민지 레벨 그대로', () {
      final w = calm();
      for (final p in w.planets.where((p) => p.colonyLevel > 0)) {
        p.colonyLevel = 3;
      }
      final levels = [for (final p in w.planets) p.colonyLevel];
      final inv = w.startInvasion();
      untilWave(w, inv, 3);
      expect(inv.timer, closeTo(90, 0.1));
      // 침공 적 일부를 잡은 상태 (본거지 레이저가 잡은 것 포함)
      final all = invaders(w).toList();
      for (final e in all.take(all.length ~/ 2)) {
        w.pirates.remove(e);
      }
      final left = invaders(w).length;
      expect(left, greaterThan(0));
      final full = (600 * w.rewardMul * w.shipCreditMul).round();
      final gems = w.profile.gems;
      final stat = w.profile.stat('invasions');
      final credits = w.credits;
      inv.timer = 0.01;
      step(w, 1 / 20);
      expect(inv.phase, InvasionPhase.done);
      expect(inv.won, isFalse);
      expect(invaders(w), isEmpty);
      expect(w.pirates.where((e) => e.eventId == inv.id), isEmpty);
      final ratio = (inv.spawned - left) / inv.spawned;
      expect(inv.killRatio, closeTo(ratio, 1e-9));
      expect(inv.reward, (full * ratio).round());
      expect(w.credits - credits, closeTo(inv.reward, w.creditIncome / 20 + 1));
      expect(w.profile.gems, gems);
      expect(w.profile.stat('invasions'), stat);
      expect([for (final p in w.planets) p.colonyLevel], levels);
    });

    test('판정 시간은 실제로 90초 (그 전엔 퇴각하지 않는다)', () {
      final w = calm();
      // 본거지가 멈춰 있어 레이저로 다 잡지 못한다. 선장은 멀리서 쏘지 않는다
      w.homeBase.disabledTime = 1e9;
      w.player.pos = const Offset(-3500, -3500);
      final inv = w.startInvasion();
      untilWave(w, inv, 3);
      step(w, 89);
      if (inv.phase == InvasionPhase.waves) {
        step(w, 1.2);
      }
      expect(inv.phase, InvasionPhase.done);
    });
  });

  group('취소·연기·간격', () {
    test('항성계를 옮기면 진행 중 침공은 보상 없이 취소, 타이머는 새로 시작', () {
      final w = calm()
        ..credits = 1e12
        ..ore = 1e12
        ..counters['maxSector'] = 99;
      final inv = w.startInvasion();
      untilWave(w, inv, 1);
      final gems = w.profile.gems;
      expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
      expect(w.invasion, isNull);
      expect(w.pirates.where((e) => e.eventId == inv.id), isEmpty);
      expect(w.invasionTimer, GameWorld.invasionFirstDelay);
      expect(w.profile.gems, gems);
      expect(w.profile.stat('invasions'), 0);
    });

    test('선장이 격추돼 있으면 시작을 미루고, 살아나면 시작한다', () {
      final w = calm();
      w.invasionTimer = 0.01;
      w.player.alive = false;
      for (var i = 0; i < 100; i++) {
        w.player.deadTime = 0; // 자동 재출격 막기
        w.update(1 / 20, InputState());
      }
      expect(w.invasion, isNull);
      w.player.alive = true;
      w.update(1 / 20, InputState());
      expect(w.invasion?.phase, InvasionPhase.warning);
    });

    test('다음 침공은 끝난 시점부터 360~480초 뒤', () {
      final gaps = <double>[];
      for (final seed in [1, 2, 3, 4, 5, 6]) {
        final w = calm(seed: seed);
        final inv = w.startInvasion();
        untilWave(w, inv, 3);
        w.pirates.removeWhere((e) => e.eventId == inv.id);
        step(w, 1 / 20);
        expect(inv.phase, InvasionPhase.done);
        gaps.add(w.invasionTimer);
        expect(w.invasionTimer, inInclusiveRange(360, 480));
        // 결과 표시가 끝나도 다음 침공은 타이머가 끝나야 온다
        step(w, 300);
        expect(w.invasion, isNull);
        expect(w.invasionTimer, closeTo(gaps.last - 300, 0.2));
      }
      expect(gaps.toSet(), hasLength(greaterThan(1)));
    });

    test('불러오면 진행 중 침공은 사라지고 타이머는 새로 시작', () {
      final w = calm();
      w.startInvasion();
      final back = GameWorld.fromJson(w.toJson(), w.profile);
      expect(back.invasion, isNull);
      expect(back.invasionTimer, GameWorld.invasionFirstDelay);
    });
  });

  group('HUD 배너', () {
    setUpAll(() async {
      final font = FontLoader(Ts.family)
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File('assets/fonts/Jua-Regular.ttf').readAsBytesSync(),
            ),
          ),
        );
      await font.load();
    });

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      AppState.profile = Profile();
      AudioService.instance
        ..soundOn = false
        ..musicOn = false;
    });

    Widget app(Widget home) => MaterialApp(
      locale: Lang.changed.value,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: Ts.family,
        useMaterial3: true,
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(1.3)),
        child: child!,
      ),
      home: home,
    );

    /// 미션 카드·대사가 다 떠 있는 붐비는 세계에 침공 [phase]를 건다
    GameWorld scene(InvasionPhase phase, {bool won = true}) {
      final w = GameWorld(seed: 1, profile: AppState.profile)
        ..spawnTimer = 1e9
        ..eventTimer = 1e9;
      for (var i = 0; i < 3; i++) {
        w.planets[i].colonyLevel = 1;
      }
      w.player.pos = w.stations.first.pos;
      w.events.add(WorldEvent(91, EventKind.meteor, w.planets[2].pos, 30));
      final inv = w.startInvasion();
      if (phase != InvasionPhase.warning) {
        step(w, 20.1);
      }
      if (phase == InvasionPhase.done) {
        if (won) {
          w.pirates.removeWhere((e) => e.eventId == inv.id);
          inv.timer = 0;
          inv.wave = 3;
        } else {
          inv.wave = 3;
          inv.timer = 0.01;
        }
        step(w, 1 / 20);
      }
      w.say(
        Speaker.advisor,
        '정거장에 오면 함선을 강화하고 승무원을 고용할 수 있어요. 해적이 몰려오기 전에 준비해요!',
      );
      return w;
    }

    String expected(GameWorld w) {
      final inv = w.invasion!;
      return switch (inv.phase) {
        InvasionPhase.warning => tr.u_invasionCountdown(inv.timer.ceil()),
        InvasionPhase.waves => tr.u_invasionWave(
          inv.wave,
          3,
          w.invasionEnemiesLeft,
        ),
        InvasionPhase.done =>
          inv.won
              ? tr.u_invasionWon(inv.reward)
              : tr.u_invasionRetreat((inv.killRatio * 100).round(), inv.reward),
      };
    }

    const sizes = [Size(360, 740), Size(800, 360)];
    const cases = [
      ('warning', InvasionPhase.warning, true),
      ('waves', InvasionPhase.waves, true),
      ('won', InvasionPhase.done, true),
      ('retreat', InvasionPhase.done, false),
    ];

    for (final locale in L10n.supportedLocales) {
      testWidgets('배너 ${locale.languageCode}: 경보·진행·결과, 넘침·겹침 없음', (
        tester,
      ) async {
        Lang.set(locale);
        addTearDown(() => Lang.set(const Locale('ko')));
        addTearDown(tester.view.reset);
        tester.view.devicePixelRatio = 1;
        final problems = <String>[];
        Future<List<String>> pumpHud(GameWorld w) async {
          final errors = <FlutterErrorDetails>[];
          final old = FlutterError.onError;
          FlutterError.onError = errors.add;
          try {
            await tester.pumpWidget(app(GameScreen(world: w)));
            await tester.pump(const Duration(milliseconds: 50));
            await tester.pump(const Duration(milliseconds: 50));
            // 틱 없이 한 번 더 그려서 문구가 지금 상태와 같게
            await tester.pump();
          } finally {
            FlutterError.onError = old;
          }
          return [
            for (final e in errors) e.exceptionAsString().split('\n').first,
          ];
        }

        for (final size in sizes) {
          tester.view.physicalSize = size;
          // 같은 장면에 침공만 없는 화면도 넘침이 없어야 한다 (기지 행동 버튼 등)
          final calmScene = scene(InvasionPhase.warning)..invasion = null;
          final baseline = await pumpHud(calmScene);
          await tester.pumpWidget(const SizedBox());
          for (final e in baseline) {
            problems.add('${locale.languageCode} calm $size: $e');
          }
          for (final (name, phase, won) in cases) {
            final w = scene(phase, won: won);
            final errors = await pumpHud(w);
            final where = '${locale.languageCode} $name $size';
            for (final e in errors.toSet().difference(baseline.toSet())) {
              problems.add('$where: $e');
            }
            final banner = find.byKey(const ValueKey('hud-invasion'));
            expect(banner, findsOneWidget, reason: where);
            expect(
              find.descendant(
                of: banner,
                matching: find.text(keepAll(expected(w))),
              ),
              findsOneWidget,
              reason: where,
            );
            final r = tester.getRect(banner);
            final screen = Offset.zero & size;
            if (r.left < -0.5 ||
                r.top < -0.5 ||
                r.right > screen.right + 0.5 ||
                r.bottom > screen.bottom + 0.5) {
              problems.add('$where: banner $r outside screen');
            }
            for (final k in [
              'hud-captain',
              'hud-minimap',
              'hud-joystick',
              'hud-cruise',
              'hud-combat',
              'hud-autofire',
              'hud-actions',
              'hud-dialog',
            ]) {
              final f = find.byKey(ValueKey(k));
              if (f.evaluate().isEmpty) continue;
              final o = r.intersect(tester.getRect(f));
              if (o.width > 1 && o.height > 1) {
                problems.add('$where: banner $r × $k ${tester.getRect(f)}');
              }
            }
            await tester.pumpWidget(const SizedBox());
          }
        }
        expect(problems, isEmpty);
      });
    }
  });
}
