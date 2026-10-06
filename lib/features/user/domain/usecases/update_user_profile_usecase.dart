import '../entities/user_profile_entity.dart';
import '../repositories/user_repository.dart';

class UpdateUserProfileUsecase {
  final UserRepository _repository;

  UpdateUserProfileUsecase(this._repository);

  Future<void> call(UserProfileEntity profile) {
    return _repository.updateProfile(profile);
  }
}
