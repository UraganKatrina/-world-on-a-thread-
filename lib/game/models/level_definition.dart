import 'connection.dart';
import 'level_visuals.dart';
import 'puzzle_node.dart';
import 'puzzle_rules.dart';
import 'win_condition.dart';

/// Static description of one puzzle. Adding a level means adding one of
/// these to the catalog; the engine and the renderer never change.
class LevelDefinition {
  const LevelDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.nodes,
    required this.allowedConnections,
    required this.winCondition,
    required this.visuals,
    required this.hint,
    this.rules = const PuzzleRules(),
    this.animation = const LevelAnimation(),
    this.chapter = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<PuzzleNode> nodes;
  final List<Connection> allowedConnections;
  final WinCondition winCondition;
  final LevelVisuals visuals;
  final String hint;
  final PuzzleRules rules;
  final LevelAnimation animation;

  /// Chapter the level belongs to in the level list.
  final int chapter;

  PuzzleNode nodeById(String id) => nodes.firstWhere((n) => n.id == id);

  bool hasNode(String id) => nodes.any((n) => n.id == id);

  /// Returns a list of problems; empty means the level is well-formed.
  List<String> validate() {
    final problems = <String>[];
    final ids = nodes.map((n) => n.id).toList();
    if (ids.toSet().length != ids.length) problems.add('duplicate node ids');
    for (final c in [...allowedConnections, ...winCondition.required]) {
      if (!hasNode(c.first) || !hasNode(c.second)) {
        problems.add('unknown node in $c');
      }
    }
    if (allowedConnections.toSet().length != allowedConnections.length) {
      problems.add('duplicate allowed connections');
    }
    for (final c in winCondition.required) {
      if (!allowedConnections.contains(c)) {
        problems.add('$c is required but not allowed');
      }
    }
    if (winCondition.goal(this) <= 0) problems.add('nothing to solve');
    for (final id in rules.lightSources) {
      if (!hasNode(id)) problems.add('unknown light source $id');
    }
    final budget = rules.threadBudget;
    if (budget != null && budget <= 0) problems.add('empty spool');
    final condition = winCondition;
    if (condition is LightTargetsCondition) {
      if (!rules.usesLight) problems.add('light targets without sources');
      for (final id in condition.targets) {
        if (!hasNode(id)) problems.add('unknown light target $id');
      }
    }
    for (final n in nodes) {
      if (n.islandId != null && visuals.islandById(n.islandId) == null) {
        problems.add('${n.id} references missing island ${n.islandId}');
      }
    }
    return problems;
  }
}
