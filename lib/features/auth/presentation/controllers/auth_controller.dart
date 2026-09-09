import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { idle, loading, success, error }

/// Machine-readable error codes. The presentation layer maps these to
/// localized copy — see [AppLocalizations].
enum AuthErrorCode { invalidCredentials, registrationFailed }

class AuthController extends ChangeNotifier {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;

  AuthController(this._loginUsecase, this._registerUsecase);

  AuthStatus _status = AuthStatus.idle;
  UserEntity? _user;
  AuthErrorCode? _errorCode;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  AuthErrorCode? get errorCode => _errorCode;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorCode = null;
    notifyListeners();

    final user = await _loginUsecase(email, password);
    if (user != null) {
      _user = user;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    }

    _errorCode = AuthErrorCode.invalidCredentials;
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String cpf,
    required String password,
    required String gender,
  }) async {
    _status = AuthStatus.loading;
    _errorCode = null;
    notifyListeners();

    final user = await _registerUsecase(
      name: name,
      email: email,
      cpf: cpf,
      password: password,
      gender: gender,
    );

    if (user != null) {
      _user = user;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    }

    _errorCode = AuthErrorCode.registrationFailed;
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  void logout() {
    _user = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void resetStatus() {
    _status = AuthStatus.idle;
    _errorCode = null;
    notifyListeners();
  }
}
