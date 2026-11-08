import 'dart:math';

import 'package:flutter/material.dart';

import '../game/crew.dart';
import '../l10n/l.dart';
import 'chibi.dart';
import 'common.dart';

/// 새 승무원 카드 공개 연출 (첫 ★3 확정 지급, 출석·원정 보상 등).
/// 카드가 뒤집히며 나타나고 별이 하나씩 켜진다. 모달 레이어 하나로 띄운다 ([OverlayPanel]).
class CrewRevealCard extends StatelessWidget {
  const CrewRevealCard({
    super.key,
    required this.crew,
    required this.onClose,
    this.assigned = false,
    this.title,
  });

  final CrewMember crew;
  final VoidCallback onClose;

  /// 이미 배치되어 효과가 적용 중이면 안내 한 줄
  final bool assigned;

  /// 제목 (없으면 희귀도에 맞는 기본 제목)
  final String? title;

  static const _gold = Color(0xFFFFD54F);

  @override
  Widget build(BuildContext context) {
    final c = crew;
    // 낮은 가로 화면: 그림을 줄여 확인 버튼이 스크롤 없이 보이게
    final short = MediaQuery.sizeOf(context).height < Layout.shortHeight;
    final heading =
        title ??
        (c.legendary
            ? tr.u_legendaryGet
            : (c.rarity >= 3 ? tr.u_rareGet : tr.u_newCrew));
    final portrait = Container(
      padding: const EdgeInsets.all(Space.s),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [_gold.withValues(alpha: 0.45), Colors.transparent],
        ),
      ),
      child: ChibiPortrait(
        style: ChibiStyle.forCrew(c),
        size: short ? 88 : 120,
      ),
    );
    final stars = _Stars(rarity: c.rarity);
    final info = <Widget>[
      const SizedBox(height: Space.xs),
      Text(
        keepAll('${c.role.icon} ${c.role.label} · ${c.displayName}'),
        textAlign: TextAlign.center,
        style: titleStyle,
      ),
      const SizedBox(height: Space.xs),
      Text(
        keepAll(c.effectText),
        textAlign: TextAlign.center,
        style: bodyStyle.copyWith(color: kSky),
      ),
      if (assigned) ...[
        const SizedBox(height: Space.xs),
        Text(
          keepAll(tr.r3_crewAssigned),
          textAlign: TextAlign.center,
          style: dimStyle,
        ),
      ],
      const SizedBox(height: Space.m),
      actionBtn(tr.u_great, true, onClose, primary: true),
    ];
    return OverlayPanel(
      key: const ValueKey('crew-reveal'),
      onClose: onClose,
      maxWidth: 420,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutBack,
        builder: (context, t, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY((1 - t.clamp(0.0, 1.0)) * pi / 2),
          child: child,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(short ? Space.m : Space.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                keepAll(heading),
                textAlign: TextAlign.center,
                style: Ts.title.copyWith(color: _gold),
              ),
              const SizedBox(height: Space.s),
              // 낮은 가로 화면: 그림·별은 왼쪽, 이름·효과·버튼은 오른쪽 (확인 버튼이 스크롤 없이 보이게)
              if (short)
                Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [portrait, stars],
                    ),
                    const SizedBox(width: Space.m),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: info,
                      ),
                    ),
                  ],
                )
              else ...[
                portrait,
                stars,
                ...info,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 별이 하나씩 커지며 켜진다
class _Stars extends StatelessWidget {
  const _Stars({required this.rarity});
  final int rarity;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < rarity; i++)
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 500 + i * 250),
          curve: Interval(0.4 + i * 0.1, 1, curve: Curves.elasticOut),
          builder: (context, t, _) => Transform.scale(
            scale: t,
            child: Text(
              '★',
              style: Ts.title.copyWith(
                color: CrewRevealCard._gold,
                fontSize: 34,
              ),
            ),
          ),
        ),
    ],
  );
}
