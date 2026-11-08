import 'dart:math';
import 'dart:ui';

import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/rift.dart';
import 'package:star_settlers/game/world.dart';

/// 카드 선택 전략
enum RiftPick {
  /// 기본: 정해 둔 선호 순서에서 가장 앞선 카드
  priority,

  /// 맨 왼쪽 카드 (생각 없이 고르는 사람)
  first,
}

/// 봇 실력
enum RiftSkill {
  /// 보통: 가까운 적을 쫓되 너무 붙지 않고, 미사일·방어막을 쓰고, 탄을 비켜 가지 않는다
  normal,

  /// 서툰: 스킬을 쓰지 않고 적에게 곧장 붙는다
  weak,

  /// 잘하는: 거리를 더 두고 옆으로 돌며, 부스트로 피한다
  strong,
}

const _priority = [
  RiftCard.multishot,
  RiftCard.damage,
  RiftCard.rapid,
  RiftCard.hull,
  RiftCard.regen,
  RiftCard.blades,
  RiftCard.homing,
  RiftCard.drone,
  RiftCard.pierce,
  RiftCard.crit,
  RiftCard.vampire,
  RiftCard.guard,
  RiftCard.shockwave,
  RiftCard.engine,
  RiftCard.magnet,
];

class RiftBotResult {
  RiftBotResult(this.outcome, this.waveTimes, this.picks);
  final RiftOutcome outcome;
  final List<double> waveTimes;
  final int picks;
}

/// 헤드리스 균열 런 한 판. 자동 사격·자동 조준을 켜고 가까운 적을 쫓는다.
RiftBotResult runRiftBot(
  int dayKey, {
  RiftSkill skill = RiftSkill.normal,
  RiftPick pick = RiftPick.priority,
  double dt = 1 / 20,
  double maxSeconds = 900,
}) {
  final w = RiftWorld(plan: RiftPlan(dayKey), mainProfile: Profile());
  final input = InputState()
    ..fire = true
    ..autoAim = true;
  final r = Random(dayKey);
  var orbit = 1.0;
  for (var t = 0.0; t < maxSeconds && !w.over; t += dt) {
    if (w.phase == RiftPhase.choosing) {
      final c = pick == RiftPick.first
          ? w.offers.first
          : _priority.firstWhere(w.offers.contains, orElse: () => w.offers.first);
      w.chooseCard(c);
      continue;
    }
    final p = w.player;
    final foes = w.pirates.where((e) => e.isPirate && !e.cloaked).toList();
    var move = Offset.zero;
    if (foes.isNotEmpty) {
      final e = foes.reduce((a, b) => (a.pos - p.pos).distance < (b.pos - p.pos).distance ? a : b);
      final to = e.pos - p.pos;
      final d = to.distance;
      final n = to / max(1, d);
      final keep = switch (skill) {
        RiftSkill.weak => 120.0,
        RiftSkill.normal => 300.0,
        RiftSkill.strong => 420.0,
      };
      if (r.nextDouble() < 0.01) orbit = -orbit;
      move = d > keep + (skill == RiftSkill.weak ? 280 : 80)
          ? n
          : d < keep - 80
              ? -n
              : Offset(-n.dy, n.dx) * orbit * (skill == RiftSkill.weak ? 0 : 1);
      // 아레나 가장자리에 몰리지 않게 가운데로 살짝
      final home = RiftWorld.arenaCenter - p.pos;
      if (home.distance > RiftWorld.arenaRadius * 0.7) move += home / home.distance * 0.6;
      if (skill != RiftSkill.weak && foes.any((f) => (f.pos - p.pos).distance < 520)) {
        w.fireMissiles();
        if (p.hp < w.playerMaxHp * 0.5) w.activateShield();
        if (skill == RiftSkill.strong && p.hp < w.playerMaxHp * 0.6 && d < 200) w.boost();
      }
    }
    input.move = move.distance > 1 ? move / move.distance : move;
    w.update(dt, input);
  }
  if (!w.over) w.giveUp();
  return RiftBotResult(w.outcome!, [...w.waveTimes], w.loadout.picks);
}
