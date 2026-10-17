import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../models/level_definition.dart';
import '../models/puzzle_node.dart';

/// Maps normalized board coordinates to pixels and back.
///
/// The board keeps a portrait aspect ratio and is fitted inside the
/// available space, so the puzzle looks the same on phones, tablets and in
/// landscape windows; the sky simply extends around it.
class BoardGeometry {
  /// [padding] reserves room for UI (top bar, hint area, safe areas): the
  /// board is fitted inside what is left, the sky is still drawn everywhere.
  BoardGeometry(
    this.size, {
    this.padding = EdgeInsets.zero,
    this.aspect = boardAspect,
  }) : rect = fit(padding.deflateRect(Offset.zero & size), aspect);

  static const double boardAspect = 9 / 16;

  final Size size;
  final EdgeInsets padding;
  final double aspect;
  final Rect rect;

  static Rect fit(Rect area, double aspect) {
    final width = math.max(0.0, area.width);
    final height = math.max(0.0, area.height);
    var w = width;
    var h = w / aspect;
    if (h > height) {
      h = height;
      w = h * aspect;
    }
    return Rect.fromLTWH(
      area.left + (width - w) / 2,
      area.top + (height - h) / 2,
      w,
      h,
    );
  }

  Offset toScreen(Offset normalized) => Offset(
    rect.left + normalized.dx * rect.width,
    rect.top + normalized.dy * rect.height,
  );

  double scale(double normalized) => normalized * rect.width;

  /// Vertical drift of an island at [time], in normalized units.
  static double islandDrift(
    LevelDefinition level,
    String? islandId,
    Duration time, {
    bool still = false,
  }) {
    if (still) return 0;
    final island = level.visuals.islandById(islandId);
    if (island == null) return 0;
    final period = level.animation.floatPeriod.inMicroseconds;
    final phase = 2 * math.pi * (time.inMicroseconds % period) / period;
    return island.floatAmplitude * math.sin(phase + island.floatPhase);
  }

  Offset nodeCenter(
    LevelDefinition level,
    PuzzleNode node,
    Duration time, {
    bool still = false,
  }) {
    final drift = islandDrift(level, node.islandId, time, still: still);
    return toScreen(node.position.translate(0, drift));
  }

  double get nodeRadius => math.max(11, rect.width * 0.032);

  /// Touch target radius; never below 24 logical pixels (48 px diameter).
  double get touchRadius => math.max(24, rect.width * 0.075);

  /// Closest node within touch range of [point], or null.
  PuzzleNode? hitTest(
    LevelDefinition level,
    Offset point,
    Duration time, {
    bool still = false,
  }) {
    PuzzleNode? best;
    var bestDistance = double.infinity;
    for (final node in level.nodes) {
      final d = (nodeCenter(level, node, time, still: still) - point).distance;
      if (d <= touchRadius && d < bestDistance) {
        best = node;
        bestDistance = d;
      }
    }
    return best;
  }
}
