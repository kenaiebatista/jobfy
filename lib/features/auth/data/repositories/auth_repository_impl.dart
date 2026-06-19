import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

// Mock implementation — substitua por integração real com Firebase/API
class AuthRepositoryImpl implements AuthRepository {
  static UserModel? _currentUser;

  @override
  Future<UserEntity?> login(String email, String senha) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.isNotEmpty && senha.length >= 6) {
      _currentUser = UserModel(
        id: 'usr_001',
        nome: email.split('@').first,
        email: email,
        cpf: '000.000.000-00',
        genero: 'Não informado',
      );
      return _currentUser;
    }
    return null;
  }

  @override
  Future<UserEntity?> register({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
    required String genero,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      nome: nome,
      email: email,
      cpf: cpf,
      genero: genero,
    );
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}
