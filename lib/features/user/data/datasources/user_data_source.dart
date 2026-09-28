import '../models/user_profile_model.dart';

/// Where [UserRepositoryImpl] gets its data from. [UserRemoteDataSource] is
/// the real implementation (Jobfy Go backend); [UserFakeDataSource] is an
/// in-memory stand-in for local development and tests while the backend
/// isn't deployed yet.
abstract class UserDataSource {
  Future<UserProfileModel> getUserProfile(String userId);

  Future<void> updateProfile(UserProfileModel profile);
}
