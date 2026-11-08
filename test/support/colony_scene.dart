import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/game/world.dart';
import 'package:star_settlers/ui/world_painter.dart';

/// 식민지 건물 렌더 테스트용 장면: 행성들을 빈 우주(본거지에서 먼 곳)에 놓고 WorldPainter로 그린다.
class ColonyScene {
  ColonyScene() : world = GameWorld(seed: 22) {
    world.planets.clear();
    world.pirates.clear();
    world.asteroids.clear();
    world.events.clear();
    world.player.alive = false;
  }

  final GameWorld world;
  static const origin = Offset(2600, 2600);

  Planet addPlanet(
    PlanetKind kind,
    double radius,
    Offset at, {
    int colony = 5,
    int buildings = 5,
    String name = 'Kepler',
  }) {
    final p = Planet(name, radius, kind, orbitRadius: 3000, orbitPhase: 0)
      ..pos = at
      ..colonyLevel = colony;
    for (final b in ColonyBuilding.values) {
      p.buildings[b] = buildings;
    }
    p.shieldHp = p.shieldMax(world.sectorMul);
    world.planets.add(p);
    return p;
  }

  /// [camera]를 화면 가운데에 두고 그린 RGBA 픽셀
  Future<(ByteData, int, int)> render(
    WidgetTester tester,
    Offset camera,
    Size size,
    double zoom,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    world.player.deathPos = camera;
    final key = GlobalKey();
    final repaint = ValueNotifier(0);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: CustomPaint(
            painter: WorldPainter(world, zoom, repaint: repaint),
            size: size,
          ),
        ),
      ),
    );
    await tester.pump();
    final data = (await tester.runAsync(() async {
      final image =
          await (key.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
      final d = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      image.dispose();
      return d;
    }))!;
    repaint.dispose();
    return (data, size.width.round(), size.height.round());
  }

  /// [camera]/[zoom] 화면에서 월드 좌표 → 화면 좌표
  static Offset toScreen(Offset world, Offset camera, Size size, double zoom) =>
      Offset(size.width / 2, size.height / 2) + (world - camera) * zoom;
}
