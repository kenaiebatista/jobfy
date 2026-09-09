import 'package:jobfy/core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl([AuthDataSource? dataSource])
      : _dataSource = dataSource ?? AuthRemoteDataSource(ApiClient());

  @override
  Future<UserEntity?> login(String email, String password) {
    return _dataSource.login(email, password);
  }

  @override
  Future<UserEntity?> register({
    required String name,
    required String email,
    required String cpf,
    required String password,
    required String gender,
  }) {
    return _dataSource.register(
      name: name,
      email: email,
      cpf: cpf,
      password: password,
      gender: gender,
    );
  }

  @override
  Future<void> logout() => _dataSource.logout();
}
