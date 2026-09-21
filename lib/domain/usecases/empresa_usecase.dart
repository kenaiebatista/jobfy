import 'package:aplicativo_jobfy/domain/entities/empresa_entity.dart';
import 'package:aplicativo_jobfy/domain/repositories/empresa_repository.dart';

class EmpresaUsecase {
  final EmpresaRepository _repository;

  EmpresaUsecase(this._repository);

  Future<EmpresaEntity> cadastrarEmpresa(EmpresaEntity empresa) {
    return _repository.cadastrarEmpresa(empresa);
  }

  Future<VagaEntity> publicarVaga(VagaEntity vaga) {
    return _repository.publicarVaga(vaga);
  }

  Future<List<CandidatoEntity>> filtrarCandidatos(
    String vagaId, {
    String? filtroCargo,
    int? matchMinimo,
  }) {
    return _repository.filtrarCandidatos(
      vagaId,
      filtroCargo: filtroCargo,
      matchMinimo: matchMinimo,
    );
  }

  Future<void> avaliarUsuario(
    String candidatoId,
    double nota, {
    String? comentario,
  }) {
    return _repository.avaliarUsuario(candidatoId, nota, comentario: comentario);
  }

  Future<void> mandarMensagem(String candidatoId, String mensagem) {
    return _repository.mandarMensagem(candidatoId, mensagem);
  }
}
