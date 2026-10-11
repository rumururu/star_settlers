import 'dart:math';

import 'package:flutter/material.dart';

import 'game/cosmetics.dart';
import 'game/models.dart';
import 'game/save.dart';
import 'game/ships.dart';
import 'game/world.dart';
import 'game/profile.dart' show ScreenOrient;
import 'services/app_state.dart';
import 'services/orientation.dart';
import 'ui/chibi.dart';
import 'l10n/l.dart';
import 'ui/common.dart';
import 'ui/game_icons.dart';
import 'ui/game_screen.dart';
import 'ui/home_screen.dart';
import 'ui/leaderboard_screen.dart';
import 'ui/meta_screens.dart';
import 'ui/shop_screen.dart';
import 'ui/sprites.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 화면 방향은 설정(기본 세로)을 따른다. 프로필을 읽기 전에도 세로로 시작한다.
  await applyOrientation(ScreenOrient.portrait);
  await Future.wait([
    AppState.init().then((_) {
      Lang.apply(AppState.profile.language);
      return applyOrientation(AppState.profile.orientation);
    }),
    // 게임 화면 스프라이트 (함선 종류 × 스킨, 해적, 행성, 정거장)
    Sprites.load([
      for (final t in shipTypes)
        for (final s in shipSkins) 'ship_${t.id}_${s.id}',
      for (final k in PirateKind.values) k == PirateKind.jelly ? 'jelly' : 'pirate_${k.name}',
      for (final k in PlanetKind.values) 'planet_${k.name}',
      'station',
      'sun',
    ]),
  ]);
  AppState.money.confirm = (title, body) async {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return false;
    return confirmDialog(ctx, title, body, ok: tr.m_ok);
  };
  // 화면 글자는 전역 tr에서 읽으므로 Localizations 변경만으로는 다시 안 그려진다.
  // 언어가 바뀌면 모든 위젯을 다시 그린다 (상태는 유지 — 게임 중에 바꿔도 게임이 이어진다).
  Lang.changed.addListener(() {
    void rebuild(Element e) {
      e.markNeedsBuild();
      e.visitChildren(rebuild);
    }

    // 빌드 도중에 언어가 바뀌면 바로 표시하면 안 되므로, 지금 프레임이 끝난 뒤 다시 그린다
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) => binding.rootElement?.visitChildren(rebuild));
    binding.scheduleFrame();
  });
  // 크레딧이 모자란 비용 버튼 → 젬으로 채우기 (게임이 없으면 비활성)
  GemTopUp.gemsFor = (c) => AppState.world?.topUpGemsFor(c);
  GemTopUp.topUp = (c) => AppState.world?.topUpCredits(c) ?? false;
  GemTopUp.gems = () => AppState.profile.gems;
  GemTopUp.credits = () => AppState.world?.credits.floor() ?? 0;
  GemTopUp.openShop = () => navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const ShopScreen()));
  runApp(const StarSettlersApp());
}

class StarSettlersApp extends StatelessWidget {
  const StarSettlersApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Locale>(
        valueListenable: Lang.changed,
        builder: (context, locale, _) => _app(locale),
      );

  Widget _app(Locale locale) => MaterialApp(
        title: tr.appTitle,
        locale: locale,
        supportedLocales: L10n.supportedLocales,
        localizationsDelegates: L10n.localizationsDelegates,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: kAccent,
          fontFamily: Ts.family,
          useMaterial3: true,
          // 스타일을 안 준 글자도 토큰 크기를 따른다
          textTheme: const TextTheme(
            bodyLarge: Ts.body,
            bodyMedium: Ts.body,
            bodySmall: Ts.bodyDim,
            labelLarge: Ts.label,
            titleMedium: Ts.heading,
            titleLarge: Ts.title,
          ),
        ),
        // 접근성 큰 글자에서도 HUD·버튼이 넘치지 않게 글자 배율은 1.3배까지만
        builder: (context, child) =>
            MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: child ?? const SizedBox.shrink()),
        home: const TitleScreen(),
      );
}

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  bool _hasSave = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    WidgetsBinding.instance.addPostFrameCallback((_) => _dailyLogin());
  }

  Future<void> _refresh() async {
    final has = await SaveService.hasSave();
    if (mounted) setState(() => _hasSave = has);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _dailyLogin() async {
    final now = DateTime.now();
    final p = AppState.profile;
    final reward = p.pendingLogin(now);
    if (reward == null || !mounted) return;
    final first = p.lastLoginDay == 0;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        scrollable: true,
        backgroundColor: kPanelColor,
        title: Text(tr.m_loginTitle, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ChibiPortrait(style: ChibiStyle.advisor, size: 90),
            // 처음 받는 출석 보상이면 '오늘도 와주셨네요' 대신 첫 인사
            Text(keepAll(first ? tr.m_loginFirst : tr.m_loginWelcome), style: bodyStyle, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            iconValue('gem', '$reward', size: 28, style: Ts.title.copyWith(color: const Color(0xFFFF80AB))),
            gemText(keepAll(tr.m_loginStreakHint), style: dimStyle, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: Text(tr.m_claim),
          ),
        ],
      ),
    );
    p.claimLogin(now);
    AppState.play(Sfx.gem);
    await SaveService.saveProfile(p);
    if (mounted) setState(() {});
  }

  Future<void> _start(GameWorld world) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameScreen(world: world)));
    _refresh();
  }

  Future<void> _newGame() async {
    if (_hasSave) {
      final ok = await confirmDialog(context, tr.m_newGameTitle, tr.m_newGameBody, ok: tr.m_start);
      if (!ok) return;
      await SaveService.clearWorld();
    }
    await _start(GameWorld(profile: AppState.profile));
  }

  Future<void> _continue() async {
    final w = await SaveService.load(AppState.profile);
    if (w == null) {
      if (mounted) toast(context, tr.m_loadFailed);
      return;
    }
    await _start(w);
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    // 설정의 '데이터 초기화' 등으로 세이브가 사라졌을 수 있으니 이어하기 상태를 다시 읽는다
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppState.profile;
    final captain = ChibiStyle.captainIn(outfitById(p.outfit));
    return Scaffold(
      backgroundColor: const Color(0xFF070614),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/sprites/title_bg.jpg', fit: BoxFit.cover),
          // 아래쪽 버튼 영역이 그림에 묻히지 않게 어둡게
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00070614), Color(0x00070614), Color(0xCC070614), Color(0xF2070614)],
                stops: [0, 0.4, 0.62, 1],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, box) {
                // 가로(낮은 화면): 왼쪽에 로고·캐릭터, 오른쪽에 버튼. 세로로 쌓으면 높이가 모자란다.
                final wide = box.maxWidth > box.maxHeight && box.maxHeight < Layout.shortHeight;
                final menuW = wide ? box.maxWidth / 2 : box.maxWidth;
                final logoW = min(menuW * 0.82, 520.0);
                // 메뉴 6칸이 좁은 폰에서도 한 줄에 들어가게
                final tileW = min(76.0, (menuW - Space.l * 2 - Space.s * 5) / 6);
                final gemBtn = Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(Space.s),
                    child: GestureDetector(
                      onTap: () => _open(const ShopScreen()),
                      child: glass(iconValue('gem', '${p.gems}  ＋',
                          size: IconSz.inline, style: Ts.body.copyWith(color: const Color(0xFFFF80AB)))),
                    ),
                  ),
                );
                final logo = AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) =>
                      Transform.translate(offset: Offset(0, sin(_anim.value * 2 * pi) * 6), child: child),
                  child: Image.asset('assets/sprites/logo.png', width: logoW, fit: BoxFit.contain),
                );
                final titleLines = <Widget>[
                  // 로고가 이미 영문 제목이라, 부제는 로고와 다른 언어(한국어 등)일 때만
                  if (tr.appTitle != 'Star Settlers')
                    Text(tr.appTitle, style: Ts.title.copyWith(fontWeight: FontWeight.bold)),
                  if (p.honor > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.xs),
                      child: Text(tr.m_honorLine(p.honor, p.honor * 5, p.honor * 3),
                          textAlign: TextAlign.center, style: Ts.body.copyWith(color: const Color(0xFFB388FF))),
                    ),
                ];
                final chibis = AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) {
                    final t = _anim.value * 2 * pi;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Transform.translate(
                            offset: Offset(0, sin(t + 1) * 5),
                            child: const ChibiPortrait(style: ChibiStyle.advisor, size: 84)),
                        Transform.translate(
                            offset: Offset(0, sin(t) * 6), child: ChibiPortrait(style: captain, size: 116)),
                        Transform.translate(
                            offset: Offset(0, sin(t + 2) * 5),
                            child: const ChibiPortrait(style: ChibiStyle.pirate, size: 84)),
                      ],
                    );
                  },
                );
                final menu = <Widget>[
                  _menuButton(tr.m_continue, _hasSave ? _continue : null,
                      primary: _hasSave, leading: Icons.play_arrow_rounded),
                  const SizedBox(height: Space.m),
                  _menuButton(tr.m_newGame, _newGame, primary: !_hasSave),
                  const SizedBox(height: Space.l),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: Space.s,
                    children: [
                      _iconMenu('menu_home', tr.m_menuHome, () => _open(const HomePlanetScreen()), tileW),
                      _iconMenu('menu_shop', tr.m_menuShop, () => _open(const ShopScreen()), tileW),
                      _iconMenu('menu_quest', tr.m_menuQuest, () => _open(const DailyQuestScreen()), tileW,
                          badge: p.dailyClaimable > 0),
                      _iconMenu('menu_trophy', tr.m_menuAchievements, () => _open(const AchievementsScreen()), tileW,
                          badge: p.claimable.isNotEmpty),
                      _iconMenu('menu_rank', tr.lb_menuShort, () => _open(appLeaderboardScreen()), tileW),
                      _iconMenu('menu_settings', tr.m_menuSettings, () => _open(const SettingsScreen()), tileW),
                    ],
                  ),
                  const SizedBox(height: Space.l),
                ];
                if (wide) {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Spacer(),
                            // 낮은 화면에서는 로고가 남는 높이에 맞춰 줄어든다
                            Flexible(flex: 6, child: logo),
                            ...titleLines,
                            const SizedBox(height: Space.m),
                            Flexible(flex: 4, child: FittedBox(child: chibis)),
                            const SizedBox(height: Space.l),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            gemBtn,
                            const Spacer(),
                            ...menu,
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    gemBtn,
                    const Spacer(flex: 2),
                    logo,
                    ...titleLines,
                    const Spacer(flex: 3),
                    chibis,
                    const SizedBox(height: Space.m),
                    ...menu,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 타이틀의 두 버튼은 글자 길이와 무관하게 같은 크기
  /// ▶ 같은 기호는 언어 글꼴에 없으면 컬러 이모지로 바뀌므로 아이콘으로 그린다
  Widget _menuButton(String label, VoidCallback? onTap, {bool primary = false, IconData? leading}) =>
      actionBtn(
        label,
        onTap != null,
        onTap,
        primary: true,
        color: primary ? const Color(0xFF7E57C2) : const Color(0xFF2A2357),
        leadingIcon: leading,
      );

  Widget _iconMenu(String icon, String label, VoidCallback onTap, double width, {bool badge = false}) =>
      InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Badge(
          isLabelVisible: badge,
          smallSize: 12,
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(vertical: Space.s),
            decoration: BoxDecoration(
              color: const Color(0x991E1A4A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x557E57C2)),
            ),
            child: Column(children: [
              GameIcon(icon, size: 40),
              const SizedBox(height: Space.xs),
              FittedBox(child: Text(label, style: Ts.body)),
            ]),
          ),
        ),
      );
}
