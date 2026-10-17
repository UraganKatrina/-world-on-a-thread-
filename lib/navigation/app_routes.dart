import 'package:flutter/material.dart';

import '../game/game_screen.dart';
import '../game/models/level_definition.dart';
import '../menu/finale_screen.dart';
import '../menu/level_select_screen.dart';
import '../settings/settings_screen.dart';

/// Central place for screen transitions: a slow cross-fade that matches the
/// calm mood of the game.
abstract final class AppRoutes {
  static Route<T> _fade<T>(Widget page) => PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    ),
  );

  static Future<void> openLevel(
    BuildContext context,
    LevelDefinition level, {
    bool replace = false,
  }) {
    final route = _fade<void>(GameScreen(level: level));
    return replace
        ? Navigator.of(context).pushReplacement(route)
        : Navigator.of(context).push(route);
  }

  static Future<void> openLevelSelect(BuildContext context) =>
      Navigator.of(context).push(_fade(const LevelSelectScreen()));

  static Future<void> openSettings(BuildContext context) =>
      Navigator.of(context).push(_fade(const SettingsScreen()));

  static Future<void> openFinale(BuildContext context) =>
      Navigator.of(context).pushReplacement(_fade(const FinaleScreen()));

  static void backToMenu(BuildContext context) =>
      Navigator.of(context).popUntil((route) => route.isFirst);
}
