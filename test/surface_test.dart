import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/codex.dart';
import 'package:star_settlers/game/game_telemetry.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/surface.dart';
import 'package:star_settlers/game/world.dart';

import 'support/surface_bot.dart';

/// 늘 같은 값을 내는 난수 (유물 확률 검사)
class _FixedRandom implements Random {
  _FixedRandom(this.v);
  final double v;
  @override
  double nextDouble() => v;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

const _kinds = [PlanetKind.garden, PlanetKind.desert, PlanetKind.ice, PlanetKind.lava];

/// 생물을 치우고 차량을 [pos]에 세운 채 [seconds]초 흘린다
void _stay(SurfaceWorld w, Offset pos, double seconds) {
  final input = InputState();
  for (var t = 0.0; t < seconds - 1e-9; t += 0.05) {
    w.pirates.clear();
    w.bullets.clear();
    w.player
      ..pos = pos
      ..vel = Offset.zero
      ..hp = w.playerMaxHp;
    w.update(0.05, input);
  }
}

SurfaceSite _site(SurfaceWorld w, SurfaceSiteKind k) => w.sites.firstWhere((s) => s.kind == k);

SurfaceOutcome _outcome({
  int sector = 0,
  int planetIndex = 1,
  SurfaceEnd reason = SurfaceEnd.returned,
  int credits = 1000,
  int ore = 100,
  int sitesDone = 5,
  bool vein = false,
  bool nest = false,
  List<String> relics = const [],
  int dry = 0,
}) => SurfaceOutcome(
  sector: sector,
  planetIndex: planetIndex,
  planetKind: PlanetKind.desert,
  reason: reason,
  credits: credits,
  ore: ore,
  sitesDone: sitesDone,
  sitesTotal: 5,
  veinFound: vein,
  nestCleared: nest,
  relics: relics,
  relicDry: dry,
  seconds: 120,
);

void main() {
  group('지도', () {
    test('같은 행성은 늘 같은 지형, 다른 행성·게임은 다르다', () {
      expect(surfaceSeed(42, 0, 3), surfaceSeed(42, 0, 3));
      final seeds = {
        for (var s = 0; s < 3; s++)
          for (var i = 0; i < 9; i++) surfaceSeed(42, s, i),
      };
      expect(seeds, hasLength(27));
      expect(surfaceSeed(42, 0, 3), isNot(surfaceSeed(43, 0, 3)));

      String sig(SurfaceMap m) => jsonEncode({
        'l': [m.lander.dx, m.lander.dy],
        's': [for (final s in m.sites) [s.kind.name, s.pos.dx, s.pos.dy]],
        'o': [for (final o in m.obstacles) [o.pos.dx, o.pos.dy, o.radius]],
        'h': [for (final h in m.hazards) [h.pos.dx, h.pos.dy, h.radius]],
      });
      final a = SurfaceMap.generate(surfaceSeed(42, 0, 3), PlanetKind.ice);
      final b = SurfaceMap.generate(surfaceSeed(42, 0, 3), PlanetKind.ice);
      expect(sig(a), sig(b));
      expect(sig(SurfaceMap.generate(surfaceSeed(42, 0, 4), PlanetKind.ice)), isNot(sig(a)));

      // 같은 메인 게임·같은 행성이면 판(전투 난수)이 달라도 지도는 같다
      final main = freshColonist(5);
      final p = main.planets[2];
      expect(sig(SurfaceWorld(main: main, planet: p, runSeed: 1).map), sig(SurfaceWorld(main: main, planet: p, runSeed: 2).map));
    });

    test('지점 5곳(유적 2·잔해 1·둥지 1·광맥 1), 장애물 25~40·위험 지대 6~10, 지점·착륙선 주변은 비어 있다', () {
      for (var seed = 0; seed < 120; seed++) {
        final kind = _kinds[seed % 4];
        final m = SurfaceMap.generate(seed * 7919 + 13, kind);
        final counts = <SurfaceSiteKind, int>{};
        for (final s in m.sites) {
          counts[s.kind] = (counts[s.kind] ?? 0) + 1;
        }
        expect(counts, {
          SurfaceSiteKind.ruin: 2,
          SurfaceSiteKind.wreck: 1,
          SurfaceSiteKind.nest: 1,
          SurfaceSiteKind.vein: 1,
        });
        // 막힌 지점을 뚫으려 장애물을 치울 수 있어 아래 한계는 조금 느슨하게
        expect(m.obstacles.length, inInclusiveRange(20, 40), reason: 'seed $seed');
        expect(m.hazards.length, inInclusiveRange(6, 10), reason: 'seed $seed');
        for (final o in m.obstacles) {
          for (final c in [m.lander, for (final s in m.sites) s.pos]) {
            expect((o.pos - c).distance, greaterThanOrEqualTo(SurfaceRules.clearRadius + o.radius), reason: 'seed $seed');
          }
        }
        for (final h in m.hazards) {
          expect((h.pos - m.lander).distance, greaterThan(h.radius + SurfaceRules.landerRadius));
          for (final s in m.sites) {
            expect((h.pos - s.pos).distance, greaterThan(h.radius + s.radius), reason: 'seed $seed: 위험 지대가 지점을 덮음');
          }
        }
        for (final s in m.sites) {
          expect(s.pos.dx, inInclusiveRange(150, SurfaceMap.size - 150));
          expect(s.pos.dy, inInclusiveRange(150, SurfaceMap.size - 150));
        }
      }
    });

    test('모든 지점은 착륙선에서 갈 수 있다 (격자 BFS, 차량 반경 여유) — 400개 지도', () {
      for (var seed = 0; seed < 400; seed++) {
        final m = SurfaceMap.generate(surfaceSeed(seed, seed % 6, seed % 9), _kinds[seed % 4]);
        for (final s in m.sites) {
          expect(m.path(m.lander, s.pos), isNotNull, reason: 'seed $seed ${s.kind.name}');
        }
      }
    });

    test('가스 행성은 착륙할 수 없고, 해금은 식민지 하나부터', () {
      final w = GameWorld(seed: 1);
      final rock = w.planets.firstWhere((p) => p.kind != PlanetKind.gas);
      final gas = w.planets.firstWhere((p) => p.kind == PlanetKind.gas);
      expect(w.landUnlocked, isFalse);
      expect(w.canLand(rock), isFalse);
      w.planets.first.colonyLevel = 1;
      expect(w.canLand(rock), isTrue);
      expect(w.canLand(gas), isFalse);
      // 두 번째 항성계부터는 식민지가 없어도 열린다
      final w2 = GameWorld(seed: 1)..sector = 1;
      expect(w2.landUnlocked, isTrue);
    });

    test('해금 뒤 처음 착륙 가능한 행성 곁에 가면 미나가 한 번 알려 준다 (프로필 플래그)', () {
      final profile = Profile();
      final w = freshColonist(1, profile: profile)
        ..spawnTimer = 1e9
        ..eventTimer = 1e9;
      final p = w.planets.firstWhere((p) => p.kind != PlanetKind.gas);
      w.dialogs.clear();
      w.player.pos = p.pos + Offset(0, p.radius + 60);
      for (var i = 0; i < 12; i++) {
        w.update(0.05, InputState());
      }
      expect(w.dialogs.map((d) => d.text), contains(contains(p.name)));
      expect(SurfaceRecords(profile.stats).hinted, isTrue);
      // 새 게임에서도 다시 하지 않는다
      final w2 = freshColonist(2, profile: profile);
      w2.dialogs.clear();
      final q = w2.planets.firstWhere((p) => p.kind != PlanetKind.gas);
      w2.player.pos = q.pos + Offset(0, q.radius + 60);
      for (var i = 0; i < 12; i++) {
        w2.update(0.05, InputState());
      }
      expect(w2.dialogs.where((d) => d.text.contains(q.name) && d.speaker == Speaker.advisor && d.text.length > 40), isEmpty);
    });
  });

  group('지점·산소·귀환', () {
    SurfaceWorld world([PlanetKind kind = PlanetKind.desert]) {
      final main = freshColonist(7);
      return SurfaceWorld(main: main, planet: landable(main, kind), runSeed: 3);
    }

    test('유적: 4초 머물면 발굴, 벗어나면 멈췄다 이어진다. 발굴을 시작하면 생물이 몰려온다', () {
      final w = world();
      final ruin = _site(w, SurfaceSiteKind.ruin);
      w.pirates.clear();
      w.player.pos = ruin.pos;
      w.update(0.05, InputState());
      expect(w.pirates.length, inInclusiveRange(SurfaceRules.ruinAmbushMin, SurfaceRules.ruinAmbushMax));
      _stay(w, ruin.pos, 2);
      expect(ruin.progress, closeTo(2.05, 0.06));
      expect(w.activeSite, ruin);
      _stay(w, w.map.lander, 1.5);
      expect(ruin.progress, closeTo(2.05, 0.06), reason: '벗어나면 멈춘다 (되돌아가지 않는다)');
      expect(ruin.done, isFalse);
      _stay(w, ruin.pos, 2.0);
      expect(ruin.done, isTrue);
      expect(w.lootCredits, closeTo(SurfaceLoot.ruinCredits * w.lootCreditMul, 1e-6));
    });

    test('광맥 3초·잔해 1초, 전리품과 발견', () {
      final w = world();
      final vein = _site(w, SurfaceSiteKind.vein);
      final wreck = _site(w, SurfaceSiteKind.wreck);
      _stay(w, vein.pos, 2.5);
      expect(vein.done, isFalse);
      _stay(w, vein.pos, 0.6);
      expect(vein.done, isTrue);
      _stay(w, wreck.pos, 1.1);
      expect(wreck.done, isTrue);
      expect(w.lootOre, closeTo((SurfaceLoot.veinOre + SurfaceLoot.wreckOre) * w.lootOreMul, 1e-6));
      w.abandon();
      expect(w.outcome!.veinFound, isTrue);
      expect(w.outcome!.nestCleared, isFalse);
      expect(w.outcome!.sitesDone, 2);
    });

    test('둥지: 가까이 가면 6초마다 기는 것 2마리(최대 8), 탄으로 부수면 낳기를 멈춘다', () {
      final w = world();
      final nest = _site(w, SurfaceSiteKind.nest);
      expect(nest.hp, closeTo(SurfaceRules.nestHp * w.enemyHpMul, 1e-6));
      final spot = nest.pos + const Offset(0, 300);
      final input = InputState();
      final start = {...w.pirates};
      var after7 = 0;
      for (var t = 0.0; t < 40; t += 0.05) {
        w.player
          ..pos = spot
          ..vel = Offset.zero
          ..hp = w.playerMaxHp;
        w.update(0.05, input);
        if (after7 == 0 && t >= 7) after7 = w.pirates.where((e) => !start.contains(e)).length;
      }
      final brood = w.pirates.where((e) => !start.contains(e)).toList();
      expect(after7, SurfaceRules.nestBrood, reason: '6초에 2마리');
      expect(brood.length, SurfaceRules.nestMaxBrood, reason: '40초 뒤 상한 8');
      expect(brood.every((e) => e.kind == PirateKind.scout), isTrue);

      // 자동 사격: 붙은 생물이 없으면 둥지를 조준해 부순다
      input
        ..fire = true
        ..autoAim = true;
      for (var t = 0.0; t < 120 && !nest.done; t += 0.05) {
        w.pirates.clear();
        w.player
          ..pos = spot
          ..vel = Offset.zero
          ..hp = w.playerMaxHp;
        w.update(0.05, input);
      }
      expect(nest.done, isTrue);
      w.pirates.clear();
      for (var t = 0.0; t < 20; t += 0.05) {
        w.player
          ..pos = spot
          ..hp = w.playerMaxHp;
        w.update(0.05, InputState());
      }
      expect(w.pirates.where((e) => (e.pos - nest.pos).distance < 120), isEmpty, reason: '부순 둥지는 낳지 않는다');
      w.abandon();
      expect(w.outcome!.nestCleared, isTrue);
    });

    test('귀환은 착륙선 반경 안에서만: 100%', () {
      final w = world();
      w.player.pos = w.map.lander + const Offset(SurfaceRules.landerRadius + 50, 0);
      expect(w.returnToLander(), isFalse);
      w.player.pos = w.map.lander;
      expect(w.returnToLander(), isTrue);
      expect(w.outcome!.reason, SurfaceEnd.returned);
      expect(w.outcome!.keepRatio, 1);
    });

    test('산소 150초, 30초 남으면 경고·생물 압박, 0이면 비상 귀환 50%', () {
      final w = world();
      expect(w.oxygen, SurfaceRules.oxygenSeconds);
      final input = InputState();
      var maxCreatures = 0;
      for (var t = 0.0; t < 200 && !w.over; t += 0.05) {
        w.player
          ..pos = w.map.lander
          ..hp = w.playerMaxHp;
        final before = w.pirates.length;
        w.update(0.05, input);
        if (w.oxygen <= SurfaceRules.oxygenWarn && w.oxygen > SurfaceRules.oxygenWarn - 0.06) {
          expect(w.warned, isTrue);
          expect(w.pirates.length, greaterThan(before));
        }
        maxCreatures = max(maxCreatures, w.pirates.length);
      }
      expect(w.over, isTrue);
      expect(w.outcome!.reason, SurfaceEnd.oxygen);
      expect(w.outcome!.keepRatio, 0.5);
      expect(w.outcome!.seconds, closeTo(150, 0.1));
      expect(maxCreatures, lessThanOrEqualTo(SurfaceRules.maxCreatures + SurfaceRules.nestMaxBrood));
    });

    test('차량이 파괴되면 50%', () {
      final w = world();
      w.player.alive = false;
      w.update(0.05, InputState());
      expect(w.outcome!.reason, SurfaceEnd.destroyed);
      expect(w.outcome!.keepRatio, 0.5);
      expect(w.outcome!.complete, isFalse);
    });

    test('장애물·지도 경계는 차량을 막는다', () {
      final w = world();
      final o = w.map.obstacles.first;
      w.pirates.clear();
      w.player
        ..pos = o.pos + const Offset(1, 0)
        ..vel = Offset.zero;
      w.update(0.05, InputState());
      expect((w.player.pos - o.pos).distance, greaterThanOrEqualTo(o.radius + 17));
      w.player.pos = const Offset(-500, 3000);
      w.update(0.05, InputState());
      expect(w.player.pos.dx, inInclusiveRange(0, SurfaceMap.size));
      expect(w.player.pos.dy, inInclusiveRange(0, SurfaceMap.size));
    });

    test('위험 지대: 행성 종류별 감속·피해 (방어막이면 피해 없음)', () {
      for (final kind in _kinds) {
        final w = world(kind);
        final h = w.map.hazards.first;
        final e = hazardEffectOf(kind);
        final base = w.playerSpeed;
        w.pirates.clear();
        w.player.pos = h.pos;
        expect(w.playerSpeed, closeTo(base * e.slow, 1e-6), reason: kind.name);
        final hp0 = w.player.hp;
        w.update(0.05, InputState());
        expect(hp0 - w.player.hp, closeTo(e.dps * 0.05, 1e-6), reason: kind.name);
      }
      expect(hazardEffectOf(PlanetKind.desert).slow, lessThan(hazardEffectOf(PlanetKind.garden).slow));
      expect(hazardEffectOf(PlanetKind.lava).dps, greaterThan(hazardEffectOf(PlanetKind.ice).dps));
    });

    test('생물은 기존 적 동작(정찰기·저격선·습격선/돌격함)을 쓰고 종류를 알 수 있다', () {
      expect(pirateKindOf(CreatureKind.crawler, PlanetKind.ice), PirateKind.scout);
      expect(pirateKindOf(CreatureKind.spitter, PlanetKind.ice), PirateKind.sniper);
      expect(pirateKindOf(CreatureKind.brute, PlanetKind.ice), PirateKind.raider);
      expect(pirateKindOf(CreatureKind.brute, PlanetKind.lava), PirateKind.juggernaut);
      for (final c in CreatureKind.values) {
        for (final k in _kinds) {
          expect(creatureOf(pirateKindOf(c, k)), c);
        }
      }
      final w = world();
      expect(w.pirates.length, inInclusiveRange(SurfaceRules.startCreaturesMin, SurfaceRules.startCreaturesMax));
      for (final e in w.pirates) {
        expect(creatureOf(e.kind), isNotNull);
        expect((e.pos - w.map.lander).distance, greaterThanOrEqualTo(SurfaceRules.startCreatureDistance));
      }
    });
  });

  group('선장 능력치·메인 월드', () {
    test('실제 강화·함선·승무원·명예를 쓰고, 적 배율은 메인 항성계 값', () {
      final profile = Profile()
        ..shipType = 'fortress'
        ..honor = 4;
      final main = freshColonist(9, profile: profile)
        ..levels[UpgradeKind.weapon] = 3
        ..levels[UpgradeKind.hull] = 2
        ..levels[UpgradeKind.missile] = 1;
      final w = SurfaceWorld(main: main, planet: main.planets[1], runSeed: 1);
      expect(w.playerDamage, closeTo(main.playerDamage, 1e-9));
      expect(w.playerMaxHp, closeTo(main.playerMaxHp, 1e-9));
      expect(w.playerShots, main.playerShots);
      expect(w.ship.id, 'fortress');
      expect(w.playerSpeed, closeTo(main.playerSpeed * SurfaceRules.roverSpeedMul, 1e-9));
      expect(w.enemyHpMul, main.enemyHpMul);
      expect(w.enemyDamageMul, closeTo(main.enemyDamageMul * SurfaceRules.creatureDamageMul, 1e-9));
      expect(w.fireMissiles(), isTrue);
    });

    test('탐사 중 메인 월드·프로필은 그대로, 격추·도감 적·젬·통계가 쌓이지 않는다', () {
      final profile = Profile()..gems = 10;
      final main = freshColonist(11, profile: profile)
        ..credits = 777
        ..ore = 55;
      String noTime(Object j) => jsonEncode(j).replaceAll(RegExp(r'"savedAt":\d+'), '');
      final worldBefore = noTime(main.toJson());
      final profileBefore = jsonEncode(profile.toJson());
      final w = SurfaceWorld(main: main, planet: main.planets[1], runSeed: 4);
      final r = runSurfaceBot(w);
      expect(w.kills, greaterThan(0));
      expect(noTime(main.toJson()), worldBefore);
      expect(jsonEncode(profile.toJson()), profileBefore);
      expect(profile.codex.kills, isEmpty);
      expect(r.outcome.credits, greaterThan(0));
    });
  });

  group('정산', () {
    late List<(TelemetryEvent, int?)> events;
    setUp(() {
      events = [];
      GameTelemetry.sink = (e, v) => events.add((e, v));
    });
    tearDown(() => GameTelemetry.sink = null);

    test('귀환 100%·비상 50%, 하루 3회 뒤 30% (로컬 날짜), 통계 surface_end', () {
      final profile = Profile();
      final main = freshColonist(3, profile: profile)
        ..credits = 0
        ..ore = 0;
      final day = DateTime(2026, 11, 11, 10);
      final a = _outcome(sitesDone: 3).settle(profile: profile, main: main, now: day);
      expect((a.credits, a.ore, a.full), (1000, 100, true));
      final b = _outcome(reason: SurfaceEnd.destroyed, sitesDone: 3).settle(profile: profile, main: main, now: day);
      expect((b.credits, b.ore), (500, 50));
      final c = _outcome(reason: SurfaceEnd.oxygen, sitesDone: 3).settle(profile: profile, main: main, now: day);
      expect(c.credits, 500);
      expect(c.fullRunsLeft, 0);
      final d = _outcome(sitesDone: 3).settle(profile: profile, main: main, now: day);
      expect(d.full, isFalse);
      expect((d.credits, d.ore), (300, 30));
      expect(main.credits, 1000 + 500 + 500 + 300);
      expect(main.ore, 100 + 50 + 50 + 30);
      // 다음 날(로컬)에는 다시 온전
      final e = _outcome(sitesDone: 3).settle(profile: profile, main: main, now: DateTime(2026, 11, 12, 0, 5));
      expect(e.full, isTrue);
      expect(events.where((x) => x.$1 == TelemetryEvent.surfaceEnd).map((x) => x.$2), [0, 2, 1, 0, 0]);
    });

    test('완전 탐사: 다섯 곳 + 스스로 귀환일 때 행성당 처음 한 번 젬 3개(play)', () {
      final profile = Profile();
      final earned = <(String, int)>[];
      Profile.onEarn = (src, key, n) => earned.add((src, n));
      addTearDown(() => Profile.onEarn = null);
      final main = freshColonist(3, profile: profile);
      final now = DateTime(2026, 11, 11, 10);
      // 비상 귀환이면 다섯 곳을 다 해도 아니다
      expect(_outcome(reason: SurfaceEnd.oxygen).settle(profile: profile, main: main, now: now).newSurveyed, isFalse);
      expect(_outcome(sitesDone: 4).settle(profile: profile, main: main, now: now).newSurveyed, isFalse);
      final s = _outcome().settle(profile: profile, main: main, now: now);
      expect(s.newSurveyed, isTrue);
      expect(s.gems, 3);
      expect(main.planets[1].surveyed, isTrue);
      final again = _outcome().settle(profile: profile, main: main, now: now);
      expect(again.gems, 0);
      expect(again.newSurveyed, isFalse);
      expect(earned, [('play', 3)]);
      expect(profile.gems, 3);
      // 다른 행성은 다시 받을 수 있다
      expect(_outcome(planetIndex: 2).settle(profile: profile, main: main, now: now).gems, 3);
    });

    test('영구 발견은 처음 한 번만 새 발견, 항성계가 바뀌었으면 적용하지 않는다', () {
      final profile = Profile();
      final main = freshColonist(3, profile: profile);
      final now = DateTime(2026, 11, 11);
      final s = _outcome(vein: true, nest: true, sitesDone: 2).settle(profile: profile, main: main, now: now);
      expect((s.newVein, s.newNest, s.applied), (true, true, true));
      expect(main.planets[1].vein && main.planets[1].nest, isTrue);
      final t = _outcome(vein: true, nest: true, sitesDone: 2).settle(profile: profile, main: main, now: now);
      expect((t.newVein, t.newNest), (false, false));
      final u = _outcome(sector: 4, vein: true).settle(profile: profile, main: main, now: now);
      expect(u.applied, isFalse);
    });

    test('유물: 35% 확률, 3번 연속 꽝이면 다음은 확정, 가진 유물은 다시 안 나온다', () {
      final miss = _FixedRandom(0.99), hit = _FixedRandom(0.0);
      var dry = 0;
      String? got;
      for (var i = 0; i < 3; i++) {
        (got, dry) = rollRelic(miss, {}, dry);
        expect(got, isNull);
      }
      expect(dry, 3);
      (got, dry) = rollRelic(miss, {}, dry);
      expect(got, isNotNull, reason: '3연속 꽝 뒤 확정');
      expect(dry, 0);
      (got, dry) = rollRelic(hit, {}, 0);
      expect(got, relicIds.first);
      final owned = {...relicIds.take(7)};
      (got, _) = rollRelic(hit, owned, 0);
      expect(got, relicIds.last);
      expect(rollRelic(hit, {...relicIds}, 2), (null, 2));
      // 여러 번 뽑아도 가진 유물·겹친 유물은 없다
      final r = Random(1);
      final have = <String>{};
      var d = 0;
      for (var i = 0; i < 200; i++) {
        final (id, nd) = rollRelic(r, have, d);
        d = nd;
        if (id != null) expect(have.add(id), isTrue);
      }
      expect(have, hasLength(8));
    });

    test('판 안에서 연속 꽝이 이어지고, 정산하면 도감(토스트)과 연속 꽝 기록이 남는다', () {
      final profile = Profile();
      profile.stats[SurfaceRecords.kDry] = 3;
      final main = freshColonist(3, profile: profile);
      final w = SurfaceWorld(main: main, planet: main.planets[1], runSeed: 2);
      _stay(w, _site(w, SurfaceSiteKind.ruin).pos, 4.2);
      expect(w.relicsFound, hasLength(1), reason: '연속 꽝 3 → 확정');
      w.player.pos = w.map.lander;
      w.returnToLander();
      final s = w.outcome!.settle(profile: profile, main: main, now: DateTime(2026, 11, 11));
      expect(s.relics, w.relicsFound);
      expect(profile.codex.relics, w.relicsFound.toSet());
      expect(profile.codex.toasts.last.tab, CodexTab.relics);
      expect(SurfaceRecords(profile.stats).dry, 0);
    });

    test('보상 기준값: 한 판 100% ≈ 같은 항성계 본 게임 약 2분 수입', () {
      // 기준: 첫 항성계에서 식민지 3곳 Lv.2를 둔 선장의 2분 = 생산 120초 + 사냥(분당 정찰기 4척 현상금)
      final main = GameWorld(seed: 21);
      for (final p in main.planets.where((p) => p.kind != PlanetKind.gas).take(3)) {
        p.colonyLevel = 2;
      }
      final twoMinutes = main.creditIncome * 120 + 2 * 4 * 25 * main.rewardMul;
      // 모든 지점의 기준값 + 생물 처치(한 판 평균 약 25마리 × 평균 11)
      final sites = [for (final k in [SurfaceSiteKind.ruin, SurfaceSiteKind.ruin, SurfaceSiteKind.wreck, SurfaceSiteKind.nest, SurfaceSiteKind.vein]) SurfaceLoot.site(k)];
      final siteCredits = sites.fold(0, (a, s) => a + s.$1) * main.rewardMul;
      final full = siteCredits + 25 * 11 * main.rewardMul;
      // ignore: avoid_print
      print('지표 한 판(100%) 크레딧 ≈ ${full.round()} / 본 게임 2분 ≈ ${twoMinutes.round()} (생산 ${main.creditIncome.toStringAsFixed(1)}/초)');
      expect(full / twoMinutes, inInclusiveRange(0.6, 1.4));
      // 광석: 본 게임 2분 광석 생산과 같은 자릿수
      final ore = sites.fold(0, (a, s) => a + s.$2) * main.sectorMul;
      expect(ore / (main.oreIncome * 120), inInclusiveRange(0.4, 2.0));
      // 뒤 항성계로 가면 현상금처럼 rewardMul·sectorMul을 따른다
      final far = GameWorld(seed: 21)..sector = 3;
      final w = SurfaceWorld(main: far, planet: far.planets[1], runSeed: 1);
      expect(w.lootCreditMul, far.rewardMul);
      expect(w.lootOreMul, far.sectorMul);
    });
  });

  group('행성 영구 발견', () {
    test('광맥: 광석 +0.4/초×레벨(광석 없던 종류에도), 둥지: 방어막 ×1.25, 완전 탐사: 크레딧 ×1.1', () {
      final p = Planet('X', 100, PlanetKind.garden, orbitRadius: 1850, orbitPhase: 0)..colonyLevel = 3;
      final ore0 = p.baseOreRate, cr0 = p.baseCreditRate, sh0 = p.shieldMax(1);
      expect(ore0, 0);
      p.vein = true;
      expect(p.baseOreRate, closeTo(0.4 * 3, 1e-9));
      p.nest = true;
      expect(p.shieldMax(1), closeTo(sh0 * 1.25, 1e-9));
      p.surveyed = true;
      expect(p.baseCreditRate, closeTo(cr0 * 1.1, 1e-9));
      expect(p.discoveries, 7);
      // 식민지가 없으면 효과도 없다 (정착하면 적용)
      final q = Planet('Y', 100, PlanetKind.ice, orbitRadius: 1850, orbitPhase: 0)..discoveries = 7;
      expect(q.baseOreRate, 0);
      expect(q.baseCreditRate, 0);
    });

    test('저장/불러오기 왕복, 다른 항성계(SectorSave)와 원격 수입(io)에도 반영', () {
      final w = GameWorld(seed: 151)
        ..credits = 1e9
        ..ore = 1e9;
      final p = w.planets[2];
      w.upgradePlanet(p);
      w.upgradePlanet(p);
      final ore0 = w.oreIncome;
      p
        ..vein = true
        ..nest = true;
      expect(w.oreIncome, greaterThan(ore0));
      final back = GameWorld.fromJson(jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>, Profile());
      expect(back.planets[2].vein, isTrue);
      expect(back.planets[2].nest, isTrue);
      expect(back.planets[2].surveyed, isFalse);
      expect(back.planets[3].discoveries, 0);

      // 다른 항성계로 떠나면 SectorSave에 남고, 원격 광석 수입이 광맥만큼 크다
      w.counters['maxSector'] = 1;
      final idleNoVein = (p.baseOreRate - 0.4 * p.colonyLevel) * w.sectorMul;
      expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
      final save = w.sectors[0]!;
      expect(save.discAt(2), 3);
      expect(w.remotePlanet(0, 2).vein, isTrue);
      expect(save.idleOre, greaterThan(idleNoVein));
      final again = SectorSave.fromJson(jsonDecode(jsonEncode(save.toJson())) as Map<String, dynamic>);
      expect(again.discAt(2), 3);
      // 원격 강화를 해도 발견은 그대로
      expect(w.upgradeRemotePlanet(0, 2), isTrue);
      expect(w.sectors[0]!.discAt(2), 3);
      // 돌아오면 다시 행성에
      expect(w.warp(w.gates.firstWhere((g) => !g.forward)), isTrue);
      expect(w.planets[2].vein && w.planets[2].nest, isTrue);
    });

    test('발견 필드가 없는 옛 저장도 읽힌다', () {
      final w = GameWorld(seed: 3);
      final j = jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>;
      (j['current'] as Map).remove('disc');
      final back = GameWorld.fromJson(j, Profile());
      expect(back.planets.every((p) => p.discoveries == 0), isTrue);
      final old = SectorSave.fromJson(
        (jsonDecode(jsonEncode(w.toJson())) as Map<String, dynamic>)['current'] as Map<String, dynamic>,
      );
      expect(old.discoveries, isEmpty);
      expect(old.discAt(5), 0);
      expect(old.toJson().containsKey('disc'), isFalse, reason: '발견이 없으면 저장 형식도 그대로');
    });
  });

  group('도감 유물 탭', () {
    test('8종, 마일스톤은 100% 하나(젬 없음), 저장 왕복', () {
      final p = Profile();
      final c = p.codex;
      expect(Codex.ids(CodexTab.relics), relicIds);
      expect(relicIds, hasLength(8));
      expect(codexMilestonesOf(CodexTab.relics), [100]);
      expect(relicSprite('star_map'), 'relic_star_map');
      expect(relicKey('crystal_core'), 'crystalCore');
      expect(c.recordRelic('idol'), isTrue);
      expect(c.recordRelic('idol'), isFalse);
      expect(c.recordRelic('nope'), isFalse);
      expect(c.isFresh(CodexTab.relics, 'idol'), isTrue);
      expect(c.canClaim(CodexTab.relics, 100), isFalse);
      for (final id in relicIds) {
        c.recordRelic(id);
      }
      expect(c.percent(CodexTab.relics), 100);
      expect(c.claimable, 1);
      final r = c.claim(CodexTab.relics, 100, p)!;
      expect(r.crewRarity, 3);
      expect(p.gems, 0);
      expect(c.claim(CodexTab.relics, 25, p), isNull);
      final back = Profile.fromJson(jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>);
      expect(back.codex.relics, relicIds.toSet());
      expect(back.codex.isClaimed(CodexTab.relics, 100), isTrue);
    });
  });

  group('봇 (헤드리스, 기존 전투 엔진)', () {
    test('기본 능력치(새 게임 첫 항성계 + 첫 식민지): 평균 90~170초, 격추율이 너무 높지 않다', () {
      final rows = <String>[];
      var total = 0.0, deaths = 0, n = 0, complete = 0;
      final perKind = <PlanetKind, int>{};
      for (final kind in _kinds) {
        for (var s = 0; s < 12; s++) {
          final main = freshColonist(300 + s);
          final w = SurfaceWorld(main: main, planet: landable(main, kind), runSeed: s);
          final o = runSurfaceBot(w).outcome;
          n++;
          total += o.seconds;
          if (o.reason == SurfaceEnd.destroyed) {
            deaths++;
            perKind[kind] = (perKind[kind] ?? 0) + 1;
          }
          if (o.complete) complete++;
          rows.add('${kind.name}/$s ${o.reason.name} ${o.seconds.round()}s ${o.sitesDone}곳');
        }
      }
      final avg = total / n;
      // ignore: avoid_print
      print('지표 봇 $n판: 평균 ${avg.toStringAsFixed(1)}초, 격추 $deaths판(${(deaths * 100 / n).round()}%) $perKind, 완전 탐사 $complete판');
      expect(avg, inInclusiveRange(90, 170));
      expect(deaths / n, lessThanOrEqualTo(0.3), reason: rows.join('\n'));
      for (final k in _kinds) {
        expect((perKind[k] ?? 0) / 12, lessThanOrEqualTo(0.5), reason: '${k.name}: ${rows.join('\n')}');
      }
      expect(complete / n, greaterThanOrEqualTo(0.4), reason: '봇도 절반 가까이는 다 돌고 돌아온다');
    });
  });
}
