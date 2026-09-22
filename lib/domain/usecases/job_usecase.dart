import '../entities/job_entity.dart';
import '../repositories/job_repository.dart';

class JobUsecase {
  final JobRepository _repository;

  JobUsecase(this._repository);

  Future<List<JobEntity>> getJobs() {
    return _repository.getJobs();
  }

  Future<void> candidatar(String jobId) {
    return _repository.candidatar(jobId);
  }

  Future<void> salvarVaga(String jobId) {
    return _repository.salvarVaga(jobId);
  }

  Future<void> removerVagaSalva(String jobId) {
    return _repository.removerVagaSalva(jobId);
  }
}
