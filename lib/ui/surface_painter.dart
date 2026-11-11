import 'dart:math';

import 'package:flutter/material.dart';

import '../game/models.dart';
import '../game/surface.dart';
import '../game/world.dart';
import '../l10n/l.dart';
import 'sprites.dart';
import 'tokens.dart';

/// 행성 지표 탐험 그리기 (surface-exploration). [WorldPainter]가 [SurfaceWorld]일 때 우주 배경 대신 부른다.
/// 그림(assets/sprites/srf_*)이 없으면 도형으로 대신 그린다.

/// 지표 탐험 스프라이트 이름 (앱 시작 때 [Sprites.load])
List<String> get surfaceSpriteNames => [
  'srf_rover',
  'srf_lander',
  for (final c in CreatureKind.values) 'srf_${c.name}',
  for (final k in SurfaceSiteKind.values) 'srf_${k.name}',
  for (final k in surfaceKinds) 'srf_rock_${k.name}',
  for (final k in surfaceKinds) 'srf_ground_${k.name}',
  for (final id in relicIds) 'relic_$id',
];

/// 지표가 있는 행성 종류 (가스는 착륙할 수 없다)
const surfaceKinds = [PlanetKind.garden, PlanetKind.desert, PlanetKind.ice, PlanetKind.lava];

/// 종류별 색: (바닥, 바닥 무늬, 위험 지대, 바위)
(Color, Color, Color, Color) surfacePalette(PlanetKind k) => switch (k) {
  PlanetKind.garden => (const Color(0xFF2E5D34), const Color(0xFF3F7A45), const Color(0xFF9C6ADE), const Color(0xFF7B5E4A)),
  PlanetKind.desert => (const Color(0xFFB98A55), const Color(0xFFA6784A), const Color(0xFFE0B470), const Color(0xFF8D5B3A)),
  PlanetKind.ice => (const Color(0xFFBFD8E6), const Color(0xFFA9C7DA), const Color(0xFF4FC3F7), const Color(0xFF7FA7C4)),
  PlanetKind.lava || PlanetKind.gas => (const Color(0xFF2B2525), const Color(0xFF3A3030), const Color(0xFFFF5722), const Color(0xFF4A3F3F)),
};

/// 지점 색 (화살표·고리)
Color siteColor(SurfaceSiteKind k) => switch (k) {
  SurfaceSiteKind.ruin => const Color(0xFFFFD54F),
  SurfaceSiteKind.wreck => const Color(0xFF80D8FF),
  SurfaceSiteKind.nest => const Color(0xFFFF5252),
  SurfaceSiteKind.vein => const Color(0xFF64FFDA),
};

const landerColor = Color(0xFF7CFFB2);

final _texts = <String, TextPainter>{};
TextPainter _text(String s, Color c, double size) {
  final key = '$s|${c.toARGB32()}|$size';
  final hit = _texts[key];
  if (hit != null) return hit;
  if (_texts.length > 200) _texts.clear();
  return _texts[key] = TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(
        fontFamily: Ts.family,
        fontSize: size,
        color: c,
        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

void _label(Canvas canvas, Offset center, String s, Color c, [double size = 18]) {
  final tp = _text(s, c, size);
  tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
}

void _bar(Canvas canvas, Offset center, double w, double f, Color c) {
  final r = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: w, height: 16), const Radius.circular(8));
  canvas.drawRRect(r, Paint()..color = Colors.black87);
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.top, w * f.clamp(0, 1), 16), const Radius.circular(8)),
    Paint()..color = c,
  );
  canvas.drawRRect(r, Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..color = Colors.white70);
}

/// 화면 바탕 (지도 밖 어둠)
void paintSurfaceBackdrop(Canvas canvas, Size size, SurfaceWorld w) {
  final (base, _, _, _) = surfacePalette(w.planetKind);
  canvas.drawRect(Offset.zero & size, Paint()..color = Color.lerp(base, Colors.black, 0.75)!);
}

/// 월드 좌표: 바닥·위험 지대·장애물·착륙선·지점 (카메라 변환 안에서 부른다)
void paintSurfaceGround(Canvas canvas, SurfaceWorld w, Rect view, double t) {
  final map = w.map;
  final kind = w.planetKind;
  final (base, speck, hazard, rock) = surfacePalette(kind);
  const bounds = Rect.fromLTWH(0, 0, SurfaceMap.size, SurfaceMap.size);
  final area = view.intersect(bounds);
  if (area.width > 0 && area.height > 0) {
    final tile = Sprites.get('srf_ground_${kind.name}');
    if (tile != null) {
      canvas.drawRect(
        area,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..shader = ImageShader(tile, TileMode.repeated, TileMode.repeated, Matrix4.identity().storage),
      );
    } else {
      canvas.drawRect(area, Paint()..color = base);
      // 도형 대체: 격자마다 정해진 얼룩 (시드 고정이라 흔들리지 않는다)
      final p = Paint()..color = speck;
      const step = 160.0;
      for (var x = (area.left / step).floor() * step; x < area.right; x += step) {
        for (var y = (area.top / step).floor() * step; y < area.bottom; y += step) {
          final h = ((x * 73856093).toInt() ^ (y * 19349663).toInt()) & 0xffff;
          canvas.drawCircle(Offset(x + (h % 120) + 20, y + ((h >> 7) % 120) + 20), 14.0 + h % 22, p);
        }
      }
    }
  }
  // 지도 경계 (벽)
  canvas.drawRect(
    bounds.inflate(18),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..color = Color.lerp(rock, Colors.black, 0.45)!,
  );

  // 위험 지대: 행성 색 웅덩이 + 일렁이는 테두리
  for (final h in map.hazards) {
    if (!view.inflate(h.radius).contains(h.pos)) continue;
    final pulse = 0.5 + 0.5 * sin(t * 2.4 + h.pos.dx * 0.01);
    canvas.drawCircle(
      h.pos,
      h.radius,
      Paint()
        ..shader = RadialGradient(
          colors: [hazard.withValues(alpha: 0.75), hazard.withValues(alpha: 0.45), hazard.withValues(alpha: 0.1)],
          stops: const [0, 0.75, 1],
        ).createShader(Rect.fromCircle(center: h.pos, radius: h.radius)),
    );
    canvas.drawCircle(
      h.pos,
      h.radius - 4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = hazard.withValues(alpha: 0.5 + 0.4 * pulse),
    );
    // 거품·결정·불꽃 같은 작은 점
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.25 + 0.25 * pulse);
    for (var i = 0; i < 5; i++) {
      final a = i * 1.3 + t * (kind == PlanetKind.lava ? 0.9 : 0.4);
      canvas.drawCircle(h.pos + OffsetX.fromAngle(a, h.radius * (0.25 + 0.12 * i)), 5, dot);
    }
  }

  // 착륙선 귀환 반경
  final landerPulse = 0.5 + 0.5 * sin(t * 3);
  canvas.drawCircle(map.lander, SurfaceRules.landerRadius, Paint()..color = landerColor.withValues(alpha: 0.10));
  canvas.drawCircle(
    map.lander,
    SurfaceRules.landerRadius,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = landerColor.withValues(alpha: 0.45 + 0.4 * landerPulse),
  );
  if (!Sprites.draw(canvas, 'srf_lander', map.lander, 190)) {
    final body = Paint()..color = const Color(0xFFCFD8DC);
    canvas.drawCircle(map.lander, 46, body);
    canvas.drawCircle(map.lander, 30, Paint()..color = const Color(0xFF546E7A));
    for (var i = 0; i < 3; i++) {
      final a = -pi / 2 + i * 2 * pi / 3;
      canvas.drawLine(
        map.lander + OffsetX.fromAngle(a, 40),
        map.lander + OffsetX.fromAngle(a, 78),
        Paint()
          ..strokeWidth = 8
          ..color = const Color(0xFF90A4AE),
      );
    }
  }

  // 지점
  for (final s in map.sites) {
    if (view.inflate(160).contains(s.pos)) _paintSite(canvas, w, s, t);
  }

  // 장애물 (바위·결정): 위에서 본 3/4 시점 그림, 없으면 도형
  for (final o in map.obstacles) {
    if (!view.inflate(o.radius * 1.4).contains(o.pos)) continue;
    final angle = (o.variant % 628) / 100.0;
    if (!Sprites.draw(canvas, 'srf_rock_${kind.name}', o.pos, o.radius * 2.5, angle: angle * 0.15)) {
      final path = Path();
      for (var i = 0; i < 9; i++) {
        final a = angle + i * 2 * pi / 9;
        final r = o.radius * (0.85 + 0.15 * ((o.variant >> i) & 1));
        final p = o.pos + OffsetX.fromAngle(a, r);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path.shift(const Offset(6, 8)), Paint()..color = Colors.black38);
      canvas.drawPath(path, Paint()..color = rock);
      canvas.drawCircle(o.pos - Offset(o.radius * 0.25, o.radius * 0.3), o.radius * 0.35, Paint()..color = Colors.white12);
    }
  }
}

void _paintSite(Canvas canvas, SurfaceWorld w, SurfaceSite s, double t) {
  final c = siteColor(s.kind);
  final done = s.done;
  if (!done && s.kind != SurfaceSiteKind.nest) {
    // 머물기 반경 (점선 고리)
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = c.withValues(alpha: 0.65);
    const n = 24;
    for (var i = 0; i < n; i++) {
      final a0 = i * 2 * pi / n + t * 0.3;
      canvas.drawArc(Rect.fromCircle(center: s.pos, radius: s.radius), a0, pi / n, false, ring);
    }
  }
  final size = switch (s.kind) {
    SurfaceSiteKind.nest => s.radius * 2.6,
    SurfaceSiteKind.ruin => 170.0,
    SurfaceSiteKind.wreck => 150.0,
    SurfaceSiteKind.vein => 140.0,
  };
  final flash = s.kind == SurfaceSiteKind.nest && !done && s.hp < s.maxHp && (t * 12).floor().isEven && s.ratio > 0.7;
  final drawn = Sprites.draw(
    canvas,
    s.sprite,
    s.pos,
    size,
    opacity: done ? 0.4 : 1,
    filter: done
        ? const ColorFilter.mode(Color(0xFF808080), BlendMode.modulate)
        : flash
        ? const ColorFilter.mode(Color(0xFFFFCDD2), BlendMode.modulate)
        : null,
  );
  if (!drawn) {
    final p = Paint()..color = (done ? Colors.grey : c).withValues(alpha: done ? 0.35 : 0.9);
    switch (s.kind) {
      case SurfaceSiteKind.ruin:
        for (var i = 0; i < 4; i++) {
          canvas.drawRect(Rect.fromCenter(center: s.pos + Offset(-45 + i * 30.0, (i.isEven ? -10 : 12)), width: 20, height: 60 - i * 6), p);
        }
      case SurfaceSiteKind.wreck:
        canvas.drawPath(
          Path()
            ..moveTo(s.pos.dx - 60, s.pos.dy + 20)
            ..lineTo(s.pos.dx + 50, s.pos.dy - 30)
            ..lineTo(s.pos.dx + 60, s.pos.dy)
            ..lineTo(s.pos.dx - 40, s.pos.dy + 40)
            ..close(),
          p,
        );
        canvas.drawRect(Rect.fromCenter(center: s.pos, width: 34, height: 26), Paint()..color = const Color(0xFF8D6E63));
      case SurfaceSiteKind.nest:
        canvas.drawCircle(s.pos, s.radius, p);
        canvas.drawCircle(s.pos, s.radius * 0.45, Paint()..color = const Color(0xFF3E0F2A));
      case SurfaceSiteKind.vein:
        for (var i = 0; i < 5; i++) {
          final a = i * 2 * pi / 5;
          canvas.drawPath(
            Path()
              ..moveTo(s.pos.dx, s.pos.dy)
              ..lineTo(s.pos.dx + cos(a - 0.2) * 50, s.pos.dy + sin(a - 0.2) * 50)
              ..lineTo(s.pos.dx + cos(a) * 70, s.pos.dy + sin(a) * 70)
              ..close(),
            p,
          );
        }
    }
  }
  final top = s.pos.dy - size / 2 - 24;
  _label(canvas, Offset(s.pos.dx, top), tr.srf_site(s.kind.name), done ? Colors.white54 : c, 30);
  // 진행 막대: 머무는 중이면 지점 위에, 둥지는 체력
  if (!done) {
    if (s.kind == SurfaceSiteKind.nest) {
      if (s.hp < s.maxHp) _bar(canvas, Offset(s.pos.dx, top + 34), 170, 1 - s.ratio, c);
    } else if (s.progress > 0) {
      _bar(canvas, Offset(s.pos.dx, top + 34), 170, s.ratio, c);
    }
  } else {
    canvas.drawCircle(Offset(s.pos.dx, top + 34), 18, Paint()..color = const Color(0xFF2E7D32));
    _label(canvas, Offset(s.pos.dx, top + 34), '✓', Colors.white, 22);
  }
}

/// 탐사 차량 (선장 함선 대신). 위쪽이 앞.
void paintRover(Canvas canvas, SurfaceWorld w, double t) {
  final p = w.player;
  if (p.invulnerable > 0.4 && (t * 10).floor().isEven) return;
  if (w.shielded) {
    canvas.drawCircle(p.pos, 44, Paint()..color = const Color(0x4480D8FF));
    canvas.drawCircle(
      p.pos,
      44,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF80D8FF),
    );
  }
  if (w.buffs.containsKey(PowerUpKind.rapid)) {
    canvas.drawCircle(p.pos, 36, Paint()..color = const Color(0x33FFEB3B));
  }
  if (Sprites.draw(canvas, 'srf_rover', p.pos, 76, angle: p.angle + pi / 2)) return;
  canvas.save();
  canvas.translate(p.pos.dx, p.pos.dy);
  canvas.rotate(p.angle + pi / 2);
  final wheel = Paint()..color = const Color(0xFF263238);
  for (final dx in const [-17.0, 17.0]) {
    for (final dy in const [-14.0, 0.0, 14.0]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(dx, dy), width: 9, height: 11), const Radius.circular(3)), wheel);
    }
  }
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 28, height: 40), const Radius.circular(8)),
    Paint()..color = const Color(0xFFFFB74D),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, -9), width: 20, height: 12), const Radius.circular(5)),
    Paint()..color = const Color(0xFF4FC3F7),
  );
  canvas.drawRect(Rect.fromCenter(center: const Offset(0, -24), width: 5, height: 12), Paint()..color = const Color(0xFF455A64));
  canvas.restore();
}

/// 생물 (적 대신). 그림이 없으면 몸통 도형.
void paintCreature(Canvas canvas, Pirate e, CreatureKind c, double t) {
  final flash = e.hitFlash > 0 ? const ColorFilter.mode(Colors.white, BlendMode.srcATop) : null;
  final size = e.radius * 3.0;
  final wobble = sin(t * 9 + e.pos.dx * 0.05) * 0.08;
  if (!Sprites.draw(canvas, 'srf_${c.name}', e.pos, size, angle: e.angle + pi / 2 + wobble, filter: flash)) {
    final color = e.hitFlash > 0
        ? Colors.white
        : switch (c) {
            CreatureKind.crawler => const Color(0xFF8BC34A),
            CreatureKind.spitter => const Color(0xFFBA68C8),
            CreatureKind.brute => const Color(0xFFE57373),
          };
    canvas.save();
    canvas.translate(e.pos.dx, e.pos.dy);
    canvas.rotate(e.angle + pi / 2);
    final body = Paint()..color = color;
    final leg = Paint()
      ..color = color
      ..strokeWidth = 3;
    for (var i = 0; i < 3; i++) {
      final y = -e.radius * 0.4 + i * e.radius * 0.4;
      final k = sin(t * 14 + i) * 4;
      canvas.drawLine(Offset(-e.radius * 0.5, y), Offset(-e.radius - 4, y + k), leg);
      canvas.drawLine(Offset(e.radius * 0.5, y), Offset(e.radius + 4, y - k), leg);
    }
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: e.radius * 1.3, height: e.radius * 1.8), body);
    canvas.drawCircle(Offset(-e.radius * 0.22, -e.radius * 0.55), 3, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(e.radius * 0.22, -e.radius * 0.55), 3, Paint()..color = Colors.black);
    canvas.restore();
  }
  if (e.hp < e.maxHp) {
    final r = Rect.fromCenter(center: e.pos + Offset(0, -e.radius - 12), width: e.radius * 1.6, height: 4);
    canvas.drawRect(r, Paint()..color = Colors.black54);
    canvas.drawRect(Rect.fromLTWH(r.left, r.top, r.width * (e.hp / e.maxHp).clamp(0, 1), 4), Paint()..color = const Color(0xFFFF7043));
  }
}

/// 화면 좌표: 화면 밖 지점 화살표(지점 색), 산소 경고 뒤에는 착륙선 큰 화살표
void paintSurfaceArrows(Canvas canvas, Size size, Offset cam, double zoom, SurfaceWorld w, double t) {
  final center = size.center(Offset.zero);
  void arrow(Offset worldPos, Color color, {double scale = 1, String? text}) {
    final rel = (worldPos - cam) * zoom;
    if (rel.dx.abs() < size.width / 2 - 20 && rel.dy.abs() < size.height / 2 - 20) return;
    final dir = rel / max(0.001, rel.distance);
    final sx = (size.width / 2 - 34) / max(0.001, dir.dx.abs());
    final sy = (size.height / 2 - 34) / max(0.001, dir.dy.abs());
    final pos = center + dir * min(sx, sy);
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(atan2(dir.dy, dir.dx));
    canvas.scale(scale);
    final path = Path()
      ..moveTo(14, 0)
      ..lineTo(-8, -11)
      ..lineTo(-8, 11)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black54);
    canvas.restore();
  }

  for (final s in w.sites) {
    if (!s.done) arrow(s.pos, siteColor(s.kind).withValues(alpha: 0.9), scale: 1.2);
  }
  if (w.warned) {
    final blink = (t * 4).floor().isEven;
    arrow(w.map.lander, blink ? landerColor : const Color(0xFFFFFFFF), scale: 2.0);
  }
}
