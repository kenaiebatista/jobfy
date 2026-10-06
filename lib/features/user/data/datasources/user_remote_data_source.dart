import 'package:jobfy/core/network/api_client.dart';
import 'package:jobfy/core/network/api_exception.dart';
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
}
