import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic surface/text colors that change between the light and dark
/// themes. Widgets read them through `context.palette` instead of using
/// hardcoded values like `Colors.white` or [AppColors.cardBorder], so
/// switching the theme in the settings screen repaints the whole app.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Page (scaffold) background behind the cards.
  final Color background;

  /// Cards, top bars and dialogs.
  final Color surface;

  /// Subtle fills inside a surface (search pill, tags, icon buttons).
  final Color surfaceMuted;

  /// Card borders and dividers.
  final Color border;

  /// Main text color.
  final Color textPrimary;

  final Color textSecondary;

  /// Secondary / helper text.
  final Color textMuted;

  final Color shadow;

  /// Background of the high-emphasis buttons (black in light mode).
  final Color strongButton;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.shadow,
    required this.strongButton,
  });

  static const light = AppPalette(
    background: AppColors.backgroundLight,
    surface: AppColors.white,
    surfaceMuted: Color(0xFFF1F5F9),
    border: AppColors.cardBorder,
    textPrimary: Colors.black87,
    textSecondary: Color(0xDD000000),
    textMuted: AppColors.textMuted,
    shadow: Color(0x08000000),
    strongButton: Colors.black,
  );

  static const dark = AppPalette(
    background: Color(0xFF0B1120),
    surface: AppColors.backgroundDark2,
    surfaceMuted: Color(0xFF1E293B),
    border: Color(0xFF1F2937),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: AppColors.textLight,
    textMuted: AppColors.textMuted,
    shadow: Color(0x40000000),
    strongButton: AppColors.accent,
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? shadow,
    Color? strongButton,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      shadow: shadow ?? this.shadow,
      strongButton: strongButton ?? this.strongButton,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      strongButton: Color.lerp(strongButton, other.strongButton, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
