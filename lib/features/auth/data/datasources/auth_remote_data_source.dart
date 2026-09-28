import 'package:jobfy/core/network/api_client.dart';
import 'auth_data_source.dart';
import '../models/user_model.dart';

/// Talks to the Jobfy backend's auth endpoints.
///
/// Expected contract (Go backend, JSON):
///   POST /auth/login    {email, password}                    -> {user, token}
///   POST /auth/register {name, email, cpf, password, gender}  -> {user, token}
///   POST /auth/logout    (Bearer token)                       -> 204
class AuthRemoteDataSource implements AuthDataSource {
  final ApiClient _client;

  AuthRemoteDataSource(this._client);

  @override
  Future<UserModel?> login(String email, String password) async {
    final json = await _client.post('/auth/login', body: {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>?;
    if (json == null) return null;

    final token = json['token'] as String?;
    if (token != null) _client.setAuthToken(token);

    return UserModel.fromJson(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel?> register({
    required String name,
    required String email,
    required String cpf,
    required String password,
    required String gender,
  }) async {
    final json = await _client.post('/auth/register', body: {
      'name': name,
      'email': email,
      'cpf': cpf,
      'password': password,
      'gender': gender,
    }) as Map<String, dynamic>?;
    if (json == null) return null;

    final token = json['token'] as String?;
    if (token != null) _client.setAuthToken(token);

    return UserModel.fromJson(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _client.post('/auth/logout');
    _client.setAuthToken(null);
  }
}
