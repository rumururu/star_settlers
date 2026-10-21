import 'package:flutter/material.dart';

import '../game/models.dart';
import '../game/star_catalog.dart';
import '../game/world.dart';
import '../game/system_traits.dart';
import '../l10n/l.dart';
import 'common.dart';
import 'game_icons.dart';
import 'station_panel.dart' show ActFn;

/// 내 식민지: 모든 항성계의 식민지를 한곳에서 보고 바로 레벨업한다.
/// 현재 항성계가 맨 위, 떠나온 항성계는 번호 순. 다른 항성계는 저장 상태를 직접 고친다.
/// Lv.5 이상 식민지는 행 안에서 특화를 펼쳐 고른다 (모달 위 모달을 띄우지 않는다).
class ColoniesPanel extends StatefulWidget {
  const ColoniesPanel({
    super.key,
    required this.world,
    required this.frame,
    required this.act,
    required this.onClose,
  });

  final GameWorld world;
  final Listenable frame;
  final ActFn act;
  final VoidCallback onClose;

  @override
  State<ColoniesPanel> createState() => _ColoniesPanelState();
}

class _ColoniesPanelState extends State<ColoniesPanel> {
  GameWorld get world => widget.world;
  ActFn get act => widget.act;

  /// 특화 선택을 펼친 행 ('항성계:행성번호'), 없으면 null
  String? _picking;

  @override
  Widget build(BuildContext context) => OverlayPanel(
    onClose: widget.onClose,
    child: ListenableBuilder(
      listenable: widget.frame,
      builder: (context, _) => _body(),
    ),
  );

  Widget _body() {
    final w = world;
    final here = [
      for (final p in w.planets)
        if (p.colonyLevel > 0) p,
    ];
    final remote = [
      for (final e
          in (w.sectors.entries.toList()..sort((a, b) => a.key - b.key)))
        (
          e.key,
          [
            for (var i = 0; i < e.value.colonyLevels.length; i++)
              if (e.value.colonyLevels[i] > 0) i,
          ],
        ),
    ].where((s) => s.$2.isNotEmpty).toList();
    final empty = here.isEmpty && remote.isEmpty;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.l, Space.m, Space.xs, 0),
          child: Row(
            children: [
              const GameIcon('colony_levelup', size: IconSz.row),
              const SizedBox(width: Space.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr.u_myColonies, style: titleStyle),
                    Text(keepAll(tr.u_myColoniesHint), style: dimStyle),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white24, height: Space.l),
        Expanded(
          child: empty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Space.l),
                    child: Text(
                      keepAll(tr.u_noColonies),
                      style: dimStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Space.l,
                    0,
                    Space.l,
                    Space.l,
                  ),
                  children: [
                    if (here.isNotEmpty) ...[
                      _systemHeader(w.sectorName, current: true),
                      for (final (i, p) in w.planets.indexed)
                        if (p.colonyLevel > 0) _localRow(i, p),
                    ],
                    for (final (sector, indexes) in remote) ...[
                      _systemHeader(systemName(sector)),
                      for (final i in indexes) _remoteRow(sector, i),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _systemHeader(String name, {bool current = false}) => Padding(
    padding: const EdgeInsets.only(top: Space.m, bottom: Space.xs),
    child: Row(
      children: [
        Flexible(
          child: Text(
            name,
            style: sectionStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (current) ...[
          const SizedBox(width: Space.s),
          Text(
            tr.u_currentHere,
            style: Ts.caption.copyWith(color: const Color(0xFF7CFFB2)),
          ),
        ],
      ],
    ),
  );

  Widget _localRow(int index, Planet p) {
    final w = world;
    final stab = ColonyBuilding.stabilizer;
    return _row(
      key: '${w.sector}:$index',
      planet: p,
      income: w.planetCreditRate(p),
      levelCost: w.planetCost(p),
      onLevel: () => act(() => w.upgradePlanet(p)),
      anchorCost: w.colonyBuildingCost(p, stab),
      onAnchor: () => act(() => w.buildColony(p, stab)),
      specCost: w.specCost(p),
      onSpec: (s) => act(() => w.setColonySpec(p, s)),
    );
  }

  Widget _remoteRow(int sector, int index) {
    final w = world;
    final p = w.remotePlanet(sector, index);
    final stab = ColonyBuilding.stabilizer;
    return _row(
      key: '$sector:$index',
      planet: p,
      income:
          p.baseCreditRate *
          (1 + sector * GameWorld.sectorIncomeStep) *
          w.incomeMul *
          systemTrait(sector).colonyCreditMul,
      levelCost: w.remotePlanetCost(sector, p),
      onLevel: () => act(() => w.upgradeRemotePlanet(sector, index)),
      anchorCost: w.remoteBuildingCost(sector, p, stab),
      onAnchor: () =>
          act(() => w.upgradeRemotePlanet(sector, index, building: stab)),
      specCost: w.remoteSpecCost(sector, p),
      onSpec: (s) => act(() => w.setRemoteColonySpec(sector, index, s)),
    );
  }

  /// 펼친 특화 선택 (행을 누르면 열리고 닫힌다). 레벨이 떨어져 효과가 꺼진 특화는 안내 한 줄.
  List<Widget> _specRows({
    required String key,
    required Planet planet,
    required Cost cost,
    required void Function(ColonySpec) onSpec,
  }) {
    final current = planet.spec;
    if (!GameWorld.canSpecialize(planet)) {
      // 레벨이 떨어져도 특화는 남는다 (효과는 Lv.5 이상에서만)
      return [
        if (current != null)
          Text(
            keepAll(tr.u_specInactive(ColonySpec.minLevel)),
            style: Ts.caption,
          ),
      ];
    }
    if (_picking != key) return const [];
    return [
      for (final s in ColonySpec.values)
        Container(
          margin: const EdgeInsets.only(top: Space.xs),
          padding: const EdgeInsets.symmetric(horizontal: Space.s),
          decoration: BoxDecoration(
            color: s == current ? const Color(0x337CFFB2) : null,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: s == current ? const Color(0xFF7CFFB2) : Colors.white24,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      keepAll('${s.emoji} ${s.label}'),
                      style: Ts.body.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(keepAll(s.effect), style: Ts.caption),
                  ],
                ),
              ),
              const SizedBox(width: Space.s),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: s == current
                      ? actionBtn('✓', false, null)
                      : current == null
                      ? actionBtn(tr.u_specFree, true, () => onSpec(s))
                      : actionBtn(
                          '',
                          world.canAfford(cost),
                          () => onSpec(s),
                          cost: cost,
                        ),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _row({
    required String key,
    required Planet planet,
    required double income,
    required Cost levelCost,
    required VoidCallback onLevel,
    required Cost anchorCost,
    required VoidCallback onAnchor,
    required Cost specCost,
    required void Function(ColonySpec) onSpec,
  }) {
    final w = world;
    final lv = planet.colonyLevel;
    final levelLocked = lv < Planet.maxLevel && lv >= w.colonyLevelCap;
    final anchor = planet.building(ColonyBuilding.stabilizer);
    final current = planet.spec;
    final canSpec = GameWorld.canSpecialize(planet);
    final open = _picking == key;
    // 특화 표시는 정박기 줄 앞에 붙인다 (행 높이를 늘리지 않게 한 줄, 넘치면 말줄임)
    final String? specText = current != null
        ? '${current.emoji} ${current.label}${canSpec ? (open ? ' ▴' : ' ▾') : ''}'
        : canSpec
        ? '✨ ${tr.u_specChoose}${open ? ' ▴' : ' ▾'}'
        : null;
    final Widget levelBtn = lv >= Planet.maxLevel
        ? actionBtn('MAX', false, null, icon: 'colony_levelup')
        : levelLocked
        ? actionBtn('🔒', false, null, icon: 'colony_levelup')
        : actionBtn(
            '',
            w.canAfford(levelCost),
            onLevel,
            icon: 'colony_levelup',
            cost: levelCost,
          );
    final Widget anchorBtn = anchor >= Planet.maxLevel
        ? actionBtn(
            'MAX',
            false,
            null,
            icon: ColonyBuilding.stabilizer.iconAsset,
          )
        : anchor >= planet.buildingCap
        // 식민지 레벨이 먼저 올라야 한다
        ? actionBtn(
            'Lv.${anchor + 1}',
            false,
            null,
            icon: ColonyBuilding.stabilizer.iconAsset,
          )
        : actionBtn(
            '',
            w.canAfford(anchorCost),
            onAnchor,
            icon: ColonyBuilding.stabilizer.iconAsset,
            cost: anchorCost,
          );
    // 행(버튼 밖)을 누르면 특화 선택을 펼친다. 행 전체가 48dp 이상의 터치 영역이다.
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: canSpec
          ? () => setState(() => _picking = open ? null : key)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/sprites/planet_${planet.kind.name}.png',
                  width: IconSz.row,
                  height: IconSz.row,
                  filterQuality: FilterQuality.medium,
                ),
                const SizedBox(width: Space.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${planet.name}  Lv.$lv',
                              overflow: TextOverflow.ellipsis,
                              style: Ts.body.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          iconValue(
                            'credits',
                            '+${income.toStringAsFixed(1)}/s',
                            size: IconSz.inline,
                            style: dimStyle,
                          ),
                        ],
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            if (specText != null) ...[
                              TextSpan(
                                text: keepAll(specText),
                                style: TextStyle(
                                  color: !canSpec
                                      ? Colors.white54
                                      : current == null
                                      ? kSky
                                      : const Color(0xFF7CFFB2),
                                ),
                              ),
                              const TextSpan(text: '  ·  '),
                            ],
                            TextSpan(
                              text:
                                  '${ColonyBuilding.stabilizer.label}  Lv.$anchor',
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Ts.caption,
                      ),
                      const SizedBox(height: Space.xs),
                      Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: levelBtn,
                            ),
                          ),
                          const SizedBox(width: Space.s),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: anchorBtn,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (levelLocked)
              Text(
                keepAll(tr.u_levelUnlockAtSystem(lv + 1, lv - 2)),
                style: dimStyle,
              ),
            ..._specRows(
              key: key,
              planet: planet,
              cost: specCost,
              onSpec: onSpec,
            ),
          ],
        ),
      ),
    );
  }
}
