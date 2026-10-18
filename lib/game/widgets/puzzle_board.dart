import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../logic/puzzle_session.dart';
import '../rendering/board_geometry.dart';
import '../rendering/board_visual_state.dart';
import '../rendering/world_painter.dart';

/// Interactive scene: turns taps into [PuzzleSession] calls and records the
/// timing of visual effects. All rules live in the session.
class PuzzleBoard extends StatefulWidget {
  const PuzzleBoard({
    super.key,
    required this.session,
    required this.effects,
    required this.onOutcome,
    required this.onVictoryFinished,
    this.paused = false,
    this.reduceMotion = false,
    this.padding = EdgeInsets.zero,
  });

  final PuzzleSession session;
  final BoardVisualState effects;
  final ValueChanged<TapOutcome> onOutcome;
  final VoidCallback onVictoryFinished;
  final bool paused;
  final bool reduceMotion;

  /// Space kept free of puzzle content for the HUD and safe areas.
  final EdgeInsets padding;

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<Duration> _clock = ValueNotifier(Duration.zero);
  late final Ticker _ticker;
  Duration _base = Duration.zero;
  bool _victoryReported = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (!widget.paused) _ticker.start();
  }

  @override
  void didUpdateWidget(PuzzleBoard old) {
    super.didUpdateWidget(old);
    if (widget.paused != old.paused) {
      if (widget.paused) {
        _base = _clock.value;
        _ticker.stop();
      } else {
        _ticker.start();
      }
    }
  }

  void _onTick(Duration elapsed) {
    _clock.value = _base + elapsed;
    final solvedAt = widget.effects.solvedAt;
    if (solvedAt == null) {
      _victoryReported = false;
      return;
    }
    final duration = widget.reduceMotion
        ? const Duration(milliseconds: 600)
        : widget.session.level.animation.victorySequence;
    if (!_victoryReported && _clock.value - solvedAt >= duration) {
      _victoryReported = true;
      widget.onVictoryFinished();
    }
  }

  void _handleTap(Offset position, Size size) {
    if (widget.paused || widget.session.isSolved) return;
    final geometry = BoardGeometry(size, padding: widget.padding);
    final node = geometry.hitTest(
      widget.session.level,
      position,
      _clock.value,
      still: widget.reduceMotion,
    );
    if (node == null) {
      widget.session.clearSelection();
      return;
    }
    final now = _clock.value;
    final outcome = widget.session.tapNode(node.id);
    final fx = widget.effects;
    switch (outcome) {
      case NodeSelected(:final nodeId):
        fx.nodeSelectedAt[nodeId] = now;
      case ThreadConnected(:final connection, :final solvedNow):
        fx.threadStarted[connection] = now;
        fx.nodeFlashed[connection.first] =
            now + widget.session.level.animation.threadDraw * 0.6;
        fx.nodeFlashed[connection.second] =
            now + widget.session.level.animation.threadDraw * 0.6;
        // The victory sequence starts once the last thread has been drawn.
        if (solvedNow) {
          fx.solvedAt = widget.reduceMotion
              ? now
              : now + widget.session.level.animation.threadDraw;
        }
      // A released thread falls away like a rejected one.
      case ThreadRejected(:final connection) || ThreadUntied(:final connection):
        fx.threadStarted.remove(connection);
        fx.rejected = connection;
        fx.rejectedAt = now;
      case SelectionCleared() || TapIgnored():
        break;
    }
    widget.onOutcome(outcome);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Semantics(
          label:
              'Игровое поле «${s.level.title}». Натянуто нитей: '
              '${s.progressCount} из ${s.goalCount}.',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _handleTap(d.localPosition, size),
            child: CustomPaint(
              size: size,
              painter: WorldPainter(
                session: s,
                effects: widget.effects,
                clock: _clock,
                reduceMotion: widget.reduceMotion,
                padding: widget.padding,
              ),
            ),
          ),
        );
      },
    );
  }
}
