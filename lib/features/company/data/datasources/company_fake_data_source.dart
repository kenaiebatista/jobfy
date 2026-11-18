import '../../domain/entities/company_entity.dart';
import 'company_data_source.dart';
import '../models/company_model.dart';
import '../models/job_model.dart';

/// In-memory stand-in for [CompanyRemoteDataSource], used until the Go
/// backend is deployed.
class CompanyFakeDataSource implements CompanyDataSource {
  final List<CandidateEntity> _candidatesMock = [
    CandidateEntity(
      id: 'usr_001',
      name: 'Caue Bueno',
      email: 'caue.bueno@email.com',
      phone: '(47) 99999-0001',
      appliedAt: DateTime(2026, 10, 20),
    ),
    CandidateEntity(
      id: 'usr_002',
      name: 'Marina Alves',
      email: 'marina.alves@email.com',
      appliedAt: DateTime(2026, 10, 18),
    ),
  ];

  CompanyEntity? _company;
  final List<JobEntity> _jobs = [];

  @override
  Future<CompanyEntity> registerCompany(CompanyEntity company, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _company = CompanyModel(
      companyId: 'cmp_001',
      companyName: company.companyName,
      cnpj: company.cnpj,
      email: company.email,
      phone: company.phone,
      tradeName: company.tradeName,
      businessArea: company.businessArea,
      zipCode: company.zipCode,
      address: company.address,
      city: company.city,
      state: company.state,
      description: company.description,
    );
  }

  @override
  Future<CompanyEntity> getCompany(String companyId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _company ??
        CompanyModel(
          companyId: companyId,
          companyName: 'Empresa Exemplo LTDA',
          tradeName: 'Empresa Exemplo',
          cnpj: '00000000000000',
          email: 'contato@empresa.com',
          phone: '(47) 3333-0000',
          city: 'Gaspar',
          state: 'SC',
        );
  }

  static String _password = 'jobfy123';

  @override
  Future<void> updateCompany(CompanyEntity company) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _company = CompanyModel(
      companyId: company.companyId,
      companyName: company.companyName,
      cnpj: company.cnpj,
      email: company.email,
      phone: company.phone,
      tradeName: company.tradeName,
      businessArea: company.businessArea,
      zipCode: company.zipCode,
      address: company.address,
      city: company.city,
      state: company.state,
      description: company.description,
    );
  }

  @override
  Future<bool> changePassword(String companyId, String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (currentPassword != _password) return false;
    _password = newPassword;
    return true;
  }

  @override
  Future<void> deleteAccount(String companyId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _company = null;
  }

  @override
  Future<List<JobEntity>> getCompanyJobs(String companyId) async => List.of(_jobs);

  @override
  Future<void> publishJob(NewJobEntity job) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _jobs.insert(
      0,
      JobModel(
        id: 'job_${_jobs.length + 1}',
        companyId: job.companyId,
        title: job.title,
        description: job.description,
        location: job.location,
        contractType: job.contractType.name,
        salary: 'R\$ ${job.salaryMin} – ${job.salaryMax}',
        workMode: job.workMode.dbValue,
        status: 'open',
        area: job.area,
        salaryMin: job.salaryMin,
        salaryMax: job.salaryMax,
        workload: job.workload,
        requirements: job.requirements,
        benefits: job.benefits,
      ),
    );
  }

  @override
  Future<void> updateJob(String jobId, NewJobEntity job) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i < 0) return;
    _jobs[i] = _copyJob(_jobs[i], job: job);
  }

  @override
  Future<void> setJobStatus(String companyId, String jobId, JobStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final i = _jobs.indexWhere((j) => j.id == jobId);
    if (i < 0) return;
    _jobs[i] = _copyJob(_jobs[i], status: status.name);
  }

  @override
  Future<void> setCandidateStatus(
    String companyId,
    String jobId,
    String userId,
    ApplicationStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final i = _candidatesMock.indexWhere((c) => c.id == userId);
    if (i >= 0) _candidatesMock[i] = _candidatesMock[i].copyWith(status: status.dbValue);
  }

  /// [old] with the edited fields and/or a new status.
  JobEntity _copyJob(JobEntity old, {NewJobEntity? job, String? status}) {
    return JobModel(
      id: old.id,
      companyId: old.companyId,
      title: job?.title ?? old.title,
      description: job?.description ?? old.description,
      location: job?.location ?? old.location,
      contractType: job?.contractType.name ?? old.contractType,
      salary: job == null ? old.salary : 'R\$ ${job.salaryMin} – ${job.salaryMax}',
      workMode: job?.workMode.dbValue ?? old.workMode,
      status: status ?? old.status,
      candidateCount: old.candidateCount,
      area: job == null ? old.area : job.area,
      salaryMin: job?.salaryMin ?? old.salaryMin,
      salaryMax: job?.salaryMax ?? old.salaryMax,
      workload: job == null ? old.workload : job.workload,
      requirements: job == null ? old.requirements : job.requirements,
      benefits: job == null ? old.benefits : job.benefits,
    );
  }

  @override
  Future<List<CandidateEntity>> getJobCandidates(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.of(_candidatesMock);
  }
}
