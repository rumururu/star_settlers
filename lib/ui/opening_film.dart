import 'package:flutter/material.dart';

import '../l10n/l.dart';
import 'common.dart';

/// Generated film keyframes with camera movement; this is not a video decoder.
class OpeningFilm extends StatefulWidget {
  const OpeningFilm({
    super.key,
    required this.page,
    required this.onNext,
    required this.onSkip,
  });
  final int page;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<OpeningFilm> createState() => _OpeningFilmState();
}

class _OpeningFilmState extends State<OpeningFilm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _camera = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );
  bool _started = false;
  bool _reduceMotion = false;
  static const _images = [
    'haven_conference',
    'haven_defense',
    'haven_captain',
    'haven_severance',
  ];

  @override
  void initState() {
    super.initState();
    _camera.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          !_reduceMotion &&
          widget.page < _images.length - 1) {
        widget.onNext();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!_started) {
      _started = true;
      for (final name in _images) {
        precacheImage(AssetImage('assets/cinematics/$name.png'), context);
      }
      if (_reduceMotion) {
        _camera.value = .65;
      } else {
        _camera.forward();
      }
    } else if (_reduceMotion) {
      _camera.stop();
    }
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = [tr.n_open0, tr.n_open1, tr.n_open2, tr.n_open3];
    final speakers = [
      tr.u_spkAdvisor,
      tr.u_spkAdvisor,
      tr.u_spkCaptain,
      tr.n_enemyCommander,
    ];
    return BlockSemantics(
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _camera,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_camera.value);
                final wide = MediaQuery.sizeOf(context).aspectRatio > 1.2;
                // Portrait follows the action across the wide film frame.
                final alignX = wide
                    ? 0.0
                    : switch (widget.page) {
                        0 => -.55 + t * 1.3,
                        1 => -.35 + t * .8,
                        _ => -.25 + t * .6,
                      };
                const shake = 0.0;
                return Transform.translate(
                  offset: Offset(shake, shake * .4),
                  child: Transform.scale(
                    scale: _reduceMotion ? 1 : 1.025 + t * .045,
                    child: Image.asset(
                      'assets/cinematics/${_images[widget.page]}.png',
                      fit: BoxFit.cover,
                      alignment: Alignment(alignX, -.15),
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                );
              },
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, .15, .53, .76, 1],
                  colors: [
                    Color(0x77000000),
                    Colors.transparent,
                    Colors.transparent,
                    Color(0x66030916),
                    Color(0xF5030916),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Space.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        key: const ValueKey('story-skip'),
                        onPressed: widget.onSkip,
                        child: Text(
                          tr.n_skip,
                          style: Ts.bodyDim.copyWith(color: Colors.white70),
                        ),
                      ),
                    ),
                    const Spacer(),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * .40,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              speakers[widget.page],
                              style: Ts.body.copyWith(color: kSky),
                            ),
                            const SizedBox(height: Space.s),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                keepAll(lines[widget.page]),
                                style: Ts.heading.copyWith(
                                  height: 1.45,
                                  shadows: const [
                                    Shadow(color: Colors.black, blurRadius: 10),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.m),
                    Row(
                      children: [
                        const Spacer(),
                        FilledButton(
                          key: const ValueKey('story-next'),
                          onPressed: widget.onNext,
                          child: Text(
                            widget.page == _images.length - 1
                                ? tr.n_launch
                                : tr.n_next,
                            style: Ts.label,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
