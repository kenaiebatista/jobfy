import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

// Mock implementation — replace with AuthRemoteDataSource once the backend is live.
class AuthRepositoryImpl implements AuthRepository {
  static UserModel? _currentUser;

  @override
  Future<UserEntity?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel(
        id: 'usr_001',
        name: email.split('@').first,
        email: email,
        cpf: '000.000.000-00',
        gender: 'unspecified',
      );
      return _currentUser;
    }
    return null;
  }

  @override
  Future<UserEntity?> register({
    required String name,
    required String email,
    required String cpf,
    required String password,
    required String gender,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      cpf: cpf,
      gender: gender,
    );
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}
