import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/l10n/l.dart';
import 'package:star_settlers/services/telemetry.dart';

const _id = '11111111-1111-4111-8111-111111111111';

/// starset_track 흉내: 호출 기록, 응답 코드 지정, 오프라인
class FakeTrackServer {
  final calls = <Map<String, Object?>>[];
  int code = 200;
  bool offline = false;

  Future<(int, String)> post(String rpc, Map<String, Object?> body) async {
    if (offline) throw const SocketException('offline');
    expect(rpc, 'starset_track');
    calls.add(body);
    final n = (body['p_events'] as List).length;
    return (code, code == 200 ? jsonEncode({'stored': n}) : '{"message":"x"}');
  }

  List<Map<String, Object?>> get events => [
        for (final c in calls)
          for (final e in c['p_events'] as List) Map<String, Object?>.from(e as Map),
      ];
}

class Clock {
  DateTime now = DateTime(2026, 11, 8, 10);
  DateTime call() => now;
}

TelemetryService svc({
  MemoryTelemetryStore? store,
  FakeTrackServer? server,
  Clock? clock,
  bool enabled = true,
}) =>
    TelemetryService(
      installId: () => _id,
      store: store ?? MemoryTelemetryStore(),
      post: (server ?? FakeTrackServer()).post,
      clock: (clock ?? Clock()).call,
      enabled: enabled,
      locale: () => 'ko',
      platform: 'android',
    );

int count(TelemetryService s, TelemetryEvent e) => s.queue.where((q) => q['n'] == e.wire).length;

/// 예약된 저장(microtask)이 끝나게
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  tearDown(() => GameTelemetry.sink = null);

  group('queue', () {
    test('상한 200개, 넘치면 오래된 것부터 버린다', () {
      final s = svc();
      for (var i = 0; i < 250; i++) {
        s.track(TelemetryEvent.loginClaim, i);
      }
      expect(s.queue.length, TelemetryConfig.maxQueue);
      expect(s.queue.first['v'], 50);
      expect(s.queue.last['v'], 249);
    });

    test('항목 형식: 이름·값·시각·앱 버전·언어·플랫폼', () {
      final s = svc();
      s.track(TelemetryEvent.tutorialStep, 3);
      s.track(TelemetryEvent.shopOpen);
      final a = s.queue.first, b = s.queue.last;
      expect(a['n'], 'tutorial_step');
      expect(a['v'], 3);
      expect(a['t'], DateTime(2026, 11, 8, 10).millisecondsSinceEpoch ~/ 1000);
      expect(a['app'], TelemetryConfig.appVersion);
      expect(a['loc'], 'ko');
      expect(a['os'], 'android');
      expect(b.containsKey('v'), isFalse);
    });

    test('저장했다가 다시 읽으면 큐가 이어진다', () async {
      final store = MemoryTelemetryStore();
      final s = svc(store: store);
      s.track(TelemetryEvent.adWatch);
      s.track(TelemetryEvent.iapStart);
      await settle();
      expect(store.writes, greaterThan(0));
      final s2 = svc(store: store);
      s2.track(TelemetryEvent.shopOpen); // 읽기 전에 쌓인 것은 뒤에 붙는다
      await s2.load();
      expect(s2.queue.map((e) => e['n']), ['ad_watch', 'iap_start', 'shop_open']);
      expect(s2.queue.map((e) => e['s']).toSet().length, 3);
    });

    test('깨진 저장은 무시한다', () async {
      final s = svc(store: MemoryTelemetryStore('{not json'));
      await s.load();
      expect(s.queue, isEmpty);
    });
  });

  group('flush', () {
    test('50개씩 나눠 보내고 보낸 것은 큐에서 뺀다', () async {
      final server = FakeTrackServer();
      final s = svc(server: server);
      for (var i = 0; i < 120; i++) {
        s.track(TelemetryEvent.loginClaim, i);
      }
      expect(await s.flush(), 120);
      expect(server.calls.map((c) => (c['p_events'] as List).length), [50, 50, 20]);
      expect(server.calls.every((c) => c['p_install_id'] == _id), isTrue);
      expect(server.events.every((e) => !e.containsKey('s')), isTrue, reason: '내부 번호는 보내지 않는다');
      expect(server.events.map((e) => e['v']), List.generate(120, (i) => i));
      expect(s.queue, isEmpty);
    });

    test('한 번에 최대 3묶음 (서버 분당 제한), 나머지는 다음에', () async {
      final server = FakeTrackServer();
      final s = svc(server: server);
      for (var i = 0; i < 200; i++) {
        s.track(TelemetryEvent.loginClaim, i);
      }
      expect(await s.flush(), 150);
      expect(s.queue.length, 50);
      expect(await s.flush(), 50);
      expect(s.queue, isEmpty);
    });

    test('네트워크 실패·서버 오류·요청 제한이면 큐를 그대로 둔다', () async {
      final server = FakeTrackServer();
      final s = svc(server: server);
      s.track(TelemetryEvent.adWatch);
      s.track(TelemetryEvent.shopOpen);
      server.offline = true;
      expect(await s.flush(), 0);
      expect(s.queue.length, 2);
      server.offline = false;
      for (final code in [500, 429, 503]) {
        server.code = code;
        expect(await s.flush(), 0);
        expect(s.queue.length, 2, reason: 'HTTP $code');
      }
      server.code = 200;
      expect(await s.flush(), 2);
      expect(s.queue, isEmpty);
    });

    test('서버가 묶음을 형식 오류(400)로 거부하면 버린다 (다시 보내도 같다)', () async {
      final server = FakeTrackServer()..code = 400;
      final s = svc(server: server);
      s.track(TelemetryEvent.adWatch);
      expect(await s.flush(), 0);
      expect(s.queue, isEmpty);
    });

    test('보내는 동안 들어온 이벤트는 남는다', () async {
      final server = FakeTrackServer();
      late TelemetryService s;
      s = TelemetryService(
        installId: () => _id,
        store: MemoryTelemetryStore(),
        post: (rpc, body) {
          s.track(TelemetryEvent.iapStart);
          return server.post(rpc, body);
        },
        clock: Clock().call,
        enabled: true,
        locale: () => 'ko',
        platform: 'ios',
      );
      s.track(TelemetryEvent.shopOpen);
      await s.flush();
      expect(server.events.first['n'], 'shop_open');
      expect(s.queue.any((e) => e['n'] == 'iap_start'), isTrue);
    });

    test('테스트·디버그 모드(enabled=false)에서는 보내지 않는다', () async {
      final server = FakeTrackServer();
      final s = svc(server: server, enabled: false);
      s.track(TelemetryEvent.adWatch);
      expect(await s.flush(), 0);
      expect(server.calls, isEmpty);
      expect(s.queue.length, 1);
    });

    test('기본값: 디버그·테스트 빌드는 전송 꺼짐', () {
      final s = TelemetryService(installId: () => _id, store: MemoryTelemetryStore());
      expect(s.enabled, isFalse);
    });
  });

  group('once / day_return / session', () {
    test('first_* 는 설치당 한 번만 (다시 실행해도)', () async {
      final store = MemoryTelemetryStore();
      final s = svc(store: store);
      for (var i = 0; i < 3; i++) {
        s.track(TelemetryEvent.firstKill);
        s.track(TelemetryEvent.firstWarp);
      }
      expect(count(s, TelemetryEvent.firstKill), 1);
      expect(count(s, TelemetryEvent.firstWarp), 1);
      await settle();
      final s2 = svc(store: store);
      await s2.load();
      s2.track(TelemetryEvent.firstKill);
      expect(count(s2, TelemetryEvent.firstKill), 1, reason: '저장분 1개만, 새로 들어가지 않음');
      // 보낸 뒤에도 다시 들어가지 않는다
      await s2.flush();
      s2.track(TelemetryEvent.firstKill);
      expect(count(s2, TelemetryEvent.firstKill), 0);
    });

    test('day_return 은 하루 한 번, 값은 첫 실행 뒤 지난 날수', () async {
      final store = MemoryTelemetryStore();
      final clock = Clock();
      final s = svc(store: store, clock: clock);
      s.sessionStart();
      s.sessionEnd();
      clock.now = clock.now.add(const Duration(hours: 5));
      s.sessionStart();
      s.sessionEnd();
      expect(s.queue.where((e) => e['n'] == 'day_return').map((e) => e['v']), [0]);

      clock.now = DateTime(2026, 11, 9, 0, 30);
      s.sessionStart();
      s.sessionEnd();
      await settle();
      // 앱을 다시 켠 사흘 뒤
      clock.now = DateTime(2026, 11, 11, 23);
      final s2 = svc(store: store, clock: clock);
      await s2.load();
      s2.sessionStart();
      s2.sessionStart(); // 세션 중 중복 호출 무시
      expect(s2.queue.where((e) => e['n'] == 'day_return').map((e) => e['v']), [0, 1, 3]);
      expect(count(s2, TelemetryEvent.sessionStart), 4);
    });

    test('session_end 값은 세션 길이(초), 세션 없이 끝내면 무시', () {
      final clock = Clock();
      final s = svc(clock: clock);
      s.sessionEnd();
      expect(count(s, TelemetryEvent.sessionEnd), 0);
      s.sessionStart();
      expect(s.inSession, isTrue);
      clock.now = clock.now.add(const Duration(minutes: 4, seconds: 5));
      s.sessionEnd();
      expect(s.inSession, isFalse);
      expect(s.queue.lastWhere((e) => e['n'] == 'session_end')['v'], 245);
    });
  });

  group('game hook', () {
    test('sink 가 없으면 버리고, sink 예외는 게임으로 나가지 않는다', () {
      GameTelemetry.emit(TelemetryEvent.firstKill);
      GameTelemetry.sink = (e, v) => throw StateError('boom');
      expect(() => GameTelemetry.emit(TelemetryEvent.firstKill), returnsNormally);
    });

    test('출석·일일 퀘스트 수령이 이벤트를 낸다', () {
      final got = <(TelemetryEvent, int?)>[];
      GameTelemetry.sink = (e, v) => got.add((e, v));
      final p = Profile();
      final day1 = DateTime(2026, 11, 8, 9);
      p.claimLogin(day1);
      p.claimLogin(day1); // 같은 날 두 번째는 수령 안 됨 → 이벤트 없음
      p.claimLogin(day1.add(const Duration(days: 1)));
      expect(got, [(TelemetryEvent.loginClaim, 1), (TelemetryEvent.loginClaim, 2)]);
      got.clear();
      p.refreshDaily(day1);
      final q = p.dailyQuests.first;
      p.addStat(q.stat, q.target);
      expect(p.claimDaily(q.id), isTrue);
      expect(p.claimDaily(q.id), isFalse);
      expect(got, [(TelemetryEvent.dailyQuestClaim, null)]);
    });

    test('새 월드: 첫 처치·첫 정착·첫 건물·워프가 한 번씩 들어간다', () async {
      Lang.set(const Locale('ko'));
      final s = svc();
      GameTelemetry.sink = s.track;
      final w = GameWorld(seed: 151)
        ..credits = 1e12
        ..ore = 1e12
        ..spawnTimer = 1e9
        ..eventTimer = 1e9;
      w.player.invulnerable = 1e9;
      expect(count(s, TelemetryEvent.firstKill), 0);
      expect(count(s, TelemetryEvent.firstColony), 0);

      for (var i = 0; i < 2; i++) {
        w.pirates
          ..clear()
          ..add(Pirate(PirateKind.raider, w.player.pos + const Offset(2000, 0), 1)..hp = -1);
        w.update(1 / 60, InputState());
      }
      expect(w.counter('kills'), 2);
      expect(count(s, TelemetryEvent.firstKill), 1);

      final mars = w.planets.first;
      expect(w.upgradePlanet(mars), isTrue);
      expect(w.upgradePlanet(mars), isTrue);
      expect(w.upgradePlanet(w.planets[1]), isTrue);
      expect(count(s, TelemetryEvent.firstColony), 1);

      expect(w.buildColony(mars, ColonyBuilding.stabilizer), isTrue);
      expect(w.buildColony(mars, ColonyBuilding.stabilizer), isTrue);
      expect(count(s, TelemetryEvent.firstBuilding), 1);

      w.counters['maxSector'] = 1;
      expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
      expect(w.warp(w.gates.firstWhere((g) => !g.forward)), isTrue);
      expect(count(s, TelemetryEvent.firstWarp), 1);
      // 이미 가 본 항성계(maxSector=1)라 새 항성계 도착은 아니다
      expect(count(s, TelemetryEvent.systemReached), 0);
    });

    test('처음 가 보는 항성계에 도착하면 system_reached (값 = 항성계 번호)', () {
      final got = <(TelemetryEvent, int?)>[];
      GameTelemetry.sink = (e, v) => got.add((e, v));
      final w = GameWorld(seed: 151);
      // 가 본 적 없는 항성계(maxSector=0)로 가려면 발전도 100%로 게이트를 연다
      w.counters['maxSector'] = 0;
      for (final p in w.planets) {
        p.colonyLevel = w.colonyLevelCap;
        for (final b in ColonyBuilding.values) {
          p.buildings[b] = p.buildingCap;
        }
      }
      expect(w.development, greaterThanOrEqualTo(1));
      expect(w.warp(w.gates.firstWhere((g) => g.forward)), isTrue);
      expect(got.where((g) => g.$1 == TelemetryEvent.systemReached), [(TelemetryEvent.systemReached, 2)]);
    });
  });

  group('sync', () {
    test('앱 버전 상수 = pubspec.yaml 버전 이름', () {
      final m = RegExp(r'^version:\s*([0-9.]+)\+', multiLine: true).firstMatch(File('pubspec.yaml').readAsStringSync());
      expect(TelemetryConfig.appVersion, m!.group(1));
    });

    test('이벤트 이름 = 서버 허용 목록 (starset_event_names)', () {
      // 가장 최근 마이그레이션의 정의가 정본 (create or replace로 목록 전체를 다시 쓴다)
      final files = Directory('supabase/migrations').listSync().whereType<File>().map((f) => f.path).toList()..sort();
      final pattern = RegExp(r'starset_event_names\(\)[\s\S]*?array\[([\s\S]*?)\]::text\[\]');
      final body = files.reversed
          .map((f) => pattern.firstMatch(File(f).readAsStringSync())?.group(1))
          .firstWhere((b) => b != null)!;
      final server = RegExp(r"'([a-z_]+)'").allMatches(body).map((m) => m.group(1)).toSet();
      expect(server, TelemetryEvent.values.map((e) => e.wire).toSet());
    });
  });
}
