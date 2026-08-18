import 'package:aplicativo_jobfy/features/company/domain/repositories/empresa_repository.dart';

class AvaliarUsuarioUsecase {
  final EmpresaRepository _repository;

  AvaliarUsuarioUsecase(this._repository);

  Future<void> call(String candidatoId, double nota, {String? comentario}) {
    return _repository.avaliarUsuario(candidatoId, nota, comentario: comentario);
  }
}
