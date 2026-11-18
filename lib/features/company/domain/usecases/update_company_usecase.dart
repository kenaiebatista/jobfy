import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class UpdateCompanyUsecase {
  final CompanyRepository _repository;

  UpdateCompanyUsecase(this._repository);

  Future<void> call(CompanyEntity company) => _repository.updateCompany(company);
}
