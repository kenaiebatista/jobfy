import '../entities/job_details_entity.dart';
import '../repositories/job_repository.dart';

class GetJobDetailsUsecase {
  final JobRepository _repository;

  GetJobDetailsUsecase(this._repository);

  Future<JobDetailsEntity?> call(String jobId, {String? userId}) {
    return _repository.getJobDetails(jobId, userId: userId);
  }
}
