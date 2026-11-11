import 'dart:math';
import 'dart:ui';

import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/profile.dart';
import 'package:star_settlers/game/surface.dart';
import 'package:star_settlers/game/world.dart';

/// 새 게임 첫 항성계 + 첫 식민지(테라노바 Lv.1) — 지표 탐험이 막 열린 선장
GameWorld freshColonist(int seed, {Profile? profile}) {
  final w = GameWorld(seed: seed, profile: profile ?? Profile());
  w.planets.first.colonyLevel = 1;
  return w;
}

/// 착륙할 수 있는 행성 중 [kind] 종류 (없으면 아무 착륙 가능 행성)
/// 첫 항성계(태양계)에 정원 행성이 없으므로, 없는 종류는 같은 자리(행성 번호)의 대역 행성을 만든다 (정산 대상 아님 — 지도·전투 측정용).
Planet landable(GameWorld w, [PlanetKind? kind]) =>
    w.planets.where((p) => p.kind == kind).firstOrNull ??
    (kind == null
        ? w.planets.firstWhere(w.canLand)
        : Planet('Test', 120, kind, orbitRadius: 1850, orbitPhase: 0));

/// 디버그용 매 프레임 호출
void Function(SurfaceWorld w, double t)? debugHook;

class SurfaceBotResult {
  SurfaceBotResult(this.world, this.outcome);
  final SurfaceWorld world;
  final SurfaceOutcome outcome;
}

/// 간단한 자동 조종: 자동 사격을 켜고, 가장 가까운 남은 지점으로 격자 경로를 따라가 머문다(둥지는 거리를 두고 쏜다).
/// 지점을 다 끝냈거나 산소가 돌아갈 시간만큼 남으면 착륙선으로 가서 귀환한다.
SurfaceBotResult runSurfaceBot(SurfaceWorld w, {double dt = 1 / 20, double maxSeconds = 400}) {
  final input = InputState()
    ..fire = true
    ..autoAim = true;
  final map = w.map;
  List<Offset>? route;
  Offset? routeTo;
  var replan = 0.0;
  var healing = false;
  for (var t = 0.0; t < maxSeconds && !w.over; t += dt) {
    final p = w.player;
    final speed = max(60.0, w.playerSpeed);
    // 돌아갈 시간 = 착륙선까지 거리 × 1.4(우회) / 속도 + 여유 10초
    final backTime = (map.lander - p.pos).distance * 1.4 / speed + 10;
    final left = w.sites.where((s) => !s.done).toList()
      ..sort((a, b) => (a.pos - p.pos).distance.compareTo((b.pos - p.pos).distance));
    // 체력이 낮으면 착륙선으로 돌아가 수리한다 (반쯤 찰 때까지)
    if (p.hp < w.playerMaxHp * 0.35) healing = true;
    if (healing && p.hp > w.playerMaxHp * 0.8) healing = false;
    final goHome = left.isEmpty || w.oxygen < backTime || healing;
    SurfaceSite? site = goHome ? null : left.first;
    final target = site?.pos ?? map.lander;
    if (goHome && !healing && w.atLander) {
      w.returnToLander();
      break;
    }
    final d = (target - p.pos).distance;
    final hold = site == null
        ? (healing ? 40.0 : 60.0)
        : site.kind == SurfaceSiteKind.nest
        ? 300.0
        : site.radius - 40;
    var move = Offset.zero;
    if (d > hold) {
      replan -= dt;
      if (route == null || routeTo != target || replan <= 0) {
        route = map.path(p.pos, target, avoidHazards: true) ?? map.path(p.pos, target);
        routeTo = target;
        replan = 1;
      }
      final r = route;
      if (r != null && r.isNotEmpty) {
        // 3칸 앞 지점을 향한다 (지나온 칸은 버린다)
        while (r.length > 1 && (r.first - p.pos).distance < SurfaceMap.cell * 1.5) {
          r.removeAt(0);
        }
        final aim = r[min(2, r.length - 1)];
        final to = aim - p.pos;
        move = to.distance > 1 ? to / to.distance : Offset.zero;
      }
    }
    final near = w.pirates.where((e) => (e.pos - p.pos).distance < 520).toList();
    if (near.isNotEmpty) {
      w.fireMissiles();
      if (p.hp < w.playerMaxHp * 0.5) w.activateShield();
    }
    input.move = move;
    w.update(dt, input);
    debugHook?.call(w, t);
  }
  if (!w.over) w.abandon();
  return SurfaceBotResult(w, w.outcome!);
}
