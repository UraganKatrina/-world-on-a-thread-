/// Optional rules a level can switch on. Every rule is checked by the
/// puzzle engine, so new levels combine them without new code.
class PuzzleRules {
  const PuzzleRules({
    this.maxThreadsPerNode,
    this.forbidCrossing = false,
    this.lightSources = const {},
    this.allowUntie = false,
    this.threadBudget,
  });

  /// How many threads may meet at one node; null means unlimited.
  final int? maxThreadsPerNode;

  /// Threads may not cross each other (shared end points are fine).
  final bool forbidCrossing;

  /// Nodes that glow from the start. When non-empty, a new thread must start
  /// at a glowing node, and light flows along threads to the nodes they reach.
  final Set<String> lightSources;

  /// Tapping both ends of an existing thread releases it.
  final bool allowUntie;

  /// How many threads the spool holds for the whole level; null means
  /// unlimited. Untying a thread returns it to the spool.
  final int? threadBudget;

  bool get usesLight => lightSources.isNotEmpty;
}
