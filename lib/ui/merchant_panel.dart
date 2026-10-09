import 'package:flutter/material.dart';

import '../game/crew.dart';
import '../game/models.dart';
import '../game/world.dart';
import '../l10n/l.dart';
import 'chibi.dart';
import 'common.dart';
import 'station_panel.dart';

class MerchantPanel extends StatelessWidget {
  const MerchantPanel({
    super.key,
    required this.world,
    required this.event,
    required this.frame,
    required this.act,
    required this.onClose,
  });

  final GameWorld world;
  final WorldEvent event;
  final Listenable frame;
  final ActFn act;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return OverlayPanel(
      onClose: onClose,
      child: ListenableBuilder(
        listenable: frame,
        builder: (context, _) {
          final w = world;
          final c = w.merchantCrew;
          return ListView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  const ChibiPortrait(style: ChibiStyle.merchant, size: 64),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr.u_merchantName, style: titleStyle),
                        Text(tr.u_merchantLeaves(event.timeLeft.ceil(), compact(w.credits)),
                            style: dimStyle),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: onClose),
                ],
              ),
              const Divider(color: Colors.white24),
              Text(tr.u_rareCrewOffer, style: sectionStyle),
              if (c == null)
                Text(tr.u_crewSoldOut, style: dimStyle)
              else
                Row(
                  children: [
                    ChibiPortrait(style: ChibiStyle.forCrew(c), size: 64),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          '${c.stars} ${c.name}\n${c.role.icon} ${c.role.label} · ${c.role.effect} +${c.bonusPct}%',
                          style: bodyStyle),
                    ),
                    actionBtn('💰${w.merchantCrewPrice}',
                        w.credits >= w.merchantCrewPrice && w.roster.length < w.rosterCap,
                        () => act(w.buyMerchantCrew)),
                  ],
                ),
              const Divider(color: Colors.white24),
              Text(tr.u_gemTrade, style: sectionStyle),
              Row(
                children: [
                  Expanded(
                      child: Text(tr.u_gemTradeRow(w.merchantGemPrice, 3 - w.merchantGemTrades),
                          style: bodyStyle)),
                  actionBtn(tr.u_convert, w.merchantGemTrades < 3 && w.credits >= w.merchantGemPrice,
                      () => act(w.buyGemsFromMerchant),
                      color: const Color(0xFFAD1457)),
                ],
              ),
              const Divider(color: Colors.white24),
              Text(tr.u_potions, style: sectionStyle),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final k in PowerUpKind.values)
                    actionBtn('${k.icon} ${k.label} 💰${GameWorld.merchantPowerPrice}',
                        w.credits >= GameWorld.merchantPowerPrice, () => act(() => w.buyPowerUp(k))),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
