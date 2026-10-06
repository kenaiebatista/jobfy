import 'package:flutter/foundation.dart';
import 'package:jobfy/core/network/api_exception.dart';
import '../../domain/entities/registration_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { idle, loading, success, error }

/// Machine-readable error codes. The presentation layer maps these to
/// localized copy — see [AppLocalizations].
enum AuthErrorCode {
  invalidCredentials,
  registrationFailed,
  emailInUse,
  cpfInUse,
  network,
}

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

    try {
      final user = await _loginUsecase(email, password);
      if (user != null) {
        _user = user;
        _status = AuthStatus.success;
        notifyListeners();
        return true;
      }
      _errorCode = AuthErrorCode.invalidCredentials;
    } on ApiException {
      _errorCode = AuthErrorCode.network;
    }

    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  Future<bool> register(RegistrationEntity data) async {
    _status = AuthStatus.loading;
    _errorCode = null;
    notifyListeners();

    try {
      final user = await _registerUsecase(data);
      if (user != null) {
        _user = user;
        _status = AuthStatus.success;
        notifyListeners();
        return true;
      }
      _errorCode = AuthErrorCode.registrationFailed;
    } on ApiStatusException catch (e) {
      // 409 = duplicate; the message says which unique field ('email'/'cpf').
      _errorCode = e.statusCode != 409
          ? AuthErrorCode.registrationFailed
          : e.message == 'cpf'
              ? AuthErrorCode.cpfInUse
              : AuthErrorCode.emailInUse;
    } on ApiException {
      _errorCode = AuthErrorCode.network;
    }

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
