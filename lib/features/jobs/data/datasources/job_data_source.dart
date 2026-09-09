import '../models/job_listing_model.dart';

/// Where [JobRepositoryImpl] gets its data from. [JobRemoteDataSource] is
/// the real implementation (Jobfy Go backend); [JobFakeDataSource] is an
/// in-memory stand-in for local development and tests while the backend
/// isn't deployed yet.
abstract class JobDataSource {
  Future<List<JobListingModel>> searchJobs({String? query, String? location});

  Future<void> applyToJob(String jobId);
}
