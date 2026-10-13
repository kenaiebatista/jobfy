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
}
