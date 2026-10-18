import 'dart:ui';

import '../models/connection.dart';
import '../models/level_definition.dart';
import '../models/level_visuals.dart';
import '../models/node_glyph.dart';
import '../models/puzzle_node.dart';
import '../models/puzzle_rules.dart';
import '../models/win_condition.dart';

/// Level 5 — «Маяк». Light and the no-crossing rule together: some tempting
/// threads cut off the only way to a far point.
final LevelDefinition lighthouseLevel = LevelDefinition(
  id: 'lighthouse',
  title: 'Маяк',
  subtitle: 'Свет должен дойти до каждого острова',
  hint:
      'Свет должен дойти до каждой точки, а нити не могут пересекаться. '
      'Прежде чем тянуть длинную нить, посмотри, не закроет ли она путь к '
      'нижнему острову.',
  nodes: const [
    PuzzleNode(
      id: 'beacon',
      position: Offset(0.42, 0.335),
      glyph: NodeGlyph.star,
      islandId: 'top',
    ),
    PuzzleNode(
      id: 'top',
      position: Offset(0.60, 0.33),
      glyph: NodeGlyph.circle,
      islandId: 'top',
    ),
    PuzzleNode(
      id: 'west_far',
      position: Offset(0.13, 0.50),
      glyph: NodeGlyph.circle,
      islandId: 'west',
    ),
    PuzzleNode(
      id: 'west_near',
      position: Offset(0.29, 0.505),
      glyph: NodeGlyph.circle,
      islandId: 'west',
    ),
    PuzzleNode(
      id: 'east_near',
      position: Offset(0.72, 0.56),
      glyph: NodeGlyph.circle,
      islandId: 'east',
    ),
    PuzzleNode(
      id: 'east_far',
      position: Offset(0.87, 0.565),
      glyph: NodeGlyph.circle,
      islandId: 'east',
    ),
    PuzzleNode(
      id: 'south_west',
      position: Offset(0.40, 0.79),
      glyph: NodeGlyph.circle,
      islandId: 'south',
    ),
    PuzzleNode(
      id: 'south_east',
      position: Offset(0.60, 0.79),
      glyph: NodeGlyph.circle,
      islandId: 'south',
    ),
  ],
  allowedConnections: [
    Connection('beacon', 'top'),
    Connection('beacon', 'west_near'),
    Connection('beacon', 'east_near'),
    Connection('west_far', 'west_near'),
    Connection('east_near', 'east_far'),
    Connection('top', 'west_near'),
    Connection('top', 'east_far'),
    Connection('west_near', 'south_east'),
    Connection('east_near', 'south_west'),
    Connection('east_far', 'south_east'),
  ],
  rules: const PuzzleRules(
    lightSources: {'beacon'},
    forbidCrossing: true,
    allowUntie: true,
  ),
  winCondition: const LightTargetsCondition([
    'top',
    'west_far',
    'west_near',
    'east_near',
    'east_far',
    'south_west',
    'south_east',
  ]),
  visuals: const LevelVisuals(
    skyTop: Color(0xFF0A0E2A),
    skyBottom: Color(0xFF5A4A9C),
    mechanismCenter: Offset(0.5, 0.585),
    mechanismRadius: 0.055,
    portalCenter: Offset(0.5, 0.14),
    showGuides: true,
    islands: [
      IslandSpec(
        id: 'top',
        center: Offset(0.51, 0.36),
        width: 0.34,
        height: 0.075,
        floatPhase: 0.9,
        tint: Color(0xFFC9B6EE),
      ),
      IslandSpec(
        id: 'west',
        center: Offset(0.21, 0.53),
        width: 0.3,
        height: 0.075,
        floatPhase: 2.6,
      ),
      IslandSpec(
        id: 'east',
        center: Offset(0.795, 0.59),
        width: 0.3,
        height: 0.075,
        floatPhase: 4.1,
      ),
      IslandSpec(
        id: 'south',
        center: Offset(0.5, 0.815),
        width: 0.34,
        height: 0.085,
        floatPhase: 5.5,
        tint: Color(0xFF9C8FD8),
      ),
    ],
  ),
);
