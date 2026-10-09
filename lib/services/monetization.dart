import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../l10n/l.dart';
import 'ads.dart';

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

/// 결제/광고 추상화.
/// - 개발/웹: [DevMonetization] (테스트 확인창)
/// - 출시: [StoreMonetization] (in_app_purchase + AdMob 보상형 광고)
abstract class MonetizationService {
  /// 결제 성공 시 호출 (상품 지급은 앱에서 처리)
  void Function(String productId)? onGrant;

  /// 개발 모드 확인창 (UI가 주입)
  Future<bool> Function(String title, String body)? confirm;

  Future<void> init();
  String priceOf(String productId);
  Future<bool> buy(String productId);
  Future<void> restore();

  /// 보상형 광고. 끝까지 보면 true
  Future<bool> showRewardedAd();

  bool get isTestMode;

  static MonetizationService create() {
    if (!kReleaseMode) return DevMonetization();
    // 웹 정식 빌드(데모)에서는 결제/광고를 막는다 (무료 지급 방지)
    if (kIsWeb) return WebDemoMonetization();
    return StoreMonetization();
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
  Future<bool> buy(String productId) async {
    final def = productDefs.firstWhere((p) => p.id == productId);
    final ok = await (confirm?.call(tr.g_testPurchaseTitle(def.title),
            tr.g_testPurchaseBody(def.desc, def.fallbackPrice)) ??
        Future.value(false));
    if (ok) onGrant?.call(productId);
    return ok;
  }

  @override
  Future<void> restore() async {}

  @override
  Future<bool> showRewardedAd() async {
    // 모바일에서는 구글 테스트 광고를 실제로 띄운다
    if (AdService.supported) return AdService.instance.showRewarded();
    return await (confirm?.call(tr.g_testAdTitle, tr.g_testAdBody) ??
        Future.value(false));
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

  Future<bool> _notice() async {
    await confirm?.call(tr.g_webDemoTitle, tr.g_webDemoBody);
    return false;
  }

  @override
  Future<bool> buy(String productId) => _notice();

  @override
  Future<void> restore() async {}

  @override
  Future<bool> showRewardedAd() => _notice();
}

class StoreMonetization extends MonetizationService {
  final _iap = InAppPurchase.instance;
  final _products = <String, ProductDetails>{};
  final _pending = <String, Completer<bool>>{};
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _available = false;

  @override
  bool get isTestMode => false;

  @override
  Future<void> init() async {
    try {
      _available = await _iap.isAvailable();
      if (!_available) return;
      _sub = _iap.purchaseStream.listen(_onPurchases, onError: (Object e) {
        debugPrint('purchase stream error: $e');
      });
      final res = await _iap.queryProductDetails(productDefs.map((p) => p.id).toSet());
      for (final p in res.productDetails) {
        _products[p.id] = p;
      }
    } catch (e) {
      debugPrint('IAP init failed: $e');
      _available = false;
    }
  }

  @override
  String priceOf(String productId) =>
      _products[productId]?.price ??
      productDefs.firstWhere((p) => p.id == productId).fallbackPrice;

  @override
  Future<bool> buy(String productId) async {
    final details = _products[productId];
    if (!_available || details == null) return false;
    final def = productDefs.firstWhere((p) => p.id == productId);
    final c = Completer<bool>();
    _pending[productId] = c;
    final param = PurchaseParam(productDetails: details);
    final started = def.consumable
        ? await _iap.buyConsumable(purchaseParam: param)
        : await _iap.buyNonConsumable(purchaseParam: param);
    if (!started) {
      _pending.remove(productId);
      return false;
    }
    return c.future.timeout(const Duration(minutes: 5), onTimeout: () => false);
  }

  Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // TODO(출시 전): 서버에서 영수증 검증 후 지급
          onGrant?.call(p.productID);
          _pending.remove(p.productID)?.complete(true);
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          _pending.remove(p.productID)?.complete(false);
        case PurchaseStatus.pending:
          break;
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  @override
  Future<void> restore() async {
    if (_available) await _iap.restorePurchases();
  }

  @override
  Future<bool> showRewardedAd() => AdService.instance.showRewarded();

  void dispose() => _sub?.cancel();
}
