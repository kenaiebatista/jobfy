import 'package:jobfy/core/config/app_config.dart';
import 'package:jobfy/core/network/api_client.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_data_source.dart';
import '../datasources/user_fake_data_source.dart';
import '../datasources/user_mysql_data_source.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/user_profile_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _dataSource;

  UserRepositoryImpl([UserDataSource? dataSource])
      : _dataSource = dataSource ??
            (AppConfig.useMysql
                ? UserMysqlDataSource()
                : AppConfig.useFakeBackend
                    ? UserFakeDataSource()
                    : UserRemoteDataSource(ApiClient()));

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
      cpf: profile.cpf,
      gender: profile.gender,
      phone: profile.phone,
      birthDate: profile.birthDate,
      educationLevel: profile.educationLevel,
      experiences: profile.experiences,
    ));
  }

  @override
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) {
    return _dataSource.changePassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> deleteAccount(String userId) {
    return _dataSource.deleteAccount(userId);
  }

  @override
  Future<void> addSkill(String userId, String name, SkillLevel level) =>
      _dataSource.addSkill(userId, name, level);

  @override
  Future<void> removeSkill(String userId, String name) => _dataSource.removeSkill(userId, name);

  @override
  Future<void> addExperience(String userId, ExperienceEntity experience) =>
      _dataSource.addExperience(userId, experience);

  @override
  Future<void> deleteExperience(String userId, String experienceId) =>
      _dataSource.deleteExperience(userId, experienceId);
}
