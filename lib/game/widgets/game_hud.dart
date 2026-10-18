import 'package:flutter/material.dart';

import '../../app/palette.dart';

/// Top bar: pause, level title, progress, restart.
class GameTopBar extends StatelessWidget {
  const GameTopBar({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    required this.onPause,
    required this.onRestart,
    this.threadsLeft,
  });

  final String title;
  final int completed;
  final int total;

  /// Threads left on the spool; null hides the spool counter.
  final int? threadsLeft;
  final VoidCallback onPause;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _RoundButton(
            icon: Icons.pause_rounded,
            label: 'Пауза',
            onPressed: onPause,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProgressThreads(completed: completed, total: total),
                    if (threadsLeft case final left?) ...[
                      const SizedBox(width: 14),
                      SpoolCounter(left: left),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _RoundButton(
            icon: Icons.replay_rounded,
            label: 'Начать заново',
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }
}

/// Progress indicator: one small bead per required thread.
class ProgressThreads extends StatelessWidget {
  const ProgressThreads({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Прогресс: $completed из $total',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0)
              Container(
                width: 18,
                height: 1.5,
                color: i <= completed ? Palette.gold : const Color(0x66D9CFF2),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < completed ? Palette.gold : Colors.transparent,
                border: Border.all(
                  color: i < completed ? Palette.gold : Palette.mist,
                  width: 1.5,
                ),
                boxShadow: i < completed
                    ? const [BoxShadow(color: Color(0x99F2C46D), blurRadius: 8)]
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small spool with the number of threads still available.
class SpoolCounter extends StatelessWidget {
  const SpoolCounter({super.key, required this.left});

  final int left;

  @override
  Widget build(BuildContext context) {
    final empty = left <= 0;
    final color = empty ? Palette.mist : Palette.softGold;
    return Semantics(
      label: 'В мотке осталось нитей: $left',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.all_inclusive_rounded, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              '$left',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      iconSize: 26,
      style: IconButton.styleFrom(
        backgroundColor: Palette.panel,
        foregroundColor: Palette.pearl,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: Color(0x44D9CFF2)),
      ),
      icon: Icon(icon, semanticLabel: label),
    );
  }
}

/// Bottom area: the latest gentle message and the hint toggle.
class HintBar extends StatelessWidget {
  const HintBar({
    super.key,
    required this.message,
    required this.messageId,
    required this.hint,
    required this.hintVisible,
    required this.hintHighlighted,
    required this.onToggleHint,
  });

  final String? message;

  /// Changes whenever a new message is posted, so repeated texts animate.
  final int messageId;
  final String hint;
  final bool hintVisible;
  final bool hintHighlighted;
  final VoidCallback onToggleHint;

  @override
  Widget build(BuildContext context) {
    final text = hintVisible ? hint : message;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: text == null
                  ? SizedBox(
                      height: 48,
                      key: ValueKey('empty-$messageId-$hintVisible'),
                    )
                  : Container(
                      key: ValueKey('text-$messageId-$hintVisible'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Palette.panel,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          text,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: hintHighlighted && !hintVisible
                  ? const [
                      BoxShadow(
                        color: Color(0xAAF2C46D),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ]
                  : const [],
            ),
            child: IconButton(
              tooltip: hintVisible ? 'Скрыть подсказку' : 'Подсказка',
              onPressed: onToggleHint,
              style: IconButton.styleFrom(
                backgroundColor: hintVisible ? Palette.gold : Palette.panel,
                foregroundColor: hintVisible ? Palette.night : Palette.softGold,
                minimumSize: const Size(52, 52),
              ),
              icon: Icon(
                Icons.lightbulb_outline_rounded,
                semanticLabel: hintVisible ? 'Скрыть подсказку' : 'Подсказка',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
