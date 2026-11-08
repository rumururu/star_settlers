import 'package:flutter/material.dart';

import 'common.dart';
import 'game_icons.dart';

/// 일시정지 메뉴 한 칸
class MenuTile {
  const MenuTile(
    this.label,
    this.icon,
    this.onTap, {
    this.badge = 0,
    this.accent,
  });
  final String label;
  final String icon;
  final VoidCallback onTap;

  /// 0보다 크면 모서리에 숫자 배지
  final int badge;

  /// 강조할 칸의 테두리·바탕 색 (상점 등)
  final Color? accent;
}

/// 문구 앞에 붙은 이모지·기호를 뗀다 ("⭐ 상점" → "상점"). 칸에는 게임 아이콘이 따로 붙는다.
String plainLabel(String s) =>
    s.replaceFirst(RegExp(r'^[^\p{L}\p{N}(]+', unicode: true), '').trim();

/// 일시정지 메뉴: 큰 계속하기 → 2열 카드 → 아래 조용한 종료 버튼.
class PauseMenu extends StatelessWidget {
  const PauseMenu({
    super.key,
    required this.title,
    required this.stats,
    required this.resumeLabel,
    required this.onResume,
    required this.tiles,
    required this.quitLabel,
    required this.onQuit,
    required this.onClose,
    this.footer,
    this.banner,
  });

  final String title;
  final String stats;
  final String resumeLabel;
  final VoidCallback onResume;
  final List<MenuTile> tiles;
  final String quitLabel;
  final VoidCallback onQuit;
  final VoidCallback onClose;
  final String? footer;

  /// 통계 아래 작은 카드 (내일 출석 보상 미리보기 등, TASK 004)
  final Widget? banner;

  @override
  Widget build(BuildContext context) => OverlayPanel(
    onClose: onClose,
    maxWidth: 460,
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(Space.l, Space.s, Space.l, Space.l),
      children: [
        Row(
          children: [
            const SizedBox(width: Tap.min),
            Expanded(
              child: Text(
                title,
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: onClose,
            ),
          ],
        ),
        Text(
          stats,
          style: Ts.caption.copyWith(color: Colors.white60),
          textAlign: TextAlign.center,
        ),
        if (banner != null) ...[
          const SizedBox(height: Space.s),
          banner!,
        ],
        const SizedBox(height: Space.l),
        _resume(),
        const SizedBox(height: Space.m),
        LayoutBuilder(
          builder: (context, c) {
            const gap = Space.s;
            final w = (c.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final t in tiles) SizedBox(width: w, child: _tile(t)),
              ],
            );
          },
        ),
        const SizedBox(height: Space.m),
        Center(
          child: TextButton.icon(
            onPressed: onQuit,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white60,
              minimumSize: const Size(Tap.min, Tap.min),
            ),
            icon: const Icon(Icons.logout_rounded, size: IconSz.inline),
            label: Text(
              plainLabel(quitLabel),
              style: Ts.label.copyWith(color: Colors.white60),
            ),
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: Space.s),
          Text(footer!, style: dimStyle, textAlign: TextAlign.center),
        ],
      ],
    ),
  );

  Widget _resume() => Material(
    color: Colors.transparent,
    child: Ink(
      height: Tap.primaryHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x667C4DFF),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onResume,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            const SizedBox(width: Space.xs),
            Flexible(
              child: Text(
                plainLabel(resumeLabel),
                overflow: TextOverflow.ellipsis,
                style: Ts.heading.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _tile(MenuTile t) {
    final accent = t.accent;
    return Material(
      color: Colors.transparent,
      child: Ink(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: accent?.withValues(alpha: .18) ?? const Color(0x14FFFFFF),
          border: Border.all(
            color: accent?.withValues(alpha: .7) ?? const Color(0x337E57C2),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: t.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s),
            child: Row(
              children: [
                Badge(
                  isLabelVisible: t.badge > 0,
                  label: Text('${t.badge}'),
                  child: GameIcon(t.icon, size: 40),
                ),
                const SizedBox(width: Space.s),
                Expanded(
                  child: Text(
                    plainLabel(t.label),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Ts.label.copyWith(color: Colors.white, height: 1.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
