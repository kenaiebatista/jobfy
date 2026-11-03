import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/features/auth/domain/entities/registration_entity.dart';
import 'package:jobfy/features/auth/domain/entities/user_entity.dart';
import 'package:jobfy/features/auth/domain/repositories/auth_repository.dart';
import 'package:jobfy/features/auth/domain/usecases/login_usecase.dart';
import 'package:jobfy/features/auth/domain/usecases/register_usecase.dart';
import 'package:jobfy/features/auth/presentation/controllers/auth_controller.dart';

class _FakeAuthRepository implements AuthRepository {
  final String accountType;

  _FakeAuthRepository(this.accountType);

  @override
  Future<UserEntity?> login(String email, String password) async => UserEntity(
        id: '1',
        name: 'Conta',
        email: email,
        cpf: '',
        gender: '',
        accountType: accountType,
      );

  @override
  Future<UserEntity?> register(RegistrationEntity data) async => null;

  @override
  Future<List<String>> getSkillNames() async => [];

  @override
  Future<void> logout() async {}
}

AuthController _controller(String accountType) {
  final repo = _FakeAuthRepository(accountType);
  return AuthController(LoginUsecase(repo), RegisterUsecase(repo));
}

void main() {
  test('a company logs in with the company option', () async {
    final controller = _controller('company');

    expect(await controller.login('a@b.c', '123456', asCompany: true), isTrue);
    expect(controller.user!.isCompany, isTrue);
  });

  test('a candidate logs in with the candidate option', () async {
    final controller = _controller('user');

    expect(await controller.login('a@b.c', '123456', asCompany: false), isTrue);
  });

  test('a company account is refused on the candidate option', () async {
    final controller = _controller('company');

    expect(await controller.login('a@b.c', '123456', asCompany: false), isFalse);
    expect(controller.errorCode, AuthErrorCode.notCandidateAccount);
    expect(controller.user, isNull);
  });

  test('a candidate account is refused on the company option', () async {
    final controller = _controller('user');

    expect(await controller.login('a@b.c', '123456', asCompany: true), isFalse);
    expect(controller.errorCode, AuthErrorCode.notCompanyAccount);
    expect(controller.user, isNull);
  });
}
