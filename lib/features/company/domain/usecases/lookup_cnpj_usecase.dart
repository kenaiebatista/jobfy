import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class LookupCnpjUsecase {
  final CompanyRepository _repository;

  LookupCnpjUsecase(this._repository);

  Future<CnpjDataEntity> call(String cnpj) => _repository.lookupCnpj(cnpj);
}
