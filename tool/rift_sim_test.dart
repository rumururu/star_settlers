// 균열 런 길이·도달 파도 측정 (일반 테스트에서 빠짐): flutter test --no-pub tool/rift_sim_test.dart
// 날짜 30개 × 실력 3종(보통·서툰·잘하는) × 카드 전략 2종. 결과 표는 RESULT_005_CLAUDE.md에 옮긴다.
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/rift.dart';

import '../test/support/rift_bot.dart';

void main() {
  test('균열 봇 분포', () {
    final days = [for (var i = 0; i < 30; i++) 20261108 + (i % 20) + (i ~/ 20) * 100];
    for (final skill in RiftSkill.values) {
      for (final pick in RiftPick.values) {
        final runs = [for (final d in days) runRiftBot(d, skill: skill, pick: pick)];
        final secs = runs.map((r) => r.outcome.seconds).toList()..sort();
        final avg = secs.reduce((a, b) => a + b) / secs.length;
        final reached = <int, int>{};
        for (final r in runs) {
          reached[r.outcome.reached] = (reached[r.outcome.reached] ?? 0) + 1;
        }
        final perWave = List.generate(RiftPlan.waveCount, (i) {
          final t = [for (final r in runs) if (r.waveTimes.length > i) r.waveTimes[i]];
          return t.isEmpty ? '-' : (t.reduce((a, b) => a + b) / t.length).toStringAsFixed(0);
        });
        final picks = runs.map((r) => r.picks).reduce((a, b) => a + b) / runs.length;
        final scores = runs.map((r) => r.outcome.score).toList()..sort();
        // ignore: avoid_print
        print('${skill.name}/${pick.name}: avg ${(avg / 60).toStringAsFixed(2)}m '
            'median ${(secs[secs.length ~/ 2] / 60).toStringAsFixed(2)}m '
            'min ${(secs.first / 60).toStringAsFixed(2)} max ${(secs.last / 60).toStringAsFixed(2)} '
            'conquered ${runs.where((r) => r.outcome.conquered).length}/${runs.length} '
            'reached ${(reached.keys.toList()..sort()).map((k) => '$k:${reached[k]}').join(' ')} '
            'waveSec [${perWave.join(' ')}] picks ${picks.toStringAsFixed(1)} '
            'score median ${scores[scores.length ~/ 2]} max ${scores.last}');
      }
    }
  }, timeout: Timeout.none);
}
