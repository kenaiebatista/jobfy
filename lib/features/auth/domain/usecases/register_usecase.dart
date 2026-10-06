import '../entities/registration_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _repository;

  RegisterUsecase(this._repository);

  Future<UserEntity?> call(RegistrationEntity data) {
    return _repository.register(data);
  }
}
