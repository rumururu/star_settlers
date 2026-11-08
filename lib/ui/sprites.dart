import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// 게임 화면(CustomPainter)용 스프라이트. 앱 시작 때 한 번 읽어 둔다.
/// 아직 안 읽혔거나 파일이 없으면 [get]이 null → 그리는 쪽이 기존 도형으로 대신 그린다.
abstract final class Sprites {
  static final _images = <String, ui.Image>{};

  static ui.Image? get(String name) => _images[name];

  /// 식민지 건물 스프라이트 (종류 × 외형 3단계, 포탑은 받침·포신 분리).
  /// 앱 시작 때 [load]를 처음 부를 때 함께 읽는다. 파일이 없으면 도형으로 대신 그린다.
  static final buildingNames = [
    for (final t in [1, 2, 3]) ...['bld_turret_${t}_base', 'bld_turret_${t}_gun'],
    for (final k in ['mine', 'trade', 'dock', 'shieldGen', 'stabilizer'])
      for (final t in [1, 2, 3]) 'bld_${k}_$t',
  ];
  static bool _buildingsRequested = false;

  static Future<void> load(Iterable<String> names) async {
    if (!_buildingsRequested) {
      _buildingsRequested = true;
      names = [...names, ...buildingNames];
    }
    await Future.wait(names.map((n) async {
      try {
        final data = await rootBundle.load('assets/sprites/$n.png');
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        _images[n] = (await codec.getNextFrame()).image;
      } catch (_) {
        // 파일이 없으면 도형 그리기로 대체
      }
    }));
  }

  /// [center]에 한 변 [size]로 그린다. [angle]은 라디안, 스프라이트는 위쪽이 앞.
  static bool draw(Canvas canvas, String name, Offset center, double size,
      {double angle = 0, double opacity = 1, ColorFilter? filter}) {
    final img = _images[name];
    if (img == null) return false;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (angle != 0) canvas.rotate(angle);
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    final dst = Rect.fromCenter(center: Offset.zero, width: size, height: size);
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = Color.fromRGBO(255, 255, 255, opacity)
      ..colorFilter = filter;
    canvas.drawImageRect(img, src, dst, paint);
    canvas.restore();
    return true;
  }
}
