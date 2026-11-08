// TASK 003 측정: 새 게임 0~10분, 스토리 단계 도달·첫 승무원·첫 ★3·미니 두목 시각 (밸런스 봇)
// flutter test --no-pub tool/r3_first_minutes_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';

import 'package:star_settlers/game/world.dart';

import '../test/first_minutes_test.dart' as gate;
import '../test/support/progression_bot.dart';

String _m(double? s) => s == null
    ? '-'
    : '${(s ~/ 60)}:${(s % 60).floor().toString().padLeft(2, '0')}';

void main() {
  test('첫 10분 타임라인', () {
    final rows = <String>[];
    for (final seed in [1, 2, 3, 4, 5]) {
      final bot = ProgressionBot(
        seed,
        sessionMinutes: 10,
        sessionsPerDay: 1,
        useOffline: false,
        dailyGems: false,
      );
      final step = <int, double>{};
      double? crew, star3, bossSpawn, bossKill;
      var lastStory = 0;
      bot.onTick = (w) {
        final t = w.totalTime;
        if (w.storyIndex != lastStory) {
          lastStory = w.storyIndex;
          step[lastStory] ??= t;
        }
        if (crew == null && w.roster.isNotEmpty) crew = t;
        if (star3 == null && w.roster.any((c) => c.rarity >= 3)) star3 = t;
        final miniBoss = w.pirates.any((e) => e.miniBoss);
        if (bossSpawn == null && miniBoss) bossSpawn = t;
        if (bossKill == null && w.counter('miniBossKills') > 0) bossKill = t;
      };
      bot.run(maxDays: 1);
      rows.add(
        '| $seed | ${[for (var i = 1; i <= 7; i++) _m(step[i])].join(' | ')} | ${_m(crew)} | ${_m(star3)} | ${_m(bossSpawn)} | ${_m(bossKill)} |',
      );
    }
    // ignore: avoid_print
    print(
      '| seed | 1 소행성 | 2 해적 | 3 식민지 | 4 강화 | 5 승무원 | 6 임무 | 7 정거장 | 첫 승무원 | 첫 ★3 | 두목 등장 | 미니 두목 처치 |\n'
      '|---|---|---|---|---|---|---|---|---|---|---|---|\n${rows.join('\n')}',
    );
  });

  test('미니 두목 vs 시작 함선 (강화 0)', () {
    final rows = <String>[];
    for (var seed = 1; seed <= 8; seed++) {
      final w = GameWorld(seed: seed)..totalTime = GameWorld.miniBossSeconds;
      w.storyIndex = 2;
      gate.tick(w);
      final boss = w.pirates.firstWhere((e) => e.miniBoss);
      final hp = boss.maxHp;
      final (t, deaths) = gate.fightMiniBoss(w);
      rows.add('| $seed | ${hp.round()} | ${t?.toStringAsFixed(1) ?? '-'}초 | $deaths | ${w.level(UpgradeKind.weapon)} |');
    }
    // ignore: avoid_print
    print('| seed | 부두목 체력 | 처치 시간 | 격추 | 처치 후 무기 Lv |\n|---|---|---|---|---|\n${rows.join('\n')}');
  });
}
