import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Three illustrated beats for the opening story. Coordinates scale with the
/// available canvas, so the same composition works in either panel orientation.
class OpeningCinematic extends StatefulWidget {
  const OpeningCinematic({super.key, required this.page});

  final int page;

  @override
  State<OpeningCinematic> createState() => _OpeningCinematicState();
}

class _OpeningCinematicState extends State<OpeningCinematic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant OpeningCinematic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      _motion.reset();
      _syncMotion();
    }
  }

  void _syncMotion() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 0.72;
    } else if (!_motion.isAnimating && _motion.value == 0) {
      _motion.forward();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _motion,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final unit = math.min(size.width, size.height);
            final t = _motion.value;
            final page = widget.page.clamp(0, 5);
            final sprites = <Widget>[];
            void sprite(
              String name,
              double x,
              double y,
              double scale, {
              double angle = 0,
              double opacity = 1,
            }) {
              final side = unit * scale;
              sprites.add(
                Positioned(
                  left: size.width * x - side / 2,
                  top: size.height * y - side / 2,
                  width: side,
                  height: side,
                  child: Opacity(
                    opacity: opacity.clamp(0, 1),
                    child: Transform.rotate(
                      angle: angle,
                      child: Image.asset(
                        'assets/sprites/$name.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              );
            }

            if (page == 0) {
              sprite('planet_garden', .41, .53, .47, angle: -.045 + t * .09);
              sprite(
                'planet_garden',
                .82 - t * .10,
                .47,
                .47,
                angle: .12 - t * .06,
                opacity: .16,
              );
            } else if (page == 1) {
              sprite('planet_garden', .39, .56, .45, angle: -.04 + t * .07);
              sprite('station', .70, .37 - t * .018, .30, angle: t * .13);
              sprite(
                'planet_garden',
                .99 + t * .12,
                .57,
                .38,
                opacity: .13 * (1 - t * .5),
              );
            } else if (page == 3) {
              sprite('planet_desert', .50, .61, .65, angle: -.08);
              sprite('ship_scout_default', .32, .30 + t * .13, .18, angle: .5);
            } else if (page == 4) {
              sprite('planet_garden', .65, .48, .44, angle: t * .08);
              sprite('station', .43, .36, .23, angle: t * .1);
              sprite('planet_desert', .16, .70, .24);
            } else if (page == 5) {
              // The school and its returning lights are drawn in the foreground.
            } else {
              sprite('planet_garden', .50, .51, .30, angle: t * .10);
              sprite('station', .59, .37, .16, angle: t * .14);
              sprite('planet_desert', .18, .55, .20, angle: -.08 + t * .05);
              sprite('planet_ice', .82, .64, .19, angle: t * .05);
              sprite(
                'ship_scout_default',
                .68 + t * .15,
                .53 - t * .27,
                .13,
                angle: .53,
              );
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _CinematicPainter(page, t)),
                ...sprites,
                CustomPaint(painter: _ForegroundPainter(page, t)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CinematicPainter extends CustomPainter {
  const _CinematicPainter(this.page, this.t);
  final int page;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final u = math.min(w, h);
    Offset p(double x, double y) => Offset(w * x, h * y);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(.1, .1),
          radius: 1.1,
          colors: [Color(0xFF1B2850), Color(0xFF101735), Color(0xFF080C20)],
        ).createShader(Offset.zero & size),
    );
    for (var i = 0; i < 48; i++) {
      final x = ((i * 73 + 19) % 101) / 101.0;
      final y = ((i * 47 + 31) % 97) / 97.0;
      final alpha = .22 + .25 * math.sin(i * 4.1 + t * 3).abs();
      canvas.drawCircle(
        p(x, y),
        i % 9 == 0 ? 1.5 : .7,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
    if (page == 0) {
      final shadow = p(.82 - t * .10, .47);
      canvas.drawCircle(
        shadow,
        u * .27,
        Paint()
          ..color = const Color(0xFF8D39DF).withValues(alpha: .16)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * .14),
      );
      canvas.drawCircle(
        p(.41, .53),
        u * .24,
        Paint()
          ..color = const Color(0xFF23B9FF).withValues(alpha: .20)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * .09),
      );
    } else if (page == 1) {
      canvas.drawCircle(
        p(.39, .56),
        u * (.27 + t * .19),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u * .012
          ..color = const Color(0xFF59F0FF).withValues(alpha: .5 * (1 - t * .4))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * .012),
      );
      canvas.drawCircle(
        p(.70, .37),
        u * .17,
        Paint()
          ..color = const Color(0xFF4BEAFF).withValues(alpha: .25)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * .07),
      );
    } else if (page == 2) {
      final orbit = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF80BDF0).withValues(alpha: .23);
      canvas.drawOval(
        Rect.fromCenter(center: p(.5, .53), width: w * .75, height: h * .50),
        orbit,
      );
      canvas.drawOval(
        Rect.fromCenter(center: p(.5, .53), width: w * .48, height: h * .32),
        orbit,
      );
      for (final point in [p(.18, .55), p(.82, .64)]) {
        final path = Path()
          ..moveTo(point.dx, point.dy)
          ..quadraticBezierTo(w * .5, h * .22, w * .54, h * .46);
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = u * .008
            ..color = const Color(0xFF57E6FF).withValues(alpha: .18)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * .025),
        );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = const Color(0xFF86F3FF).withValues(alpha: .58),
        );
        for (var i = 0; i < 3; i++) {
          final metric = path.computeMetrics().first;
          final tangent = metric.getTangentForOffset(
            metric.length * ((t * .65 + i / 3) % 1),
          );
          if (tangent != null) {
            canvas.drawCircle(
              tangent.position,
              u * .007,
              Paint()..color = const Color(0xFFB9FFFF),
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CinematicPainter oldDelegate) =>
      oldDelegate.page != page || oldDelegate.t != t;
}

class _ForegroundPainter extends CustomPainter {
  const _ForegroundPainter(this.page, this.t);
  final int page;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (page >= 3) {
      _settlement(canvas, size);
      return;
    }
    if (page != 0) return;
    final w = size.width;
    final h = size.height;
    final u = math.min(w, h);
    final x = .62 - t * .05;
    final bolt = Path()
      ..moveTo(w * x, h * .24)
      ..lineTo(w * (x - .035), h * .34)
      ..lineTo(w * (x + .025), h * .41)
      ..lineTo(w * (x - .02), h * .51)
      ..lineTo(w * (x + .035), h * .60)
      ..lineTo(w * x, h * .73);
    for (final width in [u * .055, u * .019, u * .005]) {
      canvas.drawPath(
        bolt,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width
          ..color = width < u * .01
              ? const Color(0xFFE8D9FF)
              : const Color(
                  0xFFA94BFA,
                ).withValues(alpha: width > u * .04 ? .25 : .8)
          ..maskFilter = width > u * .04
              ? MaskFilter.blur(BlurStyle.normal, u * .026)
              : null,
      );
    }
  }

  void _settlement(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    Offset p(double x, double y) => Offset(w * x, h * y);
    final paint = Paint();
    if (page == 3) {
      // Landing site: empty construction pads, not an active transmitter.
      for (var i = 0; i < 3; i++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: p(.35 + i * .15, .61),
            width: w * .12,
            height: h * .035,
          ),
          paint..color = const Color(0xFF77C3CD).withValues(alpha: .5),
        );
      }
      return;
    }
    if (page == 4) {
      final path = Path()
        ..moveTo(w * .19, h * .64)
        ..quadraticBezierTo(w * .22, h * .24, w * .44, h * .36)
        ..quadraticBezierTo(w * .55, h * .28, w * .65, h * .48);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF72E8FF).withValues(alpha: .6),
      );
      final metric = path.computeMetrics().first;
      for (var i = 0; i < 5; i++) {
        final point = metric
            .getTangentForOffset(metric.length * ((t * 2 + i / 5) % 1))!
            .position;
        canvas.drawCircle(point, 4, paint..color = const Color(0xFFB6FFFF));
      }
      canvas.drawCircle(
        p(.65, .48),
        w * (.22 + t * .06),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF7EF5DF).withValues(alpha: .4),
      );
      return;
    }
    // A school reopens at dawn: windows light sequentially, children return.
    canvas.drawCircle(
      p(.80, .27),
      w * .075,
      paint..color = const Color(0xFFFFD88D),
    );
    for (var i = 0; i < 9; i++) {
      final top = .40 + (i % 3) * .045;
      canvas.drawRect(
        Rect.fromLTRB(w * i / 9, h * top, w * (i + 1) / 9 - 4, h * .72),
        paint..color = const Color(0xFF243351),
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(0, h * .72, w, h * .11),
      paint..color = const Color(0xFF253E47),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * .19, h * .45, w * .81, h * .73),
        const Radius.circular(6),
      ),
      paint..color = const Color(0xFF829FAF),
    );
    final roof = Path()
      ..moveTo(w * .14, h * .45)
      ..lineTo(w * .50, h * .30)
      ..lineTo(w * .86, h * .45)
      ..close();
    canvas.drawPath(roof, paint..color = const Color(0xFFCC7771));
    canvas.drawCircle(
      p(.5, .39),
      w * .034,
      paint..color = const Color(0xFFFFE7B0),
    );
    canvas.drawLine(
      p(.5, .39),
      p(.5, .365),
      Paint()
        ..strokeWidth = 2
        ..color = const Color(0xFF32455F),
    );
    canvas.drawLine(
      p(.5, .39),
      p(.52, .39),
      Paint()
        ..strokeWidth = 2
        ..color = const Color(0xFF32455F),
    );
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 6; col++) {
        if (row == 1 && (col == 2 || col == 3)) continue;
        final lit = t > (row * 6 + col) / 18;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * (.23 + col * .095),
              h * (.49 + row * .11),
              w * .065,
              h * .065,
            ),
            const Radius.circular(2),
          ),
          paint
            ..color = lit ? const Color(0xFFFFE39B) : const Color(0xFF243954),
        );
      }
    }
    canvas.drawRect(
      Rect.fromLTRB(w * .455, h * .61, w * .545, h * .73),
      paint..color = const Color(0xFF20384B),
    );
    for (var i = 0; i < 4; i++) {
      final progress = (t * 1.25 - i * .12).clamp(0.0, 1.0);
      final center = p(
        .10 + i * .06 + progress * (.37 - i * .06),
        .79 - progress * .045,
      );
      final color = [
        const Color(0xFF84D8EB),
        const Color(0xFFF3C477),
        const Color(0xFFCEB3EC),
        const Color(0xFF84D8B1),
      ][i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: w * .025, height: h * .035),
          const Radius.circular(3),
        ),
        paint..color = color,
      );
      canvas.drawCircle(
        center - Offset(0, h * .027),
        w * .014,
        paint..color = const Color(0xFFFFD7BA),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ForegroundPainter oldDelegate) =>
      oldDelegate.page != page || oldDelegate.t != t;
}
