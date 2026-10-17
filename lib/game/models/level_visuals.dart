import 'dart:ui';

/// A floating island drawn behind the nodes. Coordinates are normalized.
class IslandSpec {
  const IslandSpec({
    required this.id,
    required this.center,
    required this.width,
    required this.height,
    this.floatPhase = 0,
    this.floatAmplitude = 0.008,
    this.tint = const Color(0xFF9C8FD8),
  });

  final String id;
  final Offset center;
  final double width;
  final double height;
  final double floatPhase;
  final double floatAmplitude;
  final Color tint;
}

/// Everything the renderer needs that is not puzzle logic.
class LevelVisuals {
  const LevelVisuals({
    required this.skyTop,
    required this.skyBottom,
    required this.islands,
    required this.mechanismCenter,
    required this.portalCenter,
    this.accent = const Color(0xFFF2C46D),
    this.threadColor = const Color(0xFFFFE3A3),
    this.mechanismRadius = 0.075,
    this.portalSize = const Size(0.16, 0.2),
  });

  final Color skyTop;
  final Color skyBottom;
  final List<IslandSpec> islands;
  final Offset mechanismCenter;
  final double mechanismRadius;
  final Offset portalCenter;
  final Size portalSize;
  final Color accent;
  final Color threadColor;

  IslandSpec? islandById(String? id) {
    if (id == null) return null;
    for (final island in islands) {
      if (island.id == id) return island;
    }
    return null;
  }
}

/// Timing of the level's animations.
class LevelAnimation {
  const LevelAnimation({
    this.threadDraw = const Duration(milliseconds: 650),
    this.nodeFlash = const Duration(milliseconds: 700),
    this.rejectFade = const Duration(milliseconds: 900),
    this.victorySequence = const Duration(milliseconds: 2600),
    this.floatPeriod = const Duration(seconds: 6),
  });

  final Duration threadDraw;
  final Duration nodeFlash;
  final Duration rejectFade;
  final Duration victorySequence;
  final Duration floatPeriod;
}
