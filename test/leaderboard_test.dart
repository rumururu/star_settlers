import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/l10n/l.dart';
import 'package:star_settlers/services/leaderboard.dart';
import 'package:star_settlers/ui/leaderboard_screen.dart';

/// 서버(supabase/migrations/20261011000000_starset_leaderboard.sql)의 정규식과 같은 것
final serverNicknameRegex = RegExp(r'^([0-9]|[1-3][0-9])-([0-9]|[1-3][0-9])-[0-9]{4}$');

void main() {
  group('NicknameCode', () {
    test('index ranges match the server', () {
      expect(NicknameCode.adjectiveCount, 40);
      expect(NicknameCode.animalCount, 40);
      expect(NicknameCode.pattern.pattern, serverNicknameRegex.pattern);
    });

    test('generated codes always pass the server format', () {
      final r = Random(7);
      for (var i = 0; i < 5000; i++) {
        final c = NicknameCode.generate(r);
        expect(serverNicknameRegex.hasMatch(c), isTrue, reason: c);
        expect(NicknameCode.isValid(c), isTrue, reason: c);
      }
    });

    test('valid / invalid codes (mirror of the server cases)', () {
      for (final ok in ['12-7-0427', '0-0-0000', '39-39-9999', '9-30-1234']) {
        expect(NicknameCode.isValid(ok), isTrue, reason: ok);
      }
      for (final bad in [
        '40-1-0000', '1-40-0000', '01-1-0000', '1-1-000', '1-1-00000', '-1-1-0000', '1-1-0000 ',
        '<script>', '우주고양이', 'Bad Word', '1_1_0000', '', null,
      ]) {
        expect(NicknameCode.isValid(bad), isFalse, reason: '$bad');
      }
    });

    test('nicknameText renders localized words in the language order, gender-aware', () {
      L10n t(String c) => lookupL10n(Locale(c));
      expect(nicknameText('0-0-0427', t('ko')), '용감한 수달 0427');
      expect(nicknameText('0-0-0427', t('en')), 'Brave Otter 0427');
      expect(nicknameText('39-39-0001', t('en')), 'Loyal Firefly 0001');
      expect(nicknameText('0-0-0427', t('fr')), 'Loutre Courageuse 0427');
      expect(nicknameText('0-2-0427', t('fr')), 'Renard Courageux 0427');
      expect(nicknameText('0-0-0427', t('de')), 'Mutiger Otter 0427');
      expect(nicknameText('0-4-0427', t('de')), 'Mutige Eule 0427');
      expect(nicknameText('0-10-0427', t('de')), 'Mutiges Eichhörnchen 0427');
      expect(nicknameText('0-0-0427', t('ru')), 'Смелая Выдра 0427');
      expect(nicknameText('0-0-0427', t('es')), 'Nutria Valiente 0427');
      expect(nicknameText('2-0-0427', t('pt')), 'Lontra Tranquila 0427');
      expect(nicknameText('0-0-0427', t('ja')), 'ゆうかんなラッコ 0427');
      expect(nicknameText('0-0-0427', t('zh')), '勇敢的水獭 0427');
      expect(nicknameText('0-0-0427', t('id')), 'Berang-berang Pemberani 0427');
      expect(nicknameText('99-1-0001', t('en')), '#99-1-0001');
    });

    test('every locale has 40 distinct adjectives and animals and renders all 1600 pairs', () {
      for (final loc in L10n.supportedLocales) {
        final t = lookupL10n(loc);
        final genders = t.nickGenders.isEmpty ? <String>[] : t.nickGenders.split(',');
        expect(genders.isEmpty || genders.length == NicknameCode.animalCount, isTrue, reason: '${loc.languageCode} genders');
        expect(genders.every((g) => const {'m', 'f', 'n'}.contains(g)), isTrue, reason: '${loc.languageCode} genders');
        final animals = [for (var i = 0; i < NicknameCode.animalCount; i++) nicknameAnimal(t, i)];
        final adjs = [for (var i = 0; i < NicknameCode.adjectiveCount; i++) nicknameAdjective(t, i, 'm')];
        expect(animals.toSet().length, NicknameCode.animalCount, reason: '${loc.languageCode} animals');
        expect(adjs.toSet().length, NicknameCode.adjectiveCount, reason: '${loc.languageCode} adjectives');
        for (var a = 0; a < NicknameCode.adjectiveCount; a++) {
          for (var n = 0; n < NicknameCode.animalCount; n++) {
            final s = nicknameText('$a-$n-0000', t);
            expect(s.contains('{') || s.contains('?') || s.startsWith('#') || s.trim() != s, isFalse,
                reason: '${loc.languageCode} $a-$n "$s"');
          }
        }
      }
    });
  });

  group('ISO week', () {
    test('known dates (UTC)', () {
      expect(isoWeekKey(DateTime.utc(2026, 10, 10)), 202641);
      expect(isoWeekKey(DateTime.utc(2026, 1, 1)), 202601); // Thursday
      expect(isoWeekKey(DateTime.utc(2027, 1, 1)), 202653); // Friday -> week 53 of 2026
      expect(isoWeekKey(DateTime.utc(2021, 1, 3)), 202053); // Sunday
      expect(isoWeekKey(DateTime.utc(2024, 12, 30)), 202501); // Monday -> 2025 W01
      expect(isoWeekKey(DateTime.utc(2026, 10, 12)), 202642); // Monday starts a new week
      expect(isoWeekKey(DateTime.utc(2026, 10, 11, 23, 59)), 202641);
    });

    test('uses UTC, not local time', () {
      // 2026-10-12 08:30 in UTC+9 is still Sunday 23:30 UTC
      final local = DateTime.parse('2026-10-12T08:30:00+09:00');
      expect(isoWeekKey(local), 202641);
    });

    test('previous week', () {
      expect(previousIsoWeekKey(DateTime.utc(2026, 10, 10)), 202640);
      expect(previousIsoWeekKey(DateTime.utc(2026, 1, 5)), 202601);
      expect(previousIsoWeekKey(DateTime.utc(2027, 1, 4)), 202653);
    });
  });

  group('WeeklyScore', () {
    final mon = DateTime.utc(2026, 10, 5, 9);
    final sun = DateTime.utc(2026, 10, 11, 23);
    final nextMon = DateTime.utc(2026, 10, 12, 1);

    test('accumulates by the scoring formula', () {
      final s = WeeklyScore.now(mon);
      s.addColonyLevel(mon);
      s.addColonyLevel(mon);
      s.addNewSystem(mon);
      for (var i = 0; i < 10; i++) {
        s.addPirateKill(sun);
      }
      s.addBossDefeated(sun);
      expect(s.week, 202641);
      expect(s.points, 2 * 100 + 500 + 10 * 5 + 200);
    });

    test('resets on a new ISO week and keeps last week for a late submit', () {
      final s = WeeklyScore.now(mon)..addNewSystem(mon);
      expect(s.pointsNow(sun), 500);
      s.addPirateKill(nextMon);
      expect(s.week, 202642);
      expect(s.points, 5);
      expect(s.lastWeek, 202641);
      expect(s.lastPoints, 500);
    });

    test('skipping weeks drops the old score (server would refuse it)', () {
      final s = WeeklyScore.now(mon)..addNewSystem(mon);
      expect(s.pointsNow(DateTime.utc(2026, 10, 20)), 0);
      expect(s.lastWeek, isNull);
      expect(s.lastPoints, 0);
    });

    test('clamped to the server cap', () {
      final s = WeeklyScore(week: 202641, points: WeeklyScore.maxPoints - 3);
      s.addPirateKill(mon);
      expect(s.points, WeeklyScore.maxPoints);
      expect(WeeklyScore.maxPoints, 5000000);
    });

    test('JSON round trip and broken input', () {
      final s = WeeklyScore(week: 202641, points: 1234, lastWeek: 202640, lastPoints: 99);
      final back = WeeklyScore.fromJson(jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>, mon);
      expect(back.week, 202641);
      expect(back.points, 1234);
      expect(back.lastWeek, 202640);
      expect(back.lastPoints, 99);

      final plain = WeeklyScore.fromJson(WeeklyScore(week: 202641, points: 5).toJson(), mon);
      expect(plain.lastWeek, isNull);
      expect(plain.toJson().containsKey('lastWeek'), isFalse);

      final broken = WeeklyScore.fromJson({'week': 'x'}, mon);
      expect(broken.week, 202641);
      expect(broken.points, 0);
      expect(WeeklyScore.fromJson(null, mon).points, 0);
      expect(WeeklyScore.fromJson({'week': 202641, 'points': 99999999}, mon).points, WeeklyScore.maxPoints);
    });
  });

  group('LeaderboardService', () {
    final now = DateTime.utc(2026, 10, 10, 12);

    LeaderboardService make(MemoryLeaderboardStore store, LeaderboardPost post) =>
        LeaderboardService(store: store, post: post, clock: () => now, rng: Random(1));

    test('install id is a UUID v4 made once and kept', () {
      final store = MemoryLeaderboardStore();
      final svc = make(store, (_, _) async => (200, '{}'));
      final id = svc.installId;
      expect(isUuidV4(id), isTrue, reason: id);
      expect(svc.installId, id);
      expect(store.installId, id);
      for (var i = 0; i < 200; i++) {
        expect(isUuidV4(uuidV4()), isTrue);
      }
    });

    test('opted out by default: nothing is sent', () async {
      var calls = 0;
      final svc = make(MemoryLeaderboardStore(), (_, _) async {
        calls++;
        return (200, '{"rank":1,"total":1}');
      });
      expect(svc.optedIn, isFalse);
      final r = await svc.submit(202641, 10);
      expect(r.status, LeaderboardStatus.optedOut);
      expect(calls, 0);
    });

    test('submit sends only id, code, week, score', () async {
      final store = MemoryLeaderboardStore();
      String? rpc;
      Map<String, Object?>? body;
      final svc = make(store, (r, b) async {
        rpc = r;
        body = b;
        return (200, '{"rank" : 3, "total" : 9}');
      });
      await svc.setOptIn(true);
      final r = await svc.submit(202641, 700);
      expect(r.status, LeaderboardStatus.ok);
      expect(r.rank, 3);
      expect(r.total, 9);
      expect(rpc, 'starset_submit_score');
      expect(body!.keys.toSet(), {'p_install_id', 'p_nickname', 'p_week', 'p_score'});
      expect(serverNicknameRegex.hasMatch(body!['p_nickname'] as String), isTrue);
    });

    test('errors become statuses, never exceptions', () async {
      final store = MemoryLeaderboardStore()..leaderboardOptIn = true;
      Future<SubmitResult> run(LeaderboardPost p) => make(store, p).submit(202641, 1);
      expect((await run((_, _) async => (429, '{}'))).status, LeaderboardStatus.rateLimited);
      expect((await run((_, _) async => (400, '{}'))).status, LeaderboardStatus.rejected);
      expect((await run((_, _) async => (500, '{}'))).status, LeaderboardStatus.serverError);
      expect((await run((_, _) async => (200, 'not json'))).status, LeaderboardStatus.serverError);
      expect((await run((_, _) => throw const SocketException('down'))).status, LeaderboardStatus.offline);
      expect((await run((_, _) => throw StateError('boom'))).status, LeaderboardStatus.serverError);
    });

    test('board parses rows and finds mine', () async {
      final store = MemoryLeaderboardStore()..leaderboardOptIn = true;
      final svc = make(store, (_, b) async {
        expect(b['p_week'], 202641);
        return (
          200,
          '[{"rank":1,"nickname":"0-0-0001","score":900,"me":false},'
              '{"rank":2,"nickname":"1-1-0002","score":800,"me":true},{"bad":1}]'
        );
      });
      final r = await svc.fetch(202641);
      expect(r.status, LeaderboardStatus.ok);
      expect(r.entries.length, 2);
      expect(r.mine!.rank, 2);
    });

    test('board without opt-in does not send the install id', () async {
      Map<String, Object?>? body;
      final svc = make(MemoryLeaderboardStore(), (_, b) async {
        body = b;
        return (200, '[]');
      });
      await svc.fetch(202641);
      expect(body!['p_install_id'], isNull);
    });

    test('reroll is limited', () {
      final store = MemoryLeaderboardStore();
      final svc = make(store, (_, _) async => (200, '{}'));
      final first = svc.nicknameCode;
      final seen = <String>{first};
      for (var i = 0; i < LeaderboardService.maxRerolls; i++) {
        expect(svc.canReroll, isTrue);
        seen.add(svc.reroll());
      }
      expect(svc.canReroll, isFalse);
      expect(svc.rerollsLeft, 0);
      final last = svc.nicknameCode;
      expect(svc.reroll(), last);
      expect(seen.length, greaterThan(1));
    });

    test('submitWeekly sends last week first, then clears it', () async {
      final store = MemoryLeaderboardStore()..leaderboardOptIn = true;
      final weeks = <Object?>[];
      final svc = make(store, (_, b) async {
        weeks.add(b['p_week']);
        return (200, '{"rank":1,"total":1}');
      });
      final s = WeeklyScore(week: 202641, points: 50, lastWeek: 202640, lastPoints: 300);
      final r = await svc.submitWeekly(s);
      expect(r.status, LeaderboardStatus.ok);
      expect(weeks, [202640, 202641]);
      expect(s.lastWeek, isNull);
    });

    test('forget calls starset_forget with the given id, ignores junk ids', () async {
      final calls = <String>[];
      final svc = make(MemoryLeaderboardStore(), (rpc, b) async {
        calls.add('$rpc ${b['p_install_id']}');
        return (200, '{"deleted":1}');
      });
      final id = uuidV4();
      expect(await svc.forget(id), LeaderboardStatus.ok);
      expect(await svc.forget('not-a-uuid'), LeaderboardStatus.notConfigured);
      expect(calls, ['starset_forget $id']);
      final offline = make(MemoryLeaderboardStore(), (_, _) => throw const SocketException('x'));
      expect(await offline.forget(id), LeaderboardStatus.offline);
    });

    test('client config is filled in', () {
      expect(LeaderboardConfig.configured, isTrue);
      expect(LeaderboardConfig.baseUrl, startsWith('https://'));
    });
  });

  testWidgets('screen: opt-in off by default, joining shows nickname and highlighted row', (tester) async {
    Lang.set(const Locale('en'));
    final store = MemoryLeaderboardStore();
    final svc = LeaderboardService(
      store: store,
      rng: Random(3),
      post: (rpc, b) async => rpc == 'starset_submit_score'
          ? (200, '{"rank":2,"total":2}')
          : (
              200,
              jsonEncode([
                {'rank': 1, 'nickname': '0-0-0001', 'score': 900, 'me': false},
                {'rank': 2, 'nickname': b['p_install_id'] == null ? '1-1-0002' : store.nicknameCode, 'score': 40, 'me': b['p_install_id'] != null},
              ])
            ),
    );
    final score = WeeklyScore.now()..addPirateKill()..addColonyLevel();
    await tester.pumpWidget(MaterialApp(home: LeaderboardScreen(service: svc, score: score)));
    await tester.pumpAndSettle();
    expect(find.text('Join the leaderboard'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isFalse);
    expect(find.text('Brave Otter 0001'), findsOneWidget);
    expect(find.textContaining('This week'), findsNothing);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(store.leaderboardOptIn, isTrue);
    expect(find.text('This week: 105 pts'), findsOneWidget);
    expect(find.text('#2 of 2'), findsOneWidget);
    expect(find.text(nicknameText(store.nicknameCode!, tr)), findsNWidgets(2)); // my card + my row
    expect(find.byKey(const ValueKey('lb_my_row')), findsOneWidget);
  });

  test('groupDigits', () {
    expect(groupDigits(0), '0');
    expect(groupDigits(999), '999');
    expect(groupDigits(1000), '1,000');
    expect(groupDigits(5000000), '5,000,000');
  });

  test('Profile keeps leaderboard settings and weekly score; old saves default to opted out', () {
    final p = Profile()
      ..installId = uuidV4()
      ..nicknameCode = '3-4-0005'
      ..leaderboardOptIn = true
      ..nicknameRerolls = 2;
    p.weeklyScore.addNewSystem();
    final back = Profile.fromJson(jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>);
    expect(back.installId, p.installId);
    expect(back.nicknameCode, '3-4-0005');
    expect(back.leaderboardOptIn, isTrue);
    expect(back.nicknameRerolls, 2);
    expect(back.weeklyScore.points, 500);

    final old = Profile.fromJson({'gems': 3});
    expect(old.leaderboardOptIn, isFalse);
    expect(old.installId, isNull);
    expect(old.weeklyScore.points, 0);
  });
}
