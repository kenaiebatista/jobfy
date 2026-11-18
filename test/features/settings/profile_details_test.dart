import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/settings/settings_controller.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/settings/presentation/pages/settings_page.dart';
import 'package:jobfy/features/user/data/datasources/user_fake_data_source.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/empty_job_data_source.dart';

/// The user edits skills and experiences in Settings; the profile in the
/// session is reloaded after each change (here the in-memory fake plays the
/// database).
final _users = UserRepositoryImpl(UserFakeDataSource(EmptyJobDataSource()));

Future<void> _settle(WidgetTester tester) async {
  // The fake backend answers after a short delay.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
  await tester.pumpAndSettle();
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final session = UserSessionController(GetUserProfileUsecase(_users))..start('usr_001');
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: SettingsPage(userRepository: _users)),
      ),
    ),
  );
  await _settle(tester);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('adds a skill with its level, changes it by adding again, and removes it', (tester) async {
    await _pump(tester);
    expect(find.textContaining('Flutter ·'), findsOneWidget); // the user's existing skills

    final field = find.widgetWithText(TextField, 'Other skill...');
    await tester.enterText(field, 'Python');
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await _settle(tester);

    expect(find.text('Python · Beginner'), findsOneWidget);
    expect(find.text('Changes saved successfully.'), findsOneWidget);

    // Same skill again with another level: still one chip, new level.
    await tester.tap(find.byType(DropdownButton<SkillLevel>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advanced').last);
    await tester.pumpAndSettle();
    await tester.enterText(field, 'python');
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await _settle(tester);

    expect(find.text('Python · Advanced'), findsOneWidget);
    expect(find.text('Python · Beginner'), findsNothing);

    await tester.tap(find.descendant(
      of: find.widgetWithText(InputChip, 'Python · Advanced'),
      matching: find.byTooltip('Remove'),
    ));
    await _settle(tester);

    expect(find.textContaining('Python'), findsNothing);
    expect(find.textContaining('Flutter ·'), findsOneWidget); // the others stay
  });

  testWidgets('an empty skill is not added', (tester) async {
    await _pump(tester);
    final before = find.byType(InputChip).evaluate().length;

    await tester.enterText(find.widgetWithText(TextField, 'Other skill...'), '   ');
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await _settle(tester);

    expect(find.byType(InputChip).evaluate().length, before);
  });

  testWidgets('adds an experience, shows it, and deletes it', (tester) async {
    await _pump(tester);
    expect(find.textContaining('Café Central'), findsNothing);

    await tester.ensureVisible(find.text('Add experience'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add experience'));
    await tester.pumpAndSettle();

    final fields = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextFormField));
    await tester.enterText(fields.at(0), 'Barista');
    await tester.enterText(fields.at(1), 'Café Central');
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Start')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Add')));
    await _settle(tester);

    expect(find.text('Barista'), findsOneWidget);
    expect(find.textContaining('Café Central'), findsOneWidget);

    final delete = find.descendant(
      of: find.ancestor(of: find.text('Barista'), matching: find.byType(Container)).first,
      matching: find.byTooltip('Remove'),
    );
    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await _settle(tester);

    expect(find.text('Barista'), findsNothing);
  });
}
