import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class GetCompanyUsecase {
  final CompanyRepository _repository;

  GetCompanyUsecase(this._repository);

  Future<CompanyEntity> call(String companyId) => _repository.getCompany(companyId);
}
