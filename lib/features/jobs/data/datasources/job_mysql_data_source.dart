import 'package:jobfy/core/database/database_service.dart';
import 'job_data_source.dart';
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

  // Not saved to the `applications` table yet: the button only marks the
  // job as applied on screen. (The signed-in user's id is available from
  // UserSessionController, so this is the next step.)
  @override
  Future<void> applyToJob(String jobId) async {}
}
