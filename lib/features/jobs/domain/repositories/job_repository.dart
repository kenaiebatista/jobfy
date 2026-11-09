import '../entities/job_details_entity.dart';
import '../entities/job_listing_entity.dart';

abstract class JobRepository {
  Future<List<JobListingEntity>> searchJobs({String? query, String? location});

  Future<JobDetailsEntity?> getJobDetails(String jobId, {String? userId});

  Future<void> applyToJob(String jobId, String userId);
}
