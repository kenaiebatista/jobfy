import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide preferences that affect every screen: the theme mode and the
/// language. `JobfyApp` listens to it, so changing a value here (from the
/// settings page) rebuilds the whole MaterialApp. Both values are saved with
/// shared_preferences and restored by [load] on startup.
class AppSettingsController extends ChangeNotifier {
  static const _themeModeKey = 'app.theme_mode';
  static const _localeKey = 'app.locale';

  /// Languages offered in the settings page, with their native names.
  static const supportedLanguages = [
    (locale: Locale('pt'), name: 'Português'),
    (locale: Locale('en'), name: 'English'),
    (locale: Locale('es'), name: 'Español'),
  ];

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('pt');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeModeKey);
    _themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == savedTheme,
      orElse: () => ThemeMode.light,
    );

    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null &&
        supportedLanguages.any((l) => l.locale.languageCode == savedLocale)) {
      _locale = Locale(savedLocale);
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}

final appSettings = AppSettingsController();
