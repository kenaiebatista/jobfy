import 'package:aplicativo_jobfy/domain/entities/empresa_entity.dart';

/// Contrato (o "o quê"), sem se preocupar com o "como".
/// Cada método do diagrama UML vira uma assinatura aqui.
abstract class EmpresaRepository {
  /// + cadastrarEmpresa()
  Future<EmpresaEntity> cadastrarEmpresa(EmpresaEntity empresa);

  /// + publicarVaga()
  Future<VagaEntity> publicarVaga(VagaEntity vaga);

  /// + filtrarCandidatos()
  Future<List<CandidatoEntity>> filtrarCandidatos(
    String vagaId, {
    String? filtroCargo,
    int? matchMinimo,
  });

  /// + avaliarUsuario()
  Future<void> avaliarUsuario(String candidatoId, double nota, {String? comentario});

  /// + mandarMensagem()
  Future<void> mandarMensagem(String candidatoId, String mensagem);
}
