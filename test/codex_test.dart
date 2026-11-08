// TASK 006 도감: 기록·퍼센트·마일스톤·저장 단위 테스트 + 4탭 렌더 게이트(ko/en/de, 세로·가로, 글자 1.3).
// 증거 PNG: CODEX_SNAP_DIR=<폴더> flutter test --no-pub test/codex_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/codex.dart';
import 'package:star_settlers/game/codex_world.dart';
import 'package:star_settlers/game/cosmetics.dart';
import 'package:star_settlers/game/crew.dart';
import 'package:star_settlers/game/game_telemetry.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/system_traits.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart' show Lang;
import 'package:star_settlers/main.dart' show TitleScreen;
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/audio.dart';
import 'package:star_settlers/ui/codex_screen.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;

import 'support/snap.dart';

final _snapDir = Platform.environment['CODEX_SNAP_DIR'];

Pirate _pirate(PirateKind k, {BossArchetype? arch, bool commander = false}) =>
    Pirate(k, Offset.zero, 1)
      ..archetype = arch
      ..invasionCommander = commander;

/// 발견·미발견이 섞인 도감 (증거 그림용)
Profile _mixedProfile() {
  final p = Profile();
  final c = p.codex;
  for (final k in [
    PirateKind.scout,
    PirateKind.raider,
    PirateKind.raider,
    PirateKind.sniper,
    PirateKind.jelly,
    PirateKind.missile,
    PirateKind.laser,
  ]) {
    c.recordKill(_pirate(k));
  }
  c.recordKill(_pirate(PirateKind.boss, arch: BossArchetype.plunder));
  c.recordKill(_pirate(PirateKind.raider, commander: true));
  c.recordColony(0, 0, 8, PlanetKind.desert, 5);
  c.recordColony(0, 2, 8, PlanetKind.lava, 3);
  c.recordColony(1, 1, 3, PlanetKind.garden, 2);
  c.recordColony(3, 0, 2, PlanetKind.desert, 1);
  for (final s in [0, 1, 2, 3, 4]) {
    c.recordSystem(s);
  }
  for (final (r, s) in [
    (CrewRole.gunner, 1),
    (CrewRole.gunner, 2),
    (CrewRole.engineer, 1),
    (CrewRole.pilot, 3),
    (CrewRole.scientist, 1),
    (CrewRole.trader, 2),
  ]) {
    c.recordCrew(r, s);
  }
  // 적 탭 25% 받음 → 50%는 아직, 행성 탭은 50%까지 받을 수 있음
  c.claim(CodexTab.enemies, 25, p);
  c.toasts.clear();
  return p;
}

void main() {
  setUp(() {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    AppState.profile = Profile();
    AppState.world = null;
    AudioService.instance
      ..soundOn = false
      ..musicOn = false;
    Lang.set(const Locale('ko'));
  });

  group('기록', () {
    test('같은 적을 여러 번 잡아도 항목은 하나, 처치 수는 늘고 토스트는 처음 한 번', () {
      final c = Profile().codex;
      expect(c.recordKill(_pirate(PirateKind.sniper)), isTrue);
      expect(c.recordKill(_pirate(PirateKind.sniper)), isFalse);
      expect(c.kills['sniper'], 2);
      expect(c.foundCount(CodexTab.enemies), 1);
      expect(c.toasts, [(tab: CodexTab.enemies, id: 'sniper')]);
      expect(c.fresh, {'enemies:sniper'});
    });

    test('두목 원형·지휘함·일반 두목은 따로 센다', () {
      final c = Profile().codex;
      c.recordKill(_pirate(PirateKind.boss));
      c.recordKill(_pirate(PirateKind.boss, arch: BossArchetype.fleet));
      c.recordKill(_pirate(PirateKind.raider, commander: true));
      expect(
        c.kills.keys,
        unorderedEquals(['boss', 'arch_fleet', 'commander']),
      );
      expect(c.found(CodexTab.enemies, 'raider'), isFalse);
    });

    test('항목 id 목록이 실제 적 종류·원형을 모두 덮는다', () {
      for (final k in PirateKind.values) {
        expect(codexEnemyIds, contains(k.name));
      }
      for (final a in BossArchetype.values) {
        expect(codexEnemyIds, contains('arch_${a.name}'));
      }
      expect(Codex.ids(CodexTab.crew).length, 18);
      expect(Codex.ids(CodexTab.systems).first, '0');
    });

    test('정착: 종류는 한 번, 행성별 최고 레벨만 남는다', () {
      final c = Profile().codex;
      expect(c.recordColony(2, 1, 4, PlanetKind.ice, 1), isTrue);
      expect(c.recordColony(2, 1, 4, PlanetKind.ice, 3), isFalse);
      c.recordColony(2, 1, 4, PlanetKind.ice, 2);
      expect(c.colonies['2:1:4'], 3);
      expect(c.planetKinds, {'ice'});
      expect(
        c.recordColony(2, 2, 4, PlanetKind.gas, 0),
        isFalse,
        reason: '레벨 0은 정착이 아니다',
      );
    });

    test('★4 전설은 승무원 칸에 넣지 않는다, 같은 조합은 한 번', () {
      final c = Profile().codex;
      expect(c.recordCrew(CrewRole.miner, 4), isFalse);
      expect(c.recordCrew(CrewRole.miner, 2), isTrue);
      expect(c.recordCrew(CrewRole.miner, 2), isFalse);
      expect(c.crew, {'miner:2'});
    });
  });

  group('퍼센트·마일스톤', () {
    test('퍼센트는 내림, 마일스톤은 도달해야 하고 한 번만 받는다', () {
      final p = Profile();
      final c = p.codex;
      // 적 21종 중 6종 = 28%
      for (final id in codexEnemyIds.take(6)) {
        c.kills[id] = 1;
      }
      expect(c.percent(CodexTab.enemies), 28);
      expect(c.canClaim(CodexTab.enemies, 25), isTrue);
      expect(c.claim(CodexTab.enemies, 50, p), isNull);
      final r = c.claim(CodexTab.enemies, 25, p);
      expect(r?.credits, 2000);
      expect(c.claim(CodexTab.enemies, 25, p), isNull);
      expect(c.pendingCredits, 2000);
      expect(c.claimable, 0);
    });

    test('100%: ★3 승무원과 도감 의상, 젬은 주지 않는다', () {
      final p = Profile();
      final c = p.codex;
      for (final k in PlanetKind.values) {
        c.recordColony(0, k.index, 5, k, 1);
      }
      expect(c.percent(CodexTab.planets), 100);
      for (final m in codexMilestones) {
        expect(c.claim(CodexTab.planets, m, p), isNotNull);
      }
      expect(p.gems, 0);
      expect(p.ownedOutfits, contains(codexOutfitId));
      expect(outfitById(codexOutfitId).id, codexOutfitId);
      expect(c.pendingCrew, [2, 3]);
      expect(
        captainOutfits.where((o) => o.id == codexOutfitId),
        isEmpty,
        reason: '상점에서 0젬으로 팔리면 안 된다',
      );
    });

    test('보상은 월드에 들어가고, 정원이 차면 승무원은 기다린다', () {
      final p = Profile();
      final w = GameWorld(seed: 3, profile: p);
      final c0 = w.credits, o0 = w.ore;
      p.codex
        ..pendingCredits = 2000
        ..pendingOre = 500
        ..pendingCrew.addAll([2, 3]);
      while (w.roster.length < w.rosterCap - 1) {
        w.grantCrew(1);
      }
      deliverCodexRewards(w);
      expect(w.credits, c0 + 2000);
      expect(w.ore, o0 + 500);
      expect(w.roster.length, w.rosterCap);
      expect(p.codex.pendingCrew, [3]);
      expect(p.codex.pendingCredits, 0);
    });
  });

  group('저장', () {
    test('저장/복원 왕복', () {
      final p = _mixedProfile();
      final back = Profile.fromJson(
        jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>,
      );
      final a = p.codex, b = back.codex;
      expect(b.kills, a.kills);
      expect(b.planetKinds, a.planetKinds);
      expect(b.colonies, a.colonies);
      expect(b.systems, a.systems);
      expect(b.crew, a.crew);
      expect(b.claimed, a.claimed);
      expect(b.fresh, a.fresh);
      expect(b.pendingCredits, a.pendingCredits);
      expect(b.toasts, isEmpty, reason: '토스트는 저장하지 않는다');
    });

    test('도감 이전 저장은 빈 도감으로 열린다', () {
      final old = Profile().toJson()..remove('codex');
      final p = Profile.fromJson(
        jsonDecode(jsonEncode(old)) as Map<String, dynamic>,
      );
      for (final t in CodexTab.values) {
        expect(p.codex.foundCount(t), 0);
      }
      expect(p.codex.badge, 0);
    });

    test('기록하면 프로필 저장 표시가 켜진다', () {
      final p = Profile()..dirty = false;
      p.codex.recordSystem(3);
      expect(p.dirty, isTrue);
    });
  });

  group('게임 훅', () {
    test('처치·정착·승무원·워프가 도감에 들어가고, 환생(새 월드) 뒤에도 남는다', () {
      final p = Profile();
      final w = GameWorld(seed: 151, profile: p)
        ..credits = 1e12
        ..ore = 1e12
        ..spawnTimer = 1e9
        ..eventTimer = 1e9;
      w.player.invulnerable = 1e9;
      w.pirates
        ..clear()
        ..add(
          Pirate(PirateKind.bomber, w.player.pos + const Offset(2000, 0), 1)
            ..hp = -1,
        );
      w.update(1 / 60, InputState());
      expect(p.codex.kills['bomber'], 1);

      expect(w.upgradePlanet(w.planets.first), isTrue);
      expect(p.codex.planetKinds, contains(w.planets.first.kind.name));
      expect(p.codex.colonies.keys.single, '0:0:${w.planets.length}');

      w.grantCrew(3);
      expect(p.codex.crew, contains(crewCodexId(w.roster.last.role, 3)));

      w.counters['maxSector'] = 1;
      expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
      expect(p.codex.systems, contains(1));

      // 은하 명예: 같은 프로필로 새 월드
      final again = GameWorld(seed: 9, profile: p);
      syncCodexFromWorld(again);
      expect(p.codex.kills['bomber'], 1);
      expect(p.codex.systems, containsAll([0, 1]));
    });

    test('도감 이전부터 하던 월드는 조용히(토스트 없이) 채운다', () {
      final p = Profile();
      final w = GameWorld(seed: 151, profile: p)
        ..credits = 1e12
        ..ore = 1e12;
      expect(w.upgradePlanet(w.planets[1]), isTrue);
      w.grantCrew(2);
      w.counters['maxSector'] = 3;
      final fresh = Profile()..stats.addAll(p.stats);
      final w2 = GameWorld(seed: 151, profile: fresh)
        ..planets[1].colonyLevel = 2
        ..roster.addAll(w.roster)
        ..counters['maxSector'] = 3;
      syncCodexFromWorld(w2);
      expect(fresh.codex.systems, {0, 1, 2, 3});
      expect(fresh.codex.planetKinds, contains(w2.planets[1].kind.name));
      expect(fresh.codex.crew, isNotEmpty);
      expect(fresh.codex.toasts, isEmpty);
      expect(fresh.codex.fresh, isEmpty);
    });
  });

  group('화면', () {
    setUpAll(loadAppFont);
    tearDown(() {});

    testWidgets('도감 열기: codex_open 이벤트, 탭을 보면 새 항목 표시가 지워진다', (tester) async {
      final got = <TelemetryEvent>[];
      GameTelemetry.sink = (e, v) => got.add(e);
      addTearDown(() => GameTelemetry.sink = null);
      AppState.profile = _mixedProfile();
      expect(AppState.profile.codex.freshIn(CodexTab.enemies), greaterThan(0));
      final errors = await pumpScreen(
        tester,
        const CodexScreen(),
        size: const Size(390, 844),
      );
      expect(errors, isEmpty);
      expect(got, [TelemetryEvent.codexOpen]);
      expect(AppState.profile.codex.freshIn(CodexTab.enemies), 0);
      expect(AppState.profile.codex.freshIn(CodexTab.crew), greaterThan(0));
      await tester.tap(find.byKey(const ValueKey('codex-tab-crew')));
      await tester.pumpAndSettle();
      expect(AppState.profile.codex.freshIn(CodexTab.crew), 0);
      // 받을 수 있는 행성 25%를 받는다
      await tester.tap(find.byKey(const ValueKey('codex-tab-planets')));
      await tester.pumpAndSettle();
      final ms = find.byKey(const ValueKey('codex-claim-planets'));
      await tester.ensureVisible(ms);
      await tester.tap(
        find.descendant(of: ms, matching: find.byType(ElevatedButton)),
      );
      await tester.pumpAndSettle();
      expect(AppState.profile.codex.isClaimed(CodexTab.planets, 25), isTrue);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      resetScreen(tester);
    });

    testWidgets('타이틀 도감 버튼: 세로·가로 글자 1.3, 새 항목이면 빨간 점', (tester) async {
      for (final (orient, size, pad) in [
        ('portrait', const Size(390, 844), const EdgeInsets.only(top: 47, bottom: 34)),
        ('landscape', const Size(800, 360), const EdgeInsets.only(left: 24)),
      ]) {
        for (final lang in ['ko', 'de']) {
          AppState.profile = _mixedProfile();
          final errors = await pumpScreen(tester, const TitleScreen(), size: size, padding: pad, textScale: 1.3, lang: lang);
          expect(errors, isEmpty, reason: '$lang $orient');
          final btn = find.byKey(const ValueKey('title-codex'));
          expect(btn, findsOneWidget);
          final r = tester.getRect(btn);
          expect(r.height, greaterThanOrEqualTo(40), reason: '터치 높이');
          expect(Offset.zero & size, isNot(predicate<Rect>((v) => !v.contains(r.bottomRight - const Offset(1, 1)))));
          if (_snapDir != null) {
            await savePng(tester, '$_snapDir/codex_title_${lang}_$orient.png');
          }
          await tester.pumpWidget(const SizedBox());
        }
      }
      resetScreen(tester);
    });

    const shots = [
      ('portrait', Size(390, 844), EdgeInsets.only(top: 47, bottom: 34)),
      ('landscape', Size(800, 360), EdgeInsets.only(left: 24)),
    ];
    for (final lang in ['ko', 'en', 'de']) {
      for (final (orient, size, pad) in shots) {
        testWidgets('렌더 게이트 $lang $orient 글자 1.3: 4탭 넘침 없음', (tester) async {
          final failures = <String>[];
          for (final tab in CodexTab.values) {
            AppState.profile = _mixedProfile();
            final errors = await pumpScreen(
              tester,
              CodexScreen(initialTab: tab.index),
              size: size,
              padding: pad,
              textScale: 1.3,
              lang: lang,
            );
            // 스프라이트가 실제로 읽히게 잠깐 실제 시간을 흘린다
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 300)),
            );
            await tester.pump();
            failures.addAll(errors.map((e) => '${tab.name}: $e'));
            expect(
              find.byKey(ValueKey('codex-header-${tab.name}')),
              findsOneWidget,
            );
            if (_snapDir != null) {
              await savePng(
                tester,
                '$_snapDir/codex_${lang}_${orient}_${tab.name}.png',
              );
            }
            await tester.pumpWidget(const SizedBox());
          }
          resetScreen(tester);
          expect(failures, isEmpty);
        });
      }

      testWidgets('토스트 $lang 세로·가로 글자 1.3', (tester) async {
        for (final (orient, size, pad) in shots) {
          final p = Profile();
          // 토스트는 대사가 없을 때 나온다 → 새 월드의 시작 대사를 비운다
          final w = GameWorld(seed: 5, profile: p)..dialogs.clear();
          final frame = ValueNotifier(0);
          final errors = await pumpScreen(
            tester,
            Scaffold(
              backgroundColor: const Color(0xFF05040F),
              body: Stack(
                children: [
                  Positioned.fill(
                    child: CodexHud(world: w, frame: frame),
                  ),
                  // 토스트 그림은 게임 화면의 대사 칸이 그린다(CodexHud는 순서만 정한다) → 여기서는 직접 그린다
                  Positioned.fill(
                    child: ListenableBuilder(
                      listenable: frame,
                      builder: (_, _) => switch (p.codex.showing) {
                        final f? => Center(child: CodexToastChip(f)),
                        null => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ],
              ),
            ),
            size: size,
            padding: pad,
            textScale: 1.3,
            lang: lang,
          );
          expect(errors, isEmpty);
          p.codex.recordKill(
            _pirate(PirateKind.boss, arch: BossArchetype.flare),
          );
          frame.value++;
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          expect(
            find.textContaining(
              keepAll(codexEntryName(CodexTab.enemies, 'arch_flare')),
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          if (_snapDir != null) {
            await savePng(tester, '$_snapDir/codex_toast_${lang}_$orient.png');
          }
          await tester.pumpWidget(const SizedBox());
          frame.dispose();
        }
        resetScreen(tester);
      });
    }
  });
}
