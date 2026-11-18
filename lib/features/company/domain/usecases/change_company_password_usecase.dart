import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class ChangeCompanyPasswordUsecase {
  final CompanyRepository _repository;

  ChangeCompanyPasswordUsecase(this._repository);

  Future<bool> call(String companyId, String currentPassword, String newPassword) => _repository.changePassword(companyId, currentPassword, newPassword);
}
