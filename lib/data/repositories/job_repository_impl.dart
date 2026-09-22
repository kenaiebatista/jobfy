import '../../domain/entities/job_entity.dart';
import '../models/job_model.dart';
import '../../domain/repositories/job_repository.dart';

// Mock implementation — a integração com o backend está comentada dentro de
// cada método.
//
// O app NÃO conecta direto no MySQL: ele chama uma API (Node, Spring, PHP...)
// que é quem acessa o banco. Para ativar: adicionar o pacote `http` ao pubspec,
// apontar [_baseUrl] para a API e descomentar os blocos abaixo.
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
class JobRepositoryImpl implements JobRepository {
  // static const _baseUrl = 'http://10.0.2.2:3000'; // localhost visto do emulador Android

  @override
  Future<List<JobEntity>> getJobs() async {
    // --- Backend --- GET /vagas  (SELECT ... FROM vagas WHERE ativa = 1
    //                              ORDER BY publicada_em DESC)
    // final response = await http.get(
    //   Uri.parse('$_baseUrl/vagas'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // if (response.statusCode != 200) {
    //   throw Exception('Erro ao buscar vagas (${response.statusCode})');
    // }
    // final lista = jsonDecode(response.body) as List<dynamic>;
    // return lista
    //     .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
    //     .toList();

    await Future.delayed(const Duration(milliseconds: 600));
    return _mockJobs();
  }

  @override
  Future<void> candidatar(String jobId) async {
    // --- Backend --- POST /vagas/{id}/candidaturas
    // O usuário vem do token (JWT); a API faz o INSERT em `candidaturas`
    // (id_vaga, id_usuario, criada_em) e responde 409 se já existir.
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/vagas/$jobId/candidaturas'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // if (response.statusCode != 201) {
    //   throw Exception('Erro ao candidatar (${response.statusCode})');
    // }

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> salvarVaga(String jobId) async {
    // --- Backend --- POST /usuarios/{uid}/vagas-salvas
    //                 (INSERT em `vagas_salvas`: id_vaga, id_usuario)
    // final response = await http.post(
    //   Uri.parse('$_baseUrl/usuarios/$_userId/vagas-salvas'),
    //   headers: {'Authorization': 'Bearer $token'},
    //   body: jsonEncode({'id_vaga': jobId}),
    // );
    // if (response.statusCode != 201) {
    //   throw Exception('Erro ao salvar vaga (${response.statusCode})');
    // }

    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> removerVagaSalva(String jobId) async {
    // --- Backend --- DELETE /usuarios/{uid}/vagas-salvas/{id_vaga}
    //                 (DELETE FROM `vagas_salvas` WHERE id_vaga = ? AND id_usuario = ?)
    // final response = await http.delete(
    //   Uri.parse('$_baseUrl/usuarios/$_userId/vagas-salvas/$jobId'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // if (response.statusCode != 204) {
    //   throw Exception('Erro ao remover vaga salva (${response.statusCode})');
    // }

    await Future.delayed(const Duration(milliseconds: 300));
  }

  List<JobEntity> _mockJobs() {
    final agora = DateTime.now();
    return [
      JobModel(
        id: 'job_001',
        titulo: 'Flutter Developer Senior',
        empresa: 'Nubank',
        local: 'São Paulo, SP',
        tipo: 'Remoto',
        nivel: 'Sênior',
        salario: 'R\$ 12.000 – 18.000',
        descricao:
            'Buscamos uma pessoa desenvolvedora Flutter para atuar no time de '
            'cartões, construindo experiências mobile que atendem milhões de '
            'clientes. Você terá autonomia técnica e participará das decisões '
            'de arquitetura do app.',
        requisitos: [
          '5+ anos de experiência com desenvolvimento mobile',
          'Domínio de Flutter e Dart',
          'Experiência com testes automatizados',
          'Conhecimento de Clean Architecture',
        ],
        matchPercent: 97,
        publicadaEm: agora.subtract(const Duration(hours: 3)),
      ),
      JobModel(
        id: 'job_002',
        titulo: 'Mobile Engineer',
        empresa: 'iFood',
        local: 'Campinas, SP',
        tipo: 'Híbrido',
        nivel: 'Pleno',
        salario: 'R\$ 10.000 – 15.000',
        descricao:
            'Você fará parte do time responsável pela jornada de pedidos, '
            'evoluindo o app e garantindo performance e qualidade em escala.',
        requisitos: [
          '3+ anos com desenvolvimento mobile',
          'Experiência com Flutter ou React Native',
          'Familiaridade com APIs REST',
        ],
        matchPercent: 91,
        publicadaEm: agora.subtract(const Duration(hours: 20)),
      ),
      JobModel(
        id: 'job_003',
        titulo: 'Dart/Flutter Developer',
        empresa: 'PicPay',
        local: 'Remoto',
        tipo: 'Remoto',
        nivel: 'Pleno',
        salario: 'R\$ 9.000 – 14.000',
        descricao:
            'Atue no desenvolvimento de novas funcionalidades de pagamentos, '
            'trabalhando de perto com design e produto.',
        requisitos: [
          '2+ anos com Flutter',
          'Experiência com gerenciamento de estado',
          'Git e code review',
        ],
        matchPercent: 85,
        publicadaEm: agora.subtract(const Duration(days: 2)),
      ),
      JobModel(
        id: 'job_004',
        titulo: 'Desenvolvedor Mobile Júnior',
        empresa: 'WEG',
        local: 'Jaraguá do Sul, SC',
        tipo: 'Presencial',
        nivel: 'Júnior',
        salario: 'R\$ 4.500 – 6.500',
        descricao:
            'Oportunidade para iniciar a carreira em desenvolvimento mobile, '
            'com mentoria de profissionais experientes e plano de carreira.',
        requisitos: [
          'Conhecimento básico de Dart ou Kotlin',
          'Lógica de programação',
          'Vontade de aprender',
        ],
        matchPercent: 78,
        publicadaEm: agora.subtract(const Duration(days: 3)),
      ),
      JobModel(
        id: 'job_005',
        titulo: 'UI/UX Designer',
        empresa: 'Stone',
        local: 'Rio de Janeiro, RJ',
        tipo: 'Híbrido',
        nivel: 'Pleno',
        salario: 'R\$ 8.000 – 12.000',
        descricao:
            'Desenhe interfaces para os produtos de meios de pagamento, '
            'conduzindo pesquisas com usuários e validando protótipos.',
        requisitos: [
          'Portfólio com projetos mobile',
          'Domínio de Figma',
          'Experiência com design systems',
        ],
        matchPercent: 64,
        publicadaEm: agora.subtract(const Duration(days: 5)),
      ),
      JobModel(
        id: 'job_006',
        titulo: 'Backend Developer (Node.js)',
        empresa: 'Mercado Livre',
        local: 'Blumenau, SC',
        tipo: 'Presencial',
        nivel: 'Sênior',
        salario: 'R\$ 13.000 – 19.000',
        descricao:
            'Projete e evolua APIs de alta disponibilidade que sustentam o '
            'marketplace, com foco em observabilidade e escalabilidade.',
        requisitos: [
          '5+ anos com Node.js e TypeScript',
          'Experiência com mensageria e bancos NoSQL',
          'Boas práticas de observabilidade',
        ],
        matchPercent: 58,
        publicadaEm: agora.subtract(const Duration(days: 7)),
      ),
      JobModel(
        id: 'job_007',
        titulo: 'Analista de QA Mobile',
        empresa: 'Totvs',
        local: 'Joinville, SC',
        tipo: 'Remoto',
        nivel: 'Júnior',
        salario: 'R\$ 5.000 – 7.500',
        descricao:
            'Garanta a qualidade dos apps da empresa criando e mantendo '
            'testes automatizados e roteiros de testes manuais.',
        requisitos: [
          'Noções de testes automatizados',
          'Conhecimento de Android ou iOS',
          'Atenção a detalhes',
        ],
        matchPercent: 72,
        publicadaEm: agora.subtract(const Duration(days: 12)),
      ),
      JobModel(
        id: 'job_008',
        titulo: 'Tech Lead Mobile',
        empresa: 'Creditas',
        local: 'São Paulo, SP',
        tipo: 'Híbrido',
        nivel: 'Sênior',
        salario: 'R\$ 18.000 – 25.000',
        descricao:
            'Lidere um time de desenvolvimento mobile, definindo a visão '
            'técnica e apoiando o crescimento das pessoas do time.',
        requisitos: [
          '7+ anos de experiência, sendo 2+ em liderança',
          'Experiência sólida com Flutter',
          'Capacidade de comunicação com áreas de negócio',
        ],
        matchPercent: 83,
        publicadaEm: agora.subtract(const Duration(days: 40)),
      ),
    ];
  }
}
