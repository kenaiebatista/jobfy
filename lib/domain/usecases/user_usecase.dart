import '../entities/user_profile_entity.dart';
import '../repositories/user_repository.dart';

class UserUsecase {
  final UserRepository _repository;

  UserUsecase(this._repository);

  Future<UserProfileEntity> getUserProfile(String userId) {
    return _repository.getUserProfile(userId);
  }

  Future<void> updateProfile(UserProfileEntity profile) {
    return _repository.updateProfile(profile);
  }
}
