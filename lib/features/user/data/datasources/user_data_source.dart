import '../../domain/entities/user_profile_entity.dart';
import '../models/user_profile_model.dart';

/// Where [UserRepositoryImpl] gets its data from. [UserRemoteDataSource] is
/// the real implementation (Jobfy Go backend); [UserFakeDataSource] is an
/// in-memory stand-in for local development and tests while the backend
/// isn't deployed yet.
abstract class UserDataSource {
  Future<UserProfileModel> getUserProfile(String userId);

  Future<void> updateProfile(UserProfileModel profile);

  /// Returns false when [currentPassword] is wrong.
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  /// Closes the account; the user can no longer sign in.
  Future<void> deleteAccount(String userId);

  Future<void> addSkill(String userId, String name, SkillLevel level);

  Future<void> removeSkill(String userId, String name);

  Future<void> addExperience(String userId, ExperienceEntity experience);

  Future<void> deleteExperience(String userId, String experienceId);

}
