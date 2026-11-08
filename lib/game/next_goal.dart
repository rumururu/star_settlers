import 'dart:math';
import 'dart:ui';

import '../l10n/l.dart';
import 'campaign.dart';
import 'missions.dart';
import 'models.dart';
import 'world.dart';

/// HUD에 늘 보이는 '다음 목표' 종류. 순서(index)가 통계 `goal_done`의 value다 — 끝에만 추가한다.
enum GoalKind {
  story,
  campaign,
  finalMission,
  miniBoss,
  settle,
  stabilizer,
  colonyLevel,
  building,
  crewAssign,
  develop,
  warp,
}

/// 지금 할 일 하나. [nextGoal]이 월드 상태만 보고 고른다 (순수 함수 — 월드를 바꾸지 않는다).
class NextGoal {
  const NextGoal(
    this.kind,
    this.icon,
    this.text, {
    this.heading,
    this.value = 0,
    this.target = 0,
    this.target2,
    this.sector = 0,
    this.subject = -1,
    this.extra = -1,
    this.snapshot = 0,
    this.barOnly = false,
  });

  final GoalKind kind;

  /// assets/icons 이름
  final String icon;

  /// 한 줄 설명 (현재 언어)
  final String text;

  /// 작전·최종 임무처럼 위에 작게 붙는 제목
  final String? heading;

  /// 진행도. [target]이 1 이하이면 진행 막대를 그리지 않는다
  final int value;
  final int target;

  /// 안내 화살표가 가리킬 곳 (목표 칩을 누르면 잠깐 보여 준다)
  final Offset? target2;

  /// 고른 시점의 항성계, 대상(행성 번호 등), 보조 값(건물 종류), 완료 판정 기준값
  final int sector;
  final int subject;
  final int extra;
  final int snapshot;

  bool get hasProgress => target > 1;

  /// 진행 막대 옆 숫자 ('2/3', '45%'). 막대만 보일 때는 null
  String? get progressLabel =>
      barOnly ? null : (target == 100 ? '$value%' : '$value/$target');

  /// 진행 막대만 (설명에 이미 남은 양이 있다)
  final bool barOnly;
  double get fraction => target <= 0 ? 0 : (value / target).clamp(0.0, 1.0);

  /// 같은 목표인지 (바뀌는 순간 이전 목표가 [isDone]인지 본다)
  String get signature => '${kind.index}/$sector/$subject/$extra/$snapshot';

  /// 이 목표를 이뤘는가
  bool isDone(GameWorld w) {
    Planet? planet() =>
        w.sector == sector && subject >= 0 && subject < w.planets.length
        ? w.planets[subject]
        : null;
    return switch (kind) {
      GoalKind.story => w.storyIndex > snapshot,
      GoalKind.campaign => w.counter('campaignDone_$sector') > 0,
      GoalKind.finalMission => w.finalMissionStage.index > snapshot,
      GoalKind.miniBoss => w.counter(GameWorld.miniBossKey) >= 2,
      GoalKind.settle => (planet()?.colonyLevel ?? 0) > 0,
      GoalKind.stabilizer =>
        (planet()?.building(ColonyBuilding.stabilizer) ?? 0) > snapshot,
      GoalKind.colonyLevel => (planet()?.colonyLevel ?? 0) > snapshot,
      GoalKind.building =>
        (planet()?.building(ColonyBuilding.values[extra]) ?? 0) > snapshot,
      GoalKind.crewAssign => w.assignedCount > snapshot,
      GoalKind.develop => w.sector == sector && w.development >= 1,
      GoalKind.warp => w.sector > sector,
    };
  }
}

/// 다음 목표 고르기. 언제나 하나를 돌려준다 (마지막은 무한 스토리의 발전·워프 단계).
///
/// 우선순위: 최종 임무 → 작전 → 미니 두목 → 튜토리얼 스토리 →
/// 무료로 할 수 있는 승무원 배치 → 살 수 있는 정착 → 안정화 장치 → 식민지 레벨업 → 빈 건물 칸 →
/// (발전 완료면) 워프 → 발전도.
NextGoal nextGoal(GameWorld w) {
  final p = w.player.pos;
  Planet? nearest(Iterable<Planet> ps) {
    Planet? best;
    for (final pl in ps) {
      if (best == null || (pl.pos - p).distance < (best.pos - p).distance) {
        best = pl;
      }
    }
    return best;
  }

  int idx(Planet pl) => w.planets.indexOf(pl);
  Offset? homeStation() => w.stations.isEmpty
      ? null
      : w.stations
            .reduce(
              (a, b) => (a.pos - p).distance < (b.pos - p).distance ? a : b,
            )
            .pos;

  // 최종 항성계 임무
  if (w.sector == campaignFinalSector) {
    return NextGoal(
      GoalKind.finalMission,
      'act_warp',
      _finalObjective(w),
      heading: tr.c_finalTitle,
      target2: w.storyGuideTarget,
      sector: w.sector,
      snapshot: w.finalMissionStage.index,
    );
  }
  // 작전 항성계
  if (w.campaignMissionActive) {
    return NextGoal(
      GoalKind.campaign,
      'menu_quest',
      w.campaignObjective,
      heading: w.sectorName,
      value: w.campaignWorking ? (w.campaignWorkProgress * 100).round() : 0,
      target: w.campaignWorking ? 100 : 0,
      target2: w.campaignTarget,
      sector: w.sector,
    );
  }
  // 첫 항성계 미니 두목
  final boss = w.pirates.where((e) => e.miniBoss).firstOrNull;
  if (boss != null) {
    return NextGoal(
      GoalKind.miniBoss,
      'raid',
      tr.r3_goalMiniBoss,
      value: ((1 - boss.hp / boss.maxHp) * 100).round().clamp(0, 100),
      target: 100,
      target2: boss.pos,
      sector: w.sector,
    );
  }
  // 튜토리얼 스토리
  if (w.storyIndex < storySteps.length) {
    final s = w.story;
    final (v, t) = w.storyProgress;
    var text = s.title;
    Offset? to = w.storyGuideTarget;
    var value = v, target = t;
    var barOnly = false;
    switch (s.key) {
      case 'asteroids':
        to ??= _nearestAsteroid(w);
      case 'shipKills':
        to ??= _nearestPirate(w);
      case 'colonies':
        final pl = nearest(w.planets.where((pl) => pl.colonyLevel == 0));
        if (pl != null) {
          final cost = w.planetCost(pl);
          final short = max(0, cost.$1 - w.credits.floor());
          if (short > 0) {
            text = tr.r3_goalSettleNeed(pl.name, short);
            value = w.credits.floor().clamp(0, cost.$1);
            target = cost.$1;
            barOnly = true;
          } else {
            text = tr.r3_goalSettle(pl.name);
          }
          to = pl.pos;
        }
    }
    return NextGoal(
      GoalKind.story,
      _storyIcon(s.key),
      text,
      value: value,
      target: target,
      target2: to,
      sector: w.sector,
      snapshot: w.storyIndex,
      barOnly: barOnly,
    );
  }
  // 무료: 쉬는 승무원 배치
  final idle = w.idleCrew.length;
  if (idle > 0 && w.assignedCount < w.crewSlots) {
    return NextGoal(
      GoalKind.crewAssign,
      'tab_crew',
      tr.r3_goalAssignCrew,
      target2: homeStation(),
      sector: w.sector,
      snapshot: w.assignedCount,
    );
  }
  final dev = w.development;
  if (dev < 1) {
    // 살 수 있는 정착
    final settle = nearest(
      w.planets.where(
        (pl) => pl.colonyLevel == 0 && w.canAfford(w.planetCost(pl)),
      ),
    );
    if (settle != null) {
      return NextGoal(
        GoalKind.settle,
        'act_settle',
        tr.r3_goalSettle(settle.name),
        target2: settle.pos,
        sector: w.sector,
        subject: idx(settle),
      );
    }
    // 안정화 장치 (발전도를 올리는 건물)
    final stab = nearest(
      w.planets.where(
        (pl) =>
            pl.colonyLevel > 0 &&
            pl.building(ColonyBuilding.stabilizer) < pl.buildingCap &&
            pl.building(ColonyBuilding.stabilizer) < GameWorld.devLevelCap &&
            w.canAfford(w.colonyBuildingCost(pl, ColonyBuilding.stabilizer)),
      ),
    );
    if (stab != null) {
      final lv = stab.building(ColonyBuilding.stabilizer);
      return NextGoal(
        GoalKind.stabilizer,
        'colony_levelup',
        tr.r3_goalBuild(stab.name, ColonyBuilding.stabilizer.label),
        value: (dev * 100).floor(),
        target: 100,
        target2: stab.pos,
        sector: w.sector,
        subject: idx(stab),
        extra: ColonyBuilding.stabilizer.index,
        snapshot: lv,
      );
    }
    // 식민지 레벨업 (안정화 장치 칸을 늘린다)
    final up = nearest(
      w.planets.where(
        (pl) =>
            pl.colonyLevel > 0 &&
            pl.colonyLevel < w.colonyLevelCap &&
            pl.colonyLevel <= pl.building(ColonyBuilding.stabilizer) &&
            w.canAfford(w.planetCost(pl)),
      ),
    );
    if (up != null) {
      return NextGoal(
        GoalKind.colonyLevel,
        'colony_levelup',
        tr.r3_goalColonyUp(up.name, up.colonyLevel + 1),
        target2: up.pos,
        sector: w.sector,
        subject: idx(up),
        snapshot: up.colonyLevel,
      );
    }
  }
  // 빈 건물 칸 (가장 싼 것)
  (Planet, ColonyBuilding, int)? cheapest;
  for (final pl in w.planets) {
    if (pl.colonyLevel == 0) continue;
    for (final b in ColonyBuilding.values) {
      if (b == ColonyBuilding.stabilizer || pl.building(b) >= pl.buildingCap) {
        continue;
      }
      final c = w.colonyBuildingCost(pl, b);
      if (!w.canAfford(c)) continue;
      if (cheapest == null || c.$1 < cheapest.$3) cheapest = (pl, b, c.$1);
    }
  }
  if (cheapest != null) {
    final (pl, b, _) = cheapest;
    return NextGoal(
      GoalKind.building,
      _buildingIcon(b),
      tr.r3_goalBuild(pl.name, b.label),
      target2: pl.pos,
      sector: w.sector,
      subject: idx(pl),
      extra: b.index,
      snapshot: pl.building(b),
    );
  }
  // 발전 완료 → 워프
  if (dev >= 1) {
    final gate = w.gates.where((g) => g.forward && w.gateOpen(g)).firstOrNull;
    return NextGoal(
      GoalKind.warp,
      'act_warp',
      tr.r3_goalWarp,
      target2: gate?.pos,
      sector: w.sector,
    );
  }
  // 발전도 (무한 스토리)
  final todo = nearest(
    w.planets.where(
      (pl) => pl.building(ColonyBuilding.stabilizer) < GameWorld.devLevelCap,
    ),
  );
  return NextGoal(
    GoalKind.develop,
    'menu_home',
    tr.r3_goalDevelop(w.sectorName),
    value: (dev * 100).floor(),
    target: 100,
    target2: todo?.pos,
    sector: w.sector,
  );
}

String _storyIcon(String key) => switch (key) {
  'asteroids' => 'ore',
  'shipKills' => 'up_weapon',
  'colonies' => 'act_settle',
  'shipLevels' => 'tab_ship',
  'crew' => 'tab_crew',
  'missions' => 'tab_mission',
  'stations' => 'tab_station',
  'sector' => 'act_warp',
  _ => 'menu_home',
};

String _buildingIcon(ColonyBuilding b) => switch (b) {
  ColonyBuilding.turret => 'b_turret',
  ColonyBuilding.mine => 'b_mine',
  ColonyBuilding.trade => 'b_trade',
  ColonyBuilding.dock => 'b_dock',
  ColonyBuilding.shieldGen => 'dome',
  ColonyBuilding.stabilizer => 'colony_levelup',
};

Offset? _nearestAsteroid(GameWorld w) {
  final p = w.player.pos;
  Offset? best;
  for (final a in w.asteroids) {
    if (best == null || (a.pos - p).distance < (best - p).distance) {
      best = a.pos;
    }
  }
  return best;
}

Offset? _nearestPirate(GameWorld w) {
  final p = w.player.pos;
  Offset? best;
  for (final e in w.pirates) {
    if (!e.isPirate) continue;
    if (best == null || (e.pos - p).distance < (best - p).distance) {
      best = e.pos;
    }
  }
  return best;
}

/// 최종 항성계 임무의 지금 단계 (예전 HUD `_finalObjective`를 옮겨 왔다)
String _finalObjective(GameWorld w) {
  if (w.finalMissionStage != FinalMissionStage.complete && w.development < 1) {
    return '${tr.c_stabilize} · ${(w.development * 100).floor()}%';
  }
  if (w.finalMissionStage == FinalMissionStage.synchronize && !w.atFinalRelay) {
    return tr.c_syncReady;
  }
  return switch (w.finalMissionStage) {
    FinalMissionStage.dormant || FinalMissionStage.stabilize => tr.c_syncReady,
    FinalMissionStage.synchronize => tr.c_syncProgress(
      (w.finalSyncProgress * 100).clamp(0, 100).round(),
    ),
    FinalMissionStage.guardian => tr.c_guardian,
    FinalMissionStage.counterattack => tr.c_counterattack,
    FinalMissionStage.complete => tr.c_complete,
  };
}
