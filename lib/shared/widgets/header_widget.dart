import 'package:jobfy/core/theme/app_colors.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: AppColors.backgroundDark,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {},
      ),
      title: Row(
        spacing: 8,
        children: [
          const Icon(Icons.lightbulb_circle, color: Colors.white, size: 36),
          Text(
            l10n.appName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => context.go('/settings'),
          tooltip: l10n.headerSettingsTooltip,
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
          onPressed: () => context.go('/user'),
          tooltip: l10n.headerUserAreaTooltip,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
