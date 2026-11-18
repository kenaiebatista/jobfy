import '../entities/user_profile_entity.dart';

abstract class UserRepository {
  Future<UserProfileEntity> getUserProfile(String userId);
  Future<void> updateProfile(UserProfileEntity profile);

  /// Returns false when [currentPassword] is wrong.
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount(String userId);

  Future<void> addSkill(String userId, String name, SkillLevel level);

  Future<void> removeSkill(String userId, String name);

  Future<void> addExperience(String userId, ExperienceEntity experience);

  Future<void> deleteExperience(String userId, String experienceId);

}
