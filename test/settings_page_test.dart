import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/settings/settings_controller.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/settings/presentation/pages/settings_page.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

Widget _wrap(SettingsController settings, Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider(
        create: (_) => UserSessionController(
          GetUserProfileUsecase(UserRepositoryImpl()),
        ),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ),
  );
}

void main() {
  testWidgets('tapping Dark updates the SettingsController theme mode', (tester) async {
    final settings = SettingsController();

    await tester.pumpWidget(_wrap(settings, const SettingsPage()));
    await tester.pumpAndSettle();

    expect(settings.themeMode, ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(settings.themeMode, ThemeMode.dark);
  });

  testWidgets('tapping a language option updates the SettingsController locale', (tester) async {
    final settings = SettingsController();

    await tester.pumpWidget(_wrap(settings, const SettingsPage()));
    await tester.pumpAndSettle();

    expect(settings.locale, isNull);

    await tester.tap(find.text('Português (Brasil)'));
    await tester.pumpAndSettle();

    expect(settings.locale, const Locale('pt', 'BR'));
  });
}
