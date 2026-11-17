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

/// One job with two people who applied to it.
class _FakeRepository implements CompanyRepository {
  @override
  Future<CompanyEntity> getCompany(String companyId) async => const CompanyEntity(
        companyId: '1',
        companyName: 'Tech Nova Ltda',
        cnpj: '12345678000190',
        email: 'rh@technova.com.br',
        phone: '',
      );

  @override
  Future<List<JobEntity>> getCompanyJobs(String companyId) async => const [
        JobEntity(
          id: '5',
          companyId: '1',
          title: 'Flutter Developer',
          description: '',
          location: 'Gaspar - SC',
          contractType: 'clt',
          salary: '',
          candidateCount: 2,
        ),
      ];

  @override
  Future<List<CandidateEntity>> getJobCandidates(String jobId) async => [
        CandidateEntity(id: '10', name: 'Ana Clara Souza', email: 'ana@email.com', appliedAt: DateTime(2026, 11, 2)),
        const CandidateEntity(id: '11', name: 'Marina Alves', email: 'marina@email.com'),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('the company sees who applied and can search them by name', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
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
          home: Scaffold(body: CompanyPage(repository: _FakeRepository())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('View candidates (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Clara Souza'), findsOneWidget);
    expect(find.text('Marina Alves'), findsOneWidget);
    expect(find.text('ana@email.com · Applied on 02/11/2026'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Search candidates by name'), 'mar');
    await tester.pump();

    expect(find.text('Ana Clara Souza'), findsNothing);
    expect(find.text('Marina Alves'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Search candidates by name'), 'zzz');
    await tester.pump();

    expect(find.text('No candidates with that name.'), findsOneWidget);
  });
}
