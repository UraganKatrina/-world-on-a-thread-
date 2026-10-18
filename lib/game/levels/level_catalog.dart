import '../models/level_definition.dart';
import 'awakening_level.dart';
import 'constellation_level.dart';
import 'first_light_level.dart';
import 'generated/chapters.dart';
import 'generated/generated_levels.g.dart';
import 'lighthouse_level.dart';
import 'moon_fork_level.dart';
import 'no_tangles_level.dart';
import 'spool_level.dart';

/// Ordered list of all levels. To add a level, create a [LevelDefinition]
/// and append it here — no engine or UI changes are needed.
class LevelCatalog {
  LevelCatalog(this.levels)
    : assert(levels.isNotEmpty),
      assert(levels.map((l) => l.id).toSet().length == levels.length);

  factory LevelCatalog.standard() => LevelCatalog([
    awakeningLevel,
    constellationLevel,
    firstLightLevel,
    noTanglesLevel,
    lighthouseLevel,
    spoolLevel,
    moonForkLevel,
    ..._generatedLevels(),
  ]);

  final List<LevelDefinition> levels;

  LevelDefinition get first => levels.first;

  int indexOf(String id) => levels.indexWhere((l) => l.id == id);

  LevelDefinition? byId(String id) {
    final i = indexOf(id);
    return i < 0 ? null : levels[i];
  }

  /// Level that follows [id], or null if [id] is the last one.
  LevelDefinition? nextAfter(String id) {
    final i = indexOf(id);
    if (i < 0 || i + 1 >= levels.length) return null;
    return levels[i + 1];
  }
}

/// Levels from `tool/level_generator`, numbered within their chapters.
List<LevelDefinition> _generatedLevels() {
  final counters = <int, int>{};
  return [
    for (final spec in generatedLevelSpecs)
      buildGeneratedLevel(
        spec,
        counters.update(spec.chapter, (n) => n + 1, ifAbsent: () => 1),
      ),
  ];
}
