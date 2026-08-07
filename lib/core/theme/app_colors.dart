import 'package:flutter/material.dart';

abstract class AppColors {
  // Deep Night Sky Foundation (90% Dark Night Blue Atmosphere)
  static const Color darkBackground = Color(0xFF080D2B);
  static const Color darkBackgroundSubtle = Color(0xFF0B1035);
  static const Color darkSurface = Color(0xFF10164A);

  // Translucent Liquid Glass Surfaces
  static const Color darkCard = Color(0x7319235A); // rgba(25, 35, 90, 0.45)
  static const Color darkCardElevated = Color(0x9919235A);
  static const Color darkBorder = Color(0x29B4C8FF); // rgba(180, 200, 255, 0.16)
  static const Color glassBorder = Color(0x38FFFFFF); // rgba(255, 255, 255, 0.22)

  // Light Theme Fallbacks (Harmonized)
  static const Color lightBackground = Color(0xFF080D2B);
  static const Color lightSurface = Color(0xFF10164A);
  static const Color lightCard = Color(0x7319235A);
  static const Color lightBorder = Color(0x29B4C8FF);

  // Primary Royal & Cobalt Blue Spectrum
  static const Color primary = Color(0xFF3159C9); // Royal Blue Primary
  static const Color primaryLight = Color(0xFF5C86F2); // Electric Blue Highlight
  static const Color primaryDark = Color(0xFF151B58); // Deep Navy
  static const Color primarySubtle = Color(0x333159C9); // 20% Opacity Blue

  // Lilac & Pink Illumination Spectrum
  static const Color lilacAccent = Color(0xFFB879FF);
  static const Color pinkAccent = Color(0xFFC98BFF);
  static const Color roseAccent = Color(0xFFD77BFF);
  static const Color pinkGlow = Color(0xFFE29AFF);
  static const Color lavenderSoft = Color(0xFFC7CEFA);

  // Status & Category Spectrum
  static const Color indigoAccent = Color(0xFF818CF8);
  static const Color cyanAccent = Color(0xFF38BDF8);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color tealAccent = Color(0xFF2DD4BF);
  static const Color purpleAccent = Color(0xFF6A57D8);

  // High Contrast Crisp Typography (NON-NEGOTIABLE READABILITY)
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Pure White #FFFFFF
  static const Color darkTextSecondary = Color(0xFFD9DEFF); // Cool White-Lavender
  static const Color darkTextMuted = Color(0xFFBFC8F2); // Crisp Label Text
  static const Color placeholderText = Color(0xFFAEB8E5); // Readable Placeholder

  static const Color lightTextPrimary = Color(0xFFFFFFFF);
  static const Color lightTextSecondary = Color(0xFFD9DEFF);
  static const Color lightTextMuted = Color(0xFFBFC8F2);

  // Signature Blue -> Purple -> Lilac User Bubble Gradient
  static const LinearGradient userBubbleGradient = LinearGradient(
    colors: [Color(0xFF3159C9), Color(0xFF6A57D8), Color(0xFFC98BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Primary Glass Pill Button Gradient
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [Color(0xFF3159C9), Color(0xFFB879FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkGlassGradient = LinearGradient(
    colors: [Color(0x9919235A), Color(0x6610164A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
