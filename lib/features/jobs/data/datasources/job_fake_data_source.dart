import 'job_data_source.dart';
import '../models/job_listing_model.dart';

/// In-memory stand-in for [JobRemoteDataSource], used until the Go backend
/// is deployed.
class JobFakeDataSource implements JobDataSource {
  static const _jobs = [
    JobListingModel(
      id: 'job_001',
      title: 'Flutter Developer Senior',
      company: 'Nubank',
      location: 'São Paulo, SP',
      type: 'Remoto',
      salary: 'R\$ 12.000 – 18.000',
      description:
          'Buscamos um(a) desenvolvedor(a) Flutter senior para liderar a evolução do nosso app mobile, com foco em performance e arquitetura escalável.',
      matchPercent: 97,
    ),
    JobListingModel(
      id: 'job_002',
      title: 'Mobile Engineer',
      company: 'iFood',
      location: 'Campinas, SP',
      type: 'Híbrido',
      salary: 'R\$ 10.000 – 15.000',
      description:
          'Time de mobile do iFood busca engenheiro(a) para trabalhar com Flutter e Kotlin em produtos de alta escala.',
      matchPercent: 91,
    ),
    JobListingModel(
      id: 'job_003',
      title: 'Dart/Flutter Developer',
      company: 'PicPay',
      location: 'Remoto',
      type: 'Remoto',
      salary: 'R\$ 9.000 – 14.000',
      description:
          'Vaga remota para desenvolvedor(a) Dart/Flutter atuar no time de carteira digital, integrando com APIs de pagamento.',
      matchPercent: 85,
    ),
    JobListingModel(
      id: 'job_004',
      title: 'Frontend Engineer (Flutter Web)',
      company: 'Mercado Livre',
      location: 'Remoto',
      type: 'Remoto',
      salary: 'R\$ 8.000 – 12.000',
      description:
          'Time de plataformas internas busca profissional para construir ferramentas web em Flutter.',
      matchPercent: 78,
    ),
  ];

  @override
  Future<List<JobListingModel>> searchJobs({String? query, String? location}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _jobs.where((j) {
      final matchesQuery = query == null ||
          query.isEmpty ||
          j.title.toLowerCase().contains(query.toLowerCase()) ||
          j.company.toLowerCase().contains(query.toLowerCase());
      final matchesLocation = location == null ||
          location.isEmpty ||
          j.location.toLowerCase().contains(location.toLowerCase());
      return matchesQuery && matchesLocation;
    }).toList();
  }

  @override
  Future<void> applyToJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
