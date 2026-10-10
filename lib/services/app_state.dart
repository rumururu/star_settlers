import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;

import '../game/models.dart';
import '../game/profile.dart';
import '../game/save.dart';
import '../game/world.dart';
import 'ads.dart';
import 'audio.dart';
import 'monetization.dart';
import 'notifications.dart';

/// 앱 전역 상태: 프로필, 결제, 오디오, 현재 월드
class AppState {
  AppState._();

  static Profile profile = Profile();
  static final MonetizationService money = MonetizationService.create();
  static GameWorld? world;

  static Future<void> init() async {
    profile = await SaveService.loadProfile();
    profile.refreshDaily(DateTime.now());
    money.onGrant = grant;
    await money.init();
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

  /// 소모성 상품 (재설치 후 복원 대상이 아님)
  static const consumables = {'gems_100', 'gems_550', 'gems_1200'};

  /// 결제 완료 상품 지급 (중복 호출에도 안전하게).
  /// [tx]가 있으면 거래 ID당 한 번만 지급한다. 이 기기 저장보다 먼저 산 소모성 상품은 기록만 한다.
  static bool grant(String productId, {String? tx, DateTime? at}) {
    final p = profile;
    if (tx != null && tx.isNotEmpty) {
      if (!p.grantedTx.add(tx)) return false;
      if (consumables.contains(productId) && at != null && at.isBefore(p.txSince)) {
        p.dirty = true;
        SaveService.saveProfile(p);
        return false;
      }
    }
    switch (productId) {
      case 'gems_100':
        p.gems += 100;
      case 'gems_550':
        p.gems += 550;
      case 'gems_1200':
        p.gems += 1200;
      case 'starter_pack':
        if (p.starterBought) break;
        p.starterBought = true;
        p.gems += 300;
        p.ownedSkins.add('galaxy');
        p.pendingStarCrew++;
      case 'premium_pass':
        p.premium = true;
        p.ownedSkins.add('gold');
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
