import 'package:aplicativo_jobfy/features/company/domain/entities/empresa_entity.dart';
import 'package:aplicativo_jobfy/features/company/domain/repositories/empresa_repository.dart';
import 'package:aplicativo_jobfy/features/company/data/models/empresa_model.dart';

class EmpresaRepositoryImpl implements EmpresaRepository {
  // "banco" em memória só para simular persistência, como no exemplo de user
  final List<CandidatoEntity> _candidatosMock = const [
    CandidatoEntity(
      id: 'cand_001',
      nome: 'Caue Bueno',
      cargoDesejado: 'Desenvolvedor Flutter',
      matchPercent: 97,
    ),
    CandidatoEntity(
      id: 'cand_002',
      nome: 'Marina Alves',
      cargoDesejado: 'Mobile Engineer',
      matchPercent: 88,
    ),
    CandidatoEntity(
      id: 'cand_003',
      nome: 'Rafael Souza',
      cargoDesejado: 'Dart/Flutter Developer',
      matchPercent: 74,
    ),
  ];

  @override
  Future<EmpresaEntity> cadastrarEmpresa(EmpresaEntity empresa) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Aqui entraria a chamada real (API/Firebase) para persistir a empresa.
    return EmpresaModel(
      idEmpresa: empresa.idEmpresa,
      nomeEmpresa: empresa.nomeEmpresa,
      cnpj: empresa.cnpj,
      email: empresa.email,
      telefone: empresa.telefone,
    );
  }

  @override
  Future<VagaEntity> publicarVaga(VagaEntity vaga) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return vaga;
  }

  @override
  Future<List<CandidatoEntity>> filtrarCandidatos(
    String vagaId, {
    String? filtroCargo,
    int? matchMinimo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _candidatosMock.where((c) {
      final passaCargo = filtroCargo == null ||
          c.cargoDesejado.toLowerCase().contains(filtroCargo.toLowerCase());
      final passaMatch = matchMinimo == null || c.matchPercent >= matchMinimo;
      return passaCargo && passaMatch;
    }).toList();
  }

  @override
  Future<void> avaliarUsuario(String candidatoId, double nota, {String? comentario}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Aqui salvaria a nota/comentário no backend.
  }

  @override
  Future<void> mandarMensagem(String candidatoId, String mensagem) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Aqui enviaria a mensagem via API/chat service.
  }
}
