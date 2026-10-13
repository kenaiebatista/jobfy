import 'package:jobfy/features/jobs/data/datasources/job_data_source.dart';
import 'package:jobfy/features/jobs/data/models/job_listing_model.dart';

/// Returns no jobs, so widget tests don't try to reach the MySQL database.
class EmptyJobDataSource implements JobDataSource {
  @override
  Future<List<JobListingModel>> searchJobs({String? query, String? location}) async => [];

  @override
  Future<void> applyToJob(String jobId) async {}
}
