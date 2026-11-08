import 'package:flutter/material.dart';

import '../game/rift.dart';
import '../game/world.dart';
import '../l10n/l.dart';
import 'common.dart';
import 'game_icons.dart';
import 'leaderboard_screen.dart' show groupDigits;
import 'rift_screen.dart' show riftMenuIcon;

/// 균열 런 패널들 (소개·카드 고르기·결과·일시정지). 모두 같은 모달 틀([RiftPanel]) 안에 그린다.

extension RiftCardText on RiftCard {
  String get title => switch (this) {
        RiftCard.damage => tr.rift_cardDamage,
        RiftCard.rapid => tr.rift_cardRapid,
        RiftCard.multishot => tr.rift_cardMultishot,
        RiftCard.pierce => tr.rift_cardPierce,
        RiftCard.homing => tr.rift_cardHoming,
        RiftCard.regen => tr.rift_cardRegen,
        RiftCard.drone => tr.rift_cardDrone,
        RiftCard.magnet => tr.rift_cardMagnet,
        RiftCard.crit => tr.rift_cardCrit,
        RiftCard.blades => tr.rift_cardBlades,
        RiftCard.hull => tr.rift_cardHull,
        RiftCard.engine => tr.rift_cardEngine,
        RiftCard.shockwave => tr.rift_cardShockwave,
        RiftCard.guard => tr.rift_cardGuard,
        RiftCard.vampire => tr.rift_cardVampire,
      };

  /// 효과 한 줄. "15 %"처럼 숫자와 단위 사이 공백에서 줄이 바뀌지 않게 붙인다 (독일어·프랑스어 표기).
  String get desc => _desc.replaceAllMapped(RegExp(r'(\d) ([%×])'), (m) => '${m[1]}\u00a0${m[2]}');

  String get _desc => switch (this) {
        RiftCard.damage => tr.rift_cardDamageDesc,
        RiftCard.rapid => tr.rift_cardRapidDesc,
        RiftCard.multishot => tr.rift_cardMultishotDesc,
        RiftCard.pierce => tr.rift_cardPierceDesc,
        RiftCard.homing => tr.rift_cardHomingDesc,
        RiftCard.regen => tr.rift_cardRegenDesc,
        RiftCard.drone => tr.rift_cardDroneDesc,
        RiftCard.magnet => tr.rift_cardMagnetDesc,
        RiftCard.crit => tr.rift_cardCritDesc,
        RiftCard.blades => tr.rift_cardBladesDesc,
        RiftCard.hull => tr.rift_cardHullDesc,
        RiftCard.engine => tr.rift_cardEngineDesc,
        RiftCard.shockwave => tr.rift_cardShockwaveDesc,
        RiftCard.guard => tr.rift_cardGuardDesc,
        RiftCard.vampire => tr.rift_cardVampireDesc,
      };
}

extension RiftRarityLook on RiftRarity {
  String get label => switch (this) {
        RiftRarity.common => tr.rift_rarityCommon,
        RiftRarity.rare => tr.rift_rarityRare,
        RiftRarity.epic => tr.rift_rarityEpic,
      };

  Color get color => switch (this) {
        RiftRarity.common => const Color(0xFF8AD8FF),
        RiftRarity.rare => const Color(0xFFB388FF),
        RiftRarity.epic => const Color(0xFFFFC94D),
      };
}

/// 모달 틀: 반투명 막 + 안전 영역 안 가운데 패널. 바깥을 눌러도 닫히지 않는다 (런 도중 실수 방지).
/// 내용이 높이보다 길면 내용만 스크롤되고, [actions] 버튼 줄은 늘 패널 아래에 보인다 (가로 폰).
class RiftPanel extends StatelessWidget {
  const RiftPanel(
      {super.key, required this.content, this.actions, this.maxWidth = 480, this.scrim = Colors.black54, this.padding = Space.l});
  final List<Widget> content;
  final Widget? actions;
  final double maxWidth;
  final Color scrim;
  final double padding;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: scrim,
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(Space.m),
              // 가로 화면은 높이가 모자라니 더 넓게 펴서 줄 수를 줄인다
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).aspectRatio > 1 && maxWidth < 680 ? 680 : maxWidth),
              decoration: BoxDecoration(
                color: kPanelColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFB388FF)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(padding, padding, padding, actions == null ? padding : Space.s),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: content,
                      ),
                    ),
                  ),
                  if (actions != null)
                    Padding(padding: EdgeInsets.fromLTRB(padding, Space.xs, padding, padding), child: actions),
                ],
              ),
            ),
          ),
        ),
      );
}

Widget _buttons(List<Widget> buttons) => Wrap(
      alignment: WrapAlignment.center,
      spacing: Space.s,
      runSpacing: Space.s,
      children: buttons,
    );

/// 출격 전 소개: 규칙, 개인 최고, 오늘 남은 전액 보상
class RiftIntroPanel extends StatelessWidget {
  const RiftIntroPanel({super.key, required this.records, required this.now, required this.onStart, required this.onExit});
  final RiftRecords records;
  final DateTime now;
  final VoidCallback onStart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final left = records.fullRunsLeft(now);
    return RiftPanel(
      key: const ValueKey('rift-intro'),
      content: [
        const Center(child: GameIcon(riftMenuIcon, size: IconSz.row)),
        Text(tr.rift_title, style: Ts.title.copyWith(color: const Color(0xFFE1BEE7)), textAlign: TextAlign.center),
        Text(tr.rift_menuSub, style: Ts.caption, textAlign: TextAlign.center),
        const SizedBox(height: Space.m),
        Text(keepAll(tr.rift_rules), style: bodyStyle),
        const SizedBox(height: Space.m),
        Text(
          records.best > 0 ? tr.rift_bestLine(groupDigits(records.best), records.bestWave) : tr.rift_noBest,
          style: Ts.label.copyWith(color: const Color(0xFFFFD54F)),
          textAlign: TextAlign.center,
        ),
        Text(
          keepAll(left > 0 ? tr.rift_fullLeft(left) : tr.rift_fullUsed),
          style: dimStyle,
          textAlign: TextAlign.center,
        ),
      ],
      actions: _buttons([
        actionBtn(tr.rift_start, true, onStart, color: const Color(0xFF7C4DFF), leadingIcon: Icons.rocket_launch),
        actionBtn(tr.rift_exit, true, onExit, color: const Color(0xFF2A2357)),
      ]),
    );
  }
}

/// 파도를 넘긴 뒤 카드 3장 중 1장. 세로 화면은 세로로, 가로(낮은) 화면은 가로로 늘어놓는다.
class RiftCardPicker extends StatelessWidget {
  const RiftCardPicker({super.key, required this.wave, required this.offers, required this.loadout, required this.onPick});
  final int wave;
  final List<RiftCard> offers;
  final RiftLoadout loadout;
  final void Function(RiftCard) onPick;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final row = size.width > size.height;
    final cards = [for (final c in offers) _card(c, row)];
    return RiftPanel(
      key: const ValueKey('rift-picker'),
      maxWidth: row ? 760 : 460,
      scrim: Colors.black45,
      padding: row ? Space.m : Space.l,
      content: [
        Text(keepAll(tr.rift_pickTitle(wave)), style: titleStyle, textAlign: TextAlign.center),
        const SizedBox(height: Space.m),
        if (row)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: Space.s),
                  Expanded(child: cards[i]),
                ],
              ],
            ),
          )
        else
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: Space.s),
            cards[i],
          ],
      ],
    );
  }

  Widget _card(RiftCard c, bool column) {
    final color = c.rarity.color;
    final lv = loadout.of(c) + 1;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: .2), borderRadius: BorderRadius.circular(Space.s)),
      child: Text('${c.rarity.label} · ${tr.rift_cardLevel(lv, c.maxStacks)}',
          style: Ts.caption.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
    final name = Text(c.title, style: Ts.headingBold.copyWith(color: Colors.white), textAlign: column ? TextAlign.center : null);
    final rest = [
      const SizedBox(height: Space.xs),
      chip,
      const SizedBox(height: Space.xs),
      Text(keepAll(c.desc), style: bodyStyle, textAlign: column ? TextAlign.center : null),
    ];
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: InkWell(
          key: ValueKey('rift-card-${c.name}'),
          borderRadius: BorderRadius.circular(16),
          onTap: () => onPick(c),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Tap.min),
            child: Padding(
              padding: EdgeInsets.all(column ? Space.s : Space.m),
              // 가로(낮은) 화면: 아이콘을 이름 옆에 붙여 높이를 아낀다
              child: column
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 긴 이름(독일어 'Schildregeneration')은 줄을 끊지 않고 조금 줄인다
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            GameIcon(c.icon, size: IconSz.button + 6),
                            const SizedBox(width: Space.xs),
                            name,
                          ]),
                        ),
                        ...rest,
                      ],
                    )
                  : Row(
                      children: [
                        GameIcon(c.icon, size: IconSz.row),
                        const SizedBox(width: Space.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [name, ...rest],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 결과: 도달 파도·점수·개인 최고·받은 보상
class RiftResultPanel extends StatelessWidget {
  const RiftResultPanel({
    super.key,
    required this.outcome,
    required this.settlement,
    required this.bestWave,
    required this.onAgain,
    required this.onExit,
  });
  final RiftOutcome outcome;
  final RiftSettlement settlement;
  final int bestWave;
  final VoidCallback onAgain;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final r = settlement.reward;
    final title = outcome.conquered
        ? tr.rift_resultWin
        : outcome.gaveUp
            ? tr.rift_resultGaveUp
            : tr.rift_resultLose;
    return RiftPanel(
      key: const ValueKey('rift-result'),
      content: [
        Text(keepAll(title),
            style: Ts.title.copyWith(color: outcome.conquered ? const Color(0xFFFFD54F) : const Color(0xFFE1BEE7)),
            textAlign: TextAlign.center),
        const SizedBox(height: Space.s),
        Text(tr.rift_reached(outcome.reached), style: Ts.heading, textAlign: TextAlign.center),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(groupDigits(outcome.score), style: Ts.display.copyWith(color: const Color(0xFFFFD54F))),
        ),
        if (settlement.newBest)
          Text(tr.rift_newBest, style: Ts.label.copyWith(color: const Color(0xFF7CFFB2)), textAlign: TextAlign.center)
        else
          Text(tr.rift_bestLine(groupDigits(settlement.best), bestWave), style: dimStyle, textAlign: TextAlign.center),
        const SizedBox(height: Space.m),
        Text(tr.rift_rewardTitle, style: sectionStyle, textAlign: TextAlign.center),
        const SizedBox(height: Space.xs),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Space.l,
          runSpacing: Space.xs,
          children: [
            if (settlement.mainApplied) iconValue('credits', '+${groupDigits(r.credits)}', size: 24, style: Ts.heading),
            if (settlement.mainApplied) iconValue('ore', '+${groupDigits(r.ore)}', size: 24, style: Ts.heading),
            if (r.gems > 0) iconValue('gem', '+${r.gems}', size: 24, style: Ts.heading),
          ],
        ),
        if (!settlement.mainApplied) Text(keepAll(tr.rift_noSave), style: dimStyle, textAlign: TextAlign.center),
        if (!r.full) Text(keepAll(tr.rift_rewardReduced), style: dimStyle, textAlign: TextAlign.center),
      ],
      actions: _buttons([
        actionBtn(tr.rift_again, true, onAgain, color: const Color(0xFF7C4DFF), leadingIcon: Icons.replay),
        actionBtn(tr.rift_exit, true, onExit, color: const Color(0xFF2A2357)),
      ]),
    );
  }
}

/// 런 도중 일시정지: 계속하기 / 포기하고 나가기
class RiftPausePanel extends StatelessWidget {
  const RiftPausePanel({super.key, required this.onResume, required this.onGiveUp});
  final VoidCallback onResume;
  final VoidCallback onGiveUp;

  @override
  Widget build(BuildContext context) => RiftPanel(
        key: const ValueKey('rift-pause-panel'),
        content: [
          Text(tr.u_paused, style: titleStyle, textAlign: TextAlign.center),
          const SizedBox(height: Space.s),
          Text(keepAll(tr.rift_giveUpNote), style: dimStyle, textAlign: TextAlign.center),
        ],
        actions: _buttons([
          actionBtn(plainResume(tr.u_resume), true, onResume, color: const Color(0xFF7C4DFF), leadingIcon: Icons.play_arrow_rounded),
          actionBtn(tr.rift_giveUp, true, onGiveUp, color: const Color(0xFF5A2340), leadingIcon: Icons.logout_rounded),
        ]),
      );
}

/// "▶︎ 계속하기" → "계속하기" (아이콘을 따로 붙인다)
String plainResume(String s) => s.replaceFirst(RegExp(r'^[^\p{L}\p{N}]+', unicode: true), '').trim();
