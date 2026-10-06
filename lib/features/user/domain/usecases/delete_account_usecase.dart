import '../repositories/user_repository.dart';

class DeleteAccountUsecase {
  final UserRepository _repository;

  DeleteAccountUsecase(this._repository);

  Future<void> call(String userId) {
    return _repository.deleteAccount(userId);
  }
}
