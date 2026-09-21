import 'package:flutter/foundation.dart';
import 'package:aplicativo_jobfy/domain/entities/user_entity.dart';
import 'package:aplicativo_jobfy/domain/usecases/auth_usecase.dart';

enum AuthStatus { idle, loading, success, error }

class AuthController extends ChangeNotifier {
  final AuthUsecase _authUsecase;

  AuthController(this._authUsecase);

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

    final user = await _authUsecase.login(email, senha);
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

    final user = await _authUsecase.register(
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
