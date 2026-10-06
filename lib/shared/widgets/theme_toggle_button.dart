import 'package:jobfy/core/settings/settings_controller.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Sun/moon icon button that flips the app between light and dark mode.
/// Uses the same [SettingsController] as the theme selector in the settings
/// page.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      tooltip: isDark ? l10n.settingsThemeToggleToLight : l10n.settingsThemeToggleToDark,
      onPressed: () => context
          .read<SettingsController>()
          .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            RotationTransition(turns: anim, child: child),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(isDark),
          color: color,
        ),
      ),
    );
  }
}
