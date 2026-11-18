import 'package:jobfy/core/config/app_config.dart';
import 'package:jobfy/core/network/api_client.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/brasil_api_cnpj_data_source.dart';
import '../datasources/company_data_source.dart';
import '../datasources/company_fake_data_source.dart';
import '../datasources/company_mysql_data_source.dart';
import '../datasources/company_remote_data_source.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyDataSource _dataSource;
  final BrasilApiCnpjDataSource _cnpj;

  CompanyRepositoryImpl([CompanyDataSource? dataSource, BrasilApiCnpjDataSource? cnpj])
      : _dataSource = dataSource ??
            (AppConfig.useMysql
                ? CompanyMysqlDataSource()
                : AppConfig.useFakeBackend
                    ? CompanyFakeDataSource()
                    : CompanyRemoteDataSource(ApiClient())),
        _cnpj = cnpj ?? BrasilApiCnpjDataSource();

  @override
  Future<CompanyEntity> registerCompany(CompanyEntity company, String password) {
    return _dataSource.registerCompany(company, password);
  }

  @override
  Future<CnpjDataEntity> lookupCnpj(String cnpj) => _cnpj.lookup(cnpj);

  @override
  Future<CompanyEntity> getCompany(String companyId) => _dataSource.getCompany(companyId);

  @override
  Future<void> updateCompany(CompanyEntity company) => _dataSource.updateCompany(company);

  @override
  Future<bool> changePassword(String companyId, String currentPassword, String newPassword) {
    return _dataSource.changePassword(companyId, currentPassword, newPassword);
  }

  @override
  Future<void> deleteAccount(String companyId) => _dataSource.deleteAccount(companyId);

  @override
  Future<List<JobEntity>> getCompanyJobs(String companyId) => _dataSource.getCompanyJobs(companyId);

  @override
  Future<void> publishJob(NewJobEntity job) {
    return _dataSource.publishJob(job);
  }

  @override
  Future<void> updateJob(String jobId, NewJobEntity job) => _dataSource.updateJob(jobId, job);

  @override
  Future<void> setJobStatus(String companyId, String jobId, JobStatus status) {
    return _dataSource.setJobStatus(companyId, jobId, status);
  }

  @override
  Future<void> setCandidateStatus(
    String companyId,
    String jobId,
    String userId,
    ApplicationStatus status,
  ) {
    return _dataSource.setCandidateStatus(companyId, jobId, userId, status);
  }

  @override
  Future<List<CandidateEntity>> getJobCandidates(String jobId) {
    return _dataSource.getJobCandidates(jobId);
  }
}
