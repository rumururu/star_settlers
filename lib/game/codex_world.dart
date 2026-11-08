import 'star_catalog.dart';
import 'world.dart';

/// 도감 ↔ 월드 연결 (TASK 006). 게임 화면이 열릴 때와 매 프레임 부른다.

/// 도감이 생기기 전부터 하던 게임: 지금 월드에 이미 있는 것(도달한 항성계·정착지·승무원)을
/// 조용히(토스트 없이) 도감에 채운다. 몇 번 불러도 같다.
void syncCodexFromWorld(GameWorld w) {
  final c = w.profile.codex;
  final maxSector = w.counter('maxSector');
  for (var s = 0; s <= maxSector && s < catalogSystemCount; s++) {
    c.recordSystem(s, silent: true);
  }
  c.recordSystem(w.sector, silent: true);
  for (var i = 0; i < w.planets.length; i++) {
    final p = w.planets[i];
    c.recordColony(
      w.sector,
      i,
      w.planets.length,
      p.kind,
      p.colonyLevel,
      silent: true,
    );
  }
  w.sectors.forEach((sector, save) {
    final n = save.colonyLevels.length;
    for (var i = 0; i < n; i++) {
      final lv = save.colonyLevels[i];
      if (lv > 0) {
        c.recordColony(
          sector,
          i,
          n,
          planetIdentity(sector, i, n).kind,
          lv,
          silent: true,
        );
      }
    }
  });
  for (final m in w.roster) {
    c.recordCrew(m.role, m.rarity, silent: true);
  }
}

/// 받아 둔 도감 보상을 월드에 넣는다 (승무원은 정원이 남을 때만)
void deliverCodexRewards(GameWorld w) => w.profile.codex.deliver(
  addCredits: (n) => w.credits += n,
  addOre: (n) => w.ore += n,
  addCrew: (r) {
    if (w.roster.length >= w.rosterCap) return false;
    w.grantCrew(r);
    return true;
  },
);
