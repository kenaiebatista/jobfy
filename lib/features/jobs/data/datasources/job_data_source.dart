import '../models/job_details_model.dart';
import '../models/job_listing_model.dart';

/// Where [JobRepositoryImpl] gets its data from. [JobRemoteDataSource] is
/// the real implementation (Jobfy Go backend); [JobMysqlDataSource] reads the
/// MySQL database directly while the backend
/// isn't deployed yet.
abstract class JobDataSource {
  Future<List<JobListingModel>> searchJobs({String? query, String? location});

  /// One job with its company, or null if it doesn't exist. [userId] tells
  /// whether that user already applied.
  Future<JobDetailsModel?> getJobDetails(String jobId, {String? userId});

  Future<void> applyToJob(String jobId, String userId);
}
