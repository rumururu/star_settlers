import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../game/profile.dart';
import 'leaderboard.dart' show uuidV4;
import 'rpc.dart';

/// 젬 지갑 서버 (claires-ranch 프로젝트, 접두사 starset_).
/// 서버 원본: supabase/wallet/migrations/20261012000000_starset_wallet.sql
///
/// 젬은 서버에만 있다. 앱은
/// - 번 젬을 알린다 ([earned] → starset_earn). 서버가 규칙(업적 1회, 하루 횟수, 플레이 하루 상한)대로 확정한다.
/// - 쓸 때 서버에 먼저 차감을 받는다 ([spend] → starset_spend). 서버가 거절하면 쓰지 못한다.
/// - 결제는 앱이 지급하지 않는다. RevenueCat이 서버(starset-purchase-webhook)에 알리고 서버가 지급한다.
/// 화면 젬([Profile.gems]) = 서버 잔액 + 아직 못 보낸 수입 + 이미 차감받고 아직 안 쓴 젬.
abstract final class WalletConfig {
  static const baseUrl = 'https://wthrfgiotkzjxmroljwt.supabase.co';

  /// 공개(anon) 키. 서버는 함수 3개(starset_wallet·starset_earn·starset_spend)만 anon에 열어 두었다.
  static const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0aHJmZ2lvdGt6anhtcm9sand0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2OTk0MTEsImV4cCI6MjEwNzI3NTQxMX0.UhxqvnJ5JwMKX6AEhTZHlUZy22E2LD2Q71dncq_dHQ8';

  static const timeout = Duration(seconds: 8);
}

enum WalletStatus {
  ok,

  /// 잔액 부족 (서버 판단)
  notEnough,

  /// 네트워크 없음·시간 초과
  offline,

  /// 서버가 요청을 거부 (HTTP 400)
  rejected,

  /// 1분에 60번 넘게 부름 (HTTP 429)
  rateLimited,

  serverError,
}

/// POST 한 번의 결과 (HTTP 상태, 본문)
typedef WalletPost = Future<(int, String)> Function(String rpc, Map<String, Object?> body);

class GemWallet {
  GemWallet({
    required this.profile,
    required this.installId,
    required this.save,
    this.onFlags,
    WalletPost? post,
    DateTime Function()? clock,
    Random? rng,
  })  : _post = post ?? _httpPost,
        _clock = clock ?? DateTime.now,
        _rng = rng ?? Random.secure();

  /// 지금 프로필 (초기화로 바뀔 수 있어 매번 읽는다)
  final Profile Function() profile;
  final String Function() installId;
  final Future<void> Function() save;

  /// 서버의 결제 표시(premium, starter)가 왔을 때 (꾸미기·승무원 지급은 앱이 한다)
  final void Function(bool premium, bool starter)? onFlags;

  final WalletPost _post;
  final DateTime Function() _clock;
  final Random _rng;

  /// 잔액이 바뀌면 값이 바뀐다 (화면 갱신용)
  final changed = StreamController<int>.broadcast();

  /// 서버 호출은 한 번에 하나씩 (수입·차감 순서가 섞이지 않게)
  Future<void> _chain = Future.value();

  Timer? _playTimer;

  /// 플레이 수입을 모아서 보내는 간격
  static const playFlushEvery = Duration(seconds: 60);

  /// 결제 뒤 서버 지급을 기다리는 간격과 최대 시간
  static const purchasePoll = Duration(seconds: 2);
  static const purchaseWait = Duration(seconds: 40);

  Future<T> _serial<T>(Future<T> Function() f) {
    final c = Completer<T>();
    _chain = _chain.then((_) async {
      try {
        c.complete(await f());
      } catch (e, st) {
        c.completeError(e, st);
      }
    });
    return c.future;
  }

  int _outboxSum(Profile p) => p.walletOutbox.fold(0, (s, o) => s + ((o['a'] as int?) ?? 0));

  /// 화면 젬을 서버 기준으로 다시 맞춘다
  void recompute() {
    final p = profile();
    final g = p.walletGems + _outboxSum(p) + p.walletPlay + p.prepaid;
    if (g != p.gems) {
      p.gems = g;
      p.dirty = true;
    }
    changed.add(p.gems);
  }

  String _ref() => uuidV4(_rng).replaceAll('-', '');

  /// [Profile.onEarn]에 연결된다. 플레이 수입은 모아 두고, 나머지는 바로 요청을 만든다.
  void earned(String source, String key, int amount) {
    final p = profile();
    if (source == 'play') {
      p.walletPlay += amount;
      _playTimer ??= Timer(playFlushEvery, () {
        _playTimer = null;
        unawaited(flush());
      });
    } else {
      p.walletOutbox.add({'r': _ref(), 's': source, 'k': key, 'a': amount, 'd': Profile.dayKey(_clock())});
      unawaited(flush());
    }
    p.dirty = true;
    changed.add(p.gems);
  }

  /// "모든 데이터 초기화": 서버 젬을 0으로 (결제 표시는 남아 스타터 팩·사령관 패스가 돌아온다).
  /// 오프라인이어도 보낼 목록 맨 앞에 두었다가 연결되면 보낸다.
  void wipe() {
    final p = profile();
    p.walletOutbox.insert(0, {'r': _ref(), 's': 'wipe', 'k': '', 'a': 0, 'd': Profile.dayKey(_clock())});
    p.walletGems = 0;
    p.walletPlay = 0;
    p.dirty = true;
    recompute();
    unawaited(refresh());
  }

  /// 서버 잔액·결제 표시를 받아 온다. 그 전에 쌓인 수입을 보낸다.
  Future<WalletStatus> refresh() => _serial(() async {
        final s = await _flushNow();
        if (s == WalletStatus.offline) return s;
        final r = await _call('starset_wallet', {'p_install_id': installId()});
        if (r.$1 == WalletStatus.ok) {
          _apply(r.$2);
          await save(); // 서버 값을 저장해 두어야 다음 실행(오프라인 포함)에도 서버 잔액부터 보인다
        }
        return r.$1;
      });

  /// 쌓인 수입을 보낸다. 실패하면 남겨 두었다가 다음에 다시 보낸다.
  Future<WalletStatus> flush() => _serial(_flushNow);

  Future<WalletStatus> _flushNow() async {
    final p = profile();
    if (p.walletPlay > 0) {
      p.walletOutbox.add({'r': _ref(), 's': 'play', 'k': '', 'a': p.walletPlay, 'd': Profile.dayKey(_clock())});
      p.walletPlay = 0;
    }
    var changedAny = false;
    var status = WalletStatus.ok;
    while (p.walletOutbox.isNotEmpty) {
      final o = p.walletOutbox.first;
      final r = o['s'] == 'wipe'
          ? await _call('starset_wipe', {'p_install_id': installId(), 'p_ref': o['r']})
          : await _call('starset_earn', {
              'p_install_id': installId(),
              'p_ref': o['r'],
              'p_source': o['s'],
              'p_key': o['k'],
              'p_amount': o['a'],
              'p_day': o['d'],
            });
      if (r.$1 == WalletStatus.ok) {
        p.walletOutbox.removeAt(0);
        final j = r.$2;
        final credited = j is Map ? (j['credited'] as int? ?? 0) : 0;
        // 플레이 수입이 하루 상한에 걸려 남은 몫은 다음에 다시 보낸다 (정직한 플레이어는 잃지 않는다)
        final asked = o['a'] as int? ?? 0;
        if (o['s'] == 'play' && credited < asked) p.walletPlay += asked - credited;
        _apply(j is Map ? j['wallet'] : null, recomputeNow: false);
        changedAny = true;
      } else if (r.$1 == WalletStatus.rejected) {
        p.walletOutbox.removeAt(0); // 서버 규칙에 맞지 않는 요청 (오래된 날짜 등): 버린다
        changedAny = true;
      } else {
        status = r.$1;
        break;
      }
    }
    if (changedAny) {
      recompute();
      await save();
    }
    return status;
  }

  /// 서버에서 [n]을 차감받는다. 먼저 쌓인 수입을 보내고, 응답을 잃으면 같은 요청 ID로 한 번 더 묻는다.
  Future<WalletStatus> spend(int n, String reason) => _serial(() async {
        final s = await _flushNow();
        if (s == WalletStatus.offline) return s;
        final body = {'p_install_id': installId(), 'p_ref': _ref(), 'p_reason': reason, 'p_amount': n};
        var r = await _call('starset_spend', body);
        if (r.$1 == WalletStatus.offline) r = await _call('starset_spend', body);
        if (r.$1 != WalletStatus.ok) return r.$1;
        final j = r.$2;
        if (j is! Map) return WalletStatus.serverError;
        final ok = j['ok'] == true;
        if (ok) profile().prepaid += n; // 화면 값이 그대로 유지되게 (게임이 쓰면 그때 줄어든다)
        _apply(j['wallet']);
        await save();
        return ok ? WalletStatus.ok : WalletStatus.notEnough;
      });

  /// 결제·복원 직후: 서버의 결제 수가 [before]보다 늘 때까지 기다린다 (최대 [wait]). 늘었으면 true.
  Future<bool> waitForPurchase(int before, {Duration wait = purchaseWait}) async {
    final end = _clock().add(wait);
    while (_clock().isBefore(end)) {
      await refresh();
      if (profile().walletPurchases > before) return true;
      await Future<void>.delayed(purchasePoll);
    }
    return false;
  }

  void _apply(Object? w, {bool recomputeNow = true}) {
    if (w is! Map) return;
    final p = profile();
    if (w['gems'] is int) p.walletGems = w['gems'] as int;
    if (w['purchases'] is int) p.walletPurchases = w['purchases'] as int;
    final premium = w['premium'], starter = w['starter'];
    if (premium is bool && starter is bool) onFlags?.call(premium, starter);
    p.dirty = true;
    if (recomputeNow) recompute();
  }

  Future<(WalletStatus, Object?)> _call(String rpc, Map<String, Object?> body) async {
    try {
      final (code, text) = await _post(rpc, body).timeout(WalletConfig.timeout);
      final status = switch (code) {
        >= 200 && < 300 => WalletStatus.ok,
        429 => WalletStatus.rateLimited,
        400 => WalletStatus.rejected,
        _ => WalletStatus.serverError,
      };
      if (status != WalletStatus.ok) return (status, null);
      return (WalletStatus.ok, jsonDecode(text));
    } on TimeoutException {
      return (WalletStatus.offline, null);
    } on SocketException {
      return (WalletStatus.offline, null);
    } on HandshakeException {
      return (WalletStatus.offline, null);
    } on HttpException {
      return (WalletStatus.offline, null);
    } catch (_) {
      return (WalletStatus.serverError, null);
    }
  }

  static Future<(int, String)> _httpPost(String rpc, Map<String, Object?> body) =>
      supabaseRpcPost(WalletConfig.baseUrl, WalletConfig.anonKey, WalletConfig.timeout, rpc, body);
}
