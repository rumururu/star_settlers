import 'dart:math';

import 'package:flutter/material.dart';

import '../game/models.dart';
import '../game/world.dart';
import 'sprites.dart';

/// 식민지 건물 한 채가 행성 표면에 서는 자리.
/// [base]는 표면 위 바닥 중앙(월드 좌표), [angle]은 바깥 법선 방향(라디안, 화면 좌표),
/// [size]는 건물 상자 한 변(월드 단위). 상자는 바닥에서 바깥으로 [size]×[boxHeight].
typedef BuildingPlacement = ({Offset base, double angle, double size});

/// 식민지 건물·거주 돔을 행성 표면에 그린다.
///
/// 좌표계: 건물마다 "단위 상자" 안에 그린다. x는 -0.5..0.5, y는 -1(위, 바깥)..0(바닥, 표면).
/// 스프라이트(`bld_<kind>_<tier>`, 포탑은 `_base`/`_gun`)가 있으면 상자에 그대로 그리고,
/// 없으면 같은 상자 안에 도형으로 그린다. 애니메이션 효과(셔틀·불꽃·발광)는 둘 다 같이 쓴다.
abstract final class ColonyBuildingArt {
  /// 건물별 고정 각도(도, 0=오른쪽, -90=위). 아래쪽 28°..152°는 행성 이름표 자리라 비운다.
  static double slotDeg(ColonyBuilding b) => switch (b) {
    ColonyBuilding.turret => -48,
    ColonyBuilding.mine => -10,
    ColonyBuilding.dock => 28,
    ColonyBuilding.shieldGen => -132,
    ColonyBuilding.trade => -170,
    ColonyBuilding.stabilizer => 152,
  };

  /// 거주 돔 각도(도). 레벨에 따라 1~3개.
  static const habitatDeg = [-90.0, -101.0, -79.0];

  /// 레벨 점(pip)까지 포함한 상자 높이 / 한 변
  static const boxHeight = 1.14;

  /// 표면 곡률 때문에 바닥을 살짝 묻는다 (한 변 대비)
  static const sink = 0.05;

  /// 외형 단계: Lv.1-2 → 1, Lv.3-4 → 2, Lv.5+ → 3
  static int tierOf(int level) => level >= 5 ? 3 : (level >= 3 ? 2 : 1);

  static const _tierScale = [0.0, 0.74, 0.87, 1.0];

  /// 건물 한 변 (최대 단계 기준). 행성 크기에 비례, 줌 아웃에서도 화면 36px 이상,
  /// 이웃 자리(38° 간격, 현 길이 0.65×반지름)와 겹치지 않게 반지름의 0.6배 이하.
  static double fullSize(Planet p, double zoom) =>
      min(max(p.radius * 0.58, 36 / zoom), p.radius * 0.6);

  static int habitatCount(Planet p) =>
      p.colonyLevel >= 5 ? 3 : (p.colonyLevel >= 3 ? 2 : 1);

  static BuildingPlacement placement(Planet p, ColonyBuilding b, double zoom) {
    final a = slotDeg(b) * pi / 180;
    final s = fullSize(p, zoom) * _tierScale[tierOf(p.building(b))];
    return (base: p.pos + OffsetX.fromAngle(a, p.radius), angle: a, size: s);
  }

  static BuildingPlacement habitatPlacement(Planet p, int i, double zoom) {
    final a = habitatDeg[i] * pi / 180;
    final s = fullSize(p, zoom) * (i == 0 ? 0.4 : 0.3);
    return (base: p.pos + OffsetX.fromAngle(a, p.radius), angle: a, size: s);
  }

  /// 상자 네 꼭짓점 (월드 좌표, 겹침 검사용). 높이는 [height]×size.
  static List<Offset> corners(
    BuildingPlacement pl, {
    double height = boxHeight,
  }) {
    final up = OffsetX.fromAngle(pl.angle);
    final side = Offset(-up.dy, up.dx);
    final b0 = pl.base - up * (pl.size * sink);
    final h = up * (pl.size * height);
    final w = side * (pl.size / 2);
    return [b0 - w, b0 + w, b0 + w + h, b0 - w + h];
  }

  // ---------- 상태에서 읽는 값 ----------

  /// 포탑 포신의 단위 상자 안 회전축
  static double _turretPivotY(int tier) =>
      const [0.0, -0.40, -0.45, -0.50][tier];

  /// 포탑 포신의 월드 각도 (표적이 있으면 표적 방향, 없으면 법선 주변을 천천히 훑는다)
  static double turretAim(GameWorld w, Planet p, double zoom) {
    final pl = placement(p, ColonyBuilding.turret, zoom);
    final target = w.colonyTurretTarget(p);
    if (target == null) return pl.angle + 0.35 * sin(w.totalTime * 0.6);
    final pivot = turretPivot(p, zoom);
    final d = target.pos - pivot;
    return atan2(d.dy, d.dx);
  }

  /// 포탑 회전축의 월드 좌표
  static Offset turretPivot(Planet p, double zoom) {
    final pl = placement(p, ColonyBuilding.turret, zoom);
    final tier = tierOf(p.building(ColonyBuilding.turret));
    return _local(pl, 0, _turretPivotY(tier));
  }

  static const _dishPivotY = [0.0, -0.50, -0.52, -0.56];
  static const _dishFocus = [0.0, 0.26, 0.30, 0.34];

  /// 안정기 접시의 법선 대비 회전 (본거지 방향, 표면 안쪽으로는 안 꺾인다)
  static double dishTurn(GameWorld w, Planet p, double zoom) {
    final pl = placement(p, ColonyBuilding.stabilizer, zoom);
    final d = w.homeBase.pos - pl.base;
    var rel = atan2(d.dy, d.dx) - pl.angle;
    rel = (rel + pi) % (2 * pi) - pi;
    return rel.clamp(-1.15, 1.15);
  }

  /// 안정기 접시의 초점 = 에너지선 시작점 (월드 좌표)
  static Offset dishFocus(GameWorld w, Planet p, double zoom) {
    final pl = placement(p, ColonyBuilding.stabilizer, zoom);
    final tier = tierOf(p.building(ColonyBuilding.stabilizer));
    final turn = dishTurn(w, p, zoom);
    final f = _dishFocus[tier];
    // 단위 상자 안에서 회전축 + (위쪽으로 f)를 turn만큼 돌린 점
    return _local(pl, sin(turn) * f, _dishPivotY[tier] - cos(turn) * f);
  }

  /// 단위 상자 좌표 → 월드 좌표
  static Offset _local(BuildingPlacement pl, double x, double y) {
    final up = OffsetX.fromAngle(pl.angle);
    final side = Offset(-up.dy, up.dx);
    return pl.base + side * (x * pl.size) + up * ((-y - sink) * pl.size);
  }

  // ---------- 그리기 ----------

  static final _fill = Paint()..isAntiAlias = true;
  static final _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  static final _fx = Paint();

  static const _ink = Color(0xFF1B1D36);
  static const _gold = Color(0xFFFFD54F);
  static const _steel = Color(0xFF78909C);
  static const _steelDark = Color(0xFF455A64);
  static const _steelLight = Color(0xFFB0BEC5);

  static final _art = _Art();

  static const _names = {
    ColonyBuilding.mine: ['', 'bld_mine_1', 'bld_mine_2', 'bld_mine_3'],
    ColonyBuilding.trade: ['', 'bld_trade_1', 'bld_trade_2', 'bld_trade_3'],
    ColonyBuilding.dock: ['', 'bld_dock_1', 'bld_dock_2', 'bld_dock_3'],
    ColonyBuilding.shieldGen: [
      '',
      'bld_shieldGen_1',
      'bld_shieldGen_2',
      'bld_shieldGen_3',
    ],
    ColonyBuilding.stabilizer: [
      '',
      'bld_stabilizer_1',
      'bld_stabilizer_2',
      'bld_stabilizer_3',
    ],
  };
  static const _turretBase = [
    '',
    'bld_turret_1_base',
    'bld_turret_2_base',
    'bld_turret_3_base',
  ];
  static const _turretGun = [
    '',
    'bld_turret_1_gun',
    'bld_turret_2_gun',
    'bld_turret_3_gun',
  ];

  /// 식민지 건물·거주 돔 전체. [domeColor]는 방어막 돔의 지금 색, [domeUp]은 돔이 켜졌는지.
  static void paint(
    Canvas canvas,
    GameWorld w,
    Planet p,
    double t,
    double zoom, {
    required Color domeColor,
    required bool domeOn,
  }) {
    final raided = p.raided;
    final habitats = habitatCount(p);
    for (var i = 0; i < habitats; i++) {
      _paintHabitat(canvas, habitatPlacement(p, i, zoom), t, i, raided);
    }
    for (final b in ColonyBuilding.values) {
      final lv = p.building(b);
      if (lv == 0) continue;
      final pl = placement(p, b, zoom);
      final tier = tierOf(lv);
      canvas.save();
      canvas.translate(pl.base.dx, pl.base.dy);
      canvas.rotate(pl.angle + pi / 2);
      canvas.scale(pl.size);
      canvas.translate(0, sink);
      switch (b) {
        case ColonyBuilding.turret:
          _paintTurret(canvas, w, p, pl, tier, zoom);
        case ColonyBuilding.mine:
          _paintMine(canvas, tier, lv, t, raided);
        case ColonyBuilding.trade:
          _paintTrade(canvas, tier, t);
        case ColonyBuilding.dock:
          _paintDock(canvas, w, p, tier, t);
        case ColonyBuilding.shieldGen:
          _paintShieldGen(canvas, p, tier, t, domeColor, domeOn);
        case ColonyBuilding.stabilizer:
          _paintStabilizer(canvas, w, p, tier, t, zoom);
      }
      final topY = Sprites.get(_spriteOf(b, tier)) != null
          ? -1.02
          : _fallbackTop[b]![tier];
      _paintPips(canvas, lv, pl.size, zoom, topY);
      canvas.restore();
      // 월드 좌표 효과 (상자 밖으로 날아가는 것)
      switch (b) {
        case ColonyBuilding.mine:
          if (!raided) _paintOreShuttle(canvas, w, pl, lv, t);
        case ColonyBuilding.trade:
          _paintCargoShip(canvas, pl, lv, t, raided);
        default:
          break;
      }
    }
  }

  // ---- 공통 도구 ----
  static void _fo(Canvas c, Path path, Color color, [double stroke = 0.035]) {
    _fill.color = color;
    c.drawPath(path, _fill);
    _line
      ..color = _ink
      ..strokeWidth = stroke;
    c.drawPath(path, _line);
  }

  static void _f(Canvas c, Path path, Color color) {
    _fill.color = color;
    c.drawPath(path, _fill);
  }

  static void _stroke(Canvas c, Offset a, Offset b, Color color, double w) {
    _line
      ..color = color
      ..strokeWidth = w;
    c.drawLine(a, b, _line);
  }

  static void _dot(Canvas c, Offset o, double r, Color color) {
    _fill.color = color;
    c.drawCircle(o, r, _fill);
  }

  static void _glow(Canvas c, Offset o, double r, Color color, double alpha) {
    _fx
      ..color = color.withValues(alpha: alpha * 0.35)
      ..maskFilter = null;
    c.drawCircle(o, r, _fx);
    _fx.color = color.withValues(alpha: alpha * 0.6);
    c.drawCircle(o, r * 0.6, _fx);
    _fx.color = Color.lerp(color, Colors.white, 0.6)!.withValues(alpha: alpha);
    c.drawCircle(o, r * 0.3, _fx);
  }

  /// 결정적 의사 난수 (프레임마다 객체를 만들지 않는다)
  static double _hash(int n) {
    final x = sin(n * 12.9898) * 43758.5453;
    return x - x.floorToDouble();
  }

  // ---- 레벨 점 ----
  static String _spriteOf(ColonyBuilding b, int tier) =>
      b == ColonyBuilding.turret ? _turretBase[tier] : _names[b]![tier];

  /// 도형 대체 그림의 꼭대기 높이 (레벨 점을 바로 위에 찍는다)
  static const _fallbackTop = {
    ColonyBuilding.turret: [0.0, -0.66, -0.74, -0.82],
    ColonyBuilding.mine: [0.0, -0.78, -0.90, -1.0],
    ColonyBuilding.trade: [0.0, -0.64, -0.90, -0.96],
    ColonyBuilding.dock: [0.0, -0.80, -0.90, -0.94],
    ColonyBuilding.shieldGen: [0.0, -0.84, -0.92, -0.98],
    ColonyBuilding.stabilizer: [0.0, -0.84, -0.90, -0.96],
  };

  static void _paintPips(
    Canvas c,
    int level,
    double size,
    double zoom,
    double topY,
  ) {
    final n = min(level, 5);
    // 줌 아웃에서도 화면 반지름 1.8px 이상
    final r = max(0.04, 1.8 / zoom / size);
    final gap = r * 2.3;
    final y = max(topY - r * 1.6, -boxHeight + r * 1.35);
    final x0 = -(n - 1) * gap / 2;
    final color = level >= 5 ? _gold : const Color(0xFF80DEEA);
    for (var i = 0; i < n; i++) {
      final o = Offset(x0 + i * gap, y);
      _dot(c, o, r * 1.35, _ink);
      _dot(c, o, r, color);
    }
    if (level > 5) {
      // Lv.6 이상: 금색 점 다섯 개 위에 별 하나
      _dot(c, Offset(0, y - gap), r * 1.35, _ink);
      _dot(c, Offset(0, y - gap), r, Colors.white);
    }
  }

  // ---- 거주 돔 ----
  static void _paintHabitat(
    Canvas canvas,
    BuildingPlacement pl,
    double t,
    int i,
    bool raided,
  ) {
    canvas.save();
    canvas.translate(pl.base.dx, pl.base.dy);
    canvas.rotate(pl.angle + pi / 2);
    canvas.scale(pl.size);
    canvas.translate(0, sink);
    final a = _art;
    _fo(canvas, a.habBase, _steelDark);
    _f(canvas, a.habGlassBack, const Color(0xFF1E3A5F));
    _f(canvas, a.habInside, const Color(0xFF546E7A));
    for (var k = 0; k < 3; k++) {
      final on = raided ? false : sin(t * 1.3 + i * 2.1 + k * 1.7) > -0.3;
      _dot(
        canvas,
        Offset(-0.2 + k * 0.2, -0.24 - (k == 1 ? 0.12 : 0)),
        0.045,
        on ? const Color(0xFFFFF59D) : const Color(0xFF37474F),
      );
    }
    _f(canvas, a.habGlass, const Color(0x5581D4FA));
    _f(canvas, a.habShine, const Color(0x99FFFFFF));
    _line
      ..color = _ink
      ..strokeWidth = 0.05;
    canvas.drawPath(a.habGlass, _line);
    canvas.restore();
  }

  // ---- 포탑 ----
  static void _paintTurret(
    Canvas c,
    GameWorld w,
    Planet p,
    BuildingPlacement pl,
    int tier,
    double zoom,
  ) {
    final a = _art;
    final pivotY = _turretPivotY(tier);
    final sprite = Sprites.draw(c, _turretBase[tier], const Offset(0, -0.5), 1);
    if (!sprite) {
      _fo(c, a.plate[tier], _steelDark);
      _fo(c, a.turretBody[tier], _steel);
      _f(c, a.turretShine[tier], const Color(0x55FFFFFF));
      if (tier >= 2) _fo(c, a.turretBand[tier], const Color(0xFFFFCA28), 0.025);
      _fo(c, a.turretSlit[tier], const Color(0xFF4FC3F7), 0.02);
      if (tier == 3) {
        _stroke(
          c,
          const Offset(0.36, -0.12),
          const Offset(0.36, -0.62),
          _ink,
          0.045,
        );
        _stroke(
          c,
          const Offset(0.36, -0.12),
          const Offset(0.36, -0.62),
          _steelLight,
          0.025,
        );
        final blink = sin(w.totalTime * 5) > 0;
        _dot(
          c,
          const Offset(0.36, -0.64),
          0.04,
          blink ? const Color(0xFFFF5252) : const Color(0xFF6D1B1B),
        );
      }
    }
    // 포신: 법선 대비 회전
    final aim = turretAim(w, p, zoom);
    final rel = aim - pl.angle;
    c.save();
    c.translate(0, pivotY);
    c.rotate(rel);
    if (!Sprites.draw(c, _turretGun[tier], Offset.zero, 0.9)) {
      _fo(c, a.gunBarrel[tier], _steelLight, 0.03);
      _fo(
        c,
        a.gunHead[tier],
        tier == 3 ? const Color(0xFF5C6BC0) : _steel,
        0.03,
      );
      _f(c, a.gunHeadShine[tier], const Color(0x66FFFFFF));
      if (tier == 3) {
        _line
          ..color = _gold
          ..strokeWidth = 0.025;
        c.drawPath(a.gunHead[tier], _line);
      }
    }
    final flash = w.colonyTurretFlash(p);
    if (flash > 0) {
      final muzzle = Offset(0, -_art.gunLength[tier] - 0.04);
      _glow(c, muzzle, 0.22 + 0.1 * tier, const Color(0xFFFFE082), flash);
    }
    c.restore();
  }

  // ---- 광산 ----
  static void _paintMine(Canvas c, int tier, int level, double t, bool raided) {
    final a = _art;
    final spin = raided ? 0.0 : t * (3 + level * 0.6);
    final drillX = a.drillX[tier];
    if (!Sprites.draw(
      c,
      _names[ColonyBuilding.mine]![tier],
      const Offset(0, -0.5),
      1,
    )) {
      _fo(c, a.plate[tier], const Color(0xFF6D4C41));
      if (tier >= 2) _fo(c, a.mineHopper[tier], const Color(0xFF8D6E63));
      if (tier >= 2) {
        for (final o in a.oreLumps[tier]) {
          _dot(c, o, 0.05, _ink);
          _dot(
            c,
            o,
            0.036,
            tier == 3 ? const Color(0xFF4DD0E1) : const Color(0xFFFFB74D),
          );
        }
      }
      if (tier == 3) _fo(c, a.mineTank, const Color(0xFFBCAAA4));
      _fo(c, a.mineHut[tier], const Color(0xFFA1887F));
      _fo(c, a.mineRoof[tier], const Color(0xFFE65100));
      // 철탑
      final legW = 0.05 + tier * 0.006;
      for (final seg in a.derrick[tier]) {
        _stroke(c, seg.$1, seg.$2, _ink, legW + 0.03);
      }
      for (final seg in a.derrick[tier]) {
        _stroke(c, seg.$1, seg.$2, const Color(0xFFFFCA28), legW);
      }
      final apex = a.derrickApex[tier];
      _stroke(c, apex, Offset(drillX, -0.06), _ink, 0.05);
      _stroke(c, apex, Offset(drillX, -0.06), _steelLight, 0.025);
      final lamp = !raided && sin(t * 4) > 0;
      _dot(c, apex, 0.055, _ink);
      _dot(
        c,
        apex,
        0.04,
        lamp ? const Color(0xFFFF7043) : const Color(0xFF5D4037),
      );
    }
    // 드릴 (스프라이트 위에도 바닥에서 돈다)
    c.save();
    c.translate(drillX, -0.07);
    c.rotate(spin);
    _fo(c, a.gear, const Color(0xFF90A4AE), 0.025);
    _dot(c, Offset.zero, 0.03, _ink);
    c.restore();
    if (!raided) {
      // 흙먼지
      for (var k = 0; k < 3; k++) {
        final f = (t * 1.6 + k / 3) % 1;
        _fx.color = const Color(0xFFBCAAA4).withValues(alpha: 0.55 * (1 - f));
        c.drawCircle(
          Offset(drillX + (k - 1) * 0.12 * (0.4 + f), -0.04 - f * 0.18),
          0.03 + f * 0.05,
          _fx,
        );
      }
    }
  }

  /// 광석 셔틀: 광산에서 떠서 본거지 방향으로 날아가다 사라진다 (레벨이 높을수록 자주)
  static void _paintOreShuttle(
    Canvas c,
    GameWorld w,
    BuildingPlacement pl,
    int level,
    double t,
  ) {
    final period = max(2.4, 5.5 - level * 0.5);
    final f = (t % period) / 1.8;
    if (f >= 1) return;
    final up = OffsetX.fromAngle(pl.angle);
    final start = pl.base + up * (pl.size * 0.55);
    final toHome = (w.homeBase.pos - start).normalized();
    // 처음엔 위로 뜨고, 점점 본거지 쪽으로 꺾는다
    final dir = (up * (1 - f) + toHome * (0.4 + f)).normalized();
    final pos =
        start + up * (pl.size * 0.6 * f) + toHome * (pl.size * 2.6 * f * f);
    final alpha = f < 0.8 ? 1.0 : (1 - f) / 0.2;
    final s = pl.size * 0.11;
    _fx.color = const Color(0xFFFF9800).withValues(alpha: 0.5 * alpha);
    c.drawCircle(pos - dir * (s * 1.6), s * 0.8, _fx);
    _fx.color = const Color(0xFFFFE082).withValues(alpha: 0.8 * alpha);
    c.drawCircle(pos - dir * (s * 1.1), s * 0.5, _fx);
    _fill.color = _ink.withValues(alpha: alpha);
    c.drawCircle(pos, s * 1.0, _fill);
    _fill.color = const Color(0xFFFFB74D).withValues(alpha: alpha);
    c.drawCircle(pos, s * 0.75, _fill);
    _fill.color = const Color(0xFF8D6E63).withValues(alpha: alpha);
    c.drawCircle(pos + dir * (s * 0.2), s * 0.35, _fill);
  }

  // ---- 교역소 ----
  static void _paintTrade(Canvas c, int tier, double t) {
    final a = _art;
    if (Sprites.draw(
      c,
      _names[ColonyBuilding.trade]![tier],
      const Offset(0, -0.5),
      1,
    )) {
      return;
    }
    _fo(c, a.plate[tier], const Color(0xFF00796B));
    if (tier >= 2) {
      for (final r in a.crates[tier]) {
        _fo(c, r, const Color(0xFFBF8A50), 0.025);
      }
    }
    if (tier == 3) {
      _fo(c, a.tradeTowers, const Color(0xFFFFF3E0));
      _fo(c, a.tradeTowerCaps, _gold, 0.025);
      _fo(c, a.tradeDome, _gold);
      _f(c, a.tradeDomeShine, const Color(0x88FFFFFF));
    }
    if (tier >= 2) _fo(c, a.tradeUpper[tier], const Color(0xFFFFE0B2));
    _fo(c, a.tradeBody[tier], const Color(0xFFFFF3E0));
    _fo(c, a.tradeDoor[tier], const Color(0xFF26A69A), 0.025);
    // 차양 (빨강/흰 줄)
    _f(c, a.awningWhite[tier], Colors.white);
    _f(c, a.awningRed[tier], const Color(0xFFE53935));
    _line
      ..color = _ink
      ..strokeWidth = 0.03;
    c.drawPath(a.awningOutline[tier], _line);
    // 간판 동전
    final coin = a.coinAt[tier];
    _dot(c, coin, 0.085, _ink);
    _dot(c, coin, 0.065, _gold);
    _stroke(
      c,
      coin + const Offset(0, -0.03),
      coin + const Offset(0, 0.03),
      const Color(0xFFB8860B),
      0.02,
    );
    if (tier >= 2) {
      final on = sin(t * 3) > 0;
      _dot(
        c,
        a.tradeBeacon[tier],
        0.04,
        on ? const Color(0xFF69F0AE) : const Color(0xFF1B5E20),
      );
    }
  }

  /// 화물선: 지붕에서 떠서 고리 모양으로 돌고 돌아온다. 습격 중에는 지붕에 내려앉아 있다.
  static void _paintCargoShip(
    Canvas c,
    BuildingPlacement pl,
    int level,
    double t,
    bool raided,
  ) {
    final up = OffsetX.fromAngle(pl.angle);
    final side = Offset(-up.dy, up.dx);
    final home = pl.base + up * (pl.size * 0.85);
    Offset pos;
    Offset dir;
    if (raided) {
      pos = home;
      dir = side;
    } else {
      final period = max(3.0, 6.0 - level * 0.5);
      final u = (t % period) / period * 2 * pi;
      // 지붕(u=0)에서 출발해 바깥쪽 고리를 돈다
      final rx = pl.size * 0.95, ry = pl.size * 0.7;
      pos = home + side * (rx * sin(u)) + up * (ry * (1 - cos(u)));
      dir = (side * (rx * cos(u)) + up * (ry * sin(u))).normalized();
      if (dir == Offset.zero) dir = side;
    }
    final s = pl.size * 0.13;
    final n = Offset(-dir.dy, dir.dx);
    if (!raided) {
      _fx.color = const Color(0xFF80DEEA).withValues(alpha: 0.6);
      c.drawCircle(pos - dir * (s * 1.5), s * 0.45, _fx);
    }
    final hull = _a3(
      pos + dir * (s * 1.4),
      pos - dir * s + n * (s * 0.8),
      pos - dir * s - n * (s * 0.8),
    );
    _fill.color = _ink;
    c.drawPath(hull, _fill);
    _fill.color = const Color(0xFF4DB6AC);
    c.drawCircle(pos, s * 0.62, _fill);
    _fill.color = const Color(0xFFFFF59D);
    c.drawCircle(pos + dir * (s * 0.35), s * 0.28, _fill);
  }

  static final _tri = Path();
  static Path _a3(Offset p0, Offset p1, Offset p2) => _tri
    ..reset()
    ..moveTo(p0.dx, p0.dy)
    ..lineTo(p1.dx, p1.dy)
    ..lineTo(p2.dx, p2.dy)
    ..close();

  // ---- 정비소 ----
  static void _paintDock(Canvas c, GameWorld w, Planet p, int tier, double t) {
    final a = _art;
    final sprite = Sprites.draw(
      c,
      _names[ColonyBuilding.dock]![tier],
      const Offset(0, -0.5),
      1,
    );
    // 플레이어를 실제로 고치는 중이면 크레인이 바쁘게 움직이고 불꽃이 많다
    final pl = w.player;
    final healing =
        pl.alive &&
        pl.hp < w.playerMaxHp &&
        (pl.pos - p.pos).distance < p.dockRange;
    final sway = (healing ? 0.28 : 0.14) * sin(t * (healing ? 3.2 : 1.3));
    final mast = a.craneMast[tier];
    final arm = a.craneArm[tier];
    if (!sprite) {
      _fo(c, a.plate[tier], _steelDark);
      _fo(c, a.hangar[tier], const Color(0xFF90A4AE));
      _f(c, a.hangarShine[tier], const Color(0x44FFFFFF));
      _fo(c, a.hangarDoor[tier], const Color(0xFF37474F), 0.025);
      _f(c, a.hangarStripes[tier], const Color(0xFFFFCA28));
      // 크레인 기둥
      _stroke(c, Offset(mast.dx, 0), mast, _ink, 0.08);
      _stroke(c, Offset(mast.dx, 0), mast, const Color(0xFFFF9800), 0.05);
    }
    // 팔은 흔들린다
    c.save();
    c.translate(mast.dx, mast.dy);
    c.rotate(sway);
    final tip = Offset(-arm, 0);
    if (!sprite) {
      _stroke(c, Offset(arm * 0.25, 0), tip, _ink, 0.07);
      _stroke(c, Offset(arm * 0.25, 0), tip, const Color(0xFFFF9800), 0.042);
      _dot(c, Offset(arm * 0.25, 0), 0.05, _ink);
      _dot(c, Offset(arm * 0.25, 0), 0.035, _steelDark);
    }
    final hook = tip + Offset(0, 0.22 + 0.03 * sin(t * 2));
    _stroke(c, tip, hook, _ink, 0.018);
    _dot(c, hook, 0.035, _steelLight);
    // 용접 불꽃
    final count = healing ? 7 : 3;
    final frame = (t * 14).floor();
    for (var k = 0; k < count; k++) {
      final h = _hash(frame * 31 + k);
      if (!healing && h < 0.45) continue;
      final ang = pi / 2 + (h - 0.5) * 2.6;
      final len = 0.07 + 0.12 * _hash(frame * 17 + k * 5);
      final d = Offset(cos(ang), sin(ang));
      _stroke(
        c,
        hook + d * 0.03,
        hook + d * len,
        k.isEven ? const Color(0xFFFFF176) : const Color(0xFFFFAB40),
        0.022,
      );
    }
    if (healing) _glow(c, hook, 0.13, const Color(0xFFFFF176), 0.8);
    c.restore();
  }

  // ---- 방어막 발생기 ----
  static void _paintShieldGen(
    Canvas c,
    Planet p,
    int tier,
    double t,
    Color domeColor,
    bool domeOn,
  ) {
    final a = _art;
    final orb = a.orbAt[tier];
    final hit = p.sinceShieldHit < 0.15;
    final color = domeOn ? domeColor : const Color(0xFFB71C1C);
    final pulse = domeOn
        ? (hit ? 1.0 : 0.7 + 0.3 * sin(t * 3))
        : 0.25 + 0.2 * sin(t * 1.5).abs();
    if (!Sprites.draw(
      c,
      _names[ColonyBuilding.shieldGen]![tier],
      const Offset(0, -0.5),
      1,
    )) {
      _fo(c, a.plate[tier], const Color(0xFF283593));
      if (tier == 3) {
        for (final seg in a.genLegs) {
          _stroke(c, seg.$1, seg.$2, _ink, 0.08);
          _stroke(c, seg.$1, seg.$2, const Color(0xFF7986CB), 0.05);
        }
      }
      _fo(c, a.genBase[tier], const Color(0xFF5C6BC0));
      _fo(c, a.genColumn[tier], const Color(0xFF9FA8DA));
      _f(c, a.genColumnShine[tier], const Color(0x66FFFFFF));
      if (tier == 3) _fo(c, a.genFins, const Color(0xFF3949AB));
      if (tier == 3) _fo(c, a.genCollar, _gold, 0.025);
      // 고리 (돔 상태 색)
      for (final r in a.genRings[tier]) {
        _line
          ..color = _ink
          ..strokeWidth = 0.06;
        c.drawOval(r, _line);
        _line
          ..color = Color.lerp(
            color,
            Colors.white,
            0.3,
          )!.withValues(alpha: 0.4 + 0.6 * pulse)
          ..strokeWidth = 0.032;
        c.drawOval(r, _line);
      }
      _dot(c, orb, a.orbR[tier] + 0.03, _ink);
      _dot(c, orb, a.orbR[tier], Color.lerp(color, Colors.black, 0.25)!);
    }
    _glow(c, orb, a.orbR[tier] * 2.4, color, pulse);
    if (domeOn && hit) {
      // 피격: 위로 번개
      _stroke(c, orb, orb + const Offset(-0.08, -0.22), Colors.white, 0.025);
      _stroke(c, orb, orb + const Offset(0.1, -0.2), Colors.white, 0.025);
    }
  }

  // ---- 안정기 ----
  static void _paintStabilizer(
    Canvas c,
    GameWorld w,
    Planet p,
    int tier,
    double t,
    double zoom,
  ) {
    final a = _art;
    final connected = w.relayConnected(p);
    final beam = connected ? const Color(0xFF64FFDA) : const Color(0xFF78909C);
    final turn = dishTurn(w, p, zoom);
    final pivot = Offset(0, _dishPivotY[tier]);
    final focus = _dishFocus[tier];
    final sprite = Sprites.draw(
      c,
      _names[ColonyBuilding.stabilizer]![tier],
      const Offset(0, -0.5),
      1,
    );
    if (!sprite) {
      _fo(c, a.plate[tier], _steelDark);
      if (tier == 3) {
        for (final seg in a.stabLattice) {
          _stroke(c, seg.$1, seg.$2, _ink, 0.06);
          _stroke(c, seg.$1, seg.$2, _steelLight, 0.032);
        }
      }
      _fo(c, a.stabBase[tier], const Color(0xFFCFD8DC));
      if (tier >= 2) _fo(c, a.stabWindow[tier], const Color(0xFF26C6DA), 0.02);
      _stroke(c, Offset(0, a.stabPostBottom[tier]), pivot, _ink, 0.1);
      _stroke(c, Offset(0, a.stabPostBottom[tier]), pivot, _steel, 0.06);
      c.save();
      c.translate(pivot.dx, pivot.dy);
      c.rotate(turn);
      _fo(c, a.dish[tier], const Color(0xFFECEFF1));
      _f(c, a.dishInner[tier], const Color(0xFFB0BEC5));
      _stroke(c, Offset.zero, Offset(0, -focus), _ink, 0.045);
      _stroke(c, Offset.zero, Offset(0, -focus), _steelLight, 0.022);
      if (tier >= 2) {
        final hw = a.dishHalf[tier];
        _stroke(
          c,
          Offset(-hw * 0.85, -0.08),
          Offset(0, -focus),
          _steelLight,
          0.015,
        );
        _stroke(
          c,
          Offset(hw * 0.85, -0.08),
          Offset(0, -focus),
          _steelLight,
          0.015,
        );
      }
      c.restore();
      if (tier == 3) {
        final blink = sin(t * 4 + 1) > 0.3;
        _dot(
          c,
          const Offset(-0.34, -0.42),
          0.035,
          blink ? const Color(0xFFFF5252) : const Color(0xFF6D1B1B),
        );
      }
    }
    // 초점 발광 = 에너지선 시작점
    final f = pivot + Offset(sin(turn) * focus, -cos(turn) * focus);
    _glow(
      c,
      f,
      0.1 + 0.02 * tier,
      beam,
      connected ? 0.75 + 0.25 * sin(t * 5) : 0.35,
    );
  }
}

/// 도형 대체 그리기용 Path 묶음. 처음 쓸 때 한 번 만들고 계속 쓴다 (프레임마다 Path를 만들지 않는다).
class _Art {
  _Art() {
    for (var tier = 1; tier <= 3; tier++) {
      final pw = 0.36 + tier * 0.03;
      plate[tier] = _rr(-pw, -0.07, pw, 0.03, 0.035);
      _buildTurret(tier);
      _buildMine(tier);
      _buildTrade(tier);
      _buildDock(tier);
      _buildGen(tier);
      _buildStab(tier);
    }
    // 톱니 (드릴)
    gear = Path();
    const teeth = 7;
    for (var i = 0; i < teeth * 2; i++) {
      final r = i.isEven ? 0.09 : 0.06;
      final ang = i * pi / teeth;
      final o = Offset(cos(ang) * r, sin(ang) * r);
      i == 0 ? gear.moveTo(o.dx, o.dy) : gear.lineTo(o.dx, o.dy);
    }
    gear.close();
    // 거주 돔
    habBase = _rr(-0.46, -0.1, 0.46, 0.02, 0.04);
    habGlass = Path()
      ..moveTo(-0.42, -0.08)
      ..arcToPoint(
        const Offset(0.42, -0.08),
        radius: const Radius.circular(0.42),
      )
      ..close();
    habGlassBack = Path.from(habGlass);
    habInside = Path()
      ..addRect(const Rect.fromLTRB(-0.28, -0.3, -0.1, -0.08))
      ..addRect(const Rect.fromLTRB(-0.09, -0.42, 0.09, -0.08))
      ..addRect(const Rect.fromLTRB(0.1, -0.3, 0.28, -0.08));
    habShine = Path()
      ..moveTo(-0.3, -0.24)
      ..quadraticBezierTo(-0.26, -0.4, -0.1, -0.44)
      ..quadraticBezierTo(-0.2, -0.36, -0.22, -0.22)
      ..close();
  }

  static Path _rr(double l, double t, double r, double b, double rad) =>
      Path()..addRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(rad)));
  static Path _poly(List<double> xy) {
    final p = Path()..moveTo(xy[0], xy[1]);
    for (var i = 2; i < xy.length; i += 2) {
      p.lineTo(xy[i], xy[i + 1]);
    }
    return p..close();
  }

  final plate = List<Path>.filled(4, Path());

  // 포탑
  final turretBody = List<Path>.filled(4, Path());
  final turretShine = List<Path>.filled(4, Path());
  final turretBand = List<Path>.filled(4, Path());
  final turretSlit = List<Path>.filled(4, Path());
  final gunBarrel = List<Path>.filled(4, Path());
  final gunHead = List<Path>.filled(4, Path());
  final gunHeadShine = List<Path>.filled(4, Path());
  final gunLength = const [0.0, 0.36, 0.40, 0.44];

  void _buildTurret(int tier) {
    final top = const [0.0, -0.36, -0.42, -0.48][tier];
    final bw = 0.30 + tier * 0.03;
    final tw = 0.18 + tier * 0.03;
    final body = _poly([-bw, -0.06, bw, -0.06, tw, top, -tw, top]);
    if (tier >= 2) {
      // 옆 장갑판
      body.addPath(
        _poly([
          -bw - 0.06,
          -0.06,
          -bw,
          -0.06,
          -tw,
          top + 0.12,
          -bw - 0.04,
          -0.2,
        ]),
        Offset.zero,
      );
      body.addPath(
        _poly([bw + 0.06, -0.06, bw, -0.06, tw, top + 0.12, bw + 0.04, -0.2]),
        Offset.zero,
      );
    }
    if (tier == 3) {
      body.addPath(_rr(-0.22, top - 0.05, 0.22, top + 0.03, 0.03), Offset.zero);
    }
    turretBody[tier] = body;
    turretShine[tier] = _poly([
      -bw + 0.06,
      -0.08,
      -bw + 0.14,
      -0.08,
      -tw + 0.1,
      top + 0.03,
      -tw + 0.04,
      top + 0.03,
    ]);
    turretBand[tier] = _rr(-bw + 0.04, -0.2, bw - 0.04, -0.14, 0.01);
    turretSlit[tier] = _rr(-0.1, top + 0.08, 0.1, top + 0.13, 0.02);
    final len = gunLength[tier];
    final barrel = Path();
    if (tier == 1) {
      barrel.addRRect(
        RRect.fromLTRBR(-0.045, -len, 0.045, 0, const Radius.circular(0.02)),
      );
    } else if (tier == 2) {
      barrel.addRRect(
        RRect.fromLTRBR(-0.1, -len, -0.03, 0, const Radius.circular(0.02)),
      );
      barrel.addRRect(
        RRect.fromLTRBR(0.03, -len, 0.1, 0, const Radius.circular(0.02)),
      );
    } else {
      barrel.addRRect(
        RRect.fromLTRBR(-0.06, -len, 0.06, 0, const Radius.circular(0.02)),
      );
      barrel.addRRect(
        RRect.fromLTRBR(
          -0.09,
          -len - 0.02,
          0.09,
          -len + 0.07,
          const Radius.circular(0.02),
        ),
      );
      barrel.addRRect(
        RRect.fromLTRBR(
          -0.15,
          -len * 0.7,
          -0.09,
          0,
          const Radius.circular(0.015),
        ),
      );
      barrel.addRRect(
        RRect.fromLTRBR(
          0.09,
          -len * 0.7,
          0.15,
          0,
          const Radius.circular(0.015),
        ),
      );
    }
    gunBarrel[tier] = barrel;
    final hr = 0.12 + tier * 0.025;
    gunHead[tier] = tier == 3
        ? _poly([
            for (var i = 0; i < 8; i++) ...[
              cos(i * pi / 4 + pi / 8) * hr,
              sin(i * pi / 4 + pi / 8) * hr,
            ],
          ])
        : (Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: hr)));
    gunHeadShine[tier] = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(-hr * 0.35, -hr * 0.35),
          radius: hr * 0.3,
        ),
      );
  }

  // 광산
  final mineHut = List<Path>.filled(4, Path());
  final mineRoof = List<Path>.filled(4, Path());
  final mineHopper = List<Path>.filled(4, Path());
  final oreLumps = List<List<Offset>>.filled(4, const []);
  final derrick = List<List<(Offset, Offset)>>.filled(4, const []);
  final derrickApex = List<Offset>.filled(4, Offset.zero);
  final drillX = const [0.0, 0.17, 0.18, 0.16];
  late final Path mineTank;
  late final Path gear;

  void _buildMine(int tier) {
    final hutL = tier == 3 ? -0.28 : -0.40;
    final hutR = tier == 3 ? -0.02 : -0.08;
    final hutTop = const [0.0, -0.26, -0.30, -0.32][tier];
    mineHut[tier] = _rr(hutL, hutTop, hutR, -0.05, 0.02)
      ..addRect(
        Rect.fromLTRB(hutL + 0.08, hutTop + 0.08, hutL + 0.16, hutTop + 0.15),
      );
    mineRoof[tier] = _poly([
      hutL - 0.04,
      hutTop + 0.01,
      (hutL + hutR) / 2,
      hutTop - 0.12,
      hutR + 0.04,
      hutTop + 0.01,
    ]);
    final apexY = const [0.0, -0.70, -0.82, -0.92][tier];
    final x = drillX[tier];
    final half = 0.15 + tier * 0.02;
    final apex = Offset(x, apexY);
    derrickApex[tier] = apex;
    final l = Offset(x - half, -0.05), r = Offset(x + half, -0.05);
    final segs = <(Offset, Offset)>[(l, apex), (r, apex)];
    final bars = 2 + tier;
    for (var i = 1; i <= bars; i++) {
      final f = i / (bars + 1);
      final a = Offset.lerp(l, apex, f)!, b = Offset.lerp(r, apex, f)!;
      segs.add((a, b));
      if (i < bars) {
        final f2 = (i + 1) / (bars + 1);
        segs.add((a, Offset.lerp(r, apex, f2)!));
      }
    }
    derrick[tier] = segs;
    if (tier >= 2) {
      final hx = tier == 3 ? 0.30 : -0.24;
      mineHopper[tier] = _poly([
        hx - 0.13,
        -0.42,
        hx + 0.13,
        -0.42,
        hx + 0.07,
        -0.30,
        hx + 0.07,
        -0.05,
        hx - 0.07,
        -0.05,
        hx - 0.07,
        -0.30,
      ]);
      oreLumps[tier] = [
        Offset(hx - 0.07, -0.45),
        Offset(hx + 0.0, -0.48),
        Offset(hx + 0.07, -0.45),
      ];
      if (tier == 2) {
        // 호퍼가 오두막 위로 올라가지 않게 오두막을 왼쪽 끝으로
        mineHut[tier] = _rr(-0.44, -0.24, -0.33, -0.05, 0.02);
        mineRoof[tier] = _poly([-0.47, -0.23, -0.385, -0.33, -0.30, -0.23]);
      }
    }
    if (tier == 3) {
      mineTank = Path()
        ..addRRect(
          RRect.fromLTRBR(
            -0.48,
            -0.5,
            -0.3,
            -0.05,
            const Radius.circular(0.09),
          ),
        );
    }
  }

  // 교역소
  final tradeBody = List<Path>.filled(4, Path());
  final tradeUpper = List<Path>.filled(4, Path());
  final tradeDoor = List<Path>.filled(4, Path());
  final awningWhite = List<Path>.filled(4, Path());
  final awningRed = List<Path>.filled(4, Path());
  final awningOutline = List<Path>.filled(4, Path());
  final crates = List<List<Path>>.filled(4, const []);
  final coinAt = List<Offset>.filled(4, Offset.zero);
  final tradeBeacon = List<Offset>.filled(4, Offset.zero);
  late final Path tradeDome;
  late final Path tradeDomeShine;
  late final Path tradeTowers;
  late final Path tradeTowerCaps;

  void _buildTrade(int tier) {
    final w = const [0.0, 0.30, 0.33, 0.30][tier];
    final cx = tier == 2 ? -0.06 : 0.0;
    final top = const [0.0, -0.40, -0.40, -0.42][tier];
    tradeBody[tier] = _rr(cx - w, top, cx + w, -0.05, 0.03);
    tradeDoor[tier] = _rr(cx - 0.08, -0.26, cx + 0.08, -0.05, 0.04);
    // 차양: 몸통 위쪽에 4~6칸 줄무늬, 아래 끝은 물결
    final n = 4 + tier;
    final aw = w + 0.05;
    final at = top - 0.02, ab = top + 0.1;
    final white = Path(), red = Path(), outline = Path();
    final step = aw * 2 / n;
    for (var i = 0; i < n; i++) {
      final x0 = cx - aw + i * step;
      final seg = Path()
        ..moveTo(x0, at)
        ..lineTo(x0 + step, at)
        ..lineTo(x0 + step, ab)
        ..arcToPoint(Offset(x0, ab), radius: Radius.circular(step / 2))
        ..close();
      (i.isEven ? red : white).addPath(seg, Offset.zero);
      outline.addPath(seg, Offset.zero);
    }
    awningWhite[tier] = white;
    awningRed[tier] = red;
    awningOutline[tier] = outline;
    coinAt[tier] = Offset(cx, top - 0.12);
    if (tier == 2) {
      tradeUpper[tier] = _rr(cx - 0.2, -0.72, cx + 0.2, top, 0.03)
        ..addRect(Rect.fromLTRB(cx - 0.12, -0.62, cx - 0.03, -0.53))
        ..addRect(Rect.fromLTRB(cx + 0.03, -0.62, cx + 0.12, -0.53));
      coinAt[tier] = Offset(cx, -0.72 - 0.1);
      tradeBeacon[tier] = Offset(cx + 0.17, -0.76);
      crates[tier] = [
        _rr(0.30, -0.18, 0.44, -0.05, 0.01),
        _rr(0.31, -0.30, 0.43, -0.18, 0.01),
      ];
    }
    if (tier == 3) {
      tradeUpper[tier] = _rr(-0.24, -0.6, 0.24, top, 0.03);
      tradeDome = Path()
        ..moveTo(-0.22, -0.58)
        ..arcToPoint(
          const Offset(0.22, -0.58),
          radius: const Radius.circular(0.22),
        )
        ..close();
      tradeDomeShine = Path()
        ..addOval(
          Rect.fromCircle(center: const Offset(-0.08, -0.7), radius: 0.04),
        );
      tradeTowers = Path()
        ..addRRect(
          RRect.fromLTRBR(
            -0.46,
            -0.66,
            -0.34,
            -0.05,
            const Radius.circular(0.02),
          ),
        )
        ..addRRect(
          RRect.fromLTRBR(
            0.34,
            -0.66,
            0.46,
            -0.05,
            const Radius.circular(0.02),
          ),
        );
      tradeTowerCaps = _poly([-0.48, -0.66, -0.40, -0.80, -0.32, -0.66])
        ..addPath(_poly([0.32, -0.66, 0.40, -0.80, 0.48, -0.66]), Offset.zero);
      coinAt[tier] = const Offset(0, -0.86);
      tradeBeacon[tier] = const Offset(0.40, -0.84);
      crates[tier] = const [];
    }
  }

  // 정비소
  final hangar = List<Path>.filled(4, Path());
  final hangarShine = List<Path>.filled(4, Path());
  final hangarDoor = List<Path>.filled(4, Path());
  final hangarStripes = List<Path>.filled(4, Path());
  final craneMast = List<Offset>.filled(4, Offset.zero);
  final craneArm = const [0.0, 0.40, 0.48, 0.52];

  void _buildDock(int tier) {
    final l = -0.44;
    final r = const [0.0, 0.16, 0.20, 0.22][tier];
    final h = const [0.0, 0.42, 0.50, 0.56][tier];
    final rad = (r - l) / 2;
    final body = Path()
      ..moveTo(l, -0.05)
      ..lineTo(l, -h + rad * 0.6)
      ..quadraticBezierTo(l, -h, (l + r) / 2, -h)
      ..quadraticBezierTo(r, -h, r, -h + rad * 0.6)
      ..lineTo(r, -0.05)
      ..close();
    if (tier == 3) {
      // 두 번째 작은 격납고 칸
      body.addRRect(
        RRect.fromLTRBR(
          r - 0.02,
          -0.3,
          r + 0.2,
          -0.05,
          const Radius.circular(0.04),
        ),
      );
    }
    hangar[tier] = body;
    hangarShine[tier] = Path()
      ..moveTo(l + 0.05, -0.1)
      ..lineTo(l + 0.05, -h + rad * 0.6)
      ..quadraticBezierTo(l + 0.05, -h + 0.05, (l + r) / 2 - 0.05, -h + 0.05)
      ..lineTo(l + 0.12, -h + 0.12)
      ..lineTo(l + 0.12, -0.1)
      ..close();
    final dl = l + 0.09, dr = r - 0.09, dt = -h * 0.62;
    hangarDoor[tier] = _rr(dl, dt, dr, -0.05, 0.02);
    final stripes = Path();
    final n = 3 + tier;
    final sw = (dr - dl) / n;
    for (var i = 0; i < n; i += 2) {
      stripes.addPath(
        _poly([
          dl + i * sw,
          -0.05,
          dl + (i + 1) * sw,
          -0.05,
          dl + (i + 1) * sw + 0.04,
          -0.1,
          dl + i * sw + 0.04,
          -0.1,
        ]),
        Offset.zero,
      );
    }
    hangarStripes[tier] = stripes;
    craneMast[tier] = Offset(
      tier == 3 ? 0.30 : 0.32,
      const [0.0, -0.72, -0.82, -0.86][tier],
    );
  }

  // 방어막 발생기
  final genBase = List<Path>.filled(4, Path());
  final genColumn = List<Path>.filled(4, Path());
  final genColumnShine = List<Path>.filled(4, Path());
  final genRings = List<List<Rect>>.filled(4, const []);
  final orbAt = List<Offset>.filled(4, Offset.zero);
  final orbR = const [0.0, 0.11, 0.13, 0.15];
  late final Path genFins;
  late final Path genCollar;
  late final List<(Offset, Offset)> genLegs;

  void _buildGen(int tier) {
    final bw = 0.24 + tier * 0.03;
    genBase[tier] = _poly([
      -bw,
      -0.05,
      bw,
      -0.05,
      bw - 0.08,
      -0.2,
      -bw + 0.08,
      -0.2,
    ]);
    final top = const [0.0, -0.62, -0.68, -0.70][tier];
    final cw = 0.06 + tier * 0.01;
    genColumn[tier] = _rr(-cw, top, cw, -0.18, 0.03);
    genColumnShine[tier] = _rr(
      -cw + 0.02,
      top + 0.03,
      -cw + 0.045,
      -0.22,
      0.01,
    );
    orbAt[tier] = Offset(0, top - orbR[tier] + 0.02);
    genRings[tier] = [
      for (var i = 0; i < tier; i++)
        Rect.fromCenter(
          center: Offset(0, -0.32 - i * 0.13),
          width: 0.36 - i * 0.05,
          height: 0.08,
        ),
    ];
    if (tier == 3) {
      genFins = _poly([-0.08, -0.5, -0.24, -0.36, -0.24, -0.28, -0.08, -0.36])
        ..addPath(
          _poly([0.08, -0.5, 0.24, -0.36, 0.24, -0.28, 0.08, -0.36]),
          Offset.zero,
        );
      genCollar = _rr(-0.12, top - 0.02, 0.12, top + 0.05, 0.02);
      genLegs = const [
        (Offset(-0.38, -0.04), Offset(-0.08, -0.45)),
        (Offset(0.38, -0.04), Offset(0.08, -0.45)),
      ];
    }
  }

  // 안정기
  final stabBase = List<Path>.filled(4, Path());
  final stabWindow = List<Path>.filled(4, Path());
  final stabPostBottom = const [0.0, -0.06, -0.24, -0.30];
  final dish = List<Path>.filled(4, Path());
  final dishInner = List<Path>.filled(4, Path());
  final dishHalf = const [0.0, 0.24, 0.30, 0.34];
  late final List<(Offset, Offset)> stabLattice;

  void _buildStab(int tier) {
    stabBase[tier] = switch (tier) {
      1 => _poly([-0.16, -0.05, 0.16, -0.05, 0.08, -0.14, -0.08, -0.14]),
      2 => _rr(-0.24, -0.26, 0.24, -0.05, 0.05),
      _ => _rr(-0.2, -0.32, 0.2, -0.05, 0.05),
    };
    stabWindow[tier] = _rr(-0.14, -0.2, 0.14, -0.13, 0.03);
    final hw = dishHalf[tier];
    final depth = 0.10 + tier * 0.02;
    // 접시: 위로 열린 사발. 회전축(0,0)이 사발 바닥.
    dish[tier] = Path()
      ..moveTo(-hw, -depth)
      ..quadraticBezierTo(-hw * 0.6, 0.04, 0, 0.04)
      ..quadraticBezierTo(hw * 0.6, 0.04, hw, -depth)
      ..quadraticBezierTo(0, -depth + 0.06, -hw, -depth)
      ..close();
    dishInner[tier] = Path()
      ..moveTo(-hw * 0.8, -depth + 0.015)
      ..quadraticBezierTo(0, -depth + 0.07, hw * 0.8, -depth + 0.015)
      ..quadraticBezierTo(0, -depth + 0.035, -hw * 0.8, -depth + 0.015)
      ..close();
    if (tier == 3) {
      stabLattice = const [
        (Offset(-0.34, -0.05), Offset(-0.34, -0.40)),
        (Offset(-0.34, -0.40), Offset(-0.2, -0.32)),
        (Offset(-0.34, -0.22), Offset(-0.2, -0.12)),
        (Offset(0.34, -0.05), Offset(0.2, -0.3)),
      ];
    }
  }

  // 거주 돔
  late final Path habBase;
  late final Path habGlass;
  late final Path habGlassBack;
  late final Path habInside;
  late final Path habShine;
}
