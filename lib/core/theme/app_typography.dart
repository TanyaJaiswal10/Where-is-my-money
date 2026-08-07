import 'package:flutter/material.dart';

abstract class AppTypography {
  static const String fontFamily = 'SystemFont';

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.45,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.3,
  );
}
