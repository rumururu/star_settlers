import 'package:flutter/material.dart';

import '../game/models.dart';
import '../game/world.dart';
import 'common.dart';
import 'game_icons.dart';
import 'station_panel.dart' show ActFn;

/// 항성계 현황: 발전도, 행성 목록, 점령한 다른 항성계
class SystemPanel extends StatelessWidget {
  const SystemPanel({super.key, required this.world, required this.frame, required this.onClose});

  final GameWorld world;
  final Listenable frame;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => OverlayPanel(
        onClose: onClose,
        child: ListenableBuilder(listenable: frame, builder: (context, _) => _body()),
      );

  Widget _body() {
    final w = world;
    final dev = w.development;
    final open = dev >= 1 || w.counter('maxSector') > w.sector;
    // 발전도가 낮은 행성부터 (할 일 순)
    final planets = [...w.planets]..sort((a, b) => a.colonyLevel.compareTo(b.colonyLevel));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.l, Space.m, Space.xs, 0),
          child: Row(
            children: [
              const GameIcon('menu_home', size: IconSz.row),
              const SizedBox(width: Space.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${w.sectorName} · 항성계 ${w.sector + 1}', style: titleStyle),
                    Text('위협 ${w.threat.toStringAsFixed(1)} · 자원 배율 x${w.sectorMul.toStringAsFixed(1)}',
                        style: dimStyle),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: onClose),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.l, vertical: Space.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('발전도 ${(dev * 100).floor()}%', style: sectionStyle),
                  const Spacer(),
                  iconValue('act_warp', open ? '다음 항성계 열림' : '100%에서 열림',
                      size: IconSz.inline,
                      style: Ts.body.copyWith(color: open ? const Color(0xFFB388FF) : Colors.white60)),
                ],
              ),
              const SizedBox(height: Space.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: dev,
                  minHeight: 12,
                  color: open ? const Color(0xFFB388FF) : const Color(0xFF7CFFB2),
                  backgroundColor: Colors.white12,
                ),
              ),
              const SizedBox(height: Space.xs),
              const Text('모든 행성을 Lv.3까지 키우면 100%', style: dimStyle),
            ],
          ),
        ),
        const Divider(color: Colors.white24, height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Space.l, Space.s, Space.l, Space.l),
            children: [
              for (final p in planets) _planetRow(p),
              if (w.sectors.isNotEmpty) ...[
                const Divider(color: Colors.white24, height: Space.xl),
                const Text('점령한 항성계 (계속 생산 중)', style: sectionStyle),
                for (final e in (w.sectors.entries.toList()..sort((a, b) => a.key - b.key)))
                  _otherSystemRow(e.key, e.value),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _planetRow(Planet p) {
    final w = world;
    final lv = p.colonyLevel;
    final contribution = (lv.clamp(0, GameWorld.devLevelCap)) / GameWorld.devLevelCap;
    final built = [
      for (final b in ColonyBuilding.values)
        if (p.building(b) > 0) b,
    ];
    final Widget status;
    if (lv == 0) {
      status = const Text('미정착', style: dimStyle);
    } else if (p.raided) {
      status = iconValue('raid', '습격 중', size: IconSz.inline, style: Ts.body.copyWith(color: const Color(0xFFFF8A80)));
    } else {
      status = iconValue('credits', '+${w.planetCreditRate(p).toStringAsFixed(1)}/s',
          size: IconSz.inline, style: dimStyle);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: Row(
        children: [
          Opacity(
            opacity: lv == 0 ? 0.45 : 1,
            child: Image.asset('assets/sprites/planet_${p.kind.name}.png',
                width: IconSz.row, height: IconSz.row, filterQuality: FilterQuality.medium),
          ),
          const SizedBox(width: Space.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(lv == 0 ? p.name : '${p.name}  Lv.$lv',
                          overflow: TextOverflow.ellipsis,
                          style: Ts.body.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: Space.xs),
                    for (final b in built) GameIcon(b.iconAsset, size: 18),
                  ],
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: contribution,
                    minHeight: 6,
                    color: contribution >= 1 ? const Color(0xFF7CFFB2) : const Color(0xFFFFD54F),
                    backgroundColor: Colors.white12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Space.m),
          status,
        ],
      ),
    );
  }

  Widget _otherSystemRow(int index, SectorSave s) {
    final name = index < sectorNames.length ? sectorNames[index] : '미지의 섹터 ${index + 1}';
    final dev = GameWorld.developmentOf(s.colonyLevels);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: Row(
        children: [
          Expanded(child: Text('$name · 발전 ${(dev * 100).floor()}%', style: bodyStyle)),
          iconValue('credits', '+${(s.idleCredits * world.incomeMul).toStringAsFixed(1)}/s',
              size: IconSz.inline, style: dimStyle),
          if (s.idleOre > 0) ...[
            const SizedBox(width: Space.s),
            iconValue('ore', '+${s.idleOre.toStringAsFixed(1)}/s', size: IconSz.inline, style: dimStyle),
          ],
        ],
      ),
    );
  }
}

/// 정거장 건설: 역할 고르기
class StationBuildPanel extends StatelessWidget {
  const StationBuildPanel({super.key, required this.world, required this.act, required this.onClose});

  final GameWorld world;
  final ActFn act;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = world.stationBuildCost;
    return OverlayPanel(
      onClose: onClose,
      maxWidth: 520,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Space.l),
        children: [
          Row(
            children: [
              const Expanded(child: Text('정거장 건설 · 역할 고르기', style: titleStyle)),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: onClose),
            ],
          ),
          Row(children: [const Text('비용 ', style: dimStyle), costView(c, style: dimStyle)]),
          const SizedBox(height: Space.s),
          for (final r in [StationRole.defense, StationRole.repair, StationRole.support])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xs),
              child: Row(
                children: [
                  GameIcon(r.iconAsset, size: IconSz.row),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.label, style: Ts.body.copyWith(fontWeight: FontWeight.bold)),
                        Text(r.blurb, style: dimStyle),
                      ],
                    ),
                  ),
                  const SizedBox(width: Space.s),
                  actionBtn('건설', world.canAfford(c), () {
                    onClose();
                    act(() => world.buildStation(r));
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
