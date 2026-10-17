import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_on_a_thread/game/levels/level_catalog.dart';
import 'package:world_on_a_thread/persistence/game_progress.dart';
import 'package:world_on_a_thread/persistence/key_value_store.dart';
import 'package:world_on_a_thread/persistence/progress_repository.dart';
import 'package:world_on_a_thread/settings/game_settings.dart';

void main() {
  final catalog = LevelCatalog.standard();

  test('only the first level is unlocked on a fresh install', () {
    final repo = ProgressRepository(MemoryStore(), catalog);
    expect(repo.isUnlocked('awakening'), isTrue);
    expect(repo.isUnlocked('constellation'), isFalse);
    expect(repo.resumeLevel.id, 'awakening');
  });

  test(
    'completing a level unlocks the next and moves "resume" forward',
    () async {
      final repo = ProgressRepository(MemoryStore(), catalog);
      await repo.markOpened('awakening');
      await repo.markCompleted('awakening');
      expect(repo.isUnlocked('constellation'), isTrue);
      expect(repo.resumeLevel.id, 'constellation');
    },
  );

  test('progress survives a restart through SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ProgressRepository(
      await SharedPreferencesStore.open(),
      catalog,
    );
    await first.markCompleted('awakening');
    await first.markOpened('constellation');

    final restored = ProgressRepository(
      await SharedPreferencesStore.open(),
      catalog,
    );
    expect(restored.progress.completedLevelIds, {'awakening'});
    expect(restored.progress.lastOpenedLevelId, 'constellation');
    expect(restored.resumeLevel.id, 'constellation');
  });

  test('corrupted data falls back to a fresh start', () {
    final store = MemoryStore()
      ..values[ProgressRepository.storageKey] = '{not json';
    final repo = ProgressRepository(store, catalog);
    expect(repo.progress.completedLevelIds, isEmpty);
    expect(GameProgress.decode('[1,2]').completedLevelIds, isEmpty);
  });

  test('reset wipes progress', () async {
    final repo = ProgressRepository(MemoryStore(), catalog);
    await repo.markCompleted('awakening');
    await repo.resetAll();
    expect(repo.isUnlocked('constellation'), isFalse);
  });

  test('sound settings are saved and restored independently', () async {
    final store = MemoryStore();
    final settings = GameSettings(store)
      ..musicEnabled = false
      ..effectsEnabled = true;
    expect(settings.musicAudible, isFalse);
    expect(settings.effectsAudible, isTrue);

    final restored = GameSettings(store);
    expect(restored.musicEnabled, isFalse);
    expect(restored.effectsEnabled, isTrue);

    restored.soundEnabled = false;
    expect(restored.effectsAudible, isFalse);
    expect(GameSettings(store).soundEnabled, isFalse);
  });
}
