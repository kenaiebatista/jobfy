import '../entities/company_entity.dart';

abstract class CompanyRepository {
  /// Creates the company account and profile; returns it with its id.
  Future<CompanyEntity> registerCompany(CompanyEntity company, String password);

  /// Company data (Receita Federal) for the sign-up form.
  Future<CnpjDataEntity> lookupCnpj(String cnpj);

  Future<CompanyEntity> getCompany(String companyId);

  Future<void> updateCompany(CompanyEntity company);

  /// Returns false when [currentPassword] is wrong.
  Future<bool> changePassword(String companyId, String currentPassword, String newPassword);

  /// Closes the account; the company can no longer sign in and its jobs close.
  Future<void> deleteAccount(String companyId);

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
}
