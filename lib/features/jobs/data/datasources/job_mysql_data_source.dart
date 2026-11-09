import 'package:jobfy/core/database/database_service.dart';
import 'job_data_source.dart';
import '../models/job_details_model.dart';
import '../models/job_listing_model.dart';

/// Reads the job openings straight from the Jobfy MySQL database through
/// [DatabaseService]. Stand-in until the Go backend ([JobRemoteDataSource])
/// is deployed.
class JobMysqlDataSource implements JobDataSource {
  @override
  Future<List<JobListingModel>> searchJobs({String? query, String? location}) async {
    final rows = await DatabaseService.getOpenJobs(query: query, location: location);

    return rows
        .map((row) => JobListingModel(
              id: row['id'] ?? '',
              title: row['title'] ?? '',
              company: row['company'] ?? '',
              location: row['location'] ?? '',
              type: row['type'] ?? '',
              salary: row['salary'] ?? '',
              description: row['description'] ?? '',
            ))
        .toList();
  }

  @override
  Future<JobDetailsModel?> getJobDetails(String jobId, {String? userId}) async {
    final row = await DatabaseService.getJob(
      int.parse(jobId),
      userId: userId == null ? null : int.parse(userId),
    );
    return row == null ? null : JobDetailsModel.fromJson(row);
  }

  @override
  Future<void> applyToJob(String jobId, String userId) {
    return DatabaseService.applyToJob(userId: int.parse(userId), jobId: int.parse(jobId));
  }
}
