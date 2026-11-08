import 'dart:async';
import 'dart:convert';
import 'dart:io' show HandshakeException, HttpException, Platform, SocketException;

import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/game_telemetry.dart';
import '../l10n/l.dart';
import 'leaderboard.dart' show LeaderboardConfig, LeaderboardPost;
import 'rpc.dart';

export '../game/game_telemetry.dart' show TelemetryEvent, GameTelemetry;

/// 게임 개선 통계 (이탈 지점 측정). 공용 게임 서버(mkideabox-games), 접두사 starset_.
/// 서버 원본: supabase/migrations/20261108000000_starset_events.sql (함수 starset_track)
///
/// 보내는 것: 무작위 설치 ID(순위표·지갑과 같은 UUID), 이벤트 이름([TelemetryEvent])·숫자, 앱 버전·언어 코드·플랫폼.
/// 사용자가 입력한 글자·광고 ID·기기 ID·위치는 보내지 않는다. 개인정보처리방침 "게임 개선 통계" 절.
///
/// 이벤트는 메모리 큐에 쌓고 기기에 저장해 두었다가(최대 [TelemetryConfig.maxQueue]개, 넘치면 오래된 것부터 버림)
/// [TelemetryConfig.flushEvery]마다, 그리고 앱이 백그라운드로 갈 때 [TelemetryConfig.batch]개씩 보낸다.
/// 어떤 실패도 게임에 예외를 던지지 않는다. 보내지 못한 이벤트는 큐에 남아 다음에 다시 보낸다.
abstract final class TelemetryConfig {
  /// 앱 버전 이름. pubspec.yaml `version:`의 + 앞부분과 같아야 한다 (test/telemetry_test.dart가 확인한다).
  /// package_info 의존성을 늘리지 않으려고 상수로 둔다. 버전을 올릴 때 같이 고친다.
  static const appVersion = '1.0.8';

  static const maxQueue = 200;

  /// 한 번에 보내는 최대 개수 (서버 한도 50)
  static const batch = 50;

  /// 한 번 보낼 때 이어서 보내는 최대 묶음 수 (서버 제한: 설치당 분당 10회)
  static const maxBatchesPerFlush = 3;

  static const flushEvery = Duration(seconds: 30);

  /// 저장 키 (SharedPreferences). 프로필과 따로 두어 "모든 데이터 초기화" 뒤에도 first_*를 다시 보내지 않는다.
  static const prefsKey = 'starset_telemetry_v1';
}

/// 큐와 설치 단위 기록(first_* 보낸 목록, 첫 실행 날짜, 마지막 day_return 날짜)을 담는 저장소.
abstract class TelemetryStore {
  Future<String?> read();
  Future<void> write(String data);
}

class PrefsTelemetryStore implements TelemetryStore {
  @override
  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(TelemetryConfig.prefsKey);

  @override
  Future<void> write(String data) async =>
      (await SharedPreferences.getInstance()).setString(TelemetryConfig.prefsKey, data);
}

class MemoryTelemetryStore implements TelemetryStore {
  MemoryTelemetryStore([this.data]);
  String? data;
  int writes = 0;

  @override
  Future<String?> read() async => data;

  @override
  Future<void> write(String d) async {
    data = d;
    writes++;
  }
}

class TelemetryService {
  TelemetryService({
    required this.installId,
    TelemetryStore? store,
    LeaderboardPost? post,
    DateTime Function()? clock,
    bool? enabled,
    String Function()? locale,
    String? platform,
  })  : store = store ?? PrefsTelemetryStore(),
        _post = post ?? _httpPost,
        _clock = clock ?? DateTime.now,
        enabled = enabled ?? (kReleaseMode && LeaderboardConfig.configured),
        _locale = locale ?? _defaultLocale,
        platform = platform ?? _defaultPlatform();

  final String Function() installId;
  final TelemetryStore store;
  final LeaderboardPost _post;
  final DateTime Function() _clock;
  final String Function() _locale;
  final String platform;

  /// false면 큐에는 쌓지만 서버로 보내지 않는다. 기본: 출시 빌드만 true (디버그·테스트는 보내지 않음).
  bool enabled;

  final List<Map<String, Object?>> _queue = [];
  final Set<String> _sentOnce = {};
  int _seq = 0;

  /// 첫 실행 날짜와 마지막 day_return 날짜 (yyyymmdd, 기기 현지 날짜)
  int? _firstDay;
  int? _lastReturnDay;

  DateTime? _sessionStart;
  bool _sending = false;
  bool _writeScheduled = false;
  Timer? _timer;
  _TelemetryLifecycle? _observer;

  /// 테스트·진단용
  List<Map<String, Object?>> get queue => List.unmodifiable(_queue);
  bool get inSession => _sessionStart != null;

  /// 저장된 큐와 기록을 읽는다. 읽기 전에 쌓인 이벤트는 저장분 뒤에 이어 붙인다.
  Future<void> load() async {
    try {
      final raw = await store.read();
      if (raw == null || raw.isEmpty) return;
      final j = jsonDecode(raw);
      if (j is! Map) return;
      final saved = [
        for (final e in (j['q'] as List? ?? const []))
          if (e is Map) Map<String, Object?>.from(e),
      ];
      _queue.insertAll(0, saved);
      _trim();
      for (final n in (j['once'] as List? ?? const [])) {
        if (n is String) _sentOnce.add(n);
      }
      _firstDay ??= j['first'] as int?;
      _lastReturnDay ??= j['ret'] as int?;
      final seq = j['seq'];
      if (seq is int && seq > _seq) _seq = seq;
      // 읽기 전에 쌓인 이벤트의 번호가 저장분과 겹치지 않게 다시 매긴다
      for (final e in _queue) {
        e['s'] = ++_seq;
      }
    } catch (_) {
      // 깨진 저장은 버린다 (통계일 뿐이다)
    }
  }

  /// 이벤트 하나를 큐에 넣는다. [TelemetryEvent.once]는 설치당 한 번만 들어간다.
  void track(TelemetryEvent e, [int? value]) {
    if (e.once && !_sentOnce.add(e.wire)) return;
    _queue.add({
      's': ++_seq,
      'n': e.wire,
      'v': ?value,
      't': _clock().millisecondsSinceEpoch ~/ 1000,
      'app': TelemetryConfig.appVersion,
      'loc': _safeLocale(),
      'os': platform,
    });
    _trim();
    _scheduleWrite();
  }

  void _trim() {
    if (_queue.length > TelemetryConfig.maxQueue) {
      _queue.removeRange(0, _queue.length - TelemetryConfig.maxQueue);
    }
  }

  String _safeLocale() {
    try {
      final l = _locale();
      return RegExp(r'^[a-z]{2,3}(-[A-Z]{2})?$').hasMatch(l) ? l : 'en';
    } catch (_) {
      return 'en';
    }
  }

  // ---------- 세션 ----------

  /// 앱 시작·포그라운드 복귀. 이미 세션 중이면 무시. 하루 한 번 day_return도 여기서 보낸다.
  void sessionStart() {
    if (_sessionStart != null) return;
    final now = _clock();
    _sessionStart = now;
    track(TelemetryEvent.sessionStart);
    final today = _dayKey(now);
    _firstDay ??= today;
    if (_lastReturnDay != today) {
      _lastReturnDay = today;
      track(TelemetryEvent.dayReturn, _daysBetween(_firstDay!, today));
    }
  }

  /// 백그라운드 전환·종료. value = 세션 길이(초).
  void sessionEnd() {
    final start = _sessionStart;
    if (start == null) return;
    _sessionStart = null;
    final sec = _clock().difference(start).inSeconds;
    track(TelemetryEvent.sessionEnd, sec < 0 ? 0 : sec);
  }

  static int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  static DateTime _fromKey(int k) => DateTime.utc(k ~/ 10000, k ~/ 100 % 100, k % 100);

  static int _daysBetween(int from, int to) {
    final d = _fromKey(to).difference(_fromKey(from)).inDays;
    return d < 0 ? 0 : d;
  }

  // ---------- 전송 ----------

  /// 큐를 보낸다. 보낸(또는 서버가 형식 오류로 거부한) 이벤트는 큐에서 뺀다. 실패하면 그대로 둔다.
  /// 보낸 개수를 돌려준다. 예외를 던지지 않는다.
  Future<int> flush() async {
    if (!enabled || _sending || _queue.isEmpty) return 0;
    _sending = true;
    var sent = 0;
    try {
      for (var b = 0; b < TelemetryConfig.maxBatchesPerFlush && _queue.isNotEmpty; b++) {
        final items = _queue.take(TelemetryConfig.batch).toList();
        final code = await _send(items);
        if (code == null) break;
        final ok = code >= 200 && code < 300;
        // 400 = 서버가 묶음 자체를 거부 (형식). 다시 보내도 같으니 버린다.
        if (!ok && code != 400) break;
        final seqs = {for (final e in items) e['s']};
        _queue.removeWhere((e) => seqs.contains(e['s']));
        if (ok) sent += items.length;
        _scheduleWrite();
      }
    } finally {
      _sending = false;
    }
    return sent;
  }

  /// HTTP 상태. 네트워크 오류·시간 초과는 null.
  Future<int?> _send(List<Map<String, Object?>> items) async {
    try {
      final body = {
        'p_install_id': installId(),
        'p_events': [
          for (final e in items) {for (final kv in e.entries) if (kv.key != 's') kv.key: kv.value},
        ],
      };
      final (code, _) = await _post('starset_track', body).timeout(LeaderboardConfig.timeout);
      return code;
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } on HandshakeException {
      return null;
    } on HttpException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------- 저장 ----------

  void _scheduleWrite() {
    if (_writeScheduled) return;
    _writeScheduled = true;
    scheduleMicrotask(() async {
      _writeScheduled = false;
      await persist();
    });
  }

  /// 지금 상태를 저장한다. 실패는 무시한다.
  Future<void> persist() async {
    try {
      await store.write(jsonEncode({
        'q': _queue,
        'once': _sentOnce.toList(),
        'first': _firstDay,
        'ret': _lastReturnDay,
        'seq': _seq,
      }));
    } catch (_) {}
  }

  // ---------- 앱 연결 ----------

  /// 앱에서 한 번: 게임 훅 연결, 세션 시작, 주기 전송, 앱 생명주기(백그라운드 → 세션 끝 + 전송).
  void attach() {
    GameTelemetry.sink = track;
    sessionStart();
    _timer?.cancel();
    _timer = Timer.periodic(TelemetryConfig.flushEvery, (_) => unawaited(flush()));
    if (_observer == null) {
      _observer = _TelemetryLifecycle(this);
      WidgetsBinding.instance.addObserver(_observer!);
    }
    unawaited(flush());
  }

  void _onLifecycle(AppLifecycleState s) {
    switch (s) {
      case AppLifecycleState.resumed:
        sessionStart();
        unawaited(flush());
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        sessionEnd();
        unawaited(persist());
        unawaited(flush());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  static String _defaultLocale() => Lang.locale.languageCode;

  static String _defaultPlatform() => kIsWeb ? 'web' : Platform.operatingSystem;

  static Future<(int, String)> _httpPost(String rpc, Map<String, Object?> body) =>
      supabaseRpcPost(LeaderboardConfig.baseUrl, LeaderboardConfig.anonKey, LeaderboardConfig.timeout, rpc, body);
}

class _TelemetryLifecycle with WidgetsBindingObserver {
  _TelemetryLifecycle(this.svc);
  final TelemetryService svc;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => svc._onLifecycle(state);
}
