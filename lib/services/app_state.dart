import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;

import '../game/models.dart';
import '../game/profile.dart';
import '../game/save.dart';
import '../game/world.dart';
import 'ads.dart';
import 'audio.dart';
import 'cloud_backup.dart';
import 'leaderboard.dart';
import 'monetization.dart';
import 'notifications.dart';
import 'wallet.dart';

/// 앱 전역 상태: 프로필, 결제, 오디오, 현재 월드
class AppState {
  AppState._();

  static Profile profile = Profile();
  static final MonetizationService money = MonetizationService.create();
  static GameWorld? world;

  /// 주간 순위표. 저장소는 항상 현재 [profile]을 가리킨다 (초기화로 프로필이 바뀌어도).
  static final LeaderboardService leaderboard = LeaderboardService(store: _ProfileLeaderboardStore());

  /// 젬 지갑 (서버). [useServerWallet]일 때만 연결한다. 테스트는 가짜 서버로 바꿔 끼운다.
  static GemWallet wallet = GemWallet(
    profile: () => profile,
    installId: () => leaderboard.installId,
    save: () => SaveService.saveProfile(profile),
    onFlags: applyPurchaseFlags,
  );

  /// 클라우드 백업 (Play 게임즈 / Game Center)
  static CloudBackup cloud = CloudBackup.standard(() => profile);

  /// 젬을 서버 지갑으로 셀지. 결제(RevenueCat)가 켜진 빌드는 모두 서버를 쓴다.
  /// 웹 데모와 결제 키 없는 개발 빌드(테스트 결제창)는 기기 안에서만 센다.
  static bool get useServerWallet => !kIsWeb && RevenueCatMonetization.configured;

  static DateTime? _lastSubmit;

  /// 순위표 자동 제출 최소 간격 (서버 제한은 1분 5회)
  static const submitThrottle = Duration(seconds: 60);

  /// 참여 중이면 이번 주 점수를 보낸다 (일시정지·저장 후 나가기·백그라운드).
  /// 기다리지 않고 실패도 무시한다 — 게임을 막지 않는다. [now]는 테스트용.
  static void submitLeaderboard({DateTime? now}) {
    final svc = leaderboard;
    if (!svc.configured || !svc.optedIn) return;
    final s = profile.weeklyScore;
    s.rollover();
    if (s.points <= 0 && s.lastPoints <= 0) return;
    final t = now ?? DateTime.now();
    final last = _lastSubmit;
    if (last != null && t.difference(last) < submitThrottle) return;
    _lastSubmit = t;
    svc.submitWeekly(s).then((_) => SaveService.saveProfile(profile)).catchError((Object _) {});
  }

  /// 화면에서 직접 제출했을 때 자동 제출 간격을 다시 센다
  static void markSubmitted() => _lastSubmit = DateTime.now();

  /// 젬 [n]을 쓰기 전에 부른다. 서버 지갑이면 서버가 먼저 차감해야 true이고, 차감분은
  /// [Profile.prepaid]에 들어가 이어서 부르는 게임 동작([Profile.spendGems])이 쓴다.
  /// 기기 지갑이면 바로 true (게임 동작이 직접 확인한다). 실패 이유는 [lastPay].
  static Future<bool> payGems(int n, String reason) async {
    lastPay = WalletStatus.ok;
    final p = profile;
    if (!Profile.serverWallet || n <= 0) return true;
    if (p.prepaid >= n) return true; // 지난번에 차감받고 못 쓴 몫이 있으면 그것부터
    if (p.gems < n) {
      lastPay = WalletStatus.notEnough;
      return false;
    }
    lastPay = await wallet.spend(n - p.prepaid, reason);
    return lastPay == WalletStatus.ok;
  }

  static WalletStatus lastPay = WalletStatus.ok;

  /// 서버 지갑이면 쌓인 수입을 보낸다 ([refresh]면 잔액·결제도 받아 온다). 기다리지 않는다.
  static void syncWallet({bool refresh = false}) {
    if (!Profile.serverWallet) return;
    unawaited(refresh ? wallet.refresh() : wallet.flush());
  }

  /// 서버가 알려 준 결제 표시를 게임에 반영한다. 스타터 팩·사령관 패스의 꾸미기와 ★3 승무원은 처음 한 번만 준다.
  /// 환불되면 사령관 패스 혜택을 끈다.
  static void applyPurchaseFlags(bool premium, bool starter) {
    final p = profile;
    if (starter && !p.starterBought) {
      p
        ..starterBought = true
        ..ownedSkins.add('galaxy')
        ..pendingStarCrew += 1;
      deliverPending();
    }
    if (premium) p.ownedSkins.add('gold');
    if (p.premium != premium) p.premium = premium;
    p.dirty = true;
  }

  /// 모든 데이터 초기화 뒤 새 프로필로 바꾼다. 설치 ID(= 결제·지갑 ID)는 그대로 두고 서버 젬만 비운다.
  static void resetProfile() {
    final id = profile.installId;
    profile = Profile()..installId = id;
    world = null;
    if (Profile.serverWallet) wallet.wipe();
    SaveService.saveProfile(profile);
  }

  /// 클라우드 백업으로 바꾼 프로필을 앱에 반영한다. 설치 ID가 바뀌면 결제 사용자도 바꾸고 서버 지갑을 다시 읽는다.
  static Future<void> adoptRestored(Profile restored) async {
    final before = profile.installId;
    profile = restored;
    world = null;
    _lastSubmit = null;
    final id = restored.installId;
    if (id != null && id != before) await money.switchUser(id);
    if (Profile.serverWallet) {
      wallet.recompute();
      await wallet.refresh();
    }
  }

  /// 모든 데이터 초기화: 순위표에 참여했으면 서버 기록도 지운다 (최선 노력, 기다리지 않음).
  static void forgetLeaderboard() {
    final id = profile.installId;
    if (id == null || !profile.leaderboardOptIn) return;
    leaderboard.forget(id);
  }

  static Future<void> init() async {
    profile = await SaveService.loadProfile();
    profile.refreshDaily(DateTime.now());
    money.onGrant = grant;
    if (useServerWallet) {
      Profile.onEarn = wallet.earned;
      wallet.recompute();
      // RevenueCat 사용자 = 설치 ID. 서버가 결제를 이 지갑에 넣는다.
      money.appUserId = leaderboard.installId;
    }
    await money.init();
    if (useServerWallet) unawaited(wallet.refresh());
    if (CloudBackup.supported) unawaited(cloud.resume());
    AudioService.instance
      ..soundOn = profile.sound
      ..musicOn = profile.music;
    AudioService.instance.init();
    // 광고 동의 창은 첫 화면이 뜬 뒤에
    WidgetsBinding.instance.addPostFrameCallback((_) => AdService.instance.init());
    NotificationService.instance.init();
  }

  /// 보상형 광고 시청. 사령관 패스 보유자는 광고 없이 바로 보상.
  /// 광고가 아직 준비되지 않았으면 false.
  static Future<bool> watchAd() async {
    if (profile.premium) return true;
    return money.showRewardedAd();
  }

  static void haptic() {
    if (profile.haptics) HapticFeedback.lightImpact();
  }

  static void play(Sfx s) => AudioService.instance.play(s);

  /// 테스트 결제(개발 빌드, [DevMonetization])로 산 상품을 기기에서 지급한다.
  /// 출시 빌드의 결제는 서버가 지급한다 (RevenueCat → starset-purchase-webhook → 지갑).
  static bool grant(String productId) {
    final p = profile;
    switch (productId) {
      case 'gems_100':
        p.gems += 100;
      case 'gems_550':
        p.gems += 550;
      case 'gems_1200':
        p.gems += 1200;
      case 'starter_pack':
        if (p.starterBought) break;
        p.gems += 300;
        applyPurchaseFlags(p.premium, true);
      case 'premium_pass':
        applyPurchaseFlags(true, p.starterBought);
    }
    p.dirty = true;
    deliverPending();
    SaveService.saveProfile(p);
    play(Sfx.gem);
    return true;
  }

  /// 결제로 받은 승무원을 현재 월드에 지급
  static void deliverPending() {
    final w = world;
    if (w == null) return;
    while (profile.pendingStarCrew > 0 && w.roster.length < w.rosterCap) {
      profile.pendingStarCrew--;
      w.grantCrew(3);
    }
  }
}

class _ProfileLeaderboardStore implements LeaderboardStore {
  Profile get _p => AppState.profile;

  @override
  String? get installId => _p.installId;
  @override
  set installId(String? v) => _p.installId = v;

  @override
  String? get nicknameCode => _p.nicknameCode;
  @override
  set nicknameCode(String? v) => _p.nicknameCode = v;

  @override
  bool get leaderboardOptIn => _p.leaderboardOptIn;
  @override
  set leaderboardOptIn(bool v) => _p.leaderboardOptIn = v;

  @override
  int get nicknameRerolls => _p.nicknameRerolls;
  @override
  set nicknameRerolls(int v) => _p.nicknameRerolls = v;

  @override
  Future<void> save() => SaveService.saveProfile(_p);
}
