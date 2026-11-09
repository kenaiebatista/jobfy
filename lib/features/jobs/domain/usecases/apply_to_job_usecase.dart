import '../repositories/job_repository.dart';

class ApplyToJobUsecase {
  final JobRepository _repository;

  ApplyToJobUsecase(this._repository);

  Future<void> call(String jobId, String userId) => _repository.applyToJob(jobId, userId);
}
