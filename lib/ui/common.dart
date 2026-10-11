import 'package:flutter/material.dart';

import '../game/models.dart';
import '../l10n/l.dart';
import '../services/ads.dart' show AdResult;
import 'game_icons.dart';
import 'tokens.dart';

export 'tokens.dart';

final navigatorKey = GlobalKey<NavigatorState>();

const kPanelColor = Color(0xF0151236);
const kAccent = Color(0xFF7E57C2);
const kSky = Color(0xFF8AD8FF);

/// U+2060 WORD JOINER: 이 자리에서는 줄을 바꾸지 않는다 (보이지 않는다)
const wordJoiner = '\u2060';

// 한글 음절끼리, 또는 한글과 붙은 숫자·영문 사이 (어절 안쪽)
final _hangulInWord = RegExp(r'(?<=[가-힣])(?=[가-힣0-9A-Za-z])|(?<=[0-9A-Za-z])(?=[가-힣])');

/// 한국어 문장을 어절 단위로만 줄바꿈 (CSS `word-break: keep-all` 대용).
/// Flutter는 한글을 글자마다 끊을 수 있어 "돼/요", "할까/요?"처럼 단어가 갈라진다.
/// 어절 안의 글자 사이에 [wordJoiner]를 넣어 띄어쓰기에서만 줄이 바뀌게 한다.
/// 현재 언어가 한국어일 때만 바꾼다 ([ko]는 테스트용).
String keepAll(String s, {bool? ko}) {
  if (!(ko ?? Lang.isKo) || s.isEmpty) return s;
  return s.replaceAll(_hangulInWord, wordJoiner);
}

/// 좁은 칸(아이콘 타일 등)의 짧은 설명. 띄어쓰기와 '·' 뒤에서만 줄을 바꾸고,
/// 한 단어가 폭보다 길면 그 줄만 글자를 줄인다 (단어 중간에서 끊지 않는다).
/// 그냥 Text면 "income·buildings"가 "income·bui/ldings"처럼 단어 중간에서 끊긴다.
Widget fitLines(String text, TextStyle style, double width, {TextAlign align = TextAlign.center}) =>
    Builder(builder: (context) {
      final scaler = MediaQuery.textScalerOf(context);
      double measure(String s) {
        final tp = TextPainter(
            text: TextSpan(text: s, style: style), textDirection: TextDirection.ltr, textScaler: scaler)
          ..layout();
        final w = tp.width;
        tp.dispose();
        return w;
      }

      final lines = <String>[];
      for (final line in keepAll(text).split('\n')) {
        // 끊어도 되는 자리 뒤에서 나눈 조각 ("income·", "buildings↑" / "safe ", "inside")
        final tokens = RegExp(r'[^ ·]+[ ·]*|[ ·]+').allMatches(line).map((m) => m[0]!).toList();
        var cur = '';
        for (final t in tokens) {
          if (cur.isNotEmpty && measure((cur + t).trimRight()) > width) {
            lines.add(cur.trimRight());
            cur = t;
          } else {
            cur += t;
          }
        }
        lines.add(cur.trimRight());
      }
      return Column(mainAxisSize: MainAxisSize.min, children: [
        for (final l in lines)
          SizedBox(
            width: width,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(l, maxLines: 1, softWrap: false, textAlign: align, style: style),
            ),
          ),
      ]);
    });

/// 글 속 '⭐'(젬)을 HUD와 같은 분홍 젬 아이콘으로 그린다 (⭐ 이모지는 노란 별이라 HUD와 달라 보였다).
/// 아이콘과 뒤의 숫자 사이에서는 줄을 바꾸지 않는다.
Widget gemText(String s, {TextStyle? style, TextAlign? textAlign, double? iconSize}) {
  if (!s.contains('⭐')) return Text(s, style: style, textAlign: textAlign);
  final size = iconSize ?? (style?.fontSize ?? Ts.body.fontSize!) * 1.2;
  final parts = s.split('⭐');
  return Text.rich(
    TextSpan(children: [
      for (var i = 0; i < parts.length; i++) ...[
        if (i > 0) WidgetSpan(alignment: PlaceholderAlignment.middle, child: GameIcon('gem', size: size)),
        if (parts[i].isNotEmpty) TextSpan(text: i > 0 ? '$wordJoiner${parts[i]}' : parts[i]),
      ],
    ]),
    style: style,
    textAlign: textAlign,
  );
}

String costText(Cost c) => c.$2 > 0 ? '💰${c.$1} 💎${c.$2}' : '💰${c.$1}';

String compact(num v) {
  if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
  if (v >= 1e4) return '${(v / 1e3).toStringAsFixed(1)}K';
  return v.floor().toString();
}

Widget glass(Widget child, {EdgeInsets? padding}) => Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC0D0B26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x557E57C2)),
      ),
      child: child,
    );

/// 크레딧이 모자랄 때 젬으로 채우는 연결. 게임 화면이 [gemsFor]/[topUp]/[openShop]을 넣는다.
/// 비용([cost])이 붙은 버튼은 크레딧만 모자라면 눌리고, 누르면 "⭐N으로 채울까요?"를 묻는다.
abstract final class GemTopUp {
  /// 비용을 채우는 데 필요한 젬: 0 = 이미 살 수 있음, null = 젬으로 못 채움(광석 부족 등)
  static int? Function(Cost cost)? gemsFor;
  static bool Function(Cost cost)? topUp;
  static int Function()? gems;
  static int Function()? credits;
  static VoidCallback? openShop;

  /// 묻는 창이 떠 있는 동안 true (게임 화면이 이때 게임을 멈춘다)
  static bool asking = false;

  /// 부족하면 물어보고 채운다. 진행해도 되면 true.
  static Future<bool> ensure(Cost cost) async {
    final need = gemsFor?.call(cost);
    if (need == null || need == 0) return need == 0;
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return false;
    asking = true;
    try {
      return await _ask(ctx, cost, need);
    } finally {
      asking = false;
    }
  }

  static Future<bool> _ask(BuildContext ctx, Cost cost, int need) async {
    final short = cost.$1 - (credits?.call() ?? 0);
    if ((gems?.call() ?? 0) < need) {
      final go = await confirmDialog(ctx, tr.u_topUpTitle, tr.u_topUpNoGems(need), ok: tr.u_goShop);
      if (go) openShop?.call();
      return false;
    }
    final ok = await confirmDialog(ctx, tr.u_topUpTitle, tr.u_topUpBody(short, need), ok: tr.u_topUpOk);
    return ok && (topUp?.call(cost) ?? false);
  }
}

/// 모든 버튼은 이걸 쓴다. 글자 크기는 [Ts.label] 고정, 최소 크기 [Tap.min].
/// [icon]은 assets/icons 이름, [cost]가 있으면 라벨 뒤에 아이콘 비용을 붙인다.
/// [primary]면 [Tap.primaryWidth]×[Tap.primaryHeight] 고정 크기 (글자 길이와 무관).
Widget actionBtn(String label, bool enabled, VoidCallback? onTap,
    {Color color = const Color(0xFF5E35B1),
    String? icon,
    Cost? cost,
    double iconSize = IconSz.button,
    bool primary = false,
    IconData? leadingIcon}) {
  // 크레딧만 모자란 비용 버튼: 눌러서 젬으로 채우고 진행할 수 있게
  final need = cost == null ? 0 : (GemTopUp.gemsFor?.call(cost) ?? 0);
  if (!enabled && onTap != null && cost != null && need > 0) {
    enabled = true;
    final run = onTap;
    onTap = () async {
      if (await GemTopUp.ensure(cost)) run();
    };
    color = Color.lerp(color, const Color(0xFF37305A), 0.55)!;
  }
  return _actionBtn(label, enabled, onTap,
      color: color, icon: icon, cost: cost, iconSize: iconSize, primary: primary, leadingIcon: leadingIcon,
      gemTag: need > 0 ? need : null);
}

Widget _actionBtn(String label, bool enabled, VoidCallback? onTap,
        {required Color color,
        String? icon,
        Cost? cost,
        required double iconSize,
        required bool primary,
        IconData? leadingIcon,
        int? gemTag}) =>
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF37305A),
        disabledForegroundColor: Colors.white54,
        minimumSize: primary
            ? const Size(Tap.primaryWidth, Tap.primaryHeight)
            : const Size(Tap.min, Tap.min),
        maximumSize: primary ? const Size(Tap.primaryWidth, Tap.primaryHeight) : Size.infinite,
        padding: const EdgeInsets.symmetric(horizontal: Space.l, vertical: Space.s),
        textStyle: Ts.label,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(primary ? 28 : 14)),
      ),
      onPressed: enabled ? onTap : null,
      child: icon == null && cost == null && leadingIcon == null
          ? gemText(keepAll(label), style: Ts.label.copyWith(color: null))
          : Opacity(
              opacity: enabled ? 1 : 0.6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) Icon(leadingIcon, size: iconSize),
                  if (icon != null) GameIcon(icon, size: iconSize),
                  if ((icon != null || leadingIcon != null) && label.isNotEmpty) const SizedBox(width: Space.s),
                  if (label.isNotEmpty) gemText(keepAll(label), style: Ts.label.copyWith(color: null)),
                  if (cost != null) ...[
                    if (label.isNotEmpty || icon != null) const SizedBox(width: Space.s),
                    costView(cost, style: Ts.label),
                  ],
                  // 크레딧이 모자라면 채우는 데 드는 젬을 함께 보여준다
                  if (gemTag != null) ...[
                    const SizedBox(width: Space.xs),
                    iconValue('gem', '$gemTag', size: 16, style: Ts.caption.copyWith(color: const Color(0xFFFF80AB))),
                  ],
                ],
              ),
            ),
    );

/// 프리미엄 함선 표시 칩
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF6F00)]),
          borderRadius: BorderRadius.circular(Space.s),
        ),
        child: Text(tr.u_premium, style: Ts.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      );
}

// 자주 쓰는 역할별 스타일 (토큰 별칭)
const titleStyle = Ts.headingBold;
const bodyStyle = Ts.body;
const dimStyle = Ts.bodyDim;
const sectionStyle = Ts.section;

/// 반투명 배경 위 중앙 패널
class OverlayPanel extends StatelessWidget {
  const OverlayPanel({super.key, required this.child, required this.onClose, this.maxWidth = 560});
  final Widget child;
  final VoidCallback onClose;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(12),
              constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 640),
              decoration: BoxDecoration(
                color: kPanelColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kAccent),
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          ),
        ),
      );
}

/// 넓은 화면(iPad·태블릿 가로)에서 화면 내용이 끝까지 늘어나지 않게 가운데 [Layout.contentMaxWidth] 폭으로 제한
Widget contentWidth(Widget child, {double maxWidth = Layout.contentMaxWidth}) => Center(
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
    );

/// 보상형 광고가 보상 없이 끝났을 때의 안내 (안내가 필요 없으면 null).
/// 광고가 준비 안 됐을 때만 "불러오는 중", 중간에 닫았으면 "끝까지 봐야 보상".
String? adFailMessage(AdResult r, {bool retry = false}) => switch (r) {
      AdResult.notReady => retry ? tr.u_adLoadingRetry : tr.m_adLoading,
      AdResult.closedEarly => tr.m_adWatchToEnd,
      AdResult.rewarded || AdResult.cancelled => null,
    };

/// 확인 다이얼로그
Future<bool> confirmDialog(BuildContext context, String title, String body,
    {String? ok, String? cancel}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: kPanelColor,
      title: Text(keepAll(title)),
      content: gemText(keepAll(body)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(cancel ?? tr.u_cancel)),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(ok ?? tr.u_ok)),
      ],
    ),
  );
  return r ?? false;
}

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(keepAll(msg)), duration: const Duration(seconds: 2)));
}
