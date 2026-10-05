import '../entities/registration_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register(RegistrationEntity data);
  Future<List<String>> getSkillNames();
  Future<void> logout();
}
