import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register({
    required String name,
    required String email,
    required String cpf,
    required String password,
    required String gender,
  });
  Future<void> logout();
}
