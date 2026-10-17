import 'package:flutter/material.dart';

/// The game's own colour language: deep night blues and violets, pastel
/// mists and delicate gold.
abstract final class Palette {
  static const Color night = Color(0xFF0E1236);
  static const Color indigo = Color(0xFF232A6B);
  static const Color violet = Color(0xFF5B4B9E);
  static const Color mist = Color(0xFFD9CFF2);
  static const Color pearl = Color(0xFFF6F1FF);
  static const Color gold = Color(0xFFF2C46D);
  static const Color softGold = Color(0xFFFFE3A3);
  static const Color rose = Color(0xFFF0B6C9);

  /// Panel behind text over the sky; keeps contrast above 7:1 with [pearl].
  static const Color panel = Color(0xCC12163F);
}
