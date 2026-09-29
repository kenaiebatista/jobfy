import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/features/jobs/data/datasources/job_data_source.dart';
import 'package:jobfy/features/jobs/data/models/job_listing_model.dart';
import 'package:jobfy/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:jobfy/features/jobs/domain/usecases/apply_to_job_usecase.dart';
import 'package:jobfy/features/jobs/domain/usecases/search_jobs_usecase.dart';
import 'package:jobfy/features/jobs/presentation/controllers/job_controller.dart';

/// Test-only stand-in for [JobMysqlDataSource], so these tests don't need a
/// running database. Uses two of the jobs from database/jobfy_seed.sql.
class _TestJobDataSource implements JobDataSource {
  static const _jobs = [
    JobListingModel(
      id: '1',
      title: 'Desenvolvedor(a) Flutter Pleno',
      company: 'TechNova Soluções Digitais',
      location: 'São Paulo, SP',
      type: 'Remoto',
      salary: 'R\$ 7.000 – 10.000',
      description: 'Vaga de Flutter.',
    ),
    JobListingModel(
      id: '2',
      title: 'Analista de Dados Júnior',
      company: 'Verde Agro Analytics',
      location: 'Campinas, SP',
      type: 'Híbrido',
      salary: 'R\$ 4.500 – 6.500',
      description: 'Vaga de dados.',
    ),
  ];

  @override
  Future<List<JobListingModel>> searchJobs({String? query, String? location}) async {
    final q = (query ?? '').toLowerCase();
    return _jobs
        .where((j) =>
            j.title.toLowerCase().contains(q) ||
            j.company.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<void> applyToJob(String jobId) async {}
}

void main() {
  late JobController controller;

  setUp(() {
    final repo = JobRepositoryImpl(_TestJobDataSource());
    controller = JobController(SearchJobsUsecase(repo), ApplyToJobUsecase(repo));
  });

  test('search loads jobs and filters by query', () async {
    await controller.search();
    expect(controller.jobs, isNotEmpty);

    await controller.search(query: 'TechNova');
    expect(controller.jobs, hasLength(1));
    expect(controller.jobs.first.company, 'TechNova Soluções Digitais');
  });

  test('search with no matches returns an empty, non-error list', () async {
    await controller.search(query: 'this role does not exist');
    expect(controller.jobs, isEmpty);
    expect(controller.error, isNull);
  });

  test('apply marks the job as applied', () async {
    await controller.search();
    final jobId = controller.jobs.first.id;

    expect(controller.hasApplied(jobId), isFalse);

    final ok = await controller.apply(jobId);

    expect(ok, isTrue);
    expect(controller.hasApplied(jobId), isTrue);
  });
}
