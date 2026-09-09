import 'package:jobfy/core/network/api_client.dart';
import '../../domain/entities/company_entity.dart';
import 'company_data_source.dart';
import '../models/candidate_model.dart';
import '../models/company_model.dart';
import '../models/job_model.dart';

/// Talks to the Jobfy backend's company endpoints.
///
/// Expected contract (Go backend, JSON, snake_case fields):
///   POST /companies                                    -> CompanyModel
///   POST /companies/{companyId}/jobs                   -> JobModel
///   GET  /companies/{companyId}/jobs/{jobId}/candidates -> `List<CandidateModel>`
///   POST /candidates/{id}/ratings   {rating, comment}
///   POST /candidates/{id}/messages  {message}
class CompanyRemoteDataSource implements CompanyDataSource {
  final ApiClient _client;

  CompanyRemoteDataSource(this._client);

  @override
  Future<CompanyEntity> registerCompany(CompanyEntity company) async {
    final json = await _client.post('/companies', body: {
      'company_name': company.companyName,
      'cnpj': company.cnpj,
      'email': company.email,
      'phone': company.phone,
    }) as Map<String, dynamic>;
    return CompanyModel.fromJson(json);
  }

  @override
  Future<JobEntity> publishJob(JobEntity job) async {
    final json = await _client.post(
      '/companies/${job.companyId}/jobs',
      body: {
        'title': job.title,
        'description': job.description,
        'location': job.location,
        'contract_type': job.contractType,
        'salary': job.salary,
      },
    ) as Map<String, dynamic>;
    return JobModel.fromJson(json);
  }

  @override
  Future<List<CandidateEntity>> filterCandidates(
    String jobId, {
    String? roleFilter,
    int? minMatch,
  }) async {
    final json = await _client.get(
      '/jobs/$jobId/candidates',
      query: {
        if (roleFilter != null) 'role': roleFilter,
        if (minMatch != null) 'min_match': '$minMatch',
      },
    ) as List;
    return json
        .map((c) => CandidateModel.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> rateCandidate(String candidateId, double rating, {String? comment}) {
    return _client.post('/candidates/$candidateId/ratings', body: {
      'rating': rating,
      if (comment != null) 'comment': comment,
    });
  }

  @override
  Future<void> sendMessage(String candidateId, String message) {
    return _client.post('/candidates/$candidateId/messages', body: {
      'message': message,
    });
  }
}
