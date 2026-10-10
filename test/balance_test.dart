import 'dart:math';


import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/home.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';

import 'support/progression_bot.dart';

/// 간단한 봇: 가까운 적에게 다가가 자동 조준 사격, 체력이 낮으면 기지로 후퇴,
/// 돈이 모이면 업그레이드/정착.
Map<String, num> playBot(int seed, double minutes, {bool smart = true}) {
  final w = GameWorld(seed: seed);
  final input = InputState()
    ..fire = true
    ..autoAim = smart;
  var deaths = 0;
  for (var t = 0.0; t < minutes * 60; t += 1 / 30) {
    final p = w.player;
    if (!p.alive) {
      deaths++;
      w.respawnAtBase();
    }
    Offset target;
    if (smart && p.hp < w.playerMaxHp * 0.35) {
      target = w.stations.first.pos;
    } else if (w.pirates.isNotEmpty) {
      final e = w.pirates.reduce((a, b) =>
          (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b);
      target = (e.pos - p.pos).distance > 300 ? e.pos : p.pos + (p.pos - e.pos);
    } else {
      final a = w.asteroids.reduce((a, b) =>
          (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b);
      target = a.pos;
    }
    final to = target - p.pos;
    input.move = to.distance > 40 ? to.normalized() : Offset.zero;
    w.update(1 / 30, input);
    // 소비
    for (final k in [UpgradeKind.weapon, UpgradeKind.hull, UpgradeKind.engine]) {
      if (w.canAfford(w.upgradeCost(k)) && w.credits > 300) w.upgradeShip(k);
    }
    final pl = w.planets.first;
    if (w.canAfford(w.planetCost(pl))) w.upgradePlanet(pl);
  }
  return {
    'deaths': deaths,
    'kills': w.counter('kills'),
    'threat': w.threat,
    'weapon': w.weaponLevel,
    'credits': w.credits.round(),
    'colony': w.planets.first.colonyLevel,
  };
}

void main() {
  test('봇 10분 플레이 밸런스', () {
    final results = [for (final s in [1, 2, 3]) playBot(s, 10)];
    for (final r in results) {
      // ignore: avoid_print
      print(r);
    }
    final avgDeaths = results.map((r) => r['deaths']!).reduce((a, b) => a + b) / results.length;
    final avgKills = results.map((r) => r['kills']!).reduce((a, b) => a + b) / results.length;
    expect(avgKills, greaterThan(20), reason: '10분에 해적을 충분히 잡을 수 있어야 함');
    expect(avgDeaths, lessThan(8), reason: '10분에 너무 자주 죽으면 안 됨');
  });

  test('덜 똑똑한 봇(후퇴 안 함, 전방 조준만)', () {
    for (final s in [1, 2, 3]) {
      // ignore: avoid_print
      print(playBot(s, 10, smart: false));
    }
  });

  // ---------- 진행·과금 밸런스 (support/progression_bot.dart 봇) ----------
  // 자세한 측정은 tool/balance_sim_test.dart (여러 시드, 6개 항성계, 유료 변형)

  group('진행 밸런스', () {
    test('첫 항성계: 현금·오프라인 없이 이어서 플레이해도 15~30분, 사망 2회 이하, 정체 없음', () {
      for (final seed in [1, 2, 3]) {
        final r = ProgressionBot(seed, sessionMinutes: 60, useOffline: false, dailyGems: false)
            .run(lastSector: 0, maxDays: 1);
        final s1 = r.logs.first;
        // ignore: avoid_print
        print(s1);
        expect(s1.done, isTrue, reason: '첫 항성계는 한 시간 안에 끝나야 함');
        // 봇은 사람보다 효율적이라 사람 기준 20~40분 ≈ 봇 15~30분
        expect(s1.playMinutes, inInclusiveRange(15, 30));
        expect(s1.deaths, lessThanOrEqualTo(2));
        expect(s1.stallSessions, 0);
      }
    });

    test('항성계가 뒤로 갈수록 느려지고, 패스·크레딧 팩이 3·4번째 항성계를 30% 이상 당긴다', () {
      // 하루 3번 12.5분 세션 + 세션 사이 오프라인(광고 2배) + 하루치 무료 젬
      BotRun play({bool pass = false, bool packs = false}) =>
          ProgressionBot(1, paying: pass || packs, buyPass: pass, payWithPacks: packs)
              .run(lastSector: 3, maxDays: 20);
      final free = play();
      for (final l in free.logs) {
        // ignore: avoid_print
        print(l);
      }
      expect(free.logs.length, 4);
      expect(free.logs.every((l) => l.done), isTrue, reason: '무료로도 4번째 항성계까지 끝나야 함');
      expect(free.logs.every((l) => l.stallSessions == 0), isTrue, reason: '살 게 없어 멈추는 세션 없음');
      double daysIn(BotRun r, int i) => r.logs[i].days - (i == 0 ? 0 : r.logs[i - 1].days);
      // 첫 항성계는 반나절 안, 두 번째는 하루쯤, 그 뒤로 점점 길어진다
      expect(daysIn(free, 0), lessThan(0.6));
      expect(daysIn(free, 1), inInclusiveRange(0.8, 2.5));
      expect(daysIn(free, 2), greaterThan(daysIn(free, 0)));
      expect(daysIn(free, 3), greaterThan(daysIn(free, 2)));
      // 3·4번째 항성계(유료 구매 시점부터) 걸린 날
      double window(BotRun r) => r.logs[3].days - r.logs[1].days;
      final pass = play(pass: true);
      final packs = play(packs: true);
      // ignore: avoid_print
      print('S3~S4 일수: 무료 ${window(free).toStringAsFixed(2)} 패스 ${window(pass).toStringAsFixed(2)} '
          '팩 ${window(packs).toStringAsFixed(2)}');
      expect(window(pass), lessThan(window(free) * 0.7));
      expect(window(packs), lessThan(window(free) * 0.7));
    }, timeout: const Timeout(Duration(minutes: 5)));

    test('본거지 안전 구역에 숨어 레이저로 무한 사냥해도 생산 수입의 15%도 안 된다', () {
      for (final s in [0, 1, 2, 3]) {
        final w = worldAtSector(7, s);
        final r = baseFarm(w, 20, shoot: false);
        // ignore: avoid_print
        print('S${s + 1} $r');
        // 레이저 격추 현상금은 25%만, 본거지는 버티다 정지된다 (식민지 포탑·습격 방어 보상 포함 측정)
        expect(r['bountyPerMin']!, lessThan(r['incomePerMin']! * 0.15));
      }
    });

    test('행성 수는 항성계마다 늘고, 모든 항성계에서 궤도가 겹치지 않는다', () {
      expect(GameWorld.planetCountFor(0), GameWorld.firstSystemPlanets);
      for (var s = 1; s < 12; s++) {
        expect(GameWorld.planetCountFor(s), greaterThanOrEqualTo(GameWorld.planetCountFor(s - 1)));
        expect(GameWorld.planetCountFor(s), lessThanOrEqualTo(GameWorld.maxPlanets));
      }
      final w = GameWorld(seed: 51)..counters['maxSector'] = 99;
      for (var s = 0; s < 8; s++) {
        if (s > 0) w.warp(w.gates.firstWhere((g) => g.forward));
        expect(w.sector, s);
        expect(w.planets.length, GameWorld.planetCountFor(s));
        for (var t = 0.0; t < 2400; t += 20) {
          for (final p in w.planets) {
            p.placeOnOrbit(t);
            expect(p.pos.dx.abs() + p.radius, lessThan(GameWorld.worldHalf));
            expect(p.pos.dy.abs() + p.radius, lessThan(GameWorld.worldHalf));
            expect((p.pos - GameWorld.homePos).distance, greaterThan(p.radius + 150));
          }
          for (var i = 0; i < w.planets.length; i++) {
            for (var j = i + 1; j < w.planets.length; j++) {
              final a = w.planets[i], b = w.planets[j];
              expect((a.pos - b.pos).distance, greaterThan(a.radius + b.radius),
                  reason: 'S${s + 1} ${a.name}-${b.name} t=$t');
            }
          }
        }
      }
    });

    test('발전 비용은 보상보다 빨리 커진다 (뒤 항성계가 쉬워지지 않음)', () {
      double devCost(int s) {
        final n = GameWorld.planetCountFor(s);
        var c = 0.0;
        for (var l = 0; l < GameWorld.devLevelCap; l++) {
          c += Planet.settleCost * pow(Planet.levelCostGrowth, l);
        }
        return c * n * GameWorld.costMulAt(s);
      }

      double rewardAt(int s) =>
          (1 + s * GameWorld.sectorIncomeStep) * pow(GameWorld.costMulAt(s), GameWorld.rewardCostExponent);
      for (var s = 1; s < 8; s++) {
        expect(devCost(s) / devCost(s - 1), greaterThan(rewardAt(s) / rewardAt(s - 1)));
      }
    });

    test('젬 환전 순환 없음: 상인에게 젬을 사는 값이 크레딧 팩보다 비싸다', () {
      final w = GameWorld(seed: 3)..counters['maxSector'] = 99;
      for (var s = 0; s < 8; s++) {
        if (s > 0) w.warp(w.gates.firstWhere((g) => g.forward));
        // ⭐20어치를 상인에게서 사는 값 > ⭐20 크레딧 팩
        expect(w.merchantGemPrice * GameWorld.creditPackGems / 5, greaterThan(w.creditPackAmount));
      }
    });

    test('오프라인 수입: 2시간(광고 2배)이 한 세션(12.5분) 생산의 3배 이하, 패스 8시간은 2배 미만', () {
      final w = GameWorld(seed: 4);
      for (final p in w.planets) {
        p.colonyLevel = 3;
      }
      final now = DateTime(2026, 3, 1, 12);
      w.savedAt = now.subtract(const Duration(hours: 10));
      // 생산 몇 초어치인지로 비교 (패스는 생산 자체도 +25%)
      final free = w.offlineEarnings(now).$2 * 2 / w.creditIncome;
      expect(free, lessThanOrEqualTo(12.5 * 60 * 3));
      w.profile.premium = true;
      final premium = w.offlineEarnings(now).$2 * 2 / w.creditIncome;
      expect(premium, greaterThan(free));
      expect(premium, lessThan(free * 2));
      expect(HomePlanet().offlineEfficiency, HomePlanet.offlineBaseEfficiency);
    });

    test('광고 부활은 하루 3번, 패스는 무제한', () {
      final p = Profile();
      final day = DateTime(2026, 5, 1, 10);
      for (var i = 0; i < Profile.adRevivesPerDay; i++) {
        expect(p.useAdRevive(day), isTrue);
      }
      expect(p.adRevivesLeft(day), 0);
      expect(p.useAdRevive(day), isFalse);
      expect(p.adRevivesLeft(day.add(const Duration(days: 1))), Profile.adRevivesPerDay);
      final p2 = Profile.fromJson(p.toJson());
      expect(p2.adRevivesLeft(day), 0, reason: '저장해도 횟수 유지');
      p.premium = true;
      expect(p.useAdRevive(day), isTrue);
    });

    test('내 행성 비용은 가장 멀리 간 항성계를 따른다 (첫 항성계로 돌아가도 싸지지 않음)', () {
      final w = GameWorld(seed: 6)..counters['maxSector'] = 2;
      w.warp(w.gates.firstWhere((g) => g.forward));
      w.warp(w.gates.firstWhere((g) => g.forward));
      final far = w.homeCostMul;
      expect(far, GameWorld.costMulAt(2));
      w.warp(w.gates.firstWhere((g) => !g.forward));
      expect(w.homeCostMul, far);
      expect(w.home.buildCost(BuildingType.farm, w.homeCostMul).$1,
          greaterThan(w.home.buildCost(BuildingType.farm).$1));
    });
  });
}
