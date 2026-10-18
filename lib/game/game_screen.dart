import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_services.dart';
import '../audio/audio_service.dart';
import '../navigation/app_routes.dart';
import 'logic/feedback_messages.dart';
import 'logic/puzzle_session.dart';
import 'models/level_definition.dart';
import 'rendering/board_geometry.dart';
import 'rendering/board_visual_state.dart';
import 'widgets/game_hud.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/puzzle_board.dart';
import 'widgets/victory_overlay.dart';

/// One level being played: board, HUD, pause and victory overlays.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.level});

  final LevelDefinition level;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final PuzzleSession _session = PuzzleSession(widget.level);
  final BoardVisualState _effects = BoardVisualState();
  late final AppLifecycleListener _lifecycle;

  String? _message;
  int _messageId = 0;
  Timer? _messageTimer;
  bool _hintVisible = false;
  bool _paused = false;
  bool _victoryShown = false;

  AppServices get _services => AppScope.of(context);

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () {
        if (mounted && !_victoryShown) setState(() => _paused = true);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _services.progress.markOpened(widget.level.id);
      _services.audio.ensureMusic();
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _lifecycle.dispose();
    _session.dispose();
    super.dispose();
  }

  void _say(String? text, {Duration hold = const Duration(seconds: 4)}) {
    _messageTimer?.cancel();
    setState(() {
      _message = text;
      _messageId++;
      _hintVisible = false;
    });
    if (text != null) {
      _messageTimer = Timer(hold, () {
        if (mounted) {
          setState(() {
            _message = null;
            _messageId++;
          });
        }
      });
    }
  }

  void _onOutcome(TapOutcome outcome) {
    final audio = _services.audio;
    switch (outcome) {
      case NodeSelected():
        audio.playEffect(SoundEffect.select);
        HapticFeedback.selectionClick();
        setState(() {});
      case ThreadConnected(:final solvedNow):
        audio.playEffect(solvedNow ? SoundEffect.solved : SoundEffect.connect);
        HapticFeedback.lightImpact();
        _say(
          solvedNow ? solvedMessage : connectedMessage,
          hold: const Duration(seconds: 2),
        );
      case ThreadUntied():
        audio.playEffect(SoundEffect.select);
        _say(untiedMessage, hold: const Duration(seconds: 2));
      case ThreadRejected(:final reason):
        audio.playEffect(SoundEffect.reject);
        _say(rejectionMessage(reason));
      case SelectionCleared():
        setState(() {});
      case TapIgnored():
        break;
    }
  }

  Future<void> _onVictoryFinished() async {
    if (_victoryShown) return;
    setState(() => _victoryShown = true);
    await _services.progress.markCompleted(widget.level.id);
  }

  void _restart() {
    _messageTimer?.cancel();
    _session.reset();
    _effects.clear();
    setState(() {
      _message = null;
      _hintVisible = false;
      _paused = false;
      _victoryShown = false;
    });
  }

  void _next() {
    final next = _services.catalog.nextAfter(widget.level.id);
    if (next == null) {
      AppRoutes.openFinale(context);
    } else {
      AppRoutes.openLevel(context, next, replace: true);
    }
  }

  /// Height kept for the top bar and for the message/hint area.
  static const double _topBarHeight = 72;
  static const double _hintAreaHeight = 124;
  static const double _sidePanelWidth = 300;

  @override
  Widget build(BuildContext context) {
    final services = _services;
    final media = MediaQuery.of(context);
    final reduceMotion =
        services.settings.reduceMotion || media.disableAnimations;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final safe = media.padding;
          // In wide windows (landscape tablets, web) the hint moves beside the
          // board instead of eating vertical space.
          final wideRect = BoardGeometry.fit(
            EdgeInsets.only(
              top: safe.top + _topBarHeight,
              bottom: safe.bottom + 12,
            ).deflateRect(Offset.zero & size),
            BoardGeometry.boardAspect,
          );
          final wide =
              (size.width - wideRect.width) / 2 >= _sidePanelWidth + 24;
          final boardPadding = EdgeInsets.fromLTRB(
            safe.left + 8,
            safe.top + _topBarHeight,
            safe.right + 8,
            safe.bottom + (wide ? 12 : _hintAreaHeight),
          );
          final hintBar = ListenableBuilder(
            listenable: _session,
            builder: (context, _) => HintBar(
              message: _message,
              messageId: _messageId,
              hint: widget.level.hint,
              hintVisible: _hintVisible,
              hintHighlighted: _session.rejectionCount >= 2,
              onToggleHint: () => setState(() => _hintVisible = !_hintVisible),
            ),
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              PuzzleBoard(
                session: _session,
                effects: _effects,
                paused: _paused || _victoryShown,
                reduceMotion: reduceMotion,
                padding: boardPadding,
                onOutcome: _onOutcome,
                onVictoryFinished: _onVictoryFinished,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: _topBarHeight,
                      child: ListenableBuilder(
                        listenable: _session,
                        builder: (context, _) => GameTopBar(
                          title: widget.level.title,
                          completed: _session.progressCount,
                          total: _session.goalCount,
                          onPause: () => setState(() => _paused = true),
                          onRestart: _restart,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (wide)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: _sidePanelWidth + 16,
                          child: hintBar,
                        ),
                      )
                    else
                      SizedBox(
                        height: _hintAreaHeight,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: hintBar,
                        ),
                      ),
                  ],
                ),
              ),
              if (_paused && !_victoryShown)
                PauseOverlay(
                  settings: services.settings,
                  onResume: () => setState(() => _paused = false),
                  onRestart: _restart,
                  onMenu: () => AppRoutes.backToMenu(context),
                ),
              if (_victoryShown)
                VictoryOverlay(
                  levelTitle: widget.level.title,
                  hasNextLevel:
                      services.catalog.nextAfter(widget.level.id) != null,
                  onNext: _next,
                  onReplay: _restart,
                  onMenu: () => AppRoutes.backToMenu(context),
                ),
            ],
          );
        },
      ),
    );
  }
}
