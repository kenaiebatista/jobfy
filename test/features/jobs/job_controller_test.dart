import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/features/jobs/data/datasources/job_fake_data_source.dart';
import 'package:jobfy/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:jobfy/features/jobs/domain/usecases/apply_to_job_usecase.dart';
import 'package:jobfy/features/jobs/domain/usecases/search_jobs_usecase.dart';
import 'package:jobfy/features/jobs/presentation/controllers/job_controller.dart';

void main() {
  late JobController controller;

  setUp(() {
    final repo = JobRepositoryImpl(JobFakeDataSource());
    controller = JobController(SearchJobsUsecase(repo), ApplyToJobUsecase(repo));
  });

  test('search loads jobs and filters by query', () async {
    await controller.search();
    expect(controller.jobs, isNotEmpty);

    await controller.search(query: 'Nubank');
    expect(controller.jobs, hasLength(1));
    expect(controller.jobs.first.company, 'Nubank');
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
