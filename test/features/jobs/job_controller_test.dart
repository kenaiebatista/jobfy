import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/features/jobs/data/datasources/job_data_source.dart';
import 'package:jobfy/features/jobs/data/models/job_details_model.dart';
import 'package:jobfy/features/jobs/data/models/job_listing_model.dart';
import 'package:jobfy/features/jobs/data/repositories/job_repository_impl.dart';
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

  String? lastArea;
  String? lastContractType;

  @override
  Future<List<JobListingModel>> searchJobs({
    String? query,
    String? location,
    String? area,
    String? contractType,
  }) async {
    lastArea = area;
    lastContractType = contractType;
    final q = (query ?? '').toLowerCase();
    return _jobs
        .where((j) =>
            j.title.toLowerCase().contains(q) ||
            j.company.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<JobDetailsModel?> getJobDetails(String jobId, {String? userId}) async => null;

  @override
  Future<void> applyToJob(String jobId, String userId) async {}

  @override
  Future<void> withdrawApplication(String jobId, String userId) async {}

}

void main() {
  late _TestJobDataSource source;
  late JobController controller;

  setUp(() {
    source = _TestJobDataSource();
    final repo = JobRepositoryImpl(source);
    controller = JobController(SearchJobsUsecase(repo));
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

  test('search passes the area and contract type filters on', () async {
    await controller.search(area: 'Tecnologia', contractType: 'internship');

    expect(source.lastArea, 'Tecnologia');
    expect(source.lastContractType, 'internship');
  });
}
