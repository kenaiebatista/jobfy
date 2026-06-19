import '../entities/user_profile_entity.dart';
import '../repositories/user_repository.dart';

class GetUserProfileUsecase {
  final UserRepository _repository;

  GetUserProfileUsecase(this._repository);

  Future<UserProfileEntity> call(String userId) {
    return _repository.getUserProfile(userId);
  }
}
