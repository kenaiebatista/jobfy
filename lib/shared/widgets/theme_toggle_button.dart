import 'package:aplicativo_jobfy/core/settings/app_settings_controller.dart';
import 'package:aplicativo_jobfy/core/theme/app_palette.dart';
import 'package:aplicativo_jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Sun/moon icon button that flips the app between light and dark mode.
/// Uses the same [appSettings] as the theme selector in the settings page.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = AppLocalizations.of(context);

    return IconButton(
      tooltip: isDark ? l10n.themeToggleToLight : l10n.themeToggleToDark,
      onPressed: () =>
          appSettings.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
      style: IconButton.styleFrom(
        backgroundColor: context.palette.surfaceMuted,
      ),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            RotationTransition(turns: anim, child: child),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(isDark),
        ),
      ),
    );
  }
}
