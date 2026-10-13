import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/core/theme/app_semantic_colors.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/auth/presentation/pages/login_page.dart';
import 'package:jobfy/features/auth/presentation/pages/register_page.dart';
import 'package:jobfy/l10n/app_localizations.dart';

/// Regression test: login and register follow the app theme. They used to
/// force the light theme on part of the tree while the card colors came
/// from the dark one, which rendered dark text on a dark card.
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

  /// Color the [text] is actually painted with.
  Color? paintedColor(WidgetTester tester, String text) {
    final finder = find.text(text);
    final widget = tester.widget<Text>(finder);
    final inherited = DefaultTextStyle.of(tester.element(finder)).style;
    return inherited.merge(widget.style).color;
  }

  testWidgets('LoginPage follows dark mode', (tester) async {
    await tester.pumpWidget(wrap(const LoginPage()));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Welcome back'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(paintedColor(tester, 'Welcome back'), AppSemanticColors.dark.textPrimary);
  });

  testWidgets('RegisterPage follows dark mode', (tester) async {
    await tester.pumpWidget(wrap(const RegisterPage()));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Create your account'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      paintedColor(tester, 'Create your account'),
      AppSemanticColors.dark.textPrimary,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor,
      AppSemanticColors.dark.background,
    );
  });
}
