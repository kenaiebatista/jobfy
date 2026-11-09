import 'package:jobfy/core/network/api_client.dart';
import 'package:jobfy/core/network/api_exception.dart';
import 'job_data_source.dart';
import '../models/job_details_model.dart';
import '../models/job_listing_model.dart';

/// Talks to the Jobfy backend's public job-search endpoints.
///
/// Expected contract (Go backend, JSON, snake_case fields):
///   GET  /jobs?query=&location=  -> `List<JobListingModel>`
///   GET  /jobs/{id}?user_id=     -> JobDetailsModel (404 if missing)
///   POST /jobs/{id}/apply  {user_id} -> 204
class JobRemoteDataSource implements JobDataSource {
  final ApiClient _client;

  JobRemoteDataSource(this._client);

  @override
  Future<List<JobListingModel>> searchJobs({String? query, String? location}) async {
    final json = await _client.get('/jobs', query: {
      if (query != null && query.isNotEmpty) 'query': query,
      if (location != null && location.isNotEmpty) 'location': location,
    }) as List;
    return json.map((j) => JobListingModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<JobDetailsModel?> getJobDetails(String jobId, {String? userId}) async {
    try {
      final json = await _client.get('/jobs/$jobId', query: {
        if (userId != null) 'user_id': userId,
      }) as Map<String, dynamic>;
      return JobDetailsModel.fromJson(json);
    } on ApiStatusException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> applyToJob(String jobId, String userId) {
    return _client.post('/jobs/$jobId/apply', body: {'user_id': userId});
  }
}
