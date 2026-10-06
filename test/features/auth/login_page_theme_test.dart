import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/auth/presentation/pages/login_page.dart';
import 'package:jobfy/features/auth/presentation/pages/register_page.dart';
import 'package:jobfy/l10n/app_localizations.dart';

/// Regression test: the login/register cards are intentionally light
/// regardless of the device's theme. If a future edit lets ambient dark
/// mode leak into them, their text silently turns white-on-white.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      );

  testWidgets('LoginPage form stays light even when the app is in dark mode', (tester) async {
    await tester.pumpWidget(wrap(const LoginPage()));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Welcome back'));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(Theme.of(context).colorScheme.onSurface, Colors.black87);
  });

  testWidgets('RegisterPage form stays light even when the app is in dark mode', (tester) async {
    await tester.pumpWidget(wrap(const RegisterPage()));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Create your account'));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(Theme.of(context).colorScheme.onSurface, Colors.black87);
  });
}
