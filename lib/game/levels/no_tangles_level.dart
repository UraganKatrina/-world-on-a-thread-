import 'dart:ui';

import '../models/connection.dart';
import '../models/level_definition.dart';
import '../models/level_visuals.dart';
import '../models/node_glyph.dart';
import '../models/puzzle_node.dart';
import '../models/puzzle_rules.dart';
import '../models/win_condition.dart';

const _nodes = [
  PuzzleNode(
    id: 'n1',
    position: Offset(0.40, 0.335),
    glyph: NodeGlyph.triangle,
    islandId: 'north',
  ),
  PuzzleNode(
    id: 'n2',
    position: Offset(0.60, 0.335),
    glyph: NodeGlyph.circle,
    islandId: 'north',
  ),
  PuzzleNode(
    id: 'e1',
    position: Offset(0.77, 0.525),
    glyph: NodeGlyph.triangle,
    islandId: 'east',
  ),
  PuzzleNode(
    id: 'e2',
    position: Offset(0.90, 0.53),
    glyph: NodeGlyph.circle,
    islandId: 'east',
  ),
  PuzzleNode(
    id: 's1',
    position: Offset(0.40, 0.775),
    glyph: NodeGlyph.circle,
    islandId: 'south',
  ),
  PuzzleNode(
    id: 's2',
    position: Offset(0.60, 0.775),
    glyph: NodeGlyph.diamond,
    islandId: 'south',
  ),
  PuzzleNode(
    id: 'w1',
    position: Offset(0.10, 0.53),
    glyph: NodeGlyph.circle,
    islandId: 'west',
  ),
  PuzzleNode(
    id: 'w2',
    position: Offset(0.23, 0.525),
    glyph: NodeGlyph.diamond,
    islandId: 'west',
  ),
];

/// Every pair of nodes that share a sign.
List<Connection> _sameGlyphPairs() => [
  for (var i = 0; i < _nodes.length; i++)
    for (var j = i + 1; j < _nodes.length; j++)
      if (_nodes[i].glyph == _nodes[j].glyph)
        Connection(_nodes[i].id, _nodes[j].id),
];

/// Level 4 — «Без узелков». Each point takes exactly one thread, threads
/// may not cross, and four circles leave a choice: only one pairing works.
final LevelDefinition noTanglesLevel = LevelDefinition(
  id: 'no_tangles',
  title: 'Без узелков',
  subtitle: 'Нити не любят пересекаться',
  hint:
      'Соедини одинаковые знаки так, чтобы нити не пересекались. У каждой '
      'точки одна нить. Если путь закрыт, коснись обоих концов нити, чтобы '
      'отпустить её.',
  nodes: _nodes,
  allowedConnections: _sameGlyphPairs(),
  rules: const PuzzleRules(
    maxThreadsPerNode: 1,
    forbidCrossing: true,
    allowUntie: true,
  ),
  winCondition: const AllNodesLinkedCondition(),
  visuals: const LevelVisuals(
    skyTop: Color(0xFF0D1A33),
    skyBottom: Color(0xFF86AFCF),
    mechanismCenter: Offset(0.5, 0.555),
    portalCenter: Offset(0.5, 0.14),
    mechanismRadius: 0.06,
    accent: Color(0xFFF4CB7E),
    islands: [
      IslandSpec(
        id: 'north',
        center: Offset(0.5, 0.36),
        width: 0.34,
        height: 0.075,
        floatPhase: 0.4,
        tint: Color(0xFF9FB4E6),
      ),
      IslandSpec(
        id: 'east',
        center: Offset(0.835, 0.555),
        width: 0.27,
        height: 0.075,
        floatPhase: 2.2,
      ),
      IslandSpec(
        id: 'south',
        center: Offset(0.5, 0.80),
        width: 0.34,
        height: 0.08,
        floatPhase: 3.6,
        tint: Color(0xFFA8C3E8),
      ),
      IslandSpec(
        id: 'west',
        center: Offset(0.165, 0.555),
        width: 0.27,
        height: 0.075,
        floatPhase: 5.1,
      ),
    ],
  ),
);
