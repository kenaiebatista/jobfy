import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Surface colors that change between the light and the dark theme.
///
/// Pages read them through `context.palette` instead of hardcoding
/// `Colors.white` / `AppColors.backgroundLight`, so switching the theme in
/// the settings screen repaints the whole app.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Page background behind the cards.
  final Color background;

  /// Cards, top bars and dialogs.
  final Color surface;

  /// Card borders and dividers.
  final Color border;

  /// Main text color.
  final Color textPrimary;

  /// Secondary / helper text.
  final Color textMuted;

  /// Background of the high-emphasis buttons (black in light mode).
  final Color strongButton;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.strongButton,
  });

  static const light = AppPalette(
    background: AppColors.backgroundLight,
    surface: AppColors.white,
    border: AppColors.cardBorder,
    textPrimary: Colors.black87,
    textMuted: AppColors.textMuted,
    strongButton: Colors.black,
  );

  static const dark = AppPalette(
    background: Color(0xFF0B1120),
    surface: AppColors.backgroundDark2,
    border: Color(0xFF1F2937),
    textPrimary: Color(0xFFE2E8F0),
    textMuted: AppColors.textMuted,
    strongButton: AppColors.accent,
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? border,
    Color? textPrimary,
    Color? textMuted,
    Color? strongButton,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      strongButton: strongButton ?? this.strongButton,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      strongButton: Color.lerp(strongButton, other.strongButton, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
