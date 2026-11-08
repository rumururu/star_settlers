import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/game_telemetry.dart';
import 'package:star_settlers/game/missions.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/next_goal.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';

import 'support/progression_bot.dart';

/// 시작 함선(강화 0)으로 미니 두목만 쫓아 싸운다. 체력 35% 아래면 본거지로 물러나 90%까지 수리.
/// 반환: (처치까지 걸린 초 — 못 잡으면 null, 격추 횟수)
(double?, int) fightMiniBoss(GameWorld w, {double limit = 180}) {
  final input = InputState()
    ..fire = true
    ..autoAim = true;
  var deaths = 0;
  var retreat = false;
  const dt = 1 / 20;
  for (var t = 0.0; t < limit; t += dt) {
    final p = w.player;
    if (!p.alive) {
      deaths++;
      w.respawnAtBase();
    }
    if (p.hp < w.playerMaxHp * 0.35) retreat = true;
    if (retreat && p.hp >= w.playerMaxHp * 0.9) retreat = false;
    final boss = w.pirates.where((e) => e.miniBoss).firstOrNull;
    var goal = w.homeBase.pos;
    if (!retreat && boss != null) {
      final d = (boss.pos - p.pos).distance;
      goal = d > 300 ? boss.pos : p.pos + (p.pos - boss.pos);
    }
    final to = goal - p.pos;
    input.move = to.distance > 30 ? to.normalized() : Offset.zero;
    w.update(dt, input);
    if (w.counter(GameWorld.miniBossKey) == 2) return (t, deaths);
  }
  return (null, deaths);
}

/// 0.5초 판정이 한 번 돌 만큼 (update는 한 번에 0.05초까지만 진행한다)
void tick(GameWorld w) {
  for (var i = 0; i < 12; i++) {
    w.update(0.05, InputState());
  }
}

void main() {
  final events = <(TelemetryEvent, int?)>[];
  setUp(() {
    events.clear();
    GameTelemetry.sink = (e, v) => events.add((e, v));
  });
  tearDown(() => GameTelemetry.sink = null);

  group('★3 승무원 확정 지급', () {
    test('해적 단계를 마치면 바로, 한 번만', () {
      final w = GameWorld(seed: 3);
      w.storyIndex = 2; // 소행성·해적 단계 끝
      tick(w);
      expect(w.roster.where((c) => c.rarity == 3), hasLength(1));
      expect(w.roster.single.assigned, isTrue, reason: '자동 배치');
      expect(w.crewReveal, same(w.roster.single));
      for (var i = 0; i < 10; i++) {
        tick(w);
      }
      expect(w.roster, hasLength(1), reason: '중복 지급 금지');
    });

    test('해적 단계가 늦어도 3분이면 준다', () {
      final w = GameWorld(seed: 3);
      w.totalTime = GameWorld.star3GiftSeconds - 1;
      w.update(0.05, InputState());
      expect(w.roster, isEmpty);
      tick(w);
      tick(w);
      expect(w.roster.single.rarity, 3);
    });

    test('저장·불러오기 뒤에도 다시 주지 않는다', () {
      final w = GameWorld(seed: 3)..storyIndex = 2;
      tick(w);
      final back = GameWorld.fromJson(w.toJson(), w.profile);
      tick(back);
      expect(back.roster, hasLength(1));
    });

    test('튜토리얼을 마친 프로필(환생한 새 월드)에는 주지 않는다', () {
      final w = GameWorld(seed: 3, profile: Profile()..tutorialDone = true);
      w.totalTime = 600;
      tick(w);
      expect(w.roster, isEmpty);
    });
  });

  group('미니 두목 해적 부두목', () {
    test('첫 정착 직후 나온다 (4분 전이라도)', () {
      final w = GameWorld(seed: 5)..credits = 99999;
      tick(w);
      expect(w.pirates.where((e) => e.miniBoss), isEmpty);
      w.upgradePlanet(w.planets.first);
      tick(w);
      final boss = w.pirates.where((e) => e.miniBoss).single;
      expect(boss.name, isNotNull);
      expect(w.goal.kind, GoalKind.miniBoss);
    });

    test('정착이 늦어도 4분이면 나오고, 첫 항성계에서 한 번뿐이다', () {
      final w = GameWorld(seed: 5)..totalTime = GameWorld.miniBossSeconds;
      tick(w);
      expect(w.pirates.where((e) => e.miniBoss), hasLength(1));
      tick(w);
      expect(w.pirates.where((e) => e.miniBoss), hasLength(1));
    });

    for (final seed in [1, 2, 3, 4, 5, 6, 7, 8]) {
      test('시작 함선(강화 0)으로 잡는다 — 보상: 무기 +1, mini_boss_kill (seed $seed)', () {
        final w = GameWorld(seed: seed)..totalTime = GameWorld.miniBossSeconds;
        w.storyIndex = 2;
        expect(w.level(UpgradeKind.weapon), 0);
        tick(w);
        final credits0 = w.credits;
        final (time, deaths) = fightMiniBoss(w);
        expect(time, isNotNull, reason: '3분 안에 처치');
        expect(time!, lessThan(90), reason: '시작 함선으로 1분 반 안');
        expect(deaths, 0);
        expect(w.level(UpgradeKind.weapon), 1);
        expect(w.credits, greaterThan(credits0 + GameWorld.miniBossCredits - 1));
        expect(events.where((e) => e.$1 == TelemetryEvent.miniBossKill), hasLength(1));
        // 다시 나오지 않는다
        w.totalTime += 600;
        tick(w);
        expect(w.pirates.where((e) => e.miniBoss), isEmpty);
      });
    }

    test('저장으로 사라져도(해적은 저장되지 않음) 다시 나온다', () {
      final w = GameWorld(seed: 5)..totalTime = GameWorld.miniBossSeconds;
      tick(w);
      final back = GameWorld.fromJson(w.toJson(), w.profile);
      expect(back.pirates.where((e) => e.miniBoss), isEmpty);
      tick(back);
      tick(back);
      expect(back.pirates.where((e) => e.miniBoss), hasLength(1));
    });
  });

  group('다음 목표', () {
    test('새 게임: 스토리 목표와 진행도', () {
      final w = GameWorld(seed: 1);
      final g = nextGoal(w);
      expect(g.kind, GoalKind.story);
      expect(g.text, storySteps.first.title);
      expect((g.value, g.target), (0, 3));
      expect(g.target2, isNotNull, reason: '가장 가까운 소행성');
    });

    test('정착 단계: 모자란 크레딧을 보여 준다', () {
      final w = GameWorld(seed: 1)..storyIndex = 2;
      w.credits = 0;
      final g = nextGoal(w);
      expect(g.kind, GoalKind.story);
      expect(g.text, contains('💰'));
      expect(g.hasProgress, isTrue);
      w.credits = 99999;
      expect(nextGoal(w).text, isNot(contains('💰')));
    });

    test('튜토리얼 뒤: 승무원 배치 → 정착 → 안정화 → 레벨업 → 건물 → 워프 순', () {
      final w = GameWorld(seed: 1)..storyIndex = storySteps.length;
      w.credits = 0;
      w.ore = 0;
      expect(nextGoal(w).kind, GoalKind.develop);
      final c = w.grantCrew(2)..assigned = false;
      expect(nextGoal(w).kind, GoalKind.crewAssign);
      w.toggleAssign(c);
      w.credits = 1e9;
      w.ore = 1e9;
      final settle = nextGoal(w);
      expect(settle.kind, GoalKind.settle);
      w.upgradePlanet(w.planets[settle.subject]);
      expect(settle.isDone(w), isTrue);
      final stab = nextGoal(w);
      expect(stab.kind, GoalKind.settle, reason: '살 수 있는 다른 행성 정착이 먼저');
      for (final p in w.planets) {
        while (p.colonyLevel == 0) {
          w.upgradePlanet(p);
        }
      }
      expect(nextGoal(w).kind, GoalKind.stabilizer);
      for (final p in w.planets) {
        w.buildColony(p, ColonyBuilding.stabilizer);
      }
      expect(nextGoal(w).kind, GoalKind.colonyLevel);
      for (final p in w.planets) {
        for (var i = 0; i < GameWorld.devLevelCap; i++) {
          w.upgradePlanet(p);
          w.buildColony(p, ColonyBuilding.stabilizer);
        }
      }
      expect(w.development, 1);
      expect(nextGoal(w).kind, GoalKind.building);
      w.credits = 0;
      w.ore = 0;
      expect(nextGoal(w).kind, GoalKind.warp);
    });

    test('목표를 이루면 goal_done(목표 번호)과 완료 연출', () {
      final w = GameWorld(seed: 1)..storyIndex = storySteps.length;
      w.credits = 1e9;
      w.ore = 1e9;
      tick(w);
      final g = w.goal;
      expect(g.kind, GoalKind.settle);
      w.upgradePlanet(w.planets[g.subject]);
      tick(w);
      expect(w.goalDone?.kind, GoalKind.settle);
      expect(w.goalFlash, greaterThan(0));
      expect(
        events.where((e) => e.$1 == TelemetryEvent.goalDone).map((e) => e.$2),
        [GoalKind.settle.index],
      );
    });

    test('목표 칩을 누르면 안내 화살표가 그 목표를 가리킨다', () {
      final w = GameWorld(seed: 1)..storyIndex = 1; // 해적 단계: 원래 화살표 없음
      expect(w.storyTarget, isNull);
      w.pirates.add(Pirate(PirateKind.scout, w.player.pos + const Offset(500, 0), 10));
      w.pingGoal();
      expect(w.storyTarget, isNotNull);
    });

    test('봇 0~30분: 목표가 비어 있는 프레임 0, ★3 ≤ 3분, 미니 두목 ≤ 4분', () {
      for (final seed in [1, 2, 3]) {
        final bot = ProgressionBot(
          seed,
          sessionMinutes: 30,
          sessionsPerDay: 1,
          useOffline: false,
          dailyGems: false,
        );
        var empty = 0;
        var frames = 0;
        double? star3, boss;
        bot.onTick = (w) {
          frames++;
          final g = nextGoal(w);
          if (g.text.trim().isEmpty) empty++;
          if (star3 == null && w.roster.any((c) => c.rarity >= 3)) star3 = w.totalTime;
          if (boss == null && w.pirates.any((e) => e.miniBoss)) boss = w.totalTime;
        };
        bot.run(maxDays: 1);
        expect(frames, greaterThan(30 * 60 * 19));
        expect(empty, 0, reason: 'seed $seed');
        expect(star3, isNotNull);
        expect(star3!, lessThanOrEqualTo(180), reason: 'seed $seed ★3');
        expect(boss, isNotNull);
        expect(boss!, lessThanOrEqualTo(240.5), reason: 'seed $seed 미니 두목');
      }
    });
  });
}
