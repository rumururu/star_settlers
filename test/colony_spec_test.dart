import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart';
import 'package:star_settlers/ui/colonies_panel.dart';
import 'package:star_settlers/ui/colony_panel.dart';
import 'package:star_settlers/ui/common.dart' show keepAll;
import 'package:star_settlers/ui/tokens.dart';

/// 돈이 넉넉하고 해적·이벤트가 없는 세계. 두 번째 항성계까지 가 봐서 상한은 Lv.5
GameWorld funded() => GameWorld(seed: 151)
  ..credits = 1e12
  ..ore = 1e12
  ..spawnTimer = 1e9
  ..eventTimer = 1e9
  ..counters['maxSector'] = 1;

/// [p]를 [level]까지 올린다
void raise(GameWorld w, Planet p, int level) {
  while (p.colonyLevel < level) {
    expect(w.upgradePlanet(p), isTrue);
  }
}

GameWorld reload(GameWorld w) => GameWorld.fromJson(
  jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>,
  w.profile,
);

void main() {
  setUp(() => Lang.set(const Locale('ko')));

  group('선택과 비용', () {
    test('Lv.4에서는 거부, Lv.5에서 처음 고르기는 무료', () {
      final w = funded();
      final p = w.planets.first;
      raise(w, p, 4);
      expect(GameWorld.canSpecialize(p), isFalse);
      expect(w.setColonySpec(p, ColonySpec.industry), isFalse);
      expect(p.spec, isNull);
      raise(w, p, 5);
      expect(w.specCost(p), (0, 0));
      final credits = w.credits, ore = w.ore;
      expect(w.setColonySpec(p, ColonySpec.industry), isTrue);
      expect(p.spec, ColonySpec.industry);
      expect(w.credits, credits);
      expect(w.ore, ore);
      // 같은 특화를 다시 고르는 것은 아무 일도 아니다
      expect(w.setColonySpec(p, ColonySpec.industry), isFalse);
    });

    test('바꾸기는 현재 레벨업 비용과 같고, 상한에 막혀도 같은 공식이다', () {
      final w = funded();
      final p = w.planets.first;
      raise(w, p, 5);
      expect(w.upgradePlanet(p), isFalse, reason: '항성계 2 상한 Lv.5');
      w.setColonySpec(p, ColonySpec.industry);
      final cost = w.specCost(p);
      expect(cost, w.planetCost(p));
      expect(cost.$1, greaterThan(0));
      final credits = w.credits, ore = w.ore;
      expect(w.setColonySpec(p, ColonySpec.mining), isTrue);
      expect(p.spec, ColonySpec.mining);
      expect(w.credits, credits - cost.$1);
      expect(w.ore, ore - cost.$2);
    });

    test('자원이 모자라면 바꾸기를 거부한다', () {
      final w = funded();
      final p = w.planets.first;
      raise(w, p, 5);
      w.setColonySpec(p, ColonySpec.fortress);
      final cost = w.specCost(p);
      w
        ..credits = cost.$1 - 1.0
        ..ore = 1e9;
      expect(w.setColonySpec(p, ColonySpec.industry), isFalse);
      w
        ..credits = 1e9
        ..ore = cost.$2 - 1.0;
      expect(w.setColonySpec(p, ColonySpec.industry), isFalse);
      expect(p.spec, ColonySpec.fortress);
      expect(w.ore, cost.$2 - 1.0);
    });

    test('처음 Lv.5가 되면 미나가 한 번만 안내한다', () {
      final w = funded();
      final p = w.planets.first;
      raise(w, p, 5);
      final line = tr.g_dlgSpecUnlocked(p.name);
      expect(w.dialogs.where((d) => d.text == line), hasLength(1));
      expect(w.counter('specHint'), 1);
      w.dialogs.clear();
      final q = w.planets[1];
      raise(w, q, 5);
      expect(
        w.dialogs.any((d) => d.text == tr.g_dlgSpecUnlocked(q.name)),
        isFalse,
      );
    });
  });

  group('효과', () {
    test('산업: 크레딧 ×1.5 (기초값과 실제 수입 모두)', () {
      final w = funded();
      final p = w.planets.first;
      raise(w, p, 5);
      final base = p.baseCreditRate, rate = w.planetCreditRate(p);
      final ore = p.baseOreRate;
      w.setColonySpec(p, ColonySpec.industry);
      expect(p.baseCreditRate, closeTo(base * 1.5, 1e-9));
      expect(w.planetCreditRate(p), closeTo(rate * 1.5, 1e-9));
      expect(p.baseOreRate, closeTo(ore, 1e-9));
    });

    test('채굴: 광석 ×2.5, 크레딧은 그대로', () {
      final w = funded();
      final p = w.planets.first;
      raise(w, p, 5);
      expect(w.buildColony(p, ColonyBuilding.mine), isTrue);
      final ore = p.baseOreRate, oreRate = w.planetOreRate(p);
      final credits = p.baseCreditRate;
      expect(ore, greaterThan(0));
      w.setColonySpec(p, ColonySpec.mining);
      expect(p.baseOreRate, closeTo(ore * 2.5, 1e-9));
      expect(w.planetOreRate(p), closeTo(oreRate * 2.5, 1e-9));
      expect(p.baseCreditRate, closeTo(credits, 1e-9));
    });

    test('요새: 방어막 최대치 ×2, 포탑 피해 ×1.5', () {
      final w = funded();
      final p = w.planets.first;
      raise(w, p, 5);
      w.buildColony(p, ColonyBuilding.turret);
      final shield = p.shieldMax(w.sectorMul), dmg = p.turretDamage;
      w.setColonySpec(p, ColonySpec.fortress);
      expect(p.shieldMax(w.sectorMul), closeTo(shield * 2, 1e-9));
      expect(p.turretDamage, closeTo(dmg * 1.5, 1e-9));
      // 요새를 그만두면 남은 방어막도 줄어든 최대치에 맞춘다
      p.shieldHp = p.shieldMax(w.sectorMul);
      w.setColonySpec(p, ColonySpec.industry);
      expect(p.shieldHp, p.shieldMax(w.sectorMul));
      expect(p.turretDamage, closeTo(dmg, 1e-9));
    });

    /// 방어막이 깨진 채 습격이 끝나게 한다. 남은 레벨을 돌려준다.
    int raidEnds(GameWorld w, Planet p) {
      final ev = w.startEvent(EventKind.raid)!;
      expect(ev.planet, same(p));
      p
        ..shieldHp = 0
        ..shieldBroken = true
        ..relayShieldHp = 0;
      ev.timeLeft = 0;
      w.update(1 / 60, InputState());
      expect(ev.finished, isTrue);
      return p.colonyLevel;
    }

    test('요새 Lv.5 이상은 습격으로 레벨을 잃지 않는다 (다른 특화는 잃는다)', () {
      for (final spec in ColonySpec.values) {
        final w = funded();
        final p = w.planets.first;
        raise(w, p, 5);
        w.setColonySpec(p, spec);
        final left = raidEnds(w, p);
        expect(left, spec == ColonySpec.fortress ? 5 : 4, reason: spec.name);
        if (spec == ColonySpec.fortress) {
          expect(
            w.dialogs.any((d) => d.text == tr.g_dlgRaidFortress(p.name)),
            isTrue,
          );
        }
      }
    });

    test('Lv.5 아래로 떨어져도 특화는 남고 효과만 꺼진다', () {
      final w = funded();
      final p = w.planets.first;
      raise(w, p, 5);
      w.setColonySpec(p, ColonySpec.industry);
      expect(raidEnds(w, p), 4);
      expect(p.spec, ColonySpec.industry);
      expect(p.activeSpec, isNull);
      final plain = funded();
      final q = plain.planets.first;
      raise(plain, q, 4);
      expect(p.baseCreditRate, closeTo(q.baseCreditRate, 1e-9));
      // 다시 Lv.5가 되면 효과가 돌아온다
      raise(w, p, 5);
      expect(p.activeSpec, ColonySpec.industry);
      // Lv.4에서는 바꿀 수 없다
      p.colonyLevel = 4;
      expect(w.setColonySpec(p, ColonySpec.mining), isFalse);
    });
  });

  group('저장', () {
    test('저장 → 불러오기 후에도 현재 항성계 특화가 남는다', () {
      final w = funded();
      final p = w.planets.first;
      raise(w, p, 5);
      w.setColonySpec(p, ColonySpec.fortress);
      final r = reload(w);
      expect(r.planets.first.spec, ColonySpec.fortress);
      expect(r.planets[1].spec, isNull);
      expect(r.planets.first.shieldMax(r.sectorMul), p.shieldMax(w.sectorMul));
    });

    test('특화 필드가 없는 옛 저장은 특화 없음으로 읽는다', () {
      final w = funded();
      raise(w, w.planets.first, 5);
      w.setColonySpec(w.planets.first, ColonySpec.industry);
      final j = jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>;
      (j['current'] as Map).remove('spec');
      final r = GameWorld.fromJson(j, w.profile);
      expect(r.planets.every((p) => p.spec == null), isTrue);
      expect(r.planets.first.colonyLevel, 5);
      final old = SectorSave.fromJson({
        'colonies': [5, 0],
        'stations': <Map<String, dynamic>>[],
        'elapsed': 0,
        'boss': false,
        'bosses': 0,
        'ic': 1.0,
        'io': 0.0,
      });
      expect(old.specs, isEmpty);
      expect(old.specAt(0), isNull);
      // 모르는 값도 특화 없음
      final odd = SectorSave.fromJson({
        ...old.toJson(),
        'spec': ['nope', null],
      });
      expect(odd.specAt(0), isNull);
      expect(odd.specAt(1), isNull);
    });

    test('워프로 떠나면 원격 수입에 특화가 한 번만 반영된다', () {
      GameWorld leave(ColonySpec? spec) {
        final w = funded();
        final p = w.planets.first;
        raise(w, p, 5);
        w.buildColony(p, ColonyBuilding.mine);
        if (spec != null) w.setColonySpec(p, spec);
        expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
        return w;
      }

      final plain = leave(null);
      final mars = plain.remotePlanet(0, 0);
      final ind = leave(ColonySpec.industry);
      expect(
        ind.sectors[0]!.idleCredits - plain.sectors[0]!.idleCredits,
        closeTo(mars.baseCreditRate * 0.5, 1e-9),
      );
      expect(ind.otherSectorCredits, greaterThan(plain.otherSectorCredits));
      expect(ind.sectors[0]!.idleOre, closeTo(plain.sectors[0]!.idleOre, 1e-9));
      final min = leave(ColonySpec.mining);
      expect(
        min.sectors[0]!.idleOre - plain.sectors[0]!.idleOre,
        closeTo(mars.baseOreRate * 1.5, 1e-9),
      );
      // 원격 사본도 특화를 알고, 표시 수입(기초값)이 저장값과 맞는다
      expect(ind.remotePlanet(0, 0).spec, ColonySpec.industry);
      expect(
        ind.remotePlanet(0, 0).baseCreditRate,
        closeTo(mars.baseCreditRate * 1.5, 1e-9),
      );
      // 저장해도 유지되고, 돌아가면 행성에 다시 붙는다
      final r = reload(ind);
      expect(r.remotePlanet(0, 0).spec, ColonySpec.industry);
      expect(ind.warp(ind.gates.firstWhere((g) => !g.forward)), isTrue);
      expect(ind.planets.first.spec, ColonySpec.industry);
    });

    test('떠나온 항성계 식민지도 특화를 고르고 바꿀 수 있다', () {
      final w = funded();
      final p = w.planets.first;
      raise(w, p, 4);
      w.buildColony(p, ColonyBuilding.mine);
      expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
      // Lv.4는 거부
      expect(w.setRemoteColonySpec(0, 0, ColonySpec.industry), isFalse);
      expect(w.upgradeRemotePlanet(0, 0), isTrue);
      final save0 = w.sectors[0]!;
      final mars = w.remotePlanet(0, 0);
      expect(w.remoteSpecCost(0, mars), (0, 0));
      final credits = w.credits;
      expect(w.setRemoteColonySpec(0, 0, ColonySpec.industry), isTrue);
      expect(w.credits, credits);
      expect(w.remotePlanet(0, 0).spec, ColonySpec.industry);
      expect(
        w.sectors[0]!.idleCredits - save0.idleCredits,
        closeTo(mars.baseCreditRate * 0.5, 1e-9),
      );
      // 바꾸기: 원격 레벨업 비용과 같다. 산업 보너스는 빠지고 채굴 보너스가 붙는다
      final cost = w.remoteSpecCost(0, w.remotePlanet(0, 0));
      expect(cost, w.remotePlanetCost(0, w.remotePlanet(0, 0)));
      final c1 = w.credits;
      expect(w.setRemoteColonySpec(0, 0, ColonySpec.mining), isTrue);
      expect(w.credits, c1 - cost.$1);
      expect(w.sectors[0]!.idleCredits, closeTo(save0.idleCredits, 1e-9));
      expect(
        w.sectors[0]!.idleOre - save0.idleOre,
        closeTo(mars.baseOreRate * 1.5, 1e-9),
      );
      // 다른 행성 특화·레벨·건물은 그대로
      expect(w.sectors[0]!.specs.length, save0.colonyLevels.length);
      expect(w.sectors[0]!.specAt(1), isNull);
      expect(w.sectors[0]!.buildings, save0.buildings);
      // 원격 레벨업도 특화를 지우지 않는다
      w.counters['maxSector'] = 2;
      expect(w.upgradeRemotePlanet(0, 0), isTrue);
      expect(w.remotePlanet(0, 0).spec, ColonySpec.mining);
      // 자원이 모자라면 거부
      w.credits = 0;
      expect(w.setRemoteColonySpec(0, 0, ColonySpec.fortress), isFalse);
      expect(w.remotePlanet(0, 0).spec, ColonySpec.mining);
    });
  });

  group('화면', () {
    Future<void> loadFont() async {
      final font = FontLoader(Ts.family)
        ..addFont(rootBundle.load('assets/fonts/Jua-Regular.ttf'));
      await font.load();
    }

    Widget app(Locale locale, Widget body) => MaterialApp(
      theme: ThemeData(fontFamily: Ts.family),
      locale: locale,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(1.3)),
        child: child!,
      ),
      home: Scaffold(body: body),
    );

    /// 특화 [s] 줄(테두리 상자) 안의 버튼
    Finder specButton(ColonySpec s) => find.descendant(
      of: find
          .ancestor(
            of: find.text(keepAll('${s.emoji} ${s.label}')),
            matching: find.byType(Container),
          )
          .first,
      matching: find.byType(ElevatedButton),
    );

    for (final locale in L10n.supportedLocales) {
      testWidgets('colony panel spec ${locale.languageCode}', (tester) async {
        await loadFont();
        Lang.set(locale);
        final w = funded();
        w.profile.colonyTutorialSeen = true;
        final p = w.planets.first;
        raise(w, p, 4);
        final frame = ValueNotifier(0);
        addTearDown(frame.dispose);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.view.devicePixelRatio = 1;
        final panel = ColonyPanel(
          world: w,
          planet: p,
          frame: frame,
          act: (f) {
            f();
            frame.value++;
          },
          onClose: () {},
          onTutorialDone: () {},
        );
        for (final size in [const Size(360, 740), const Size(800, 360)]) {
          tester.view.physicalSize = size;
          p
            ..colonyLevel = 4
            ..spec = null;
          frame.value++;
          await tester.pumpWidget(
            app(locale, KeyedSubtree(key: ValueKey(size), child: panel)),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$size Lv.4');
          final locked = find.text(
            keepAll('🔒 ${tr.u_specLocked(ColonySpec.minLevel)}'),
          );
          await tester.scrollUntilVisible(
            locked,
            100,
            scrollable: find.byType(Scrollable).last,
          );
          expect(locked, findsOneWidget);

          p.colonyLevel = 5;
          frame.value++;
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$size Lv.5');
          final free = find.ancestor(
            of: find.text(keepAll(tr.u_specFree)),
            matching: find.byType(ElevatedButton),
          );
          await tester.scrollUntilVisible(
            free.first,
            100,
            scrollable: find.byType(Scrollable).last,
          );
          expect(free, findsNWidgets(3));
          for (var i = 0; i < 3; i++) {
            final s = tester.getSize(free.at(i));
            expect(s.width, greaterThanOrEqualTo(Tap.min));
            expect(s.height, greaterThanOrEqualTo(Tap.min));
          }
          for (final s in ColonySpec.values) {
            expect(find.text(keepAll(s.effect)), findsOneWidget);
          }
          final mining = specButton(ColonySpec.mining);
          await tester.ensureVisible(mining);
          await tester.pump();
          await tester.tap(mining);
          await tester.pump();
          expect(p.spec, ColonySpec.mining);
          expect(tester.takeException(), isNull, reason: '$size picked');
          expect(find.text(keepAll(tr.u_specFree)), findsNothing);
          // 현재 특화는 ✓, 나머지 두 개는 비용 버튼
          expect(find.text(keepAll('✓')), findsOneWidget);
        }
      });

      testWidgets('colonies panel spec ${locale.languageCode}', (tester) async {
        await loadFont();
        Lang.set(locale);
        final w = funded();
        raise(w, w.planets.first, 5);
        w.buildColony(w.planets.first, ColonyBuilding.stabilizer);
        expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
        raise(w, w.planets.first, 5);
        w.setColonySpec(w.planets.first, ColonySpec.fortress);
        final frame = ValueNotifier(0);
        addTearDown(frame.dispose);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.view.devicePixelRatio = 1;
        for (final size in [const Size(360, 740), const Size(800, 360)]) {
          tester.view.physicalSize = size;
          w.sectors[0] = SectorSave.fromJson({
            ...w.sectors[0]!.toJson(),
            'spec': <String>[],
          });
          await tester.pumpWidget(
            app(
              locale,
              ColoniesPanel(
                key: ValueKey(size),
                world: w,
                frame: frame,
                act: (f) {
                  f();
                  frame.value++;
                },
                onClose: () {},
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$size');
          // 특화는 정박기 줄 앞에 이모지+이름으로 표시한다 (행 높이는 그대로)
          final fortress = ColonySpec.fortress;
          expect(
            find.textContaining(keepAll('${fortress.emoji} ${fortress.label}')),
            findsOneWidget,
          );
          // 떠나온 화성: 행을 눌러 특화 선택을 펼치고 무료로 고른다
          final choose = find.textContaining(keepAll('✨ ${tr.u_specChoose}'));
          await tester.scrollUntilVisible(
            choose,
            100,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.ensureVisible(choose);
          await tester.pump();
          expect(choose, findsOneWidget);
          final row = find.ancestor(of: choose, matching: find.byType(InkWell));
          expect(
            tester.getSize(row.first).height,
            greaterThanOrEqualTo(Tap.min),
          );
          await tester.tap(choose);
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$size open');
          final free = find.ancestor(
            of: find.text(keepAll(tr.u_specFree)),
            matching: find.byType(ElevatedButton),
          );
          expect(free, findsNWidgets(3));
          await tester.scrollUntilVisible(
            free.first,
            100,
            scrollable: find.byType(Scrollable).last,
          );
          final industry0 = specButton(ColonySpec.industry);
          await tester.ensureVisible(industry0);
          await tester.pump();
          await tester.tap(industry0);
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$size picked');
          expect(w.remotePlanet(0, 0).spec, ColonySpec.industry);
          final industry = ColonySpec.industry;
          expect(
            find.textContaining(keepAll('${industry.emoji} ${industry.label}')),
            findsAtLeastNWidgets(2),
            reason: '행 표시 + 펼친 선택',
          );
          // 다시 누르면 접힌다
          final picked = find.textContaining(
            keepAll('${industry.emoji} ${industry.label} ▴'),
          );
          await tester.ensureVisible(picked);
          await tester.pump();
          await tester.tap(picked);
          await tester.pump();
          expect(free, findsNothing);
          expect(find.text(keepAll('✓')), findsNothing);
        }
      });
    }
  });
}
