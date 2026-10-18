import 'dart:ui';

import '../models/connection.dart';
import '../models/level_definition.dart';
import '../models/level_visuals.dart';
import '../models/node_glyph.dart';
import '../models/puzzle_node.dart';
import '../models/puzzle_rules.dart';
import '../models/win_condition.dart';

/// Level 6 — «Моток». Introduces the spool: only four threads for three
/// lamps, so the long ways round along both edges are too costly.
final LevelDefinition spoolLevel = LevelDefinition(
  id: 'spool',
  title: 'Моток',
  subtitle: 'Нитей ровно столько, сколько нужно',
  hint:
      'В мотке всего четыре нити. Ромбы сами не светятся, но через них свет '
      'может разойтись сразу в несколько сторон. Отпусти лишнюю нить, '
      'коснувшись обоих её концов.',
  nodes: const [
    PuzzleNode(
      id: 'star',
      position: Offset(0.5, 0.33),
      glyph: NodeGlyph.star,
      islandId: 'crown',
    ),
    PuzzleNode(
      id: 'north_west',
      position: Offset(0.24, 0.43),
      glyph: NodeGlyph.diamond,
      islandId: 'west_high',
    ),
    PuzzleNode(
      id: 'north_east',
      position: Offset(0.76, 0.43),
      glyph: NodeGlyph.diamond,
      islandId: 'east_high',
    ),
    PuzzleNode(
      id: 'hub',
      position: Offset(0.5, 0.53),
      glyph: NodeGlyph.diamond,
      islandId: 'heart',
    ),
    PuzzleNode(
      id: 'west',
      position: Offset(0.14, 0.6),
      glyph: NodeGlyph.circle,
      islandId: 'west',
    ),
    PuzzleNode(
      id: 'east',
      position: Offset(0.86, 0.6),
      glyph: NodeGlyph.circle,
      islandId: 'east',
    ),
    PuzzleNode(
      id: 'south',
      position: Offset(0.5, 0.8),
      glyph: NodeGlyph.circle,
      islandId: 'south',
    ),
  ],
  allowedConnections: [
    Connection('star', 'hub'),
    Connection('hub', 'west'),
    Connection('hub', 'east'),
    Connection('hub', 'south'),
    Connection('star', 'north_west'),
    Connection('north_west', 'west'),
    Connection('star', 'north_east'),
    Connection('north_east', 'east'),
    Connection('west', 'south'),
    Connection('east', 'south'),
  ],
  rules: const PuzzleRules(
    lightSources: {'star'},
    threadBudget: 4,
    allowUntie: true,
  ),
  winCondition: const LightTargetsCondition(['west', 'east', 'south']),
  visuals: const LevelVisuals(
    skyTop: Color(0xFF13183A),
    skyBottom: Color(0xFF7FA7C9),
    mechanismCenter: Offset(0.5, 0.67),
    mechanismRadius: 0.05,
    portalCenter: Offset(0.5, 0.14),
    showGuides: true,
    accent: Color(0xFFBFE3F2),
    islands: [
      IslandSpec(
        id: 'crown',
        center: Offset(0.5, 0.355),
        width: 0.24,
        height: 0.065,
        floatPhase: 0.4,
        tint: Color(0xFFB7D3EC),
      ),
      IslandSpec(
        id: 'west_high',
        center: Offset(0.24, 0.455),
        width: 0.16,
        height: 0.05,
        floatPhase: 3.5,
        tint: Color(0xFFB9C4EC),
      ),
      IslandSpec(
        id: 'west',
        center: Offset(0.15, 0.625),
        width: 0.24,
        height: 0.075,
        floatPhase: 2.2,
      ),
      IslandSpec(
        id: 'east_high',
        center: Offset(0.76, 0.455),
        width: 0.16,
        height: 0.05,
        floatPhase: 4.800000000000001,
        tint: Color(0xFFB9C4EC),
      ),
      IslandSpec(
        id: 'east',
        center: Offset(0.85, 0.625),
        width: 0.24,
        height: 0.075,
        floatPhase: 3.7,
      ),
      IslandSpec(
        id: 'heart',
        center: Offset(0.5, 0.555),
        width: 0.18,
        height: 0.06,
        floatPhase: 5.1,
        tint: Color(0xFFB7D3EC),
      ),
      IslandSpec(
        id: 'south',
        center: Offset(0.5, 0.825),
        width: 0.28,
        height: 0.075,
        floatPhase: 1.6,
        tint: Color(0xFF8FA6D8),
      ),
    ],
  ),
);
