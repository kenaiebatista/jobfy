import '../entities/company_entity.dart';

abstract class CompanyRepository {
  /// Creates the company account and profile; returns it with its id.
  Future<CompanyEntity> registerCompany(CompanyEntity company, String password);

  /// Company data (Receita Federal) for the sign-up form.
  Future<CnpjDataEntity> lookupCnpj(String cnpj);

  Future<CompanyEntity> getCompany(String companyId);

  Future<List<JobEntity>> getCompanyJobs(String companyId);

  Future<void> publishJob(NewJobEntity job);

  Future<void> updateJob(String jobId, NewJobEntity job);

  Future<void> setJobStatus(String companyId, String jobId, JobStatus status);

  /// The company's answer to [userId]'s application to [jobId].
  Future<void> setCandidateStatus(
    String companyId,
    String jobId,
    String userId,
    ApplicationStatus status,
  );

  /// Who applied to the job.
  Future<List<CandidateEntity>> getJobCandidates(String jobId);

  Future<void> rateCandidate(String candidateId, double rating, {String? comment});
}
