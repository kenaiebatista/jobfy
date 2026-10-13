import '../repositories/user_repository.dart';

class ChangePasswordUsecase {
  final UserRepository _repository;

  ChangePasswordUsecase(this._repository);

  /// Returns false when [currentPassword] is wrong.
  Future<bool> call({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
