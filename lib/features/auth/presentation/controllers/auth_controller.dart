import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { idle, loading, success, error }

class AuthController extends ChangeNotifier {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;

  AuthController(this._loginUsecase, this._registerUsecase);

  AuthStatus _status = AuthStatus.idle;
  UserEntity? _user;
  String _errorMessage = '';

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> login(String email, String senha) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final user = await _loginUsecase(email, senha);
    if (user != null) {
      _user = user;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    }

    _errorMessage = 'Email ou senha inválidos.';
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
    required String genero,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final user = await _registerUsecase(
      nome: nome,
      email: email,
      cpf: cpf,
      senha: senha,
      genero: genero,
    );

    if (user != null) {
      _user = user;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    }

    _errorMessage = 'Erro ao criar conta. Tente novamente.';
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
    _errorMessage = '';
    notifyListeners();
  }
}
