import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/wallet.dart';

/// 서버 함수를 흉내 낸다 (supabase/wallet/migrations 규칙 중 앱이 기대는 부분: 요청 ID 1회, 업적 1회,
/// 플레이 하루 상한, 잔액 부족 거절, 초기화). 실제 서버 검사는 supabase/wallet/tests/live.sh.
class FakeWalletServer {
  int gems = 0;
  int purchases = 0;
  bool premium = false, starter = false;
  int playToday = 0;
  int playCap = 1000;
  bool offline = false;
  final answered = <String, Map<String, Object?>>{};
  final achievements = <String>{};
  final calls = <String>[];

  Map<String, Object?> get wallet =>
      {'gems': gems, 'premium': premium, 'starter': starter, 'purchases': purchases};

  Future<(int, String)> post(String rpc, Map<String, Object?> b) async {
    if (offline) throw const SocketException('offline');
    calls.add(rpc);
    final ref = b['p_ref'] as String?;
    if (ref != null && answered.containsKey(ref)) {
      return (200, jsonEncode({...answered[ref]!, 'wallet': wallet, 'repeat': true}));
    }
    Map<String, Object?> res;
    switch (rpc) {
      case 'starset_wallet':
        return (200, jsonEncode(wallet));
      case 'starset_earn':
        final source = b['p_source'], amount = b['p_amount'] as int;
        var give = 0;
        if (source == 'play') {
          give = amount.clamp(0, playCap - playToday);
          playToday += give;
        } else if (source == 'ach') {
          give = achievements.add(b['p_key'] as String) ? 5 : 0;
        } else if (source == 'login' || source == 'quest' || source == 'ad') {
          give = amount;
        } else {
          return (400, '{"message":"invalid source"}');
        }
        gems += give;
        res = {'ok': true, 'credited': give};
      case 'starset_spend':
        final n = b['p_amount'] as int;
        if (gems < n) return (200, jsonEncode({'ok': false, 'reason': 'not enough', 'wallet': wallet}));
        gems -= n;
        res = {'ok': true, 'spent': n};
      case 'starset_wipe':
        res = {'ok': true, 'wiped': gems};
        gems = 0;
      default:
        return (404, '');
    }
    answered[ref!] = res;
    return (200, jsonEncode({...res, 'wallet': wallet}));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeWalletServer server;
  late GemWallet wallet;
  const id = '9b2c1d7e-3f4a-4b5c-8d6e-7f8091a2b3c4';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    server = FakeWalletServer();
    AppState.profile = Profile()..installId = id;
    wallet = GemWallet(
      profile: () => AppState.profile,
      installId: () => id,
      save: () async {},
      onFlags: AppState.applyPurchaseFlags,
      post: server.post,
    );
    AppState.wallet = wallet;
    Profile.onEarn = wallet.earned;
  });

  tearDown(() => Profile.onEarn = null);

  test('기기에서 젬 숫자를 바꿔도 서버가 차감해 주지 않으면 쓸 수 없다', () async {
    final p = AppState.profile..gems = 99999; // 저장 파일 조작
    expect(p.spendGems(100), isFalse);
    expect(await AppState.payGems(100, 'ship'), isFalse);
    expect(AppState.lastPay, WalletStatus.notEnough);
    expect(server.gems, 0);
  });

  test('서버가 차감하면 그만큼만 게임에서 쓸 수 있고, 화면 값은 서버를 따른다', () async {
    server.gems = 150;
    await wallet.refresh();
    expect(AppState.profile.gems, 150);
    expect(await AppState.payGems(100, 'ship'), isTrue);
    expect(server.gems, 50);
    expect(AppState.profile.gems, 150, reason: '차감받은 100은 게임이 쓰기 전까지 화면에 남는다');
    expect(AppState.profile.spendGems(100), isTrue);
    expect(AppState.profile.gems, 50);
    expect(AppState.profile.spendGems(1), isFalse, reason: '차감받지 않은 젬은 못 쓴다');
  });

  test('플레이 수입은 모았다가 한 요청으로 보내고, 하루 상한을 넘은 몫은 다음에 다시 보낸다', () async {
    server.playCap = 10;
    final p = AppState.profile;
    for (var i = 0; i < 7; i++) {
      p.earnGems('play', '', 2);
    }
    expect(p.gems, 14);
    await wallet.flush();
    expect(server.calls.where((c) => c == 'starset_earn').length, 1);
    expect(server.gems, 10);
    expect(p.walletPlay, 4, reason: '상한에 걸린 4는 버리지 않고 남겨 둔다');
    expect(p.gems, 14);
    server
      ..playToday = 0 // 다음 날
      ..playCap = 1000;
    await wallet.flush();
    expect(server.gems, 14);
    expect(p.walletPlay, 0);
  });

  test('오프라인에서 번 젬은 저장되었다가, 다시 켜면 같은 요청 ID로 보낸다', () async {
    server.offline = true;
    AppState.profile
      ..addStat(achievements.first.stat, achievements.first.target)
      ..claim(achievements.first);
    await wallet.flush();
    expect(AppState.profile.walletOutbox, hasLength(1));
    final ref = AppState.profile.walletOutbox.first['r'];
    // 저장 → 앱 재시작
    final back = Profile.fromJson(jsonDecode(jsonEncode(AppState.profile.toJson())) as Map<String, dynamic>);
    AppState.profile = back;
    expect(back.walletOutbox.single['r'], ref);
    server.offline = false;
    await wallet.refresh();
    expect(server.gems, 5);
    expect(back.walletOutbox, isEmpty);
    expect(back.gems, 5);
  });

  test('서버가 이미 준 업적이면 화면 값도 서버대로 돌아간다', () async {
    server.achievements.add(achievements.first.id);
    AppState.profile
      ..addStat(achievements.first.stat, achievements.first.target)
      ..claim(achievements.first);
    expect(AppState.profile.gems, achievements.first.gems);
    await wallet.flush();
    expect(AppState.profile.gems, 0);
  });

  test('서버에 연결하지 못하면 쓰지 못하고 이유가 남는다', () async {
    server.gems = 100;
    await wallet.refresh();
    server.offline = true;
    expect(await AppState.payGems(10, 'revive'), isFalse);
    expect(AppState.lastPay, WalletStatus.offline);
    expect(AppState.profile.spendGems(10), isFalse);
  });

  test('서버가 거부한 수입(규칙 밖)은 버리고 다음 것을 보낸다', () async {
    AppState.profile.walletOutbox.add({'r': 'aaaaaaaaaaaa', 's': 'made_up', 'k': '', 'a': 5, 'd': 20261013});
    AppState.profile.earnGems('ad', '', 5);
    await wallet.flush();
    expect(AppState.profile.walletOutbox, isEmpty);
    expect(server.gems, 5);
    expect(AppState.profile.gems, 5);
  });

  test('초기화: 서버 젬을 비우고 결제 표시는 남는다 (사령관 패스가 돌아온다)', () async {
    server
      ..gems = 700
      ..premium = true;
    await wallet.refresh();
    expect(AppState.profile.premium, isTrue);
    AppState.resetProfile();
    await wallet.refresh();
    expect(server.gems, 0);
    expect(AppState.profile.gems, 0);
    expect(AppState.profile.premium, isTrue);
    expect(AppState.profile.installId, id);
  });

  test('결제 뒤 서버 결제 수가 늘면 지급이 끝난 것으로 본다', () async {
    final before = AppState.profile.walletPurchases;
    server
      ..gems += 550
      ..purchases += 1;
    expect(await wallet.waitForPurchase(before, wait: const Duration(seconds: 1)), isTrue);
    expect(AppState.profile.gems, 550);
  });
}
