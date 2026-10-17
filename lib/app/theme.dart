import 'package:flutter/material.dart';

import 'palette.dart';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Palette.violet,
    brightness: Brightness.dark,
    primary: Palette.gold,
    onPrimary: Palette.night,
    surface: Palette.night,
    onSurface: Palette.pearl,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Palette.night,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w300,
        letterSpacing: 1.5,
        color: Palette.pearl,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.6,
        color: Palette.pearl,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: Palette.pearl,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: Palette.pearl),
      bodyMedium: TextStyle(fontSize: 15, height: 1.4, color: Palette.mist),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.gold,
        foregroundColor: Palette.night,
        minimumSize: const Size(200, 52),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.pearl,
        side: const BorderSide(color: Palette.mist, width: 1),
        minimumSize: const Size(200, 52),
        shape: const StadiumBorder(),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Palette.night : Palette.mist,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Palette.gold : Palette.indigo,
      ),
    ),
  );
}
