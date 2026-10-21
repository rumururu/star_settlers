import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/ui/sprites.dart';
import 'package:star_settlers/ui/world_painter.dart';

void main() {
  testWidgets(
    'antimatter body moves across viewport with world camera, not with ship',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 600);
      addTearDown(tester.view.reset);
      await tester.runAsync(() => Sprites.load(['antimatter_earth']));
      final w = GameWorld(seed: 22);
      final location = w.antimatterPosition;
      final key = GlobalKey();
      final repaint = ValueNotifier(0);
      addTearDown(repaint.dispose);
      Future<ByteData> frame(Offset camera) async {
        w.player.pos = camera;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: RepaintBoundary(
              key: key,
              child: CustomPaint(
                painter: WorldPainter(w, 1, repaint: repaint),
                size: const Size(1000, 600),
              ),
            ),
          ),
        );
        repaint.value++;
        await tester.pump();
        return (await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final data = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          image.dispose();
          return data;
        }))!;
      }

      int purple(ByteData d, int cx) {
        var count = 0;
        for (var y = 275; y < 325; y++) {
          for (var x = cx - 25; x < cx + 25; x++) {
            final i = (y * 1000 + x) * 4;
            final r = d.getUint8(i),
                g = d.getUint8(i + 1),
                b = d.getUint8(i + 2);
            if (r > 45 && r > g * 1.3 && b > g * 1.3) count++;
          }
        }
        return count;
      }

      final first = await frame(location - const Offset(250, 0));
      expect(purple(first, 750), greaterThan(150));
      final second = await frame(location + const Offset(150, 0));
      expect(w.antimatterPosition, location);
      expect(purple(second, 350), greaterThan(150));
      expect(purple(second, 750), lessThan(purple(second, 350) ~/ 3));
    },
  );
}
