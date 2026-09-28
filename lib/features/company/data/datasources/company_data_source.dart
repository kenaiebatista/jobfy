import '../../domain/entities/company_entity.dart';

/// Where [CompanyRepositoryImpl] gets its data from.
/// [CompanyRemoteDataSource] is the real implementation (Jobfy Go backend);
/// [CompanyFakeDataSource] is an in-memory stand-in for local development
/// and tests while the backend isn't deployed yet.
abstract class CompanyDataSource {
  Future<CompanyEntity> registerCompany(CompanyEntity company);

  Future<JobEntity> publishJob(JobEntity job);

  Future<List<CandidateEntity>> filterCandidates(
    String jobId, {
    String? roleFilter,
    int? minMatch,
  });

  Future<void> rateCandidate(String candidateId, double rating, {String? comment});

  Future<void> sendMessage(String candidateId, String message);
}
