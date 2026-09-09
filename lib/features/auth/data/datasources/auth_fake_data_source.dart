import 'auth_data_source.dart';
import '../models/user_model.dart';

/// In-memory stand-in for [AuthRemoteDataSource], used until the Go backend
/// is deployed. Accepts any email with a 6+ character password.
class AuthFakeDataSource implements AuthDataSource {
  UserModel? _currentUser;

  @override
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.isEmpty || password.length < 6) return null;
    _currentUser = UserModel(
      id: 'usr_001',
      name: email.split('@').first,
      email: email,
      cpf: '000.000.000-00',
      gender: 'unspecified',
    );
    return _currentUser;
  }

  @override
  Future<UserModel?> register({
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
