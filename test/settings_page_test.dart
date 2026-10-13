import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/settings/settings_controller.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:jobfy/features/settings/presentation/pages/settings_page.dart';
import 'package:jobfy/features/user/data/datasources/user_fake_data_source.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/empty_job_data_source.dart';

final _fakeUsers = UserRepositoryImpl(UserFakeDataSource(EmptyJobDataSource()));

Widget _wrap(SettingsController settings, Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider(
        create: (_) => UserSessionController(
          GetUserProfileUsecase(_fakeUsers),
        )..start('usr_001'),
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
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tapping Dark updates the SettingsController theme mode', (tester) async {
    final settings = SettingsController();

    await tester.pumpWidget(_wrap(settings, SettingsPage(userRepository: _fakeUsers)));
    await tester.pumpAndSettle();

    expect(settings.themeMode, ThemeMode.system);

    await tester.ensureVisible(find.text('Dark'));
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(settings.themeMode, ThemeMode.dark);
  });

  testWidgets('tapping a language option updates the SettingsController locale', (tester) async {
    final settings = SettingsController();

    await tester.pumpWidget(_wrap(settings, SettingsPage(userRepository: _fakeUsers)));
    await tester.pumpAndSettle();

    expect(settings.locale, isNull);

    await tester.ensureVisible(find.text('Português (Brasil)'));
    await tester.tap(find.text('Português (Brasil)'));
    await tester.pumpAndSettle();

    expect(settings.locale, const Locale('pt', 'BR'));
  });
  testWidgets('notification toggles are saved on the device', (tester) async {
    await tester.pumpWidget(_wrap(SettingsController(), SettingsPage(userRepository: _fakeUsers)));
    await tester.pumpAndSettle();

    final toggle = find.byType(Switch).first;
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();

    final saved = await SettingsRepositoryImpl().getPreferences();
    expect(saved.newJobAlerts, isFalse);
  });

  testWidgets('change password rejects a wrong current password', (tester) async {
    await tester.pumpWidget(_wrap(SettingsController(), SettingsPage(userRepository: _fakeUsers)));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Change password'));
    await tester.tap(find.text('Change password'));
    await tester.pumpAndSettle();

    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.at(0), 'wrong-password');
    await tester.enterText(fields.at(1), 'newpass123');
    await tester.enterText(fields.at(2), 'newpass123');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Current password is incorrect.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('saving the account form updates the signed-in profile', (tester) async {
    await tester.pumpWidget(_wrap(SettingsController(), SettingsPage(userRepository: _fakeUsers)));
    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextFormField, 'Full name');
    await tester.enterText(nameField, 'Maria Souza');
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    // The session reloads the profile from the (slow) fake source.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Changes saved successfully.'), findsOneWidget);
    final session = tester
        .element(find.byType(SettingsPage))
        .read<UserSessionController>();
    expect(session.profile?.name, 'Maria Souza');
  });
}
