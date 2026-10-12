import 'dart:math';

import 'package:flutter/material.dart';

import '../game/models.dart';
import '../game/save.dart';
import '../game/ships.dart';
import '../l10n/l.dart';
import '../services/app_state.dart';
import 'common.dart';
import 'game_icons.dart';

/// 함선 크게 보기: 한 장씩 넘겨 보며 탑승·구매한다.
/// 게임 중이면 월드의 흐름(구매 후 바로 탑승, 체력 비율 유지)을 쓰고, 타이틀에서는 프로필만 바꾼다.
class HangarScreen extends StatefulWidget {
  const HangarScreen({super.key, this.initialId, this.premiumOnly = false});

  final String? initialId;
  final bool premiumOnly;

  @override
  State<HangarScreen> createState() => _HangarScreenState();
}

class _HangarScreenState extends State<HangarScreen> with SingleTickerProviderStateMixin {
  late final List<ShipType> _ships =
      widget.premiumOnly ? shipTypes.where((t) => t.premium).toList() : shipTypes;
  late final _page = PageController(
    viewportFraction: 0.88,
    initialPage: max(0, _ships.indexWhere((t) => t.id == widget.initialId)),
  );
  late final _anim = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  late int _index = _page.initialPage;

  @override
  void dispose() {
    _page.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _buy(ShipType t) async {
    final p = AppState.profile;
    if (p.gems < t.gemPrice) {
      toast(context, tr.u_notEnoughGems);
      return;
    }
    if (!await confirmDialog(context, tr.u_buyConfirmTitle, tr.u_buyShipConfirm(t.name, eul('⭐${t.gemPrice}')))) return;
    if (!await payGems(t.gemPrice, 'ship')) return;
    final w = AppState.world;
    final ok = w != null ? w.buyShip(t) : p.buyShip(t);
    if (!ok) return;
    if (w == null) p.shipType = t.id;
    AppState.play(Sfx.gem);
    await SaveService.saveProfile(p);
    if (mounted) {
      toast(context, tr.u_shipBought(t.name));
      setState(() {});
    }
  }

  Future<void> _board(ShipType t) async {
    final p = AppState.profile;
    final w = AppState.world;
    if (w != null) {
      w.switchShip(t);
    } else {
      p
        ..shipType = t.id
        ..dirty = true;
    }
    AppState.play(Sfx.upgrade);
    await SaveService.saveProfile(p);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = AppState.profile;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B26),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151236),
        title: Text(widget.premiumOnly ? tr.u_premiumShips : tr.u_hangarTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Space.l),
            child: Center(child: iconValue('gem', '${p.gems}', size: IconSz.inline)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _ships.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _card(_ships[i]),
              ),
            ),
            _pager(),
            const SizedBox(height: Space.l),
          ],
        ),
      ),
    );
  }

  Widget _pager() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 32,
            color: Colors.white,
            onPressed: _index > 0
                ? () => _page.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          for (var i = 0; i < _ships.length; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _index ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == _index
                    ? (_ships[i].premium ? const Color(0xFFFFC107) : kSky)
                    : Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          IconButton(
            iconSize: 32,
            color: Colors.white,
            onPressed: _index < _ships.length - 1
                ? () => _page.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      );

  Widget _card(ShipType t) {
    final p = AppState.profile;
    final unlocked = p.shipUnlocked(t);
    final current = p.shipType == t.id;
    final glow = t.premium ? const Color(0xFFFFC107) : kSky;
    // 넓은 화면(iPad)에서 폭을 제한하고, 키 큰 화면에서는 카드를 내용 높이로 줄여 가운데 둔다
    // (늘어난 카드 아래쪽이 비어 보이지 않게). 내용이 화면보다 길면 카드 안에서 스크롤.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: Space.m),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _cardBody(t, unlocked, current, glow),
        ),
      ),
    );
  }

  Widget _cardBody(ShipType t, bool unlocked, bool current, Color glow) {
    final p = AppState.profile;
    return Container(
        decoration: BoxDecoration(
          color: kPanelColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: glow.withValues(alpha: t.premium ? 0.9 : 0.4), width: t.premium ? 2 : 1),
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final shipSize = min(box.maxWidth * 0.78, box.maxHeight * 0.42);
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(Space.l),
              children: [
                // 함선: 크게, 둥실둥실
                SizedBox(
                  height: shipSize + Space.xl,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: shipSize,
                        height: shipSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [glow.withValues(alpha: 0.28), glow.withValues(alpha: 0)],
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _anim,
                        builder: (context, child) {
                          final a = _anim.value * 2 * pi;
                          return Transform.translate(
                            offset: Offset(0, sin(a) * 8),
                            child: Transform.rotate(angle: sin(a) * 0.05, child: child),
                          );
                        },
                        child: Opacity(
                          opacity: unlocked ? 1 : 0.55,
                          child: Image.asset(
                            'assets/sprites/ship_${t.id}_${p.skin}.png',
                            width: shipSize * 0.9,
                            height: shipSize * 0.9,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                      if (!unlocked)
                        const Positioned(right: 0, top: 0, child: Icon(Icons.lock, color: Colors.white70, size: 28)),
                    ],
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: Space.s,
                  children: [
                    Text(t.name, style: Ts.title.copyWith(fontWeight: FontWeight.bold)),
                    if (t.premium) const PremiumBadge(),
                  ],
                ),
                const SizedBox(height: Space.xs),
                Text(t.desc, textAlign: TextAlign.center, style: dimStyle),
                if (t.ability.isNotEmpty) ...[
                  const SizedBox(height: Space.s),
                  Text('✨ ${t.ability}',
                      textAlign: TextAlign.center, style: Ts.body.copyWith(color: const Color(0xFFFFE082))),
                ],
                const SizedBox(height: Space.m),
                _stat(tr.u_hp, t.hpMul),
                _stat(tr.u_speed, t.speedMul),
                _stat(tr.u_attack, t.dmgMul),
                _stat(tr.u_fireRate, 1 / t.fireMul),
                if (t.oreMul != 1) _stat(tr.u_ore, t.oreMul),
                if (t.crit > 0) _stat(tr.u_crit, 1 + t.crit * 2, label: '${(t.crit * 100).round()}%'),
                const SizedBox(height: Space.l),
                Center(child: _action(t, unlocked, current)),
                if (!unlocked && !t.premium) ...[
                  const SizedBox(height: Space.xs),
                  Text(tr.u_unlock(t.unlockDesc), textAlign: TextAlign.center, style: dimStyle),
                ],
              ],
            );
          },
        ),
    );
  }

  /// 능력치 막대: 기본(x1.0)이 막대의 60%쯤
  Widget _stat(String name, double v, {String? label}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            // 언어마다 길이가 달라 고정 폭이면 단어 중간에서 줄이 바뀐다. 넓게 잡고 넘치면 줄여서 한 줄로.
            SizedBox(
              width: 112,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(name, style: Ts.body, maxLines: 1),
              ),
            ),
            const SizedBox(width: Space.s),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: (v / 1.7).clamp(0.05, 1.0),
                  minHeight: 10,
                  color: v > 1.001 ? const Color(0xFF7CFFB2) : (v < 0.999 ? const Color(0xFFFF8A80) : kSky),
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(label ?? 'x${v.toStringAsFixed(2)}', textAlign: TextAlign.right, style: dimStyle),
            ),
          ],
        ),
      );

  Widget _action(ShipType t, bool unlocked, bool current) {
    final p = AppState.profile;
    if (current) return Text(tr.u_boarded, style: Ts.title.copyWith(color: const Color(0xFF7CFFB2)));
    if (unlocked) return actionBtn(tr.u_boardNow, true, () => _board(t), primary: true);
    return actionBtn(tr.u_buyGems(t.gemPrice), p.gems >= t.gemPrice, () => _buy(t),
        primary: true, color: const Color(0xFFAD1457));
  }
}
