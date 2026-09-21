import '../entities/job_entity.dart';

abstract class JobRepository {
  Future<List<JobEntity>> getJobs();
  Future<void> candidatar(String jobId);
}
