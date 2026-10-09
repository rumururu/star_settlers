import '../game/josa.dart';
import 'dart:math';

import 'package:flutter/material.dart';

import '../game/crew.dart';
import '../game/missions.dart';
import '../game/models.dart';
import '../game/profile.dart';
import '../game/ships.dart';
import '../game/world.dart';
import 'chibi.dart';
import 'common.dart';
import 'game_icons.dart';
import 'hangar_screen.dart';

typedef ActFn = void Function(bool Function() action);

class StationPanel extends StatelessWidget {
  const StationPanel({
    super.key,
    required this.world,
    required this.station,
    required this.frame,
    required this.act,
    required this.onClose,
    required this.onOpenShop,
  });

  final GameWorld world;
  final Station station;
  final Listenable frame;
  final ActFn act;
  final VoidCallback onClose;
  final VoidCallback onOpenShop;

  @override
  Widget build(BuildContext context) {
    return OverlayPanel(
      onClose: onClose,
      maxWidth: 600,
      child: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            ListenableBuilder(listenable: frame, builder: (c, _) => _header()),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: kSky,
              tabs: [
                Tab(icon: GameIcon('tab_ship', size: 30), text: '함선', iconMargin: const EdgeInsets.only(bottom: 2)),
                Tab(icon: GameIcon('tab_station', size: 30), text: '정거장', iconMargin: const EdgeInsets.only(bottom: 2)),
                Tab(icon: GameIcon('tab_crew', size: 30), text: '승무원', iconMargin: const EdgeInsets.only(bottom: 2)),
                Tab(icon: GameIcon('tab_mission', size: 30), text: '임무', iconMargin: const EdgeInsets.only(bottom: 2)),
                Tab(icon: GameIcon('tab_market', size: 30), text: '시장', iconMargin: const EdgeInsets.only(bottom: 2)),
              ],
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: frame,
                builder: (context, _) => TabBarView(
                  children: [
                    _ShipTab(world: world, act: act),
                    _StationTab(world: world, station: station, act: act),
                    _CrewTab(world: world, act: act, onOpenShop: onOpenShop),
                    _MissionTab(world: world, act: act),
                    _MarketTab(world: world, act: act, onOpenShop: onOpenShop),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 4),
        child: Row(
          children: [
            const ChibiPortrait(style: ChibiStyle.advisor, size: 52),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name, style: titleStyle),
                  Wrap(
                    spacing: 10,
                    children: [
                      iconValue('credits',
                          '${compact(world.credits)} +${world.creditIncome.toStringAsFixed(1)}/s',
                          style: dimStyle),
                      iconValue('ore', '${compact(world.ore)} +${world.oreIncome.toStringAsFixed(1)}/s',
                          style: dimStyle),
                      iconValue('gem', '${world.profile.gems}', style: dimStyle),
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

Widget _row(String title, String desc, Widget trailing, {Widget? leading, Widget? badge}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 8)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge == null)
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                else
                  Wrap(
                    spacing: Space.s,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      badge,
                    ],
                  ),
                Text(desc, style: dimStyle),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );

class _ShipTab extends StatelessWidget {
  const _ShipTab({required this.world, required this.act});
  final GameWorld world;
  final ActFn act;

  String _desc(UpgradeKind k) {
    final w = world;
    return switch (k) {
      UpgradeKind.weapon => '공격력 ${w.playerDamage.toInt()} · Lv.3 2연발 · Lv.6 3연발',
      UpgradeKind.hull => '최대 체력 ${w.playerMaxHp.toInt()}',
      UpgradeKind.engine => '최고 속도 ${w.playerSpeed.toInt()}',
      UpgradeKind.missile => w.level(k) == 0
          ? '적을 추적하는 미사일 (Q키 / 🚀 버튼)'
          : '${2 + w.level(k) ~/ 2}발 · 쿨타임 ${w.missileCooldownMax.toStringAsFixed(1)}초',
      UpgradeKind.shield => w.level(k) == 0
          ? '모든 피해를 막는 실드 (F키 / 🛡 버튼)'
          : '${(2.5 + w.level(k) * 0.5).toStringAsFixed(1)}초 · 쿨타임 ${w.shieldCooldownMax.toStringAsFixed(1)}초',
      UpgradeKind.drone => w.level(k) == 0
          ? '곁을 돌며 자동으로 쏘고 아이템을 끌어와요'
          : '피해 ${w.droneDamage.toInt()} · ${w.droneInterval.toStringAsFixed(2)}초마다 발사',
      UpgradeKind.magnet => '크레딧·광석을 끌어오는 범위 ${w.magnetRadius.toInt()} · 힘 x${(w.magnetPull / 1400).toStringAsFixed(1)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        for (final k in UpgradeKind.values)
          _row(
            '${k.label}  Lv.${world.level(k)}${world.level(k) >= k.maxLevel ? ' (MAX)' : ''}',
            _desc(k),
            world.level(k) >= k.maxLevel
                ? actionBtn('MAX', false, null)
                : actionBtn(
                    world.level(k) == 0 &&
                            (k == UpgradeKind.missile || k == UpgradeKind.shield || k == UpgradeKind.drone)
                        ? '장착'
                        : '',
                    world.canAfford(world.upgradeCost(k)),
                    () => act(() => world.upgradeShip(k)),
                    cost: world.upgradeCost(k),
                  ),
            leading: GameIcon(k.iconAsset, size: 44),
          ),
        const SizedBox(height: 8),
        const Text('💨 부스트(Shift / 💨 버튼)는 기본 장착되어 있어요.', style: dimStyle),
        const Divider(color: Colors.white24, height: 28),
        Row(
          children: [
            const Expanded(child: Text('🛸 격납고', style: sectionStyle)),
            actionBtn('크게 보기', true, () => _openHangar(context, null), icon: 'tab_ship'),
          ],
        ),
        const SizedBox(height: 4),
        for (final t in shipTypes) _shipRow(t),
      ],
    );
  }

  Widget _shipRow(ShipType t) {
    final p = world.profile;
    final unlocked = p.shipUnlocked(t);
    final current = p.shipType == t.id;
    final stats = [
      if (t.hpMul != 1) '체력 x${t.hpMul}',
      if (t.speedMul != 1) '속도 x${t.speedMul}',
      if (t.dmgMul != 1) '공격 x${t.dmgMul}',
      if (t.fireMul != 1) '연사 x${(1 / t.fireMul).toStringAsFixed(2)}',
      if (t.oreMul != 1) '광석 x${t.oreMul}',
      if (t.crit > 0) '치명타 ${(t.crit * 100).round()}%',
    ].join(' · ');
    final Widget trailing;
    if (current) {
      trailing = const Text('탑승 중', style: TextStyle(color: Color(0xFF7CFFB2)));
    } else if (unlocked) {
      trailing = actionBtn('탑승', true, () => act(() => world.switchShip(t)));
    } else {
      trailing = actionBtn('⭐${t.gemPrice}', p.gems >= t.gemPrice, () => act(() => world.buyShip(t)),
          color: const Color(0xFFAD1457));
    }
    final ability = t.ability.isEmpty ? '' : '\n✨ ${t.ability}';
    final unlockHint = unlocked ? '' : (t.premium ? '\n젬으로만 구매할 수 있어요' : '\n해금: ${t.unlockDesc} 또는 젬');
    return _row(
      '${t.name}${unlocked ? '' : ' 🔒'}',
      '${t.desc}${stats.isEmpty ? '' : '\n$stats'}$ability$unlockHint',
      trailing,
      badge: t.premium ? const PremiumBadge() : null,
      // 지금 장착한 스킨을 입힌 함선 그림 (잠긴 함선은 흐리게). 누르면 크게 보기
      leading: Builder(
        builder: (context) => GestureDetector(
          onTap: () => _openHangar(context, t.id),
          child: Opacity(
        opacity: unlocked ? 1 : 0.45,
        child: Image.asset('assets/sprites/ship_${t.id}_${p.skin}.png',
            width: IconSz.row + 8, height: IconSz.row + 8, filterQuality: FilterQuality.medium),
          ),
        ),
      ),
    );
  }
}

void _openHangar(BuildContext context, String? id) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => HangarScreen(initialId: id)));

class _StationTab extends StatelessWidget {
  const _StationTab({required this.world, required this.station, required this.act});
  final GameWorld world;
  final Station station;
  final ActFn act;

  @override
  Widget build(BuildContext context) {
    final s = station;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _row(s.role.label, s.role.blurb, const SizedBox.shrink(),
            leading: GameIcon(s.role.iconAsset, size: 44)),
        Text('내구도 ${s.hp.toInt()} / ${s.maxHp.toInt()}', style: dimStyle),
        const SizedBox(height: 6),
        _row(
          '거주구역  Lv.${s.habitatLevel}',
          '수입 💰${world.stationCreditRate(s).toStringAsFixed(1)}/s · 내구도 ${s.maxHp.toInt()}',
          s.habitatLevel >= Station.maxLevel
              ? actionBtn('MAX', false, null)
              : actionBtn('', world.canAfford(world.habitatCost(s)), () => act(() => world.upgradeHabitat(s)),
                  cost: world.habitatCost(s)),
          leading: const GameIcon('st_habitat', size: 44),
        ),
        _row(
          '방어포탑  Lv.${s.turretLevel}',
          s.turretLevel == 0
              ? '해적을 자동으로 요격해요'
              : '피해 ${(s.turretDamage * world.sectorMul).toInt()} · 사거리 ${s.turretRange.toInt()}',
          s.turretLevel >= Station.maxLevel
              ? actionBtn('MAX', false, null)
              : actionBtn('', world.canAfford(world.turretCost(s)), () => act(() => world.upgradeTurret(s)),
                  cost: world.turretCost(s)),
          leading: const GameIcon('st_turret', size: 44),
        ),
        if (s.isHome)
          _row(
            '본거지 강화  Lv.${s.baseLevel}',
            '레이저 ${s.laserDamage.toInt()} · 사거리 ${s.laserRange.toInt()} · 내구도 ${s.maxHp.toInt()}'
                '${s.disabled ? '\n기능 정지 ${s.disabledTime.ceil()}초' : ''}',
            s.baseLevel >= Station.maxBaseLevel
                ? actionBtn('MAX', false, null)
                : actionBtn('', world.canAfford(world.baseUpgradeCost(s)), () => act(() => world.upgradeBase(s)),
                    cost: world.baseUpgradeCost(s)),
            leading: const GameIcon('dome', size: 44),
          ),
        const Divider(color: Colors.white24),
        Text('${world.sectorName} 현황', style: sectionStyle),
        const SizedBox(height: 4),
        Text(
          '정착한 행성 ${world.colonyCount} / ${world.planets.length}\n'
          '정거장 ${world.stations.length}개\n'
          '섹터 보너스: 생산량 x${world.sectorMul.toStringAsFixed(1)}\n'
          '다른 섹터 수입: 💰${world.otherSectorCredits.toStringAsFixed(1)}/s',
          style: bodyStyle,
        ),
      ],
    );
  }
}

class _CrewTab extends StatelessWidget {
  const _CrewTab({required this.world, required this.act, required this.onOpenShop});
  final GameWorld world;
  final ActFn act;
  final VoidCallback onOpenShop;

  Future<void> _recruit(BuildContext context, CrewMember? Function() f) async {
    CrewMember? got;
    act(() {
      got = f();
      return got != null;
    });
    final c = got;
    if (c == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kPanelColor,
        title: Text(
            c.legendary
                ? '🌟 전설 등급! 🌟'
                : (c.rarity == 3 ? '✨ 희귀한 동료! ✨' : '새 동료 합류!'),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChibiPortrait(style: ChibiStyle.forCrew(c), size: 140),
            Text(c.stars, style: Ts.title.copyWith(color: Color(0xFFFFD54F))),
            Text('${c.role.icon} ${c.role.label} ${c.displayName}', style: titleStyle),
            Text('${c.role.effect} +${c.bonusPct}%', style: bodyStyle),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('좋아!'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = world;
    final full = w.roster.length >= w.rosterCap;
    final p = w.profile;
    final slotPrice = p.nextCrewSlotPrice;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Text('승무원 ${w.roster.length}/${w.rosterCap} · 배치 ${w.assignedCount}/${w.crewSlots}',
            style: sectionStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            actionBtn('영입 💰${w.recruitCost}', !full && w.credits >= w.recruitCost,
                () => _recruit(context, w.recruitWithCredits)),
            actionBtn('고급 영입 ⭐${GameWorld.recruitGemCost}',
                !full && w.profile.gems >= GameWorld.recruitGemCost,
                () => _recruit(context, w.recruitWithGems),
                color: const Color(0xFFAD1457)),
            actionBtn('🌟 전설 확정 모집 ⭐${GameWorld.legendaryGemCost}',
                !full && p.gems >= GameWorld.legendaryGemCost,
                () => _recruit(context, w.recruitLegendary),
                color: const Color(0xFFFF6F00)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '확률 안내 · 일반 영입: ${CrewMember.oddsText(CrewMember.creditOdds)}\n'
          '고급 영입: ${CrewMember.oddsText(CrewMember.gemOdds)}\n'
          '전설 확정 모집: ★4 100%',
          style: dimStyle,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            actionBtn(
                slotPrice == null ? '배치 슬롯 MAX (${w.crewSlots})' : '배치 슬롯 +1 ⭐$slotPrice',
                slotPrice != null && p.gems >= slotPrice,
                () => act(p.buyCrewSlot),
                color: const Color(0xFFAD1457)),
            actionBtn(
                p.rosterPacks >= Profile.maxRosterPacks
                    ? '정원 MAX (${w.rosterCap})'
                    : '정원 +${Profile.rosterPackSize} ⭐${Profile.rosterPackPrice}',
                p.rosterPacks < Profile.maxRosterPacks && p.gems >= Profile.rosterPackPrice,
                () => act(p.buyRosterPack),
                color: const Color(0xFFAD1457)),
          ],
        ),
        const Divider(color: Colors.white24),
        if (w.roster.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('아직 동료가 없어요. 영입해서 함선에 배치해봐요!',
                style: bodyStyle, textAlign: TextAlign.center),
          ),
        for (final c in w.roster)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.assigned ? const Color(0x332196F3) : const Color(0x22FFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.assigned ? kSky : Colors.white12),
            ),
            child: Row(
              children: [
                ChibiPortrait(style: ChibiStyle.forCrew(c), size: 56),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${c.stars} ${c.displayName}  Lv.${c.level}',
                          style: TextStyle(
                              color: c.legendary
                                  ? const Color(0xFFFF9E40)
                                  : (c.rarity == 3 ? const Color(0xFFFFD54F) : Colors.white),
                              fontWeight: FontWeight.bold)),
                      Text('${c.role.icon} ${c.role.label} · ${c.role.effect} +${c.bonusPct}%',
                          style: dimStyle),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    actionBtn(c.assigned ? '해제' : '배치',
                        c.assigned || w.assignedCount < w.crewSlots, () => act(() => w.toggleAssign(c)),
                        color: c.assigned ? const Color(0xFF455A64) : const Color(0xFF1E88E5)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        actionBtn(c.level >= CrewMember.maxLevel ? 'MAX' : '⬆ 💰${c.levelUpCost}',
                            c.level < CrewMember.maxLevel && w.credits >= c.levelUpCost,
                            () => act(() => w.levelUpCrew(c))),
                        IconButton(
                          tooltip: '방출',
                          icon: const Icon(Icons.logout, color: Colors.white38, size: 18),
                          onPressed: () async {
                            if (await confirmDialog(
                                context, '승무원 방출', '${eul(c.name)} 떠나보낼까요? 되돌릴 수 없어요.')) {
                              act(() {
                                w.dismissCrew(c);
                                return true;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MissionTab extends StatelessWidget {
  const _MissionTab({required this.world, required this.act});
  final GameWorld world;
  final ActFn act;

  String _progress(Mission m) => switch (m.type) {
        MissionType.kill || MissionType.mine => '${min(m.progress, m.target)} / ${m.target}',
        MissionType.deliver => '목적지로 이동하세요 (노란 화살표)',
        MissionType.bounty => '목표를 찾아 처치하세요 (노란 화살표)',
      };

  String _reward(Mission m) =>
      '보상 💰${m.rewardCredits}${m.rewardGems > 0 ? ' ⭐${m.rewardGems}' : ''}';

  @override
  Widget build(BuildContext context) {
    final w = world;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Text('진행 중 (${w.activeMissions.length}/3)', style: sectionStyle),
        if (w.activeMissions.isEmpty) const Text('진행 중인 임무가 없어요.', style: dimStyle),
        for (final m in w.activeMissions)
          _row('${m.icon} ${m.title(w.planets)}', '${_progress(m)} · ${_reward(m)}',
              TextButton(
                onPressed: () => act(() {
                  w.abandonMission(m);
                  return true;
                }),
                child: const Text('포기', style: TextStyle(color: Colors.white54)),
              )),
        const Divider(color: Colors.white24),
        Text('임무 게시판 · 새 임무까지 ${w.offerTimer.ceil()}초', style: sectionStyle),
        for (final m in w.missionOffers)
          _row('${m.icon} ${m.title(w.planets)}', _reward(m),
              actionBtn('수락', w.activeMissions.length < 3, () => act(() => w.acceptMission(m)))),
      ],
    );
  }
}

class _MarketTab extends StatelessWidget {
  const _MarketTab({required this.world, required this.act, required this.onOpenShop});
  final GameWorld world;
  final ActFn act;
  final VoidCallback onOpenShop;

  @override
  Widget build(BuildContext context) {
    final w = world;
    final price = w.orePrice;
    final base = 2 + w.sector * 0.6;
    final trend = price > base * 1.15
        ? '📈 비싸요! 팔 때예요'
        : (price < base * 0.85 ? '📉 싸요… 기다려봐요' : '➡ 보통');
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('광석 시세', style: sectionStyle),
        const SizedBox(height: 4),
        Text('1💎 = 💰${price.toStringAsFixed(2)}   $trend', style: bodyStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            actionBtn('100개 판매', w.ore >= 1, () => act(() => w.sellOre(100))),
            actionBtn('절반 판매', w.ore >= 2, () => act(() => w.sellOre(w.ore ~/ 2))),
            actionBtn('전부 판매', w.ore >= 1, () => act(() => w.sellOre(w.ore.floor()))),
          ],
        ),
        const SizedBox(height: 6),
        const Text('시세는 시간에 따라 오르내려요. 비쌀 때 팔면 이득!', style: dimStyle),
        const Divider(color: Colors.white24),
        const Text('⭐ 스타젬 교환', style: sectionStyle),
        _row('크레딧 꾸러미', '⭐${GameWorld.creditPackGems} → 💰${w.creditPackAmount}',
            actionBtn('교환', w.profile.gems >= GameWorld.creditPackGems,
                () => act(w.buyCreditsWithGems),
                color: const Color(0xFFAD1457))),
        const SizedBox(height: 8),
        actionBtn('⭐ 상점 열기', true, onOpenShop, color: const Color(0xFFAD1457)),
      ],
    );
  }
}
