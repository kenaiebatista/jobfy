import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide theme mode (claro / escuro / sistema). The choice is saved with
/// shared_preferences so the app reopens in the same mode.
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  /// Whether dark mode is in effect right now, resolving [ThemeMode.system]
  /// against the platform brightness.
  bool get isDark => switch (_mode) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system =>
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark,
      };

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      _mode = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.light,
      );
    } catch (_) {
      // Sem armazenamento disponível: segue no tema claro.
      _mode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } catch (_) {
      // A troca já foi aplicada; só não será lembrada no próximo início.
    }
  }

  /// Switches between light and dark (used by the quick toggle buttons).
  Future<void> toggle() => setMode(isDark ? ThemeMode.light : ThemeMode.dark);
}

final themeController = ThemeController();
