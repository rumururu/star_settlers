import 'package:flutter/material.dart';

import '../game/cosmetics.dart';

/// 함선 [shipId]에 스킨 [skin]을 입힌 그림. 그림을 빌려 쓰는 스킨([ShipSkin.sprite])은
/// 빌린 그림에 색상 회전([ShipSkin.hue])을 걸어 보여 준다 (예: 7일 출석 전용 스킨).
Widget shipSkinImage(
  String shipId,
  ShipSkin skin, {
  double? width,
  double? height,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  final image = Image.asset(
    'assets/sprites/ship_${shipId}_${skin.sprite}.png',
    width: width,
    height: height,
    filterQuality: FilterQuality.medium,
    errorBuilder: errorBuilder,
  );
  final hue = skin.hue;
  return hue == null
      ? image
      : ColorFiltered(
          colorFilter: ColorFilter.matrix(hueRotateMatrix(hue)),
          child: image,
        );
}
