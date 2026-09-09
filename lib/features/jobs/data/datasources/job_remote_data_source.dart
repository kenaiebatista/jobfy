import 'package:jobfy/core/network/api_client.dart';
import 'job_data_source.dart';
import '../models/job_listing_model.dart';

/// Talks to the Jobfy backend's public job-search endpoints.
///
/// Expected contract (Go backend, JSON, snake_case fields):
///   GET  /jobs?query=&location=  -> `List<JobListingModel>`
///   POST /jobs/{id}/apply        -> 204
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
  Future<void> applyToJob(String jobId) {
    return _client.post('/jobs/$jobId/apply');
  }
}
