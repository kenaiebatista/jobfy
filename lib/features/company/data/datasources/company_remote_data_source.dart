import 'package:jobfy/core/network/api_client.dart';
import 'package:jobfy/core/network/api_exception.dart';
import '../../domain/entities/company_entity.dart';
import 'company_data_source.dart';
import '../models/candidate_model.dart';
import '../models/company_model.dart';
import '../models/job_model.dart';

/// Talks to the Jobfy backend's company endpoints.
///
/// Expected contract (Go backend, JSON, snake_case fields):
///   POST /companies   {..., password}                  -> CompanyModel
///   GET  /companies/{companyId}                        -> CompanyModel
///   PUT  /companies/{companyId}                        {same fields as the sign-up body}
///   PUT  /companies/{companyId}/password               {current_password, new_password}
///                                                      (403 when the current one is wrong)
///   DELETE /companies/{companyId}
///   GET  /companies/{companyId}/jobs                   -> `List<JobModel>`
///   POST /companies/{companyId}/jobs                   -> JobModel
///   PUT  /companies/{companyId}/jobs/{jobId}           {same body as POST}
///   PUT  /companies/{companyId}/jobs/{jobId}/status    {status: open|paused|closed}
///   PUT  /companies/{companyId}/jobs/{jobId}/candidates/{userId} {status: under_review|approved|rejected}
///   GET  /jobs/{jobId}/candidates                      -> `List<CandidateModel>`
class CompanyRemoteDataSource implements CompanyDataSource {
  final ApiClient _client;

  CompanyRemoteDataSource(this._client);

  @override
  Future<CompanyEntity> registerCompany(CompanyEntity company, String password) async {
    final body = CompanyModel(
      companyId: '',
      companyName: company.companyName,
      cnpj: company.cnpj,
      email: company.email,
      phone: company.phone,
      tradeName: company.tradeName,
      businessArea: company.businessArea,
      zipCode: company.zipCode,
      address: company.address,
      city: company.city,
      state: company.state,
      description: company.description,
    ).toJson()
      ..remove('company_id')
      ..['password'] = password;
    final json = await _client.post('/companies', body: body) as Map<String, dynamic>;
    return CompanyModel.fromJson(json);
  }

  @override
  Future<CompanyEntity> getCompany(String companyId) async {
    final json = await _client.get('/companies/$companyId') as Map<String, dynamic>;
    return CompanyModel.fromJson(json);
  }

  @override
  Future<void> updateCompany(CompanyEntity company) async {
    final body = CompanyModel(
      companyId: company.companyId,
      companyName: company.companyName,
      cnpj: company.cnpj,
      email: company.email,
      phone: company.phone,
      tradeName: company.tradeName,
      businessArea: company.businessArea,
      zipCode: company.zipCode,
      address: company.address,
      city: company.city,
      state: company.state,
      description: company.description,
    ).toJson();
    await _client.put('/companies/${company.companyId}', body: body);
  }

  @override
  Future<bool> changePassword(String companyId, String currentPassword, String newPassword) async {
    try {
      await _client.put('/companies/$companyId/password', body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      return true;
    } on ApiStatusException catch (e) {
      if (e.statusCode == 403) return false;
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String companyId) async {
    await _client.delete('/companies/$companyId');
  }

  @override
  Future<List<JobEntity>> getCompanyJobs(String companyId) async {
    final json = await _client.get('/companies/$companyId/jobs') as List;
    return json.map((j) => JobModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> publishJob(NewJobEntity job) {
    return _client.post(
      '/companies/${job.companyId}/jobs',
      body: {
        'title': job.title,
        'area': job.area,
        'description': job.description,
        'location': job.location,
        'work_mode': job.workMode.dbValue,
        'contract_type': job.contractType.name,
        'salary_min': job.salaryMin,
        'salary_max': job.salaryMax,
        'workload': job.workload,
        'requirements': job.requirements,
        'benefits': job.benefits,
      },
    );
  }

  @override
  Future<void> updateJob(String jobId, NewJobEntity job) {
    return _client.put(
      '/companies/${job.companyId}/jobs/$jobId',
      body: {
        'title': job.title,
        'area': job.area,
        'description': job.description,
        'location': job.location,
        'work_mode': job.workMode.dbValue,
        'contract_type': job.contractType.name,
        'salary_min': job.salaryMin,
        'salary_max': job.salaryMax,
        'workload': job.workload,
        'requirements': job.requirements,
        'benefits': job.benefits,
      },
    );
  }

  @override
  Future<void> setJobStatus(String companyId, String jobId, JobStatus status) {
    return _client.put(
      '/companies/$companyId/jobs/$jobId/status',
      body: {'status': status.name},
    );
  }

  @override
  Future<void> setCandidateStatus(
    String companyId,
    String jobId,
    String userId,
    ApplicationStatus status,
  ) {
    return _client.put(
      '/companies/$companyId/jobs/$jobId/candidates/$userId',
      body: {'status': status.dbValue},
    );
  }

  @override
  Future<List<CandidateEntity>> getJobCandidates(String jobId) async {
    final json = await _client.get('/jobs/$jobId/candidates') as List;
    return json
        .map((c) => CandidateModel.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}
