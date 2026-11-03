import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/app_theme.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';
import 'package:jobfy/features/company/presentation/pages/company_page.dart';
import 'package:jobfy/features/user/data/datasources/user_fake_data_source.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../helpers/empty_job_data_source.dart';

/// Keeps what was published in memory, like the `jobs` table would.
class _FakeRepository implements CompanyRepository {
  final published = <NewJobEntity>[];

  @override
  Future<CompanyEntity> getCompany(String companyId) async => const CompanyEntity(
        companyId: '1',
        companyName: 'Tech Nova Ltda',
        cnpj: '12345678000190',
        email: 'rh@technova.com.br',
        phone: '',
      );

  @override
  Future<List<JobEntity>> getCompanyJobs(String companyId) async => [
        for (final job in published)
          JobEntity(
            id: job.title,
            companyId: job.companyId,
            title: job.title,
            description: job.description,
            location: job.location,
            contractType: job.contractType.name,
            salary: '',
            workMode: job.workMode.dbValue,
            status: 'open',
          ),
      ];

  @override
  Future<void> publishJob(NewJobEntity job) async => published.add(job);

  // The candidate tools and the sign-up aren't used by the job form.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, CompanyRepository repository) async {
  tester.view.physicalSize = const Size(1000, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => UserSessionController(
        GetUserProfileUsecase(UserRepositoryImpl(UserFakeDataSource(EmptyJobDataSource()))),
      )..startCompany('1'),
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
        home: CompanyPage(repository: repository),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String label, String text) =>
    tester.enterText(find.widgetWithText(TextFormField, label), text);

Future<void> _select(WidgetTester tester, String label, String option) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

Future<void> _fillForm(WidgetTester tester, {String min = '4000', String max = '6000'}) async {
  await _enter(tester, 'Job title', 'Flutter Developer');
  await _enter(tester, 'Area', 'Technology');
  await _enter(tester, 'Location', 'Gaspar - SC');
  await _select(tester, 'Work mode', 'Hybrid');
  await _select(tester, 'Contract type', 'CLT');
  await _enter(tester, 'Minimum salary (R\$)', min);
  await _enter(tester, 'Maximum salary (R\$)', max);
  await _enter(tester, 'Description', 'Build the app.');
}

Future<void> _publish(WidgetTester tester) async {
  await tester.tap(find.text('Publish job'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an empty form publishes nothing', (tester) async {
    final repository = _FakeRepository();
    await _pump(tester, repository);

    await _publish(tester);

    expect(find.text('Required field'), findsWidgets);
    expect(repository.published, isEmpty);
  });

  testWidgets('the maximum salary cannot be lower than the minimum', (tester) async {
    final repository = _FakeRepository();
    await _pump(tester, repository);

    await _fillForm(tester, min: '6000', max: '4000');
    await _publish(tester);

    expect(find.text('Cannot be lower than the minimum salary.'), findsOneWidget);
    expect(repository.published, isEmpty);
  });

  testWidgets('publishing sends the jobs columns, lists the job and clears the form', (tester) async {
    final repository = _FakeRepository();
    await _pump(tester, repository);

    await _fillForm(tester);
    await _publish(tester);

    final job = repository.published.single;
    expect(job.companyId, '1');
    expect(job.title, 'Flutter Developer');
    expect(job.area, 'Technology');
    expect(job.location, 'Gaspar - SC');
    expect(job.workMode, WorkMode.hybrid);
    expect(job.contractType, ContractType.clt);
    expect(job.salaryMin, 4000);
    expect(job.salaryMax, 6000);
    expect(job.description, 'Build the app.');

    expect(find.text('Job published!'), findsOneWidget);
    expect(find.text('Flutter Developer'), findsOneWidget); // the job card
    expect(find.widgetWithText(TextFormField, 'Flutter Developer'), findsNothing);
    final dropdown = tester.widget<DropdownButtonFormField<WorkMode>>(
      find.byType(DropdownButtonFormField<WorkMode>),
    );
    expect(dropdown.initialValue, isNull);
    expect(find.text('Hybrid'), findsNothing);
  });
}
