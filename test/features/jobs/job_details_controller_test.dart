import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/features/jobs/data/datasources/job_data_source.dart';
import 'package:jobfy/features/jobs/data/models/job_details_model.dart';
import 'package:jobfy/features/jobs/data/models/job_listing_model.dart';
import 'package:jobfy/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:jobfy/features/jobs/domain/usecases/apply_to_job_usecase.dart';
import 'package:jobfy/features/jobs/domain/usecases/get_job_details_usecase.dart';
import 'package:jobfy/features/jobs/domain/usecases/withdraw_application_usecase.dart';
import 'package:jobfy/features/jobs/presentation/controllers/job_details_controller.dart';

/// Keeps the applications in memory, like the `applications` table would.
class _TestJobDataSource implements JobDataSource {
  final applications = <(String jobId, String userId)>{};
  String status = 'open';

  /// What the company answered ('approved', 'rejected'...), when applied.
  String? answer;

  @override
  Future<List<JobListingModel>> searchJobs({
    String? query,
    String? location,
    String? area,
    String? contractType,
  }) async => [];

  @override
  Future<JobDetailsModel?> getJobDetails(String jobId, {String? userId}) async {
    if (jobId != '1') return null;
    // Same shape as the MySQL row (everything as text).
    return JobDetailsModel.fromJson({
      'id': '1',
      'title': 'Estágio em Suporte de TI',
      'location': 'Belo Horizonte, MG',
      'work_mode': 'Presencial',
      'contract_type': 'internship',
      'workload': '30h semanais (6h por dia)',
      'salary': 'R\$ 1.500 – 1.800',
      'description': 'Atendimento a usuários.',
      'requirements': 'Cursando TI.',
      'benefits': '',
      'published_at': '2026-11-01',
      'status': status,
      'company_name': 'Conecta Telecom',
      'trade_name': null,
      'application_status':
          applications.contains((jobId, userId)) ? (answer ?? 'under_review') : null,
    });
  }

  @override
  Future<void> applyToJob(String jobId, String userId) async {
    // Like the database: applying again starts over only after withdrawing.
    if (answer == 'withdrawn') answer = null;
    applications.add((jobId, userId));
  }

  @override
  Future<void> withdrawApplication(String jobId, String userId) async => answer = 'withdrawn';
}

void main() {
  late _TestJobDataSource source;
  late JobDetailsController controller;

  setUp(() {
    source = _TestJobDataSource();
    final repo = JobRepositoryImpl(source);
    controller = JobDetailsController(
      GetJobDetailsUsecase(repo),
      ApplyToJobUsecase(repo),
      WithdrawApplicationUsecase(repo),
    );
  });

  test('loads the job details from the row', () async {
    await controller.load('1', userId: '7');

    final job = controller.job!;
    expect(controller.status, JobDetailsStatus.loaded);
    expect(job.workload, '30h semanais (6h por dia)');
    expect(job.requirements, 'Cursando TI.');
    expect(job.benefits, isNull); // empty text counts as not informed
    expect(job.publishedAt, DateTime(2026, 11, 1));
    expect(job.companyDisplayName, 'Conecta Telecom');
    expect(job.hasApplied, isFalse);
  });

  test('a missing job is not found', () async {
    await controller.load('99', userId: '7');

    expect(controller.status, JobDetailsStatus.notFound);
  });

  test('applying saves the application once and marks the job', () async {
    await controller.load('1', userId: '7');

    expect(await controller.apply('7'), isTrue);
    expect(controller.job!.hasApplied, isTrue);
    expect(source.applications, {('1', '7')});

    // Already applied: nothing else is sent.
    expect(await controller.apply('7'), isFalse);

    // Opening the job again still shows it as applied.
    await controller.load('1', userId: '7');
    expect(controller.job!.hasApplied, isTrue);
  });

  test('shows what the company answered to the application', () async {
    source.applications.add(('1', '7'));
    source.answer = 'approved';

    await controller.load('1', userId: '7');

    expect(controller.job!.hasApplied, isTrue);
    expect(controller.job!.applicationStatus, 'approved');
  });

  test('withdrawing gives up the application and allows applying again', () async {
    await controller.load('1', userId: '7');
    expect(await controller.withdraw('7'), isFalse); // nothing to withdraw yet

    await controller.apply('7');
    expect(controller.job!.canWithdraw, isTrue);

    expect(await controller.withdraw('7'), isTrue);
    expect(controller.job!.applicationStatus, 'withdrawn');
    expect(controller.job!.hasApplied, isFalse); // not an active application
    expect(controller.job!.canWithdraw, isFalse);

    expect(await controller.apply('7'), isTrue); // applies again
    expect(controller.job!.applicationStatus, 'under_review');
  });

  test('a rejected application can not be withdrawn', () async {
    source.applications.add(('1', '7'));
    source.answer = 'rejected';
    await controller.load('1', userId: '7');

    expect(controller.job!.canWithdraw, isFalse);
    expect(await controller.withdraw('7'), isFalse);
  });

  test('a closed job takes no applications', () async {
    source.status = 'closed';
    await controller.load('1', userId: '7');

    expect(await controller.apply('7'), isFalse);
    expect(source.applications, isEmpty);
  });
}
