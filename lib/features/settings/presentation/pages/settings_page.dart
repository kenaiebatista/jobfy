import 'package:jobfy/core/settings/settings_controller.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsController>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.settingsBack,
          onPressed: () => context.canPop() ? context.pop() : context.go('/user'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: [
                _SettingsSection(
                  title: l10n.settingsAppearance,
                  description: l10n.settingsAppearanceDescription,
                  child: _ThemeModeSelector(
                    l10n: l10n,
                    colors: colors,
                    value: settings.themeMode,
                    onChanged: settings.setThemeMode,
                  ),
                ),
                _SettingsSection(
                  title: l10n.settingsLanguage,
                  description: l10n.settingsLanguageDescription,
                  child: _LanguageSelector(
                    l10n: l10n,
                    colors: colors,
                    value: settings.locale,
                    onChanged: settings.setLocale,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colors.onSurface,
            ),
          ),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme colors;
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({
    required this.l10n,
    required this.colors,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <(ThemeMode, IconData, String)>[
      (ThemeMode.light, Icons.light_mode_outlined, l10n.settingsThemeLight),
      (ThemeMode.dark, Icons.dark_mode_outlined, l10n.settingsThemeDark),
      (ThemeMode.system, Icons.brightness_auto_outlined, l10n.settingsThemeSystem),
    ];

    return Row(
      spacing: 12,
      children: options
          .map((o) => Expanded(
                child: _OptionTile(
                  icon: o.$2,
                  label: o.$3,
                  selected: value == o.$1,
                  onTap: () => onChanged(o.$1),
                ),
              ))
          .toList(),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme colors;
  final Locale? value;
  final ValueChanged<Locale?> onChanged;

  const _LanguageSelector({
    required this.l10n,
    required this.colors,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <(Locale?, String)>[
      (null, l10n.settingsLanguageSystem),
      (const Locale('en'), 'English'),
      (const Locale('pt', 'BR'), 'Português (Brasil)'),
      (const Locale('es'), 'Español'),
    ];

    return Column(
      spacing: 8,
      children: options
          .map((o) => _RadioRow(
                label: o.$2,
                selected: value == o.$1,
                onTap: () => onChanged(o.$1),
              ))
          .toList(),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          spacing: 6,
          children: [
            Icon(icon, color: selected ? colors.primary : colors.onSurfaceVariant),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: Row(
          spacing: 10,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
