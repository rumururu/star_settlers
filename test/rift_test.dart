import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/rift.dart';
import 'package:star_settlers/game/weekly_score.dart';
import 'package:star_settlers/game/world.dart';

import 'support/rift_bot.dart';

/// 균열 런 (TASK 005) 규칙: 시드 결정성, 카드 효과·중첩, 점수·상한, 보상 하루 상한, 기록, 메인 저장 불변, 봇 길이
void main() {
  group('오늘의 균열 시드', () {
    test('날짜는 UTC 기준', () {
      expect(riftDayKey(DateTime.utc(2026, 11, 8, 23, 59)), 20261108);
      expect(riftDayKey(DateTime.parse('2026-11-08T23:30:00-05:00')), 20261109);
      expect(riftDayKey(DateTime.parse('2026-11-09T08:30:00+09:00')), 20261108);
    });

    test('같은 날이면 파도·후반 적·두목·카드 순서가 모두 같다', () {
      final a = RiftPlan(20261108), b = RiftPlan(20261108);
      expect(a.seed, b.seed);
      for (var n = 1; n <= RiftPlan.waveCount; n++) {
        expect(a.wave(n).kinds, b.wave(n).kinds, reason: 'wave $n');
        expect(a.wave(n).hpMul, b.wave(n).hpMul);
      }
      expect(a.lateFoes, b.lateFoes);
      expect(a.bossArchetype, b.bossArchetype);
      for (var n = 1; n < RiftPlan.waveCount; n++) {
        expect(a.offers(n, RiftLoadout()), b.offers(n, RiftLoadout()), reason: 'offers $n');
      }
    });

    test('날짜가 다르면 구성이 달라진다', () {
      final days = [for (var i = 0; i < 20; i++) RiftPlan(20261101 + i)];
      expect(days.map((p) => p.seed).toSet(), hasLength(20));
      expect(days.map((p) => p.wave(6).kinds.join(',')).toSet().length, greaterThan(10));
      expect(days.map((p) => p.offers(1, RiftLoadout()).join(',')).toSet().length, greaterThan(5));
    });

    test('파도 구성: 수는 3+2n, 두목 파도는 두목 1 + 호위 8, 체력·공격 배율은 오른다', () {
      final p = RiftPlan(20261108);
      for (var n = 1; n < RiftPlan.waveCount; n++) {
        expect(p.wave(n).count, RiftPlan.regularCount(n));
        expect(p.wave(n).kinds, isNot(contains(PirateKind.boss)));
        expect(p.wave(n + 1).hpMul, greaterThan(p.wave(n).hpMul));
      }
      final boss = p.wave(RiftPlan.waveCount);
      expect(boss.boss, isTrue);
      expect(boss.kinds.first, PirateKind.boss);
      expect(boss.count, 1 + RiftPlan.bossEscorts);
      // 1~2파는 기본 해적만
      expect(p.wave(1).kinds.toSet(), {PirateKind.scout});
    });
  });

  group('카드', () {
    test('효과와 중첩', () {
      final l = RiftLoadout();
      expect(l.damageMul, 1);
      expect(l.shots, 1);
      expect(l.maxHp, 100);
      expect(l.homingInterval, 0);
      expect(l.droneLevel, 0);
      for (var i = 0; i < 3; i++) {
        expect(l.take(RiftCard.damage), isTrue);
      }
      expect(l.damageMul, closeTo(1.75, 1e-9));
      l
        ..take(RiftCard.multishot)
        ..take(RiftCard.multishot)
        ..take(RiftCard.rapid)
        ..take(RiftCard.hull)
        ..take(RiftCard.homing)
        ..take(RiftCard.homing)
        ..take(RiftCard.drone)
        ..take(RiftCard.drone)
        ..take(RiftCard.crit)
        ..take(RiftCard.blades)
        ..take(RiftCard.shockwave)
        ..take(RiftCard.guard)
        ..take(RiftCard.vampire)
        ..take(RiftCard.regen)
        ..take(RiftCard.engine)
        ..take(RiftCard.magnet)
        ..take(RiftCard.pierce);
      expect(l.shots, 3);
      expect(l.fireIntervalMul, closeTo(0.85, 1e-9));
      expect(l.maxHp, 135);
      expect(l.homingInterval, closeTo(3.2, 1e-9));
      expect(l.homingCount, 3);
      expect(l.homingDamage, closeTo(22 * 1.75, 1e-9));
      expect(l.droneLevel, 3);
      expect(l.crit, closeTo(0.12, 1e-9));
      expect(l.blades, 1);
      expect(l.bladeDamage, closeTo(12 * 1.75, 1e-9));
      expect(l.shockInterval, 7);
      expect(l.guardInterval, 9);
      expect(l.healPerKill, 3);
      expect(l.regenPerSec, 2);
      expect(l.speedMul, closeTo(1.12, 1e-9));
      expect(l.magnetBonus, 160);
      expect(l.pierce, 1);
      expect(l.picks, 20);
    });

    test('최대 중첩을 넘지 못하고, 치명타는 60%가 상한', () {
      for (final c in RiftCard.values) {
        final l = RiftLoadout();
        for (var i = 0; i < c.maxStacks; i++) {
          expect(l.take(c), isTrue);
        }
        expect(l.take(c), isFalse, reason: c.name);
        expect(l.of(c), c.maxStacks);
      }
      expect(RiftCard.values.length, greaterThanOrEqualTo(12));
      expect(RiftCard.values.map((c) => c.rarity).toSet(), RiftRarity.values.toSet());
      final l = RiftLoadout();
      for (var i = 0; i < RiftCard.crit.maxStacks; i++) {
        l.take(RiftCard.crit);
      }
      expect(l.crit, lessThanOrEqualTo(0.6));
    });

    test('제시 카드: 서로 다른 3장, 최대로 겹친 카드는 빼고 같은 순위에서 다음 카드', () {
      final p = RiftPlan(20261108);
      final fresh = p.offers(1, RiftLoadout());
      expect(fresh, hasLength(3));
      expect(fresh.toSet(), hasLength(3));
      final maxed = RiftLoadout();
      for (var i = 0; i < fresh.first.maxStacks; i++) {
        maxed.take(fresh.first);
      }
      final next = p.offers(1, maxed);
      expect(next, isNot(contains(fresh.first)));
      expect(next.take(2), fresh.skip(1)); // 나머지 순서는 그대로
      final all = RiftLoadout();
      for (final c in RiftCard.values) {
        for (var i = 0; i < c.maxStacks; i++) {
          all.take(c);
        }
      }
      expect(p.offers(1, all), isEmpty);
    });
  });

  group('점수', () {
    test('격추·조각·돌파·정복·시간 보너스', () {
      expect(RiftScore.kill(PirateKind.scout, 1), 10);
      expect(RiftScore.kill(PirateKind.juggernaut, 9), 540);
      expect(RiftScore.kill(PirateKind.boss, 10), 6000);
      expect(RiftScore.shards(540), 270);
      expect(RiftScore.waveClear(4), 600);
      expect(RiftScore.timeBonus(300), 1800);
      expect(RiftScore.timeBonus(600), 0);
      expect(RiftScore.maxScore, 95700);
      for (final k in PirateKind.values) {
        if (k != PirateKind.boss) expect(RiftScore.base(k), lessThanOrEqualTo(RiftScore.maxRegularBase));
      }
    });

    test('서버 상한(마이그레이션)과 같은 식', () {
      // supabase/migrations/20261108020000_starset_rift.sql starset_rift_max(r)와 같은 값 (파이썬으로 SQL 식을 따로 계산해 맞춤)
      expect([for (var r = 1; r <= 10; r++) RiftScore.maxForWave(r)],
          [450, 1860, 4590, 9000, 15450, 24300, 35910, 50640, 68850, 95700]);
      final sql = File('supabase/migrations/20261108020000_starset_rift.sql').readAsStringSync();
      expect(sql, contains('score between 0 and ${RiftScore.maxScore}'));
      expect(sql, contains('(3 + 2 * n) * 90 * n'));
      expect(sql, contains('16200'));
      expect(RiftPlan.regularCount(1), 5);
      expect(RiftPlan.bossEscorts, 8);
    });

    test('파도별 상한은 단조 증가하고, 어떤 날의 구성도 상한을 넘지 않는다', () {
      for (var r = 2; r <= RiftPlan.waveCount; r++) {
        expect(RiftScore.maxForWave(r), greaterThan(RiftScore.maxForWave(r - 1)));
      }
      for (var d = 0; d < 400; d++) {
        final p = RiftPlan(20260101 + d);
        var s = 0;
        for (var n = 1; n <= RiftPlan.waveCount; n++) {
          final kills = p.wave(n).kinds.fold<int>(0, (a, k) => a + RiftScore.kill(k, n));
          s += kills + RiftScore.shards(kills) + RiftScore.waveClear(n);
          final cap = n == RiftPlan.waveCount
              ? RiftScore.maxForWave(n)
              : RiftScore.maxForWave(n + 1) - RiftScore.maxKillsAt(n + 1);
          expect(s, lessThanOrEqualTo(cap), reason: 'day $d wave $n');
        }
        s += RiftScore.clearBonus + RiftScore.timeBonusSeconds * 10;
        expect(s, lessThanOrEqualTo(RiftScore.maxScore), reason: 'day $d');
      }
    });
  });

  group('보상', () {
    test('하루 처음 3판은 전액, 그다음은 1/4. 젬은 전액 판에서만 (10파 3, 5파 이상 1)', () {
      RiftReward r(int cleared, int before) =>
          RiftRewards.compute(cleared: cleared, rewardMul: 2, sectorMul: 1.5, runsBefore: before);
      expect(r(4, 0).credits, ((40 + 45 * 4) * 2).round());
      expect(r(4, 0).ore, ((6 + 5 * 4) * 1.5).round());
      expect(r(4, 0).gems, 0);
      expect(r(5, 2).gems, 1);
      expect(r(10, 2).gems, 3);
      expect(r(10, 2).full, isTrue);
      final reduced = r(10, 3);
      expect(reduced.full, isFalse);
      expect(reduced.gems, 0);
      expect(reduced.credits, ((40 + 45 * 10) * 2 * 0.25).round());
    });
  });

  group('기록 (Profile.stats)', () {
    test('하루 판 수는 UTC 날짜로, 주간 최고는 ISO 주로 넘어간다', () {
      final stats = <String, int>{};
      var changed = 0;
      final rec = RiftRecords(stats, onChanged: () => changed++);
      final mon = DateTime.utc(2026, 11, 9, 1); // 월요일
      expect(rec.runsToday(mon), 0);
      expect(rec.record(score: 1000, reached: 4, now: mon), isTrue);
      expect(rec.record(score: 700, reached: 3, now: mon), isFalse);
      expect(rec.runsToday(mon), 2);
      expect(rec.fullRunsLeft(mon), 1);
      expect(rec.best, 1000);
      expect(rec.bestWave, 4);
      expect(rec.weekBest(mon), 1000);
      expect(changed, greaterThan(0));
      final tue = mon.add(const Duration(days: 1));
      expect(rec.runsToday(tue), 0);
      // 다음 주: 보내지 못한 지난주 최고는 lastWeek로 남는다
      final nextMon = mon.add(const Duration(days: 7));
      expect(rec.weekBest(nextMon), 0);
      expect(rec.lastWeek, isoWeekKey(mon));
      expect(rec.lastBest, 1000);
      expect(rec.lastWaves, 4);
      expect(rec.totalRuns, 2);
      // 저장 형식: 정수 맵 그대로 (Profile toJson/fromJson 통과)
      final p = Profile()..stats.addAll(stats);
      final back = Profile.fromJson(jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>);
      expect(RiftRecords(back.stats).best, 1000);
      expect(RiftRecords(Profile().stats).best, 0); // 예전 저장 = 기록 없음
    });

    test('보낸 점수는 다시 보내지 않고, 더 높은 기록이 나오면 다시 보낸다', () {
      final rec = RiftRecords(<String, int>{});
      final t = DateTime.utc(2026, 11, 10);
      rec.record(score: 500, reached: 3, now: t);
      expect(rec.weekSent, isFalse);
      rec.markWeekSent(500);
      expect(rec.weekSent, isTrue);
      rec.record(score: 400, reached: 3, now: t);
      expect(rec.weekSent, isTrue);
      rec.record(score: 900, reached: 5, now: t);
      expect(rec.weekSent, isFalse);
    });

    test('해금: 스토리 2단계(해적 3척 격추)를 마치면 열리고 계속 열려 있다', () {
      final rec = RiftRecords(<String, int>{});
      expect(rec.unlockBy(0), isFalse);
      expect(rec.unlockBy(1), isFalse);
      expect(rec.unlockBy(2), isTrue);
      expect(rec.unlockBy(0), isTrue);
    });
  });

  group('아레나 (기존 전투 엔진)', () {
    RiftWorld fresh([int day = 20261108]) => RiftWorld(plan: RiftPlan(day), mainProfile: Profile());
    void step(RiftWorld w, double seconds, [InputState? input]) {
      final i = input ?? InputState();
      for (var t = 0.0; t < seconds; t += 1 / 20) {
        w.update(1 / 20, i);
      }
    }

    test('런 전용 함선: 메인 강화·명예·함선 능력 무시, 외형(함선 종류)만 따른다', () {
      final main = Profile()
        ..shipType = 'nova'
        ..honor = 50
        ..skin = 'gold';
      final w = RiftWorld(plan: RiftPlan(20261108), mainProfile: main);
      expect(w.ship.id, 'nova');
      expect(w.ship.dmgMul, 1);
      expect(w.ship.pierce, 0);
      expect(w.ship.creditMul, 1);
      expect(w.profile.skin, 'gold');
      expect(w.profile.honor, 0);
      expect(identical(w.profile, main), isFalse);
      expect(w.playerDamage, 10);
      expect(w.playerMaxHp, 100);
      expect(w.player.hp, 100);
      expect(w.planets, isEmpty);
      expect(w.asteroids, isEmpty);
      expect((w.player.pos - RiftWorld.arenaCenter).distance, lessThan(RiftWorld.arenaRadius));
    });

    test('카운트다운 → 파도 시작 → 처치하면 점수·조각 → 파도 돌파 → 카드 → 다음 파도', () {
      final w = fresh();
      expect(w.phase, RiftPhase.countdown);
      step(w, RiftWorld.countdownSeconds + 0.1);
      expect(w.phase, RiftPhase.fighting);
      step(w, 6); // 모두 나올 때까지
      expect(w.enemiesLeft, w.currentWave.count);
      final s0 = w.score;
      for (final e in w.pirates) {
        e.hp = 0;
      }
      step(w, 1 / 20);
      expect(w.kills, w.currentWave.count);
      expect(w.score - s0, RiftScore.kill(PirateKind.scout, 1) * w.kills + RiftScore.waveClear(1));
      expect(w.pickups.where((k) => k.kind == PickupKind.ore), isNotEmpty);
      expect(w.phase, RiftPhase.choosing);
      expect(w.offers, hasLength(3));
      expect(w.waveTimes, hasLength(1));
      // 카드: 목록에 없는 카드는 거부, 있는 카드는 적용되고 다음 파도 카운트다운
      final notOffered = RiftCard.values.firstWhere((c) => !w.offers.contains(c));
      expect(w.chooseCard(notOffered), isFalse);
      final pick = w.offers.first;
      expect(w.chooseCard(pick), isTrue);
      expect(w.loadout.of(pick), 1);
      expect(w.wave, 2);
      expect(w.phase, RiftPhase.countdown);
      // 조각을 주우면 점수 (카운트다운 중에도 줍는다)
      final shard = w.pickups.firstWhere((k) => k.kind == PickupKind.ore);
      final before = w.score;
      w.pickups.retainWhere((k) => identical(k, shard));
      shard.pos = w.player.pos;
      step(w, 1 / 20);
      expect(w.score, before + shard.amount);
    });

    test('카드가 엔진 능력치에 반영된다 (피해·연사·다중 사격·치명타·관통·보호막·체력)', () {
      final w = fresh();
      w.loadout
        ..take(RiftCard.damage)
        ..take(RiftCard.rapid)
        ..take(RiftCard.multishot)
        ..take(RiftCard.drone);
      expect(w.playerDamage, closeTo(12.5, 1e-9));
      expect(w.playerFireInterval, closeTo(0.25 * 0.85, 1e-9));
      expect(w.playerShots, 2);
      expect(w.droneLevel, 1);
      // 함선 능력(치명타·관통·보호막)은 카드를 고를 때 다시 만든다
      w.phase = RiftPhase.choosing;
      w.offers = [RiftCard.crit, RiftCard.pierce, RiftCard.guard];
      w.chooseCard(RiftCard.crit);
      expect(w.ship.crit, closeTo(0.12, 1e-9));
      w.phase = RiftPhase.choosing;
      w.offers = [RiftCard.hull, RiftCard.pierce, RiftCard.guard];
      w.player.hp = 10;
      w.chooseCard(RiftCard.hull);
      expect(w.playerMaxHp, 135);
      expect(w.player.hp, 135);
    });

    test('회전 칼날·충격파·흡수는 적에게 피해를 주고 처치를 센다', () {
      final w = fresh();
      for (final c in [RiftCard.blades, RiftCard.blades, RiftCard.blades, RiftCard.shockwave, RiftCard.vampire]) {
        w.loadout.take(c);
      }
      step(w, RiftWorld.countdownSeconds + 0.1);
      step(w, 6);
      // 적을 선장 둘레에 붙여 둔다
      var i = 0;
      for (final e in w.pirates) {
        e.pos = w.player.pos + Offset.fromDirection(i++ * 1.3, RiftLoadout.bladeRadius);
        e.vel = Offset.zero;
      }
      final hp0 = {for (final e in w.pirates) e: e.hp};
      final kills0 = w.kills;
      w.player.invulnerable = 1e9;
      var shocked = false;
      // 충격파 주기(7초)가 한 번은 돌도록 적을 계속 둘레에 붙여 둔다
      for (var t = 0.0; t < 8 && w.phase == RiftPhase.fighting; t += 1 / 20) {
        var j = 0;
        for (final e in w.pirates) {
          e.pos = w.player.pos + Offset.fromDirection(j++ * 1.3, RiftLoadout.bladeRadius);
        }
        w.update(1 / 20, InputState());
        if (w.shockAge < 0.1) shocked = true;
      }
      expect(hp0.keys.where((e) => !w.pirates.contains(e) || e.hp < hp0[e]!), isNotEmpty);
      expect(w.kills, greaterThan(kills0));
      expect(shocked, isTrue);
    });

    test('아레나 밖으로 나가지 못한다', () {
      final w = fresh();
      w.player.pos = RiftWorld.arenaCenter + const Offset(RiftWorld.arenaRadius + 500, 0);
      w.player.vel = const Offset(500, 0);
      step(w, 1 / 20);
      expect((w.player.pos - RiftWorld.arenaCenter).distance, lessThanOrEqualTo(RiftWorld.arenaRadius + 1));
      expect(w.player.vel.dx, lessThanOrEqualTo(0.01));
    });

    test('격추되면 끝, 포기해도 끝 (도달 파도까지 기록)', () {
      final w = fresh();
      step(w, RiftWorld.countdownSeconds + 0.1);
      w.player.hp = 0.1;
      w.player.invulnerable = 0;
      // 적 탄 한 발
      w.bullets.add(Bullet(w.player.pos, Offset.zero, 50, false));
      step(w, 1 / 20);
      expect(w.over, isTrue);
      expect(w.outcome!.reached, 1);
      expect(w.outcome!.cleared, 0);
      expect(w.outcome!.conquered, isFalse);
      expect(w.outcome!.gaveUp, isFalse);
      final g = fresh();
      step(g, 1);
      g.giveUp();
      expect(g.outcome!.gaveUp, isTrue);
      final s = g.score;
      step(g, 5);
      expect(g.score, s); // 끝난 뒤에는 멈춘다
    });

    test('오래 끄는 파도는 균열 붕괴로 끝난다 (서로 고치는 수리선도)', () {
      final w = fresh();
      step(w, RiftWorld.countdownSeconds + 0.1);
      step(w, 6);
      // 선장은 아무것도 하지 않고, 적은 죽지 않게 피해를 막는다
      w.player.invulnerable = 1e9;
      final input = InputState();
      for (var t = 0.0; t < 120 && w.phase == RiftPhase.fighting; t += 1 / 20) {
        w.update(1 / 20, input);
      }
      expect(w.phase, RiftPhase.choosing);
      expect(w.waveTimes.single, lessThan(RiftWorld.collapseAfter + 40));
    });

    test('같은 날·같은 조작이면 결과가 같다 (공정한 순위)', () {
      final a = runRiftBot(20261108), b = runRiftBot(20261108);
      expect(a.outcome.score, b.outcome.score);
      expect(a.outcome.reached, b.outcome.reached);
      expect(a.waveTimes, b.waveTimes);
    });

    test('점수는 도달 파도 상한을 넘지 않는다 (봇 30판)', () {
      for (var d = 0; d < 30; d++) {
        final r = runRiftBot(20261101 + d, skill: RiftSkill.strong);
        expect(r.outcome.score, lessThanOrEqualTo(RiftScore.maxForWave(r.outcome.reached)));
      }
    });
  });

  group('메인 저장 불변', () {
    test('런 전후 메인 world/profile JSON은 보상(크레딧·광석·젬·균열 기록) 외에 같다', () {
      final profile = Profile()
        ..shipType = 'fortress'
        ..honor = 3
        ..gems = 40;
      final main = GameWorld(seed: 3, profile: profile)
        ..credits = 1234
        ..ore = 56;
      final worldBefore = jsonEncode(main.toJson());
      final profileBefore = jsonEncode(profile.toJson());

      final r = runRiftBot(20261108, skill: RiftSkill.strong);
      expect(r.outcome.reached, greaterThan(1));
      // 런은 메인 프로필·월드를 건드리지 않는다 (savedAt은 toJson을 부른 시각)
      String noTime(String j) => j.replaceAll(RegExp(r'"savedAt":\d+'), '');
      expect(noTime(jsonEncode(main.toJson())), noTime(worldBefore));
      expect(jsonEncode(profile.toJson()), profileBefore);

      final now = DateTime.utc(2026, 11, 8, 12);
      final s = r.outcome.settle(profile: profile, main: main, now: now);
      expect(s.mainApplied, isTrue);
      expect(main.credits, 1234 + s.reward.credits);
      expect(main.ore, 56 + s.reward.ore);
      expect(profile.gems, 40 + s.reward.gems);
      expect(RiftRecords(profile.stats).runsToday(now), 1);

      Map<String, dynamic> strip(Map<String, dynamic> j, List<String> keys) =>
          {for (final e in j.entries) if (!keys.contains(e.key)) e.key: e.value};
      final wa = strip(jsonDecode(worldBefore) as Map<String, dynamic>, ['credits', 'ore', 'savedAt']);
      final wb = strip(main.toJson().cast<String, dynamic>(), ['credits', 'ore', 'savedAt']);
      expect(jsonEncode(jsonDecode(jsonEncode(wb))), jsonEncode(wa));
      final pa = strip(jsonDecode(profileBefore) as Map<String, dynamic>, ['gems', 'stats']);
      final pb = strip(jsonDecode(jsonEncode(profile.toJson())) as Map<String, dynamic>, ['gems', 'stats']);
      expect(jsonEncode(pb), jsonEncode(pa));
      final stats = (jsonDecode(jsonEncode(profile.toJson())) as Map)['stats'] as Map;
      expect(stats.keys.where((k) => !(k as String).startsWith('rift')), isEmpty);
    });

    test('하루 4판째부터는 보상이 줄고 젬이 없다', () {
      final profile = Profile();
      final main = GameWorld(seed: 3, profile: profile);
      final now = DateTime.utc(2026, 11, 8, 12);
      const o = RiftOutcome(score: 9000, reached: 10, cleared: 10, conquered: true, seconds: 250, kills: 99, gaveUp: false);
      final full = [for (var i = 0; i < 3; i++) o.settle(profile: profile, main: main, now: now)];
      expect(full.every((s) => s.reward.full && s.reward.gems == 3), isTrue);
      final fourth = o.settle(profile: profile, main: main, now: now);
      expect(fourth.reward.full, isFalse);
      expect(fourth.reward.gems, 0);
      expect(fourth.reward.credits, lessThan(full.first.reward.credits));
      // 다음 UTC 날에는 다시 전액
      expect(o.settle(profile: profile, main: main, now: now.add(const Duration(days: 1))).reward.full, isTrue);
    });

    test('세이브가 없으면 크레딧·광석은 건너뛰고 기록·젬만', () {
      final profile = Profile();
      const o = RiftOutcome(score: 100, reached: 6, cleared: 5, conquered: false, seconds: 100, kills: 10, gaveUp: true);
      final s = o.settle(profile: profile, now: DateTime.utc(2026, 11, 8));
      expect(s.mainApplied, isFalse);
      expect(s.reward.gems, 1);
      expect(profile.gems, 1);
    });
  });

  group('봇 (헤드리스, 기존 전투 엔진)', () {
    test('보통 실력 + 기본 카드 전략: 평균 런 3~5분', () {
      final runs = [for (var d = 0; d < 20; d++) runRiftBot(20261108 + d)];
      final avg = runs.map((r) => r.outcome.seconds).reduce((a, b) => a + b) / runs.length / 60;
      expect(avg, inInclusiveRange(3.0, 5.0));
      // 끝나지 않는 판 없음 (봇 최대 15분)
      expect(runs.every((r) => !r.outcome.gaveUp), isTrue);
    });
  });
}
