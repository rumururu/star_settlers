import '../game/josa.dart';
import 'package:flutter/material.dart';

import '../game/cosmetics.dart';
import '../game/crew.dart';
import '../game/models.dart';
import '../game/profile.dart';
import '../game/save.dart';
import '../game/ships.dart';
import '../game/world.dart';
import '../services/app_state.dart';
import '../services/monetization.dart';
import 'chibi.dart';
import 'common.dart';
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
    final ok = await AppState.money.buy(id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) toast(context, '구매 완료! 감사합니다 💜');
  }

  Future<void> _freeGems() async {
    final now = DateTime.now();
    if (AppState.profile.adGemsLeft(now) <= 0) return;
    final ok = await AppState.watchAd();
    if (!mounted) return;
    if (!ok) {
      toast(context, '광고를 불러오는 중이에요. 잠시 후 다시 시도해 주세요.');
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
      toast(context, '젬이 부족해요');
      return;
    }
    if (!await confirmDialog(context, '구매 확인', '${eul("⭐$price")} 사용할까요?')) return;
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
          title: const Text('⭐ 상점'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('⭐ ${p.gems}',
                    style: Ts.heading.copyWith(color: Color(0xFFFF80AB))),
              ),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: '젬 충전'),
              Tab(text: '패키지'),
              Tab(text: '프리미엄 함선'),
              Tab(text: '함선 스킨'),
              Tab(text: '선장 의상'),
              Tab(text: '무료 젬'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(children: [_gems(), _packs(), _premiumShips(), _skins(), _outfits(), _free()]),
            if (AppState.money.isTestMode)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: const Color(0xCC4A148C),
                  padding: const EdgeInsets.all(6),
                  child: const Text('🧪 테스트 모드: 실제 결제/광고가 일어나지 않아요',
                      textAlign: TextAlign.center, style: dimStyle),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(ProductDef d, {Widget? leading, bool owned = false}) => Card(
        color: const Color(0xFF1E1A4A),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: leading,
          title: Text(d.title, style: titleStyle),
          subtitle: Text(d.desc, style: dimStyle),
          trailing: owned
              ? const Text('보유 중', style: TextStyle(color: Color(0xFF7CFFB2)))
              : actionBtn(AppState.money.priceOf(d.id), !_busy, () => _buy(d.id),
                  color: const Color(0xFFAD1457)),
        ),
      );

  Widget _gems() => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final d in productDefs.where((d) => d.id.startsWith('gems_')))
            _productCard(d,
                leading: Text(
                    d.id == 'gems_100' ? '⭐' : (d.id == 'gems_550' ? '💰' : '🎁'),
                    style: Ts.glyph)),
          const SizedBox(height: 8),
          const Text('젬은 꾸미기, 고급 영입, 즉시 부활, 크레딧 교환에 쓸 수 있어요.\n'
              '게임 플레이(업적·출석·두목·보급 캡슐)로도 모을 수 있어요.', style: dimStyle),
        ],
      );

  Widget _packs() {
    final starter = productDefs.firstWhere((d) => d.id == 'starter_pack');
    final premium = productDefs.firstWhere((d) => d.id == 'premium_pass');
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _productCard(starter,
            owned: _p.starterBought,
            leading: _skinPreview(skinById('galaxy'))),
        _productCard(premium,
            owned: _p.premium,
            leading: _skinPreview(skinById('gold'))),
        const SizedBox(height: 12),
        const Text('👩‍🚀 승무원 (젬)', style: sectionStyle),
        const SizedBox(height: 6),
        ..._crewItems(),
        const SizedBox(height: 12),
        actionBtn('구매 복원', true, () async {
          await AppState.money.restore();
          if (mounted) toast(context, '구매 내역을 확인했어요');
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
      toast(context, '젬이 부족해요');
      return;
    }
    if (!await confirmDialog(context, '구매 확인', '${t.name}에 ${eul("⭐${t.gemPrice}")} 사용할까요?')) return;
    final w = AppState.world;
    final ok = w != null ? w.buyShip(t) : p.buyShip(t);
    if (!ok) return;
    if (w == null) {
      p.shipType = t.id;
      AppState.play(Sfx.gem);
    }
    await SaveService.saveProfile(p);
    if (mounted) {
      toast(context, '${t.name} 획득! 바로 탑승했어요');
      setState(() {});
    }
  }

  Widget _premiumShips() {
    final p = AppState.profile;
    return ListView(
      padding: const EdgeInsets.all(Space.m),
      children: [
        const Text('🛸 프리미엄 함선', style: sectionStyle),
        const SizedBox(height: Space.xs),
        const Text('젬으로만 얻을 수 있는 특별한 전투기예요. 고유 능력이 있어요.', style: dimStyle),
        const SizedBox(height: Space.s),
        Center(
          child: actionBtn('한 장씩 크게 보기', true, () => _openPremium(null), icon: 'tab_ship', primary: true),
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
                    Text('탑승 중', style: Ts.label.copyWith(color: const Color(0xFF7CFFB2)))
                  else if (p.ownedShips.contains(t.id))
                    Text('보유 중', style: Ts.label.copyWith(color: const Color(0xFF7CFFB2)))
                  else
                    actionBtn('⭐${t.gemPrice}', p.gems >= t.gemPrice, () => _buyShip(t),
                        color: const Color(0xFFAD1457)),
                ],
              ),
            ),
            ),
          ),
        const SizedBox(height: Space.s),
        const Text('격납고(정거장 → 함선 탭)에서도 구매·교체할 수 있어요.', style: dimStyle),
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
        title: '전설 승무원 확정 모집',
        desc: w == null
            ? '★4 전설 승무원 1명 (보너스 20%~, 칭호·금빛 오라)\n게임을 시작한 뒤 구매할 수 있어요'
            : '★4 전설 승무원 1명 (보너스 20%~, 칭호·금빛 오라)\n승무원 ${w.roster.length}/${w.rosterCap}',
        price: GameWorld.legendaryGemCost,
        enabled: w != null && w.roster.length < w.rosterCap,
        onBuy: () => _buyGemItem(GameWorld.legendaryGemCost, () {
          final c = w?.recruitLegendary();
          if (c != null && w != null) {
            SaveService.save(w);
            toast(context, '${c.stars} ${c.displayName} 합류!');
          }
          return c != null;
        }),
      ),
      _gemItemCard(
        icon: '🪑',
        title: '배치 슬롯 +1',
        desc: '함선에 동시에 배치할 수 있는 승무원 수 · 현재 $slots',
        price: slotPrice,
        enabled: slotPrice != null,
        onBuy: () => _buyGemItem(slotPrice ?? 0, p.buyCrewSlot),
      ),
      _gemItemCard(
        icon: '🛏',
        title: '승무원 정원 +${Profile.rosterPackSize}',
        desc: '보유할 수 있는 승무원 수 · 현재 $cap (최대 ${GameWorld.maxRoster + Profile.maxRosterPacks * Profile.rosterPackSize})',
        price: rosterMax ? null : Profile.rosterPackPrice,
        enabled: !rosterMax,
        onBuy: () => _buyGemItem(Profile.rosterPackPrice, p.buyRosterPack),
      ),
      Text('고급 영입 확률: ${CrewMember.oddsText(CrewMember.gemOdds)} · 전설 확정 모집: ★4 100%',
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
          subtitle: Text(desc, style: dimStyle),
          trailing: price == null
              ? const Text('MAX', style: TextStyle(color: Color(0xFF7CFFB2)))
              : actionBtn('⭐$price', enabled && _p.gems >= price, onBuy,
                  color: const Color(0xFFAD1457)),
        ),
      );

  Future<void> _buyGemItem(int price, bool Function() buy) async {
    if (!await confirmDialog(context, '구매 확인', '${eul("⭐$price")} 사용할까요?')) return;
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
      padding: const EdgeInsets.all(12),
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
      padding: const EdgeInsets.all(12),
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
      button = const Text('장착 중', style: TextStyle(color: Color(0xFF7CFFB2)));
    } else if (owned) {
      button = actionBtn('장착', true, onEquip);
    } else if (exclusive != null) {
      button = Text(exclusive == 'premium_pass' ? '사령관 패스 전용' : '스타터 팩 전용',
          style: dimStyle, textAlign: TextAlign.center);
    } else {
      button = actionBtn('⭐$price', true, onBuy, color: const Color(0xFFAD1457));
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
      padding: const EdgeInsets.all(16),
      children: [
        const Text('📺 광고 보고 무료 젬', style: sectionStyle),
        const SizedBox(height: 6),
        Text('하루 ${3}회, 1회에 ⭐5 · 오늘 $left회 남음', style: bodyStyle),
        const SizedBox(height: 8),
        actionBtn(p.premium ? '⭐5 받기 (사령관 패스: 광고 없음)' : '광고 보고 ⭐5 받기', left > 0, _freeGems,
            color: const Color(0xFF00897B)),
        const Divider(color: Colors.white24, height: 32),
        const Text('📅 출석 보상', style: sectionStyle),
        const SizedBox(height: 6),
        Text('연속 출석 ${p.loginStreak}일째', style: bodyStyle),
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
                  Text('${i + 1}일', style: dimStyle),
                  Text('⭐${[5, 5, 10, 10, 15, 20, 50][i]}', style: bodyStyle),
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
