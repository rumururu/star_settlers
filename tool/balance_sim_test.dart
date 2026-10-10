// 밸런스 측정용 (일반 테스트에서 빠짐). 실행 예:
// flutter test tool/balance_sim_test.dart --dart-define=SEEDS=1,2,3 --dart-define=PAY=0 --dart-define=LAST=5 --dart-define=DAYS=60
// PAY: 0 무료, 1 유료(⭐1200: 오로라+전설+슬롯), 2 유료(⭐1200 크레딧 팩), 3 사령관 패스
// MODE=s1 이면 첫 항성계를 오프라인 없이 이어서 플레이한 시간만 잰다
import 'package:flutter_test/flutter_test.dart';

import '../test/support/progression_bot.dart';

void main() {
  const seeds = String.fromEnvironment('SEEDS', defaultValue: '1');
  const pay = int.fromEnvironment('PAY', defaultValue: 0);
  const last = int.fromEnvironment('LAST', defaultValue: 5);
  const days = int.fromEnvironment('DAYS', defaultValue: 60);
  const mode = String.fromEnvironment('MODE', defaultValue: 'days');
  test('진행 측정', () {
    // ignore: avoid_print
    print('무료 젬/일 ≈ ${freeGemsPerDay().toStringAsFixed(1)}');
    for (final s in seeds.split(',').map(int.parse)) {
      final sw = Stopwatch()..start();
      final bot = mode == 's1'
          ? ProgressionBot(s, sessionMinutes: 120, useOffline: false, dailyGems: false)
          : ProgressionBot(s, paying: pay > 0, payWithPacks: pay == 2, buyPass: pay == 3);
      final r = bot.run(lastSector: mode == 's1' ? 0 : last, maxDays: mode == 's1' ? 1 : days.toDouble());
      // ignore: avoid_print
      print('--- seed $s ${pay > 0 ? '유료$pay' : '무료'} (${sw.elapsed.inSeconds}s) weapon${r.world.weaponLevel}');
      for (final l in r.logs) {
        // ignore: avoid_print
        print(l);
      }
    }
  }, timeout: Timeout.none);
}
