import '../entities/job_entity.dart';

abstract class JobRepository {
  Future<List<JobEntity>> getJobs();
  Future<void> candidatar(String jobId);
  Future<void> salvarVaga(String jobId);
  Future<void> removerVagaSalva(String jobId);
}
