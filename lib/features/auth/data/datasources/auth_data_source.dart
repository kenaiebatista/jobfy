import '../models/user_model.dart';

/// Where [AuthRepositoryImpl] gets its data from. [AuthRemoteDataSource] is
/// the real implementation (Jobfy Go backend); [AuthFakeDataSource] is an
/// in-memory stand-in for local development and tests while the backend
/// isn't deployed yet.
abstract class AuthDataSource {
  Future<UserModel?> login(String email, String password);

  Future<UserModel?> register({
    required String name,
    required String email,
    required String cpf,
    required String password,
    required String gender,
  });

  Future<void> logout();
}
