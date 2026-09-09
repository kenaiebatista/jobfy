import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Theme-aware color roles. Define the light/dark values once here, then
/// read them anywhere via `context.colors.*` (see `build_context_x.dart`)
/// instead of branching on brightness or hardcoding a color at each call
/// site.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  /// Scaffold-level background.
  final Color background;

  /// Card / panel / dialog background.
  final Color surface;

  /// Card border and hairline dividers.
  final Color surfaceBorder;

  /// Primary body text and icons.
  final Color textPrimary;

  /// Secondary text, hints, captions.
  final Color textMuted;

  final Color accent;
  final Color success;
  final Color warning;
  final Color danger;

  /// Text/icon color for content placed on top of an accent-colored
  /// surface (e.g. a filled button) — always white, named for intent
  /// rather than value.
  final Color onAccent;

  const AppSemanticColors({
    required this.background,
    required this.surface,
    required this.surfaceBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.onAccent,
  });

  static const light = AppSemanticColors(
    background: AppColors.backgroundLight,
    surface: AppColors.white,
    surfaceBorder: AppColors.cardBorder,
    textPrimary: Colors.black87,
    textMuted: AppColors.textMuted,
    accent: AppColors.accent,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    onAccent: Colors.white,
  );

  static const dark = AppSemanticColors(
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    surfaceBorder: AppColors.cardBorderDark,
    textPrimary: Colors.white,
    textMuted: AppColors.textMutedDark,
    accent: AppColors.accent,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    onAccent: Colors.white,
  );

  @override
  AppSemanticColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceBorder,
    Color? textPrimary,
    Color? textMuted,
    Color? accent,
    Color? success,
    Color? warning,
    Color? danger,
    Color? onAccent,
  }) {
    return AppSemanticColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}
