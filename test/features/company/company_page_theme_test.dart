import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/core/theme/app_semantic_colors.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/company/presentation/widgets/company_register_form.dart';
import 'package:jobfy/l10n/app_localizations.dart';

/// Regression test: the company registration button used to be hardcoded
/// black. On the dark theme, the page background is also near-black
/// (AppColors.backgroundDark), so the button became effectively invisible.
/// The company sign-up now lives on the register page (CompanyRegisterForm)
/// and its button follows the theme like the candidate sign-up button.
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
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompanyRegisterForm(
              termsRow: const SizedBox.shrink(),
              acceptedTerms: false,
              footer: const SizedBox.shrink(),
              onRegistered: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final backgroundColor = button.style?.backgroundColor?.resolve({});

    expect(backgroundColor, isNotNull);
    expect(backgroundColor, isNot(Colors.black));
    expect(backgroundColor, isNot(AppSemanticColors.dark.background));
    expect(backgroundColor, AppSemanticColors.dark.textPrimary);
  });
}
