import 'dart:math';

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

  /// 배경음악 목록 (tool/gen_sounds.py가 만든다). 한 곡이 끝나면 방금 곡이 아닌 다른 곡을 고른다.
  static const tracks = [
    'audio/bgm.wav',
    'audio/music/drift.m4a',
    'audio/music/frontier.m4a',
    'audio/music/nebula.m4a',
    'audio/music/pursuit.m4a',
  ];
  int _track = -1;
  final _rng = Random();

  /// 보스가 있는 동안 반복하는 긴장감 있는 곡
  static const bossTrack = 'audio/music/boss.m4a';
  bool _boss = false;

  /// 게임 화면이 매 프레임 알려 준다. 바뀔 때만 곡을 바꾼다 (보스 → 보스 곡, 끝나면 목록의 다음 곡).
  Future<void> setBossFight(bool on) async {
    if (on == _boss) return;
    _boss = on;
    if (!musicOn || _bgm == null) return;
    await _playNext();
  }

  /// 다음 곡 번호: 첫 곡은 처음 곡, 그다음부터는 직전 곡을 피해 무작위
  static int nextTrack(int current, Random rng) {
    if (current < 0) return 0;
    final n = 1 + rng.nextInt(tracks.length - 1);
    return (current + n) % tracks.length;
  }
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

  /// 다른 앱의 음악을 멈추지 않는다. 오디오 포커스를 요청하지 않고(Android) 섞어서 재생한다(iOS ambient).
  /// 기본값(AUDIOFOCUS_GAIN)이면 효과음이 날 때마다 포커스를 가져가 다른 앱 음악이 끊긴다.
  /// iOS ambient는 무음 스위치를 따르고 항상 다른 앱 소리와 섞인다.
  static final mixContext = AudioContext(
    android: const AudioContextAndroid(
      audioFocus: AndroidAudioFocus.none,
      usageType: AndroidUsageType.game,
      contentType: AndroidContentType.sonification,
    ),
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );

  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    try {
      // 이후 만드는 모든 플레이어의 기본값 (각 플레이어에도 다시 넣는다)
      await AudioPlayer.global.setAudioContext(mixContext);
    } catch (e) {
      debugPrint('audio context failed: $e');
    }
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
      if (_bgm == null) {
        _bgm = AudioPlayer()
          ..positionUpdater = null // 재생 위치를 안 쓰므로 매 프레임 조회를 끈다
          ..setReleaseMode(ReleaseMode.stop);
        // 곡이 끝나면 다음 곡
        _bgm!.onPlayerComplete.listen((_) {
          if (musicOn) _playNext();
        });
      }
      await _bgm!.setAudioContext(mixContext);
      if (_bgm!.state == PlayerState.playing) return;
      // 멈췄다 다시 켜면 이어서 새 곡
      await _playNext();
    } catch (e) {
      debugPrint('bgm failed: $e');
    }
  }

  Future<void> _playNext() async {
    try {
      if (_boss) {
        await _bgm!.play(AssetSource(bossTrack), volume: 0.45);
        return;
      }
      _track = nextTrack(_track, _rng);
      await _bgm!.play(AssetSource(tracks[_track]), volume: 0.45);
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
      await p.setAudioContext(AudioService.mixContext);
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
