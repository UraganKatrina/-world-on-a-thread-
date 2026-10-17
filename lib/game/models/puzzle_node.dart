import 'dart:ui' show Offset;

import 'node_glyph.dart';

/// A glowing point the player can tap.
///
/// [position] is expressed in normalized board space: (0, 0) is the top-left
/// corner of the board and (1, 1) the bottom-right one. The board keeps a
/// fixed aspect ratio, so positions stay meaningful on every screen size.
class PuzzleNode {
  const PuzzleNode({
    required this.id,
    required this.position,
    required this.glyph,
    this.islandId,
  });

  final String id;
  final Offset position;
  final NodeGlyph glyph;

  /// Island the node rests on. The node floats together with its island.
  final String? islandId;

  @override
  String toString() => 'PuzzleNode($id)';
}
