import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class RegisterCompanyUsecase {
  final CompanyRepository _repository;

  RegisterCompanyUsecase(this._repository);

  Future<CompanyEntity> call(CompanyEntity company) {
    return _repository.registerCompany(company);
  }
}
