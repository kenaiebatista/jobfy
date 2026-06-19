import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String senha);
  Future<UserEntity?> register({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
    required String genero,
  });
  Future<void> logout();
}
