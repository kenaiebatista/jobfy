import 'package:flutter/foundation.dart' show debugPrint;
import 'package:jobfy/core/database/database_service.dart';
import 'package:jobfy/core/network/api_exception.dart';
import 'package:mysql_client/exception.dart';
import '../../domain/entities/registration_entity.dart';
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
    // Only user accounts for now: company/institution accounts have no
    // `users` row (user_id is null) and no screens of their own yet.
    final userId = row?['user_id'];
    if (row == null || userId == null) return null;

    return UserModel(
      id: userId,
      name: row['name'] ?? email,
      email: row['email'] ?? email,
      cpf: row['cpf'] ?? '',
      gender: row['gender'] ?? '',
    );
  }

  @override
  Future<UserModel?> register(RegistrationEntity data) async {
    try {
      await DatabaseService.registerUser(
        name: data.name,
        email: data.email,
        password: data.password,
        cpf: data.cpf,
        gender: data.gender.name,
        phone: data.phone,
        birthDate: _date(data.birthDate),
        educationLevel: data.educationLevel?.dbValue,
        skills: [
          for (final s in data.skills) (name: s.name, level: s.level.name),
        ],
        experiences: [
          for (final e in data.experiences)
            (
              jobTitle: e.jobTitle,
              companyName: e.companyName,
              description: e.description,
              startDate: _date(e.startDate)!,
              endDate: _date(e.endDate),
            ),
        ],
      );
    } on EmailAlreadyInUseException {
      throw const ApiStatusException(409, 'email');
    } on CpfAlreadyInUseException {
      throw const ApiStatusException(409, 'cpf');
    } on MySQLServerException catch (e) {
      // The server answered but refused the data (e.g. a missing column).
      debugPrint('MySQL error (host ${DatabaseService.host}): $e');
      throw ApiStatusException(500, e.message);
    } catch (e) {
      debugPrint('MySQL error (host ${DatabaseService.host}): $e');
      throw ApiUnreachableException(e.toString());
    }
    return login(data.email, data.password);
  }

  @override
  Future<List<String>> getSkillNames() async {
    try {
      return await DatabaseService.getSkillNames();
    } catch (e) {
      debugPrint('MySQL error (host ${DatabaseService.host}): $e');
      throw ApiUnreachableException(e.toString());
    }
  }

  @override
  Future<void> logout() async {}

  /// 'YYYY-MM-DD', the format MySQL expects for DATE columns.
  static String? _date(DateTime? d) => d?.toIso8601String().substring(0, 10);
}
