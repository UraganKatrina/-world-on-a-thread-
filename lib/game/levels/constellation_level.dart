import 'dart:ui';

import '../models/connection.dart';
import '../models/level_definition.dart';
import '../models/level_visuals.dart';
import '../models/node_glyph.dart';
import '../models/puzzle_node.dart';
import '../models/win_condition.dart';

/// Level 2 — «Созвездие». Four pairs, any order, across four islands.
final LevelDefinition constellationLevel = LevelDefinition(
  id: 'constellation',
  title: 'Созвездие',
  subtitle: 'Острова рассыпались, но помнят друг друга',
  hint:
      'Здесь порядок не важен. Найди каждой точке её двойника на другом '
      'острове.',
  nodes: const [
    PuzzleNode(
      id: 'nw_star',
      position: Offset(0.12, 0.40),
      glyph: NodeGlyph.star,
      islandId: 'nw',
    ),
    PuzzleNode(
      id: 'nw_square',
      position: Offset(0.27, 0.395),
      glyph: NodeGlyph.square,
      islandId: 'nw',
    ),
    PuzzleNode(
      id: 'ne_circle',
      position: Offset(0.73, 0.355),
      glyph: NodeGlyph.circle,
      islandId: 'ne',
    ),
    PuzzleNode(
      id: 'ne_star',
      position: Offset(0.88, 0.36),
      glyph: NodeGlyph.star,
      islandId: 'ne',
    ),
    PuzzleNode(
      id: 'sw_circle',
      position: Offset(0.14, 0.715),
      glyph: NodeGlyph.circle,
      islandId: 'sw',
    ),
    PuzzleNode(
      id: 'sw_triangle',
      position: Offset(0.29, 0.705),
      glyph: NodeGlyph.triangle,
      islandId: 'sw',
    ),
    PuzzleNode(
      id: 'se_square',
      position: Offset(0.71, 0.765),
      glyph: NodeGlyph.square,
      islandId: 'se',
    ),
    PuzzleNode(
      id: 'se_triangle',
      position: Offset(0.86, 0.77),
      glyph: NodeGlyph.triangle,
      islandId: 'se',
    ),
  ],
  allowedConnections: [
    Connection('nw_star', 'ne_star'),
    Connection('nw_square', 'se_square'),
    Connection('ne_circle', 'sw_circle'),
    Connection('sw_triangle', 'se_triangle'),
  ],
  winCondition: AllConnectionsCondition([
    Connection('nw_star', 'ne_star'),
    Connection('nw_square', 'se_square'),
    Connection('ne_circle', 'sw_circle'),
    Connection('sw_triangle', 'se_triangle'),
  ]),
  visuals: const LevelVisuals(
    skyTop: Color(0xFF0F1838),
    skyBottom: Color(0xFF6E7FC9),
    mechanismCenter: Offset(0.5, 0.56),
    portalCenter: Offset(0.5, 0.14),
    accent: Color(0xFFF5CF7A),
    islands: [
      IslandSpec(
        id: 'nw',
        center: Offset(0.2, 0.425),
        width: 0.3,
        height: 0.075,
        floatPhase: 0.6,
      ),
      IslandSpec(
        id: 'ne',
        center: Offset(0.8, 0.385),
        width: 0.3,
        height: 0.075,
        floatPhase: 1.9,
        tint: Color(0xFF8EA2E0),
      ),
      IslandSpec(
        id: 'sw',
        center: Offset(0.215, 0.74),
        width: 0.3,
        height: 0.08,
        floatPhase: 3.3,
        tint: Color(0xFFB59BE0),
      ),
      IslandSpec(
        id: 'se',
        center: Offset(0.785, 0.795),
        width: 0.3,
        height: 0.08,
        floatPhase: 5.0,
      ),
    ],
  ),
);
