import '../../domain/entities/company_entity.dart';
import 'company_data_source.dart';
import '../models/company_model.dart';

/// In-memory stand-in for [CompanyRemoteDataSource], used until the Go
/// backend is deployed.
class CompanyFakeDataSource implements CompanyDataSource {
  final List<CandidateEntity> _candidatesMock = const [
    CandidateEntity(
      id: 'cand_001',
      name: 'Caue Bueno',
      desiredRole: 'Flutter Developer',
      matchPercent: 97,
    ),
    CandidateEntity(
      id: 'cand_002',
      name: 'Marina Alves',
      desiredRole: 'Mobile Engineer',
      matchPercent: 88,
    ),
    CandidateEntity(
      id: 'cand_003',
      name: 'Rafael Souza',
      desiredRole: 'Dart/Flutter Developer',
      matchPercent: 74,
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
  Future<JobEntity> publishJob(JobEntity job) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _jobs.add(job);
    return job;
  }

  @override
  Future<List<CandidateEntity>> filterCandidates(
    String jobId, {
    String? roleFilter,
    int? minMatch,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _candidatesMock.where((c) {
      final matchesRole = roleFilter == null ||
          c.desiredRole.toLowerCase().contains(roleFilter.toLowerCase());
      final matchesScore = minMatch == null || c.matchPercent >= minMatch;
      return matchesRole && matchesScore;
    }).toList();
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
