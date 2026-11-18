import '../repositories/job_repository.dart';

class WithdrawApplicationUsecase {
  final JobRepository _repository;

  WithdrawApplicationUsecase(this._repository);

  Future<void> call(String jobId, String userId) => _repository.withdrawApplication(jobId, userId);
}
