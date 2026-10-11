import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

import 'app_state.dart';

import '../l10n/l.dart';
import 'ads.dart';

export 'ads.dart' show AdResult;

/// 인앱 상품 정의 (스토어 콘솔에 같은 ID로 등록해야 함)
class ProductDef {
  const ProductDef(this.id, this.fallbackPrice, {this.consumable = true});
  final String id;
  String get title => switch (id) {
        'gems_100' => tr.g_productGems100Title,
        'gems_550' => tr.g_productGems550Title,
        'gems_1200' => tr.g_productGems1200Title,
        'starter_pack' => tr.g_productStarterTitle,
        'premium_pass' => tr.g_productPassTitle,
        _ => id,
      };
  String get desc => switch (id) {
        'gems_100' => '⭐100',
        'gems_550' => tr.g_productGems550Desc,
        'gems_1200' => tr.g_productGems1200Desc,
        'starter_pack' => tr.g_productStarterDesc,
        'premium_pass' => tr.g_productPassDesc,
        _ => '',
      };
  final String fallbackPrice;
  final bool consumable;
}

const productDefs = [
  ProductDef('gems_100', '₩1,200'),
  ProductDef('gems_550', '₩5,900'),
  ProductDef('gems_1200', '₩12,000'),
  ProductDef('starter_pack', '₩3,900',
      consumable: false),
  ProductDef('premium_pass', '₩6,500', consumable: false),
];

/// 결제 결과. UI는 [failed]일 때만 오류를 안내한다 (사용자 취소는 조용히).
enum PurchaseResult {
  success,

  /// 사용자가 결제창/확인창에서 취소했거나 이미 안내창을 보여줌
  cancelled,

  /// 스토어 연결 실패, 상품 없음 등
  failed,
}

/// 결제/광고 추상화.
/// - 개발/웹: [DevMonetization] (테스트 확인창)
/// - 출시: [RevenueCatMonetization] (RevenueCat + AdMob 보상형 광고)
abstract class MonetizationService {
  /// 결제 성공 시 호출 (상품 지급은 앱에서 처리).
  /// [tx]는 거래 ID — 같은 거래는 한 번만 지급된다. [at]은 구매 시각. 새로 지급했으면 true.
  bool Function(String productId, {String? tx, DateTime? at})? onGrant;

  /// 개발 모드 확인창 (UI가 주입)
  Future<bool> Function(String title, String body)? confirm;

  Future<void> init();
  String priceOf(String productId);
  Future<PurchaseResult> buy(String productId);
  Future<void> restore();

  /// 보상형 광고 결과 (준비 안 됨 / 중간에 닫음 / 보상 받음 구분)
  Future<AdResult> showRewardedAdResult();

  /// 마지막 [showRewardedAd] 결과. bool만 받는 호출부(AppState.watchAd)가 실패 이유를 알 수 있게 남겨둔다.
  AdResult lastAdResult = AdResult.notReady;

  /// 보상형 광고. 끝까지 보면 true (실패 이유는 [lastAdResult])
  Future<bool> showRewardedAd() async {
    lastAdResult = await showRewardedAdResult();
    return lastAdResult == AdResult.rewarded;
  }

  bool get isTestMode;

  static MonetizationService create() {
    // 키가 있으면 디버그에서도 RevenueCat (Test Store 키로 결제 흐름 시험)
    if (RevenueCatMonetization.configured) return RevenueCatMonetization();
    if (!kReleaseMode) return DevMonetization();
    // 웹 정식 빌드(데모)에서는 결제/광고를 막는다 (무료 지급 방지)
    if (kIsWeb) return WebDemoMonetization();
    return RevenueCatMonetization();
  }
}

class DevMonetization extends MonetizationService {
  @override
  bool get isTestMode => true;

  @override
  Future<void> init() async {}

  @override
  String priceOf(String productId) =>
      productDefs.firstWhere((p) => p.id == productId).fallbackPrice;

  @override
  Future<PurchaseResult> buy(String productId) async {
    final def = productDefs.firstWhere((p) => p.id == productId);
    final ok = await (confirm?.call(tr.g_testPurchaseTitle(def.title),
            tr.g_testPurchaseBody(def.desc, def.fallbackPrice)) ??
        Future.value(false));
    if (!ok) return PurchaseResult.cancelled;
    onGrant?.call(productId);
    return PurchaseResult.success;
  }

  @override
  Future<void> restore() async {}

  @override
  Future<AdResult> showRewardedAdResult() async {
    // 모바일에서는 구글 테스트 광고를 실제로 띄운다
    if (AdService.supported) return AdService.instance.showRewarded();
    final ok = await (confirm?.call(tr.g_testAdTitle, tr.g_testAdBody) ??
        Future.value(false));
    return ok ? AdResult.rewarded : AdResult.cancelled;
  }
}

/// 웹 데모: 구매와 광고 보상은 모바일 앱에서만
class WebDemoMonetization extends MonetizationService {
  @override
  bool get isTestMode => false;

  @override
  Future<void> init() async {}

  @override
  String priceOf(String productId) =>
      productDefs.firstWhere((p) => p.id == productId).fallbackPrice;

  Future<void> _notice() async {
    await confirm?.call(tr.g_webDemoTitle, tr.g_webDemoBody);
  }

  @override
  Future<PurchaseResult> buy(String productId) async {
    await _notice();
    return PurchaseResult.cancelled;
  }

  @override
  Future<void> restore() async {}

  @override
  Future<AdResult> showRewardedAdResult() async {
    await _notice();
    return AdResult.cancelled;
  }
}

/// 출시 결제: RevenueCat (익명 사용자, 로그인 없음).
/// RevenueCat 서버가 스토어 영수증을 검증한 뒤에만 구매 성공이 돌아온다.
/// 지급은 거래 ID 단위로 한 번만 ([onGrant]의 `tx`) — 구매 직후, 앱 시작, 복원이 같은 경로를 탄다.
/// 키는 빌드 때 `--dart-define=REVENUECAT_API_KEY_ANDROID=goog_...` / `REVENUECAT_API_KEY_IOS=appl_...`.
class RevenueCatMonetization extends MonetizationService {
  static const _androidKey = String.fromEnvironment('REVENUECAT_API_KEY_ANDROID');
  static const _iosKey = String.fromEnvironment('REVENUECAT_API_KEY_IOS');
  static String get apiKey => kIsWeb ? '' : (Platform.isAndroid ? _androidKey : (Platform.isIOS ? _iosKey : ''));
  static bool get configured => apiKey.isNotEmpty;

  final _products = <String, StoreProduct>{};
  final _packages = <String, Package>{};
  bool _available = false;

  @override
  bool get isTestMode => false;

  @override
  Future<void> init() async {
    if (!configured) {
      debugPrint('RevenueCat key missing: purchases disabled');
      return;
    }
    try {
      await Purchases.setLogLevel(kReleaseMode ? LogLevel.warn : LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _available = true;
      Purchases.addCustomerInfoUpdateListener(_sync);
      await _loadProducts();
      _sync(await Purchases.getCustomerInfo());
    } catch (e) {
      debugPrint('RevenueCat init failed: $e');
    }
  }

  /// 표준 경로: 현재 offering 의 package. offering 에 없는 상품만 getProducts 로 보충.
  Future<void> _loadProducts() async {
    final offering = (await Purchases.getOfferings()).current;
    for (final pkg in offering?.availablePackages ?? const <Package>[]) {
      final id = _baseId(pkg.storeProduct.identifier);
      _packages[id] = pkg;
      _products[id] = pkg.storeProduct;
    }
    final missing = productDefs.map((p) => p.id).where((id) => !_products.containsKey(id)).toList();
    if (missing.isEmpty) return;
    for (final p in await Purchases.getProducts(missing, productCategory: ProductCategory.nonSubscription)) {
      _products[_baseId(p.identifier)] = p;
    }
  }

  /// Play 상품 ID 는 `gems_100:base` 꼴로 올 수 있다
  static String _baseId(String id) => id.split(':').first;

  /// RevenueCat 고객 기록의 거래를 지급한다. 새로 지급한 상품 ID 를 돌려준다.
  Set<String> _sync(CustomerInfo info) {
    final got = <String>{};
    for (final t in info.nonSubscriptionTransactions) {
      final id = _baseId(t.productIdentifier);
      if (onGrant?.call(id, tx: t.transactionIdentifier, at: DateTime.tryParse(t.purchaseDate)) ?? false) got.add(id);
    }
    return got;
  }

  @override
  String priceOf(String productId) =>
      _products[productId]?.priceString ?? productDefs.firstWhere((p) => p.id == productId).fallbackPrice;

  @override
  Future<PurchaseResult> buy(String productId) async {
    if (!_available) return PurchaseResult.failed;
    final pkg = _packages[productId];
    final product = _products[productId];
    if (pkg == null && product == null) return PurchaseResult.failed;
    try {
      final r = await Purchases.purchase(
          pkg != null ? PurchaseParams.package(pkg) : PurchaseParams.storeProduct(product!));
      // 기본은 고객 기록(_sync)으로 지급. 기록에 이번 거래가 아직 없을 때만 이번 거래로 지급한다.
      // (구매 결과의 거래 ID 는 고객 기록의 ID 와 체계가 달라 같은 거래로 묶이지 않는다)
      // 결제 직후 기록 갱신 알림(_sync)이 먼저 지급했으면 여기서 "새로 지급 없음"이 나오므로,
      // 새로 지급했는지가 아니라 기록에 최근 거래가 있는지로 판단한다 — 아니면 두 번 지급된다.
      _sync(r.customerInfo);
      final now = DateTime.now();
      final inRecord = r.customerInfo.nonSubscriptionTransactions.any((t) =>
          _baseId(t.productIdentifier) == productId &&
          (DateTime.tryParse(t.purchaseDate)?.difference(now).abs() ?? const Duration(days: 1)) <
              AppState.fallbackMatchWindow);
      if (!inRecord) {
        final t = r.storeTransaction;
        onGrant?.call(productId, tx: '${AppState.fallbackTxPrefix}${t.transactionIdentifier}', at: now);
      }
      return PurchaseResult.success;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) return PurchaseResult.cancelled;
      debugPrint('purchase failed: $code');
      return PurchaseResult.failed;
    }
  }

  @override
  Future<void> restore() async {
    if (!_available) return;
    try {
      _sync(await Purchases.restorePurchases());
    } on PlatformException catch (e) {
      debugPrint('restore failed: ${PurchasesErrorHelper.getErrorCode(e)}');
    }
  }

  @override
  Future<AdResult> showRewardedAdResult() => AdService.instance.showRewarded();
}
