import 'package:flutter/foundation.dart';

import '../../../user/domain/entities/user_profile_entity.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../../user/domain/usecases/get_user_profile_usecase.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/usecases/get_user_preferences_usecase.dart';
import '../../domain/usecases/save_user_preferences_usecase.dart';

enum SettingsStatus { idle, loading, loaded, error }

/// Holds the settings screen state: the loaded profile plus every toggle
/// group shown on the page. Each toggle is saved on the device as soon as it
/// changes. Theme and language live in the app-wide AppSettingsController,
/// because they affect every screen, not only this one.
class SettingsController extends ChangeNotifier {
  final GetUserProfileUsecase _getProfileUsecase;
  final UserRepository _repository;
  final GetUserPreferencesUsecase _getPreferencesUsecase;
  final SaveUserPreferencesUsecase _savePreferencesUsecase;

  SettingsController(
    this._getProfileUsecase,
    this._repository,
    this._getPreferencesUsecase,
    this._savePreferencesUsecase,
  );

  SettingsStatus _status = SettingsStatus.idle;
  UserProfileEntity? _profile;
  UserPreferencesEntity _preferences = const UserPreferencesEntity();
  bool _isSavingProfile = false;
  bool _isChangingPassword = false;

  SettingsStatus get status => _status;
  UserProfileEntity? get profile => _profile;
  UserPreferencesEntity get preferences => _preferences;
  bool get isLoading => _status == SettingsStatus.loading;
  bool get isSavingProfile => _isSavingProfile;
  bool get isChangingPassword => _isChangingPassword;

  Future<void> loadProfile(String userId) async {
    _status = SettingsStatus.loading;
    notifyListeners();

    try {
      _profile = await _getProfileUsecase(userId);
      _preferences = await _getPreferencesUsecase();
      _status = SettingsStatus.loaded;
    } catch (_) {
      _status = SettingsStatus.error;
    }
    notifyListeners();
  }

  Future<void> _updatePreferences(UserPreferencesEntity novas) async {
    _preferences = novas;
    notifyListeners();
    await _savePreferencesUsecase(novas);
  }

  void setNotifNovasVagas(bool value) =>
      _updatePreferences(_preferences.copyWith(notifNovasVagas: value));

  void setNotifMensagens(bool value) =>
      _updatePreferences(_preferences.copyWith(notifMensagens: value));

  void setNotifEmailSemanal(bool value) =>
      _updatePreferences(_preferences.copyWith(notifEmailSemanal: value));

  void setNotifPush(bool value) =>
      _updatePreferences(_preferences.copyWith(notifPush: value));

  void setPerfilVisivelParaEmpresas(bool value) => _updatePreferences(
        _preferences.copyWith(perfilVisivelParaEmpresas: value),
      );

  void setMostrarEmailNoPerfil(bool value) =>
      _updatePreferences(_preferences.copyWith(mostrarEmailNoPerfil: value));

  void toggleTipoVaga(TipoVaga tipo) {
    final tipos = Set<TipoVaga>.of(_preferences.tiposVaga);
    if (!tipos.remove(tipo)) tipos.add(tipo);
    _updatePreferences(_preferences.copyWith(tiposVaga: tipos));
  }

  Future<void> salvarPerfil({
    required String nome,
    required String email,
    required String localizacao,
  }) async {
    final current = _profile;
    if (current == null) return;

    _isSavingProfile = true;
    notifyListeners();

    final atualizado = UserProfileEntity(
      id: current.id,
      nome: nome,
      email: email,
      cargo: current.cargo,
      localizacao: localizacao,
      perfilCompleto: current.perfilCompleto,
      candidaturas: current.candidaturas,
      matchScore: current.matchScore,
      visualizacoes: current.visualizacoes,
      habilidades: current.habilidades,
      vagasRecomendadas: current.vagasRecomendadas,
      atividades: current.atividades,
    );

    await _repository.updateProfile(atualizado);

    _profile = atualizado;
    _isSavingProfile = false;
    notifyListeners();
  }

  Future<void> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    _isChangingPassword = true;
    notifyListeners();

    await _repository.changePassword(
      senhaAtual: senhaAtual,
      novaSenha: novaSenha,
    );

    _isChangingPassword = false;
    notifyListeners();
  }
}
