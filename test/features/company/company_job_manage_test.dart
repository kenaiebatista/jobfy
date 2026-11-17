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

/// One job and one candidate, kept in memory like the tables would be.
class _FakeRepository implements CompanyRepository {
  JobEntity job = const JobEntity(
    id: '5',
    companyId: '1',
    title: 'Flutter Developer',
    description: 'Build the app.',
    location: 'Gaspar - SC',
    contractType: 'clt',
    salary: 'R\$ 4000 – 6000',
    workMode: 'Híbrido',
    status: 'open',
    candidateCount: 1,
    area: 'Technology',
    salaryMin: 4000,
    salaryMax: 6000,
    workload: '40h semanais',
  );
  CandidateEntity candidate = const CandidateEntity(id: '10', name: 'Ana Clara Souza', email: 'ana@email.com');

  final updated = <NewJobEntity>[];
  final statuses = <JobStatus>[];
  final answers = <ApplicationStatus>[];

  @override
  Future<CompanyEntity> getCompany(String companyId) async => const CompanyEntity(
        companyId: '1',
        companyName: 'Tech Nova Ltda',
        cnpj: '12345678000190',
        email: 'rh@technova.com.br',
        phone: '',
      );

  @override
  Future<List<JobEntity>> getCompanyJobs(String companyId) async => [job];

  @override
  Future<void> updateJob(String jobId, NewJobEntity edited) async {
    updated.add(edited);
    job = JobEntity(
      id: job.id,
      companyId: job.companyId,
      title: edited.title,
      description: edited.description,
      location: edited.location,
      contractType: edited.contractType.name,
      salary: job.salary,
      workMode: edited.workMode.dbValue,
      status: job.status,
      candidateCount: job.candidateCount,
    );
  }

  @override
  Future<void> setJobStatus(String companyId, String jobId, JobStatus status) async {
    statuses.add(status);
    job = JobEntity(
      id: job.id,
      companyId: job.companyId,
      title: job.title,
      description: job.description,
      location: job.location,
      contractType: job.contractType,
      salary: job.salary,
      workMode: job.workMode,
      status: status.name,
      candidateCount: job.candidateCount,
    );
  }

  @override
  Future<List<CandidateEntity>> getJobCandidates(String jobId) async => [candidate];

  @override
  Future<void> setCandidateStatus(
    String companyId,
    String jobId,
    String userId,
    ApplicationStatus status,
  ) async {
    answers.add(status);
    candidate = candidate.copyWith(status: status.dbValue);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, _FakeRepository repository) async {
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
        home: Scaffold(body: CompanyPage(repository: repository)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openMenu(WidgetTester tester, String tooltip, String item) async {
  await tester.tap(find.byTooltip(tooltip));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the company edits a job: the form comes filled and saves the changes', (tester) async {
    final repository = _FakeRepository();
    await _pump(tester, repository);

    await _openMenu(tester, 'Job options', 'Edit job');

    final dialog = find.byType(Dialog);
    final title = find.descendant(of: dialog, matching: find.widgetWithText(TextFormField, 'Job title'));
    expect(tester.widget<TextFormField>(title).controller!.text, 'Flutter Developer');
    expect(find.descendant(of: dialog, matching: find.text('Hybrid')), findsOneWidget);
    expect(find.descendant(of: dialog, matching: find.text('CLT')), findsOneWidget);

    await tester.enterText(title, 'Senior Flutter Developer');
    await tester.pumpAndSettle();
    // The form scrolls inside the dialog.
    final save = find.descendant(of: dialog, matching: find.text('Save changes'));
    await tester.scrollUntilVisible(
      save,
      100,
      scrollable: find
          .descendant(of: dialog, matching: find.byType(Scrollable))
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    final saved = repository.updated.single;
    expect(saved.title, 'Senior Flutter Developer');
    expect(saved.salaryMin, 4000);
    expect(saved.salaryMax, 6000);
    expect(saved.area, 'Technology');
    expect(saved.workMode, WorkMode.hybrid);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Job updated!'), findsOneWidget);
    expect(find.text('Senior Flutter Developer'), findsOneWidget);
  });

  testWidgets('the company closes a job after confirming, and can reopen it', (tester) async {
    final repository = _FakeRepository();
    await _pump(tester, repository);

    await _openMenu(tester, 'Job options', 'Close job');
    expect(find.text('Close this job? It stops showing to candidates and takes no more applications.'), findsOneWidget);

    // Cancel: nothing changes.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.statuses, isEmpty);

    await _openMenu(tester, 'Job options', 'Close job');
    // The dialog title says "Close job" too; tap the button.
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(TextButton, 'Close job'),
    ));
    await tester.pumpAndSettle();

    expect(repository.statuses, [JobStatus.closed]);
    expect(find.text('Job closed.'), findsOneWidget);
    expect(find.textContaining('Closed'), findsOneWidget);

    await _openMenu(tester, 'Job options', 'Reopen job');
    expect(repository.statuses, [JobStatus.closed, JobStatus.open]);
  });

  testWidgets('the company approves and rejects a candidate from the list', (tester) async {
    final repository = _FakeRepository();
    await _pump(tester, repository);

    await tester.tap(find.text('View candidates (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Under review'), findsOneWidget);

    await _openMenu(tester, 'Answer candidate', 'Approve');
    expect(repository.answers, [ApplicationStatus.approved]);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Under review'), findsNothing);

    // The menu no longer offers the current answer.
    await tester.tap(find.byTooltip('Answer candidate'));
    await tester.pumpAndSettle();
    expect(find.text('Approve'), findsNothing);
    expect(find.text('Reject'), findsOneWidget);
    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();

    expect(repository.answers, [ApplicationStatus.approved, ApplicationStatus.rejected]);
    expect(find.text('Rejected'), findsOneWidget);
  });
}
