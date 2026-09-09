import 'package:jobfy/core/network/api_client.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_data_source.dart';
import '../datasources/company_remote_data_source.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyDataSource _dataSource;

  CompanyRepositoryImpl([CompanyDataSource? dataSource])
      : _dataSource = dataSource ?? CompanyRemoteDataSource(ApiClient());

  @override
  Future<CompanyEntity> registerCompany(CompanyEntity company) {
    return _dataSource.registerCompany(company);
  }

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
