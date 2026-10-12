import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/services/app_state.dart';

/// 출시 결제는 서버가 지급한다 (test/wallet_test.dart). 여기서는 개발 빌드의 테스트 결제 지급과,
/// 서버가 알려 준 결제 표시(스타터 팩·사령관 패스)를 게임에 반영하는 부분만 본다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Profile.onEarn = null;
    AppState.profile = Profile();
  });

  test('테스트 결제: 젬 상품은 그만큼 준다', () {
    AppState.grant('gems_550');
    AppState.grant('gems_100');
    expect(AppState.profile.gems, 650);
  });

  test('테스트 결제: 스타터 팩은 한 번만 (젬 300, 은하 스킨, ★3 승무원 예약)', () {
    AppState.grant('starter_pack');
    AppState.grant('starter_pack');
    final p = AppState.profile;
    expect(p.gems, 300);
    expect(p.starterBought, isTrue);
    expect(p.ownedSkins, contains('galaxy'));
    expect(p.pendingStarCrew, 1);
  });

  test('서버 결제 표시: 스타터 팩의 꾸미기·승무원은 처음 한 번만 준다', () {
    AppState.applyPurchaseFlags(false, true);
    AppState.applyPurchaseFlags(false, true);
    expect(AppState.profile.pendingStarCrew, 1);
    expect(AppState.profile.ownedSkins, contains('galaxy'));
  });

  test('서버 결제 표시: 사령관 패스는 켜지고, 환불되면 꺼진다 (금색 스킨은 남는다)', () {
    AppState.applyPurchaseFlags(true, false);
    expect(AppState.profile.premium, isTrue);
    expect(AppState.profile.ownedSkins, contains('gold'));
    AppState.applyPurchaseFlags(false, false);
    expect(AppState.profile.premium, isFalse);
  });

  test('초기화해도 설치 ID(결제·지갑 ID)는 그대로', () {
    AppState.profile.installId = '9b2c1d7e-3f4a-4b5c-8d6e-7f8091a2b3c4';
    AppState.profile.gems = 500;
    AppState.resetProfile();
    expect(AppState.profile.installId, '9b2c1d7e-3f4a-4b5c-8d6e-7f8091a2b3c4');
    expect(AppState.profile.gems, 0);
  });
}
