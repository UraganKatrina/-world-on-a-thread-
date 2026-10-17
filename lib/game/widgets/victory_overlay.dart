import 'package:flutter/material.dart';

import '../../app/palette.dart';
import 'glass_panel.dart';

class VictoryOverlay extends StatefulWidget {
  const VictoryOverlay({
    super.key,
    required this.levelTitle,
    required this.hasNextLevel,
    required this.onNext,
    required this.onReplay,
    required this.onMenu,
  });

  final String levelTitle;
  final bool hasNextLevel;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _appear = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  @override
  void dispose() {
    _appear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _appear, curve: Curves.easeOutBack);
    return FadeTransition(
      opacity: _appear,
      child: ColoredBox(
        color: const Color(0x66080A24),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ScaleTransition(
                scale: Tween(begin: 0.9, end: 1.0).animate(curve),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: GlassPanel(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Palette.gold,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Проход открыт',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Уровень «${widget.levelTitle}» пройден.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: widget.onNext,
                          child: Text(
                            widget.hasNextLevel ? 'Дальше' : 'Завершить',
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: widget.onReplay,
                          child: const Text('Пройти ещё раз'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: widget.onMenu,
                          child: const Text('В главное меню'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
