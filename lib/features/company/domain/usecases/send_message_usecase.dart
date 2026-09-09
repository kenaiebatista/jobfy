import 'package:aplicativo_jobfy/features/company/domain/repositories/empresa_repository.dart';

class MandarMensagemUsecase {
  final EmpresaRepository _repository;

  MandarMensagemUsecase(this._repository);

  Future<void> call(String candidatoId, String mensagem) {
    return _repository.mandarMensagem(candidatoId, mensagem);
  }
}
