import 'package:aplicativo_jobfy/features/company/domain/entities/empresa_entity.dart';
import 'package:aplicativo_jobfy/features/company/domain/repositories/empresa_repository.dart';

class CadastrarEmpresaUsecase {
  final EmpresaRepository _repository;

  CadastrarEmpresaUsecase(this._repository);

  Future<EmpresaEntity> call(EmpresaEntity empresa) {
    return _repository.cadastrarEmpresa(empresa);
  }
}
