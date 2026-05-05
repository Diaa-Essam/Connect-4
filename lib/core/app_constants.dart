import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._(); // prevents instantiation

  // Colors
  static const Color gradientTop = Color(0xFF0F172A);
  static const Color gradientBottom = Color(0xFF1E3A8A);
  static const Color player1Color = Colors.red;
  static const Color player2Color = Colors.yellow;
  static const Color emptyCell = Color(0xFFE5E7EB);
  static const Color boardColor = Colors.blue;

  // Durations
  static const Duration fadeTransition = Duration(milliseconds: 500);
  static const Duration entranceAnimation = Duration(milliseconds: 1300);
  static const Duration pulseAnimation = Duration(milliseconds: 900);
  static const Duration aiMoveDelay = Duration(milliseconds: 300);
}
