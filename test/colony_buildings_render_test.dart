import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_settlers/game/models.dart';
import 'package:star_settlers/ui/colony_buildings.dart';
import 'package:star_settlers/ui/sprites.dart';
import 'package:star_settlers/ui/world_painter.dart';

import 'support/colony_scene.dart';

/// 식민지 건물 렌더 게이트.
/// 픽셀 판정은 특정 색이 아니라 "건물이 없을 때와의 차이"로 한다 → 도형 대체 그림이든
/// 생성 스프라이트(`bld_*`)든 같은 테스트가 통과해야 한다.
const _size = Size(1000, 800);
const _zoom = 1.6;
const _radius = 120.0;
// 이름표 폭을 넉넉히 잡도록 긴 이름 (테스트 글꼴은 글자당 14px)
const _longName = 'Kepler-442b Prime';

bool _convexContains(List<Offset> poly, Offset p) {
  var sign = 0;
  for (var i = 0; i < poly.length; i++) {
    final a = poly[i], b = poly[(i + 1) % poly.length];
    final cross = (b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx);
    final s = cross > 0 ? 1 : (cross < 0 ? -1 : 0);
    if (s == 0) continue;
    if (sign == 0) {
      sign = s;
    } else if (s != sign) {
      return false;
    }
  }
  return true;
}

/// 볼록 다각형 둘이 겹치는지 (분리축 정리)
bool _overlap(List<Offset> a, List<Offset> b) {
  for (final poly in [a, b]) {
    for (var i = 0; i < poly.length; i++) {
      final e = poly[(i + 1) % poly.length] - poly[i];
      final axis = Offset(-e.dy, e.dx);
      double dot(Offset p) => p.dx * axis.dx + p.dy * axis.dy;
      final pa = a.map(dot), pb = b.map(dot);
      if (pa.reduce(max) <= pb.reduce(min) ||
          pb.reduce(max) <= pa.reduce(min)) {
        return false;
      }
    }
  }
  return true;
}

List<Offset> _rectPoly(Rect r) => [
  r.topLeft,
  r.topRight,
  r.bottomRight,
  r.bottomLeft,
];

bool _differs(ByteData a, ByteData b, int i) {
  final d =
      (a.getUint8(i) - b.getUint8(i)).abs() +
      (a.getUint8(i + 1) - b.getUint8(i + 1)).abs() +
      (a.getUint8(i + 2) - b.getUint8(i + 2)).abs();
  return d > 40;
}

void main() {
  Future<void> loadSprites(WidgetTester tester) => tester.runAsync(
    () => Sprites.load([
      for (final k in PlanetKind.values) 'planet_${k.name}',
      'station',
      'pirate_raider',
    ]),
  );

  ColonyScene scene(int level, {Set<ColonyBuilding>? only}) {
    final s = ColonyScene();
    final p = s.addPlanet(
      PlanetKind.garden,
      _radius,
      ColonyScene.origin,
      colony: 5,
      buildings: 0,
      name: _longName,
    );
    for (final b in only ?? ColonyBuilding.values.toSet()) {
      p.buildings[b] = level;
    }
    p.shieldHp = p.shieldMax(s.world.sectorMul);
    s.world.totalTime = 0;
    return s;
  }

  Offset scr(Offset w) =>
      ColonyScene.toScreen(w, ColonyScene.origin, _size, _zoom);

  testWidgets('(a) 각 건물 자리에 건물 픽셀이 그려진다 (Lv.1/3/5)', (tester) async {
    addTearDown(tester.view.reset);
    await loadSprites(tester);
    final empty = scene(1, only: {});
    final (base, w, _) = await empty.render(
      tester,
      ColonyScene.origin,
      _size,
      _zoom,
    );
    for (final level in [1, 3, 5]) {
      for (final b in ColonyBuilding.values) {
        final s = scene(level, only: {b});
        final p = s.world.planets.single;
        final (img, _, _) = await s.render(
          tester,
          ColonyScene.origin,
          _size,
          _zoom,
        );
        final box = ColonyBuildingArt.corners(
          ColonyBuildingArt.placement(p, b, _zoom),
        ).map(scr).toList();
        final bounds = Rect.fromPoints(
          box[0],
          box[2],
        ).expandToInclude(Rect.fromPoints(box[1], box[3]));
        var inside = 0, changed = 0;
        for (var y = bounds.top.floor(); y < bounds.bottom.ceil(); y++) {
          for (var x = bounds.left.floor(); x < bounds.right.ceil(); x++) {
            final pt = Offset(x + .5, y + .5);
            if (!_convexContains(box, pt)) continue;
            inside++;
            if (_differs(img, base, (y * w + x) * 4)) changed++;
          }
        }
        expect(
          changed / inside,
          greaterThan(0.08),
          reason: '$b Lv.$level: 건물 상자 안에 그려진 픽셀 $changed / $inside',
        );
      }
    }
  });

  testWidgets('(b)(c) 건물끼리, 거주 돔과, 행성 이름표와 겹치지 않는다', (tester) async {
    addTearDown(tester.view.reset);
    final s = ColonyScene();
    for (final radius in [90.0, 110.0, 140.0, 200.0]) {
      for (final zoom in [0.55, 0.8, 1.1, 1.6]) {
        for (final level in [1, 3, 5, 8]) {
          final p = s.addPlanet(
            PlanetKind.ice,
            radius,
            ColonyScene.origin,
            colony: level,
            buildings: level,
            name: _longName,
          );
          final boxes = {
            for (final b in ColonyBuilding.values)
              b.name: ColonyBuildingArt.corners(
                ColonyBuildingArt.placement(p, b, zoom),
              ),
          };
          final habitats = [
            for (var i = 0; i < ColonyBuildingArt.habitatCount(p); i++)
              ColonyBuildingArt.corners(
                ColonyBuildingArt.habitatPlacement(p, i, zoom),
                height: 0.6,
              ),
          ];
          final label = _rectPoly(WorldPainter.planetLabelRect(p));
          final names = boxes.keys.toList();
          final at = 'R=$radius zoom=$zoom Lv.$level';
          for (var i = 0; i < names.length; i++) {
            final a = boxes[names[i]]!;
            for (var j = i + 1; j < names.length; j++) {
              expect(
                _overlap(a, boxes[names[j]]!),
                isFalse,
                reason: '$at: ${names[i]} ↔ ${names[j]}',
              );
            }
            for (final h in habitats) {
              expect(
                _overlap(a, h),
                isFalse,
                reason: '$at: ${names[i]} ↔ 거주 돔',
              );
            }
            expect(
              _overlap(a, label),
              isFalse,
              reason: '$at: ${names[i]} ↔ 이름표',
            );
          }
          s.world.planets.remove(p);
        }
      }
    }
  });

  testWidgets('(d) 포탑 포신이 실제 표적 방향 ±15° 안을 향한다', (tester) async {
    addTearDown(tester.view.reset);
    await loadSprites(tester);
    for (final level in [1, 3, 5]) {
      ColonyScene withTarget(double? rel) {
        final s = scene(level, only: {ColonyBuilding.turret});
        final p = s.world.planets.single;
        if (rel != null) {
          final pl = ColonyBuildingArt.placement(
            p,
            ColonyBuilding.turret,
            _zoom,
          );
          final pivot = ColonyBuildingArt.turretPivot(p, _zoom);
          s.world.pirates.add(
            Pirate(
              PirateKind.raider,
              pivot + OffsetX.fromAngle(pl.angle + rel, 260),
              100,
            ),
          );
        }
        return s;
      }

      final none = withTarget(null);
      final (n, w, _) = await none.render(
        tester,
        ColonyScene.origin,
        _size,
        _zoom,
      );
      final aims = <double, ByteData>{};
      for (final rel in [1.3, -1.3]) {
        final s = withTarget(rel);
        final p = s.world.planets.single;
        final target = s.world.colonyTurretTarget(p);
        expect(target, isNotNull);
        // 기하: 포신 각도 = 표적 방향
        final pivot = ColonyBuildingArt.turretPivot(p, _zoom);
        final want = atan2(target!.pos.dy - pivot.dy, target.pos.dx - pivot.dx);
        final aim = ColonyBuildingArt.turretAim(s.world, p, _zoom);
        final err = ((aim - want + pi) % (2 * pi) - pi).abs();
        expect(err, lessThan(15 * pi / 180), reason: 'Lv.$level 조준 각도');
        aims[want] = (await s.render(
          tester,
          ColonyScene.origin,
          _size,
          _zoom,
        )).$1;
      }
      // 픽셀: (표적 A 화면 − 표적 없음) 중 (표적 B 화면 − 표적 없음)에 없는 픽셀 = A 쪽 포신.
      // 그 무게중심이 회전축에서 표적 A 방향에 있어야 한다.
      final p = none.world.planets.single;
      final pl = ColonyBuildingArt.placement(p, ColonyBuilding.turret, _zoom);
      final pivot = scr(ColonyBuildingArt.turretPivot(p, _zoom));
      final inner = pl.size * _zoom * 0.2, outer = pl.size * _zoom * 0.5;
      final keys = aims.keys.toList();
      for (var k = 0; k < 2; k++) {
        final a = aims[keys[k]]!, b = aims[keys[1 - k]]!;
        var sx = 0.0, sy = 0.0, count = 0;
        for (var y = (pivot.dy - outer).floor(); y <= pivot.dy + outer; y++) {
          for (var x = (pivot.dx - outer).floor(); x <= pivot.dx + outer; x++) {
            final d = Offset(x + .5, y + .5) - pivot;
            if (d.distance < inner || d.distance > outer) continue;
            final i = (y * w + x) * 4;
            if (_differs(a, n, i) && !_differs(b, n, i)) {
              sx += d.dx;
              sy += d.dy;
              count++;
            }
          }
        }
        expect(count, greaterThan(10), reason: 'Lv.$level 포신 픽셀');
        final drawn = atan2(sy, sx);
        final err = ((drawn - keys[k] + pi) % (2 * pi) - pi).abs();
        expect(
          err,
          lessThan(15 * pi / 180),
          reason:
              'Lv.$level 화면의 포신 방향 ${drawn * 180 / pi}° vs 표적 ${keys[k] * 180 / pi}°',
        );
      }
    }
  });
}
