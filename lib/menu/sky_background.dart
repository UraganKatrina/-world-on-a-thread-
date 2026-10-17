import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/palette.dart';

/// Calm animated backdrop for menus: gradient sky, stars and one small
/// island hanging on a golden thread.
class SkyBackground extends StatefulWidget {
  const SkyBackground({super.key, required this.child});

  final Widget child;

  @override
  State<SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends State<SkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SkyPainter(_c), child: widget.child);
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Palette.night, Palette.indigo, Color(0xFF8D78C8)],
          stops: [0, 0.6, 1],
        ).createShader(rect),
    );
    final phase = t.value * 2 * math.pi;
    final rnd = math.Random(7);
    for (var i = 0; i < 80; i++) {
      final p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height * 0.7,
      );
      final a = 0.35 + 0.35 * (1 + math.sin(phase * 2 + i)) / 2;
      canvas.drawCircle(
        p,
        0.5 + rnd.nextDouble(),
        Paint()..color = Colors.white.withValues(alpha: a),
      );
    }
    // A tiny island suspended from the top of the sky.
    final w = math.min(size.width, size.height) * 0.28;
    final c = Offset(
      size.width * 0.72,
      size.height * 0.2 + math.sin(phase) * 6,
    );
    canvas.drawLine(
      Offset(c.dx, 0),
      c.translate(0, -w * 0.08),
      Paint()
        ..color = Palette.softGold.withValues(alpha: 0.8)
        ..strokeWidth = 1.2,
    );
    final under = Path()
      ..moveTo(c.dx - w / 2, c.dy)
      ..quadraticBezierTo(c.dx - w * 0.3, c.dy + w * 0.3, c.dx, c.dy + w * 0.55)
      ..quadraticBezierTo(c.dx + w * 0.25, c.dy + w * 0.25, c.dx + w / 2, c.dy)
      ..close();
    canvas.drawPath(under, Paint()..color = const Color(0xFF2A2463));
    canvas.drawOval(
      Rect.fromCenter(center: c, width: w, height: w * 0.18),
      Paint()..color = Palette.mist,
    );
    canvas.drawCircle(
      c.translate(0, -w * 0.08),
      5,
      Paint()
        ..color = Palette.gold
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(_SkyPainter old) => false;
}
