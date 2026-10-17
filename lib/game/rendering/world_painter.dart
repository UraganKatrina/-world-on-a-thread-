import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../logic/puzzle_session.dart';
import '../models/connection.dart';
import '../models/level_definition.dart';
import '../models/level_visuals.dart';
import '../models/node_glyph.dart';
import 'board_geometry.dart';
import 'board_visual_state.dart';
import 'glyph_painter.dart';

/// Draws the whole scene with plain Canvas calls: sky, distant portal,
/// central mechanism, floating islands, threads and nodes.
class WorldPainter extends CustomPainter {
  WorldPainter({
    required this.session,
    required this.effects,
    required this.clock,
    required this.reduceMotion,
    this.padding = EdgeInsets.zero,
  }) : super(repaint: Listenable.merge([clock, session]));

  final PuzzleSession session;
  final BoardVisualState effects;
  final ValueNotifier<Duration> clock;
  final bool reduceMotion;
  final EdgeInsets padding;

  LevelDefinition get level => session.level;
  LevelVisuals get visuals => level.visuals;

  /// 0..1 progress of [duration] since [start]; 1 when motion is reduced.
  double _since(Duration? start, Duration duration) {
    if (start == null) return 0;
    if (reduceMotion) return 1;
    final t = (clock.value - start).inMicroseconds / duration.inMicroseconds;
    return t.clamp(0.0, 1.0);
  }

  double get _victory =>
      _since(effects.solvedAt, level.animation.victorySequence);

  double get _seconds => reduceMotion ? 0 : clock.value.inMicroseconds / 1e6;

  @override
  void paint(Canvas canvas, Size size) {
    final g = BoardGeometry(size, padding: padding);
    _paintSky(canvas, size, g);
    _paintPortal(canvas, g);
    _paintBeam(canvas, g);
    _paintMechanism(canvas, g);
    for (final island in visuals.islands) {
      _paintIsland(canvas, g, island);
    }
    _paintRejected(canvas, g);
    for (final c in session.connections) {
      _paintThread(canvas, g, c);
    }
    for (final node in level.nodes) {
      _paintNode(canvas, g, node.id);
    }
  }

  // ---------------------------------------------------------------- sky

  void _paintSky(Canvas canvas, Size size, BoardGeometry g) {
    final full = Offset.zero & size;
    final v = _victory;
    final bottom = Color.lerp(
      visuals.skyBottom,
      const Color(0xFFF3D9C8),
      v * 0.35,
    )!;
    canvas.drawRect(
      full,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            visuals.skyTop,
            Color.lerp(visuals.skyTop, bottom, 0.55)!,
            bottom,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(full),
    );

    // Soft mist clouds.
    final mist = Paint()
      ..color = const Color(0x22FFFFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    for (var i = 0; i < 4; i++) {
      final drift = math.sin(_seconds * 0.05 + i * 1.7) * 0.03;
      final c = g.toScreen(
        Offset(0.15 + i * 0.25 + drift, 0.3 + (i.isEven ? 0.05 : 0.38)),
      );
      canvas.drawOval(
        Rect.fromCenter(center: c, width: g.scale(0.5), height: g.scale(0.14)),
        mist,
      );
    }

    // Stars: deterministic positions, gentle twinkle.
    final rnd = math.Random(level.id.hashCode);
    final star = Paint();
    for (var i = 0; i < 70; i++) {
      final p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height * 0.6,
      );
      final twinkle =
          0.45 +
          0.55 *
              (0.5 + 0.5 * math.sin(_seconds * (0.6 + rnd.nextDouble()) + i));
      final fade = 1 - (p.dy / (size.height * 0.6));
      star.color = Colors.white.withValues(alpha: 0.75 * twinkle * fade);
      canvas.drawCircle(p, 0.6 + rnd.nextDouble() * 1.1, star);
    }
  }

  // ---------------------------------------------------------------- portal

  void _paintPortal(Canvas canvas, BoardGeometry g) {
    final c = g.toScreen(visuals.portalCenter);
    final w = g.scale(visuals.portalSize.width);
    final h = g.scale(visuals.portalSize.height);
    final rect = Rect.fromCenter(center: c, width: w, height: h);
    final arch = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top + w / 2)
      ..arcToPoint(
        Offset(rect.right, rect.top + w / 2),
        radius: Radius.circular(w / 2),
      )
      ..lineTo(rect.right, rect.bottom)
      ..close();

    final open = Curves.easeInOut.transform(
      ((_victory - 0.35) / 0.5).clamp(0.0, 1.0),
    );
    final idle = 0.5 + 0.5 * math.sin(_seconds * 0.8);

    // Distant floating plinth under the portal.
    canvas.drawOval(
      Rect.fromCenter(
        center: rect.bottomCenter.translate(0, g.scale(0.012)),
        width: w * 1.6,
        height: g.scale(0.03),
      ),
      Paint()..color = const Color(0x553B3576),
    );

    // Halo.
    canvas.drawPath(
      arch,
      Paint()
        ..color = visuals.accent.withValues(
          alpha: 0.12 + 0.08 * idle + 0.5 * open,
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 + 30 * open),
    );
    // Inside: closed is a dark veil, open is warm light.
    canvas.drawPath(
      arch,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF1B1C4A), const Color(0xFFFFF4D6), open)!,
            Color.lerp(const Color(0xFF2E2766), visuals.accent, open)!,
          ],
        ).createShader(rect),
    );
    // Frame.
    canvas.drawPath(
      arch,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = visuals.accent.withValues(alpha: 0.55 + 0.45 * open),
    );
    // Closed seal: a thin vertical seam that dissolves as the portal opens.
    if (open < 1) {
      canvas.drawLine(
        Offset(c.dx, rect.top + w * 0.25),
        Offset(c.dx, rect.bottom - 4),
        Paint()
          ..strokeWidth = 1.4
          ..color = visuals.threadColor.withValues(
            alpha: (0.5 + 0.3 * idle) * (1 - open),
          ),
      );
    }
    // Rays when open.
    if (open > 0) {
      final rays = Paint()
        ..strokeWidth = 1.5
        ..color = visuals.threadColor.withValues(alpha: 0.35 * open);
      for (var i = 0; i < 12; i++) {
        final a =
            -math.pi / 2 + (i - 5.5) * 0.22 + math.sin(_seconds + i) * 0.02;
        final from = c + Offset(math.cos(a), math.sin(a)) * (h * 0.55);
        final to =
            c + Offset(math.cos(a), math.sin(a)) * (h * (0.75 + 0.35 * open));
        canvas.drawLine(from, to, rays);
      }
    }
  }

  // ---------------------------------------------------------------- mechanism

  /// Light that travels from the mechanism to the portal during victory.
  void _paintBeam(Canvas canvas, BoardGeometry g) {
    final v = _victory;
    if (v <= 0.15) return;
    final t = Curves.easeOut.transform(((v - 0.15) / 0.35).clamp(0.0, 1.0));
    final from = g.toScreen(visuals.mechanismCenter);
    final to = g.toScreen(
      visuals.portalCenter.translate(0, visuals.portalSize.height / 2),
    );
    final end = Offset.lerp(from, to, t)!;
    canvas.drawLine(
      from,
      end,
      Paint()
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = visuals.accent.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawLine(
      from,
      end,
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = visuals.threadColor,
    );
  }

  void _paintMechanism(Canvas canvas, BoardGeometry g) {
    final c = g.toScreen(visuals.mechanismCenter);
    final r = g.scale(visuals.mechanismRadius);
    final v = _victory;
    final p = session.progress;
    final spin =
        _seconds * (0.08 + 0.25 * p) +
        Curves.easeInOut.transform(v) * math.pi * 2;

    // Shadow and glow.
    canvas.drawCircle(
      c,
      r * 1.5,
      Paint()
        ..color = visuals.accent.withValues(alpha: 0.08 + 0.25 * p + 0.4 * v)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.6),
    );

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Color.lerp(const Color(0xFFB9B2E6), visuals.accent, p)!;

    // Outer ring with notches.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(spin);
    canvas.drawCircle(Offset.zero, r, ring);
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      canvas.drawLine(
        Offset(math.cos(a), math.sin(a)) * r,
        Offset(math.cos(a), math.sin(a)) * (r * 1.12),
        ring,
      );
    }
    canvas.restore();

    // Inner counter-rotating square — an "impossible" twist.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-spin * 1.6 + math.pi / 4);
    final inner = r * (0.42 + 0.12 * v);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: inner, height: inner),
      ring,
    );
    canvas.rotate(math.pi / 4);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: inner, height: inner),
      ring..color = ring.color.withValues(alpha: 0.6),
    );
    canvas.restore();

    // Core.
    canvas.drawCircle(
      c,
      r * (0.14 + 0.1 * v),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF7D73C2),
          const Color(0xFFFFF4D6),
          math.max(p * 0.6, v),
        )!,
    );

    // Sockets: one per required thread, in order, showing its glyph.
    final required = level.winCondition.required;
    for (var i = 0; i < required.length; i++) {
      final a = math.pi / 2 + ((required.length - 1) / 2 - i) * 0.5;
      final sc = c + Offset(math.cos(a), math.sin(a)) * (r * 1.55);
      final done = session.isConnected(required[i]);
      final glyph = level.nodeById(required[i].first).glyph;
      _paintSocket(canvas, sc, r * 0.22, glyph, done);
    }
  }

  void _paintSocket(
    Canvas canvas,
    Offset c,
    double size,
    NodeGlyph glyph,
    bool lit,
  ) {
    canvas.drawCircle(
      c,
      size * 1.25,
      Paint()
        ..color = lit
            ? visuals.accent.withValues(alpha: 0.35)
            : const Color(0x55141747),
    );
    GlyphPainter.paint(
      canvas,
      glyph,
      c,
      size,
      Paint()
        ..style = lit ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = lit ? const Color(0xFFFFF4D6) : const Color(0xFFCFC7F0),
    );
  }

  // ---------------------------------------------------------------- islands

  void _paintIsland(Canvas canvas, BoardGeometry g, IslandSpec island) {
    final drift = BoardGeometry.islandDrift(
      level,
      island.id,
      clock.value,
      still: reduceMotion,
    );
    final c = g.toScreen(island.center.translate(0, drift));
    final w = g.scale(island.width);
    final h = g.scale(island.height);
    final top = Rect.fromCenter(center: c, width: w, height: h * 0.55);

    // Soft shadow far below — the island floats.
    canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(0, h * 2.2 - g.scale(drift) * 3),
        width: w * 0.6,
        height: h * 0.25,
      ),
      Paint()
        ..color = const Color(0x33100C30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Rocky underside: an inverted, slightly asymmetric cone.
    final under = Path()
      ..moveTo(top.left, c.dy)
      ..quadraticBezierTo(
        top.left + w * 0.12,
        c.dy + h * 0.9,
        c.dx - w * 0.06,
        c.dy + h * 1.6,
      )
      ..lineTo(c.dx + w * 0.02, c.dy + h * 1.95)
      ..quadraticBezierTo(c.dx + w * 0.2, c.dy + h * 1.0, top.right, c.dy)
      ..close();
    canvas.drawPath(
      under,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(island.tint, const Color(0xFF2A2463), 0.45)!,
            const Color(0xFF1A1645),
          ],
        ).createShader(Rect.fromLTRB(top.left, c.dy, top.right, c.dy + h * 2)),
    );
    // Faceted strata lines.
    final strata = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x33FFFFFF);
    canvas.drawLine(
      Offset(top.left + w * 0.18, c.dy + h * 0.45),
      Offset(top.right - w * 0.25, c.dy + h * 0.55),
      strata,
    );
    canvas.drawLine(
      Offset(c.dx - w * 0.12, c.dy + h * 1.05),
      Offset(c.dx + w * 0.1, c.dy + h * 0.95),
      strata,
    );

    // Grassy pastel top.
    canvas.drawOval(
      top,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.6),
          radius: 1.1,
          colors: [Color.lerp(island.tint, Colors.white, 0.55)!, island.tint],
        ).createShader(top),
    );
    canvas.drawOval(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x66FFFFFF),
    );
  }

  // ---------------------------------------------------------------- threads

  Path _threadPath(Offset a, Offset b, double sag) {
    final mid = Offset.lerp(a, b, 0.5)!.translate(0, sag);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);
  }

  Offset _nodeAt(BoardGeometry g, String id) =>
      g.nodeCenter(level, level.nodeById(id), clock.value, still: reduceMotion);

  void _paintThread(Canvas canvas, BoardGeometry g, Connection c) {
    final t = Curves.easeOutCubic.transform(
      _since(effects.threadStarted[c], level.animation.threadDraw),
    );
    if (t <= 0) return;
    final a = _nodeAt(g, c.first);
    final b = _nodeAt(g, c.second);
    final sway = reduceMotion
        ? 0.0
        : math.sin(_seconds * 0.9 + a.dx * 0.01) * 3;
    final path = _threadPath(a, b, g.scale(0.03) + sway);
    final metric = path.computeMetrics().first;
    final partial = metric.extractPath(0, metric.length * t);

    canvas.drawPath(
      partial,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7
        ..color = visuals.accent.withValues(alpha: 0.28 + 0.2 * _victory)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      partial,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.8
        ..color = visuals.threadColor,
    );
    // A spark rides the tip while the thread is being drawn.
    if (t < 1) {
      final tip = metric.getTangentForOffset(metric.length * t)?.position;
      if (tip != null) {
        canvas.drawCircle(
          tip,
          4,
          Paint()
            ..color = Colors.white
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  void _paintRejected(Canvas canvas, BoardGeometry g) {
    final c = effects.rejected;
    if (c == null) return;
    final t = _since(effects.rejectedAt, level.animation.rejectFade);
    if (t >= 1) return;
    final a = _nodeAt(g, c.first);
    final b = _nodeAt(g, c.second);
    final path = _threadPath(
      a,
      b,
      g.scale(0.06) * (0.5 + t),
    ); // droops like loose yarn
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFFE6DDFF).withValues(alpha: 0.55 * (1 - t));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + 5, metric.length)),
          paint,
        );
      }
    }
  }

  // ---------------------------------------------------------------- nodes

  void _paintNode(Canvas canvas, BoardGeometry g, String id) {
    final node = level.nodeById(id);
    final c = _nodeAt(g, id);
    final r = g.nodeRadius;
    final connected = session.connections.any((x) => x.involves(id));
    final selected = session.selectedNodeId == id;
    final flashStart = effects.nodeFlashed[id];
    final flash = 1 - _since(flashStart, level.animation.nodeFlash);
    final hasFlash =
        flashStart != null &&
        !reduceMotion &&
        clock.value >= flashStart &&
        flash > 0;
    final breathe = 0.5 + 0.5 * math.sin(_seconds * 1.6 + c.dx * 0.05);
    final v = _victory;

    // Halo.
    canvas.drawCircle(
      c,
      r * (1.9 + 0.25 * breathe + (hasFlash ? flash * 1.2 : 0)),
      Paint()
        ..color = (connected ? visuals.accent : const Color(0xFFCFC2FF))
            .withValues(
              alpha:
                  0.18 +
                  0.1 * breathe +
                  (hasFlash ? 0.45 * flash : 0) +
                  0.3 * v,
            )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.9),
    );

    // Body.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          colors: connected
              ? [const Color(0xFFFFF6DC), visuals.accent]
              : [const Color(0xFFF4F0FF), const Color(0xFF9A8FE0)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    GlyphPainter.paint(
      canvas,
      node.glyph,
      c,
      r * 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF2A2463),
    );

    if (selected) {
      final pulse = reduceMotion ? 0.5 : 0.5 + 0.5 * math.sin(_seconds * 5);
      canvas.drawCircle(
        c,
        r * (1.45 + 0.15 * pulse),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = visuals.threadColor,
      );
    }
    if (hasFlash) {
      canvas.drawCircle(
        c,
        r * (1.3 + 1.4 * (1 - flash)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = visuals.threadColor.withValues(alpha: flash),
      );
    }
  }

  @override
  bool shouldRepaint(WorldPainter old) =>
      old.session != session ||
      old.reduceMotion != reduceMotion ||
      old.effects != effects ||
      old.padding != padding;
}
