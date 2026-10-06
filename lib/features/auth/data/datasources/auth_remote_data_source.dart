import 'package:jobfy/core/network/api_client.dart';
import '../../domain/entities/registration_entity.dart';
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
  Future<UserModel?> register(RegistrationEntity data) async {
    final json = await _client.post('/auth/register', body: {
      'name': data.name,
      'email': data.email,
      'cpf': data.cpf,
      'password': data.password,
      'gender': data.gender.name,
      'phone': data.phone,
      'birth_date': data.birthDate?.toIso8601String().substring(0, 10),
      'education_level': data.educationLevel?.dbValue,
      'skills': [
        for (final s in data.skills) {'name': s.name, 'level': s.level.name},
      ],
      'experiences': [
        for (final e in data.experiences)
          {
            'job_title': e.jobTitle,
            'company_name': e.companyName,
            'description': e.description,
            'start_date': e.startDate.toIso8601String().substring(0, 10),
            'end_date': e.endDate?.toIso8601String().substring(0, 10),
          },
      ],
    }) as Map<String, dynamic>?;
    if (json == null) return null;

    final token = json['token'] as String?;
    if (token != null) _client.setAuthToken(token);

    return UserModel.fromJson(json['user'] as Map<String, dynamic>);
  }

  /// Expected contract: GET /skills -> ["Flutter", "SQL", ...]
  @override
  Future<List<String>> getSkillNames() async {
    final json = await _client.get('/skills') as List;
    return json.cast<String>();
  }

  @override
  Future<void> logout() async {
    await _client.post('/auth/logout');
    _client.setAuthToken(null);
  }
}
