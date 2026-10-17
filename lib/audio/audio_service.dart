import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../settings/game_settings.dart';
import 'tone_synth.dart';

enum SoundEffect { select, connect, reject, solved }

/// Plays music and effects, always respecting [GameSettings].
abstract class AudioService {
  void playEffect(SoundEffect effect);

  /// Starts ambient music if it is enabled. Safe to call repeatedly.
  void ensureMusic();

  void dispose();
}

/// Used in tests and whenever audio is unavailable.
class SilentAudioService implements AudioService {
  final List<SoundEffect> played = [];

  @override
  void playEffect(SoundEffect effect) => played.add(effect);

  @override
  void ensureMusic() {}

  @override
  void dispose() {}
}

/// Real implementation on top of `audioplayers` with synthesized sounds.
/// Any platform error is swallowed: sound is never required to play.
class SynthAudioService implements AudioService {
  SynthAudioService(this._settings) {
    const synth = ToneSynth();
    _effects = {
      SoundEffect.select: synth.toWav(synth.bell(880, 0.25, volume: 0.25)),
      SoundEffect.connect: synth.toWav(
        synth.arpeggio([659.25, 987.77], 0.09, 0.6, volume: 0.3),
      ),
      SoundEffect.reject: synth.toWav(synth.bell(293.66, 0.45, volume: 0.22)),
      SoundEffect.solved: synth.toWav(
        synth.arpeggio(
          [523.25, 659.25, 783.99, 1046.5],
          0.16,
          1.4,
          volume: 0.32,
        ),
      ),
    };
    _music = synth.toWav(synth.pad());
    _settings.addListener(_onSettingsChanged);
  }

  final GameSettings _settings;
  late final Map<SoundEffect, Uint8List> _effects;
  late final Uint8List _music;

  final List<AudioPlayer> _pool = [];
  int _next = 0;
  AudioPlayer? _musicPlayer;
  bool _musicPlaying = false;

  AudioPlayer _player() {
    if (_pool.length < 4) {
      final p = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _pool.add(p);
      return p;
    }
    return _pool[_next++ % _pool.length];
  }

  @override
  void playEffect(SoundEffect effect) {
    if (!_settings.effectsAudible) return;
    _guard(() async {
      final p = _player();
      await p.stop();
      await p.play(BytesSource(_effects[effect]!, mimeType: 'audio/wav'));
    });
  }

  @override
  void ensureMusic() {
    if (!_settings.musicAudible || _musicPlaying) return;
    _musicPlaying = true;
    _guard(() async {
      final p = _musicPlayer ??= AudioPlayer();
      await p.setReleaseMode(ReleaseMode.loop);
      await p.setVolume(0.6);
      await p.play(BytesSource(_music, mimeType: 'audio/wav'));
    }, onError: () => _musicPlaying = false);
  }

  void _onSettingsChanged() {
    if (!_settings.musicAudible && _musicPlaying) {
      _musicPlaying = false;
      _guard(() async => _musicPlayer?.stop());
    } else if (_settings.musicAudible) {
      ensureMusic();
    }
  }

  void _guard(Future<void> Function() body, {VoidCallback? onError}) {
    body().catchError((Object e) {
      debugPrint('Audio unavailable: $e');
      onError?.call();
    });
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    for (final p in _pool) {
      p.dispose();
    }
    _musicPlayer?.dispose();
  }
}
