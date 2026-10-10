// 밸런스 측정용 (일반 테스트에서 빠짐). 실행 예:
// flutter test tool/balance_sim_test.dart --dart-define=SEEDS=1,2,3 --dart-define=PAYS=0,1,2,3,4 --dart-define=LAST=5 --dart-define=DAYS=60
// PAY: 0 무료, 1 유료(⭐1200: 오로라+전설+슬롯), 2 유료(⭐1200 크레딧 팩), 3 사령관 패스, 4 패스+장비(⭐1200)
// (예전 --dart-define=PAY=n 도 그대로 된다.) 시드×결제 조합은 아이솔레이트로 동시에 돈다.
// MODE=s1 이면 첫 항성계를 오프라인 없이 이어서 플레이한 시간만 잰다
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';

import '../test/support/progression_bot.dart';

const _names = {0: '무료', 1: '장비', 2: '크레딧팩', 3: '패스', 4: '패스+장비'};

String _runOne(int seed, int pay, int last, int days, String mode) {
  final sw = Stopwatch()..start();
  final bot = mode == 's1'
      ? ProgressionBot(seed, sessionMinutes: 120, useOffline: false, dailyGems: false)
      : ProgressionBot(seed,
          paying: pay > 0, payWithPacks: pay == 2, buyPass: pay == 3, passAndGear: pay == 4);
  final r = bot.run(lastSector: mode == 's1' ? 0 : last, maxDays: mode == 's1' ? 1 : days.toDouble());
  final out = StringBuffer('--- seed $seed ${_names[pay]} (${sw.elapsed.inSeconds}s) weapon${r.world.weaponLevel}\n');
  for (final l in r.logs) {
    out.writeln(l);
  }
  // 집계용 기계 판독 줄: CSV,pay,seed,항성계,완료,누적일,사망,기지재출격,본거지정지,약탈,플레이분
  for (final l in r.logs) {
    out.writeln('CSV,$pay,$seed,${l.sector},${l.done ? 1 : 0},${l.days.toStringAsFixed(3)},'
        '${l.deaths},${l.baseRespawns},${l.baseDisables},${l.raidLosses},${l.playMinutes.toStringAsFixed(1)}');
  }
  return out.toString();
}

void main() {
  const seeds = String.fromEnvironment('SEEDS', defaultValue: '1');
  const pay = int.fromEnvironment('PAY', defaultValue: 0);
  const pays = String.fromEnvironment('PAYS', defaultValue: '');
  const last = int.fromEnvironment('LAST', defaultValue: 5);
  const days = int.fromEnvironment('DAYS', defaultValue: 60);
  const mode = String.fromEnvironment('MODE', defaultValue: 'days');
  test('진행 측정', () async {
    // ignore: avoid_print
    print('무료 젬/일 ≈ ${freeGemsPerDay().toStringAsFixed(1)}');
    final payList = pays.isEmpty ? [pay] : pays.split(',').map(int.parse).toList();
    final jobs = [
      for (final p in payList)
        for (final s in seeds.split(',').map(int.parse)) (s, p),
    ];
    final results = await Future.wait([
      for (final (s, p) in jobs) Isolate.run(() => _runOne(s, p, last, days, mode)),
    ]);
    for (final r in results) {
      // ignore: avoid_print
      print(r);
    }
  }, timeout: Timeout.none);
}
