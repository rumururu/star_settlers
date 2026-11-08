import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/attendance.dart';
import 'package:star_settlers/game/cosmetics.dart';
import 'package:star_settlers/game/crew.dart';
import 'package:star_settlers/game/expedition.dart';
import 'package:star_settlers/game/game_telemetry.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/services/notifications.dart';

/// TASK 004: 7일 출석 달력 · 내일 미리보기 · 승무원 원정
void main() {
  final events = <(TelemetryEvent, int?)>[];
  setUp(() {
    events.clear();
    GameTelemetry.sink = (e, v) => events.add((e, v));
  });
  tearDown(() => GameTelemetry.sink = null);

  DateTime day(int d, [int h = 10]) => DateTime(2026, 11, d, h);

  group('출석 달력 칸', () {
    test('연속이면 칸이 하나씩, 7일 뒤에는 1칸으로 돌아간다', () {
      final p = Profile();
      final cells = <int>[];
      for (var d = 1; d <= 9; d++) {
        expect(Attendance.stateOf(Attendance.cell(Attendance.streakToday(p, day(d))), p, day(d)), CellState.today);
        cells.add(Attendance.claim(p, day(d))!.$2);
        expect(Attendance.claimable(p, day(d)), isFalse, reason: '하루 한 번');
      }
      expect(cells, [1, 2, 3, 4, 5, 6, 7, 1, 2]);
    });

    test('하루 빠지면 1칸부터', () {
      final p = Profile();
      Attendance.claim(p, day(1));
      Attendance.claim(p, day(2));
      Attendance.claim(p, day(3));
      expect(Attendance.streakToday(p, day(5)), 1);
      expect(Attendance.claim(p, day(5))!.$2, 1);
    });

    test('시계를 되돌리면 받을 수 없다 (같은 날·과거)', () {
      final p = Profile();
      Attendance.claim(p, day(5));
      expect(Attendance.claimable(p, day(5, 23)), isFalse);
      expect(Attendance.claimable(p, day(3)), isFalse);
      expect(Attendance.claim(p, day(4)), isNull);
      expect(Attendance.claimable(p, day(6)), isTrue);
    });

    test('지난 칸 · 오늘 · 받은 오늘 · 앞으로', () {
      final p = Profile();
      Attendance.claim(p, day(1));
      Attendance.claim(p, day(2));
      final now = day(3);
      expect([for (var i = 1; i <= 7; i++) Attendance.stateOf(i, p, now)], [
        CellState.past,
        CellState.past,
        CellState.today,
        CellState.future,
        CellState.future,
        CellState.future,
        CellState.future,
      ]);
      Attendance.claim(p, now);
      expect(Attendance.stateOf(3, p, now), CellState.claimedToday);
    });

    test('칸 보상: 2일 광석 · 3일 ★2 · 5일 크레딧 · 7일 스킨(한 번만, 그 뒤 ★3)', () {
      final p = Profile();
      for (var d = 1; d <= 7; d++) {
        Attendance.claim(p, day(d));
      }
      expect(p.pendingOre, Attendance.oreAmount);
      expect(p.pendingCrew2, 1);
      expect(p.pendingCredits, Attendance.creditAmount);
      expect(p.ownedSkins, contains(attendanceSkinId));
      expect(p.pendingStarCrew, 0);
      for (var d = 8; d <= 14; d++) {
        Attendance.claim(p, day(d));
      }
      expect(p.pendingStarCrew, 1, reason: '두 번째 7일째는 스킨 대신 ★3');
      expect(p.ownedSkins.where((s) => s == attendanceSkinId), hasLength(1));
      expect(p.pendingCrew2, 2);
    });

    test('젬은 서버 표와 같다 (출석 젬 액수는 바꾸지 않는다)', () {
      expect([for (var i = 1; i <= 7; i++) Attendance.gemsFor(i)], loginRewards);
      final p = Profile();
      final (gems, _, _) = Attendance.claim(p, day(1))!;
      expect(gems, loginRewards.first);
      expect(events.where((e) => e.$1 == TelemetryEvent.loginClaim), hasLength(1));
    });

    test('달력 보상 저장·복원', () {
      final p = Profile();
      for (var d = 1; d <= 7; d++) {
        Attendance.claim(p, day(d));
      }
      final back = Profile.fromJson(p.toJson());
      expect((back.pendingOre, back.pendingCredits, back.pendingCrew2), (p.pendingOre, p.pendingCredits, 1));
      expect(back.ownedSkins, contains(attendanceSkinId));
      // 예전 저장(값 없음)은 0
      final old = Profile.fromJson(Profile().toJson()..remove('pendingOre')..remove('pendingCrew2'));
      expect((old.pendingOre, old.pendingCrew2), (0, 0));
    });

    test('월드에 들어갈 때 광석·크레딧(보상 배율)·★2 승무원 지급', () {
      final p = Profile()
        ..pendingOre = 100
        ..pendingCredits = 1000
        ..pendingCrew2 = 1;
      final w = GameWorld(seed: 1, profile: p);
      final ore0 = w.ore, cr0 = w.credits;
      w.deliverCalendarRewards();
      expect(w.ore - ore0, closeTo(100 * w.baseRewardMul, 0.01));
      expect(w.credits - cr0, closeTo(1000 * w.baseRewardMul, 0.01));
      expect(w.roster.single.rarity, 2);
      expect(w.crewReveal, same(w.roster.single));
      expect((p.pendingOre, p.pendingCredits, p.pendingCrew2), (0, 0, 0));
    });

    test('출석 전용 스킨: 상점 판매 없음, 은하 그림 색 회전', () {
      expect(attendanceSkin.price, 0);
      expect(attendanceSkin.exclusive, 'attendance');
      expect(shipSkins.map((s) => s.id), isNot(contains(attendanceSkinId)), reason: '판매 목록 밖');
      expect(skinById(attendanceSkinId).sprite, 'galaxy');
      expect(skinById(attendanceSkinId).hue, isNotNull);
    });
  });

  group('게임 안 달력 표시 조건', () {
    test('처음 받는 플레이어: 해적 단계(스토리 2단계)를 마친 뒤에만', () {
      final p = Profile();
      expect(Attendance.showInGame(p, day(1), storyIndex: 0), isFalse);
      expect(Attendance.showInGame(p, day(1), storyIndex: 1), isFalse);
      expect(Attendance.showInGame(p, day(1), storyIndex: 2), isTrue);
    });

    test('받아 본 적 있으면 게임 진입 때 바로, 타이틀에서 오늘 받았으면 안 뜬다', () {
      final p = Profile();
      Attendance.claim(p, day(1));
      expect(Attendance.showInGame(p, day(2), storyIndex: 0), isTrue);
      Attendance.claim(p, day(2)); // 타이틀에서 받음
      expect(Attendance.showInGame(p, day(2), storyIndex: 9), isFalse);
    });

    test('내일 미리보기: 오늘 받기 전이면 오늘 다음 칸, 받은 뒤에도 같은 칸', () {
      final p = Profile();
      Attendance.claim(p, day(1));
      expect(Attendance.cell(Attendance.streakTomorrow(p, day(2))), 3);
      Attendance.claim(p, day(2));
      expect(Attendance.cell(Attendance.streakTomorrow(p, day(2))), 3);
      // 하루 빠졌으면 오늘 1칸 → 내일 2칸
      expect(Attendance.cell(Attendance.streakTomorrow(p, day(5))), 2);
    });

    test('다음 날 알림 시각: 20시간 뒤, 다음 날 오전 9시보다 이르지 않게', () {
      expect(NotificationService.tomorrowRewardAt(DateTime(2026, 11, 8, 1)), DateTime(2026, 11, 9, 9));
      expect(NotificationService.tomorrowRewardAt(DateTime(2026, 11, 8, 20)), DateTime(2026, 11, 9, 16));
    });
  });

  group('승무원 원정', () {
    GameWorld world({bool premium = false}) {
      final w = GameWorld(seed: 7, profile: Profile()..premium = premium);
      for (var i = 0; i < 4; i++) {
        w.grantCrew(2).assigned = false; // 새 승무원은 자리가 있으면 자동 배치된다
      }
      return w;
    }

    final t0 = DateTime(2026, 11, 8, 12);

    test('동시 2개 (사령관 패스 3개), 배치된·원정 중인 승무원은 못 보낸다', () {
      final w = world();
      final c = w.roster;
      expect(w.startExpedition(c[0], 1, t0), isNotNull);
      expect(w.startExpedition(c[0], 1, t0), isNull, reason: '이미 원정 중');
      expect(w.startExpedition(c[1], 4, t0), isNotNull);
      expect(w.startExpedition(c[2], 8, t0), isNull, reason: '슬롯 2개');
      final p = world(premium: true);
      for (var i = 0; i < 3; i++) {
        expect(p.startExpedition(p.roster[i], 1, t0), isNotNull);
      }
      expect(p.startExpedition(p.roster[3], 1, t0), isNull);
      final a = world();
      a.toggleAssign(a.roster[0]);
      expect(a.startExpedition(a.roster[0], 1, t0), isNull, reason: '배치된 승무원');
      expect(a.startExpedition(a.roster[1], 2, t0), isNull, reason: '1·4·8시간만');
      expect(events.where((e) => e.$1 == TelemetryEvent.expeditionStart).map((e) => e.$2), [1, 4, 1, 1, 1]);
    });

    test('원정 중에는 배치·해고 불가', () {
      final w = world();
      final c = w.roster.first;
      w.startExpedition(c, 1, t0);
      expect(w.toggleAssign(c), isFalse);
      expect(c.assigned, isFalse);
      w.dismissCrew(c);
      expect(w.roster, contains(c));
      expect(w.idleCrew, isNot(contains(c)));
    });

    test('실제 시간으로 진행: 끝나기 전에는 못 받고, 끝나면 보상 + 경험치', () {
      final w = world();
      final c = w.roster.first;
      final e = w.startExpedition(c, 4, t0)!;
      expect(e.remaining(w.expeditionClock.now(t0.add(const Duration(hours: 3)))), const Duration(hours: 1));
      expect(w.claimExpedition(e, t0.add(const Duration(hours: 3, minutes: 59))), isNull);
      final cr0 = w.credits, ore0 = w.ore;
      final r = w.claimExpedition(e, t0.add(const Duration(hours: 4)))!;
      expect(w.credits - cr0, r.credits);
      expect(w.ore - ore0, r.ore);
      expect(r.xp, Expeditions.xpFor(4));
      expect(c.level, 2, reason: 'Lv.1 → 2 에 경험치 3');
      expect(w.expeditions, isEmpty);
      expect(w.claimExpedition(e, t0.add(const Duration(hours: 9))), isNull, reason: '두 번 받기 금지');
      expect(events.where((e) => e.$1 == TelemetryEvent.expeditionClaim).single.$2, 4);
    });

    test('보상 범위: 시간이 길수록 많고, 젬·★3은 8시간만', () {
      final w = world();
      final rng = <int, List<Expedition>>{};
      for (final h in Expeditions.durations) {
        rng[h] = [
          for (var i = 0; i < 300; i++)
            Expeditions.plan(
              crewId: 1,
              rarity: 2,
              hours: h,
              startMs: 0,
              creditIncome: w.creditIncome,
              oreIncome: w.oreIncome,
              sectorMul: w.sectorMul,
              rng: Random(i),
            ),
        ];
      }
      expect(rng[1]!.first.credits, lessThan(rng[4]!.first.credits));
      expect(rng[4]!.first.credits, lessThan(rng[8]!.first.credits));
      for (final h in [1, 4]) {
        expect(rng[h]!.every((e) => e.gems == 0 && !e.rareCrew), isTrue);
      }
      final gemRate = rng[8]!.where((e) => e.gems > 0).length / 300;
      final crewRate = rng[8]!.where((e) => e.rareCrew).length / 300;
      expect(gemRate, inInclusiveRange(0.2, 0.4));
      expect(crewRate, inInclusiveRange(0.04, 0.17));
      expect(rng[8]!.where((e) => e.gems > 0).every((e) => e.gems == Expeditions.gemAmount), isTrue);
      // 생산이 클수록 많이 (현재 항성계 배율)
      final rich = Expeditions.plan(
        crewId: 1,
        rarity: 2,
        hours: 8,
        startMs: 0,
        creditIncome: 100,
        oreIncome: 10,
        sectorMul: 1,
        rng: Random(1),
      );
      expect(rich.credits, greaterThan(rng[8]!.first.credits));
    });

    test('8시간 행운: 젬은 플레이 젬(하루 상한)으로, 희귀 승무원은 카드 공개', () {
      final earned = <(String, int)>[];
      Profile.onEarn = (s, k, n) => earned.add((s, n));
      addTearDown(() => Profile.onEarn = null);
      final w = world();
      final c = w.roster.first;
      final e = Expedition(
        crewId: c.id,
        hours: 8,
        startMs: w.expeditionClock.now(t0),
        credits: 10,
        ore: 10,
        xp: 6,
        gems: 5,
        rareCrew: true,
      );
      w.expeditions.add(e);
      final r = w.claimExpedition(e, t0.add(const Duration(hours: 8)))!;
      expect(r.gems, 5);
      expect(earned, [('play', 5)]);
      expect(r.rareCrew, isTrue);
      expect(w.crewReveal?.rarity, 3);
    });

    test('저장·복원: 원정과 시계가 남고, 앱을 꺼도 시간이 흐른다', () {
      final w = world();
      final c = w.roster.first;
      w.startExpedition(c, 1, t0);
      final back = GameWorld.fromJson(w.toJson(), w.profile);
      expect(back.expeditions.single.crewId, c.id);
      expect(back.crewAway(back.roster.firstWhere((m) => m.id == c.id)), isTrue);
      expect(back.claimExpedition(back.expeditions.single, t0.add(const Duration(hours: 1))), isNotNull);
      // 예전 저장(원정 없음)
      final old = GameWorld.fromJson(w.toJson()..remove('expeditions')..remove('expClock'), w.profile);
      expect(old.expeditions, isEmpty);
    });

    test('시계 되돌리기: 진행이 줄지 않고, 되돌린 뒤 보낸 원정도 앞선 시각부터 센다', () {
      final w = world();
      final c = w.roster.first;
      final e = w.startExpedition(c, 1, t0)!;
      w.expeditionClock.now(t0.add(const Duration(minutes: 50)));
      // 시계를 어제로
      final back = t0.subtract(const Duration(days: 1));
      expect(e.remaining(w.expeditionClock.now(back)), const Duration(minutes: 10));
      final e2 = w.startExpedition(w.roster[1], 1, back)!;
      expect(e2.startMs, t0.add(const Duration(minutes: 50)).millisecondsSinceEpoch);
    });

    test('승무원 경험치: 최고 레벨이면 쌓지 않는다, 저장된다', () {
      final c = CrewMember(id: 1, name: '뭉치', role: CrewRole.gunner, rarity: 2, lookSeed: 1);
      expect(c.gainXp(2), 0);
      expect(c.gainXp(1), 1);
      expect((c.level, c.xp), (2, 0));
      expect(c.gainXp(100), CrewMember.maxLevel - 2);
      expect((c.level, c.xp), (CrewMember.maxLevel, 0));
      final j = CrewMember(id: 2, name: '코코', role: CrewRole.miner, rarity: 1, lookSeed: 1, xp: 2).toJson();
      expect(CrewMember.fromJson(j).xp, 2);
      expect(CrewMember.fromJson(j..remove('xp')).xp, 0);
    });
  });
}
