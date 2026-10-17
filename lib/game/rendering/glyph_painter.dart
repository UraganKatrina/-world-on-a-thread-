import 'dart:math' as math;
import 'dart:ui';

import '../models/node_glyph.dart';

/// Draws the small signs that tell matching nodes apart.
abstract final class GlyphPainter {
  static void paint(
    Canvas canvas,
    NodeGlyph glyph,
    Offset c,
    double size,
    Paint paint,
  ) {
    switch (glyph) {
      case NodeGlyph.circle:
        canvas.drawCircle(c, size * 0.75, paint);
      case NodeGlyph.triangle:
        canvas.drawPath(_polygon(c, size, 3, -math.pi / 2), paint);
      case NodeGlyph.diamond:
        canvas.drawPath(_polygon(c, size, 4, -math.pi / 2), paint);
      case NodeGlyph.square:
        canvas.drawPath(_polygon(c, size * 0.95, 4, -math.pi / 4), paint);
      case NodeGlyph.star:
        canvas.drawPath(_star(c, size), paint);
    }
  }

  static Path _polygon(Offset c, double r, int sides, double start) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final a = start + i * 2 * math.pi / sides;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  static Path _star(Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final rr = i.isEven ? r : r * 0.45;
      final p = c + Offset(math.cos(a), math.sin(a)) * rr;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }
}
