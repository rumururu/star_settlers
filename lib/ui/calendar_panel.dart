import 'package:flutter/material.dart';

import '../game/attendance.dart';
import '../game/game_telemetry.dart';
import '../game/profile.dart';
import '../l10n/l.dart';
import 'chibi.dart';
import 'common.dart';
import 'game_icons.dart';

/// 출석 칸 보상 한 줄 이름 (젬 제외)
String calendarRewardLabel(CalendarReward r) => switch (r.kind) {
  CalendarRewardKind.ore => tr.r4_rewardOre,
  CalendarRewardKind.credits => tr.r4_rewardCredits,
  CalendarRewardKind.crew2 => tr.r4_rewardCrew2,
  CalendarRewardKind.crew3 => tr.r4_rewardCrew3,
  CalendarRewardKind.skin => tr.r4_rewardSkin,
  CalendarRewardKind.none => '',
};

/// '⭐10 + ★3 승무원' (젬 + 그 칸의 보상)
String calendarCellText(int cell, Profile p) {
  final r = Attendance.rewardFor(
    cell,
    skinOwned: p.ownedSkins.contains(attendanceSkinId),
  );
  final extra = calendarRewardLabel(r);
  return '⭐${Attendance.gemsFor(cell)}${extra.isEmpty ? '' : ' + $extra'}';
}

/// 내일 접속하면 받는 것 (오늘 받는다고 가정)
String tomorrowRewardText(Profile p, DateTime now) =>
    calendarCellText(Attendance.cell(Attendance.streakTomorrow(p, now)), p);

/// 7일 출석 달력. 오늘 칸 강조, 지난 칸 체크, 앞으로 칸은 보상 미리보기.
/// [onClaimed]: 받은 뒤 (월드 보상 지급·저장은 부르는 쪽이 한다)
class CalendarPanel extends StatefulWidget {
  const CalendarPanel({
    super.key,
    required this.profile,
    required this.onClose,
    this.onClaimed,
    this.now,
  });

  final Profile profile;
  final VoidCallback onClose;
  final VoidCallback? onClaimed;

  /// 테스트용 고정 시각 (없으면 지금)
  final DateTime? now;

  @override
  State<CalendarPanel> createState() => _CalendarPanelState();
}

class _CalendarPanelState extends State<CalendarPanel> {
  DateTime get _now => widget.now ?? DateTime.now();
  Profile get _p => widget.profile;

  @override
  void initState() {
    super.initState();
    GameTelemetry.emit(
      TelemetryEvent.calendarOpen,
      Attendance.cell(Attendance.streakToday(_p, _now)),
    );
  }

  void _claim() {
    if (Attendance.claim(_p, _now) == null) return;
    widget.onClaimed?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = _now;
    final streak = Attendance.streakToday(_p, now);
    final claimable = Attendance.claimable(_p, now);
    return OverlayPanel(
      key: const ValueKey('calendar-panel'),
      onClose: widget.onClose,
      maxWidth: 620,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const ChibiPortrait(style: ChibiStyle.advisor, size: 56),
                const SizedBox(width: Space.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(keepAll(tr.r4_calendarTitle), style: titleStyle),
                      Text(
                        keepAll(tr.r4_calendarStreak(streak)),
                        style: bodyStyle.copyWith(color: kSky),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: tr.u_close,
                  constraints: const BoxConstraints(
                    minWidth: Tap.min,
                    minHeight: Tap.min,
                  ),
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: Space.s),
            LayoutBuilder(
              builder: (context, c) {
                // 넓으면 한 줄 7칸, 좁으면 4칸 + 3칸
                final perRow = c.maxWidth >= 520 ? 7 : 4;
                const gap = Space.s;
                final w = (c.maxWidth - gap * (perRow - 1)) / perRow;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var i = 1; i <= Attendance.days; i++)
                      _cell(
                        i,
                        w,
                        Attendance.stateOf(i, _p, now),
                        compact: perRow == 7,
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: Space.m),
            // 받기 버튼을 설명보다 먼저: 낮은 가로 화면에서도 스크롤 없이 보이게
            if (claimable)
              KeyedSubtree(
                key: const ValueKey('calendar-claim'),
                child: actionBtn(
                  tr.r4_calendarClaim,
                  true,
                  _claim,
                  primary: true,
                  color: const Color(0xFF00897B),
                ),
              )
            else ...[
              Text(
                keepAll(tr.r4_calendarClaimed),
                style: bodyStyle.copyWith(color: const Color(0xFF7CFFB2)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Space.s),
              // 가로 화면에서는 나란히 (스크롤 없이 닫기 버튼이 보이게)
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Space.m,
                runSpacing: Space.s,
                children: [
                  TomorrowCard(profile: _p, now: now),
                  actionBtn(tr.u_great, true, widget.onClose, primary: true),
                ],
              ),
            ],
            const SizedBox(height: Space.m),
            Text(
              keepAll(tr.r4_calendarHint),
              style: dimStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(int day, double width, CellState state, {bool compact = false}) {
    final reward = Attendance.rewardFor(
      day,
      skinOwned: _p.ownedSkins.contains(attendanceSkinId),
    );
    final today = state == CellState.today || state == CellState.claimedToday;
    final done = state == CellState.past || state == CellState.claimedToday;
    const gold = Color(0xFFFFD54F);
    final big = day == Attendance.days;
    final label = calendarRewardLabel(reward);
    final cell = Container(
      key: ValueKey('calendar-day-$day'),
      width: width,
      constraints: BoxConstraints(minHeight: compact ? 0 : 104),
      padding: const EdgeInsets.symmetric(vertical: Space.s, horizontal: 2),
      decoration: BoxDecoration(
        color: today
            ? const Color(0xFF4527A0)
            : big
            ? const Color(0xFF3E2A10)
            : const Color(0xFF1E1A4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: today
              ? gold
              : (big ? const Color(0xAAFFB300) : Colors.white12),
          width: today ? 2.5 : 1,
        ),
        boxShadow: today
            ? [BoxShadow(color: gold.withValues(alpha: 0.4), blurRadius: 10)]
            : null,
      ),
      child: Opacity(
        opacity: state == CellState.past ? 0.5 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            fitLines(
              today ? tr.r4_calendarToday : tr.m_dayN(day),
              Ts.caption.copyWith(
                color: today ? gold : Colors.white70,
                fontWeight: today ? FontWeight.bold : null,
              ),
              width - 4,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: iconValue(
                'gem',
                '${Attendance.gemsFor(day)}',
                size: IconSz.inline,
                style: bodyStyle,
              ),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 2),
              _rewardIcon(reward),
              fitLines(
                label,
                Ts.caption.copyWith(color: big ? gold : kSky),
                width - 4,
              ),
            ],
          ],
        ),
      ),
    );
    // 받은 칸: 오른쪽 위 체크 (숫자를 가리지 않게)
    return Stack(
      clipBehavior: Clip.none,
      children: [
        cell,
        if (done)
          const Positioned(
            top: -6,
            right: -4,
            child: Icon(
              Icons.check_circle,
              color: Color(0xFF7CFFB2),
              size: IconSz.inline + 2,
            ),
          ),
      ],
    );
  }

  Widget _rewardIcon(CalendarReward r) => switch (r.kind) {
    CalendarRewardKind.ore => const GameIcon('ore', size: IconSz.inline),
    CalendarRewardKind.credits => const GameIcon(
      'credits',
      size: IconSz.inline,
    ),
    CalendarRewardKind.crew2 ||
    CalendarRewardKind.crew3 => const GameIcon('tab_crew', size: IconSz.inline),
    CalendarRewardKind.skin => const GameIcon('tab_ship', size: IconSz.inline),
    CalendarRewardKind.none => const SizedBox.shrink(),
  };
}

/// 작은 '내일 접속: …' 카드 (일시정지 메뉴·타이틀·달력)
class TomorrowCard extends StatelessWidget {
  const TomorrowCard({super.key, required this.profile, this.now, this.onTap});
  final Profile profile;
  final DateTime? now;

  /// 누르면 달력 열기 (일시정지 메뉴)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = glass(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎁', style: Ts.body),
          const SizedBox(width: Space.xs),
          Flexible(
            child: gemText(
              keepAll(
                tr.r4_tomorrow(
                  tomorrowRewardText(profile, now ?? DateTime.now()),
                ),
              ),
              style: Ts.body.copyWith(color: const Color(0xFFFFD54F)),
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.m,
        vertical: Space.s,
      ),
    );
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        key: const ValueKey('tomorrow-card'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Tap.min),
          child: Align(widthFactor: 1, child: card),
        ),
      ),
    );
  }
}
