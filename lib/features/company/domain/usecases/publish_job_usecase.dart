import 'package:aplicativo_jobfy/features/company/domain/entities/empresa_entity.dart';
import 'package:aplicativo_jobfy/features/company/domain/repositories/empresa_repository.dart';

class PublicarVagaUsecase {
  final EmpresaRepository _repository;

  PublicarVagaUsecase(this._repository);

  Future<VagaEntity> call(VagaEntity vaga) {
    return _repository.publicarVaga(vaga);
  }
}
