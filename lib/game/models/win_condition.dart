import '../logic/light.dart';
import 'connection.dart';
import 'level_definition.dart';
import 'node_glyph.dart';

/// Rule that decides when a puzzle is solved.
///
/// Conditions are pure data plus pure functions, so they can be checked in
/// tests without any rendering.
sealed class WinCondition {
  const WinCondition();

  /// Specific threads that must exist, if the condition names any.
  List<Connection> get required => const [];

  /// Number of steps shown in the progress indicator.
  int goal(LevelDefinition level);

  /// How many of those steps are done.
  int progress(List<Connection> made, LevelDefinition level);

  /// Whether [connection] may be added right now, given the threads that
  /// already exist (in the order they were made).
  bool acceptsNext(Connection connection, List<Connection> made) => true;

  bool isSatisfied(List<Connection> made, LevelDefinition level) =>
      progress(made, level) >= goal(level);

  /// Glyph shown on the mechanism socket for step [index].
  NodeGlyph socketGlyph(LevelDefinition level, int index) => NodeGlyph.circle;
}

/// Every required connection must exist; order does not matter.
class AllConnectionsCondition extends WinCondition {
  const AllConnectionsCondition(this.required);

  @override
  final List<Connection> required;

  @override
  int goal(LevelDefinition level) => required.length;

  @override
  int progress(List<Connection> made, LevelDefinition level) =>
      required.where(made.contains).length;

  @override
  NodeGlyph socketGlyph(LevelDefinition level, int index) =>
      level.nodeById(required[index].first).glyph;
}

/// Required connections must be made exactly in the listed order.
class SequenceCondition extends AllConnectionsCondition {
  const SequenceCondition(super.required);

  @override
  bool acceptsNext(Connection connection, List<Connection> made) {
    final index = required.indexOf(connection);
    if (index < 0) return true; // not part of the sequence, order-agnostic
    final done = required.where(made.contains).length;
    return index == done;
  }

  @override
  bool isSatisfied(List<Connection> made, LevelDefinition level) {
    final inOrder = made.where(required.contains).toList();
    if (inOrder.length != required.length) return false;
    for (var i = 0; i < required.length; i++) {
      if (inOrder[i] != required[i]) return false;
    }
    return true;
  }
}

/// Every node must hold at least one thread. Progress is counted in pairs.
class AllNodesLinkedCondition extends WinCondition {
  const AllNodesLinkedCondition();

  @override
  int goal(LevelDefinition level) => (level.nodes.length / 2).ceil();

  @override
  int progress(List<Connection> made, LevelDefinition level) {
    final linked = {
      for (final c in made) ...[c.first, c.second],
    };
    return linked.length ~/ 2;
  }

  @override
  bool isSatisfied(List<Connection> made, LevelDefinition level) {
    final linked = {
      for (final c in made) ...[c.first, c.second],
    };
    return level.nodes.every((n) => linked.contains(n.id));
  }
}

/// Light from the level's sources must reach every target node.
class LightTargetsCondition extends WinCondition {
  const LightTargetsCondition(this.targets);

  final List<String> targets;

  @override
  int goal(LevelDefinition level) => targets.length;

  @override
  int progress(List<Connection> made, LevelDefinition level) {
    final lit = litNodes(level.rules.lightSources, made);
    return targets.where(lit.contains).length;
  }

  @override
  NodeGlyph socketGlyph(LevelDefinition level, int index) =>
      level.nodeById(targets[index]).glyph;
}
