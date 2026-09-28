import '../entities/user_profile_entity.dart';

abstract class UserRepository {
  Future<UserProfileEntity> getUserProfile(String userId);
  Future<void> updateProfile(UserProfileEntity profile);
}
