import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jobfy/core/network/api_exception.dart';
import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/settings/settings_controller.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';
import 'package:jobfy/features/settings/presentation/pages/settings_page.dart';
import 'package:jobfy/features/user/data/datasources/user_fake_data_source.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/empty_job_data_source.dart';

/// The company's account lives in memory, like the `companies`/`accounts`
/// rows would.
class _FakeCompanies implements CompanyRepository {
  CompanyEntity company = const CompanyEntity(
    companyId: '1',
    companyName: 'Tech Nova Ltda',
    cnpj: '12345678000190',
    email: 'rh@technova.com.br',
    phone: '(11) 4003-2211',
    tradeName: 'TechNova',
    city: 'Gaspar',
    state: 'SC',
  );
  final saved = <CompanyEntity>[];
  var password = 'jobfy123';
  var emailTaken = false;
  var deleted = false;

  @override
  Future<CompanyEntity> getCompany(String companyId) async => company;

  @override
  Future<void> updateCompany(CompanyEntity updated) async {
    if (emailTaken) throw const ApiStatusException(409, 'email');
    saved.add(updated);
    company = updated;
  }

  @override
  Future<bool> changePassword(String companyId, String currentPassword, String newPassword) async {
    if (currentPassword != password) return false;
    password = newPassword;
    return true;
  }

  @override
  Future<void> deleteAccount(String companyId) async => deleted = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<UserSessionController> _pump(WidgetTester tester, _FakeCompanies companies) async {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final session = UserSessionController(
    GetUserProfileUsecase(UserRepositoryImpl(UserFakeDataSource(EmptyJobDataSource()))),
  )..startCompany('1', name: 'Tech Nova Ltda');

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Signing out goes to '/', so the page needs a router to leave through.
        routerConfig: GoRouter(
          initialLocation: '/settings',
          routes: [
            GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('home'))),
            GoRoute(
              path: '/settings',
              builder: (_, __) => Scaffold(body: SettingsPage(companyRepository: companies)),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return session;
}

Finder _field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the company data, with the legal name and CNPJ fixed', (tester) async {
    await _pump(tester, _FakeCompanies());

    expect(find.text('Company data'), findsOneWidget);
    expect(tester.widget<TextFormField>(_field('Trade name')).controller!.text, 'TechNova');
    expect(tester.widget<TextFormField>(_field('Phone')).controller!.text, '(11) 4003-2211');
    expect(find.text('Tech Nova Ltda'), findsOneWidget); // legal name, not editable
    expect(find.text('12.345.678/0001-90'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget); // app preferences are still there
  });

  testWidgets('saving changes the data in the database', (tester) async {
    final companies = _FakeCompanies();
    await _pump(tester, companies);

    await tester.enterText(_field('Phone'), '(47) 3333-0000');
    await tester.enterText(_field('ZIP code'), '89110-000');
    await tester.enterText(_field('State'), 'sc');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final updated = companies.saved.single;
    expect(updated.phone, '(47) 3333-0000');
    expect(updated.zipCode, '89110-000');
    expect(updated.tradeName, 'TechNova');
    expect(updated.companyName, 'Tech Nova Ltda'); // never changes
    expect(updated.cnpj, '12345678000190');
    expect(find.text('Changes saved successfully.'), findsOneWidget);
  });

  testWidgets('an invalid email or ZIP code is not saved', (tester) async {
    final companies = _FakeCompanies();
    await _pump(tester, companies);

    await tester.enterText(_field('Email'), 'not-an-email');
    await tester.enterText(_field('ZIP code'), '123');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email.'), findsOneWidget);
    expect(find.text('The ZIP code must have 8 digits.'), findsOneWidget);
    expect(companies.saved, isEmpty);
  });

  testWidgets('an email that belongs to another account is refused', (tester) async {
    final companies = _FakeCompanies()..emailTaken = true;
    await _pump(tester, companies);

    await tester.enterText(_field('Email'), 'other@company.com');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('This email is already registered.'), findsOneWidget);
    expect(companies.saved, isEmpty);
  });

  testWidgets('the password changes only with the right current one', (tester) async {
    final companies = _FakeCompanies();
    await _pump(tester, companies);

    Future<void> submit(String current) async {
      await tester.tap(find.widgetWithText(OutlinedButton, 'Change password'));
      await tester.pumpAndSettle();
      final fields = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextFormField));
      await tester.enterText(fields.at(0), current);
      await tester.enterText(fields.at(1), 'newpass123');
      await tester.enterText(fields.at(2), 'newpass123');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }

    await submit('wrong-password');
    expect(find.text('Current password is incorrect.'), findsOneWidget);
    expect(companies.password, 'jobfy123');

    // The dialog stays open: fix the current password and send again.
    final fields = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextFormField));
    await tester.enterText(fields.at(0), 'jobfy123');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(companies.password, 'newpass123');
    expect(find.text('Password changed successfully.'), findsOneWidget);
  });

  testWidgets('deleting the account asks first, then closes it', (tester) async {
    final companies = _FakeCompanies();
    final session = await _pump(tester, companies);

    await tester.ensureVisible(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    // Cancel: nothing happens.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(companies.deleted, isFalse);
    expect(session.isCompanySignedIn, isTrue);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Its jobs will be closed'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(companies.deleted, isTrue);
    expect(session.isCompanySignedIn, isFalse); // signed out
    expect(find.text('home'), findsOneWidget);
  });
}
