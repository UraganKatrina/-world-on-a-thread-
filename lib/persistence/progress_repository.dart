import 'package:flutter/foundation.dart';

import '../game/levels/level_catalog.dart';
import '../game/models/level_definition.dart';
import 'game_progress.dart';
import 'key_value_store.dart';

/// Loads, updates and saves [GameProgress], and answers "which levels are
/// open?" using the [LevelCatalog].
class ProgressRepository extends ChangeNotifier {
  ProgressRepository(this._store, this.catalog)
    : _progress = GameProgress.decode(_store.getString(storageKey));

  static const String storageKey = 'progress.v1';

  final KeyValueStore _store;
  final LevelCatalog catalog;
  GameProgress _progress;

  GameProgress get progress => _progress;

  /// A level is unlocked if it is the first one or the previous one is done.
  bool isUnlocked(String levelId) {
    final i = catalog.indexOf(levelId);
    if (i < 0) return false;
    if (i == 0) return true;
    return _progress.isCompleted(catalog.levels[i - 1].id);
  }

  /// Level the "Play" button should open: the last opened one if it is still
  /// unlocked and unfinished, otherwise the first unfinished unlocked level.
  LevelDefinition get resumeLevel {
    final last = _progress.lastOpenedLevelId;
    if (last != null && isUnlocked(last) && !_progress.isCompleted(last)) {
      return catalog.byId(last)!;
    }
    for (final level in catalog.levels) {
      if (isUnlocked(level.id) && !_progress.isCompleted(level.id)) {
        return level;
      }
    }
    return catalog.levels.last;
  }

  Future<void> markOpened(String levelId) =>
      _save(_progress.withLastOpened(levelId));

  Future<void> markCompleted(String levelId) =>
      _save(_progress.markCompleted(levelId));

  Future<void> resetAll() => _save(const GameProgress());

  Future<void> _save(GameProgress next) async {
    _progress = next;
    notifyListeners();
    await _store.setString(storageKey, next.encode());
  }
}
