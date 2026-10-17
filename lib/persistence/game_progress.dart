import 'dart:convert';

/// What the player has achieved. Serialized as JSON with a version field so
/// the format can evolve.
class GameProgress {
  const GameProgress({
    this.completedLevelIds = const {},
    this.lastOpenedLevelId,
  });

  static const int formatVersion = 1;

  final Set<String> completedLevelIds;
  final String? lastOpenedLevelId;

  bool isCompleted(String levelId) => completedLevelIds.contains(levelId);

  GameProgress markCompleted(String levelId) => GameProgress(
    completedLevelIds: {...completedLevelIds, levelId},
    lastOpenedLevelId: lastOpenedLevelId,
  );

  GameProgress withLastOpened(String levelId) => GameProgress(
    completedLevelIds: completedLevelIds,
    lastOpenedLevelId: levelId,
  );

  Map<String, Object?> toJson() => {
    'v': formatVersion,
    'completed': completedLevelIds.toList()..sort(),
    'lastOpened': lastOpenedLevelId,
  };

  String encode() => jsonEncode(toJson());

  /// Never throws: corrupted data falls back to a fresh start.
  static GameProgress decode(String? raw) {
    if (raw == null) return const GameProgress();
    try {
      final map = jsonDecode(raw) as Map<String, Object?>;
      final completed =
          (map['completed'] as List?)?.whereType<String>().toSet() ??
          <String>{};
      return GameProgress(
        completedLevelIds: completed,
        lastOpenedLevelId: map['lastOpened'] as String?,
      );
    } catch (_) {
      return const GameProgress();
    }
  }
}
