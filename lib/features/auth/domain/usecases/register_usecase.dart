import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _repository;

  RegisterUsecase(this._repository);

  Future<UserEntity?> call({
    required String name,
    required String email,
    required String cpf,
    required String password,
    required String gender,
  }) {
    return _repository.register(
      name: name,
      email: email,
      cpf: cpf,
      password: password,
      gender: gender,
    );
  }
}
