// 본거지 레이저 파밍 측정 (일반 테스트에서 빠짐)
import 'package:flutter_test/flutter_test.dart';

import '../test/support/progression_bot.dart';

void main() {
  test('본거지 파밍', () {
    for (final s in [0, 1, 2, 3, 4, 5]) {
      final w = worldAtSector(7, s);
      final r = baseFarm(w, 30, shoot: const bool.fromEnvironment("SHOOT", defaultValue: true));
      // ignore: avoid_print
      print('S${s + 1} 파밍 $r 보상배율 ${w.rewardMul.toStringAsFixed(1)}');
    }
  }, timeout: Timeout.none);
}
