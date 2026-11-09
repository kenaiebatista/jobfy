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
      ),
    );
  }

  @override
  Future<List<CandidateEntity>> getJobCandidates(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.of(_candidatesMock);
  }

  @override
  Future<void> rateCandidate(String candidateId, double rating, {String? comment}) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> sendMessage(String candidateId, String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
