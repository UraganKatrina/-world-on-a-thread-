import 'dart:ui';

import '../models/connection.dart';
import '../models/level_definition.dart';
import '../models/level_visuals.dart';
import '../models/node_glyph.dart';
import '../models/puzzle_node.dart';
import '../models/puzzle_rules.dart';
import '../models/win_condition.dart';

/// Level 7 — «Лунная развилка». Five threads for four lamps: only one
/// diamond may be used, and the obvious way along both edges falls short.
final LevelDefinition moonForkLevel = LevelDefinition(
  id: 'moon_fork',
  title: 'Лунная развилка',
  subtitle: 'Пять нитей на четыре фонаря',
  hint:
      'Нитей хватит только на один ромб. Выбери ромб, от которого свет '
      'дойдёт до двух фонарей сразу, а остальные зажги друг от друга.',
  nodes: const [
    PuzzleNode(
      id: 'moon',
      position: Offset(0.5, 0.3),
      glyph: NodeGlyph.star,
      islandId: 'crown',
    ),
    PuzzleNode(
      id: 'west_gate',
      position: Offset(0.27, 0.44),
      glyph: NodeGlyph.diamond,
      islandId: 'west_high',
    ),
    PuzzleNode(
      id: 'east_gate',
      position: Offset(0.73, 0.44),
      glyph: NodeGlyph.diamond,
      islandId: 'east_high',
    ),
    PuzzleNode(
      id: 'core',
      position: Offset(0.5, 0.55),
      glyph: NodeGlyph.diamond,
      islandId: 'heart',
    ),
    PuzzleNode(
      id: 'west',
      position: Offset(0.12, 0.62),
      glyph: NodeGlyph.circle,
      islandId: 'west',
    ),
    PuzzleNode(
      id: 'east',
      position: Offset(0.88, 0.62),
      glyph: NodeGlyph.circle,
      islandId: 'east',
    ),
    PuzzleNode(
      id: 'south_west',
      position: Offset(0.33, 0.8),
      glyph: NodeGlyph.circle,
      islandId: 'south',
    ),
    PuzzleNode(
      id: 'south_east',
      position: Offset(0.67, 0.8),
      glyph: NodeGlyph.circle,
      islandId: 'south',
    ),
  ],
  allowedConnections: [
    Connection('moon', 'west_gate'),
    Connection('moon', 'east_gate'),
    Connection('moon', 'core'),
    Connection('west_gate', 'west'),
    Connection('east_gate', 'east'),
    Connection('core', 'south_west'),
    Connection('core', 'south_east'),
    Connection('west_gate', 'south_east'),
    Connection('east_gate', 'south_west'),
    Connection('west', 'south_west'),
    Connection('east', 'south_east'),
    Connection('west_gate', 'core'),
    Connection('east_gate', 'core'),
  ],
  rules: const PuzzleRules(
    lightSources: {'moon'},
    threadBudget: 5,
    allowUntie: true,
  ),
  winCondition: const LightTargetsCondition([
    'west',
    'east',
    'south_west',
    'south_east',
  ]),
  visuals: const LevelVisuals(
    skyTop: Color(0xFF080B22),
    skyBottom: Color(0xFF3E5A8C),
    mechanismCenter: Offset(0.5, 0.7),
    mechanismRadius: 0.05,
    portalCenter: Offset(0.5, 0.13),
    showGuides: true,
    accent: Color(0xFFD7E4FF),
    islands: [
      IslandSpec(
        id: 'crown',
        center: Offset(0.5, 0.325),
        width: 0.24,
        height: 0.065,
        floatPhase: 1.1,
        tint: Color(0xFFC6D2F2),
      ),
      IslandSpec(
        id: 'west_high',
        center: Offset(0.27, 0.465),
        width: 0.16,
        height: 0.05,
        floatPhase: 4.2,
        tint: Color(0xFFB9C4EC),
      ),
      IslandSpec(
        id: 'west',
        center: Offset(0.135, 0.645),
        width: 0.24,
        height: 0.075,
        floatPhase: 2.9,
      ),
      IslandSpec(
        id: 'east_high',
        center: Offset(0.73, 0.465),
        width: 0.16,
        height: 0.05,
        floatPhase: 5.699999999999999,
        tint: Color(0xFFB9C4EC),
      ),
      IslandSpec(
        id: 'east',
        center: Offset(0.865, 0.645),
        width: 0.24,
        height: 0.075,
        floatPhase: 4.6,
      ),
      IslandSpec(
        id: 'heart',
        center: Offset(0.5, 0.575),
        width: 0.16,
        height: 0.055,
        floatPhase: 0.3,
        tint: Color(0xFFC6D2F2),
      ),
      IslandSpec(
        id: 'south',
        center: Offset(0.5, 0.825),
        width: 0.44,
        height: 0.08,
        floatPhase: 3.4,
        tint: Color(0xFF8C9BD6),
      ),
    ],
  ),
);
