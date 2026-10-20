import '../entities/company_entity.dart';

abstract class CompanyRepository {
  /// Creates the company account and profile; returns it with its id.
  Future<CompanyEntity> registerCompany(CompanyEntity company, String password);

  /// Company data (Receita Federal) for the sign-up form.
  Future<CnpjDataEntity> lookupCnpj(String cnpj);

  Future<CompanyEntity> getCompany(String companyId);

  Future<List<JobEntity>> getCompanyJobs(String companyId);

  Future<JobEntity> publishJob(JobEntity job);

  Future<List<CandidateEntity>> filterCandidates(
    String jobId, {
    String? roleFilter,
    int? minMatch,
  });

  Future<void> rateCandidate(String candidateId, double rating, {String? comment});

  Future<void> sendMessage(String candidateId, String message);
}
