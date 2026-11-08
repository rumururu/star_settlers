import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/attendance.dart';
import '../game/cosmetics.dart';
import '../game/crew.dart';
import '../game/campaign.dart';
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
import 'colonies_panel.dart';
import 'codex_screen.dart';
import 'calendar_panel.dart';
import 'colony_panel.dart';
import 'crew_reveal.dart';
import 'home_screen.dart';
import 'leaderboard_screen.dart';
import 'pause_menu.dart';
import 'rift_screen.dart';
import 'common.dart';
import 'game_icons.dart';
import 'merchant_panel.dart';
import 'meta_screens.dart';
import 'shop_screen.dart';
import 'station_panel.dart';
import 'story_panel.dart';
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

enum _Overlay {
  none,
  station,
  merchant,
  colony,
  buildStation,
  system,
  colonies,
  pause,

  /// 새 승무원 카드 공개 (첫 ★3 확정 지급 등)
  crewReveal,

  /// 7일 출석 달력 (TASK 004)
  calendar,
}

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

  /// [_Overlay.crewReveal]로 보여 주는 승무원
  CrewMember? _revealCrew;

  /// 게임 진입·복귀 때 한 번 출석 달력을 띄울지 본다 (처음 받는 사람은 해적 단계를 마칠 때까지 기다린다)
  bool _calendarArmed = true;
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
    // 게임 중 "상점으로"는 게임을 멈추는 모달 경로로
    GemTopUp.openShop = () => _openShop();
    NotificationService.instance.cancelAll();
    // 알림 권한은 시작하자마자 묻지 않는다 (첫 튜토리얼 대사를 가린다) — [_maybeAskNotifications]
    AudioService.instance.startMusic();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showOffline());
  }

  /// 환생 등으로 이 월드를 버릴 때는 저장하지 않는다
  bool _discarded = false;

  @override
  void dispose() {
    // 환생했거나 설정에서 데이터를 초기화했으면(프로필이 바뀜) 저장하지 않는다
    if (!_discarded && identical(w.profile, AppState.profile)) {
      SaveService.save(w).then((_) => AppState.cloud.auto());
    }
    AppState.world = null;
    GemTopUp.openShop = () => navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    );
    AudioService.instance.stopMusic();
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _frame.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// 앱 생명주기 저장 시각 (inactive → hidden → paused가 연달아 와도 한 번만 저장)
  DateTime? _lifecycleSavedAt;

  bool get _canSave => !_discarded && identical(w.profile, AppState.profile);

  /// 진행 중인 생명주기 저장 (연달아 불리면 같은 저장이 끝나기를 기다린다)
  Future<void> _lifecycleSaving = Future.value();

  Future<void> _lifecycleSave() {
    final now = DateTime.now();
    final last = _lifecycleSavedAt;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return _lifecycleSaving;
    }
    _lifecycleSavedAt = now;
    _saveTimer = 0;
    return _lifecycleSaving = SaveService.save(w);
  }

  /// 복귀 알림 권한: 튜토리얼 첫 목표들(소행성·해적)을 마치고 첫 식민지를 세운 뒤,
  /// 대사·창이 모두 사라졌을 때 묻는다. 시작하자마자 물으면 첫 튜토리얼 대사를 가린다.
  bool _notifAsked = false;

  Future<void> _maybeAskNotifications() async {
    if (_notifAsked || !w.profile.notifications) return;
    if (_overlay != _Overlay.none ||
        _modal ||
        GemTopUp.asking ||
        w.dialogs.isNotEmpty ||
        w.pendingStoryScene != null) {
      return;
    }
    if (!w.player.alive || (w.storyIndex < 3 && w.counter('colonies') == 0)) {
      return;
    }
    _notifAsked = true;
    _modal = true;
    await NotificationService.instance.requestPermission();
    if (mounted) _endModal();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      // 전화·알림창·결제창 등으로 잠깐 가려질 때도 저장 (이대로 앱이 종료되면 최대 20초를 잃었다)
      if (_canSave) _lifecycleSave();
    } else if (state == AppLifecycleState.resumed) {
      _calendarArmed = true; // 자정을 넘겨 돌아왔으면 달력
      AudioService.instance.startMusic();
      NotificationService.instance.cancelAll();
      AppState.syncWallet(refresh: true); // 앱 밖에 있는 동안 들어온 결제
      // 백그라운드에 있던 시간만큼 오프라인 수입 (1분 이상일 때)
      if (w.savedAt != null && !_modal) _showOffline();
    } else if (_canSave &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden)) {
      w.savedAt ??= DateTime.now();
      // 저장이 끝난 뒤 클라우드 백업 (연결된 기기만, 10분에 한 번)
      _lifecycleSave().then((_) => AppState.cloud.auto());
      AppState.submitLeaderboard();
      AppState.syncWallet();
      if (w.profile.notifications) {
        final now = DateTime.now();
        NotificationService.instance.scheduleReturn(
          storageFullIn: Duration(hours: w.profile.premium ? 8 : 2),
          hasColonies: w.counter('colonies') > 0,
          // 다음 날 출석 보상 미리보기 + 원정 귀환 (TASK 004)
          tomorrowReward: calendarCellText(
            Attendance.cell(Attendance.streakTomorrow(w.profile, now)),
            w.profile,
          ),
          expeditionsDone: [
            for (final e in w.expeditions)
              DateTime.fromMillisecondsSinceEpoch(e.endMs),
          ],
        );
      }
      AudioService.instance.stopMusic();
    }
  }

  // ---------------- 루프 ----------------
  void _onTick(Duration now) {
    final dt = _last == Duration.zero
        ? 0.016
        : (now - _last).inMicroseconds / 1e6;
    _last = now;

    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    bool k(LogicalKeyboardKey a, LogicalKeyboardKey b) =>
        keys.contains(a) || keys.contains(b);
    var kb = Offset(
      (k(LogicalKeyboardKey.keyD, LogicalKeyboardKey.arrowRight) ? 1 : 0) -
          (k(LogicalKeyboardKey.keyA, LogicalKeyboardKey.arrowLeft) ? 1.0 : 0),
      (k(LogicalKeyboardKey.keyS, LogicalKeyboardKey.arrowDown) ? 1 : 0) -
          (k(LogicalKeyboardKey.keyW, LogicalKeyboardKey.arrowUp) ? 1.0 : 0),
    );
    if (kb != Offset.zero) kb = kb.normalized();
    _input.move = kb != Offset.zero ? kb : _stick;
    _input.fire =
        _touchFire ||
        keys.contains(LogicalKeyboardKey.space) ||
        (_autoFire && _targetInRange());
    _input.autoAim = _autoFire;
    _input.cruise = w.profile.cruise;

    w.paused =
        _overlay != _Overlay.none ||
        _modal ||
        GemTopUp.asking ||
        w.pendingStoryScene != null;
    w.update(dt, _input);

    for (final s in w.sfx) {
      AudioService.instance.play(s);
      if (s == Sfx.hurt || s == Sfx.bigExplode) AppState.haptic();
    }
    w.sfx.clear();
    AudioService.instance.setBossFight(w.pirates.any((e) => e.isBossLike));

    _saveTimer += dt;
    if (_saveTimer > 20 && _canSave) {
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
      if (w.profile.dirty &&
          _profileSaveCount % 5 == 0 &&
          identical(w.profile, AppState.profile)) {
        SaveService.saveProfile(w.profile);
      }
    }
    // 다른 오버레이가 사라졌으면 닫기
    if (_overlay == _Overlay.station && w.nearbyStation == null) {
      _setOverlay(_Overlay.none);
    }
    if (_overlay == _Overlay.merchant && w.nearbyMerchant == null) {
      _setOverlay(_Overlay.none);
    }
    if (_overlay == _Overlay.colony && _nearbyColony == null) {
      _setOverlay(_Overlay.none);
    }
    // 첫 정착 직후: 식민지 안내 창 자동으로 열기
    if (w.colonyTutorialPending &&
        _overlay == _Overlay.none &&
        !_modal &&
        w.pendingStoryScene == null) {
      w.colonyTutorialPending = false;
      if (_nearbyColony != null) _setOverlay(_Overlay.colony);
    }
    // 새 승무원 카드 공개 (대사·다른 창이 없을 때)
    if (w.crewReveal != null &&
        _overlay == _Overlay.none &&
        !_modal &&
        w.pendingStoryScene == null) {
      _revealCrew = w.crewReveal;
      w.crewReveal = null;
      AudioService.instance.play(Sfx.gem);
      _setOverlay(_Overlay.crewReveal);
    }
    // 출석 달력: 받을 보상이 있으면 (처음이면 첫 튜토리얼 뒤). 타이틀에서 받았으면 뜨지 않는다
    if (_calendarArmed &&
        _overlay == _Overlay.none &&
        !_modal &&
        w.pendingStoryScene == null &&
        w.crewReveal == null &&
        !w.star3GiftDue && // 첫 ★3 카드가 먼저
        w.player.alive) {
      final now = DateTime.now();
      if (!Attendance.claimable(w.profile, now)) {
        _calendarArmed = false;
      } else if (Attendance.showInGame(
        w.profile,
        now,
        storyIndex: w.storyIndex,
      )) {
        _calendarArmed = false;
        _setOverlay(_Overlay.calendar);
      }
    }
    _maybeAskNotifications();
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

  bool _targetInRange() =>
      w.pirates.any((e) => (e.pos - w.player.pos).distance < 520);

  void _setOverlay(_Overlay o) {
    if (_overlay == o) return;
    // 일시정지할 때 주간 순위 점수를 보낸다 (참여 중일 때만, 60초 간격, 기다리지 않음)
    if (o == _Overlay.pause) AppState.submitLeaderboard();
    setState(() => _overlay = o);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (w.pendingStoryScene != null) return KeyEventResult.ignored;
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
    } else if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight) {
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
    if (w.canWorkCampaign && !w.campaignWorking) {
      _act(w.startCampaignWork);
    } else if (w.nearbyMerchant != null) {
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
    final r = await Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (_) => page));
    // 격추된 채 상점 등에 다녀왔으면 자동 재출격 대기를 처음부터 (젬을 사 와서 젬 부활을 누를 시간)
    if (w.player.awaitingRevive) w.player.deadTime = 0;
    _endModal();
    AppState.deliverPending();
    if (mounted) setState(() {});
    return r;
  }

  Future<void> _exchangeCredits() async {
    _modal = true;
    final ok = await confirmDialog(
      context,
      tr.u_exchangeTitle,
      tr.u_exchangeBody(GameWorld.creditPackGems, w.creditPackAmount),
      ok: tr.u_exchange,
    );
    _endModal();
    if (!ok) return;
    if (w.profile.gems < GameWorld.creditPackGems) {
      _openShop();
      return;
    }
    if (!await payGems(GameWorld.creditPackGems, 'credit_pack')) return;
    _act(w.buyCreditsWithGems);
  }

  Future<void> _openShop([int tab = 0]) =>
      _modalRoute(ShopScreen(initialTab: tab));

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
        scrollable: true,
        backgroundColor: kPanelColor,
        title: Text(tr.u_welcomeBack, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ChibiPortrait(style: ChibiStyle.advisor, size: 90),
            Text(
              h > 0 ? tr.u_offlineHm(h, m) : tr.u_offlineM(m),
              textAlign: TextAlign.center,
              style: bodyStyle,
            ),
            const SizedBox(height: 8),
            Text(
              '💰${compact(c)}  💎${compact(o)}',
              style: Ts.title.copyWith(color: Color(0xFFFFD54F)),
            ),
            if (!premium) Text(tr.u_passOfflineHint, style: dimStyle),
          ],
        ),
        actions: [
          if (!premium)
            TextButton(
              onPressed: () => Navigator.pop(ctx, 1),
              child: Text(tr.u_collect),
            ),
          FilledButton(
            onPressed: () async {
              final ok = await AppState.watchAd();
              if (!ctx.mounted) return;
              if (ok) {
                Navigator.pop(ctx, 2);
              } else {
                final msg = adFailMessage(AppState.money.lastAdResult);
                if (msg != null) toast(ctx, msg);
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
        scrollable: true,
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
            // 원정은 월드에 속한다: 환생하면 원정 중인 승무원도 다른 승무원처럼 사라진다 (TASK 004)
            if (w.expeditions.isNotEmpty)
              Text(
                keepAll(tr.r4_ascendExpWarn(w.expeditions.length)),
                style: bodyStyle.copyWith(color: const Color(0xFFFFB74D)),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 10),
            if (can)
              Text(
                tr.u_ascendGain(gain),
                style: Ts.body.copyWith(color: Color(0xFFFFD54F)),
                textAlign: TextAlign.center,
              )
            else
              Text(
                tr.u_ascendLocked,
                style: const TextStyle(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(tr.u_close),
          ),
          if (can)
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(tr.u_ascendBtn(gain)),
            ),
        ],
      ),
    );
    _endModal();
    if (ok != true || !mounted) return;
    if (!await confirmDialog(
      context,
      tr.u_ascendConfirmTitle,
      tr.u_ascendConfirmBody,
      ok: tr.u_ascend,
    )) {
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
      MaterialPageRoute(
        builder: (_) => GameScreen(world: GameWorld(profile: p)),
      ),
    );
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
    } else if (!ok) {
      final msg = adFailMessage(AppState.money.lastAdResult, retry: true);
      if (msg != null) w.say(Speaker.advisor, msg);
    }
  }

  Future<void> _reviveWithGems() async {
    if (w.profile.gems < 10) {
      _openShop();
      return;
    }
    if (!await payGems(10, 'revive')) return;
    if (w.profile.spendGems(10)) {
      w.reviveHere();
      SaveService.saveProfile(w.profile);
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
            Positioned.fill(
              child: CustomPaint(
                painter: WorldPainter(w, zoom, repaint: _frame),
              ),
            ),
            Positioned.fill(
              child: ListenableBuilder(
                listenable: _frame,
                builder: (context, _) => _hud(context),
              ),
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
                child: SystemPanel(
                  world: w,
                  frame: _frame,
                  onClose: () => _setOverlay(_Overlay.none),
                  onOpenColonies: () => _setOverlay(_Overlay.colonies),
                ),
              ),
            if (_overlay == _Overlay.colonies)
              Positioned.fill(
                child: ColoniesPanel(
                  world: w,
                  frame: _frame,
                  act: _act,
                  onClose: () => _setOverlay(_Overlay.none),
                ),
              ),
            if (_overlay == _Overlay.buildStation)
              Positioned.fill(
                child: StationBuildPanel(
                  world: w,
                  act: _act,
                  onClose: () => _setOverlay(_Overlay.none),
                ),
              ),
            Positioned.fill(
              child: CodexHud(world: w, frame: _frame),
            ), // 도감 토스트·보상 (TASK 006)
            if (_overlay == _Overlay.pause)
              Positioned.fill(child: _pauseMenu()),
            if (_overlay == _Overlay.calendar)
              Positioned.fill(
                child: CalendarPanel(
                  profile: w.profile,
                  onClose: () => _setOverlay(_Overlay.none),
                  onClaimed: () {
                    AudioService.instance.play(Sfx.gem);
                    AppState.deliverPending();
                    SaveService.saveProfile(w.profile);
                    SaveService.save(w);
                  },
                ),
              ),
            if (_overlay == _Overlay.crewReveal && _revealCrew != null)
              Positioned.fill(
                child: CrewRevealCard(
                  crew: _revealCrew!,
                  assigned: _revealCrew!.assigned,
                  onClose: () {
                    _revealCrew = null;
                    _setOverlay(_Overlay.none);
                  },
                ),
              ),
            Positioned.fill(
              child: ListenableBuilder(
                listenable: _frame,
                builder: (context, _) {
                  final scene = w.pendingStoryScene;
                  if (scene == null) return const SizedBox.shrink();
                  return StoryPanel(
                    key: ValueKey('${scene.name}_${w.pendingCampaignSector}'),
                    scene: scene,
                    campaignSector: w.pendingCampaignSector,
                    onDone: () {
                      w.finishStoryScene();
                      _stick = Offset.zero;
                      _touchFire = false;
                      SaveService.save(w);
                      _frame.tick();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 낮은 화면(폰 가로): 높이가 모자라 세로용 고정 배치를 쓰면 위아래 위젯이 겹친다
  static bool isShortLayout(Size size) =>
      size.width > size.height && size.height < Layout.shortHeight;

  Widget _hud(BuildContext context) => isShortLayout(MediaQuery.sizeOf(context))
      ? _hudShort()
      : _hudTall(context);

  /// 가로 HUD: 왼쪽(상태 → 이동) · 가운데(대사 → 상황 버튼) · 오른쪽(항성계·미니맵 → 전투) 세 존을
  /// Row/Column으로 나눈다. 존끼리는 레이아웃이 자리를 나누므로 서로 겹치지 않고,
  /// 존 안에서 내용이 넘치면 위쪽 정보가 잘릴 뿐 조작 버튼을 덮지 않는다.
  Widget _hudShort() {
    final p = w.player;
    Widget clipTop(String key, Widget child) => ClipRect(
      key: ValueKey(key),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: child,
      ),
    );
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(Space.s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  key: const ValueKey('hud-left'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: clipTop('hud-captain', _captainCard())),
                    if (p.alive)
                      Padding(
                        padding: const EdgeInsets.only(top: Space.s),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            KeyedSubtree(
                              key: const ValueKey('hud-joystick'),
                              child: _joystick(),
                            ),
                            const SizedBox(width: Space.m),
                            KeyedSubtree(
                              key: const ValueKey('hud-cruise'),
                              child: _cruiseToggle(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: Space.s),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_message() case final msg?)
                        Flexible(
                          child: clipTop(
                            'hud-dialog-zone',
                            Center(
                              child: KeyedSubtree(
                                key: const ValueKey('hud-dialog'),
                                child: msg,
                              ),
                            ),
                          ),
                        )
                      else
                        // 대화가 없어도 행동 버튼은 아래(엄지 쪽)에 둔다
                        const Spacer(),
                      if (p.alive)
                        Flexible(
                          child: SingleChildScrollView(
                            reverse: true,
                            child: Wrap(
                              key: const ValueKey('hud-actions'),
                              alignment: WrapAlignment.center,
                              spacing: Space.s,
                              runSpacing: Space.s,
                              children: _contextActions(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.s),
                SizedBox(
                  width: _rightZoneWidth,
                  child: Column(
                    key: const ValueKey('hud-right'),
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: clipTop('hud-info', _rightColumn(short: true)),
                      ),
                      if (p.alive)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(height: Space.xs),
                            _autoFireToggle(),
                            const SizedBox(height: Space.xs),
                            KeyedSubtree(
                              key: const ValueKey('hud-combat'),
                              child: _combatButtons(short: true),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!p.alive) Positioned.fill(child: _reviveOverlay()),
        ],
      ),
    );
  }

  Widget _hudTall(BuildContext context) {
    final p = w.player;
    if (MediaQuery.sizeOf(context).width < Layout.contentMaxWidth) {
      return _hudPortrait();
    }
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 8,
            child: KeyedSubtree(
              key: const ValueKey('hud-captain'),
              child: _captainCard(),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: KeyedSubtree(
              key: const ValueKey('hud-info'),
              child: _rightColumn(),
            ),
          ),
          if (_message() case final msg?)
            Positioned(
              top: 70,
              left: 240,
              right: 150,
              child: Center(
                child: KeyedSubtree(
                  key: const ValueKey('hud-dialog'),
                  child: msg,
                ),
              ),
            ),
          if (!p.alive) Positioned.fill(child: _reviveOverlay()),
          if (p.alive) ...[
            Positioned(
              left: 20,
              bottom: 20,
              child: KeyedSubtree(
                key: const ValueKey('hud-joystick'),
                child: _joystick(),
              ),
            ),
            // 순항 토글: 조이스틱 바로 위 (왼손 엄지 영역)
            Positioned(
              left: 20,
              bottom: 156,
              child: KeyedSubtree(
                key: const ValueKey('hud-cruise'),
                child: _cruiseToggle(),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: KeyedSubtree(
                key: const ValueKey('hud-combat'),
                child: _combatButtons(),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 150,
              child: Wrap(
                key: const ValueKey('hud-actions'),
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

  /// 세로 폰: 정보와 조작을 각각 한 행에 묶고, 대사와 상황 버튼은 그 사이에 둔다.
  /// 하단 행의 실제 높이만큼 공간을 예약하므로 번역이나 버튼 크기가 달라도 겹치지 않는다.
  Widget _hudPortrait() => SafeArea(
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(Space.s),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    KeyedSubtree(
                      key: const ValueKey('hud-info'),
                      child: _rightColumn(bottom: false),
                    ),
                    const SizedBox(height: Space.s),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: KeyedSubtree(
                            key: const ValueKey('hud-captain'),
                            child: _captainCard(),
                          ),
                        ),
                        const SizedBox(width: Space.s),
                        // 미니맵 열: 경보 글자가 길어도(글자 배율·독일어) 선장 카드 몫을 빼앗지 않게 폭을 묶는다
                        ConstrainedBox(
                          key: const ValueKey('hud-map'),
                          constraints: BoxConstraints(
                            maxWidth: max(
                              _minimapSize,
                              MediaQuery.sizeOf(context).width * 0.38,
                            ),
                          ),
                          child: _rightColumn(top: false),
                        ),
                      ],
                    ),
                    if (_message() case final msg?) ...[
                      const SizedBox(height: Space.s),
                      Flexible(
                        child: ClipRect(
                          key: const ValueKey('hud-dialog-zone'),
                          child: SingleChildScrollView(
                            child: KeyedSubtree(
                              key: const ValueKey('hud-dialog'),
                              child: msg,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (w.player.alive) ...[
                const SizedBox(height: Space.s),
                Wrap(
                  key: const ValueKey('hud-actions'),
                  alignment: WrapAlignment.center,
                  spacing: Space.s,
                  runSpacing: Space.s,
                  children: _contextActions(),
                ),
                Padding(
                  padding: const EdgeInsets.all(Space.s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            KeyedSubtree(
                              key: const ValueKey('hud-cruise'),
                              child: _cruiseToggle(),
                            ),
                            const SizedBox(height: Space.m),
                            KeyedSubtree(
                              key: const ValueKey('hud-joystick'),
                              child: _joystick(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Space.s),
                      KeyedSubtree(
                        key: const ValueKey('hud-combat'),
                        child: _combatButtons(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!w.player.alive) Positioned.fill(child: _reviveOverlay()),
      ],
    ),
  );

  Widget _captainCard() {
    final p = w.player;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        glass(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ChibiPortrait(
                    style: ChibiStyle.captainIn(outfitById(w.profile.outfit)),
                    size: 54,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hpBar(p.hp / w.playerMaxHp),
                  const SizedBox(height: 3),
                  // 누르면 젬 → 크레딧 교환
                  GestureDetector(
                    onTap: _exchangeCredits,
                    child: _res('credits', w.credits, w.creditIncome),
                  ),
                  _res('ore', w.ore, w.oreIncome),
                  GestureDetector(
                    onTap: () => _openShop(),
                    child: iconValue(
                      'gem',
                      '${w.profile.gems}  ＋',
                      style: Ts.caption.copyWith(color: Color(0xFFFF80AB)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 230),
          child: glass(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _goalChip(),
                for (final m in w.activeMissions)
                  Text(
                    '${m.icon} ${_missionShort(m)}',
                    style: Ts.caption.copyWith(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                // 공격받는 중이거나 깨진 식민지 방어막만 표시
                for (final pl in w.planets.where(
                  (p) =>
                      p.colonyLevel > 0 &&
                      p.shieldHp < p.shieldMax(w.sectorMul) - 0.5,
                ))
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const GameIcon('dome', size: IconSz.inline),
                      const SizedBox(width: Space.xs),
                      Flexible(
                        child: Text(
                          keepAll(
                            pl.domeUp
                                ? '${pl.name} ${(100 * pl.shieldHp / pl.shieldMax(w.sectorMul)).floor()}%'
                                : w.relayShieldActive(pl)
                                ? '${pl.name} · ${tr.u_sharedShield} ${pl.relayShieldHp.round()}'
                                : tr.u_shieldBroken(pl.name),
                          ),
                          style: Ts.caption.copyWith(
                            color: WorldPainter.shieldColor(
                              pl.domeUp
                                  ? pl.shieldHp / pl.shieldMax(w.sectorMul)
                                  : w.relayShieldActive(pl)
                                  ? pl.relayShieldHp / w.relayShieldMax(pl)
                                  : 0,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (w.buffs.isNotEmpty)
                  Text(
                    w.buffs.entries
                        .map((e) => '${e.key.icon}${e.value.ceil()}s')
                        .join('  '),
                    style: Ts.caption.copyWith(color: Color(0xFFB9F6CA)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _missionShort(Mission m) => switch (m.type) {
    MissionType.kill || MissionType.mine =>
      '${m.title(w.planets)} ${min(m.progress, m.target)}/${m.target}',
    _ => m.title(w.planets),
  };

  /// 미니맵 한 변. 가로(낮은 화면)에서는 아래 전투 버튼 자리를 남기려고 조금 작게
  static const _minimapSize = 120.0;
  static const _minimapSizeShort = 100.0;

  /// [short]: 가로 HUD. 이벤트·본거지 경보를 미니맵 아래가 아니라 왼쪽에 쌓아 높이를 아낀다.
  /// 대규모 침공 배너: 경보 카운트다운 → 파도 진행 → 결과 한 줄.
  /// 이벤트 목록 맨 위에 붙어서 미니맵 열 안에 머문다 (폭을 묶어 줄바꿈 — 왼쪽 카드·버튼을 덮지 않게).
  Widget? _invasionBanner({required bool short}) {
    final inv = w.invasion;
    if (inv == null) return null;
    final text = switch (inv.phase) {
      InvasionPhase.warning => tr.u_invasionCountdown(max(0, inv.timer.ceil())),
      InvasionPhase.waves => tr.u_invasionWave(
        inv.wave,
        GameWorld.invasionWaves,
        w.invasionEnemiesLeft,
      ),
      InvasionPhase.done =>
        inv.won
            ? tr.u_invasionWon(inv.reward)
            : tr.u_invasionRetreat((inv.killRatio * 100).round(), inv.reward),
    };
    final color = switch (inv.phase) {
      InvasionPhase.done =>
        inv.won ? const Color(0xFF7CFFB2) : const Color(0xFFFFD740),
      _ => const Color(0xFFFF5252),
    };
    return Padding(
      key: const ValueKey('hud-invasion'),
      padding: const EdgeInsets.only(top: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: short
              ? _rightZoneWidth - _minimapSizeShort - Space.xs
              : _invasionBannerWidth,
        ),
        child: glass(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GameIcon('raid', size: 20),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  keepAll(text),
                  style: Ts.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
    );
  }

  /// 세로 HUD 배너 폭: 왼쪽 임무 카드(최대 230)와 겹치지 않는 만큼만. 넘치면 줄을 바꾼다.
  /// 넓은 화면(대사 상자가 오른쪽 150 앞에서 끝난다)은 140으로 묶어 대사와도 겹치지 않게.
  double get _invasionBannerWidth {
    final mq = MediaQuery.of(context);
    if (mq.size.width >= 720) return 140;
    final free = mq.size.width - mq.padding.horizontal - 8 - 8 - 230 - 4;
    return free.clamp(96.0, 170.0);
  }

  /// [top]: 항성계 배지 + 메뉴 줄, [bottom]: 미니맵 + 경보. 세로 폰은 둘을 나눠
  /// 배지 줄을 화면 폭 전체에 놓는다 (반쪽 폭에 넣으면 글자가 4~6px로 줄어 읽을 수 없었다).
  Widget _rightColumn({
    bool short = false,
    bool top = true,
    bool bottom = true,
  }) {
    final invasionBanner = _invasionBanner(short: short);
    final alerts = <Widget>[
      ?invasionBanner,
      // 본거지 위기: 내구도 30% 미만 또는 기능 정지
      if (w.homeBase.disabled || w.homeBase.hp < w.homeBase.maxHp * 0.3)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: glass(
            iconValue(
              'raid',
              w.homeBase.disabled
                  ? tr.u_baseDisabled(w.homeBase.disabledTime.ceil())
                  : tr.u_baseHp(
                      (w.homeBase.hp / w.homeBase.maxHp * 100).floor(),
                    ),
              size: 20,
              style: Ts.caption.copyWith(color: Color(0xFFFF5252)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      for (final ev in w.events)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: glass(
            ev.kind == EventKind.raid
                ? iconValue(
                    'raid',
                    '${ev.planet?.name ?? ''} ${ev.timeLeft.ceil()}s',
                    size: 20,
                    style: Ts.caption.copyWith(color: Color(0xFFFF8A80)),
                  )
                : Text(
                    '${ev.title} ${ev.timeLeft.ceil()}s',
                    style: Ts.caption.copyWith(color: Color(0xFFFFD740)),
                  ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
    ];
    final minimap = SizedBox(
      key: const ValueKey('hud-minimap'),
      width: short ? _minimapSizeShort : _minimapSize,
      height: short ? _minimapSizeShort : _minimapSize,
      child: CustomPaint(painter: MinimapPainter(w, repaint: _frame)),
    );
    // 항성계 정보 폭: 세로는 화면 절반(왼쪽 선장 카드를 덮지 않게), 가로는 오른쪽 존 폭 안
    final sectorMax = short
        ? _rightZoneWidth - Tap.min - 6
        : !bottom
        ? double.infinity
        : MediaQuery.sizeOf(context).width / 2 - 64;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (top)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 누르면 항성계 현황
              Flexible(
                child: GestureDetector(
                  onTap: () => _setOverlay(_Overlay.system),
                  // 언어마다 길이가 달라서, 왼쪽 선장 카드를 덮지 않게 화면 절반 안으로 줄인다
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: Tap.min,
                      minHeight: Tap.min,
                      maxWidth: sectorMax,
                    ),
                    child: glass(
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const GameIcon('menu_home', size: 30),
                            const SizedBox(width: Space.xs),
                            Text(
                              tr.u_hudSector(
                                w.sectorName,
                                (w.development * 100).floor(),
                                w.threat.toStringAsFixed(1),
                                compact(w.empireValue),
                              ),
                              textAlign: TextAlign.right,
                              style: Ts.caption.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Badge(
                isLabelVisible:
                    w.profile.claimable.isNotEmpty ||
                    w.profile.dailyClaimable > 0,
                smallSize: 10,
                child: _iconBtn(Icons.menu, () => _setOverlay(_Overlay.pause)),
              ),
            ],
          ),
        if (top && bottom) const SizedBox(height: 6),
        if (!bottom)
          const SizedBox.shrink()
        else if (short)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final a in alerts)
                      FittedBox(fit: BoxFit.scaleDown, child: a),
                  ],
                ),
              ),
              const SizedBox(width: Space.xs),
              minimap,
            ],
          )
        else ...[
          minimap,
          ...alerts,
        ],
      ],
    );
  }

  List<Widget> _contextActions() {
    final out = <Widget>[];
    if (w.canWorkCampaign && !w.campaignWorking) {
      out.add(
        actionBtn(
          keyHint('${tr.c_operate} (E)'),
          true,
          () => _act(w.startCampaignWork),
          icon: 'act_station',
        ),
      );
    }
    if (w.sector == campaignFinalSector) {
      if (w.canStartFinalSync) {
        out.add(
          actionBtn(
            tr.c_syncButton,
            true,
            () => _act(w.startFinalSync),
            icon: 'act_station',
            color: const Color(0xFF00897B),
          ),
        );
      }
      if (w.canCounterattack) {
        out.add(
          actionBtn(
            tr.c_fireButton,
            true,
            () => _act(w.launchCounterattack),
            icon: 'act_warp',
            color: const Color(0xFF6A1B9A),
          ),
        );
      }
    }
    final merchant = w.nearbyMerchant;
    final st = w.nearbyStation;
    final gate = w.nearbyGate;
    final pl = w.nearbyPlanet;
    if (merchant != null) {
      out.add(
        actionBtn(
          keyHint(tr.u_merchantE),
          true,
          () => _setOverlay(_Overlay.merchant),
          icon: 'act_merchant',
          color: const Color(0xFF00897B),
        ),
      );
    }
    if (st != null) {
      out.add(
        actionBtn(
          keyHint('${st.name} (E)'),
          true,
          () => _setOverlay(_Overlay.station),
          icon: 'act_station',
        ),
      );
    }
    if (gate != null) {
      out.add(
        w.gateOpen(gate)
            ? actionBtn(
                keyHint(gate.forward ? tr.u_nextSectorE : tr.u_prevSectorE),
                true,
                () => _act(() => w.warp(gate)),
                icon: 'act_warp',
                color: const Color(0xFF6A1B9A),
              )
            : actionBtn(
                w.campaignMissionActive && w.development >= 1
                    ? tr.c_finishOperation
                    : tr.u_gateLocked((w.development * 100).floor()),
                false,
                null,
                icon: 'act_warp',
              ),
      );
    }
    if (pl != null) {
      if (pl.colonyLevel == 0) {
        final c = w.planetCost(pl);
        out.add(
          actionBtn(
            tr.u_settle(pl.name),
            w.canAfford(c),
            () => _act(() => w.upgradePlanet(pl)),
            icon: 'act_settle',
            cost: c,
          ),
        );
      } else {
        out.add(
          actionBtn(
            keyHint(tr.u_manageE(pl.name)),
            true,
            () => _setOverlay(_Overlay.colony),
            icon: pl.raided ? 'raid' : 'colony_levelup',
            color: const Color(0xFF2E7D32),
          ),
        );
      }
      final (cr, orr) = pl.ratePerLevel;
      const dim = Ts.caption;
      out.add(
        glass(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${pl.kindLabel}  ', style: dim),
              iconValue(
                'credits',
                '+${(cr * w.sectorMul).toStringAsFixed(1)}/s',
                size: 14,
                style: dim,
              ),
              if (orr > 0) ...[
                const SizedBox(width: 6),
                iconValue(
                  'ore',
                  '+${(orr * w.sectorMul).toStringAsFixed(1)}/s',
                  size: 14,
                  style: dim,
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (w.canBuildStationHere &&
        (w.counter('colonies') > 0 || w.credits >= w.stationBuildCost.$1)) {
      final c = w.stationBuildCost;
      out.add(
        actionBtn(
          tr.u_buildStation,
          w.canAfford(c),
          () => _setOverlay(_Overlay.buildStation),
          icon: 'tab_station',
          cost: c,
        ),
      );
    }
    return out;
  }

  /// HUD '다음 목표' 칩: 아이콘 + 한 줄 + 진행 막대. 누르면 안내 화살표가 그 목표를 잠깐 가리킨다.
  /// 목표를 이루면 잠깐 초록으로 빛나며 '목표 달성!'을 보여 준다.
  Widget _goalChip() {
    final g = w.goal;
    final done = w.goalFlash > 0 ? w.goalDone : null;
    const green = Color(0xFF7CFFB2);
    final pulse = done == null
        ? 0.0
        : sin(pi * (w.goalFlash / GameWorld.goalFlashSeconds).clamp(0.0, 1.0));
    final chip = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (done == null && g.heading != null)
          Text(
            keepAll('🎯 ${g.heading}'),
            style: Ts.caption.copyWith(
              color: green,
              fontWeight: FontWeight.bold,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameIcon(done?.icon ?? g.icon, size: IconSz.inline),
            const SizedBox(width: Space.xs),
            Flexible(
              child: Text(
                keepAll(done != null ? '✔ ${tr.g_floatGoalDone}' : g.text),
                style: Ts.caption.copyWith(
                  color: done != null || g.heading == null ? green : kSky,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (done == null && g.hasProgress)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 96,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: g.fraction,
                        minHeight: 5,
                        backgroundColor: Colors.white12,
                        color: green,
                      ),
                    ),
                  ),
                ),
                if (g.progressLabel != null) ...[
                  const SizedBox(width: Space.s),
                  Text(g.progressLabel!, style: Ts.caption),
                ],
              ],
            ),
          ),
      ],
    );
    return GestureDetector(
      key: const ValueKey('hud-goal'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        w.pingGoal();
        AppState.haptic();
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: Tap.min,
          minWidth: Tap.min,
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          decoration: done == null
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: green.withValues(alpha: 0.5 * pulse),
                      blurRadius: 12 * pulse,
                    ),
                  ],
                ),
          child: Transform.scale(
            scale: 1 + 0.06 * pulse,
            alignment: Alignment.centerLeft,
            child: chip,
          ),
        ),
      ),
    );
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

  Widget _cruiseToggle() => GestureDetector(
    onTap: () => setState(() {
      w.profile.cruise = !w.profile.cruise;
      w.profile.dirty = true;
    }),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Tap.min),
      child: glass(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.double_arrow,
              size: 22,
              color: w.profile.cruise
                  ? const Color(0xFF7CFFB2)
                  : Colors.white60,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${tr.u_cruise} ${w.profile.cruise ? tr.u_autoFireOn : tr.u_autoFireOff}',
                style: Ts.caption.copyWith(
                  color: w.profile.cruise
                      ? const Color(0xFF7CFFB2)
                      : Colors.white60,
                ),
              ),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    ),
  );

  void _updateStick(Offset local, double radius) {
    _stick = ((local - Offset(radius, radius)) / (radius - 20)).clampLength(1);
  }

  /// 가로 HUD 오른쪽 존 폭 (전투 버튼 묶음이 들어가는 폭)
  static const _rightZoneWidth = 236.0;

  /// 자동 사격 토글. 세로 HUD는 전투 버튼 묶음 맨 위, 가로 HUD는 묶음 바로 위에 따로 놓는다.
  Widget _autoFireToggle() => GestureDetector(
    key: const ValueKey('hud-autofire'),
    onTap: () => setState(() => _autoFire = !_autoFire),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Tap.min, minWidth: Tap.min),
      child: glass(
        iconValue(
          'cmb_auto',
          _autoFire ? tr.u_autoFireOn : tr.u_autoFireOff,
          size: 22,
          style: Ts.caption.copyWith(
            color: _autoFire ? const Color(0xFF7CFFB2) : Colors.white60,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.s,
          vertical: Space.m,
        ),
      ),
    ),
  );

  /// 발사 버튼(오른쪽 아래)과 그 둘레의 스킬 버튼.
  /// 세로: 스킬과 발사 버튼을 두 열로 쌓고, 맨 위에 자동 사격을 둔다.
  /// 가로(낮은 화면): 스킬을 발사 버튼 왼쪽으로 펼쳐 높이를 줄인다 (224×122, 자동 사격은 묶음 밖).
  Widget _combatButtons({bool short = false}) {
    final p = w.player;
    final fire = Listener(
      onPointerDown: (_) => _touchFire = true,
      onPointerUp: (_) => _touchFire = false,
      onPointerCancel: (_) => _touchFire = false,
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              (_touchFire ? const Color(0xFFFF5252) : const Color(0xFFE53935))
                  .withValues(alpha: 0.55),
          border: Border.all(color: Colors.white38, width: 2),
        ),
        child: Center(child: Text(tr.u_fire, style: Ts.heading)),
      ),
    );
    final boost = _skillBtn(
      'cmb_boost',
      p.boostCooldown,
      w.boostCooldownMax,
      true,
      w.boost,
    );
    final missile = _skillBtn(
      'cmb_missile',
      p.missileCooldown,
      w.missileCooldownMax,
      w.level(UpgradeKind.missile) > 0,
      w.fireMissiles,
    );
    final shield = _skillBtn(
      'cmb_shield',
      p.shieldCooldown,
      w.shieldCooldownMax,
      w.level(UpgradeKind.shield) > 0,
      w.activateShield,
    );
    if (short) {
      return SizedBox(
        width: 224,
        height: 122,
        child: Stack(
          children: [
            Positioned(right: 0, bottom: 0, child: fire),
            Positioned(right: 104, bottom: 0, child: boost),
            Positioned(right: 100, bottom: 66, child: missile),
            Positioned(right: 168, bottom: 34, child: shield),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _autoFireToggle(),
        const SizedBox(height: Space.s),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                missile,
                const SizedBox(height: Space.m),
                boost,
              ],
            ),
            const SizedBox(width: Space.m),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                shield,
                const SizedBox(height: Space.m),
                fire,
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _skillBtn(
    String icon,
    double cd,
    double cdMax,
    bool unlocked,
    bool Function() use,
  ) {
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
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        GameIcon(icon, size: 36),
                        const Icon(Icons.lock, color: Colors.white, size: 18),
                      ],
                    ),
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
      // 가로 화면(낮은 높이)에서는 버튼까지 스크롤된다
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.s),
        child: glass(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ChibiPortrait(style: ChibiStyle.pirate, size: 80),
              Text(tr.u_shotDown, style: Ts.title),
              Text(
                tr.u_autoRespawn(max(0, 20 - p.deadTime).ceil()),
                style: dimStyle,
              ),
              const SizedBox(height: 12),
              // 광고 부활은 하루 횟수 제한 (패스는 무제한)
              if (adLeft > 0) ...[
                actionBtn(
                  premium
                      ? tr.u_reviveFree
                      : '${tr.u_reviveAd} ($adLeft/${Profile.adRevivesPerDay})',
                  true,
                  _reviveWithAd,
                  color: const Color(0xFF00897B),
                ),
                const SizedBox(height: 8),
              ],
              actionBtn(
                tr.u_reviveGems,
                true,
                _reviveWithGems,
                color: const Color(0xFFAD1457),
              ),
              const SizedBox(height: 8),
              actionBtn(
                tr.u_respawnBase(
                  (100 *
                          GameWorld.respawnCostRatio(
                            w.stations.reduce(
                              (a, b) =>
                                  (a.pos - p.deathPos).distance <
                                      (b.pos - p.deathPos).distance
                                  ? a
                                  : b,
                            ),
                          ))
                      .round(),
                ),
                true,
                w.respawnAtBase,
                color: const Color(0xFF455A64),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  /// HUD 대사 칸에 보일 것: 대사가 먼저, 대사가 없을 때 도감 새 항목 토스트([CodexHud]가 순서를 정함).
  Widget? _message() {
    if (w.dialogs.isNotEmpty) return _dialog(w.dialogs.last);
    final f = w.profile.codex.showing;
    return f == null ? null : Center(child: CodexToastChip(f));
  }

  Widget _dialog(DialogLine d) {
    final name = switch (d.speaker) {
      Speaker.captain => tr.u_spkCaptain,
      Speaker.pirate => w.enemySpeakerName,
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
                style: ChibiStyle.of(
                  d.speaker,
                  captainStyle: ChibiStyle.captainIn(
                    outfitById(w.profile.outfit),
                  ),
                ),
                size: 48,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: Ts.caption.copyWith(
                        color: d.speaker == Speaker.pirate
                            ? const Color(0xFFFF8A80)
                            : kSky,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(keepAll(d.text), style: bodyStyle),
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
      visualDensity: VisualDensity.standard,
    ),
  );

  Widget _pauseMenu() => PauseMenu(
    onClose: () => _setOverlay(_Overlay.none),
    title: tr.u_paused,
    stats: tr.u_pauseStats(
      w.sectorName,
      w.counter('kills'),
      w.roster.length,
      w.counter('colonies'),
      w.stations.length,
      w.counter('missions'),
    ),
    resumeLabel: tr.u_resume,
    onResume: () => _setOverlay(_Overlay.none),
    // 내일 출석 보상 미리보기 (누르면 달력)
    banner: TomorrowCard(
      profile: w.profile,
      onTap: () => _setOverlay(_Overlay.calendar),
    ),
    tiles: [
      MenuTile(
        tr.u_shop,
        'menu_shop',
        _openShop,
        accent: const Color(0xFFFF4F9A),
      ),
      MenuTile(
        tr.u_achievements,
        'menu_trophy',
        () => _modalRoute(const AchievementsScreen()),
        badge: w.profile.claimable.length,
      ),
      MenuTile(
        tr.codex_title,
        codexMenuIcon,
        () => _modalRoute(const CodexScreen()),
        badge: w.profile.codex.badge,
      ),
      MenuTile(
        tr.u_dailyQuests,
        'menu_quest',
        () => _modalRoute(const DailyQuestScreen()),
        badge: w.profile.dailyClaimable,
      ),
      MenuTile(
        tr.lb_menu,
        'menu_rank',
        () => _modalRoute(appLeaderboardScreen()),
      ),
      MenuTile(
        tr.u_myColonies,
        'colony_levelup',
        () => _setOverlay(_Overlay.colonies),
      ),
      MenuTile(
        tr.u_myPlanet,
        'menu_home',
        () => _modalRoute(const HomePlanetScreen()),
      ),
      // 균열 런 (TASK 005): 잠겨 있으면 해금 조건만 알린다
      MenuTile(tr.rift_title, riftMenuIcon, () async {
        if (await riftUnlocked(w.profile)) {
          _modalRoute(RiftScreen(mainWorld: w));
        } else if (mounted) {
          toast(context, tr.rift_locked(tr.g_storyKillsTitle));
        }
      }),
      MenuTile(tr.u_ascendMenu, 'act_warp', _showAscend),
      MenuTile(
        tr.u_settings,
        'menu_settings',
        () => _modalRoute(const SettingsScreen()),
      ),
    ],
    quitLabel: tr.u_saveAndQuit,
    onQuit: () async {
      await SaveService.save(w);
      AppState.submitLeaderboard();
      if (mounted) Navigator.of(context).pop();
    },
    // 키보드 단축키 안내는 키보드가 있는 웹·데스크톱에서만
    footer: showKeyHints ? tr.u_keyboardHelp : null,
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
        ..color = unlocked && fraction == 0
            ? const Color(0xFF80D8FF)
            : Colors.white24,
    );
    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -pi / 2,
        2 * pi * fraction,
        true,
        Paint()..color = const Color(0xAA000000),
      );
    }
  }

  @override
  bool shouldRepaint(_CooldownPainter old) =>
      old.fraction != fraction || old.unlocked != unlocked;
}
