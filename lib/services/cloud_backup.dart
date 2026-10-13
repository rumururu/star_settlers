import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:games_services/games_services.dart';

import '../game/profile.dart';
import '../game/save.dart';

/// 플랫폼 게임 계정의 저장 슬롯 (Android: Play 게임즈 저장 게임, iOS: Game Center 저장 게임 = iCloud).
/// 테스트는 가짜로 바꿔 끼운다.
abstract class CloudSaveGateway {
  /// 계정 연결 (필요하면 플랫폼 로그인 창). 연결되면 표시 이름, 아니면 null
  Future<String?> signIn();
  Future<bool> get isSignedIn;
  Future<void> write(String name, String data);

  /// 슬롯이 없으면 null
  Future<String?> read(String name);
}

class GamesServicesGateway implements CloudSaveGateway {
  @override
  Future<String?> signIn() async {
    await GamesServices.signIn();
    if (!await isSignedIn) return null;
    return await GamesServices.getPlayerName() ?? '';
  }

  @override
  Future<bool> get isSignedIn => GamesServices.isSignedIn;

  @override
  Future<void> write(String name, String data) async {
    await GamesServices.saveGame(data: data, name: name);
  }

  @override
  Future<String?> read(String name) async {
    final games = await GamesServices.getSavedGames(forceRefresh: true) ?? const [];
    if (!games.any((g) => g.name == name)) return null;
    return GamesServices.loadGame(name: name);
  }
}

/// 클라우드에 있는 백업 한 벌: 프로필(설치 ID 포함 = 젬 지갑·결제 ID) + 진행 중인 월드
class CloudSnapshot {
  CloudSnapshot({required this.savedAt, required this.profile, required this.world});

  final DateTime savedAt;
  final Map<String, dynamic> profile;

  /// 월드 저장 원문 (게임을 시작하지 않았으면 null)
  final String? world;

  String? get installId => profile['lbId'] as String?;

  static const version = 1;

  String encode() => jsonEncode({
        'v': version,
        'app': 'star_settlers',
        'savedAt': savedAt.toUtc().toIso8601String(),
        'profile': profile,
        'world': world,
      });

  /// 다른 앱·더 새 버전·손상된 백업이면 null
  static CloudSnapshot? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      if (j['app'] != 'star_settlers' || (j['v'] as int? ?? 0) > version) return null;
      final p = (j['profile'] as Map).cast<String, dynamic>();
      Profile.fromJson(p); // 읽을 수 있는지 미리 확인
      return CloudSnapshot(
        savedAt: DateTime.parse(j['savedAt'] as String).toLocal(),
        profile: p,
        world: j['world'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

enum BackupStatus { ok, notSignedIn, nothingToRestore, failed }

/// 클라우드 백업. 계정을 연결하고 '지금 백업' 또는 '복원'을 한 번 하면 그 기기에서 자동 백업이 켜진다
/// ([Profile.cloudLinked]). 새 기기에서 연결만 한 상태로 자동 백업하면 클라우드의 진행을 덮어쓰기 때문이다.
class CloudBackup {
  CloudBackup({
    CloudSaveGateway? gateway,
    required this.profile,
    required this.saveProfile,
    required this.readWorld,
    required this.writeAll,
    DateTime Function()? clock,
  })  : _gw = gateway ?? GamesServicesGateway(),
        _clock = clock ?? DateTime.now;

  final CloudSaveGateway _gw;
  final Profile Function() profile;
  final Future<void> Function() saveProfile;
  final Future<String?> Function() readWorld;

  /// 복원: 프로필 JSON과 월드 원문을 기기 저장소에 쓴다
  final Future<void> Function(Map<String, dynamic> profile, String? world) writeAll;
  final DateTime Function() _clock;

  static const slot = 'star_settlers_backup';

  /// 자동 백업 최소 간격
  static const autoInterval = Duration(minutes: 10);

  /// Play 게임즈 / Game Center가 있는 플랫폼인지
  static bool get supported => !kIsWeb;

  String? playerName;
  bool _busy = false;
  DateTime? _lastAuto;

  Future<bool> get isSignedIn async {
    try {
      return await _gw.isSignedIn;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signIn() async {
    try {
      playerName = await _gw.signIn();
      return playerName != null;
    } catch (e) {
      debugPrint('cloud sign-in failed: $e');
      return false;
    }
  }

  /// 앱 시작 때: 전에 연결해 둔 기기면 조용히 다시 연결한다 (창이 뜨는 첫 연결은 설정에서)
  Future<void> resume() async {
    if (!profile().cloudLinked) return;
    await signIn();
  }

  /// 클라우드 백업 정보 (복원 확인창에 시각을 보여 준다)
  Future<(BackupStatus, CloudSnapshot?)> peek() async {
    if (!await isSignedIn) return (BackupStatus.notSignedIn, null);
    try {
      final s = CloudSnapshot.decode(await _gw.read(slot));
      return (s == null ? BackupStatus.nothingToRestore : BackupStatus.ok, s);
    } catch (e) {
      debugPrint('cloud read failed: $e');
      return (BackupStatus.failed, null);
    }
  }

  Future<BackupStatus> backupNow() async {
    if (_busy) return BackupStatus.failed;
    if (!await isSignedIn) return BackupStatus.notSignedIn;
    _busy = true;
    try {
      final p = profile();
      final now = _clock();
      p
        ..cloudLinked = true
        ..cloudBackupAt = now;
      await saveProfile();
      final snap = CloudSnapshot(savedAt: now, profile: p.toJson(), world: await readWorld());
      await _gw.write(slot, snap.encode());
      _lastAuto = now;
      return BackupStatus.ok;
    } catch (e) {
      debugPrint('cloud backup failed: $e');
      return BackupStatus.failed;
    } finally {
      _busy = false;
    }
  }

  /// 앱이 내려갈 때·게임에서 나갈 때. 이 기기에서 백업이나 복원을 한 적이 있을 때만, 10분에 한 번.
  Future<void> auto() async {
    if (!profile().cloudLinked) return;
    final last = _lastAuto;
    final now = _clock();
    if (last != null && now.difference(last) < autoInterval) return;
    _lastAuto = now;
    await backupNow();
  }

  /// 클라우드 백업으로 이 기기의 진행을 바꾼다. 설치 ID도 백업의 것으로 돌아오므로 젬 지갑·결제가 따라온다.
  /// 성공하면 새 프로필을 돌려준다 (부르는 쪽이 앱 상태에 반영).
  Future<(BackupStatus, Profile?)> restore(CloudSnapshot snap) async {
    try {
      final restored = Profile.fromJson(snap.profile)
        ..cloudLinked = true
        ..cloudBackupAt = snap.savedAt
        ..prepaid = 0;
      await writeAll(restored.toJson(), snap.world);
      _lastAuto = _clock();
      return (BackupStatus.ok, restored);
    } catch (e) {
      debugPrint('cloud restore failed: $e');
      return (BackupStatus.failed, null);
    }
  }

  /// 앱 기본 연결 (SharedPreferences 저장소)
  static CloudBackup standard(Profile Function() profile) => CloudBackup(
        profile: profile,
        saveProfile: () => SaveService.saveProfile(profile()),
        readWorld: SaveService.rawWorld,
        writeAll: SaveService.writeRaw,
      );
}
