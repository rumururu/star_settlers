import 'dart:math';

import 'package:flutter/material.dart';

import 'game/cosmetics.dart';
import 'game/models.dart';
import 'game/save.dart';
import 'game/ships.dart';
import 'game/world.dart';
import 'services/app_state.dart';
import 'ui/chibi.dart';
import 'ui/common.dart';
import 'ui/game_icons.dart';
import 'ui/game_screen.dart';
import 'ui/home_screen.dart';
import 'ui/meta_screens.dart';
import 'ui/shop_screen.dart';
import 'ui/sprites.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    AppState.init(),
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
    return confirmDialog(ctx, title, body, ok: '확인');
  };
  runApp(const StarSettlersApp());
}

class StarSettlersApp extends StatelessWidget {
  const StarSettlersApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: '우주 개척단',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: kAccent,
          fontFamily: 'Jua',
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
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: kPanelColor,
        title: const Text('📅 출석 보상', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ChibiPortrait(style: ChibiStyle.advisor, size: 90),
            const Text('오늘도 와주셨네요, 선장님!', style: bodyStyle),
            const SizedBox(height: 8),
            Text('⭐ $reward', style: Ts.title.copyWith(color: Color(0xFFFF80AB))),
            const Text('7일 연속 출석하면 ⭐50!', style: dimStyle),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('받기'),
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
      final ok = await confirmDialog(context, '새 게임',
          '기존 진행 상황이 지워져요.\n(젬, 꾸미기, 업적, 구매 상품은 유지돼요) 계속할까요?',
          ok: '시작');
      if (!ok) return;
      await SaveService.clearWorld();
    }
    await _start(GameWorld(profile: AppState.profile));
  }

  Future<void> _continue() async {
    final w = await SaveService.load(AppState.profile);
    if (w == null) {
      if (mounted) toast(context, '저장 데이터를 불러오지 못했어요.');
      return;
    }
    await _start(w);
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {});
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
                final logoW = min(box.maxWidth * 0.82, 520.0);
                // 메뉴 5칸이 좁은 폰에서도 한 줄에 들어가게
                final tileW = min(76.0, (box.maxWidth - Space.l * 2 - Space.s * 4) / 5);
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(Space.s),
                        child: GestureDetector(
                          onTap: () => _open(const ShopScreen()),
                          child: glass(iconValue('gem', '${p.gems}  ＋',
                              size: IconSz.inline, style: Ts.body.copyWith(color: const Color(0xFFFF80AB)))),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (context, child) => Transform.translate(
                          offset: Offset(0, sin(_anim.value * 2 * pi) * 6), child: child),
                      child: Image.asset('assets/sprites/logo.png', width: logoW),
                    ),
                    Text('우주 개척단', style: Ts.title.copyWith(fontWeight: FontWeight.bold)),
                    if (p.honor > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: Space.xs),
                        child: Text('🌌 은하 명예 ${p.honor}점 · 수입 +${p.honor * 5}% · 공격 +${p.honor * 3}%',
                            style: Ts.body.copyWith(color: const Color(0xFFB388FF))),
                      ),
                    const Spacer(flex: 3),
                    AnimatedBuilder(
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
                                offset: Offset(0, sin(t) * 6),
                                child: ChibiPortrait(style: captain, size: 116)),
                            Transform.translate(
                                offset: Offset(0, sin(t + 2) * 5),
                                child: const ChibiPortrait(style: ChibiStyle.pirate, size: 84)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: Space.m),
                    _menuButton('▶ 이어하기', _hasSave ? _continue : null, primary: _hasSave),
                    const SizedBox(height: Space.m),
                    _menuButton('✨ 새 게임', _newGame, primary: !_hasSave),
                    const SizedBox(height: Space.l),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: Space.s,
                      children: [
                        _iconMenu('menu_home', '내 행성', () => _open(const HomePlanetScreen()), tileW),
                        _iconMenu('menu_shop', '상점', () => _open(const ShopScreen()), tileW),
                        _iconMenu('menu_quest', '퀘스트', () => _open(const DailyQuestScreen()), tileW,
                            badge: p.dailyClaimable > 0),
                        _iconMenu('menu_trophy', '업적', () => _open(const AchievementsScreen()), tileW,
                            badge: p.claimable.isNotEmpty),
                        _iconMenu('menu_settings', '설정', () => _open(const SettingsScreen()), tileW),
                      ],
                    ),
                    const SizedBox(height: Space.l),
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
  Widget _menuButton(String label, VoidCallback? onTap, {bool primary = false}) => actionBtn(
        label,
        onTap != null,
        onTap,
        primary: true,
        color: primary ? const Color(0xFF7E57C2) : const Color(0xFF2A2357),
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
