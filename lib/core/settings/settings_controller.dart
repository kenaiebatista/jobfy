import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide user preferences (theme, locale) with local persistence.
class SettingsController extends ChangeNotifier {
  static const _themeModeKey = 'settings.theme_mode';
  static const _localeKey = 'settings.locale';

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale; // null means "follow the device locale".

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final storedTheme = prefs.getString(_themeModeKey);
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == storedTheme,
      orElse: () => ThemeMode.system,
    );

    final storedLocale = prefs.getString(_localeKey);
    _locale = storedLocale == null ? null : _parseLocale(storedLocale);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  /// Pass `null` to follow the device locale.
  Future<void> setLocale(Locale? locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, _encodeLocale(locale));
    }
  }

  static String _encodeLocale(Locale locale) => locale.countryCode == null
      ? locale.languageCode
      : '${locale.languageCode}_${locale.countryCode}';

  static Locale _parseLocale(String value) {
    final parts = value.split('_');
    return parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }
}
