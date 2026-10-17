import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../persistence/key_value_store.dart';

/// Player preferences. Sound is split into a master switch, music and
/// effects so each can be turned off independently.
class GameSettings extends ChangeNotifier {
  GameSettings(this._store) {
    _load();
  }

  static const String storageKey = 'settings.v1';

  final KeyValueStore _store;

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _effectsEnabled = true;
  bool _reduceMotion = false;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get effectsEnabled => _effectsEnabled;
  bool get reduceMotion => _reduceMotion;

  bool get musicAudible => _soundEnabled && _musicEnabled;
  bool get effectsAudible => _soundEnabled && _effectsEnabled;

  set soundEnabled(bool v) => _update(() => _soundEnabled = v);
  set musicEnabled(bool v) => _update(() => _musicEnabled = v);
  set effectsEnabled(bool v) => _update(() => _effectsEnabled = v);
  set reduceMotion(bool v) => _update(() => _reduceMotion = v);

  void _load() {
    final raw = _store.getString(storageKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, Object?>;
      _soundEnabled = map['sound'] as bool? ?? true;
      _musicEnabled = map['music'] as bool? ?? true;
      _effectsEnabled = map['effects'] as bool? ?? true;
      _reduceMotion = map['reduceMotion'] as bool? ?? false;
    } catch (_) {
      // Corrupted settings: keep defaults.
    }
  }

  void _update(VoidCallback change) {
    change();
    notifyListeners();
    _store.setString(
      storageKey,
      jsonEncode({
        'sound': _soundEnabled,
        'music': _musicEnabled,
        'effects': _effectsEnabled,
        'reduceMotion': _reduceMotion,
      }),
    );
  }
}
