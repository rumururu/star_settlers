import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppState.profile = Profile();
  });

  test('같은 거래 ID 는 한 번만 지급 (구매 직후 + 고객 기록 + 복원이 겹쳐도)', () {
    expect(AppState.grant('gems_550', tx: 'o1', at: DateTime.now()), isTrue);
    expect(AppState.grant('gems_550', tx: 'o1', at: DateTime.now()), isFalse);
    expect(AppState.profile.gems, 550);
    expect(AppState.grant('gems_550', tx: 'o2', at: DateTime.now()), isTrue);
    expect(AppState.profile.gems, 1100);
  });

  test('이 기기 저장보다 먼저 산 소모성 상품은 다시 주지 않음 (재설치 후 젬 반복 방지)', () {
    final before = AppState.profile.txSince.subtract(const Duration(days: 3));
    expect(AppState.grant('gems_1200', tx: 'old', at: before), isFalse);
    expect(AppState.profile.gems, 0);
    expect(AppState.profile.grantedTx, contains('old'));
  });

  test('비소모성은 예전 구매도 복원된다', () {
    final before = AppState.profile.txSince.subtract(const Duration(days: 30));
    AppState.grant('premium_pass', tx: 'p1', at: before);
    AppState.grant('starter_pack', tx: 's1', at: before);
    expect(AppState.profile.premium, isTrue);
    expect(AppState.profile.starterBought, isTrue);
    expect(AppState.profile.gems, 300);
    // 다른 ID 로 또 와도 스타터팩 젬은 한 번만
    AppState.grant('starter_pack', tx: 'store:s1', at: DateTime.now());
    expect(AppState.profile.gems, 300);
  });

  test('지급 기록은 저장·불러오기 후에도 유지', () {
    AppState.grant('gems_100', tx: 'x', at: DateTime.now());
    final back = Profile.fromJson(AppState.profile.toJson());
    expect(back.grantedTx, contains('x'));
    expect(back.txSince.millisecondsSinceEpoch, AppState.profile.txSince.millisecondsSinceEpoch);
  });
}
