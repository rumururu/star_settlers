import 'package:flutter/material.dart';

import '../game/missions.dart';
import '../game/campaign.dart';
import '../l10n/l.dart';
import '../game/profile.dart';
import '../services/app_state.dart';
import '../services/orientation.dart';
import 'chibi.dart';
import 'common.dart';
import 'opening_film.dart';

/// 중요한 이야기는 자동으로 사라지는 HUD 대사와 분리한다.
/// 게임의 기존 오버레이 안에서 표시하고, 일시정지는 GameScreen이 관리한다.
class StoryPanel extends StatefulWidget {
  const StoryPanel({
    super.key,
    required this.scene,
    required this.onDone,
    this.campaignSector,
  });

  final StoryScene scene;
  final VoidCallback onDone;
  final int? campaignSector;

  @override
  State<StoryPanel> createState() => _StoryPanelState();
}

class _StoryPanelState extends State<StoryPanel> {
  int _page = 0;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.scene == StoryScene.opening) {
      applyOrientation(ScreenOrient.landscape);
    }
  }

  @override
  void dispose() {
    if (widget.scene == StoryScene.opening) {
      applyOrientation(AppState.profile.orientation);
    }
    _scroll.dispose();
    super.dispose();
  }

  List<({String place, String speaker, String text, IconData icon, bool mina})>
  get _pages => switch (widget.scene) {
    StoryScene.opening => [
      (
        place: tr.n_signal,
        speaker: tr.n_signalSpeaker,
        text: tr.n_open0,
        icon: Icons.cell_tower,
        mina: false,
      ),
      (
        place: tr.n_haven,
        speaker: tr.u_spkAdvisor,
        text: tr.n_open1,
        icon: Icons.rocket,
        mina: true,
      ),
      (
        place: tr.n_departure,
        speaker: tr.u_spkCaptain,
        text: tr.n_open2,
        icon: Icons.rocket_launch,
        mina: false,
      ),
      (
        place: tr.n_departure,
        speaker: tr.n_enemyCommander,
        text: tr.n_open3,
        icon: Icons.warning,
        mina: false,
      ),
    ],
    StoryScene.mars => [
      (
        place: tr.n_mars,
        speaker: tr.n_settler,
        text: tr.n_mars0,
        icon: Icons.cottage,
        mina: false,
      ),
      (
        place: tr.n_mars,
        speaker: tr.u_spkAdvisor,
        text: tr.n_mars1,
        icon: Icons.public,
        mina: true,
      ),
      (
        place: tr.n_mars,
        speaker: tr.n_settler,
        text: tr.n_mars2,
        icon: Icons.nightlight_round,
        mina: false,
      ),
    ],
    StoryScene.firstTransmission => [
      (
        place: tr.n_transmission,
        speaker: tr.u_spkAdvisor,
        text: tr.n_transmission0,
        icon: Icons.hub,
        mina: true,
      ),
      (
        place: tr.n_earthReport,
        speaker: tr.n_earthReport,
        text: tr.n_transmission1,
        icon: Icons.public,
        mina: false,
      ),
    ],
    StoryScene.firstWarp => [
      (
        place: tr.n_gate,
        speaker: tr.u_spkAdvisor,
        text: tr.n_warp0,
        icon: Icons.hub,
        mina: true,
      ),
      (
        place: tr.n_gate,
        speaker: tr.u_spkCaptain,
        text: tr.n_warp1,
        icon: Icons.travel_explore,
        mina: false,
      ),
    ],
    StoryScene.campaign || StoryScene.ending || StoryScene.counterattack => [],
  };

  Widget _campaignPage() {
    final ending = widget.scene == StoryScene.ending;
    final reverse = widget.scene == StoryScene.counterattack;
    final sector = widget.campaignSector ?? 0;
    final imageSector = campaignSectors.contains(sector) ? sector : 1;
    final title = reverse
        ? tr.c_finalTitle
        : ending
        ? tr.c_endingTitle
        : tr.c_title(sector.toString());
    final body = reverse
        ? tr.c_reverseResult
        : ending
        ? tr.c_endingBody
        : tr.c_body(sector.toString());
    final landscape = MediaQuery.sizeOf(context).aspectRatio > 1.25;
    final picture = Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          reverse
              ? 'assets/cinematics/story_counterattack.webp'
              : ending
              ? 'assets/cinematics/story_ending.webp'
              : 'assets/cinematics/story_sector_${imageSector.toString().padLeft(2, '0')}.webp',
          fit: BoxFit.contain,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xCC070B1C)],
            ),
          ),
        ),
        Positioned(
          left: Space.l,
          right: Space.l,
          bottom: Space.l,
          child: Text(keepAll(title), style: Ts.title),
        ),
      ],
    );
    final copy = Padding(
      padding: const EdgeInsets.all(Space.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Text(keepAll(body), style: Ts.body.copyWith(height: 1.6)),
            ),
          ),
          const SizedBox(height: Space.m),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              key: const ValueKey('story-next'),
              onPressed: widget.onDone,
              child: Text(tr.m_continue, style: Ts.label),
            ),
          ),
        ],
      ),
    );
    return BlockSemantics(
      child: Material(
        color: const Color(0xFF070B1C),
        child: SafeArea(
          child: landscape
              ? Row(
                  children: [
                    Expanded(flex: 5, child: picture),
                    Expanded(flex: 4, child: copy),
                  ],
                )
              : Column(
                  children: [
                    Expanded(flex: 5, child: picture),
                    Expanded(flex: 4, child: copy),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _illustrated(
    ({String place, String speaker, String text, IconData icon, bool mina})
    page,
    int count,
    bool last,
  ) {
    final landscape = MediaQuery.sizeOf(context).aspectRatio > 1.25;
    final visual = Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(switch (widget.scene) {
          StoryScene.mars => 'assets/cinematics/story_colony.webp',
          StoryScene.firstTransmission =>
            'assets/cinematics/story_transmission.webp',
          StoryScene.firstWarp => 'assets/cinematics/story_warp.webp',
          _ => 'assets/cinematics/haven_conference.png',
        }, fit: BoxFit.contain),
        Positioned(
          left: Space.l,
          right: Space.l,
          top: Space.l,
          child: Row(
            children: [
              Expanded(child: Text(tr.n_title, style: Ts.bodyDim)),
              Text('${_page + 1} / $count', style: Ts.caption),
            ],
          ),
        ),
        Positioned(
          left: Space.l,
          right: Space.l,
          bottom: Space.l,
          child: Text(keepAll(page.place), style: Ts.title),
        ),
      ],
    );
    final dialogue = DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF100F24),
        border: Border(top: BorderSide(color: Color(0xFF384968))),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Space.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (page.mina) ...[
                  const ChibiPortrait(style: ChibiStyle.advisor, size: 48),
                  const SizedBox(width: Space.m),
                ],
                Expanded(child: Text(page.speaker, style: Ts.section)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    count,
                    (i) => Container(
                      margin: const EdgeInsets.only(left: 5),
                      width: i == _page ? 22 : 6,
                      height: 4,
                      decoration: BoxDecoration(
                        color: i == _page ? kSky : const Color(0xFF41415E),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.m),
            Expanded(
              child: Scrollbar(
                controller: _scroll,
                child: SingleChildScrollView(
                  controller: _scroll,
                  key: ValueKey('opening_$_page'),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      keepAll(page.text),
                      style: Ts.body.copyWith(height: 1.6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Space.s),
            OverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              spacing: Space.s,
              children: [
                TextButton(
                  key: const ValueKey('story-skip'),
                  onPressed: widget.onDone,
                  child: Text(tr.n_skip, style: Ts.bodyDim),
                ),
                FilledButton(
                  key: const ValueKey('story-next'),
                  onPressed: last
                      ? widget.onDone
                      : () {
                          _scroll.jumpTo(0);
                          setState(() => _page++);
                        },
                  child: Text(
                    last
                        ? (widget.scene == StoryScene.opening
                              ? tr.n_launch
                              : tr.m_continue)
                        : tr.n_next,
                    style: Ts.label,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return BlockSemantics(
      child: Material(
        color: const Color(0xFF070B1C),
        child: SafeArea(
          child: landscape
              ? Row(
                  children: [
                    Expanded(flex: 5, child: visual),
                    Expanded(flex: 4, child: dialogue),
                  ],
                )
              : Column(
                  children: [
                    Expanded(flex: 55, child: visual),
                    Expanded(flex: 45, child: dialogue),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scene == StoryScene.campaign ||
        widget.scene == StoryScene.ending ||
        widget.scene == StoryScene.counterattack) {
      return _campaignPage();
    }
    if (widget.scene == StoryScene.opening) {
      final film = OpeningFilm(
        key: ValueKey('film_$_page'),
        page: _page,
        onSkip: widget.onDone,
        onNext: () {
          if (_page == 3) {
            widget.onDone();
          } else {
            setState(() => _page++);
          }
        },
      );
      final media = MediaQuery.of(context);
      if (media.size.width < media.size.height) {
        // Browser and OS rotation-lock fallback: retain the complete wide shot.
        return RotatedBox(
          quarterTurns: 1,
          child: MediaQuery(
            data: media.copyWith(
              size: Size(media.size.height, media.size.width),
            ),
            child: film,
          ),
        );
      }
      return film;
    }
    final pages = _pages;
    return _illustrated(pages[_page], pages.length, _page == pages.length - 1);
  }
}
