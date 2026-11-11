import 'package:flutter/material.dart';

import '../game/codex.dart';
import '../game/surface.dart' show relicIds;
import '../game/codex_world.dart';
import '../game/cosmetics.dart';
import '../game/crew.dart';
import '../game/game_telemetry.dart';
import '../game/models.dart';
import '../game/save.dart';
import '../game/star_catalog.dart';
import '../game/system_traits.dart';
import '../game/world.dart';
import '../l10n/l.dart';
import '../services/app_state.dart';
import 'chibi.dart';
import 'common.dart';
import 'game_icons.dart';

/// 도감 (TASK 006): 적 · 행성 · 항성계 · 승무원 4탭 + 탭별 25/50/75/100% 수집 보상.
/// 타이틀([CodexTitleButton])과 일시정지 메뉴에서 연다. 기록은 [Profile.codex] (계정 단위).

const _bg = Color(0xFF0D0B26);
const _bar = Color(0xFF151236);
const _card = Color(0xFF1E1A4A);
const _cardFound = Color(0xFF26215C);
const _silhouette = Color(0xFF3A3470);
const _newDot = Color(0xFFFF5252);
const _mint = Color(0xFF7CFFB2);

/// 메뉴용 아이콘 (전용 도감 아이콘이 생기기 전까지 임무 목록 아이콘)
const codexMenuIcon = 'menu_codex';

/// 항목 이름 (토스트·카드 공통). 미발견 표시는 부르는 쪽이 '???'로 가린다.
String codexEntryName(CodexTab tab, String id) => switch (tab) {
  CodexTab.enemies => tr.codex_enemy(id),
  CodexTab.planets => tr.codex_planetKind(id),
  CodexTab.systems => systemName(int.tryParse(id) ?? 0),
  CodexTab.crew => () {
    final (role, r) = _crewOf(id);
    return '${role.label} ${'★' * r}';
  }(),
  CodexTab.relics => tr.srf_relicName(relicKey(id)),
};

/// 탭 이름 (유물 탭은 지표 탐험 문구)
String codexTabName(CodexTab t) =>
    t == CodexTab.relics ? tr.srf_codexTab : tr.codex_tab(t.name);

(CrewRole, int) _crewOf(String id) {
  final [role, r] = id.split(':');
  return (CrewRole.values.byName(role), int.parse(r));
}

/// 빨간 점 (숫자 없이)
Widget _dot() => Container(
  width: 10,
  height: 10,
  decoration: const BoxDecoration(color: _newDot, shape: BoxShape.circle),
);

class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: CodexTab.values.length,
    vsync: this,
    initialIndex: widget.initialTab,
  );

  /// 연 순간의 새 항목: 탭을 보면 저장된 표시는 지우지만, 이번에 보는 동안은 NEW로 남긴다
  late final Set<String> _fresh = {...AppState.profile.codex.fresh};

  Codex get _codex => AppState.profile.codex;

  @override
  void initState() {
    super.initState();
    GameTelemetry.emit(TelemetryEvent.codexOpen, _codex.claimable);
    _codex.markSeen(CodexTab.values[_tabs.index]);
    _tabs.addListener(() {
      _codex.markSeen(CodexTab.values[_tabs.index]);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    SaveService.saveProfile(AppState.profile);
    super.dispose();
  }

  Future<void> _claim(CodexTab tab, int pct) async {
    final p = AppState.profile;
    final r = _codex.claim(tab, pct, p);
    if (r == null) return;
    final w = AppState.world;
    if (w != null) deliverCodexRewards(w);
    AppState.play(Sfx.gem);
    await SaveService.saveProfile(p);
    if (!mounted) return;
    setState(() {});
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: kPanelColor,
        title: Text('${tr.codex_rewards} · $pct%', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (r.outfit)
              ChibiPortrait(style: ChibiStyle.captainIn(codexOutfit), size: 96),
            _RewardLine(reward: r, center: true),
            if (w == null) ...[
              const SizedBox(height: Space.s),
              Text(
                keepAll(tr.codex_claimedLater),
                style: dimStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          if (r.outfit)
            TextButton(
              onPressed: () {
                p.outfit = codexOutfitId;
                p.dirty = true;
                Navigator.pop(c);
              },
              child: Text(tr.m_equip),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: Text(tr.m_claim),
          ),
        ],
      ),
    );
    await SaveService.saveProfile(p);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = _codex;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bar,
        title: Text(tr.codex_title),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            for (final t in CodexTab.values)
              Tab(
                key: ValueKey('codex-tab-${t.name}'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (t == CodexTab.relics) ...[
                      const GameIcon('menu_relic', size: IconSz.inline),
                      const SizedBox(width: Space.xs),
                    ],
                    Text(codexTabName(t)),
                    if (c.freshIn(t) > 0 ||
                        codexMilestonesOf(t).any((m) => c.canClaim(t, m))) ...[
                      const SizedBox(width: Space.xs),
                      _dot(),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
      body: contentWidth(
        TabBarView(
          controller: _tabs,
          children: [for (final t in CodexTab.values) _tab(t)],
        ),
      ),
    );
  }

  Widget _tab(CodexTab tab) => ListView(
    key: PageStorageKey('codex-${tab.name}'),
    padding: const EdgeInsets.all(Space.m),
    children: [
      _header(tab),
      const SizedBox(height: Space.m),
      switch (tab) {
        CodexTab.enemies => _grid([
          for (final id in codexEnemyIds) _enemyCell(id),
        ], minCell: 150),
        CodexTab.planets => _planets(),
        CodexTab.systems => _systems(),
        CodexTab.crew => _crew(),
        CodexTab.relics => _grid([
          for (final id in relicIds) _relicCell(id),
        ], minCell: 150),
      },
    ],
  );

  // ---------- 진행도 + 마일스톤 ----------
  Widget _header(CodexTab tab) {
    final c = _codex;
    final pct = c.percent(tab);
    return Container(
      key: ValueKey('codex-header-${tab.name}'),
      padding: const EdgeInsets.all(Space.m),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr.codex_progress(c.foundCount(tab), c.total(tab), pct),
            style: Ts.heading,
          ),
          const SizedBox(height: Space.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 10,
              color: _mint,
              backgroundColor: Colors.white12,
            ),
          ),
          if (c.pendingCrew.isNotEmpty && AppState.world != null) ...[
            const SizedBox(height: Space.s),
            Text(
              keepAll(tr.codex_pendingCrew(c.pendingCrew.length)),
              style: dimStyle,
            ),
          ],
          const SizedBox(height: Space.s),
          // 마일스톤 4개: 받음(민트) · 받을 수 있음(분홍) · 아직(어둡게)
          Row(
            children: [
              for (final m in codexMilestonesOf(tab)) ...[
                if (m != codexMilestonesOf(tab).first)
                  const SizedBox(width: Space.xs),
                Expanded(child: _pill(tab, m)),
              ],
            ],
          ),
          const SizedBox(height: Space.s),
          _next(tab),
        ],
      ),
    );
  }

  Widget _pill(CodexTab tab, int pct) {
    final c = _codex;
    final claimed = c.isClaimed(tab, pct);
    final ready = c.canClaim(tab, pct);
    final color = claimed
        ? _mint
        : (ready ? const Color(0xFFFF80AB) : Colors.white24);
    return Container(
      key: ValueKey('codex-ms-${tab.name}-$pct'),
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      decoration: BoxDecoration(
        color: ready ? const Color(0xFF3A1E5C) : _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (claimed) const Icon(Icons.check, size: 14, color: _mint),
            Text(
              '$pct%',
              style: Ts.caption.copyWith(
                color: claimed || ready ? color : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 다음 보상 한 줄: 받을 수 있는 가장 낮은 단계, 없으면 아직 못 받은 가장 낮은 단계.
  /// 다 받았으면 도감 의상 장착 버튼(가지고 있고 안 입었을 때)만.
  Widget _next(CodexTab tab) {
    final c = _codex;
    final p = AppState.profile;
    final pct =
        codexMilestonesOf(tab).where((m) => c.canClaim(tab, m)).firstOrNull ??
        codexMilestonesOf(tab).where((m) => !c.isClaimed(tab, m)).firstOrNull;
    if (pct == null) {
      if (tab == CodexTab.relics || !p.ownedOutfits.contains(codexOutfitId)) {
        return const SizedBox.shrink();
      }
      return Row(
        children: [
          ChibiPortrait(
            style: ChibiStyle.captainIn(codexOutfit),
            size: Tap.min,
          ),
          const SizedBox(width: Space.s),
          Expanded(
            child: Text(
              keepAll(tr.codex_outfitName),
              style: Ts.body.copyWith(color: const Color(0xFF80D8FF)),
            ),
          ),
          const SizedBox(width: Space.s),
          p.outfit == codexOutfitId
              ? Text(tr.m_equipped, style: Ts.body.copyWith(color: _mint))
              : actionBtn(tr.m_equip, true, () async {
                  p.outfit = codexOutfitId;
                  await SaveService.saveProfile(p);
                  setState(() {});
                }),
        ],
      );
    }
    final ready = c.canClaim(tab, pct);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tr.codex_rewards} · $pct%',
                style: Ts.body.copyWith(color: kSky),
              ),
              const SizedBox(height: Space.xs),
              _RewardLine(reward: codexRewardOf(tab, pct)),
            ],
          ),
        ),
        const SizedBox(width: Space.s),
        KeyedSubtree(
          key: ValueKey('codex-claim-${tab.name}'),
          child: actionBtn(
            tr.m_claim,
            ready,
            () => _claim(tab, pct),
            color: const Color(0xFFAD1457),
          ),
        ),
      ],
    );
  }

  // ---------- 칸 ----------
  /// 같은 높이의 칸을 [cols]개씩 줄로 놓는다 (글자 배율이 커져도 칸이 늘어날 뿐 넘치지 않게)
  Widget _rows(List<Widget> cells, int cols) => Column(
    children: [
      for (var i = 0; i < cells.length; i += cols)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : Space.s),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = i; j < i + cols; j++) ...[
                  if (j > i) const SizedBox(width: Space.s),
                  Expanded(
                    child: j < cells.length ? cells[j] : const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ),
    ],
  );

  Widget _grid(
    List<Widget> cells, {
    required double minCell,
    int maxCols = 6,
  }) => LayoutBuilder(
    builder: (context, box) =>
        _rows(cells, (box.maxWidth / minCell).floor().clamp(2, maxCols)),
  );

  Widget _cell({
    required Key key,
    required bool found,
    required bool fresh,
    required Widget picture,
    required String title,
    String? sub,
  }) => Container(
    key: key,
    padding: const EdgeInsets.all(Space.s),
    decoration: BoxDecoration(
      color: found ? _cardFound : _card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: fresh
            ? _newDot
            : (found ? const Color(0x557E57C2) : Colors.white10),
      ),
    ),
    child: Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: IconSz.hero, height: IconSz.hero, child: picture),
              const SizedBox(height: Space.xs),
              Text(
                found ? keepAll(title) : '???',
                style: Ts.body.copyWith(
                  color: found ? Colors.white : Colors.white38,
                ),
                textAlign: TextAlign.center,
              ),
              if (sub != null)
                Text(
                  keepAll(sub),
                  style: Ts.caption,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        if (fresh) Positioned(top: 0, right: 0, child: _dot()),
      ],
    ),
  );

  /// 못 만난 항목의 그림: 어두운 실루엣
  Widget _shade(bool found, Widget child) => found
      ? child
      : ColorFiltered(
          colorFilter: const ColorFilter.mode(_silhouette, BlendMode.srcIn),
          child: child,
        );

  Widget _sprite(String name) => Image.asset(
    'assets/sprites/$name.png',
    fit: BoxFit.contain,
    filterQuality: FilterQuality.medium,
    errorBuilder: (_, _, _) => const Icon(
      Icons.help_outline,
      color: Colors.white24,
      size: IconSz.button,
    ),
  );

  Widget _enemyCell(String id) {
    final c = _codex;
    final found = c.found(CodexTab.enemies, id);
    final from = codexEnemySector(id);
    return _cell(
      key: ValueKey('codex-enemies-$id'),
      found: found,
      fresh: _fresh.contains('enemies:$id'),
      picture: _shade(found, _sprite(codexEnemySprite(id))),
      title: tr.codex_enemy(id),
      sub: found
          ? tr.codex_kills(c.kills[id] ?? 0)
          : (from > 0 ? tr.codex_fromSystem(from + 1) : null),
    );
  }

  Widget _relicCell(String id) {
    final found = _codex.found(CodexTab.relics, id);
    return _cell(
      key: ValueKey('codex-relics-$id'),
      found: found,
      fresh: _fresh.contains('relics:$id'),
      picture: _shade(found, _sprite(relicSprite(id))),
      title: tr.srf_relicName(relicKey(id)),
      sub: found ? tr.srf_relicDesc(relicKey(id)) : tr.srf_relicHint,
    );
  }

  Widget _planets() {
    final c = _codex;
    final settled = c.colonies.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _grid([
          for (final k in PlanetKind.values)
            _cell(
              key: ValueKey('codex-planets-${k.name}'),
              found: c.found(CodexTab.planets, k.name),
              fresh: _fresh.contains('planets:${k.name}'),
              picture: _shade(
                c.found(CodexTab.planets, k.name),
                _sprite('planet_${k.name}'),
              ),
              title: tr.codex_planetKind(k.name),
              sub: c.found(CodexTab.planets, k.name)
                  ? null
                  : tr.codex_planetHint,
            ),
        ], minCell: 150),
        const SizedBox(height: Space.l),
        Text(tr.codex_settled(settled.length), style: sectionStyle),
        const SizedBox(height: Space.s),
        if (settled.isEmpty)
          Text(keepAll(tr.codex_settledNone), style: dimStyle),
        for (final e in settled) _settledRow(e.key, e.value),
      ],
    );
  }

  Widget _settledRow(String key, int level) {
    final parts = key.split(':').map(int.tryParse).toList();
    if (parts.length != 3 || parts.contains(null)) {
      return const SizedBox.shrink();
    }
    final [sector!, index!, count!] = parts;
    final id = planetIdentity(sector, index, count);
    return Container(
      margin: const EdgeInsets.only(bottom: Space.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.m,
        vertical: Space.s,
      ),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: _sprite('planet_${id.kind.name}'),
          ),
          const SizedBox(width: Space.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id.name, style: Ts.body),
                Text(systemName(sector), style: dimStyle),
              ],
            ),
          ),
          const SizedBox(width: Space.s),
          Text('Lv.$level', style: Ts.heading.copyWith(color: _mint)),
        ],
      ),
    );
  }

  Widget _systems() {
    final c = _codex;
    // 다음에 갈 곳 하나만 힌트를 보여 준다
    final next = [
      for (var s = 0; s < catalogSystemCount; s++) s,
    ].where((s) => !c.systems.contains(s)).firstOrNull;
    return Column(
      children: [
        for (var s = 0; s < catalogSystemCount; s++) _systemRow(s, s == next),
      ],
    );
  }

  Widget _systemRow(int sector, bool isNext) {
    final c = _codex;
    final found = c.systems.contains(sector);
    final fresh = _fresh.contains('systems:$sector');
    final trait = systemTrait(sector);
    final String? detail = !found
        ? (isNext ? tr.codex_unreached : null)
        : trait == null
        ? tr.codex_home
        : tr.u_systemTrait(trait.name);
    return Container(
      key: ValueKey('codex-systems-$sector'),
      margin: const EdgeInsets.only(bottom: Space.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.m,
        vertical: Space.s,
      ),
      constraints: const BoxConstraints(minHeight: Tap.min),
      decoration: BoxDecoration(
        color: found ? _cardFound : _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fresh ? _newDot : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: found ? const Color(0xFF5E35B1) : _silhouette,
            ),
            child: Text(
              '${sector + 1}',
              style: Ts.caption.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: Space.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  found ? systemName(sector) : '???',
                  style: Ts.body.copyWith(
                    color: found ? Colors.white : Colors.white38,
                  ),
                ),
                if (detail != null) Text(keepAll(detail), style: dimStyle),
              ],
            ),
          ),
          if (fresh) ...[const SizedBox(width: Space.s), _dot()],
        ],
      ),
    );
  }

  Widget _crew() {
    final c = _codex;
    return _rows([
      for (final role in CrewRole.values)
        for (final r in codexCrewRarities)
          () {
            final id = crewCodexId(role, r);
            final found = c.found(CodexTab.crew, id);
            final look = CrewMember(
              id: 0,
              name: '',
              role: role,
              rarity: r,
              lookSeed: role.index * 7 + r * 31,
            );
            return _cell(
              key: ValueKey('codex-crew-$id'),
              found: found,
              fresh: _fresh.contains('crew:$id'),
              picture: _shade(
                found,
                ChibiPortrait(
                  style: ChibiStyle.forCrew(look),
                  size: IconSz.hero,
                ),
              ),
              title: role.label,
              sub: found ? '★' * r : tr.codex_crewHint,
            );
          }(),
    ], codexCrewRarities.length);
  }
}

/// 보상 한 줄: 크레딧·광석 아이콘 숫자, ★ 승무원, 의상 이름
class _RewardLine extends StatelessWidget {
  const _RewardLine({required this.reward, this.center = false});
  final CodexReward reward;
  final bool center;

  @override
  Widget build(BuildContext context) {
    const style = Ts.body;
    return Wrap(
      alignment: center ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Space.s,
      runSpacing: Space.xs,
      children: [
        if (reward.credits > 0)
          iconValue(
            'credits',
            compact(reward.credits),
            size: IconSz.inline,
            style: style,
          ),
        if (reward.ore > 0)
          iconValue(
            'ore',
            compact(reward.ore),
            size: IconSz.inline,
            style: style,
          ),
        if (reward.crewRarity > 0)
          Text(
            tr.codex_rewardCrew('★' * reward.crewRarity),
            style: style.copyWith(color: const Color(0xFFFFD54F)),
          ),
        if (reward.outfit)
          Text(
            keepAll(tr.codex_outfitName),
            style: style.copyWith(color: const Color(0xFF80D8FF)),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

/// 타이틀 화면의 '도감' 버튼 (새 항목·받을 보상이 있으면 빨간 점)
class CodexTitleButton extends StatelessWidget {
  const CodexTitleButton({super.key, required this.open});
  final Future<void> Function(Widget page) open;

  @override
  Widget build(BuildContext context) {
    final badge = AppState.profile.codex.badge;
    return TextButton.icon(
      key: const ValueKey('title-codex'),
      onPressed: () => open(const CodexScreen()),
      icon: Badge(
        isLabelVisible: badge > 0,
        backgroundColor: _newDot,
        smallSize: 10,
        child: const GameIcon(codexMenuIcon, size: IconSz.inline + 6),
      ),
      label: Text(tr.codex_title, style: Ts.body),
    );
  }
}

/// 게임 화면 위의 도감 층: 처음 열 때 기존 진행을 도감에 채우고, 받은 보상을 넣고,
/// 새 항목 토스트를 하나씩 띄운다. 화면 가운데 위쪽(월드 영역)이라 HUD 존을 덮지 않고 터치도 막지 않는다.
class CodexHud extends StatefulWidget {
  const CodexHud({super.key, required this.world, required this.frame});
  final GameWorld world;
  final Listenable frame;

  @override
  State<CodexHud> createState() => _CodexHudState();
}

class _CodexHudState extends State<CodexHud> {
  static const _show = Duration(milliseconds: 2600);
  final _clock = Stopwatch()..start();
  CodexFind? _current;
  Duration _until = Duration.zero;

  @override
  void initState() {
    super.initState();
    syncCodexFromWorld(widget.world);
    // 처음 채울 때 생긴 토스트는 없다 (조용히 채움). 이전 화면에서 남은 것만 보여 준다.
    widget.frame.addListener(_tick);
  }

  @override
  void dispose() {
    widget.frame.removeListener(_tick);
    super.dispose();
  }

  void _tick() {
    final c = widget.world.profile.codex;
    if (c.hasPending) deliverCodexRewards(widget.world);
    final now = _clock.elapsed;
    if (_current != null && now < _until) return;
    // 토스트는 대사와 같은 칸(HUD 대사 자리)에 나온다. 대사가 떠 있으면 끝날 때까지 기다린다.
    if (widget.world.dialogs.isNotEmpty) {
      _current = c.showing = null;
      return;
    }
    final next = c.toasts.isEmpty ? null : c.toasts.removeAt(0);
    if (next == null && _current == null) return;
    _current = c.showing = next;
    _until = now + _show;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 도감 새 항목 토스트. 게임 화면이 대사 칸([CodexHud]가 정한 [Codex.showing])에 그린다.
class CodexToastChip extends StatelessWidget {
  const CodexToastChip(this.f, {super.key});
  final CodexFind f;

  @override
  Widget build(BuildContext context) => Container(
                    key: ValueKey('codex-toast-${f.tab.name}-${f.id}'),
                    constraints: const BoxConstraints(maxWidth: 360),
                    margin: const EdgeInsets.symmetric(horizontal: Space.l),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.l,
                      vertical: Space.s,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xE6151236),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFFD54F)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GameIcon(codexMenuIcon, size: IconSz.inline + 4),
                        const SizedBox(width: Space.s),
                        Flexible(
                          child: Text(
                            keepAll(
                              tr.codex_newEntry(codexEntryName(f.tab, f.id)),
                            ),
                            style: Ts.body,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
}
