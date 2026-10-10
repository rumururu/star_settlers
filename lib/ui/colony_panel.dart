import 'package:flutter/material.dart';

import '../game/models.dart';
import '../game/world.dart';
import '../l10n/l.dart';
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
          // 행성 그림 + 오른쪽 아래 상태 배지 (습격 / 방어막)
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset('assets/sprites/planet_${p.kind.name}.png',
                    width: 44, height: 44, filterQuality: FilterQuality.medium),
                if (p.raided || p.domeUp)
                  Positioned(right: -2, bottom: -2, child: GameIcon(p.raided ? 'raid' : 'dome', size: 22)),
              ],
            ),
          ),
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
                            : tr.u_recharging,
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
              tile('dome', tr.u_tutDome),
              tile('colony_levelup', tr.u_tutLevelUp),
              tile('b_turret', tr.u_tutTurret),
              tile('b_mine', tr.u_ore),
              tile('b_trade', tr.u_incomePct(25)),
              tile('b_dock', tr.u_tutRepair),
              tile('raid', tr.u_tutRaid),
            ],
          ),
          const SizedBox(height: 6),
          actionBtn(tr.u_gotIt, true, onTutorialDone, color: const Color(0xFF1E88E5)),
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
        ColonyBuilding.turret => tr.u_damage(((5 + lv * 4) * world.sectorMul).toInt()),
        ColonyBuilding.mine => tr.u_oreRate((0.8 * lv * world.sectorMul).toStringAsFixed(1)),
        ColonyBuilding.trade => tr.u_incomePct(lv * 25),
        ColonyBuilding.dock => tr.u_repairRate(6 + lv * 6),
        ColonyBuilding.shieldGen => tr.u_shieldPlus((250 * lv * world.sectorMul).round()),
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
          // 버튼이 길면(번역에 따라) 글자 대신 버튼이 줄어든다
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: FittedBox(fit: BoxFit.scaleDown, child: trailing),
          ),
        ],
      ),
    );
