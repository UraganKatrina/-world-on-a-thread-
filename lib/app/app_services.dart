import 'package:flutter/widgets.dart';

import '../audio/audio_service.dart';
import '../game/levels/level_catalog.dart';
import '../persistence/progress_repository.dart';
import '../settings/game_settings.dart';

/// Long-lived services shared by every screen.
class AppServices {
  AppServices({
    required this.catalog,
    required this.progress,
    required this.settings,
    required this.audio,
  });

  final LevelCatalog catalog;
  final ProgressRepository progress;
  final GameSettings settings;
  final AudioService audio;
}

/// Makes [AppServices] reachable from any widget below it.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above $context');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
