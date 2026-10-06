import '../repositories/job_repository.dart';

class ApplyToJobUsecase {
  final JobRepository _repository;

  ApplyToJobUsecase(this._repository);

  Future<void> call(String jobId) => _repository.applyToJob(jobId);
}
