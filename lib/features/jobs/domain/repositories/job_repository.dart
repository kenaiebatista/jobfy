import '../entities/job_listing_entity.dart';

abstract class JobRepository {
  Future<List<JobListingEntity>> searchJobs({String? query, String? location});

  Future<void> applyToJob(String jobId);
}
