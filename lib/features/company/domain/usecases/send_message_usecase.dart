import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class SendMessageUsecase {
  final CompanyRepository _repository;

  SendMessageUsecase(this._repository);

  Future<void> call(String candidateId, String message) {
    return _repository.sendMessage(candidateId, message);
  }
}
