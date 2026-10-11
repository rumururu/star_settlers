import 'package:flutter/material.dart';

import '../game/models.dart';
import '../game/world.dart';
import 'tokens.dart';

/// `assets/icons/{name}.png` 아이콘 (256px 투명 PNG)
class GameIcon extends StatelessWidget {
  const GameIcon(this.name, {super.key, this.size = 24, this.opacity = 1});
  final String name;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/icons/$name.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
        opacity: opacity == 1 ? null : AlwaysStoppedAnimation(opacity),
      );
}

/// 아이콘 + 숫자 한 쌍
Widget iconValue(String icon, String value,
        {double size = 18, TextStyle style = Ts.body}) =>
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [GameIcon(icon, size: size), const SizedBox(width: 2), Text(value, style: style)],
    );

/// 비용 표시: [코인]150 [광석]40
/// 모자란 비용 표시 색
const kShortRed = Color(0xFFFF6B6B);

/// [creditColor]가 있으면 크레딧 숫자만 그 색으로 (모자랄 때 빨강)
Widget costView(Cost c, {double size = 18, TextStyle style = Ts.body, Color? creditColor}) =>
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconValue('credits', '${c.$1}', size: size, style: creditColor == null ? style : style.copyWith(color: creditColor)),
        if (c.$2 > 0) ...[const SizedBox(width: 6), iconValue('ore', '${c.$2}', size: size, style: style)],
      ],
    );

extension ColonyBuildingIcon on ColonyBuilding {
  String get iconAsset => switch (this) {
        ColonyBuilding.turret => 'b_turret',
        ColonyBuilding.mine => 'b_mine',
        ColonyBuilding.trade => 'b_trade',
        ColonyBuilding.dock => 'b_dock',
        ColonyBuilding.shieldGen => 'dome',
      };
}

extension UpgradeKindIcon on UpgradeKind {
  String get iconAsset => switch (this) {
        UpgradeKind.weapon => 'up_weapon',
        UpgradeKind.hull => 'up_hull',
        UpgradeKind.engine => 'up_engine',
        UpgradeKind.missile => 'up_missile',
        UpgradeKind.shield => 'up_shield',
        UpgradeKind.drone => 'up_drone',
        UpgradeKind.magnet => 'up_magnet',
      };
}
