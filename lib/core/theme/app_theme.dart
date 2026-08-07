import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

abstract class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.lilacAccent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
          side: const BorderSide(color: AppColors.darkBorder, width: 1.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBackgroundSubtle,
        selectedItemColor: AppColors.darkTextPrimary,
        unselectedItemColor: AppColors.darkTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1.0,
      ),
    );
  }

  static ThemeData get lightTheme => darkTheme;
}
