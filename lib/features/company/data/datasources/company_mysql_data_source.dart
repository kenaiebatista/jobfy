import 'package:flutter/foundation.dart' show debugPrint;
import 'package:jobfy/core/database/database_service.dart';
import 'package:jobfy/core/network/api_exception.dart';
import 'package:mysql_client/exception.dart';
import '../../domain/entities/company_entity.dart';
import '../models/candidate_model.dart';
import '../models/company_model.dart';
import '../models/job_model.dart';
import 'company_data_source.dart';
import 'company_fake_data_source.dart';

/// Company data straight from the Jobfy MySQL database through
/// [DatabaseService]. Stand-in until the Go backend
/// ([CompanyRemoteDataSource]) is deployed.
///
/// Rating and messaging candidates still use [CompanyFakeDataSource].
class CompanyMysqlDataSource implements CompanyDataSource {
  final CompanyFakeDataSource _notYetInDatabase = CompanyFakeDataSource();

  @override
  Future<CompanyEntity> registerCompany(CompanyEntity company, String password) async {
    String? opt(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    final int companyId;
    try {
      companyId = await DatabaseService.registerCompany(
        email: company.email,
        password: password,
        cnpj: company.cnpj,
        companyName: company.companyName,
        tradeName: opt(company.tradeName),
        phone: opt(company.phone),
        businessArea: opt(company.businessArea),
        zipCode: opt(company.zipCode),
        address: opt(company.address),
        city: opt(company.city),
        state: opt(company.state)?.toUpperCase(),
        description: opt(company.description),
      );
    } on EmailAlreadyInUseException {
      throw const ApiStatusException(409, 'email');
    } on CnpjAlreadyInUseException {
      throw const ApiStatusException(409, 'cnpj');
    } on MySQLServerException catch (e) {
      // The server answered but refused the data (e.g. a missing column).
      debugPrint('MySQL error (host ${DatabaseService.host}): $e');
      throw ApiStatusException(500, e.message);
    } catch (e) {
      debugPrint('MySQL error (host ${DatabaseService.host}): $e');
      throw ApiUnreachableException(e.toString());
    }
    return getCompany('$companyId');
  }

  @override
  Future<CompanyEntity> getCompany(String companyId) async {
    final row = await DatabaseService.getCompany(int.parse(companyId));
    if (row == null) throw StateError('Company $companyId not found');
    return CompanyModel(
      companyId: row['company_id'] ?? companyId,
      companyName: row['company_name'] ?? '',
      cnpj: row['cnpj'] ?? '',
      email: row['email'] ?? '',
      phone: row['phone'] ?? '',
      tradeName: row['trade_name'],
      businessArea: row['business_area'],
      zipCode: row['zip_code'],
      address: row['address'],
      city: row['city'],
      state: row['state'],
      description: row['description'],
    );
  }

  @override
  Future<List<JobEntity>> getCompanyJobs(String companyId) async {
    final rows = await DatabaseService.getCompanyJobs(int.parse(companyId));
    return [
      for (final r in rows)
        JobModel(
          id: r['id'] ?? '',
          companyId: companyId,
          title: r['title'] ?? '',
          description: r['description'] ?? '',
          location: r['location'] ?? '',
          contractType: r['contract_type'] ?? '',
          salary: r['salary'] ?? '',
          workMode: r['work_mode'],
          status: r['status'],
          candidateCount: int.tryParse(r['candidates'] ?? '') ?? 0,
        ),
    ];
  }

  @override
  Future<void> publishJob(NewJobEntity job) {
    String? opt(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    return DatabaseService.insertJob(
      companyId: int.parse(job.companyId),
      title: job.title,
      area: opt(job.area),
      location: job.location,
      workMode: job.workMode.dbValue,
      description: job.description,
      contractType: job.contractType.name,
      salaryMin: job.salaryMin,
      salaryMax: job.salaryMax,
      workload: opt(job.workload),
      requirements: opt(job.requirements),
      benefits: opt(job.benefits),
    );
  }

  @override
  Future<List<CandidateEntity>> getJobCandidates(String jobId) async {
    final rows = await DatabaseService.getJobCandidates(int.parse(jobId));
    return [for (final r in rows) CandidateModel.fromJson(r)];
  }

  @override
  Future<void> rateCandidate(String candidateId, double rating, {String? comment}) =>
      _notYetInDatabase.rateCandidate(candidateId, rating, comment: comment);

  @override
  Future<void> sendMessage(String candidateId, String message) =>
      _notYetInDatabase.sendMessage(candidateId, message);
}
