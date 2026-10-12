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
import '../l10n/l.dart';

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
                Tab(icon: GameIcon('tab_ship', size: 30), text: tr.u_tabShip, iconMargin: const EdgeInsets.only(bottom: 2)),
                Tab(icon: GameIcon('tab_station', size: 30), text: tr.u_tabStation, iconMargin: const EdgeInsets.only(bottom: 2)),
                Tab(icon: GameIcon('tab_crew', size: 30), text: tr.u_tabCrew, iconMargin: const EdgeInsets.only(bottom: 2)),
                Tab(icon: GameIcon('tab_mission', size: 30), text: tr.u_tabMission, iconMargin: const EdgeInsets.only(bottom: 2)),
                Tab(icon: GameIcon('tab_market', size: 30), text: tr.u_tabMarket, iconMargin: const EdgeInsets.only(bottom: 2)),
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
                Text(keepAll(desc), style: dimStyle),
              ],
            ),
          ),
          // 버튼이 길면(번역에 따라) 글자 대신 버튼이 줄어든다
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: FittedBox(fit: BoxFit.scaleDown, child: trailing),
          ),
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
      UpgradeKind.weapon => tr.u_upWeapon(w.playerDamage.toInt()),
      UpgradeKind.hull => tr.u_upHull(w.playerMaxHp.toInt()),
      UpgradeKind.engine => tr.u_upEngine(w.playerSpeed.toInt()),
      UpgradeKind.missile => w.level(k) == 0
          ? keyHint(tr.u_upMissileIntro)
          : tr.u_upMissile(2 + w.level(k) ~/ 2, w.missileCooldownMax.toStringAsFixed(1)),
      UpgradeKind.shield => w.level(k) == 0
          ? keyHint(tr.u_upShieldIntro)
          : tr.u_upShield((2.5 + w.level(k) * 0.5).toStringAsFixed(1), w.shieldCooldownMax.toStringAsFixed(1)),
      UpgradeKind.drone => w.level(k) == 0
          ? tr.u_upDroneIntro
          : tr.u_upDrone(w.droneDamage.toInt(), w.droneInterval.toStringAsFixed(2)),
      UpgradeKind.magnet => tr.u_upMagnet(w.magnetRadius.toInt(), (w.magnetPull / 1400).toStringAsFixed(1)),
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
                        ? tr.u_equip
                        : '',
                    world.canAfford(world.upgradeCost(k)),
                    () => act(() => world.upgradeShip(k)),
                    cost: world.upgradeCost(k),
                  ),
            leading: GameIcon(k.iconAsset, size: 44),
          ),
        const Divider(color: Colors.white24, height: 28),
        Row(
          children: [
            Expanded(child: Text(tr.u_hangarSection, style: sectionStyle)),
            actionBtn(tr.u_viewLarge, true, () => _openHangar(context, null), icon: 'tab_ship'),
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
      if (t.hpMul != 1) '${tr.u_hp} x${t.hpMul}',
      if (t.speedMul != 1) '${tr.u_speed} x${t.speedMul}',
      if (t.dmgMul != 1) '${tr.u_attack} x${t.dmgMul}',
      if (t.fireMul != 1) '${tr.u_fireRate} x${(1 / t.fireMul).toStringAsFixed(2)}',
      if (t.oreMul != 1) '${tr.u_ore} x${t.oreMul}',
      if (t.crit > 0) '${tr.u_crit} ${(t.crit * 100).round()}%',
    ].join(' · ');
    final Widget trailing;
    if (current) {
      trailing = Text(tr.u_boarded, style: const TextStyle(color: Color(0xFF7CFFB2)));
    } else if (unlocked) {
      trailing = actionBtn(tr.u_board, true, () => act(() => world.switchShip(t)));
    } else {
      trailing = actionBtn('${t.gemPrice}', p.gems >= t.gemPrice, () async {
        if (await payGems(t.gemPrice, 'ship')) act(() => world.buyShip(t));
      },
          icon: 'gem', iconSize: IconSz.inline, color: const Color(0xFFAD1457));
    }
    final ability = t.ability.isEmpty ? '' : '\n✨ ${t.ability}';
    final unlockHint = unlocked ? '' : (t.premium ? '\n${tr.u_gemsOnly}' : '\n${tr.u_unlockOrGems(t.unlockDesc)}');
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
        Text(tr.u_durability(s.hp.toInt(), s.maxHp.toInt()), style: dimStyle),
        const SizedBox(height: 6),
        _row(
          '${tr.u_habitat}  Lv.${s.habitatLevel}',
          tr.u_habitatDesc(world.stationCreditRate(s).toStringAsFixed(1), s.maxHp.toInt()),
          s.habitatLevel >= Station.maxLevel
              ? actionBtn('MAX', false, null)
              : actionBtn('', world.canAfford(world.habitatCost(s)), () => act(() => world.upgradeHabitat(s)),
                  cost: world.habitatCost(s)),
          leading: const GameIcon('st_habitat', size: 44),
        ),
        _row(
          '${tr.u_turret}  Lv.${s.turretLevel}',
          s.turretLevel == 0
              ? tr.u_turretIntro
              : tr.u_turretDesc((s.turretDamage * world.sectorMul).toInt(), s.turretRange.toInt()),
          s.turretLevel >= Station.maxLevel
              ? actionBtn('MAX', false, null)
              : actionBtn('', world.canAfford(world.turretCost(s)), () => act(() => world.upgradeTurret(s)),
                  cost: world.turretCost(s)),
          leading: const GameIcon('st_turret', size: 44),
        ),
        if (s.isHome)
          _row(
            '${tr.u_baseUpgrade}  Lv.${s.baseLevel}',
            tr.u_baseDesc(s.laserDamage.toInt(), s.laserRange.toInt(), s.maxHp.toInt()) +
                (s.disabled ? '\n${tr.u_disabledSec(s.disabledTime.ceil())}' : ''),
            s.baseLevel >= Station.maxBaseLevel
                ? actionBtn('MAX', false, null)
                : actionBtn('', world.canAfford(world.baseUpgradeCost(s)), () => act(() => world.upgradeBase(s)),
                    cost: world.baseUpgradeCost(s)),
            leading: const GameIcon('dome', size: 44),
          ),
        const Divider(color: Colors.white24),
        Text(tr.u_sectorStatus(world.sectorName), style: sectionStyle),
        const SizedBox(height: 4),
        Text(
          tr.u_sectorStats(world.colonyCount, world.planets.length, world.stations.length,
              world.sectorMul.toStringAsFixed(1), world.otherSectorCredits.toStringAsFixed(1)),
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

  Future<void> _recruit(BuildContext context, CrewMember? Function() f, {int gems = 0}) async {
    if (gems > 0 && !await payGems(gems, gems >= GameWorld.legendaryGemCost ? 'legendary' : 'recruit')) return;
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
        scrollable: true,
        backgroundColor: kPanelColor,
        title: Text(
            c.legendary
                ? tr.u_legendaryGet
                : (c.rarity == 3 ? tr.u_rareGet : tr.u_newCrew),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChibiPortrait(style: ChibiStyle.forCrew(c), size: 140),
            Text(c.stars, style: Ts.title.copyWith(color: Color(0xFFFFD54F))),
            Text('${c.role.icon} ${c.role.label} ${c.displayName}', style: titleStyle),
            Text(c.effectText, textAlign: TextAlign.center, style: bodyStyle),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr.u_great))],
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
        Text(tr.u_crewHeader(w.roster.length, w.rosterCap, w.assignedCount, w.crewSlots),
            style: sectionStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            actionBtn(tr.u_recruit(w.recruitCost), !full && w.credits >= w.recruitCost,
                () => _recruit(context, w.recruitWithCredits)),
            actionBtn(tr.u_recruitPremium(GameWorld.recruitGemCost),
                !full && w.profile.gems >= GameWorld.recruitGemCost,
                () => _recruit(context, w.recruitWithGems, gems: GameWorld.recruitGemCost),
                color: const Color(0xFFAD1457)),
            actionBtn(tr.u_recruitLegendary(GameWorld.legendaryGemCost),
                !full && p.gems >= GameWorld.legendaryGemCost,
                () => _recruit(context, w.recruitLegendary, gems: GameWorld.legendaryGemCost),
                color: const Color(0xFFFF6F00)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          tr.u_recruitOdds(
              CrewMember.oddsText(CrewMember.creditOdds), CrewMember.oddsText(CrewMember.gemOdds)),
          style: dimStyle,
        ),
        // 직책은 모든 모집에서 직책 목록 중 균등 추첨 (crew.dart CrewMember.random)
        Text(tr.u_recruitRoleOdds(CrewRole.values.length, _pct(100 / CrewRole.values.length)), style: dimStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            actionBtn(
                slotPrice == null ? tr.u_slotMax(w.crewSlots) : tr.u_slotBuy(slotPrice),
                slotPrice != null && p.gems >= slotPrice,
                () async {
                  if (slotPrice != null && await payGems(slotPrice, 'crew_slot')) act(p.buyCrewSlot);
                },
                color: const Color(0xFFAD1457)),
            actionBtn(
                p.rosterPacks >= Profile.maxRosterPacks
                    ? tr.u_rosterMax(w.rosterCap)
                    : tr.u_rosterBuy(Profile.rosterPackSize, Profile.rosterPackPrice),
                p.rosterPacks < Profile.maxRosterPacks && p.gems >= Profile.rosterPackPrice,
                () async {
                  if (await payGems(Profile.rosterPackPrice, 'roster')) act(p.buyRosterPack);
                },
                color: const Color(0xFFAD1457)),
          ],
        ),
        const Divider(color: Colors.white24),
        if (w.roster.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(tr.u_noCrew,
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
                      Text('${c.role.icon} ${c.role.label} · ${c.effectText}',
                          style: dimStyle),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    actionBtn(c.assigned ? tr.u_unassign : tr.u_assign,
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
                          tooltip: tr.u_dismiss,
                          icon: const Icon(Icons.logout, color: Colors.white38, size: 18),
                          onPressed: () async {
                            if (await confirmDialog(
                                context, tr.u_dismissCrewTitle, tr.u_dismissCrewBody(eul(c.name)))) {
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
        MissionType.deliver => tr.u_missionDeliverHint,
        MissionType.bounty => tr.u_missionBountyHint,
      };

  String _reward(Mission m) =>
      tr.u_reward('💰${m.rewardCredits}${m.rewardGems > 0 ? ' ⭐${m.rewardGems}' : ''}');

  @override
  Widget build(BuildContext context) {
    final w = world;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Text(tr.u_activeMissions(w.activeMissions.length), style: sectionStyle),
        if (w.activeMissions.isEmpty) Text(tr.u_noActiveMissions, style: dimStyle),
        for (final m in w.activeMissions)
          _row('${m.icon} ${m.title(w.planets)}', '${_progress(m)} · ${_reward(m)}',
              TextButton(
                onPressed: () => act(() {
                  w.abandonMission(m);
                  return true;
                }),
                child: Text(tr.u_abandon, style: const TextStyle(color: Colors.white54)),
              )),
        const Divider(color: Colors.white24),
        Text(tr.u_missionBoard(w.offerTimer.ceil()), style: sectionStyle),
        for (final m in w.missionOffers)
          _row('${m.icon} ${m.title(w.planets)}', _reward(m),
              actionBtn(tr.u_accept, w.activeMissions.length < 3, () => act(() => w.acceptMission(m)))),
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
        ? tr.u_priceHigh
        : (price < base * 0.85 ? tr.u_priceLow : tr.u_priceNormal);
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Text(tr.u_orePrice, style: sectionStyle),
        const SizedBox(height: 4),
        Text('1💎 = 💰${price.toStringAsFixed(2)}   $trend', style: bodyStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            actionBtn(tr.u_sell100, w.ore >= 1, () => act(() => w.sellOre(100))),
            actionBtn(tr.u_sellHalf, w.ore >= 2, () => act(() => w.sellOre(w.ore ~/ 2))),
            actionBtn(tr.u_sellAll, w.ore >= 1, () => act(() => w.sellOre(w.ore.floor()))),
          ],
        ),
        const SizedBox(height: 6),
        Text(tr.u_marketTip, style: dimStyle),
        const Divider(color: Colors.white24),
        Text(tr.u_gemExchange, style: sectionStyle),
        _row(tr.u_creditPack, '⭐${GameWorld.creditPackGems} → 💰${w.creditPackAmount}',
            actionBtn(tr.u_exchange, w.profile.gems >= GameWorld.creditPackGems,
                () async {
                  if (await payGems(GameWorld.creditPackGems, 'credit_pack')) act(w.buyCreditsWithGems);
                },
                color: const Color(0xFFAD1457))),
        const SizedBox(height: 8),
        actionBtn(tr.u_openShop, true, onOpenShop, color: const Color(0xFFAD1457)),
      ],
    );
  }
}

/// 확률 표기: 16.666… → "16.7%", 20 → "20%"
String _pct(double v) {
  final s = v.toStringAsFixed(1);
  return '${s.endsWith('.0') ? s.substring(0, s.length - 2) : s}%';
}
