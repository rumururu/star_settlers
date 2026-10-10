import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/cosmetics.dart';
import '../game/missions.dart';
import '../game/models.dart';
import '../game/profile.dart';
import '../game/save.dart';
import '../game/world.dart';
import '../l10n/l.dart';
import '../services/app_state.dart';
import '../services/audio.dart';
import '../services/notifications.dart';
import 'chibi.dart';
import 'colony_panel.dart';
import 'home_screen.dart';
import 'common.dart';
import 'game_icons.dart';
import 'merchant_panel.dart';
import 'meta_screens.dart';
import 'shop_screen.dart';
import 'station_panel.dart';
import 'system_panel.dart';
import 'world_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.world});
  final GameWorld world;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _FrameNotifier extends ChangeNotifier {
  void tick() => notifyListeners();
}

enum _Overlay { none, station, merchant, colony, buildStation, system, pause }

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  final _frame = _FrameNotifier();
  final _input = InputState();
  final _focus = FocusNode();
  Duration _last = Duration.zero;
  double _saveTimer = 0;
  double _profileTimer = 0;
  int _profileSaveCount = 0;
  final _notified = <String>{};

  Offset _stick = Offset.zero;
  bool _touchFire = false;
  bool _autoFire = false;
  _Overlay _overlay = _Overlay.none;
  bool _modal = false; // 다이얼로그/다른 화면이 떠 있음

  /// 모달이 끝날 때: 그 사이 백그라운드에 다녀왔다면 오프라인 수입 정산
  void _endModal() {
    _modal = false;
    if (w.savedAt != null && mounted && !_discarded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_modal) _showOffline();
      });
    }
  }

  GameWorld get w => widget.world;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppState.world = w;
    AppState.deliverPending();
    _notified.addAll(w.profile.claimable.map((a) => a.id));
    _ticker = createTicker(_onTick)..start();
    NotificationService.instance.cancelAll();
    if (w.profile.notifications) NotificationService.instance.requestPermission();
    AudioService.instance.startMusic();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOffline());
  }

  /// 환생 등으로 이 월드를 버릴 때는 저장하지 않는다
  bool _discarded = false;

  @override
  void dispose() {
    // 환생했거나 설정에서 데이터를 초기화했으면(프로필이 바뀜) 저장하지 않는다
    if (!_discarded && identical(w.profile, AppState.profile)) SaveService.save(w);
    AppState.world = null;
    AudioService.instance.stopMusic();
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _frame.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AudioService.instance.startMusic();
      NotificationService.instance.cancelAll();
      // 백그라운드에 있던 시간만큼 오프라인 수입 (1분 이상일 때)
      if (w.savedAt != null && !_modal) _showOffline();
    } else if (!_discarded &&
        identical(w.profile, AppState.profile) &&
        (state == AppLifecycleState.paused || state == AppLifecycleState.hidden)) {
      w.savedAt ??= DateTime.now();
      SaveService.save(w);
      if (w.profile.notifications) {
        NotificationService.instance.scheduleReturn(
          storageFullIn: Duration(hours: w.profile.premium ? 8 : 2),
          hasColonies: w.counter('colonies') > 0,
        );
      }
      AudioService.instance.stopMusic();
    }
  }

  // ---------------- 루프 ----------------
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
    if (kb != Offset.zero) kb = kb.normalized();
    _input.move = kb != Offset.zero ? kb : _stick;
    _input.fire = _touchFire ||
        keys.contains(LogicalKeyboardKey.space) ||
        (_autoFire && _targetInRange());
    _input.autoAim = _autoFire;

    w.paused = _overlay != _Overlay.none || _modal;
    w.update(dt, _input);

    for (final s in w.sfx) {
      AudioService.instance.play(s);
      if (s == Sfx.hurt || s == Sfx.bigExplode) AppState.haptic();
    }
    w.sfx.clear();

    _saveTimer += dt;
    if (_saveTimer > 20 && !_discarded && identical(w.profile, AppState.profile)) {
      _saveTimer = 0;
      SaveService.save(w);
    }
    _profileTimer += dt;
    if (_profileTimer > 1) {
      _profileTimer = 0;
      _profileSaveCount++;
      for (final a in w.profile.claimable) {
        if (_notified.add(a.id)) {
          w.say(Speaker.advisor, tr.u_achievementDone(a.title, a.gems));
          w.sfx.add(Sfx.gem);
        }
      }
      if (w.profile.dirty && _profileSaveCount % 5 == 0 && identical(w.profile, AppState.profile)) {
        SaveService.saveProfile(w.profile);
      }
    }
    // 다른 오버레이가 사라졌으면 닫기
    if (_overlay == _Overlay.station && w.nearbyStation == null) _setOverlay(_Overlay.none);
    if (_overlay == _Overlay.merchant && w.nearbyMerchant == null) _setOverlay(_Overlay.none);
    if (_overlay == _Overlay.colony && _nearbyColony == null) _setOverlay(_Overlay.none);
    // 첫 정착 직후: 식민지 안내 창 자동으로 열기
    if (w.colonyTutorialPending && _overlay == _Overlay.none && !_modal) {
      w.colonyTutorialPending = false;
      if (_nearbyColony != null) _setOverlay(_Overlay.colony);
    }
    _frame.tick();
  }

  Planet? get _nearbyColony {
    final p = w.nearbyPlanet;
    return p != null && p.colonyLevel > 0 ? p : null;
  }

  void _finishColonyTutorial() {
    w.profile
      ..colonyTutorialSeen = true
      ..dirty = true;
    SaveService.saveProfile(w.profile);
    setState(() {});
  }

  bool _targetInRange() => w.pirates.any((e) => (e.pos - w.player.pos).distance < 520);

  void _setOverlay(_Overlay o) {
    if (_overlay == o) return;
    setState(() => _overlay = o);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final key = e.logicalKey;
    if (key == LogicalKeyboardKey.keyE) {
      _interact();
    } else if (key == LogicalKeyboardKey.keyB) {
      if (w.canBuildStationHere) _setOverlay(_Overlay.buildStation);
    } else if (key == LogicalKeyboardKey.keyQ) {
      w.fireMissiles();
    } else if (key == LogicalKeyboardKey.keyF) {
      w.activateShield();
    } else if (key == LogicalKeyboardKey.shiftLeft || key == LogicalKeyboardKey.shiftRight) {
      w.boost();
    } else if (key == LogicalKeyboardKey.escape) {
      _setOverlay(_overlay == _Overlay.none ? _Overlay.pause : _Overlay.none);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _interact() {
    if (_overlay != _Overlay.none) {
      _setOverlay(_Overlay.none);
      return;
    }
    if (w.nearbyMerchant != null) {
      _setOverlay(_Overlay.merchant);
    } else if (w.nearbyStation != null) {
      _setOverlay(_Overlay.station);
    } else if (w.nearbyGate != null) {
      _act(() => w.warp(w.nearbyGate!));
    } else if (_nearbyColony != null) {
      _setOverlay(_Overlay.colony);
    } else if (w.nearbyPlanet != null) {
      _act(() => w.upgradePlanet(w.nearbyPlanet!));
    }
  }

  void _act(bool Function() f) {
    if (f()) {
      AppState.haptic();
      SaveService.save(w);
    } else {
      w.say(Speaker.advisor, tr.u_cannotDo);
    }
    setState(() {});
  }

  Future<T?> _modalRoute<T>(Widget page) async {
    _modal = true;
    final r = await Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
    _endModal();
    AppState.deliverPending();
    if (mounted) setState(() {});
    return r;
  }

  Future<void> _openShop([int tab = 0]) => _modalRoute(ShopScreen(initialTab: tab));

  // ---------------- 오프라인 수입 / 부활 ----------------
  Future<void> _showOffline() async {
    final (sec, c, o) = w.offlineEarnings(DateTime.now());
    w.savedAt = null;
    if (sec <= 0 || !mounted) return;
    _modal = true;
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final premium = w.profile.premium;
    final mult = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: kPanelColor,
        title: Text(tr.u_welcomeBack, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ChibiPortrait(style: ChibiStyle.advisor, size: 90),
            Text(h > 0 ? tr.u_offlineHm(h, m) : tr.u_offlineM(m),
                textAlign: TextAlign.center, style: bodyStyle),
            const SizedBox(height: 8),
            Text('💰${compact(c)}  💎${compact(o)}',
                style: Ts.title.copyWith(color: Color(0xFFFFD54F))),
            if (!premium)
              Text(tr.u_passOfflineHint, style: dimStyle),
          ],
        ),
        actions: [
          if (!premium) TextButton(onPressed: () => Navigator.pop(ctx, 1), child: Text(tr.u_collect)),
          FilledButton(
            onPressed: () async {
              final ok = await AppState.watchAd();
              if (!ctx.mounted) return;
              if (ok) {
                Navigator.pop(ctx, 2);
              } else {
                toast(ctx, tr.u_adLoading);
              }
            },
            child: Text(premium ? tr.u_collectDouble : tr.u_adDouble),
          ),
        ],
      ),
    );
    w.applyOffline(c * (mult ?? 1), o * (mult ?? 1));
    w.sfx.add(Sfx.coin);
    _endModal();
    SaveService.save(w);
  }

  Future<void> _showAscend() async {
    final p = w.profile;
    final can = w.canAscend;
    final gain = w.honorGain;
    _modal = true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: kPanelColor,
        title: Text(tr.u_galaxyHonor, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr.u_honorStatus(p.honor, p.ascensions), style: bodyStyle),
            Text(tr.u_honorBonus(p.honor * 5, p.honor * 3), style: dimStyle),
            const Divider(color: Colors.white24),
            Text(
              tr.u_ascendExplain,
              style: bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (can)
              Text(tr.u_ascendGain(gain),
                  style: Ts.body.copyWith(color: Color(0xFFFFD54F)),
                  textAlign: TextAlign.center)
            else
              Text(tr.u_ascendLocked,
                  style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr.u_close)),
          if (can)
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(tr.u_ascendBtn(gain))),
        ],
      ),
    );
    _endModal();
    if (ok != true || !mounted) return;
    if (!await confirmDialog(context, tr.u_ascendConfirmTitle, tr.u_ascendConfirmBody, ok: tr.u_ascend)) {
      return;
    }
    _discarded = true;
    _ticker.stop();
    p.honor += gain;
    p.ascensions++;
    p.addStat('ascensions');
    await SaveService.clearWorld();
    await SaveService.saveProfile(p);
    if (!mounted) return;
    AudioService.instance.play(Sfx.warp);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GameScreen(world: GameWorld(profile: p))));
  }

  bool _reviving = false;

  Future<void> _reviveWithAd() async {
    if (_reviving) return; // 연타 방지
    _reviving = true;
    _modal = true;
    final ok = await AppState.watchAd();
    _reviving = false;
    _endModal();
    if (ok && w.profile.useAdRevive(DateTime.now())) {
      w.reviveHere();
    } else {
      w.say(Speaker.advisor, tr.u_adLoadingRetry);
    }
  }

  void _reviveWithGems() {
    if (w.profile.spendGems(10)) {
      w.reviveHere();
      SaveService.saveProfile(w.profile);
    } else {
      _openShop();
    }
  }

  // ---------------- 빌드 ----------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final zoom = (size.shortestSide / 750).clamp(0.55, 1.1);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: WorldPainter(w, zoom, repaint: _frame))),
            Positioned.fill(
              child: ListenableBuilder(listenable: _frame, builder: (context, _) => _hud(context)),
            ),
            if (_overlay == _Overlay.station && w.nearbyStation != null)
              Positioned.fill(
                child: StationPanel(
                  world: w,
                  station: w.nearbyStation!,
                  frame: _frame,
                  act: _act,
                  onClose: () => _setOverlay(_Overlay.none),
                  onOpenShop: () => _openShop(),
                ),
              ),
            if (_overlay == _Overlay.merchant && w.nearbyMerchant != null)
              Positioned.fill(
                child: MerchantPanel(
                  world: w,
                  event: w.nearbyMerchant!,
                  frame: _frame,
                  act: _act,
                  onClose: () => _setOverlay(_Overlay.none),
                ),
              ),
            if (_overlay == _Overlay.colony && _nearbyColony != null)
              Positioned.fill(
                child: ColonyPanel(
                  world: w,
                  planet: _nearbyColony!,
                  frame: _frame,
                  act: _act,
                  onClose: () => _setOverlay(_Overlay.none),
                  onTutorialDone: _finishColonyTutorial,
                ),
              ),
            if (_overlay == _Overlay.system)
              Positioned.fill(
                child: SystemPanel(world: w, frame: _frame, onClose: () => _setOverlay(_Overlay.none)),
              ),
            if (_overlay == _Overlay.buildStation)
              Positioned.fill(
                child: StationBuildPanel(world: w, act: _act, onClose: () => _setOverlay(_Overlay.none)),
              ),
            if (_overlay == _Overlay.pause) Positioned.fill(child: _pauseMenu()),
          ],
        ),
      ),
    );
  }

  Widget _hud(BuildContext context) {
    final p = w.player;
    final narrow = MediaQuery.sizeOf(context).width < 720;
    return SafeArea(
      child: Stack(
        children: [
          Positioned(left: 8, top: 8, child: _captainCard()),
          Positioned(right: 8, top: 8, child: _rightColumn()),
          if (w.dialogs.isNotEmpty)
            Positioned(
              top: narrow ? 230 : 70,
              left: narrow ? 8 : 240,
              right: narrow ? 8 : 150,
              child: Center(child: _dialog(w.dialogs.last)),
            ),
          if (!p.alive) Positioned.fill(child: _reviveOverlay()),
          if (p.alive) ...[
            Positioned(left: 20, bottom: 20, child: _joystick()),
            Positioned(right: 16, bottom: 16, child: _combatButtons()),
            Positioned(
              left: 8,
              right: 8,
              bottom: narrow ? 200 : 150,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _contextActions(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _captainCard() {
    final p = w.player;
    final (sv, st) = w.storyProgress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        glass(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChibiPortrait(style: ChibiStyle.captainIn(outfitById(w.profile.outfit)), size: 54),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hpBar(p.hp / w.playerMaxHp),
                const SizedBox(height: 3),
                _res('credits', w.credits, w.creditIncome),
                _res('ore', w.ore, w.oreIncome),
                GestureDetector(
                  onTap: () => _openShop(),
                  child: iconValue('gem', '${w.profile.gems}  ＋',
                      style: Ts.caption.copyWith(color: Color(0xFFFF80AB))),
                ),
              ],
            ),
          ],
        )),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 230),
          child: glass(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎯 ${w.story.title}',
                  style: Ts.caption.copyWith(color: Color(0xFF7CFFB2), fontWeight: FontWeight.bold)),
              if (st > 1) Text('$sv / $st', style: dimStyle),
              for (final m in w.activeMissions)
                Text('${m.icon} ${_missionShort(m)}',
                    style: Ts.caption.copyWith(color: Colors.white70),
                    overflow: TextOverflow.ellipsis),
              // 공격받는 중이거나 깨진 식민지 방어막만 표시
              for (final pl in w.planets.where((p) =>
                  p.colonyLevel > 0 && p.shieldHp < p.shieldMax(w.sectorMul) - 0.5))
                iconValue(
                    'dome',
                    pl.domeUp
                        ? '${pl.name} ${(100 * pl.shieldHp / pl.shieldMax(w.sectorMul)).floor()}%'
                        : tr.u_shieldBroken(pl.name),
                    size: 20,
                    style: Ts.caption.copyWith(color: WorldPainter.shieldColor(
                            pl.domeUp ? pl.shieldHp / pl.shieldMax(w.sectorMul) : 0), fontWeight: FontWeight.bold)),
              if (w.buffs.isNotEmpty)
                Text(w.buffs.entries.map((e) => '${e.key.icon}${e.value.ceil()}s').join('  '),
                    style: Ts.caption.copyWith(color: Color(0xFFB9F6CA))),
            ],
          )),
        ),
      ],
    );
  }

  String _missionShort(Mission m) => switch (m.type) {
        MissionType.kill || MissionType.mine =>
          '${m.title(w.planets)} ${min(m.progress, m.target)}/${m.target}',
        _ => m.title(w.planets),
      };

  Widget _rightColumn() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 누르면 항성계 현황
              GestureDetector(
                onTap: () => _setOverlay(_Overlay.system),
                // 언어마다 길이가 달라서, 왼쪽 선장 카드를 덮지 않게 화면 절반 안으로 줄인다
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width / 2 - 64),
                  child: glass(FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GameIcon('menu_home', size: 30),
                        const SizedBox(width: Space.xs),
                        Text(
                          tr.u_hudSector(w.sectorName, (w.development * 100).floor(),
                              w.threat.toStringAsFixed(1), compact(w.empireValue)),
                          textAlign: TextAlign.right,
                          style: Ts.caption.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  )),
                ),
              ),
              const SizedBox(width: 6),
              Badge(
                isLabelVisible: w.profile.claimable.isNotEmpty || w.profile.dailyClaimable > 0,
                smallSize: 10,
                child: _iconBtn(Icons.menu, () => _setOverlay(_Overlay.pause)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(painter: MinimapPainter(w, repaint: _frame)),
          ),
          // 본거지 위기: 내구도 30% 미만 또는 기능 정지
          if (w.homeBase.disabled || w.homeBase.hp < w.homeBase.maxHp * 0.3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: glass(
                iconValue(
                    'raid',
                    w.homeBase.disabled
                        ? tr.u_baseDisabled(w.homeBase.disabledTime.ceil())
                        : tr.u_baseHp((w.homeBase.hp / w.homeBase.maxHp * 100).floor()),
                    size: 20,
                    style: Ts.caption.copyWith(color: Color(0xFFFF5252))),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          for (final ev in w.events)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: glass(
                ev.kind == EventKind.raid
                    ? iconValue('raid', '${ev.planet?.name ?? ''} ${ev.timeLeft.ceil()}s',
                        size: 20, style: Ts.caption.copyWith(color: Color(0xFFFF8A80)))
                    : Text('${ev.title} ${ev.timeLeft.ceil()}s',
                        style: Ts.caption.copyWith(color: Color(0xFFFFD740))),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
        ],
      );

  List<Widget> _contextActions() {
    final out = <Widget>[];
    final merchant = w.nearbyMerchant;
    final st = w.nearbyStation;
    final gate = w.nearbyGate;
    final pl = w.nearbyPlanet;
    if (merchant != null) {
      out.add(actionBtn(tr.u_merchantE, true, () => _setOverlay(_Overlay.merchant),
          icon: 'act_merchant', color: const Color(0xFF00897B)));
    }
    if (st != null) {
      out.add(actionBtn('${st.name} (E)', true, () => _setOverlay(_Overlay.station),
          icon: 'act_station'));
    }
    if (gate != null) {
      out.add(w.gateOpen(gate)
          ? actionBtn(gate.forward ? tr.u_nextSectorE : tr.u_prevSectorE, true,
              () => _act(() => w.warp(gate)),
              icon: 'act_warp', color: const Color(0xFF6A1B9A))
          : actionBtn(tr.u_gateLocked((w.development * 100).floor()), false, null,
              icon: 'act_warp'));
    }
    if (pl != null) {
      if (pl.colonyLevel == 0) {
        final c = w.planetCost(pl);
        out.add(actionBtn(tr.u_settle(pl.name), w.canAfford(c), () => _act(() => w.upgradePlanet(pl)),
            icon: 'act_settle', cost: c));
      } else {
        out.add(actionBtn(tr.u_manageE(pl.name), true, () => _setOverlay(_Overlay.colony),
            icon: pl.raided ? 'raid' : 'colony_levelup', color: const Color(0xFF2E7D32)));
      }
      final (cr, orr) = pl.ratePerLevel;
      const dim = Ts.caption;
      out.add(glass(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${pl.kindLabel}  ', style: dim),
          iconValue('credits', '+${(cr * w.sectorMul).toStringAsFixed(1)}/s', size: 14, style: dim),
          if (orr > 0) ...[
            const SizedBox(width: 6),
            iconValue('ore', '+${(orr * w.sectorMul).toStringAsFixed(1)}/s', size: 14, style: dim),
          ],
        ],
      )));
    }
    if (w.canBuildStationHere && (w.counter('colonies') > 0 || w.credits >= w.stationBuildCost.$1)) {
      final c = w.stationBuildCost;
      out.add(actionBtn(tr.u_buildStation, w.canAfford(c), () => _setOverlay(_Overlay.buildStation),
          icon: 'tab_station', cost: c));
    }
    return out;
  }

  Widget _joystick() {
    const radius = 62.0;
    return Listener(
      onPointerDown: (e) => _updateStick(e.localPosition, radius),
      onPointerMove: (e) => _updateStick(e.localPosition, radius),
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
                color: const Color(0xFF42A5F5).withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateStick(Offset local, double radius) {
    _stick = ((local - Offset(radius, radius)) / (radius - 20)).clampLength(1);
  }

  Widget _combatButtons() {
    final p = w.player;
    return SizedBox(
      width: 190,
      height: 200,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Listener(
              onPointerDown: (_) => _touchFire = true,
              onPointerUp: (_) => _touchFire = false,
              onPointerCancel: (_) => _touchFire = false,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_touchFire ? const Color(0xFFFF5252) : const Color(0xFFE53935))
                      .withValues(alpha: 0.55),
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: Center(child: Text(tr.u_fire, style: Ts.heading)),
              ),
            ),
          ),
          Positioned(
            right: 104,
            bottom: 0,
            child: _skillBtn('cmb_boost', p.boostCooldown, w.boostCooldownMax, true, w.boost),
          ),
          Positioned(
            right: 96,
            bottom: 66,
            child: _skillBtn('cmb_missile', p.missileCooldown, w.missileCooldownMax,
                w.level(UpgradeKind.missile) > 0, w.fireMissiles),
          ),
          Positioned(
            right: 28,
            bottom: 104,
            child: _skillBtn('cmb_shield', p.shieldCooldown, w.shieldCooldownMax,
                w.level(UpgradeKind.shield) > 0, w.activateShield),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => setState(() => _autoFire = !_autoFire),
              child: glass(
                iconValue('cmb_auto', _autoFire ? 'ON' : 'OFF',
                    size: 22,
                    style: Ts.caption.copyWith(color: _autoFire ? const Color(0xFF7CFFB2) : Colors.white60)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillBtn(String icon, double cd, double cdMax, bool unlocked, bool Function() use) {
    final f = cdMax <= 0 ? 0.0 : (cd / cdMax).clamp(0.0, 1.0);
    return Listener(
      onPointerDown: (_) {
        if (!unlocked) {
          w.say(Speaker.advisor, tr.u_equipAtStation);
          return;
        }
        if (use()) AppState.haptic();
      },
      child: SizedBox(
        width: 56,
        height: 56,
        child: CustomPaint(
          painter: _CooldownPainter(f, unlocked),
          child: Center(
            child: Opacity(
              opacity: unlocked ? 1 : 0.35,
              child: unlocked
                  ? GameIcon(icon, size: 36)
                  : Stack(alignment: Alignment.center, children: [
                      GameIcon(icon, size: 36),
                      const Icon(Icons.lock, color: Colors.white, size: 18),
                    ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviveOverlay() {
    final p = w.player;
    if (!p.awaitingRevive) return const SizedBox();
    final premium = w.profile.premium;
    final adLeft = w.profile.adRevivesLeft(DateTime.now());
    return Container(
      color: Colors.black45,
      alignment: Alignment.center,
      child: glass(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ChibiPortrait(style: ChibiStyle.pirate, size: 80),
            Text(tr.u_shotDown, style: Ts.title),
            Text(tr.u_autoRespawn(max(0, 20 - p.deadTime).ceil()), style: dimStyle),
            const SizedBox(height: 12),
            // 광고 부활은 하루 횟수 제한 (패스는 무제한)
            if (adLeft > 0) ...[
              actionBtn(
                  premium
                      ? tr.u_reviveFree
                      : '${tr.u_reviveAd} ($adLeft/${Profile.adRevivesPerDay})',
                  true,
                  _reviveWithAd,
                  color: const Color(0xFF00897B)),
              const SizedBox(height: 8),
            ],
            actionBtn(tr.u_reviveGems, true, _reviveWithGems, color: const Color(0xFFAD1457)),
            const SizedBox(height: 8),
            actionBtn(tr.u_respawnBase((100 * GameWorld.respawnCostRatio(w.stations.reduce((a, b) => (a.pos - p.deathPos).distance < (b.pos - p.deathPos).distance ? a : b))).round()),
                true, w.respawnAtBase,
                color: const Color(0xFF455A64)),
          ],
        ),
        padding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _dialog(DialogLine d) {
    final name = switch (d.speaker) {
      Speaker.captain => tr.u_spkCaptain,
      Speaker.pirate => tr.u_spkPirate,
      Speaker.advisor => tr.u_spkAdvisor,
      Speaker.merchant => tr.u_spkMerchant,
    };
    return Opacity(
      opacity: d.time.clamp(0.0, 0.5) * 2,
      child: glass(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChibiPortrait(
                  style: ChibiStyle.of(d.speaker,
                      captainStyle: ChibiStyle.captainIn(outfitById(w.profile.outfit))),
                  size: 48),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name,
                        style: Ts.caption.copyWith(color: d.speaker == Speaker.pirate ? const Color(0xFFFF8A80) : kSky, fontWeight: FontWeight.bold)),
                    Text(d.text, style: bodyStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hpBar(double f) => SizedBox(
        width: 120,
        height: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: f.clamp(0, 1),
            backgroundColor: Colors.black45,
            color: f > 0.35 ? const Color(0xFF66BB6A) : const Color(0xFFFF5252),
          ),
        ),
      );

  Widget _res(String icon, double v, double rate) => iconValue(
        icon,
        '${compact(v)}${rate > 0 ? '  +${rate.toStringAsFixed(1)}/s' : ''}',
      );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => Material(
        color: const Color(0xCC0D0B26),
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onTap,
          visualDensity: VisualDensity.compact,
        ),
      );

  Widget _pauseMenu() => OverlayPanel(
        onClose: () => _setOverlay(_Overlay.none),
        maxWidth: 420,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            Text(tr.u_paused, style: titleStyle, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              tr.u_pauseStats(w.sectorName, w.counter('kills'), w.roster.length, w.counter('colonies'),
                  w.stations.length, w.counter('missions')),
              style: dimStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            actionBtn(tr.u_resume, true, () => _setOverlay(_Overlay.none)),
            const SizedBox(height: 8),
            actionBtn(tr.u_shop, true, () => _openShop(), color: const Color(0xFFAD1457)),
            const SizedBox(height: 8),
            Badge(
              isLabelVisible: w.profile.claimable.isNotEmpty,
              label: Text('${w.profile.claimable.length}'),
              child: SizedBox(
                width: double.infinity,
                child: actionBtn(tr.u_achievements, true, () => _modalRoute(const AchievementsScreen())),
              ),
            ),
            const SizedBox(height: 8),
            Badge(
              isLabelVisible: w.profile.dailyClaimable > 0,
              label: Text('${w.profile.dailyClaimable}'),
              child: SizedBox(
                width: double.infinity,
                child: actionBtn(tr.u_dailyQuests, true, () => _modalRoute(const DailyQuestScreen())),
              ),
            ),
            const SizedBox(height: 8),
            actionBtn(tr.u_myPlanet, true, () => _modalRoute(const HomePlanetScreen()),
                color: const Color(0xFF00897B)),
            const SizedBox(height: 8),
            actionBtn(tr.u_ascendMenu, true, _showAscend, color: const Color(0xFF4527A0)),
            const SizedBox(height: 8),
            actionBtn(tr.u_settings, true, () => _modalRoute(const SettingsScreen()),
                color: const Color(0xFF455A64)),
            const SizedBox(height: 8),
            actionBtn(tr.u_saveAndQuit, true, () async {
              await SaveService.save(w);
              if (mounted) Navigator.of(context).pop();
            }, color: const Color(0xFF455A64)),
            const SizedBox(height: 16),
            Text(
              tr.u_keyboardHelp,
              style: dimStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class _CooldownPainter extends CustomPainter {
  _CooldownPainter(this.fraction, this.unlocked);
  final double fraction;
  final bool unlocked;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0x881A237E));
    canvas.drawCircle(
        c,
        r - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = unlocked && fraction == 0 ? const Color(0xFF80D8FF) : Colors.white24);
    if (fraction > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi * fraction, true,
          Paint()..color = const Color(0xAA000000));
    }
  }

  @override
  bool shouldRepaint(_CooldownPainter old) => old.fraction != fraction || old.unlocked != unlocked;
}
