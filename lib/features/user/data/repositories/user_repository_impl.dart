import 'package:jobfy/core/network/api_client.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_data_source.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/user_profile_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _dataSource;

  UserRepositoryImpl([UserDataSource? dataSource])
      : _dataSource = dataSource ?? UserRemoteDataSource(ApiClient());

  @override
  Future<UserProfileEntity> getUserProfile(String userId) {
    return _dataSource.getUserProfile(userId);
  }

  @override
  Future<void> updateProfile(UserProfileEntity profile) {
    return _dataSource.updateProfile(UserProfileModel(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      role: profile.role,
      location: profile.location,
      profileCompletion: profile.profileCompletion,
      applications: profile.applications,
      matchScore: profile.matchScore,
      profileViews: profile.profileViews,
      skills: profile.skills,
      recommendedJobs: profile.recommendedJobs,
      activities: profile.activities,
    ));
  }
}
