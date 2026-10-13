import '../../domain/entities/registration_entity.dart';
import '../models/user_model.dart';

/// Where [AuthRepositoryImpl] gets its data from. [AuthRemoteDataSource] is
/// the real implementation (Jobfy Go backend); [AuthFakeDataSource] is an
/// in-memory stand-in for local development and tests while the backend
/// isn't deployed yet.
abstract class AuthDataSource {
  Future<UserModel?> login(String email, String password);

  Future<UserModel?> register(RegistrationEntity data);

  /// Names in the skills catalog, offered as choices in the sign-up form.
  Future<List<String>> getSkillNames();

  Future<void> logout();
}
