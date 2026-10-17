import 'dart:ui';

import '../models/connection.dart';
import '../models/level_definition.dart';
import '../models/level_visuals.dart';
import '../models/node_glyph.dart';
import '../models/puzzle_node.dart';
import '../models/win_condition.dart';

/// Level 1 — «Пробуждение».
///
/// Three islands, six points. Points with the same sign belong together and
/// the sockets on the central mechanism show the order: circle, triangle,
/// diamond.
final LevelDefinition awakeningLevel = LevelDefinition(
  id: 'awakening',
  title: 'Пробуждение',
  subtitle: 'Три острова ждут первых нитей',
  hint:
      'Знаки на механизме подсказывают порядок. Соедини одинаковые знаки, '
      'начиная с круга.',
  nodes: const [
    PuzzleNode(
      id: 'west_circle',
      position: Offset(0.14, 0.585),
      glyph: NodeGlyph.circle,
      islandId: 'west',
    ),
    PuzzleNode(
      id: 'west_diamond',
      position: Offset(0.29, 0.575),
      glyph: NodeGlyph.diamond,
      islandId: 'west',
    ),
    PuzzleNode(
      id: 'east_triangle',
      position: Offset(0.71, 0.545),
      glyph: NodeGlyph.triangle,
      islandId: 'east',
    ),
    PuzzleNode(
      id: 'east_diamond',
      position: Offset(0.86, 0.555),
      glyph: NodeGlyph.diamond,
      islandId: 'east',
    ),
    PuzzleNode(
      id: 'south_circle',
      position: Offset(0.41, 0.775),
      glyph: NodeGlyph.circle,
      islandId: 'south',
    ),
    PuzzleNode(
      id: 'south_triangle',
      position: Offset(0.59, 0.775),
      glyph: NodeGlyph.triangle,
      islandId: 'south',
    ),
  ],
  allowedConnections: [
    Connection('west_circle', 'south_circle'),
    Connection('south_triangle', 'east_triangle'),
    Connection('west_diamond', 'east_diamond'),
  ],
  winCondition: SequenceCondition([
    Connection('west_circle', 'south_circle'),
    Connection('south_triangle', 'east_triangle'),
    Connection('west_diamond', 'east_diamond'),
  ]),
  visuals: const LevelVisuals(
    skyTop: Color(0xFF161A47),
    skyBottom: Color(0xFFB79AD9),
    mechanismCenter: Offset(0.5, 0.42),
    portalCenter: Offset(0.5, 0.16),
    islands: [
      IslandSpec(
        id: 'west',
        center: Offset(0.21, 0.61),
        width: 0.32,
        height: 0.085,
        floatPhase: 0.0,
      ),
      IslandSpec(
        id: 'east',
        center: Offset(0.79, 0.575),
        width: 0.32,
        height: 0.08,
        floatPhase: 2.1,
      ),
      IslandSpec(
        id: 'south',
        center: Offset(0.5, 0.80),
        width: 0.36,
        height: 0.09,
        floatPhase: 4.0,
      ),
    ],
  ),
);
