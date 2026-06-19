import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _repository;

  RegisterUsecase(this._repository);

  Future<UserEntity?> call({
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
}
