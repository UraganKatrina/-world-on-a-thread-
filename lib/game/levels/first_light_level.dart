import 'dart:ui';

import '../models/connection.dart';
import '../models/level_definition.dart';
import '../models/level_visuals.dart';
import '../models/node_glyph.dart';
import '../models/puzzle_node.dart';
import '../models/puzzle_rules.dart';
import '../models/win_condition.dart';

/// Level 3 — «Первый свет». Introduces light: threads only grow from a
/// glowing point, and light flows along them to every point they reach.
final LevelDefinition firstLightLevel = LevelDefinition(
  id: 'first_light',
  title: 'Первый свет',
  subtitle: 'Звезда делится сиянием по нитям',
  hint:
      'Свет течёт по нитям. Начни от сияющей звезды и веди нить к соседней '
      'точке, а от неё дальше.',
  nodes: const [
    PuzzleNode(
      id: 'star',
      position: Offset(0.5, 0.385),
      glyph: NodeGlyph.star,
      islandId: 'crown',
    ),
    PuzzleNode(
      id: 'west',
      position: Offset(0.19, 0.545),
      glyph: NodeGlyph.circle,
      islandId: 'west',
    ),
    PuzzleNode(
      id: 'east',
      position: Offset(0.81, 0.535),
      glyph: NodeGlyph.circle,
      islandId: 'east',
    ),
    PuzzleNode(
      id: 'south_west',
      position: Offset(0.39, 0.785),
      glyph: NodeGlyph.circle,
      islandId: 'south',
    ),
    PuzzleNode(
      id: 'south_east',
      position: Offset(0.61, 0.785),
      glyph: NodeGlyph.circle,
      islandId: 'south',
    ),
  ],
  allowedConnections: [
    Connection('star', 'west'),
    Connection('star', 'east'),
    Connection('west', 'south_west'),
    Connection('east', 'south_east'),
    Connection('south_west', 'south_east'),
  ],
  rules: const PuzzleRules(lightSources: {'star'}, allowUntie: true),
  winCondition: const LightTargetsCondition([
    'west',
    'east',
    'south_west',
    'south_east',
  ]),
  visuals: const LevelVisuals(
    skyTop: Color(0xFF1B1440),
    skyBottom: Color(0xFFE0A7BE),
    mechanismCenter: Offset(0.5, 0.6),
    portalCenter: Offset(0.5, 0.15),
    showGuides: true,
    islands: [
      IslandSpec(
        id: 'crown',
        center: Offset(0.5, 0.41),
        width: 0.26,
        height: 0.07,
        floatPhase: 1.2,
        tint: Color(0xFFE8B9D0),
      ),
      IslandSpec(
        id: 'west',
        center: Offset(0.21, 0.57),
        width: 0.28,
        height: 0.08,
        floatPhase: 3.0,
      ),
      IslandSpec(
        id: 'east',
        center: Offset(0.79, 0.56),
        width: 0.28,
        height: 0.08,
        floatPhase: 0.2,
      ),
      IslandSpec(
        id: 'south',
        center: Offset(0.5, 0.81),
        width: 0.38,
        height: 0.09,
        floatPhase: 4.4,
        tint: Color(0xFFB59BE0),
      ),
    ],
  ),
);
