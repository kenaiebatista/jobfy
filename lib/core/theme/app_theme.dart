import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.white,
    dividerColor: AppColors.cardBorder,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
    ).copyWith(
      surface: AppColors.white,
      onSurface: Colors.black87,
      onSurfaceVariant: AppColors.textMuted,
      outlineVariant: AppColors.cardBorder,
    ),
    inputDecorationTheme: _inputDecorationTheme(
      borderColor: AppColors.cardBorder,
      labelColor: Colors.black87,
      hintColor: AppColors.textMuted,
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.surfaceDark,
    dividerColor: AppColors.cardBorderDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      surface: AppColors.surfaceDark,
      onSurface: Colors.white,
      onSurfaceVariant: AppColors.textMutedDark,
      outlineVariant: AppColors.cardBorderDark,
    ),
    inputDecorationTheme: _inputDecorationTheme(
      borderColor: AppColors.cardBorderDark,
      labelColor: Colors.white,
      hintColor: AppColors.textMutedDark,
    ),
  );

  static InputDecorationTheme _inputDecorationTheme({
    required Color borderColor,
    required Color labelColor,
    required Color hintColor,
  }) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      labelStyle: TextStyle(color: labelColor, fontSize: 14),
      hintStyle: TextStyle(color: hintColor, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
