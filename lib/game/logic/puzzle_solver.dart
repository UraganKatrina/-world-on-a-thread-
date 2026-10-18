import '../models/connection.dart';
import '../models/level_definition.dart';
import 'puzzle_session.dart';

/// Result of exhaustively exploring a level.
class SolverReport {
  const SolverReport({required this.shortest, required this.solutionCount});

  /// One shortest sequence of threads that solves the level, or null.
  final List<Connection>? shortest;

  /// Number of distinct solved sets of threads reachable by the rules.
  final int solutionCount;

  bool get solvable => shortest != null;
}

/// Breadth-first search over the threads a player can make, using the real
/// [PuzzleSession] rules. Levels are small, so this stays fast; it is used by
/// tests to prove every level can be finished, and can later power hints.
SolverReport solveLevel(LevelDefinition level, {int maxStates = 200000}) {
  String keyOf(Iterable<Connection> cs) =>
      (cs.map((c) => c.key).toList()..sort()).join(',');

  final seen = <String>{keyOf(const [])};
  final solved = <String>{};
  List<Connection>? shortest;
  var frontier = <List<Connection>>[[]];

  while (frontier.isNotEmpty && seen.length < maxStates) {
    final next = <List<Connection>>[];
    for (final path in frontier) {
      for (final c in level.allowedConnections) {
        if (path.contains(c)) continue;
        final session = PuzzleSession(level);
        for (final step in path) {
          session.tryConnect(step.first, step.second);
        }
        final outcome = session.tryConnect(c.first, c.second);
        if (outcome is! ThreadConnected) continue;
        final extended = [...path, c];
        final key = keyOf(extended);
        if (!seen.add(key)) continue;
        if (outcome.solvedNow) {
          solved.add(key);
          shortest ??= extended;
        } else {
          next.add(extended);
        }
      }
    }
    frontier = next;
  }
  return SolverReport(shortest: shortest, solutionCount: solved.length);
}
