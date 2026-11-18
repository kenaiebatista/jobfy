import 'package:flutter/foundation.dart' show debugPrint;
import 'package:jobfy/core/database/database_service.dart';
import 'package:jobfy/core/network/api_exception.dart';
import 'package:mysql_client/exception.dart';
import '../../domain/entities/company_entity.dart';
import '../models/candidate_model.dart';
import '../models/company_model.dart';
import '../models/job_model.dart';
import 'company_data_source.dart';

/// Company data straight from the Jobfy MySQL database through
/// [DatabaseService]. Stand-in until the Go backend
/// ([CompanyRemoteDataSource]) is deployed.
///
class CompanyMysqlDataSource implements CompanyDataSource {
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
  Future<void> updateCompany(CompanyEntity company) async {
    String? opt(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    final zip = company.zipCode?.replaceAll(RegExp(r'\D'), '');
    try {
      await DatabaseService.updateCompanyAccount(
        companyId: int.parse(company.companyId),
        email: company.email.trim(),
        tradeName: opt(company.tradeName),
        phone: opt(company.phone),
        businessArea: opt(company.businessArea),
        zipCode: opt(zip),
        address: opt(company.address),
        city: opt(company.city),
        state: opt(company.state)?.toUpperCase(),
        description: opt(company.description),
      );
    } on EmailAlreadyInUseException {
      throw const ApiStatusException(409, 'email');
    }
  }

  @override
  Future<bool> changePassword(String companyId, String currentPassword, String newPassword) {
    return DatabaseService.changeCompanyPassword(
      companyId: int.parse(companyId),
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> deleteAccount(String companyId) {
    return DatabaseService.deactivateCompanyAccount(int.parse(companyId));
  }

  @override
  Future<List<JobEntity>> getCompanyJobs(String companyId) async {
    final rows = await DatabaseService.getCompanyJobs(int.parse(companyId));
    return [
      for (final r in rows)
        // The row has the same snake_case names as the backend JSON.
        JobModel.fromJson({...r, 'company_id': companyId}),
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
  Future<void> updateJob(String jobId, NewJobEntity job) {
    String? opt(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    return DatabaseService.updateJob(
      jobId: int.parse(jobId),
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
  Future<void> setJobStatus(String companyId, String jobId, JobStatus status) {
    return DatabaseService.setJobStatus(
      jobId: int.parse(jobId),
      companyId: int.parse(companyId),
      status: status.name,
    );
  }

  @override
  Future<void> setCandidateStatus(
    String companyId,
    String jobId,
    String userId,
    ApplicationStatus status,
  ) {
    return DatabaseService.setApplicationStatus(
      jobId: int.parse(jobId),
      userId: int.parse(userId),
      companyId: int.parse(companyId),
      status: status.dbValue,
    );
  }

  @override
  Future<List<CandidateEntity>> getJobCandidates(String jobId) async {
    final rows = await DatabaseService.getJobCandidates(int.parse(jobId));
    return [for (final r in rows) CandidateModel.fromJson(r)];
  }
}
