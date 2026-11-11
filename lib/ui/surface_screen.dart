import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/codex.dart' show relicKey, relicSprite;
import '../game/game_telemetry.dart';
import '../game/models.dart';
import '../game/profile.dart';
import '../game/save.dart';
import '../game/surface.dart';
import '../game/world.dart';
import '../l10n/l.dart';
import '../services/app_state.dart';
import '../services/audio.dart';
import 'common.dart';
import 'game_icons.dart';
import 'leaderboard_screen.dart' show groupDigits;
import 'rift_cards.dart' show RiftPanel, plainResume;
import 'world_painter.dart';

/// 착륙 탐사 버튼 아이콘 (assets/icons/act_land.png)
const landIcon = 'act_land';

const _mint = Color(0xFF7CFFB2);
const _amber = Color(0xFFFFD54F);
const _danger = Color(0xFFFF5252);
const _accent = Color(0xFF26A69A);

/// 행성 지표 탐험 화면 (surface-exploration).
/// 소개 → 탐사(기존 [WorldPainter] + 지표 HUD) → 결과. 패널은 한 번에 하나만 뜨는 모달 층이다.
/// 게임 화면에서 행성 곁 「착륙 탐사」로만 들어오므로 메인 월드가 늘 있다 (정산을 바로 넣고 저장한다).
class SurfaceScreen extends StatefulWidget {
  const SurfaceScreen({super.key, required this.mainWorld, required this.planet, this.clock, this.world, this.launched = false});

  final GameWorld mainWorld;
  final Planet planet;

  /// 테스트·렌더 하네스용: 시계, 미리 만든 판, 소개 없이 바로 탐사
  final DateTime Function()? clock;
  final SurfaceWorld? world;
  final bool launched;

  @override
  State<SurfaceScreen> createState() => _SurfaceScreenState();
}

enum _Stage { intro, playing, result }

class _Frame extends ChangeNotifier {
  void tick() => notifyListeners();
}

class _SurfaceScreenState extends State<SurfaceScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  final _frame = _Frame();
  final _input = InputState();
  final _focus = FocusNode();
  Duration _last = Duration.zero;

  late SurfaceWorld _w;
  _Stage _stage = _Stage.intro;
  bool _paused = false;
  bool _confirmLeave = false;
  SurfaceSettlement? _settled;
  bool _settling = false;

  Offset _stick = Offset.zero;
  bool _touchFire = false;
  bool _autoFire = true;

  Profile get _profile => widget.mainWorld.profile;
  DateTime _now() => (widget.clock ?? DateTime.now)();
  SurfaceRecords get _records => SurfaceRecords(_profile.stats, onChanged: () => _profile.dirty = true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _w = widget.world ?? SurfaceWorld(main: widget.mainWorld, planet: widget.planet);
    if (widget.launched) _stage = _Stage.playing;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _frame.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _stage == _Stage.playing && !_w.over) {
      setState(() => _paused = true);
    }
  }

  void _launch() {
    GameTelemetry.emit(TelemetryEvent.surfaceStart, _w.planetKind.index);
    setState(() => _stage = _Stage.playing);
  }

  void _onTick(Duration now) {
    final dt = _last == Duration.zero ? 0.016 : (now - _last).inMicroseconds / 1e6;
    _last = now;
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    bool k(LogicalKeyboardKey a, LogicalKeyboardKey b) => keys.contains(a) || keys.contains(b);
    var kb = Offset(
      (k(LogicalKeyboardKey.keyD, LogicalKeyboardKey.arrowRight) ? 1 : 0) -
          (k(LogicalKeyboardKey.keyA, LogicalKeyboardKey.arrowLeft) ? 1.0 : 0),
      (k(LogicalKeyboardKey.keyS, LogicalKeyboardKey.arrowDown) ? 1 : 0) -
          (k(LogicalKeyboardKey.keyW, LogicalKeyboardKey.arrowUp) ? 1.0 : 0),
    );
    if (kb != Offset.zero) kb = kb / kb.distance;
    _input
      ..move = kb != Offset.zero ? kb : _stick
      ..fire = _touchFire || keys.contains(LogicalKeyboardKey.space) || _autoFire
      ..autoAim = _autoFire
      ..cruise = false;
    _w.paused = _stage != _Stage.playing || _paused;
    _w.update(dt, _input);
    for (final s in _w.sfx) {
      AudioService.instance.play(s);
      if (s == Sfx.hurt || s == Sfx.bigExplode) AppState.haptic();
    }
    _w.sfx.clear();
    if (_w.over && _stage == _Stage.playing && !_settling) _finish();
    _frame.tick();
  }

  Future<void> _finish() async {
    _settling = true;
    final main = widget.mainWorld;
    final s = _w.outcome!.settle(profile: _profile, main: main, now: _now());
    await SaveService.save(main); // 프로필도 같이 저장된다
    AppState.syncWallet();
    if (!mounted) return;
    setState(() {
      _settled = s;
      _stage = _Stage.result;
      _paused = false;
      _confirmLeave = false;
      _settling = false;
    });
  }

  void _return() {
    if (_w.returnToLander()) AppState.haptic();
  }

  void _leave() {
    setState(() {
      _paused = false;
      _confirmLeave = false;
    });
    _w.abandon();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent || _stage != _Stage.playing) return KeyEventResult.ignored;
    final key = e.logicalKey;
    if (key == LogicalKeyboardKey.keyQ) {
      _w.fireMissiles();
    } else if (key == LogicalKeyboardKey.keyF) {
      _w.activateShield();
    } else if (key == LogicalKeyboardKey.shiftLeft || key == LogicalKeyboardKey.shiftRight) {
      _w.boost();
    } else if (key == LogicalKeyboardKey.keyE || key == LogicalKeyboardKey.keyR) {
      _return();
    } else if (key == LogicalKeyboardKey.escape) {
      setState(() => _paused = !_paused);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final zoom = (size.shortestSide / 750).clamp(0.55, 1.1).toDouble();
    return PopScope(
      // 탐사 도중 뒤로 가기는 일시정지 (나가려면 '비상 귀환')
      canPop: _stage != _Stage.playing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _stage == _Stage.playing && !_w.over) setState(() => _paused = true);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
          focusNode: _focus,
          autofocus: true,
          onKeyEvent: _onKey,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: WorldPainter(_w, zoom, repaint: _frame))),
              Positioned.fill(
                child: ListenableBuilder(
                  listenable: _frame,
                  builder: (context, _) => _stage == _Stage.playing ? _hud(size) : const SizedBox.shrink(),
                ),
              ),
              // 모달 층: 한 번에 하나만
              Positioned.fill(child: ListenableBuilder(listenable: _frame, builder: (context, _) => _modal())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modal() {
    switch (_stage) {
      case _Stage.intro:
        return SurfaceIntroPanel(
          world: _w,
          fullLeft: _records.fullRunsLeft(_now()),
          onStart: _launch,
          onExit: () => Navigator.of(context).maybePop(),
        );
      case _Stage.result:
        final s = _settled;
        if (s == null) return const SizedBox.shrink();
        return SurfaceResultPanel(
          outcome: _w.outcome!,
          settlement: s,
          onExit: () => Navigator.of(context).maybePop(),
        );
      case _Stage.playing:
        if (_confirmLeave) {
          return RiftPanel(
            key: const ValueKey('srf-leave'),
            content: [
              Text(keepAll(tr.srf_leaveTitle), style: titleStyle, textAlign: TextAlign.center),
              const SizedBox(height: Space.s),
              Text(keepAll(tr.srf_leaveBody), style: bodyStyle, textAlign: TextAlign.center),
            ],
            actions: _buttons([
              actionBtn(plainResume(tr.u_resume), true, () => setState(() {
                _confirmLeave = false;
                _paused = false;
              }), color: _accent, leadingIcon: Icons.play_arrow_rounded),
              actionBtn(tr.srf_leaveYes, true, _leave, color: const Color(0xFF5A2340), leadingIcon: Icons.logout_rounded),
            ]),
          );
        }
        if (_paused) {
          return RiftPanel(
            key: const ValueKey('srf-pause-panel'),
            content: [
              Text(tr.u_paused, style: titleStyle, textAlign: TextAlign.center),
              const SizedBox(height: Space.s),
              Text(keepAll(tr.srf_leaveBody), style: dimStyle, textAlign: TextAlign.center),
            ],
            actions: _buttons([
              actionBtn(plainResume(tr.u_resume), true, () => setState(() => _paused = false),
                  color: _accent, leadingIcon: Icons.play_arrow_rounded),
              actionBtn(tr.srf_leaveYes, true, () => setState(() => _confirmLeave = true),
                  color: const Color(0xFF5A2340), leadingIcon: Icons.logout_rounded),
            ]),
          );
        }
        return const SizedBox.shrink();
    }
  }

  // ---------------- HUD ----------------
  static bool isShort(Size s) => s.width > s.height && s.height < Layout.shortHeight;

  Widget _hud(Size size) {
    final short = isShort(size);
    final status = _status();
    final ret = _w.atLander && !_w.over ? _returnButton() : null;
    final top = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _info(),
        const SizedBox(width: Space.s),
        Expanded(child: short && status != null ? Center(child: status) : const SizedBox.shrink()),
        const SizedBox(width: Space.s),
        _pauseButton(),
      ],
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Space.s),
        child: Column(
          children: [
            top,
            if (!short && status != null) ...[const SizedBox(height: Space.s), status],
            const Spacer(),
            // 세로 화면: 귀환 버튼은 조이스틱·전투 버튼 줄 위 가운데
            if (!short && ret != null) ...[Center(child: ret), const SizedBox(height: Space.m)],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                KeyedSubtree(key: const ValueKey('srf-joystick'), child: _joystick()),
                // 가로 화면: 조이스틱과 전투 버튼 사이
                Expanded(child: short && ret != null ? Center(child: ret) : const SizedBox.shrink()),
                KeyedSubtree(key: const ValueKey('srf-combat'), child: _combat()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meter(double f, Color color, {double width = 130}) => SizedBox(
    width: width,
    height: 10,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: LinearProgressIndicator(value: f.clamp(0.0, 1.0), backgroundColor: Colors.black45, color: color),
    ),
  );

  /// 왼쪽 위: 체력·산소 막대, 남은 지점, 이번 판 전리품
  Widget _info() {
    final p = _w.player;
    final hp = (p.hp / _w.playerMaxHp).clamp(0.0, 1.0);
    final o2 = _w.oxygen / SurfaceRules.oxygenSeconds;
    final low = _w.oxygen <= SurfaceRules.oxygenWarn;
    final blink = low && (_w.totalTime * 3).floor().isEven;
    final o2Color = low ? (blink ? _danger : const Color(0xFFFF8A80)) : const Color(0xFF4FC3F7);
    return ConstrainedBox(
      key: const ValueKey('srf-info'),
      constraints: const BoxConstraints(maxWidth: 230),
      child: glass(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 34, child: Text('HP', style: Ts.caption)),
              _meter(hp, hp > 0.35 ? const Color(0xFF66BB6A) : _danger),
            ]),
            const SizedBox(height: Space.xs),
            Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 34,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(tr.srf_oxygen, style: Ts.caption.copyWith(color: o2Color)),
                ),
              ),
              _meter(o2, o2Color),
              const SizedBox(width: Space.xs),
              Text('${_w.oxygen.ceil()}', key: const ValueKey('srf-oxygen'), style: Ts.caption.copyWith(color: o2Color)),
            ]),
            const SizedBox(height: Space.xs),
            Text(tr.srf_sitesLeft(_w.sitesLeft), style: Ts.caption.copyWith(color: Colors.white)),
            Wrap(spacing: Space.s, children: [
              iconValue('credits', groupDigits(_w.lootCredits.round()), size: 16, style: Ts.caption.copyWith(color: _amber)),
              iconValue('ore', groupDigits(_w.lootOre.round()), size: 16, style: Ts.caption.copyWith(color: const Color(0xFF4DD0E1))),
            ]),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.s),
      ),
    );
  }

  /// 대사 한 줄 (산소 경고 등)
  Widget? _status() {
    final d = _w.dialogs.lastOrNull;
    if (d == null) return null;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: glass(
        Text(keepAll(d.text), key: const ValueKey('srf-status'), style: Ts.caption.copyWith(color: const Color(0xFFFF8A80)), textAlign: TextAlign.center),
        padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.s),
      ),
    );
  }

  Widget _returnButton() => KeyedSubtree(
    key: const ValueKey('srf-return'),
    child: actionBtn(tr.srf_return, true, _return, color: const Color(0xFF2E7D32), leadingIcon: Icons.rocket_launch, iconSize: IconSz.button),
  );

  Widget _pauseButton() => Material(
    key: const ValueKey('srf-pause'),
    color: const Color(0xCC0D0B26),
    shape: const CircleBorder(),
    child: IconButton(
      icon: const Icon(Icons.pause, color: Colors.white),
      constraints: const BoxConstraints(minWidth: Tap.min, minHeight: Tap.min),
      onPressed: () => setState(() => _paused = true),
    ),
  );

  Widget _joystick() {
    const radius = 62.0;
    void upd(Offset local) => _stick = ((local - const Offset(radius, radius)) / (radius - 20)).clampLength(1);
    return Listener(
      onPointerDown: (e) => upd(e.localPosition),
      onPointerMove: (e) => upd(e.localPosition),
      onPointerUp: (_) => _stick = Offset.zero,
      onPointerCancel: (_) => _stick = Offset.zero,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Center(
          child: Transform.translate(
            offset: _stick * (radius - 20),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _accent.withValues(alpha: 0.75)),
            ),
          ),
        ),
      ),
    );
  }

  /// 자동 사격 토글 + 미사일·부스트·방어막·발사 (균열 런·메인 게임 HUD와 같은 배치)
  Widget _combat() {
    final p = _w.player;
    final auto = GestureDetector(
      onTap: () => setState(() => _autoFire = !_autoFire),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Tap.min, minWidth: Tap.min),
        child: glass(
          iconValue('cmb_auto', _autoFire ? tr.u_autoFireOn : tr.u_autoFireOff,
              size: 22, style: Ts.caption.copyWith(color: _autoFire ? _mint : Colors.white60)),
          padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: Space.m),
        ),
      ),
    );
    final fire = Listener(
      onPointerDown: (_) => _touchFire = true,
      onPointerUp: (_) => _touchFire = false,
      onPointerCancel: (_) => _touchFire = false,
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (_touchFire ? const Color(0xFFFF5252) : const Color(0xFFE53935)).withValues(alpha: 0.55),
          border: Border.all(color: Colors.white38, width: 2),
        ),
        child: Center(child: Text(tr.u_fire, style: Ts.heading)),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        auto,
        const SizedBox(height: Space.s),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              _skill('cmb_missile', p.missileCooldown, _w.missileCooldownMax, _w.fireMissiles, _w.level(UpgradeKind.missile) > 0),
              const SizedBox(height: Space.m),
              _skill('cmb_boost', p.boostCooldown, _w.boostCooldownMax, _w.boost, true),
            ]),
            const SizedBox(width: Space.m),
            Column(mainAxisSize: MainAxisSize.min, children: [
              _skill('cmb_shield', p.shieldCooldown, _w.shieldCooldownMax, _w.activateShield, _w.level(UpgradeKind.shield) > 0),
              const SizedBox(height: Space.m),
              fire,
            ]),
          ],
        ),
      ],
    );
  }

  Widget _skill(String icon, double cd, double cdMax, bool Function() use, bool owned) {
    final f = cdMax <= 0 ? 0.0 : (cd / cdMax).clamp(0.0, 1.0);
    return Listener(
      onPointerDown: (_) {
        if (use()) AppState.haptic();
      },
      child: SizedBox(
        width: 56,
        height: 56,
        child: CustomPaint(
          painter: _CooldownRing(f),
          child: Center(child: GameIcon(icon, size: 36, opacity: owned ? 1 : 0.35)),
        ),
      ),
    );
  }
}

Widget _buttons(List<Widget> buttons) =>
    Wrap(alignment: WrapAlignment.center, spacing: Space.s, runSpacing: Space.s, children: buttons);

class _CooldownRing extends CustomPainter {
  _CooldownRing(this.f);
  final double f;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0x660D0B26));
    canvas.drawCircle(c, r - 1, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white30);
    if (f > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi * f, true, Paint()..color = const Color(0x99000000));
    }
  }

  @override
  bool shouldRepaint(_CooldownRing old) => old.f != f;
}

/// 영구 발견 배지 (소개·결과·식민지 패널 공용): 이름 + 효과 한 줄
class SurfaceDiscoveryBadge extends StatelessWidget {
  const SurfaceDiscoveryBadge(this.kind, {super.key, this.fresh = false, this.compact = false});

  /// vein / nest / surveyed
  final String kind;
  final bool fresh;

  /// 이름만 (효과 한 줄 없이)
  final bool compact;

  static IconData iconOf(String kind) => switch (kind) {
    'vein' => Icons.diamond_outlined,
    'nest' => Icons.bug_report_outlined,
    _ => Icons.explore_outlined,
  };

  static Color colorOf(String kind) => switch (kind) {
    'vein' => const Color(0xFF64FFDA),
    'nest' => const Color(0xFFFF8A80),
    _ => _amber,
  };

  @override
  Widget build(BuildContext context) {
    final c = colorOf(kind);
    return Container(
      key: ValueKey('srf-disc-$kind'),
      padding: const EdgeInsets.symmetric(horizontal: Space.s, vertical: Space.xs),
      decoration: BoxDecoration(
        color: c.withValues(alpha: fresh ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: fresh ? 1 : 0.6), width: fresh ? 2 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconOf(kind), size: IconSz.inline, color: c),
          const SizedBox(width: Space.xs),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(keepAll(tr.srf_disc(kind)), style: Ts.caption.copyWith(color: c, fontWeight: FontWeight.bold)),
                if (!compact) Text(keepAll(tr.srf_discEffect(kind)), style: Ts.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 행성 [p]의 영구 발견 종류 목록
List<String> planetDiscoveries(Planet p) => [if (p.vein) 'vein', if (p.nest) 'nest', if (p.surveyed) 'surveyed'];

/// 착륙 전 소개: 행성 이름·종류, 이미 찾은 발견, 오늘 남은 온전 보상, 규칙 세 줄
class SurfaceIntroPanel extends StatelessWidget {
  const SurfaceIntroPanel({super.key, required this.world, required this.fullLeft, required this.onStart, required this.onExit});
  final SurfaceWorld world;
  final int fullLeft;
  final VoidCallback onStart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final found = [if (world.hadVein) 'vein', if (world.hadNest) 'nest', if (world.hadSurveyed) 'surveyed'];
    Widget rule(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: Space.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: IconSz.inline, color: _mint),
          const SizedBox(width: Space.s),
          Expanded(child: Text(keepAll(text), style: bodyStyle)),
        ],
      ),
    );
    return RiftPanel(
      key: const ValueKey('srf-intro'),
      content: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GameIcon(landIcon, size: IconSz.row),
            const SizedBox(width: Space.s),
            SizedBox(
              width: IconSz.row,
              height: IconSz.row,
              child: Image.asset('assets/sprites/planet_${world.planetKind.name}.png',
                  errorBuilder: (_, _, _) => const SizedBox.shrink()),
            ),
          ],
        ),
        Text(keepAll(tr.srf_introTitle(world.planetName)), style: Ts.title.copyWith(color: _mint), textAlign: TextAlign.center),
        Text(_kindLabel(world.planetKind), style: Ts.caption, textAlign: TextAlign.center),
        const SizedBox(height: Space.m),
        if (found.isEmpty)
          Text(keepAll(tr.srf_noDisc), style: dimStyle, textAlign: TextAlign.center)
        else
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.s,
            runSpacing: Space.s,
            children: [for (final k in found) SurfaceDiscoveryBadge(k)],
          ),
        const SizedBox(height: Space.m),
        rule(Icons.travel_explore, tr.srf_rule1),
        rule(Icons.air, tr.srf_rule2),
        rule(Icons.warning_amber_rounded, tr.srf_rule3),
        const SizedBox(height: Space.m),
        Text(
          keepAll(fullLeft > 0 ? tr.srf_fullLeft(fullLeft, SurfaceRules.fullRunsPerDay) : tr.srf_reduced),
          key: const ValueKey('srf-full-left'),
          style: fullLeft > 0 ? Ts.label.copyWith(color: _amber) : dimStyle,
          textAlign: TextAlign.center,
        ),
      ],
      actions: _buttons([
        actionBtn(tr.srf_launch, true, onStart, color: _accent, icon: landIcon),
        actionBtn(tr.u_close, true, onExit, color: const Color(0xFF2A2357)),
      ]),
    );
  }
}

String _kindLabel(PlanetKind k) => switch (k) {
  PlanetKind.garden => tr.g_planetKindGarden,
  PlanetKind.desert => tr.g_planetKindDesert,
  PlanetKind.ice => tr.g_planetKindIce,
  PlanetKind.lava => tr.g_planetKindLava,
  PlanetKind.gas => tr.g_planetKindGas,
};

/// 결과: 끝난 이유, 받은 전리품(남긴 비율), 새 발견 배지, 새 유물 카드, 오늘 남은 온전 보상
class SurfaceResultPanel extends StatelessWidget {
  const SurfaceResultPanel({super.key, required this.outcome, required this.settlement, required this.onExit});
  final SurfaceOutcome outcome;
  final SurfaceSettlement settlement;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final s = settlement;
    final good = outcome.returned;
    final news = [if (s.newVein) 'vein', if (s.newNest) 'nest', if (s.newSurveyed) 'surveyed'];
    return RiftPanel(
      key: const ValueKey('srf-result'),
      content: [
        Text(keepAll(tr.srf_resultTitle(outcome.reason.name)),
            style: Ts.title.copyWith(color: good ? _mint : const Color(0xFFFF8A80)), textAlign: TextAlign.center),
        const SizedBox(height: Space.xs),
        Text(tr.srf_sitesDone(outcome.sitesDone, outcome.sitesTotal), style: Ts.heading, textAlign: TextAlign.center),
        Text(tr.srf_kept((s.keepRatio * 100).round()),
            style: Ts.label.copyWith(color: good ? _mint : const Color(0xFFFFAB91)), textAlign: TextAlign.center),
        const SizedBox(height: Space.s),
        Wrap(
          key: const ValueKey('srf-rewards'),
          alignment: WrapAlignment.center,
          spacing: Space.l,
          runSpacing: Space.xs,
          children: [
            iconValue('credits', '+${groupDigits(s.credits)}', size: 24, style: Ts.heading),
            iconValue('ore', '+${groupDigits(s.ore)}', size: 24, style: Ts.heading),
            if (s.gems > 0) iconValue('gem', '+${s.gems}', size: 24, style: Ts.heading),
          ],
        ),
        if (!s.full) Text(keepAll(tr.srf_reduced), style: dimStyle, textAlign: TextAlign.center),
        if (news.isNotEmpty) ...[
          const SizedBox(height: Space.m),
          Text(tr.srf_newDisc, style: sectionStyle, textAlign: TextAlign.center),
          const SizedBox(height: Space.xs),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.s,
            runSpacing: Space.s,
            children: [for (final k in news) SurfaceDiscoveryBadge(k, fresh: true)],
          ),
        ],
        if (s.relics.isNotEmpty) ...[
          const SizedBox(height: Space.m),
          Text(tr.srf_newRelic, style: sectionStyle, textAlign: TextAlign.center),
          const SizedBox(height: Space.xs),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.s,
            runSpacing: Space.s,
            children: [for (final id in s.relics) _RelicCard(id)],
          ),
        ],
        const SizedBox(height: Space.m),
        Text(
          keepAll(tr.srf_fullLeft(s.fullRunsLeft, SurfaceRules.fullRunsPerDay)),
          style: dimStyle,
          textAlign: TextAlign.center,
        ),
      ],
      actions: _buttons([
        actionBtn(tr.srf_back, true, onExit, color: _accent, leadingIcon: Icons.rocket_launch),
      ]),
    );
  }
}

class _RelicCard extends StatelessWidget {
  const _RelicCard(this.id);
  final String id;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('srf-relic-$id'),
    width: 150,
    padding: const EdgeInsets.all(Space.s),
    decoration: BoxDecoration(
      color: const Color(0xFF26215C),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _amber),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: IconSz.hero,
          height: IconSz.hero,
          child: Image.asset('assets/sprites/${relicSprite(id)}.png',
              errorBuilder: (_, _, _) => const Icon(Icons.auto_awesome, color: _amber, size: IconSz.button)),
        ),
        const SizedBox(height: Space.xs),
        // 긴 한 단어 이름(독일어 'Gravitationskompass')은 줄이지 않으면 잘린다
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(keepAll(tr.srf_relicName(relicKey(id))), style: Ts.body.copyWith(color: _amber), textAlign: TextAlign.center),
        ),
        Text(keepAll(tr.srf_relicDesc(relicKey(id))), style: Ts.caption, textAlign: TextAlign.center),
      ],
    ),
  );
}
