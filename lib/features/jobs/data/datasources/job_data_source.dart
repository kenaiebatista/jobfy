import '../models/job_details_model.dart';
import '../models/job_listing_model.dart';

/// Where [JobRepositoryImpl] gets its data from. [JobRemoteDataSource] is
/// the real implementation (Jobfy Go backend); [JobMysqlDataSource] reads the
/// MySQL database directly while the backend
/// isn't deployed yet.
abstract class JobDataSource {
  /// [area] is free text; [contractType] a `jobs.contract_type` value.
  Future<List<JobListingModel>> searchJobs({
    String? query,
    String? location,
    String? area,
    String? contractType,
  });

  /// One job with its company, or null if it doesn't exist. [userId] tells
  /// whether that user already applied.
  Future<JobDetailsModel?> getJobDetails(String jobId, {String? userId});

  Future<void> applyToJob(String jobId, String userId);

  /// The user gives up the application (a pending or approved one).
  Future<void> withdrawApplication(String jobId, String userId);
}
