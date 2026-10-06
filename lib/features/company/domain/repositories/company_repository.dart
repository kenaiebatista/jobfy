import '../entities/company_entity.dart';

abstract class CompanyRepository {
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
