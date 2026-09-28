import 'package:aplicativo_jobfy/core/theme/app_palette.dart';
import 'package:aplicativo_jobfy/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';

/// Sun/moon icon button that flips the app between light and dark mode.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return IconButton(
      tooltip: isDark ? 'Usar tema claro' : 'Usar modo noturno',
      onPressed: themeController.toggle,
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
