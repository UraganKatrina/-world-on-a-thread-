import 'package:flutter/material.dart';

import '../../app/palette.dart';

/// Rounded translucent panel used for every piece of UI over the sky, so
/// text always has enough contrast. It is a [Material], so list tiles and
/// ink splashes inside it render correctly.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(24)),
    side: BorderSide(color: Color(0x55F2C46D)),
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.panel,
      shape: _shape,
      elevation: 12,
      shadowColor: const Color(0x99000000),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
