import '../../models/node_glyph.dart';

/// Kind of puzzle a generated level is.
enum PuzzleFamily {
  /// Carry light from the stars to every round lamp.
  light,

  /// Join every point to a twin with the same sign, without crossings.
  pairs,
}

/// One point of a generated level, in normalized board coordinates.
class SpecNode {
  const SpecNode(this.id, this.x, this.y, this.glyph);

  final String id;
  final double x;
  final double y;
  final NodeGlyph glyph;
}

/// Compact, data-only description of a level produced by
/// `tool/level_generator`. The generator proves each spec solvable with the
/// real rules before writing it; tests replay [solution] to check it again.
class GeneratedLevelSpec {
  const GeneratedLevelSpec({
    required this.id,
    required this.chapter,
    required this.family,
    required this.nodes,
    required this.edges,
    required this.solution,
    this.budget,
    this.maxPerNode,
    this.noCrossing = false,
  });

  final String id;

  /// Index into the chapter list, see `chapters.dart`.
  final int chapter;
  final PuzzleFamily family;
  final List<SpecNode> nodes;

  /// Allowed threads as `first|second` keys.
  final List<String> edges;

  /// One sequence of threads that solves the level.
  final List<String> solution;
  final int? budget;
  final int? maxPerNode;
  final bool noCrossing;
}
