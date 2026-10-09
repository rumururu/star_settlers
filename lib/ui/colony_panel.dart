import 'package:flutter/material.dart';

import '../game/models.dart';
import '../game/world.dart';
import 'common.dart';
import 'game_icons.dart';
import 'station_panel.dart' show ActFn;

/// 식민지 관리: 레벨업 + 건물 짓기. 첫 정착 때는 그림 안내 카드가 위에 붙는다.
class ColonyPanel extends StatelessWidget {
  const ColonyPanel({
    super.key,
    required this.world,
    required this.planet,
    required this.frame,
    required this.act,
    required this.onClose,
    required this.onTutorialDone,
  });

  final GameWorld world;
  final Planet planet;
  final Listenable frame;
  final ActFn act;
  final VoidCallback onClose;
  final VoidCallback onTutorialDone;

  @override
  Widget build(BuildContext context) {
    return OverlayPanel(
      onClose: onClose,
      child: ListenableBuilder(
        listenable: frame,
        builder: (context, _) => Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                children: [
                  if (!world.profile.colonyTutorialSeen) _tutorial(),
                  _levelRow(),
                  const Divider(color: Colors.white24, height: 20),
                  for (final b in ColonyBuilding.values) _buildingRow(b),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final w = world;
    final p = planet;
    final dim = Ts.body.copyWith(color: Colors.white70);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 4),
      child: Row(
        children: [
          GameIcon(p.raided ? 'raid' : (p.domeUp ? 'dome' : 'act_settle'), size: 44),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${p.name}  Lv.${p.colonyLevel}', style: titleStyle),
                Wrap(
                  spacing: 10,
                  children: [
                    iconValue('credits', '+${w.planetCreditRate(p).toStringAsFixed(1)}/s', style: dim),
                    if (w.planetOreRate(p) > 0)
                      iconValue('ore', '+${w.planetOreRate(p).toStringAsFixed(1)}/s', style: dim),
                    iconValue(
                        'dome',
                        p.domeUp
                            ? '${p.shieldHp.round()}/${p.shieldMax(w.sectorMul).round()}'
                            : '재충전 중',
                        style: dim),
                  ],
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: onClose),
        ],
      ),
    );
  }

  /// 첫 정착 안내: 그림 위주, 한 줄씩
  Widget _tutorial() {
    Widget tile(String icon, String label) => SizedBox(
          width: 72,
          child: Column(
            children: [
              GameIcon(icon, size: 48),
              const SizedBox(height: 2),
              Text(label,
                  textAlign: TextAlign.center,
                  style: Ts.body.copyWith(color: Colors.white)),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x3342A5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kSky),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 6,
            children: [
              tile('dome', '방어막\n안에 있으면 안전'),
              tile('colony_levelup', '레벨업\n수입·건물↑'),
              tile('b_turret', '포탑'),
              tile('b_mine', '광석'),
              tile('b_trade', '수입 +25%'),
              tile('b_dock', '수리'),
              tile('raid', '습격 막기'),
            ],
          ),
          const SizedBox(height: 6),
          actionBtn('알겠어요', true, onTutorialDone, color: const Color(0xFF1E88E5)),
        ],
      ),
    );
  }

  Widget _levelRow() {
    final p = planet;
    final max = p.colonyLevel >= Planet.maxLevel;
    final c = world.planetCost(p);
    return _row(
      'colony_levelup',
      max ? 'Lv.${p.colonyLevel} MAX' : 'Lv.${p.colonyLevel} → ${p.colonyLevel + 1}',
      iconValue('credits', '+${(p.ratePerLevel.$1 * world.sectorMul).toStringAsFixed(1)}/s',
          style: dimStyle, size: 14),
      max
          ? actionBtn('MAX', false, null)
          : actionBtn('', world.canAfford(c), () => act(() => world.upgradePlanet(p)), cost: c),
    );
  }

  Widget _buildingRow(ColonyBuilding b) {
    final p = planet;
    final lv = p.building(b);
    final Widget btn;
    if (lv >= Planet.maxLevel) {
      btn = actionBtn('MAX', false, null);
    } else if (lv >= p.buildingCap) {
      // 식민지 레벨이 먼저 올라야 한다
      btn = actionBtn('Lv.${lv + 1}', false, null, icon: 'colony_levelup', iconSize: 20);
    } else {
      final c = world.colonyBuildingCost(p, b);
      btn = actionBtn('', world.canAfford(c), () => act(() => world.buildColony(p, b)), cost: c);
    }
    return _row(
      b.iconAsset,
      '${b.label}  Lv.$lv',
      Text(_effect(b, lv == 0 ? 1 : lv), style: dimStyle),
      btn,
    );
  }

  /// 효과 한 줄 (Lv.0이면 Lv.1 미리보기)
  String _effect(ColonyBuilding b, int lv) => switch (b) {
        ColonyBuilding.turret => '피해 ${((5 + lv * 4) * world.sectorMul).toInt()}',
        ColonyBuilding.mine => '광석 +${(0.8 * lv * world.sectorMul).toStringAsFixed(1)}/s',
        ColonyBuilding.trade => '수입 +${lv * 25}%',
        ColonyBuilding.dock => '체력 +${6 + lv * 6}/s',
        ColonyBuilding.shieldGen => '방어막 +${(250 * lv * world.sectorMul).round()}',
      };
}

Widget _row(String icon, String title, Widget sub, Widget trailing) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GameIcon(icon, size: 48),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                sub,
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
