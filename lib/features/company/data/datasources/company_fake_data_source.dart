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

  @override
  Future<CompanyEntity> registerCompany(CompanyEntity company) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return CompanyModel(
      companyId: company.companyId,
      companyName: company.companyName,
      cnpj: company.cnpj,
      email: company.email,
      phone: company.phone,
    );
  }

  @override
  Future<JobEntity> publishJob(JobEntity job) async {
    await Future.delayed(const Duration(milliseconds: 500));
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
