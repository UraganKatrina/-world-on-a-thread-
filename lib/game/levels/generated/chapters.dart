import 'dart:ui';

import '../../models/connection.dart';
import '../../models/level_definition.dart';
import '../../models/level_visuals.dart';
import '../../models/node_glyph.dart';
import '../../models/puzzle_node.dart';
import '../../models/puzzle_rules.dart';
import '../../models/win_condition.dart';
import 'level_spec.dart';

/// A group of levels that share a sky and a name.
class Chapter {
  const Chapter({
    required this.title,
    required this.skyTop,
    required this.skyBottom,
    required this.islandTint,
    this.accent = const Color(0xFFF2C46D),
  });

  final String title;
  final Color skyTop;
  final Color skyBottom;
  final Color islandTint;
  final Color accent;
}

/// Chapter 0 holds the hand-made levels; generated ones start at 1.
const List<Chapter> chapters = [
  Chapter(
    title: 'Пробуждение',
    skyTop: Color(0xFF14123A),
    skyBottom: Color(0xFFB79BD9),
    islandTint: Color(0xFF9C8FD8),
  ),
  Chapter(
    title: 'Тихие огни',
    skyTop: Color(0xFF1B1440),
    skyBottom: Color(0xFFE0A7BE),
    islandTint: Color(0xFFB59BE0),
  ),
  Chapter(
    title: 'Зеркальные пары',
    skyTop: Color(0xFF0D1A33),
    skyBottom: Color(0xFF86AFCF),
    islandTint: Color(0xFF9FB4E6),
    accent: Color(0xFFF4CB7E),
  ),
  Chapter(
    title: 'Ночной перевал',
    skyTop: Color(0xFF0A0E2A),
    skyBottom: Color(0xFF5A4A9C),
    islandTint: Color(0xFF9C8FD8),
  ),
  Chapter(
    title: 'Нитяные мотки',
    skyTop: Color(0xFF13183A),
    skyBottom: Color(0xFF7FA7C9),
    islandTint: Color(0xFF8FA6D8),
    accent: Color(0xFFBFE3F2),
  ),
  Chapter(
    title: 'Узкие тропы',
    skyTop: Color(0xFF1A1030),
    skyBottom: Color(0xFFC98FA0),
    islandTint: Color(0xFFB98FC9),
    accent: Color(0xFFFFD1A3),
  ),
  Chapter(
    title: 'Близнецы',
    skyTop: Color(0xFF0B1F2E),
    skyBottom: Color(0xFF7FC2B8),
    islandTint: Color(0xFF8FC1C9),
    accent: Color(0xFFE8F2B0),
  ),
  Chapter(
    title: 'Две звезды',
    skyTop: Color(0xFF080B22),
    skyBottom: Color(0xFF3E5A8C),
    islandTint: Color(0xFF8C9BD6),
    accent: Color(0xFFD7E4FF),
  ),
  Chapter(
    title: 'Лабиринт света',
    skyTop: Color(0xFF1E0F2A),
    skyBottom: Color(0xFFE3A06E),
    islandTint: Color(0xFFC79AD0),
    accent: Color(0xFFFFE0A0),
  ),
  Chapter(
    title: 'Сердце мира',
    skyTop: Color(0xFF05061A),
    skyBottom: Color(0xFF6B5BB5),
    islandTint: Color(0xFFA897E6),
  ),
];

/// Turns a generated spec into a playable level. [number] is the level's
/// position inside its chapter, starting at 1.
LevelDefinition buildGeneratedLevel(GeneratedLevelSpec spec, int number) {
  final chapter = chapters[spec.chapter];
  final light = spec.family == PuzzleFamily.light;
  final sources = {
    for (final n in spec.nodes)
      if (light && n.glyph == NodeGlyph.star) n.id,
  };
  final targets = [
    for (final n in spec.nodes)
      if (light && n.glyph == NodeGlyph.circle) n.id,
  ];
  return LevelDefinition(
    id: spec.id,
    chapter: spec.chapter,
    title: '${chapter.title} · $number',
    subtitle: _subtitle(spec, sources.length, targets.length),
    hint: _hint(spec),
    nodes: [
      for (final n in spec.nodes)
        PuzzleNode(
          id: n.id,
          position: Offset(n.x, n.y),
          glyph: n.glyph,
          islandId: n.id,
        ),
    ],
    allowedConnections: [
      for (final e in spec.edges) Connection(e.split('|')[0], e.split('|')[1]),
    ],
    rules: PuzzleRules(
      lightSources: sources,
      threadBudget: spec.budget,
      maxThreadsPerNode: spec.maxPerNode,
      forbidCrossing: spec.noCrossing,
      allowUntie: true,
    ),
    winCondition: light
        ? LightTargetsCondition(targets)
        : const AllNodesLinkedCondition(),
    visuals: LevelVisuals(
      skyTop: chapter.skyTop,
      skyBottom: chapter.skyBottom,
      accent: chapter.accent,
      mechanismCenter: generatedMechanismCenter,
      mechanismRadius: 0.045,
      portalCenter: const Offset(0.5, 0.13),
      showGuides: true,
      islands: [
        for (final (i, n) in spec.nodes.indexed)
          IslandSpec(
            id: n.id,
            center: Offset(n.x, n.y + 0.024),
            width: 0.15,
            height: 0.05,
            floatPhase: (i * 1.7) % 6.2,
            tint: n.glyph == NodeGlyph.circle
                ? chapter.islandTint
                : Color.lerp(chapter.islandTint, const Color(0xFFE6E0FA), 0.4)!,
          ),
      ],
    ),
  );
}

/// Generated layouts keep this point free for the mechanism.
const Offset generatedMechanismCenter = Offset(0.5, 0.67);

String _subtitle(GeneratedLevelSpec spec, int sources, int targets) {
  if (spec.family == PuzzleFamily.pairs) {
    return 'Пар: ${spec.nodes.length ~/ 2}';
  }
  final parts = [
    sources > 1 ? 'Две звезды' : 'Одна звезда',
    'фонарей: $targets',
    if (spec.budget != null) 'нитей в мотке: ${spec.budget}',
  ];
  return parts.join(', ');
}

String _hint(GeneratedLevelSpec spec) {
  if (spec.family == PuzzleFamily.pairs) {
    return 'Соедини одинаковые знаки так, чтобы нити не пересекались. У каждой '
        'точки одна нить. Начни с точки, у которой меньше всего вариантов.';
  }
  final tips = <String>[
    'Свет течёт по нитям от звезды. Зажги все круглые фонари.',
    if (spec.budget != null)
      'Нитей в мотке ровно ${spec.budget}: не трать их на путь к точке, '
          'которая уже светится.',
    if (spec.maxPerNode != null)
      'К одной точке можно привязать не больше ${spec.maxPerNode} нитей.',
    if (spec.noCrossing) 'Нити не могут пересекаться.',
    if (spec.nodes.any((n) => n.glyph == NodeGlyph.diamond)) 'Ромбы светиться не обязаны, но через них свет может разойтись в стороны.',
  ];
  return tips.join(' ');
}
