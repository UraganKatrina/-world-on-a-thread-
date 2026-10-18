// Level generator. Run from the project root:
//
//   flutter test tool/level_generator/generate_levels_test.dart
//
// It writes lib/game/levels/generated/generated_levels.g.dart. Every level is
// built with the real game rules and kept only if the search proves it
// solvable and it fits its chapter's difficulty window. The output is
// deterministic for a given seed.
// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:world_on_a_thread/game/levels/generated/chapters.dart';
import 'package:world_on_a_thread/game/levels/generated/level_spec.dart';
import 'package:world_on_a_thread/game/logic/puzzle_session.dart';
import 'package:world_on_a_thread/game/models/connection.dart';
import 'package:world_on_a_thread/game/models/level_definition.dart';
import 'package:world_on_a_thread/game/models/node_glyph.dart';

/// What one chapter asks of the generator.
class ChapterPlan {
  const ChapterPlan({
    required this.chapter,
    required this.count,
    required this.family,
    required this.minNodes,
    required this.maxNodes,
    required this.maxRate,
    this.minRate = 0,
    this.twoStars = false,
    this.budget = false,
    this.maxPerNode = const [null],
    this.noCrossing = const [false],
    this.relayChance = 0.2,
    this.maxSolutions,
  });

  final int chapter;
  final int count;
  final PuzzleFamily family;
  final int minNodes;
  final int maxNodes;

  /// Share of random play-throughs that win; lower is harder.
  final double minRate;
  final double maxRate;
  final bool twoStars;
  final bool budget;
  final List<int?> maxPerNode;
  final List<bool> noCrossing;
  final double relayChance;

  /// Upper bound on distinct winning thread sets, when it matters.
  final int? maxSolutions;
}

const plans = [
  ChapterPlan(
    chapter: 1,
    count: 10,
    family: PuzzleFamily.light,
    minNodes: 6,
    maxNodes: 7,
    minRate: 0.3,
    maxRate: 0.85,
    maxPerNode: [2],
    relayChance: 0.1,
  ),
  ChapterPlan(
    chapter: 2,
    count: 10,
    family: PuzzleFamily.pairs,
    minNodes: 6,
    maxNodes: 8,
    maxRate: 0.7,
    maxSolutions: 1,
  ),
  ChapterPlan(
    chapter: 3,
    count: 10,
    family: PuzzleFamily.light,
    minNodes: 7,
    maxNodes: 8,
    maxRate: 0.6,
    noCrossing: [true],
    maxPerNode: [null, 2],
  ),
  ChapterPlan(
    chapter: 4,
    count: 10,
    family: PuzzleFamily.light,
    minNodes: 7,
    maxNodes: 9,
    minRate: 0.06,
    maxRate: 0.4,
    budget: true,
    relayChance: 0.3,
    maxSolutions: 3,
  ),
  ChapterPlan(
    chapter: 5,
    count: 10,
    family: PuzzleFamily.light,
    minNodes: 8,
    maxNodes: 9,
    minRate: 0.03,
    maxRate: 0.3,
    budget: true,
    maxPerNode: [2],
    relayChance: 0.3,
    maxSolutions: 2,
  ),
  ChapterPlan(
    chapter: 6,
    count: 10,
    family: PuzzleFamily.pairs,
    minNodes: 8,
    maxNodes: 10,
    maxRate: 0.35,
    maxSolutions: 1,
  ),
  ChapterPlan(
    chapter: 7,
    count: 10,
    family: PuzzleFamily.light,
    minNodes: 8,
    maxNodes: 10,
    minRate: 0.02,
    maxRate: 0.3,
    twoStars: true,
    budget: true,
    noCrossing: [true, false],
    relayChance: 0.25,
    maxSolutions: 2,
  ),
  ChapterPlan(
    chapter: 8,
    count: 10,
    family: PuzzleFamily.light,
    minNodes: 9,
    maxNodes: 10,
    maxRate: 0.15,
    budget: true,
    noCrossing: [true, false],
    maxPerNode: [null, 2, 3],
    relayChance: 0.3,
    maxSolutions: 2,
  ),
  ChapterPlan(
    chapter: 9,
    count: 7,
    family: PuzzleFamily.light,
    minNodes: 10,
    maxNodes: 11,
    maxRate: 0.08,
    budget: true,
    twoStars: true,
    noCrossing: [true],
    maxPerNode: [null, 2],
    relayChance: 0.3,
    maxSolutions: 1,
  ),
  ChapterPlan(
    chapter: 9,
    count: 6,
    family: PuzzleFamily.pairs,
    minNodes: 10,
    maxNodes: 12,
    maxRate: 0.15,
    maxSolutions: 1,
  ),
];

const rows = [0.30, 0.42, 0.54, 0.67, 0.80];
const cols = [0.1, 0.3, 0.5, 0.7, 0.9];
const pairGlyphs = [
  NodeGlyph.triangle,
  NodeGlyph.square,
  NodeGlyph.circle,
  NodeGlyph.diamond,
  NodeGlyph.star,
];

double _dist(SpecNode p, SpecNode q) {
  final dx = p.x - q.x, dy = (p.y - q.y) * 16 / 9;
  return sqrt(dx * dx + dy * dy);
}

double _segDist(double px, double py, SpecNode a, SpecNode b) {
  const k = 16 / 9;
  final vx = b.x - a.x, vy = (b.y - a.y) * k;
  var t = ((px - a.x) * vx + (py * k - a.y * k) * vy) / (vx * vx + vy * vy);
  t = t.clamp(0.0, 1.0);
  final cx = a.x + t * vx - px, cy = a.y * k + t * vy - py * k;
  return sqrt(cx * cx + cy * cy);
}

bool _edgeClear(List<SpecNode> nodes, SpecNode a, SpecNode b) {
  for (final o in nodes) {
    if (o == a || o == b) continue;
    if (_segDist(o.x, o.y, a, b) < 0.07) return false;
  }
  final m = generatedMechanismCenter;
  return _segDist(m.dx, m.dy, a, b) >= 0.06;
}

/// Search result for one candidate.
class Analysis {
  Analysis(this.solution, this.solutions, this.complete);
  final List<Connection>? solution;
  final int solutions;
  final bool complete;
}

/// Depth-first search over thread sets with the real session. Threads are
/// added and untied on one session, so every rule is the game's own.
Analysis analyse(LevelDefinition level, {int maxStates = 150000}) {
  final edges = level.allowedConnections;
  final session = PuzzleSession(level);
  final seen = <int>{};
  final solved = <int>{};
  List<Connection>? first;
  var complete = true;
  final path = <Connection>[];

  void visit(int mask) {
    if (seen.length >= maxStates) {
      complete = false;
      return;
    }
    for (var i = 0; i < edges.length; i++) {
      if (mask & (1 << i) != 0) continue;
      final next = mask | (1 << i);
      if (seen.contains(next)) continue;
      final c = edges[i];
      if (session.rejectionFor(c) != null) continue;
      seen.add(next);
      session.tryConnect(c.first, c.second);
      path.add(c);
      if (session.isSolved) {
        solved.add(next);
        first ??= List.of(path);
        session.reset();
        path.removeLast();
        for (final p in path) {
          session.tryConnect(p.first, p.second);
        }
        continue;
      }
      visit(next);
      path.removeLast();
      session.tryConnect(c.first, c.second); // untie
    }
  }

  visit(0);
  return Analysis(first, solved.length, complete);
}

double randomWinRate(LevelDefinition level, Random r, int runs) {
  var won = 0;
  for (var k = 0; k < runs; k++) {
    final s = PuzzleSession(level);
    while (!s.isSolved) {
      final moves = level.allowedConnections
          .where((c) => s.rejectionFor(c) == null)
          .toList();
      if (moves.isEmpty) break;
      final m = moves[r.nextInt(moves.length)];
      s.tryConnect(m.first, m.second);
    }
    if (s.isSolved) won++;
  }
  return won / runs;
}

class Candidate {
  Candidate(this.spec, this.rate);
  final GeneratedLevelSpec spec;
  final double rate;
}

Candidate? tryCandidate(ChapterPlan plan, Random r, String id) {
  final size = plan.minNodes + r.nextInt(plan.maxNodes - plan.minNodes + 1);
  final slots = <(int, int)>[
    for (var y = 0; y < rows.length; y++)
      for (var x = 0; x < cols.length; x++)
        if (!(y == 3 && x == 2)) (y, x),
  ]..shuffle(r);
  var chosen = slots.take(size).toList();
  if (!chosen.any((s) => s.$1 == 0)) return null;
  if (plan.twoStars && !chosen.any((s) => s.$1 == 4)) return null;
  chosen.sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);

  double jitter() => (r.nextDouble() - 0.5) * 0.05;
  final light = plan.family == PuzzleFamily.light;
  final topIndex = chosen.indexWhere((s) => s.$1 == 0);
  final bottomIndex = chosen.lastIndexWhere((s) => s.$1 == 4);
  final pairCount = size ~/ 2;
  if (!light && size.isOdd) return null;
  // Signs come in groups of four (and one group of two or six when the
  // count needs it), so every point has several possible twins.
  final groups = <int>[];
  var left = pairCount * 2;
  while (left > 0) {
    final g = left == 6 || left == 2 ? left : 4;
    groups.add(g);
    left -= g;
  }
  final glyphs = [
    for (final (i, g) in groups.indexed)
      for (var k = 0; k < g; k++) pairGlyphs[i % pairGlyphs.length],
  ]..shuffle(r);

  final nodes = <SpecNode>[];
  for (final (i, s) in chosen.indexed) {
    final NodeGlyph glyph;
    if (!light) {
      glyph = glyphs[i];
    } else if (i == topIndex || (plan.twoStars && i == bottomIndex)) {
      glyph = NodeGlyph.star;
    } else {
      glyph = r.nextDouble() < plan.relayChance
          ? NodeGlyph.diamond
          : NodeGlyph.circle;
    }
    final x = (cols[s.$2] + jitter()).clamp(0.08, 0.92);
    final y = rows[s.$1] + jitter() * 0.6;
    nodes.add(
      SpecNode(
        String.fromCharCode(97 + i),
        double.parse(x.toStringAsFixed(3)),
        double.parse(y.toStringAsFixed(3)),
        glyph,
      ),
    );
  }
  final lamps = nodes.where((n) => n.glyph == NodeGlyph.circle).length;
  if (light && (lamps < 3 || lamps < size * 0.4)) return null;

  final edges = <String>[];
  for (var a = 0; a < nodes.length; a++) {
    for (var b = a + 1; b < nodes.length; b++) {
      final p = nodes[a], q = nodes[b];
      if (!_edgeClear(nodes, p, q)) continue;
      if (light) {
        if (_dist(p, q) > 0.42 || r.nextDouble() > 0.68) continue;
      } else {
        if (p.glyph != q.glyph || _dist(p, q) > 0.75) continue;
      }
      edges.add(Connection(p.id, q.id).key);
    }
  }
  final minEdges = light ? size - 1 : size ~/ 2 + 2;
  if (edges.length < minEdges || edges.length > 20) return null;

  final maxPer = plan.family == PuzzleFamily.pairs
      ? 1
      : plan.maxPerNode[r.nextInt(plan.maxPerNode.length)];
  final noCrossing = plan.family == PuzzleFamily.pairs
      ? true
      : plan.noCrossing[r.nextInt(plan.noCrossing.length)];

  GeneratedLevelSpec specWith(int? budget, List<String> solution) =>
      GeneratedLevelSpec(
        id: id,
        chapter: plan.chapter,
        family: plan.family,
        nodes: nodes,
        edges: edges,
        solution: solution,
        budget: budget,
        maxPerNode: maxPer,
        noCrossing: noCrossing,
      );

  var level = buildGeneratedLevel(specWith(null, const []), 1);
  if (level.validate().isNotEmpty) return null;
  var analysis = analyse(level);
  if (analysis.solution == null) return null;

  int? budget;
  if (plan.budget) {
    // The spool holds exactly as many threads as the shortest answer. Find
    // that length by tightening the budget until the level stops being
    // solvable.
    var best = analysis.solution!.length;
    for (var b = best - 1; b >= 1; b--) {
      final tight = buildGeneratedLevel(specWith(b, const []), 1);
      final a = analyse(tight);
      if (a.solution == null) break;
      best = b;
    }
    final targets = nodes.where((n) => n.glyph == NodeGlyph.circle).length;
    if (best <= targets) return null; // the spool must actually bite
    budget = best;
    level = buildGeneratedLevel(specWith(budget, const []), 1);
    analysis = analyse(level);
    if (analysis.solution == null) return null;
  }
  final max = plan.maxSolutions;
  if (max != null && (!analysis.complete || analysis.solutions > max)) {
    return null;
  }
  final rate = randomWinRate(level, r, 120);
  if (rate < plan.minRate || rate > plan.maxRate) return null;
  return Candidate(
    specWith(budget, [for (final c in analysis.solution!) c.key]),
    rate,
  );
}

String emit(List<GeneratedLevelSpec> specs) {
  final b = StringBuffer()
    ..writeln('// GENERATED by tool/level_generator. Do not edit by hand.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln("import '../../models/node_glyph.dart';")
    ..writeln("import 'level_spec.dart';")
    ..writeln()
    ..writeln('const List<GeneratedLevelSpec> generatedLevelSpecs = [');
  for (final s in specs) {
    b
      ..writeln('  GeneratedLevelSpec(')
      ..writeln("    id: '${s.id}',")
      ..writeln('    chapter: ${s.chapter},')
      ..writeln('    family: PuzzleFamily.${s.family.name},')
      ..writeln('    nodes: [');
    for (final n in s.nodes) {
      b.writeln(
        "      SpecNode('${n.id}', ${n.x}, ${n.y}, NodeGlyph.${n.glyph.name}),",
      );
    }
    b
      ..writeln('    ],')
      ..writeln('    edges: [${s.edges.map((e) => "'$e'").join(', ')}],')
      ..writeln('    solution: [${s.solution.map((e) => "'$e'").join(', ')}],');
    if (s.budget != null) b.writeln('    budget: ${s.budget},');
    if (s.maxPerNode != null) b.writeln('    maxPerNode: ${s.maxPerNode},');
    if (s.noCrossing) b.writeln('    noCrossing: true,');
    b.writeln('  ),');
  }
  b.writeln('];');
  return b.toString();
}

void main() {
  test('generate levels', () {
    final r = Random(20261018);
    final specs = <GeneratedLevelSpec>[];
    var number = 8; // levels 1–7 are hand-made
    for (final plan in plans) {
      final picked = <Candidate>[];
      final layouts = <String>{};
      var attempts = 0;
      while (picked.length < plan.count) {
        attempts++;
        if (attempts > 40000) {
          fail('chapter ${plan.chapter}: only ${picked.length} levels found');
        }
        final c = tryCandidate(plan, r, 'tmp');
        if (c == null) continue;
        final key = c.spec.edges.join(',') + c.spec.nodes.length.toString();
        if (!layouts.add(key)) continue;
        picked.add(c);
      }
      // Easier levels first within a chapter.
      picked.sort((a, b) => b.rate.compareTo(a.rate));
      for (final c in picked) {
        final s = c.spec;
        specs.add(
          GeneratedLevelSpec(
            id: 'isle_${number.toString().padLeft(3, '0')}',
            chapter: s.chapter,
            family: s.family,
            nodes: s.nodes,
            edges: s.edges,
            solution: s.solution,
            budget: s.budget,
            maxPerNode: s.maxPerNode,
            noCrossing: s.noCrossing,
          ),
        );
        print(
          'level $number: chapter ${s.chapter} ${s.family.name} '
          'nodes=${s.nodes.length} rate=${c.rate.toStringAsFixed(2)} '
          'budget=${s.budget} max=${s.maxPerNode} cross=${s.noCrossing}',
        );
        number++;
      }
      print('chapter ${plan.chapter}: $attempts attempts');
    }
    File('lib/game/levels/generated/generated_levels.g.dart')
        .writeAsStringSync(emit(specs));
  }, timeout: const Timeout(Duration(hours: 1)));
}
