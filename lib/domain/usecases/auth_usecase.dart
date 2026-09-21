import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class AuthUsecase {
  final AuthRepository _repository;

  AuthUsecase(this._repository);

  Future<UserEntity?> login(String email, String senha) {
    return _repository.login(email, senha);
  }

  Future<UserEntity?> register({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
    required String genero,
  }) {
    return _repository.register(
      nome: nome,
      email: email,
      cpf: cpf,
      senha: senha,
      genero: genero,
    );
  }

  Future<void> logout() {
    return _repository.logout();
  }
}
