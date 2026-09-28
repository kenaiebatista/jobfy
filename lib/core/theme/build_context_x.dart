import 'package:flutter/material.dart';
import 'app_semantic_colors.dart';

/// Shorthand for the theme-aware values widgets need most often, so
/// choosing a color is just `context.colors.textMuted` instead of
/// repeating `Theme.of(context).colorScheme...` (or, worse, hardcoding a
/// color that only looks right in one brightness) at every call site.
extension BuildContextThemeX on BuildContext {
  AppSemanticColors get colors => Theme.of(this).extension<AppSemanticColors>()!;

  TextTheme get textStyles => Theme.of(this).textTheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
