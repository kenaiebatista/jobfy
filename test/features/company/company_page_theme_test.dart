import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/core/theme/app_semantic_colors.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/company/presentation/pages/company_page.dart';
import 'package:jobfy/l10n/app_localizations.dart';

/// Regression test: the company registration button used to be hardcoded
/// black. On the dark theme, the page background is also near-black
/// (AppColors.backgroundDark), so the button became effectively invisible.
/// It must now track the theme's accent color instead.
void main() {
  testWidgets('Company registration button is not black-on-black in dark mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
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
        home: const CompanyPage(),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final backgroundColor = button.style?.backgroundColor?.resolve({});

    expect(backgroundColor, isNotNull);
    expect(backgroundColor, isNot(Colors.black));
    expect(backgroundColor, AppSemanticColors.dark.accent);
  });
}
