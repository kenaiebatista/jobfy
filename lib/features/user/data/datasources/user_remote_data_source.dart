import 'package:jobfy/core/network/api_client.dart';
import 'user_data_source.dart';
import '../models/user_profile_model.dart';

/// Talks to the Jobfy backend's user-profile endpoints.
///
/// Expected contract (Go backend, JSON, snake_case fields):
///   GET /users/{id}/profile -> UserProfileModel.fromJson
///   PUT /users/{id}/profile <- UserProfileModel.toJson
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
}
