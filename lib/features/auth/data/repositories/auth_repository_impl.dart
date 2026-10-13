import 'package:jobfy/core/config/app_config.dart';
import 'package:jobfy/core/network/api_client.dart';
import '../../domain/entities/registration_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../datasources/auth_fake_data_source.dart';
import '../datasources/auth_mysql_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl([AuthDataSource? dataSource])
      : _dataSource = dataSource ??
            (AppConfig.useMysql
                ? AuthMysqlDataSource()
                : AppConfig.useFakeBackend
                    ? AuthFakeDataSource()
                    : AuthRemoteDataSource(ApiClient()));

  @override
  Future<UserEntity?> login(String email, String password) {
    return _dataSource.login(email, password);
  }

  @override
  Future<UserEntity?> register(RegistrationEntity data) {
    return _dataSource.register(data);
  }

  @override
  Future<List<String>> getSkillNames() => _dataSource.getSkillNames();

  @override
  Future<void> logout() => _dataSource.logout();
}
