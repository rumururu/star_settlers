import 'package:flutter/material.dart';

import '../game/cosmetics.dart';
import '../game/crew.dart';
import '../game/models.dart';
import '../game/profile.dart';
import '../game/save.dart';
import '../game/ships.dart';
import '../game/world.dart';
import '../l10n/l.dart';
import '../services/app_state.dart';
import '../services/monetization.dart';
import 'chibi.dart';
import 'common.dart';
import 'game_icons.dart';
import 'hangar_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _busy = false;

  Profile get _p => AppState.profile;

  Future<void> _buy(String id) async {
    if (_busy) return;
    setState(() => _busy = true);
    final r = await AppState.money.buy(id);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case PurchaseResult.success:
        toast(context, tr.m_buyThanks);
      case PurchaseResult.failed:
        toast(context, tr.m_purchaseFailed);
      case PurchaseResult.cancelled:
        break;
    }
  }

  Future<void> _freeGems() async {
    final now = DateTime.now();
    if (AppState.profile.adGemsLeft(now) <= 0) return;
    final ok = await AppState.watchAd();
    if (!mounted) return;
    if (!ok) {
      final msg = adFailMessage(AppState.money.lastAdResult);
      if (msg != null) toast(context, msg);
      return;
    }
    AppState.profile.claimAdGems(now);
    AppState.play(Sfx.gem);
    await SaveService.saveProfile(AppState.profile);
    if (mounted) setState(() {});
  }

  void _buyCosmetic(int price, VoidCallback give) async {
    final p = AppState.profile;
    if (p.gems < price) {
      toast(context, tr.m_notEnoughGems);
      return;
    }
    if (!await confirmDialog(context, tr.m_buyConfirmTitle, tr.m_spendGemsConfirm(eul('⭐$price')))) return;
    p.spendGems(price);
    give();
    p.addStat('cosmetics');
    AppState.play(Sfx.gem);
    await SaveService.saveProfile(p);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = AppState.profile;
    return DefaultTabController(
      length: 6,
      initialIndex: widget.initialTab,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0B26),
        appBar: AppBar(
          backgroundColor: const Color(0xFF151236),
          title: gemText(tr.m_shopTitle, iconSize: 26),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: iconValue('gem', '${p.gems}',
                    size: IconSz.inline, style: Ts.heading.copyWith(color: const Color(0xFFFF80AB))),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: tr.m_tabGems),
              Tab(text: tr.m_tabPacks),
              Tab(text: tr.m_tabPremiumShips),
              Tab(text: tr.m_tabSkins),
              Tab(text: tr.m_tabOutfits),
              Tab(text: tr.m_tabFree),
            ],
          ),
        ),
        // 테스트 모드 띠는 목록 위에 겹치지 않게 아래에 따로 둔다 (목록 맨 아래 "구매 복원" 버튼을 가리지 않게).
        // iPad 등 넓은 화면에서는 내용 폭을 제한한다.
        body: Column(
          children: [
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: AppState.money.isTestMode,
                child: contentWidth(TabBarView(
                    children: [_gems(), _packs(), _premiumShips(), _skins(), _outfits(), _free()])),
              ),
            ),
            if (AppState.money.isTestMode)
              Container(
                width: double.infinity,
                color: const Color(0xCC4A148C),
                padding: const EdgeInsets.all(6),
                child: SafeArea(
                  top: false,
                  child: Text(tr.m_testMode, textAlign: TextAlign.center, style: dimStyle),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 목록 여백 + 아래쪽 안전 영역(iPhone 홈 인디케이터)
  EdgeInsets _pad(double v) => EdgeInsets.fromLTRB(v, v, v, v + MediaQuery.paddingOf(context).bottom);

  Widget _productCard(ProductDef d, {Widget? leading, bool owned = false}) => Card(
        color: const Color(0xFF1E1A4A),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: leading,
          title: Text(d.title, style: titleStyle),
          subtitle: gemText(keepAll(d.desc), style: dimStyle),
          trailing: owned
              ? Text(tr.m_owned, style: const TextStyle(color: Color(0xFF7CFFB2)))
              : actionBtn(AppState.money.priceOf(d.id), !_busy, () => _buy(d.id),
                  color: const Color(0xFFAD1457)),
        ),
      );

  Widget _gems() => ListView(
        padding: _pad(12),
        children: [
          for (final d in productDefs.where((d) => d.id.startsWith('gems_')))
            _productCard(d,
                leading: d.id == 'gems_100'
                    ? const GameIcon('gem', size: 32)
                    : Text(d.id == 'gems_550' ? '💰' : '🎁', style: Ts.glyph)),
          const SizedBox(height: 8),
          Text(tr.m_gemsInfo, style: dimStyle),
        ],
      );

  Widget _packs() {
    final starter = productDefs.firstWhere((d) => d.id == 'starter_pack');
    final premium = productDefs.firstWhere((d) => d.id == 'premium_pass');
    return ListView(
      padding: _pad(12),
      children: [
        _productCard(starter,
            owned: _p.starterBought,
            leading: _skinPreview(skinById('galaxy'))),
        _productCard(premium,
            owned: _p.premium,
            leading: _skinPreview(skinById('gold'))),
        const SizedBox(height: 12),
        Text(tr.m_crewSection, style: sectionStyle),
        const SizedBox(height: 6),
        ..._crewItems(),
        const SizedBox(height: 12),
        actionBtn(tr.m_restorePurchases, true, () async {
          await AppState.money.restore();
          if (!mounted) return;
          setState(() {}); // 복원된 패키지를 바로 "보유 중"으로
          toast(context, tr.m_restoreDone);
        }, color: const Color(0xFF455A64)),
      ],
    );
  }

  Future<void> _openPremium(String? id) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => HangarScreen(initialId: id, premiumOnly: true)));
    if (mounted) setState(() {});
  }

  /// 프리미엄 함선 구매: 게임 중이면 월드의 구매 흐름(구매 후 바로 탑승)을 그대로 쓴다
  Future<void> _buyShip(ShipType t) async {
    final p = AppState.profile;
    if (p.gems < t.gemPrice) {
      toast(context, tr.m_notEnoughGems);
      return;
    }
    if (!await confirmDialog(context, tr.m_buyConfirmTitle, tr.m_buyShipConfirm(t.name, eul('⭐${t.gemPrice}')))) return;
    final w = AppState.world;
    final ok = w != null ? w.buyShip(t) : p.buyShip(t);
    if (!ok) return;
    if (w == null) {
      p.shipType = t.id;
      AppState.play(Sfx.gem);
    }
    await SaveService.saveProfile(p);
    if (mounted) {
      toast(context, tr.m_shipAcquired(t.name));
      setState(() {});
    }
  }

  Widget _premiumShips() {
    final p = AppState.profile;
    return ListView(
      padding: _pad(Space.m),
      children: [
        Text(tr.m_premiumSection, style: sectionStyle),
        const SizedBox(height: Space.xs),
        Text(tr.m_premiumDesc, style: dimStyle),
        const SizedBox(height: Space.s),
        Center(
          child: actionBtn(tr.m_viewLarge, true, () => _openPremium(null), icon: 'tab_ship', primary: true),
        ),
        const SizedBox(height: Space.s),
        for (final t in shipTypes.where((t) => t.premium))
          Card(
            color: const Color(0xFF1E1A4A),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openPremium(t.id),
              child: Padding(
              padding: const EdgeInsets.all(Space.m),
              child: Row(
                children: [
                  Image.asset('assets/sprites/ship_${t.id}_${p.skin}.png',
                      width: IconSz.hero,
                      height: IconSz.hero,
                      errorBuilder: (_, _, _) => _skinPreview(skinById(p.skin), size: IconSz.hero)),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: Space.s,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [Text(t.name, style: titleStyle), const PremiumBadge()],
                        ),
                        Text(t.desc, style: dimStyle),
                        Text('✨ ${t.ability}', style: bodyStyle),
                      ],
                    ),
                  ),
                  const SizedBox(width: Space.s),
                  if (p.shipType == t.id)
                    Text(tr.m_boarded, style: Ts.label.copyWith(color: const Color(0xFF7CFFB2)))
                  else if (p.ownedShips.contains(t.id))
                    Text(tr.m_owned, style: Ts.label.copyWith(color: const Color(0xFF7CFFB2)))
                  else
                    actionBtn('${t.gemPrice}', p.gems >= t.gemPrice, () => _buyShip(t),
                        icon: 'gem', iconSize: IconSz.inline, color: const Color(0xFFAD1457)),
                ],
              ),
            ),
            ),
          ),
        const SizedBox(height: Space.s),
        Text(tr.m_premiumHangarHint, style: dimStyle),
      ],
    );
  }

  /// 젬으로 사는 승무원 아이템 (전설 확정 모집, 배치 슬롯, 정원 확장)
  List<Widget> _crewItems() {
    final p = _p;
    final w = AppState.world;
    final slotPrice = p.nextCrewSlotPrice;
    final slots = 3 + p.extraCrewSlots;
    final cap = GameWorld.maxRoster + p.rosterPacks * Profile.rosterPackSize;
    final rosterMax = p.rosterPacks >= Profile.maxRosterPacks;
    return [
      _gemItemCard(
        icon: '🌟',
        title: tr.m_legendTitle,
        desc: w == null
            ? tr.m_legendDescNoGame
            : tr.m_legendDesc(w.roster.length, w.rosterCap),
        price: GameWorld.legendaryGemCost,
        enabled: w != null && w.roster.length < w.rosterCap,
        onBuy: () => _buyGemItem(GameWorld.legendaryGemCost, () {
          final c = w?.recruitLegendary();
          if (c != null && w != null) {
            SaveService.save(w);
            toast(context, tr.m_crewJoined(c.stars, c.displayName));
          }
          return c != null;
        }),
      ),
      _gemItemCard(
        icon: '🪑',
        title: tr.m_slotTitle,
        desc: tr.m_slotDesc(slots),
        price: slotPrice,
        enabled: slotPrice != null,
        onBuy: () => _buyGemItem(slotPrice ?? 0, p.buyCrewSlot),
      ),
      _gemItemCard(
        icon: '🛏',
        title: tr.m_rosterTitle(Profile.rosterPackSize),
        desc: tr.m_rosterDesc(cap, GameWorld.maxRoster + Profile.maxRosterPacks * Profile.rosterPackSize),
        price: rosterMax ? null : Profile.rosterPackPrice,
        enabled: !rosterMax,
        onBuy: () => _buyGemItem(Profile.rosterPackPrice, p.buyRosterPack),
      ),
      Text(tr.m_crewOdds(CrewMember.oddsText(CrewMember.gemOdds)),
          style: dimStyle),
    ];
  }

  Widget _gemItemCard({
    required String icon,
    required String title,
    required String desc,
    required int? price,
    required bool enabled,
    required VoidCallback onBuy,
  }) =>
      Card(
        color: const Color(0xFF1E1A4A),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Text(icon, style: Ts.glyph),
          title: Text(title, style: titleStyle),
          subtitle: gemText(keepAll(desc), style: dimStyle),
          trailing: price == null
              ? const Text('MAX', style: TextStyle(color: Color(0xFF7CFFB2)))
              : actionBtn('$price', enabled && _p.gems >= price, onBuy,
                  icon: 'gem', iconSize: IconSz.inline, color: const Color(0xFFAD1457)),
        ),
      );

  Future<void> _buyGemItem(int price, bool Function() buy) async {
    if (!await confirmDialog(context, tr.m_buyConfirmTitle, tr.m_spendGemsConfirm(eul('⭐$price')))) return;
    if (!mounted || !buy()) return;
    AppState.play(Sfx.gem);
    await SaveService.saveProfile(_p);
    if (mounted) setState(() {});
  }

  /// 지금 탄 함선에 이 스킨을 입힌 그림 (없으면 예전 도형 그림)
  Widget _skinPreview(ShipSkin s, {double size = 48}) => SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          'assets/sprites/ship_${AppState.profile.shipType}_${s.id}.png',
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) => CustomPaint(painter: _ShipPreviewPainter(s)),
        ),
      );

  Widget _skins() {
    final p = AppState.profile;
    return GridView.count(
      padding: _pad(12),
      crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
      childAspectRatio: 0.85,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (final s in shipSkins)
          _cosmeticCard(
            preview: _skinPreview(s, size: 80),
            name: s.name,
            owned: p.ownedSkins.contains(s.id),
            equipped: p.skin == s.id,
            price: s.price,
            exclusive: s.exclusive,
            onBuy: () => _buyCosmetic(s.price, () => p.ownedSkins.add(s.id)),
            onEquip: () async {
              p.skin = s.id;
              await SaveService.saveProfile(p);
              setState(() {});
            },
          ),
      ],
    );
  }

  Widget _outfits() {
    final p = AppState.profile;
    return GridView.count(
      padding: _pad(12),
      crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
      childAspectRatio: 0.85,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (final o in captainOutfits)
          _cosmeticCard(
            preview: ChibiPortrait(style: ChibiStyle.captainIn(o), size: 90),
            name: o.name,
            owned: p.ownedOutfits.contains(o.id),
            equipped: p.outfit == o.id,
            price: o.price,
            onBuy: () => _buyCosmetic(o.price, () => p.ownedOutfits.add(o.id)),
            onEquip: () async {
              p.outfit = o.id;
              await SaveService.saveProfile(p);
              setState(() {});
            },
          ),
      ],
    );
  }

  Widget _cosmeticCard({
    required Widget preview,
    required String name,
    required bool owned,
    required bool equipped,
    required int price,
    String? exclusive,
    required VoidCallback onBuy,
    required VoidCallback onEquip,
  }) {
    Widget button;
    if (equipped) {
      button = Text(tr.m_equipped, style: const TextStyle(color: Color(0xFF7CFFB2)));
    } else if (owned) {
      button = actionBtn(tr.m_equip, true, onEquip);
    } else if (exclusive != null) {
      button = Text(exclusive == 'premium_pass' ? tr.m_passOnly : tr.m_starterOnly,
          style: dimStyle, textAlign: TextAlign.center);
    } else {
      button = actionBtn('$price', true, onBuy,
          icon: 'gem', iconSize: IconSz.inline, color: const Color(0xFFAD1457));
    }
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A4A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: equipped ? const Color(0xFF7CFFB2) : Colors.white12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          preview,
          Text(name, style: bodyStyle, textAlign: TextAlign.center),
          button,
        ],
      ),
    );
  }

  Widget _free() {
    final p = AppState.profile;
    final left = p.adGemsLeft(DateTime.now());
    return ListView(
      padding: _pad(Space.l),
      children: [
        Text(tr.m_adSection, style: sectionStyle),
        const SizedBox(height: 6),
        Text(tr.m_adInfo(3, left), style: bodyStyle),
        const SizedBox(height: 8),
        actionBtn(p.premium ? tr.m_adClaimPremium : tr.m_adWatch, left > 0, _freeGems,
            color: const Color(0xFF00897B)),
        const Divider(color: Colors.white24, height: 32),
        Text(tr.m_loginTitle, style: sectionStyle),
        const SizedBox(height: 6),
        Text(tr.m_loginStreak(p.loginStreak), style: bodyStyle),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < 7; i++)
              Container(
                width: 64,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: i < ((p.loginStreak - 1) % 7 + 1) && p.loginStreak > 0
                      ? const Color(0xFF4527A0)
                      : const Color(0xFF1E1A4A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: [
                  Text(tr.m_dayN(i + 1), style: dimStyle),
                  iconValue('gem', '${[5, 5, 10, 10, 15, 20, 50][i]}', size: IconSz.inline, style: bodyStyle),
                ]),
              ),
          ],
        ),
      ],
    );
  }
}

class _ShipPreviewPainter extends CustomPainter {
  _ShipPreviewPainter(this.skin);
  final ShipSkin skin;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final s = size.shortestSide / 60;
    canvas.scale(s);
    final wing = Paint()
      ..shader = skin.rainbow
          ? const SweepGradient(colors: [
              Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red
            ]).createShader(const Rect.fromLTWH(-26, -26, 52, 52))
          : null
      ..color = skin.wing;
    canvas.drawPath(
        Path()
          ..moveTo(-8, -4)
          ..lineTo(-26, 16)
          ..lineTo(-8, 14)
          ..close(),
        wing);
    canvas.drawPath(
        Path()
          ..moveTo(8, -4)
          ..lineTo(26, 16)
          ..lineTo(8, 14)
          ..close(),
        wing);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-11, -26, 22, 46), const Radius.circular(11)),
        Paint()..color = skin.hull);
    canvas.drawRect(const Rect.fromLTWH(-11, 8, 22, 4), Paint()..color = skin.stripe);
    canvas.drawCircle(const Offset(0, -8), 9, Paint()..color = const Color(0xFF263238));
    canvas.drawCircle(const Offset(0, -8), 9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xAAB3E5FC));
  }

  @override
  bool shouldRepaint(_ShipPreviewPainter old) => old.skin != skin;
}
