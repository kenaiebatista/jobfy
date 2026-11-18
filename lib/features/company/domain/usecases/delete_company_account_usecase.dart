import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class DeleteCompanyAccountUsecase {
  final CompanyRepository _repository;

  DeleteCompanyAccountUsecase(this._repository);

  Future<void> call(String companyId) => _repository.deleteAccount(companyId);
}
