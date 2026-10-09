import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../game/models.dart';

/// 효과음/배경음악. 실패해도 게임은 계속되도록 모든 호출을 감싼다.
class AudioService {
  AudioService._();
  static final instance = AudioService._();

  final _pools = <Sfx, _SfxPool>{};
  final _last = <Sfx, DateTime>{};
  AudioPlayer? _bgm;
  bool soundOn = true;
  bool musicOn = true;
  bool _ready = false;

  static String _file(Sfx s) => switch (s) {
        Sfx.shoot => 'shoot',
        Sfx.hit => 'hit',
        Sfx.explode => 'explode',
        Sfx.bigExplode => 'big_explode',
        Sfx.pickup => 'pickup',
        Sfx.coin => 'coin',
        Sfx.gem => 'gem',
        Sfx.upgrade => 'upgrade',
        Sfx.alarm => 'alarm',
        Sfx.warp => 'warp',
        Sfx.missile => 'missile',
        Sfx.shield => 'shield',
        Sfx.boost => 'boost',
        Sfx.hurt => 'hurt',
      };

  /// 같은 소리가 너무 자주 겹치지 않게 최소 간격(ms)
  static int _gap(Sfx s) => switch (s) {
        Sfx.shoot => 70,
        Sfx.hit || Sfx.pickup || Sfx.coin => 50,
        Sfx.explode => 60,
        _ => 120,
      };

  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    for (final s in Sfx.values) {
      try {
        _pools[s] = await _SfxPool.create(
          'audio/${_file(s)}.wav',
          s == Sfx.shoot || s == Sfx.hit ? 4 : 2,
          s == Sfx.shoot ? 0.5 : 0.9,
        );
      } catch (e) {
        debugPrint('sfx load failed: $s $e');
      }
    }
  }

  void play(Sfx s) {
    if (!soundOn) return;
    final now = DateTime.now();
    final last = _last[s];
    if (last != null && now.difference(last).inMilliseconds < _gap(s)) return;
    _last[s] = now;
    _pools[s]?.play();
  }

  Future<void> startMusic() async {
    if (!musicOn) return;
    try {
      _bgm ??= AudioPlayer()
        ..positionUpdater = null // 재생 위치를 안 쓰므로 매 프레임 조회를 끈다
        ..setReleaseMode(ReleaseMode.loop);
      if (_bgm!.state == PlayerState.playing) return;
      await _bgm!.play(AssetSource('audio/bgm.wav'), volume: 0.45);
    } catch (e) {
      debugPrint('bgm failed: $e');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _bgm?.stop();
    } catch (_) {}
  }

  Future<void> setMusic(bool on) async {
    musicOn = on;
    on ? await startMusic() : await stopMusic();
  }
}

/// 효과음 한 종류를 미리 읽어 둔 플레이어 몇 개로 돌려 쓴다.
/// audioplayers 기본 AudioPool은 플레이어마다 재생 위치를 매 프레임 플랫폼에 물어봐서
/// (FramePositionUpdater) 전투 중 소리가 겹치면 프레임이 떨어진다. 여기서는 그걸 끈다.
class _SfxPool {
  _SfxPool(this._players);
  final List<AudioPlayer> _players;
  int _next = 0;

  static Future<_SfxPool> create(String path, int count, double volume) async {
    final players = <AudioPlayer>[];
    for (var i = 0; i < count; i++) {
      final p = AudioPlayer()..positionUpdater = null;
      await p.setPlayerMode(PlayerMode.lowLatency);
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setVolume(volume);
      await p.setSource(AssetSource(path));
      players.add(p);
    }
    return _SfxPool(players);
  }

  void play() {
    final p = _players[_next];
    _next = (_next + 1) % _players.length;
    p.stop().then((_) => p.resume()).catchError((Object _) {});
  }
}
