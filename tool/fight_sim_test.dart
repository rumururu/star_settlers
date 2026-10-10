// 전투 난이도 측정 (일반 테스트에서 빠짐): 항성계별 기본 함선(정찰선) vs 오로라·노바, 강화 Lv.8
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/ships.dart';

import '../test/support/progression_bot.dart';

void main() {
  test('항성계별 전투', () {
    for (final ship in ['scout', 'aurora', 'nova']) {
      for (final s in [0, 1, 2, 3, 4, 5]) {
        for (final lv in [2 + 2 * s > 8 ? 8 : 2 + 2 * s, 1]) {
          final w = worldAtSector(7, s, weapon: lv, hull: lv);
          w.profile.ownedShips.add(ship);
          w.switchShip(shipTypeById(ship));
          w.player.hp = w.playerMaxHp;
          final r = huntFight(w, 10);
          // ignore: avoid_print
          print('$ship S${s + 1} Lv$lv ${r.map((k, v) => MapEntry(k, v.toStringAsFixed(1)))}');
        }
      }
    }
  }, timeout: Timeout.none);
}
