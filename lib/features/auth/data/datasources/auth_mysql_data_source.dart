import 'package:flutter/foundation.dart' show debugPrint;
import 'package:jobfy/core/database/database_service.dart';
import 'package:jobfy/core/network/api_exception.dart';
import 'auth_data_source.dart';
import '../models/user_model.dart';

/// Talks straight to the Jobfy MySQL database through [DatabaseService].
/// Stand-in until the Go backend ([AuthRemoteDataSource]) is deployed.
class AuthMysqlDataSource implements AuthDataSource {
  @override
  Future<UserModel?> login(String email, String password) async {
    final Map<String, String?>? row;
    try {
      row = await DatabaseService.login(email, password);
    } catch (e) {
      debugPrint('MySQL error (host ${DatabaseService.host}): $e');
      throw ApiUnreachableException(e.toString());
    }
    if (row == null) return null;

    return UserModel(
      id: row['user_id'] ?? row['account_id'] ?? '',
      name: row['name'] ?? row['email'] ?? email,
      email: row['email'] ?? email,
      cpf: row['cpf'] ?? '',
      gender: row['gender'] ?? '',
    );
  }

  @override
  Future<UserModel?> register({
    required String name,
    required String email,
    required String cpf,
    required String password,
    required String gender,
  }) async {
    try {
      await DatabaseService.registerUser(name, email, password);
    } on EmailAlreadyInUseException {
      throw const ApiStatusException(409, 'Email already registered.');
    } catch (e) {
      debugPrint('MySQL error (host ${DatabaseService.host}): $e');
      throw ApiUnreachableException(e.toString());
    }
    return login(email, password);
  }

  @override
  Future<void> logout() async {}
}
