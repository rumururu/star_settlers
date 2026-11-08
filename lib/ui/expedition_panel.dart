import 'package:flutter/material.dart';

import '../game/crew.dart';
import '../game/expedition.dart';
import '../game/world.dart';
import '../l10n/l.dart';
import 'chibi.dart';
import 'common.dart';
import 'game_icons.dart';

/// '3시간 12분' / '12분'
String expeditionTime(Duration d) {
  final m = (d.inSeconds / 60).ceil();
  return m >= 60 ? tr.r4_timeHm(m ~/ 60, m % 60) : tr.r4_timeM(m);
}

/// 승무원 원정 (정거장 승무원 탭 맨 위). 진행 중인 원정 카드 + 빈 자리에 보낼 승무원·시간 고르기.
/// 다른 창을 겹쳐 띄우지 않고 패널 안에서 끝난다 (받은 보상도 이 안에 한 줄로 보여 준다).
class ExpeditionPanel extends StatefulWidget {
  const ExpeditionPanel({
    super.key,
    required this.world,
    required this.act,
    this.now,
  });

  final GameWorld world;
  final void Function(bool Function() action) act;

  /// 테스트용 고정 시각
  final DateTime Function()? now;

  @override
  State<ExpeditionPanel> createState() => _ExpeditionPanelState();
}

class _ExpeditionPanelState extends State<ExpeditionPanel> {
  int? _crewId;
  ExpeditionReward? _last;

  GameWorld get w => widget.world;
  DateTime _wall() => widget.now?.call() ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final nowMs = w.expeditionClock.now(_wall());
    final idle = w.idleCrew.toList();
    final free = w.expeditions.length < w.expeditionSlots;
    if (_crewId != null && !idle.any((c) => c.id == _crewId)) _crewId = null;
    _crewId ??= idle.isEmpty ? null : idle.first.id;
    return Container(
      key: const ValueKey('expedition-panel'),
      padding: const EdgeInsets.all(Space.m),
      decoration: BoxDecoration(
        color: const Color(0x2200E5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x6600E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Space.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(keepAll('🚀 ${tr.r4_expTitle}'), style: sectionStyle),
              Text(
                tr.r4_expSlots(w.expeditions.length, w.expeditionSlots),
                style: bodyStyle.copyWith(color: kSky),
              ),
              if (!w.profile.premium)
                Text(keepAll(tr.r4_expPassSlot), style: dimStyle),
            ],
          ),
          Text(keepAll(tr.r4_expHint), style: dimStyle),
          if (_last != null) ...[
            const SizedBox(height: Space.s),
            _rewardLine(_last!),
          ],
          for (final e in w.expeditions) ...[
            const SizedBox(height: Space.s),
            _activeCard(e, nowMs),
          ],
          if (free) ...[
            const SizedBox(height: Space.s),
            if (idle.isEmpty)
              Text(keepAll(tr.r4_expNoIdle), style: bodyStyle)
            else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [for (final c in idle) _crewChip(c)]),
              ),
              const SizedBox(height: Space.s),
              Wrap(
                spacing: Space.s,
                runSpacing: Space.s,
                children: [
                  for (final h in Expeditions.durations) _sendBtn(h, idle),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  CrewMember? _crew(int id) => w.roster.where((c) => c.id == id).firstOrNull;

  Widget _crewChip(CrewMember c) {
    final sel = c.id == _crewId;
    return Padding(
      padding: const EdgeInsets.only(right: Space.s),
      child: InkWell(
        key: ValueKey('exp-crew-${c.id}'),
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _crewId = c.id),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: Tap.min,
            minHeight: Tap.min,
          ),
          padding: const EdgeInsets.all(Space.xs),
          decoration: BoxDecoration(
            color: sel ? const Color(0x5500E5FF) : const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sel ? const Color(0xFF00E5FF) : Colors.white12,
              width: sel ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              ChibiPortrait(style: ChibiStyle.forCrew(c), size: 40),
              Text(
                '${c.stars} ${c.name}',
                style: Ts.caption.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sendBtn(int hours, List<CrewMember> idle) {
    final c = idle.where((m) => m.id == _crewId).firstOrNull;
    return actionBtn(
      '${tr.r4_expHours(hours)}${hours >= 8 ? ' · ${tr.r4_expLuck}' : ''}',
      c != null,
      c == null
          ? null
          : () => widget.act(() {
              final ok = w.startExpedition(c, hours, _wall()) != null;
              if (ok) setState(() => _crewId = null);
              return ok;
            }),
      icon: 'act_warp',
      iconSize: IconSz.inline,
      color: const Color(0xFF00838F),
    );
  }

  Widget _activeCard(Expedition e, int nowMs) {
    final c = _crew(e.crewId);
    final done = e.isDone(nowMs);
    return Container(
      key: ValueKey('exp-active-${e.crewId}'),
      padding: const EdgeInsets.all(Space.s),
      decoration: BoxDecoration(
        color: done ? const Color(0x3343A047) : const Color(0x22FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done ? const Color(0xFF7CFFB2) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          if (c != null) ChibiPortrait(style: ChibiStyle.forCrew(c), size: 44),
          const SizedBox(width: Space.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  keepAll('${c?.name ?? '?'} · ${tr.r4_expHours(e.hours)}'),
                  style: bodyStyle,
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: e.progress(nowMs),
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    color: done
                        ? const Color(0xFF7CFFB2)
                        : const Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: Space.s,
                  children: [
                    iconValue(
                      'credits',
                      compact(e.credits),
                      size: 16,
                      style: Ts.caption,
                    ),
                    iconValue(
                      'ore',
                      compact(e.ore),
                      size: 16,
                      style: Ts.caption,
                    ),
                    Text('XP +${e.xp}', style: Ts.caption),
                    if (!done)
                      Text(
                        keepAll(
                          tr.r4_expLeft(expeditionTime(e.remaining(nowMs))),
                        ),
                        style: Ts.caption.copyWith(color: kSky),
                      ),
                  ],
                ),
                // 받기 버튼은 정보 아래 (옆에 두면 좁은 화면·긴 번역에서 정보 칸이 50px까지 줄었다)
                if (done) ...[
                  const SizedBox(height: Space.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: actionBtn(
                      tr.r4_expClaim,
                      true,
                      () => widget.act(() {
                        final r = w.claimExpedition(e, _wall());
                        if (r != null) setState(() => _last = r);
                        return r != null;
                      }),
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardLine(ExpeditionReward r) {
    final parts = [
      '💰${compact(r.credits)}',
      '💎${compact(r.ore)}',
      'XP +${r.xp}',
      if (r.levelUps > 0) 'Lv ↑${r.levelUps}',
      if (r.gems > 0) '⭐${r.gems}',
      if (r.rareCrew) tr.r4_rewardCrew3,
    ];
    return glass(
      Row(
        children: [
          const GameIcon('credits', size: IconSz.inline),
          const SizedBox(width: Space.xs),
          Expanded(
            child: gemText(
              keepAll(tr.r4_expGot(parts.join('  '))),
              style: bodyStyle.copyWith(color: const Color(0xFF7CFFB2)),
            ),
          ),
        ],
      ),
    );
  }
}
