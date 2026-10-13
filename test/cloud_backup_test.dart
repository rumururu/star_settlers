import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/save.dart';
import 'package:star_settlers/services/app_state.dart';
import 'package:star_settlers/services/cloud_backup.dart';
import 'package:star_settlers/services/wallet.dart';

import 'wallet_test.dart' show FakeWalletServer;

/// Play 게임즈 / Game Center 저장 슬롯 흉내
class FakeGateway implements CloudSaveGateway {
  bool signedIn = false;
  bool canSignIn = true;
  bool offline = false;
  final slots = <String, String>{};
  int writes = 0;

  @override
  Future<String?> signIn() async {
    signedIn = canSignIn;
    return signedIn ? 'Captain' : null;
  }

  @override
  Future<bool> get isSignedIn async => signedIn;

  @override
  Future<void> write(String name, String data) async {
    if (offline) throw Exception('offline');
    writes++;
    slots[name] = data;
  }

  @override
  Future<String?> read(String name) async {
    if (offline) throw Exception('offline');
    return slots[name];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeGateway gw;
  late DateTime now;
  late CloudBackup cloud;
  const idA = '11111111-2222-4333-8444-555555555555';
  const idB = '99999999-8888-4777-8666-555555555555';

  CloudBackup make() => CloudBackup(
        gateway: gw,
        profile: () => AppState.profile,
        saveProfile: () => SaveService.saveProfile(AppState.profile),
        readWorld: SaveService.rawWorld,
        writeAll: SaveService.writeRaw,
        clock: () => now,
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({'star_settlers_world_v2': '{"sector":3}'});
    gw = FakeGateway();
    now = DateTime(2026, 10, 13, 9);
    AppState.profile = Profile()
      ..installId = idA
      ..honor = 42;
    cloud = make();
  });

  test('백업 한 벌에는 프로필(설치 ID 포함)과 월드 원문이 들어가고, 다시 읽힌다', () async {
    gw.signedIn = true;
    expect(await cloud.backupNow(), BackupStatus.ok);
    final snap = CloudSnapshot.decode(gw.slots[CloudBackup.slot]);
    expect(snap, isNotNull);
    expect(snap!.installId, idA);
    expect(snap.profile['honor'], 42);
    expect(snap.world, '{"sector":3}');
    expect(snap.savedAt, now);
    expect(AppState.profile.cloudLinked, isTrue);
    expect(AppState.profile.cloudBackupAt, now);
  });

  test('다른 앱·더 새 버전·손상된 백업은 읽지 않는다', () {
    expect(CloudSnapshot.decode(null), isNull);
    expect(CloudSnapshot.decode('not json'), isNull);
    expect(CloudSnapshot.decode(jsonEncode({'app': 'other', 'v': 1, 'savedAt': '2026-01-01T00:00:00Z', 'profile': {}})),
        isNull);
    expect(
        CloudSnapshot.decode(jsonEncode({'app': 'star_settlers', 'v': 99, 'savedAt': '2026-01-01T00:00:00Z', 'profile': {}})),
        isNull);
  });

  test('연결되지 않았으면 백업하지 않는다', () async {
    expect(await cloud.backupNow(), BackupStatus.notSignedIn);
    expect(gw.writes, 0);
    expect(AppState.profile.cloudLinked, isFalse);
  });

  test('자동 백업은 이 기기에서 백업이나 복원을 한 뒤에만, 10분에 한 번', () async {
    gw.signedIn = true;
    await cloud.auto();
    expect(gw.writes, 0, reason: '새 기기에서 연결만 하고 자동 백업하면 클라우드 진행을 덮어쓴다');
    await cloud.backupNow();
    expect(gw.writes, 1);
    now = now.add(const Duration(minutes: 5));
    await cloud.auto();
    expect(gw.writes, 1);
    now = now.add(const Duration(minutes: 6));
    await cloud.auto();
    expect(gw.writes, 2);
  });

  test('백업이 실패해도 앱은 멈추지 않고 이유를 돌려준다', () async {
    gw
      ..signedIn = true
      ..offline = true;
    expect(await cloud.backupNow(), BackupStatus.failed);
    expect((await cloud.peek()).$1, BackupStatus.failed);
  });

  test('복원: 기기 저장을 백업으로 바꾸고, 설치 ID가 돌아와 서버 지갑·결제 사용자가 따라온다', () async {
    // 기기 A에서 백업
    gw.signedIn = true;
    AppState.profile.premium = true;
    await cloud.backupNow();

    // 새 기기 B (다른 설치 ID, 다른 진행)
    SharedPreferences.setMockInitialValues({'star_settlers_world_v2': '{"sector":1}'});
    AppState.profile = Profile()..installId = idB;
    final server = FakeWalletServer()..gems = 305;
    final wallet = GemWallet(
      profile: () => AppState.profile,
      installId: () => AppState.profile.installId!,
      save: () async {},
      onFlags: AppState.applyPurchaseFlags,
      post: server.post,
    );
    AppState.wallet = wallet;
    Profile.onEarn = wallet.earned;
    addTearDown(() => Profile.onEarn = null);
    cloud = make();

    final (status, snap) = await cloud.peek();
    expect(status, BackupStatus.ok);
    final (r, restored) = await cloud.restore(snap!);
    expect(r, BackupStatus.ok);
    await AppState.adoptRestored(restored!);

    expect(AppState.profile.installId, idA);
    expect(AppState.profile.honor, 42);
    expect(AppState.profile.cloudLinked, isTrue, reason: '복원한 기기는 이어서 자동 백업한다');
    expect(AppState.money.appUserId, idA, reason: '결제 사용자도 백업의 설치 ID로');
    expect(AppState.profile.gems, 305, reason: '젬은 백업이 아니라 서버 지갑 값');
    expect(AppState.world, isNull);
    expect(await SaveService.rawWorld(), '{"sector":3}');
    final saved = await SaveService.loadProfile();
    expect(saved.installId, idA);
  });

  test('복원할 백업이 없으면 그렇게 알려 준다', () async {
    gw.signedIn = true;
    final (status, snap) = await cloud.peek();
    expect(status, BackupStatus.nothingToRestore);
    expect(snap, isNull);
  });

  test('데이터 초기화하면 자동 백업이 꺼진다 (빈 진행으로 클라우드를 덮어쓰지 않게)', () async {
    gw.signedIn = true;
    await cloud.backupNow();
    AppState.resetProfile();
    expect(AppState.profile.cloudLinked, isFalse);
    now = now.add(const Duration(hours: 1));
    await cloud.auto();
    expect(gw.writes, 1);
  });
}
