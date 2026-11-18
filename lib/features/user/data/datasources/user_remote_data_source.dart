import 'package:jobfy/core/network/api_client.dart';
import 'package:jobfy/core/network/api_exception.dart';
import '../../domain/entities/user_profile_entity.dart';
import 'user_data_source.dart';
import '../models/user_profile_model.dart';

/// Talks to the Jobfy backend's user-profile endpoints.
///
/// Expected contract (Go backend, JSON, snake_case fields):
///   GET /users/{id}/profile -> UserProfileModel.fromJson
///   PUT /users/{id}/profile <- UserProfileModel.toJson
///   PUT /users/{id}/password <- {current_password, new_password}
///       (403 when the current password is wrong)
///   DELETE /users/{id}
///   POST /users/{id}/skills {name, level}; DELETE /users/{id}/skills/{name}
///   POST /users/{id}/experiences {job_title, company_name, description,
///        start_date, end_date}; DELETE /users/{id}/experiences/{experienceId}
class UserRemoteDataSource implements UserDataSource {
  final ApiClient _client;

  UserRemoteDataSource(this._client);

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    final json = await _client.get('/users/$userId/profile') as Map<String, dynamic>;
    return UserProfileModel.fromJson(json);
  }

  @override
  Future<void> updateProfile(UserProfileModel profile) async {
    await _client.put('/users/${profile.id}/profile', body: profile.toJson());
  }

  @override
  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _client.put('/users/$userId/password', body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      return true;
    } on ApiStatusException catch (e) {
      if (e.statusCode == 403) return false;
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await _client.delete('/users/$userId');
  }

  @override
  Future<void> addSkill(String userId, String name, SkillLevel level) async {
    await _client.post('/users/$userId/skills', body: {'name': name, 'level': level.name});
  }

  @override
  Future<void> removeSkill(String userId, String name) async {
    await _client.delete('/users/$userId/skills/${Uri.encodeComponent(name)}');
  }

  @override
  Future<void> addExperience(String userId, ExperienceEntity experience) async {
    String day(DateTime d) => d.toIso8601String().substring(0, 10);
    await _client.post('/users/$userId/experiences', body: {
      'job_title': experience.jobTitle,
      'company_name': experience.companyName,
      'description': experience.description,
      'start_date': day(experience.startDate),
      'end_date': experience.endDate == null ? null : day(experience.endDate!),
    });
  }

  @override
  Future<void> deleteExperience(String userId, String experienceId) async {
    await _client.delete('/users/$userId/experiences/$experienceId');
  }
}
