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
  Future<List<JobEntity>> getCompanyJobs(String companyId) => _dataSource.getCompanyJobs(companyId);

  @override
  Future<JobEntity> publishJob(JobEntity job) {
    return _dataSource.publishJob(job);
  }

  @override
  Future<List<CandidateEntity>> filterCandidates(
    String jobId, {
    String? roleFilter,
    int? minMatch,
  }) {
    return _dataSource.filterCandidates(
      jobId,
      roleFilter: roleFilter,
      minMatch: minMatch,
    );
  }

  @override
  Future<void> rateCandidate(String candidateId, double rating, {String? comment}) {
    return _dataSource.rateCandidate(candidateId, rating, comment: comment);
  }

  @override
  Future<void> sendMessage(String candidateId, String message) {
    return _dataSource.sendMessage(candidateId, message);
  }
}
