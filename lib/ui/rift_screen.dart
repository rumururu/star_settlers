import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/game_telemetry.dart';
import '../game/models.dart';
import '../game/profile.dart';
import '../game/rift.dart';
import '../game/save.dart';
import '../game/world.dart';
import '../l10n/l.dart';
import '../services/app_state.dart';
import '../services/audio.dart';
import 'common.dart';
import 'game_icons.dart';
import 'leaderboard_screen.dart' show groupDigits;
import 'rift_cards.dart';
import 'world_painter.dart';

/// 균열 런 화면 (TASK 005).
/// 소개 → 전투(기존 [WorldPainter] + 런 HUD) ⇄ 카드 고르기 → 결과. 모든 패널은 한 번에 하나만 뜨는 모달 층이다.
///
/// [mainWorld]: 게임 중 일시정지 메뉴에서 들어오면 지금 월드(보상을 바로 넣고, 게임 화면이 저장한다).
/// 타이틀에서 들어오면 null — 결과 때 세이브를 읽어 보상을 넣고 저장한다.
class RiftScreen extends StatefulWidget {
  const RiftScreen({super.key, this.mainWorld, this.plan, this.clock, this.world, this.launched = false});

  final GameWorld? mainWorld;

  /// 테스트·렌더 하네스용: 정해진 날의 균열·시계, 미리 만든 런, 소개 없이 바로 전투
  final RiftPlan? plan;
  final DateTime Function()? clock;
  final RiftWorld? world;
  final bool launched;

  @override
  State<RiftScreen> createState() => _RiftScreenState();
}

enum _Stage { intro, playing, result }

class _Frame extends ChangeNotifier {
  void tick() => notifyListeners();
}

class _RiftScreenState extends State<RiftScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  final _frame = _Frame();
  final _input = InputState();
  final _focus = FocusNode();
  Duration _last = Duration.zero;

  late RiftWorld _w;
  _Stage _stage = _Stage.intro;
  bool _paused = false;
  RiftSettlement? _settled;
  bool _settling = false;

  Offset _stick = Offset.zero;
  bool _touchFire = false;
  bool _autoFire = true;

  Profile get _profile => AppState.profile;
  DateTime _now() => (widget.clock ?? DateTime.now)();
  RiftRecords get _records => RiftRecords(_profile.stats, onChanged: () => _profile.dirty = true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _w = widget.world ?? _newWorld();
    if (widget.launched) _stage = _Stage.playing;
    _ticker = createTicker(_onTick)..start();
  }

  RiftWorld _newWorld() =>
      RiftWorld(plan: widget.plan ?? RiftPlan.today(_now()), mainProfile: _profile);

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
    GameTelemetry.emit(TelemetryEvent.riftStart);
    setState(() => _stage = _Stage.playing);
  }

  void _again() {
    setState(() {
      _w = _newWorld();
      _settled = null;
      _paused = false;
      _stick = Offset.zero;
      _touchFire = false;
    });
    _launch();
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
    final outcome = _w.outcome!;
    final now = _now();
    final main = widget.mainWorld ?? await SaveService.load(_profile);
    final s = outcome.settle(profile: _profile, main: main, now: now);
    if (main != null) {
      await SaveService.save(main); // 프로필도 같이 저장된다
    } else {
      await SaveService.saveProfile(_profile);
    }
    AppState.syncWallet();
    // 순위표에 참여 중이면 이번 주 균열 최고 기록을 보낸다 (기다리지 않고 실패도 무시)
    final lb = AppState.leaderboard;
    if (lb.configured && lb.optedIn) {
      unawaited(lb
          .submitRiftWeekly(_records)
          .then((_) => SaveService.saveProfile(_profile))
          .catchError((Object _) {}));
    }
    if (!mounted) return;
    setState(() {
      _settled = s;
      _stage = _Stage.result;
      _settling = false;
    });
  }

  void _giveUp() {
    setState(() => _paused = false);
    _w.giveUp();
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
    } else if (key == LogicalKeyboardKey.escape) {
      setState(() => _paused = !_paused);
    } else if (_w.phase == RiftPhase.choosing &&
        (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.digit3)) {
      final i = key == LogicalKeyboardKey.digit1 ? 0 : (key == LogicalKeyboardKey.digit2 ? 1 : 2);
      if (i < _w.offers.length) _w.chooseCard(_w.offers[i]);
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
      // 런 도중 뒤로 가기는 일시정지 (나가려면 '포기하고 나가기')
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
              Positioned.fill(child: CustomPaint(painter: RiftArenaPainter(_w, zoom, repaint: _frame))),
              Positioned.fill(
                child: ListenableBuilder(
                  listenable: _frame,
                  builder: (context, _) => _stage == _Stage.playing ? _hud(size) : const SizedBox.shrink(),
                ),
              ),
              // 모달 층: 한 번에 하나만
              Positioned.fill(
                child: ListenableBuilder(listenable: _frame, builder: (context, _) => _modal()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modal() {
    switch (_stage) {
      case _Stage.intro:
        return RiftIntroPanel(
          records: _records,
          now: _now(),
          onStart: _launch,
          onExit: () => Navigator.of(context).maybePop(),
        );
      case _Stage.result:
        final s = _settled;
        if (s == null) return const SizedBox.shrink();
        return RiftResultPanel(
          outcome: _w.outcome!,
          settlement: s,
          bestWave: _records.bestWave,
          onAgain: _again,
          onExit: () => Navigator.of(context).maybePop(),
        );
      case _Stage.playing:
        if (_paused) {
          return RiftPausePanel(onResume: () => setState(() => _paused = false), onGiveUp: _giveUp);
        }
        if (_w.phase == RiftPhase.choosing) {
          return RiftCardPicker(
            wave: _w.wave,
            offers: _w.offers,
            loadout: _w.loadout,
            onPick: (c) {
              if (_w.chooseCard(c)) AppState.haptic();
              _frame.tick();
            },
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
    final top = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _info(),
        const SizedBox(width: Space.s),
        Expanded(
          child: short && status != null ? Center(child: status) : const SizedBox.shrink(),
        ),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                KeyedSubtree(key: const ValueKey('rift-joystick'), child: _joystick()),
                const Spacer(),
                KeyedSubtree(key: const ValueKey('rift-combat'), child: _combat()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info() {
    final p = _w.player;
    final f = (p.hp / _w.playerMaxHp).clamp(0.0, 1.0);
    return ConstrainedBox(
      key: const ValueKey('rift-info'),
      constraints: const BoxConstraints(maxWidth: 200),
      child: glass(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr.rift_wave(_w.wave, RiftPlan.waveCount),
                style: Ts.label.copyWith(color: const Color(0xFFE1BEE7), fontWeight: FontWeight.bold)),
            Text(tr.rift_score(groupDigits(_w.score)), style: Ts.caption.copyWith(color: Colors.white)),
            const SizedBox(height: Space.xs),
            SizedBox(
              width: 120,
              height: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: f,
                  backgroundColor: Colors.black45,
                  color: f > 0.35 ? const Color(0xFF66BB6A) : const Color(0xFFFF5252),
                ),
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.s),
      ),
    );
  }

  /// 파도 상태 한 줄: 카운트다운 / 남은 적 / 붕괴
  Widget? _status() {
    final String text;
    Color color = Colors.white;
    switch (_w.phase) {
      case RiftPhase.countdown:
        final s = max(1, _w.phaseTimer.ceil());
        text = _w.currentWave.boss ? tr.rift_bossIncoming(s) : tr.rift_incoming(_w.wave, s);
        color = _w.currentWave.boss ? const Color(0xFFFF8A80) : const Color(0xFFE1BEE7);
      case RiftPhase.fighting:
        if (_w.collapsing) {
          text = tr.rift_collapse;
          color = const Color(0xFFFFAB40);
        } else {
          text = tr.rift_enemiesLeft(_w.enemiesLeft);
        }
      case RiftPhase.choosing:
      case RiftPhase.done:
        return null;
    }
    return glass(
      Text(keepAll(text), key: const ValueKey('rift-status'), style: Ts.label.copyWith(color: color), textAlign: TextAlign.center),
      padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.s),
    );
  }

  Widget _pauseButton() => Material(
        key: const ValueKey('rift-pause'),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB388FF).withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 자동 사격 토글 + 미사일·부스트·방어막·발사 (메인 게임 HUD와 같은 배치)
  Widget _combat() {
    final p = _w.player;
    final auto = GestureDetector(
      onTap: () => setState(() => _autoFire = !_autoFire),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Tap.min, minWidth: Tap.min),
        child: glass(
          iconValue('cmb_auto', _autoFire ? tr.u_autoFireOn : tr.u_autoFireOff,
              size: 22, style: Ts.caption.copyWith(color: _autoFire ? const Color(0xFF7CFFB2) : Colors.white60)),
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
              _skill('cmb_missile', p.missileCooldown, _w.missileCooldownMax, _w.fireMissiles),
              const SizedBox(height: Space.m),
              _skill('cmb_boost', p.boostCooldown, _w.boostCooldownMax, _w.boost),
            ]),
            const SizedBox(width: Space.m),
            Column(mainAxisSize: MainAxisSize.min, children: [
              _skill('cmb_shield', p.shieldCooldown, _w.shieldCooldownMax, _w.activateShield),
              const SizedBox(height: Space.m),
              fire,
            ]),
          ],
        ),
      ],
    );
  }

  Widget _skill(String icon, double cd, double cdMax, bool Function() use) {
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
          child: Center(child: GameIcon(icon, size: 36)),
        ),
      ),
    );
  }
}

class _CooldownRing extends CustomPainter {
  _CooldownRing(this.f);
  final double f;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0x660D0B26));
    canvas.drawCircle(
        c,
        r - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white30);
    if (f > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi * f, true,
          Paint()..color = const Color(0x99000000));
    }
  }

  @override
  bool shouldRepaint(_CooldownRing old) => old.f != f;
}

/// 아레나 경계(균열 고리)와 카드 효과(회전 칼날·충격파)를 월드 위에 그린다. 카메라는 [WorldPainter]와 같다.
class RiftArenaPainter extends CustomPainter {
  RiftArenaPainter(this.world, this.zoom, {required Listenable repaint}) : super(repaint: repaint);
  final RiftWorld world;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = world.player.alive ? world.player.pos : world.player.deathPos;
    final t = world.totalTime;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(zoom);
    canvas.translate(-cam.dx, -cam.dy);
    // 균열 고리: 바깥으로 갈수록 흐려지는 보라 띠 + 일렁이는 테두리
    const c = RiftWorld.arenaCenter;
    const r = RiftWorld.arenaRadius;
    canvas.drawCircle(
      c,
      r + 60,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 120
        ..shader = RadialGradient(
          colors: const [Color(0x00B388FF), Color(0x55B388FF), Color(0x00B388FF)],
          stops: const [0.88, 0.95, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r + 130)),
    );
    final path = Path();
    for (var i = 0; i <= 180; i++) {
      final a = i / 180 * 2 * pi;
      final rr = r + 8 * sin(a * 9 + t * 2) + 5 * sin(a * 23 - t * 3);
      final p = c + Offset(cos(a), sin(a)) * rr;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xCCE1BEE7),
    );
    if (world.player.alive) {
      for (final b in world.bladePositions) {
        canvas.save();
        canvas.translate(b.dx, b.dy);
        canvas.rotate(world.bladeAngle * 3);
        final blade = Path()
          ..moveTo(0, -16)
          ..lineTo(5, 0)
          ..lineTo(0, 16)
          ..lineTo(-5, 0)
          ..close();
        canvas.drawPath(blade, Paint()..color = const Color(0xFFE1BEE7));
        canvas.rotate(pi / 2);
        canvas.drawPath(blade, Paint()..color = const Color(0xFFB388FF));
        canvas.restore();
      }
      if (world.shockAge < 0.4) {
        final f = world.shockAge / 0.4;
        canvas.drawCircle(
          world.player.pos,
          RiftLoadout.shockRadius * (0.3 + 0.7 * f),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10 * (1 - f) + 2
            ..color = const Color(0xFFB388FF).withValues(alpha: 1 - f),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(RiftArenaPainter old) => true;
}

/// 균열 런을 열 수 있는지: 프로필에 열림 표시가 있거나, 메인 게임 세이브의 스토리가 '해적 3척 격추'를 넘었으면.
/// 세이브에서 열린 것을 확인하면 프로필에 표시를 남긴다 (환생해도 열려 있다).
Future<bool> riftUnlocked(Profile p) async {
  final rec = RiftRecords(p.stats, onChanged: () => p.dirty = true);
  if (rec.unlocked) return true;
  final w = AppState.world;
  if (w != null) return rec.unlockBy(w.storyIndex);
  final raw = await SaveService.rawWorld();
  if (raw == null) return false;
  try {
    final story = (jsonDecode(raw) as Map)['story'];
    if (story is int && rec.unlockBy(story)) {
      await SaveService.saveProfile(p);
      return true;
    }
  } catch (_) {}
  return false;
}

/// 타이틀 화면의 균열 런 버튼. 잠겨 있으면 자물쇠와 함께 누르면 해금 조건을 알려 준다.
/// 균열 런 메뉴 아이콘 (assets/icons/menu_rift.png, Gemini 생성)
const riftMenuIcon = 'menu_rift';

class RiftTitleButton extends StatefulWidget {
  const RiftTitleButton({super.key, required this.open});

  /// 화면 열기 (타이틀이 돌아온 뒤 상태를 다시 읽는다)
  final Future<void> Function(Widget page) open;

  @override
  State<RiftTitleButton> createState() => _RiftTitleButtonState();
}

class _RiftTitleButtonState extends State<RiftTitleButton> {
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ok = await riftUnlocked(AppState.profile);
    if (mounted && ok != _open) setState(() => _open = ok);
  }

  @override
  Widget build(BuildContext context) => TextButton.icon(
        key: const ValueKey('title-rift'),
        style: TextButton.styleFrom(
          foregroundColor: _open ? const Color(0xFFE1BEE7) : Colors.white54,
          minimumSize: const Size(Tap.min, Tap.min),
        ),
        onPressed: () async {
          if (!_open) {
            toast(context, tr.rift_locked(tr.g_storyKillsTitle));
            return;
          }
          await widget.open(const RiftScreen());
          _check();
        },
        icon: _open
            ? const GameIcon(riftMenuIcon, size: IconSz.inline + 6)
            : const Icon(Icons.lock_outline),
        label: Text(tr.rift_title, style: Ts.body.copyWith(color: null)),
      );
}
