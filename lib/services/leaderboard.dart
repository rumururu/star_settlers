import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../game/weekly_score.dart';
import '../l10n/l.dart';
import 'rpc.dart';

export '../game/weekly_score.dart' show isoWeekKey, previousIsoWeekKey, ScorePoints, WeeklyScore;

/// 주간 순위표 (공용 게임 서버, 접두사 starset_).
/// 규칙: /Volumes/home_extension/mkideabox-corp-process/processes/infrastructure/game-shared-backend.md
/// 서버 원본: supabase/migrations/20261011000000_starset_leaderboard.sql
///
/// 보내는 것은 무작위 설치 ID(UUID)·별명 코드("형용사번호-동물번호-4자리")·주간 점수뿐이다.
/// 사용자가 입력한 글자는 서버로도, 다른 플레이어에게도 가지 않는다 (아이 사용자 보호).
/// 어떤 실패도 게임으로 예외를 던지지 않고 [LeaderboardStatus]로 돌려준다.
abstract final class LeaderboardConfig {
  static const baseUrl = 'https://qfhbkfzxhldfycmcwntw.supabase.co';

  /// 공개(anon) 키. 서버는 함수 2개만 anon에 열어 두었다 (테이블 직접 접근 불가).
  static const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFmaGJrZnp4aGxkZnljbWN3bnR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2MjgzNjUsImV4cCI6MjEwNzIwNDM2NX0.RQ_K4X1DvgG2dCv57IK4TxlK8H55kxYpFACSk1YCYhE';

  static bool get configured => baseUrl.isNotEmpty && anonKey.isNotEmpty && !anonKey.startsWith('__');

  static const timeout = Duration(seconds: 8);
}

/// 별명 코드: "<형용사 0..39>-<동물 0..39>-<0000..9999>" (예: "12-7-0427").
/// 서버 정규식과 같다. 단어는 각 기기가 자기 언어로 그린다 ([nicknameText]).
abstract final class NicknameCode {
  /// 서버 검증 범위와 맞춘다. 바꾸면 마이그레이션의 정규식도 바꾼다.
  static const adjectiveCount = 40;
  static const animalCount = 40;

  static final pattern = RegExp(r'^([0-9]|[1-3][0-9])-([0-9]|[1-3][0-9])-[0-9]{4}$');

  static bool isValid(String? code) {
    if (code == null || !pattern.hasMatch(code)) return false;
    final p = parse(code)!;
    return p.adj < adjectiveCount && p.animal < animalCount;
  }

  /// 형식이 맞으면 (형용사, 동물, 숫자)
  static ({int adj, int animal, String number})? parse(String code) {
    final m = pattern.firstMatch(code);
    if (m == null) return null;
    return (adj: int.parse(m[1]!), animal: int.parse(m[2]!), number: code.substring(code.lastIndexOf('-') + 1));
  }

  static String generate([Random? rng]) {
    final r = rng ?? Random.secure();
    final n = r.nextInt(10000).toString().padLeft(4, '0');
    return '${r.nextInt(adjectiveCount)}-${r.nextInt(animalCount)}-$n';
  }
}

/// 별명 형용사 [i] (0..39). [g]는 동물의 문법적 성(m/f/n) — 프랑스어·독일어 등은 성에 맞춰 형태가 바뀐다.
/// 단어는 ARB(nickAdj0..39 / nickAnimal0..39)에 있고, 인덱스가 곧 서버에 저장되는 값이라 순서를 바꾸지 않는다.
String nicknameAdjective(L10n t, int i, String g) => switch (i) {
      0 => t.nickAdj0(g),
      1 => t.nickAdj1(g),
      2 => t.nickAdj2(g),
      3 => t.nickAdj3(g),
      4 => t.nickAdj4(g),
      5 => t.nickAdj5(g),
      6 => t.nickAdj6(g),
      7 => t.nickAdj7(g),
      8 => t.nickAdj8(g),
      9 => t.nickAdj9(g),
      10 => t.nickAdj10(g),
      11 => t.nickAdj11(g),
      12 => t.nickAdj12(g),
      13 => t.nickAdj13(g),
      14 => t.nickAdj14(g),
      15 => t.nickAdj15(g),
      16 => t.nickAdj16(g),
      17 => t.nickAdj17(g),
      18 => t.nickAdj18(g),
      19 => t.nickAdj19(g),
      20 => t.nickAdj20(g),
      21 => t.nickAdj21(g),
      22 => t.nickAdj22(g),
      23 => t.nickAdj23(g),
      24 => t.nickAdj24(g),
      25 => t.nickAdj25(g),
      26 => t.nickAdj26(g),
      27 => t.nickAdj27(g),
      28 => t.nickAdj28(g),
      29 => t.nickAdj29(g),
      30 => t.nickAdj30(g),
      31 => t.nickAdj31(g),
      32 => t.nickAdj32(g),
      33 => t.nickAdj33(g),
      34 => t.nickAdj34(g),
      35 => t.nickAdj35(g),
      36 => t.nickAdj36(g),
      37 => t.nickAdj37(g),
      38 => t.nickAdj38(g),
      39 => t.nickAdj39(g),
      _ => '?',
    };

/// 별명 동물 [i] (0..39)
String nicknameAnimal(L10n t, int i) => switch (i) {
      0 => t.nickAnimal0,
      1 => t.nickAnimal1,
      2 => t.nickAnimal2,
      3 => t.nickAnimal3,
      4 => t.nickAnimal4,
      5 => t.nickAnimal5,
      6 => t.nickAnimal6,
      7 => t.nickAnimal7,
      8 => t.nickAnimal8,
      9 => t.nickAnimal9,
      10 => t.nickAnimal10,
      11 => t.nickAnimal11,
      12 => t.nickAnimal12,
      13 => t.nickAnimal13,
      14 => t.nickAnimal14,
      15 => t.nickAnimal15,
      16 => t.nickAnimal16,
      17 => t.nickAnimal17,
      18 => t.nickAnimal18,
      19 => t.nickAnimal19,
      20 => t.nickAnimal20,
      21 => t.nickAnimal21,
      22 => t.nickAnimal22,
      23 => t.nickAnimal23,
      24 => t.nickAnimal24,
      25 => t.nickAnimal25,
      26 => t.nickAnimal26,
      27 => t.nickAnimal27,
      28 => t.nickAnimal28,
      29 => t.nickAnimal29,
      30 => t.nickAnimal30,
      31 => t.nickAnimal31,
      32 => t.nickAnimal32,
      33 => t.nickAnimal33,
      34 => t.nickAnimal34,
      35 => t.nickAnimal35,
      36 => t.nickAnimal36,
      37 => t.nickAnimal37,
      38 => t.nickAnimal38,
      39 => t.nickAnimal39,
      _ => '?',
    };

/// 동물 [i]의 문법적 성. 성이 없는 언어는 'm'.
String nicknameGender(L10n t, int i) {
  final list = t.nickGenders.split(',');
  return i < list.length && list[i].isNotEmpty ? list[i].trim() : 'm';
}

/// 별명 코드를 그 언어의 글자로 ("12-7-0427" → "노래하는 돌고래 0427"). 형식이 틀린 코드는 "#코드".
String nicknameText(String code, L10n t) {
  final p = NicknameCode.isValid(code) ? NicknameCode.parse(code) : null;
  if (p == null) return '#$code';
  final animal = nicknameAnimal(t, p.animal);
  final adj = nicknameAdjective(t, p.adj, nicknameGender(t, p.animal));
  return t.nickFormat(adj, animal, p.number);
}

/// 순위표 설정 저장소. 앱에서는 프로필(AppState의 어댑터)이, 테스트에서는 [MemoryLeaderboardStore]가 구현한다.
abstract class LeaderboardStore {
  String? get installId;
  set installId(String? v);

  String? get nicknameCode;
  set nicknameCode(String? v);

  /// 순위표 참여 동의. 기본 꺼짐. 꺼져 있으면 아무것도 보내지 않는다.
  bool get leaderboardOptIn;
  set leaderboardOptIn(bool v);

  /// 별명을 다시 뽑은 횟수 ([LeaderboardService.maxRerolls]까지)
  int get nicknameRerolls;
  set nicknameRerolls(int v);

  /// 값이 바뀐 뒤 저장 (프로필 저장 연결)
  Future<void> save();
}

class MemoryLeaderboardStore implements LeaderboardStore {
  @override
  String? installId;
  @override
  String? nicknameCode;
  @override
  bool leaderboardOptIn = false;
  @override
  int nicknameRerolls = 0;
  int saves = 0;

  @override
  Future<void> save() async => saves++;
}

enum LeaderboardStatus {
  ok,

  /// 참여 동의 전 (보내지 않음)
  optedOut,

  /// 서버 주소·키가 없음 (기능 숨김)
  notConfigured,

  /// 네트워크 없음·시간 초과
  offline,

  /// 1분에 5번 넘게 보냄 (HTTP 429)
  rateLimited,

  /// 서버가 값을 거부 (HTTP 400: 주·점수·별명 형식)
  rejected,

  /// 그 밖의 서버 오류
  serverError,
}

class LeaderboardEntry {
  const LeaderboardEntry({required this.rank, required this.nicknameCode, required this.score, required this.me});
  final int rank;
  final String nicknameCode;
  final int score;
  final bool me;

  static LeaderboardEntry? fromJson(Object? j) {
    if (j is! Map) return null;
    final rank = j['rank'], nick = j['nickname'], score = j['score'], me = j['me'];
    if (rank is! int || nick is! String || score is! int) return null;
    return LeaderboardEntry(rank: rank, nicknameCode: nick, score: score, me: me == true);
  }
}

class SubmitResult {
  const SubmitResult(this.status, {this.rank, this.total});
  final LeaderboardStatus status;
  final int? rank;
  final int? total;
}

class BoardResult {
  const BoardResult(this.status, {this.entries = const []});
  final LeaderboardStatus status;
  final List<LeaderboardEntry> entries;

  LeaderboardEntry? get mine => entries.where((e) => e.me).firstOrNull;
}

/// POST 한 번의 결과 (HTTP 상태, 본문)
typedef LeaderboardPost = Future<(int, String)> Function(String rpc, Map<String, Object?> body);

class LeaderboardService {
  LeaderboardService({required this.store, LeaderboardPost? post, DateTime Function()? clock, Random? rng})
      : _post = post ?? _httpPost,
        _clock = clock ?? DateTime.now,
        _rng = rng ?? Random.secure();

  final LeaderboardStore store;
  final LeaderboardPost _post;
  final DateTime Function() _clock;
  final Random _rng;

  /// 별명 다시 뽑기 한도 (간단하게: 평생 5번)
  static const maxRerolls = 5;

  bool get configured => LeaderboardConfig.configured;
  bool get optedIn => store.leaderboardOptIn;

  /// 처음 부를 때 만든다 (무작위 UUID v4, 광고 ID·기기 ID 아님)
  String get installId {
    final id = store.installId;
    if (id != null && _uuidPattern.hasMatch(id)) return id;
    final made = uuidV4(_rng);
    store.installId = made;
    unawaited(store.save());
    return made;
  }

  String get nicknameCode {
    final c = store.nicknameCode;
    if (NicknameCode.isValid(c)) return c!;
    final made = NicknameCode.generate(_rng);
    store.nicknameCode = made;
    unawaited(store.save());
    return made;
  }

  int get rerollsLeft => max(0, maxRerolls - store.nicknameRerolls);
  bool get canReroll => rerollsLeft > 0;

  /// 새 별명 코드를 뽑는다. 한도를 넘으면 그대로 둔다. 서버에는 다음 점수 제출 때 반영된다.
  String reroll() {
    if (!canReroll) return nicknameCode;
    var next = NicknameCode.generate(_rng);
    while (next == store.nicknameCode) {
      next = NicknameCode.generate(_rng);
    }
    store
      ..nicknameCode = next
      ..nicknameRerolls = store.nicknameRerolls + 1;
    unawaited(store.save());
    return next;
  }

  Future<void> setOptIn(bool v) async {
    store.leaderboardOptIn = v;
    if (v) {
      installId;
      nicknameCode;
    }
    await store.save();
  }

  int get currentWeek => isoWeekKey(_clock());

  /// 점수 제출. 동의 전·설정 없음이면 보내지 않는다. 예외를 던지지 않는다.
  Future<SubmitResult> submit(int week, int score) async {
    if (!configured) return const SubmitResult(LeaderboardStatus.notConfigured);
    if (!optedIn) return const SubmitResult(LeaderboardStatus.optedOut);
    final r = await _call('starset_submit_score', {
      'p_install_id': installId,
      'p_nickname': nicknameCode,
      'p_week': week,
      'p_score': score.clamp(0, WeeklyScore.maxPoints),
    });
    if (r.$1 != LeaderboardStatus.ok) return SubmitResult(r.$1);
    final j = r.$2;
    if (j is Map && j['rank'] is int && j['total'] is int) {
      return SubmitResult(LeaderboardStatus.ok, rank: j['rank'] as int, total: j['total'] as int);
    }
    return const SubmitResult(LeaderboardStatus.serverError);
  }

  /// 지난주에서 넘어온 점수가 있으면 먼저 보내고, 이번 주 점수를 보낸다.
  /// 지난주 점수는 보냈으면(또는 서버가 거부했으면) 비운다.
  Future<SubmitResult> submitWeekly(WeeklyScore s) async {
    s.rollover(_clock());
    final last = s.lastWeek;
    if (last != null && s.lastPoints > 0 && optedIn && configured) {
      final r = await submit(last, s.lastPoints);
      if (r.status == LeaderboardStatus.ok || r.status == LeaderboardStatus.rejected) {
        s
          ..lastWeek = null
          ..lastPoints = 0;
      }
    }
    return submit(s.week, s.points);
  }

  /// 상위 50 + 내 줄. 동의 전에도 볼 수는 있다 (내 ID는 동의했을 때만 보낸다).
  Future<BoardResult> fetch(int week) async {
    if (!configured) return const BoardResult(LeaderboardStatus.notConfigured);
    final r = await _call('starset_leaderboard', {
      'p_week': week,
      'p_install_id': optedIn ? installId : null,
    });
    if (r.$1 != LeaderboardStatus.ok) return BoardResult(r.$1);
    final j = r.$2;
    if (j is! List) return const BoardResult(LeaderboardStatus.serverError);
    final entries = [for (final e in j) ?LeaderboardEntry.fromJson(e)];
    return BoardResult(LeaderboardStatus.ok, entries: entries);
  }

  /// 이 설치의 서버 기록(별명·점수)을 지운다 ("모든 데이터 초기화"). 동의 여부와 무관하게 [installId]로 부른다.
  /// 예외를 던지지 않는다. 기다리지 않아도 된다.
  Future<LeaderboardStatus> forget(String installId) async {
    if (!configured || !_uuidPattern.hasMatch(installId)) return LeaderboardStatus.notConfigured;
    final r = await _call('starset_forget', {'p_install_id': installId});
    return r.$1;
  }

  Future<(LeaderboardStatus, Object?)> _call(String rpc, Map<String, Object?> body) async {
    try {
      final (code, text) = await _post(rpc, body).timeout(LeaderboardConfig.timeout);
      final status = statusForHttp(code);
      if (status != LeaderboardStatus.ok) return (status, null);
      return (LeaderboardStatus.ok, jsonDecode(text));
    } on TimeoutException {
      return (LeaderboardStatus.offline, null);
    } on SocketException {
      return (LeaderboardStatus.offline, null);
    } on HandshakeException {
      return (LeaderboardStatus.offline, null);
    } on HttpException {
      return (LeaderboardStatus.offline, null);
    } on FormatException {
      return (LeaderboardStatus.serverError, null);
    } catch (_) {
      return (LeaderboardStatus.serverError, null);
    }
  }

  static LeaderboardStatus statusForHttp(int code) => switch (code) {
        >= 200 && < 300 => LeaderboardStatus.ok,
        429 => LeaderboardStatus.rateLimited,
        400 => LeaderboardStatus.rejected,
        _ => LeaderboardStatus.serverError,
      };

  static Future<(int, String)> _httpPost(String rpc, Map<String, Object?> body) =>
      supabaseRpcPost(LeaderboardConfig.baseUrl, LeaderboardConfig.anonKey, LeaderboardConfig.timeout, rpc, body);
}

final _uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

/// 무작위 UUID v4 (소문자)
String uuidV4([Random? rng]) {
  final r = rng ?? Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

/// 테스트용: uuid 형식 확인
bool isUuidV4(String s) => _uuidPattern.hasMatch(s);
