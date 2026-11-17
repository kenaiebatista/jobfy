import '../../domain/entities/company_entity.dart';

/// Where [CompanyRepositoryImpl] gets its data from.
/// [CompanyMysqlDataSource] reads/writes the MySQL database directly;
/// [CompanyRemoteDataSource] is the future Go backend; [CompanyFakeDataSource]
/// is an in-memory stand-in for tests.
abstract class CompanyDataSource {
  Future<CompanyEntity> registerCompany(CompanyEntity company, String password);

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
