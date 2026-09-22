import 'package:flutter/foundation.dart';

import '../../../user/domain/entities/user_profile_entity.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../../user/domain/usecases/get_user_profile_usecase.dart';

enum SettingsStatus { idle, loading, loaded, error }

/// Holds the settings screen state: the loaded profile plus every toggle
/// group shown on the page. Mirrors the load/notify pattern already used by
/// UserController, but also owns the (mocked) save flow for the account
/// form and preference switches.
class SettingsController extends ChangeNotifier {
  final GetUserProfileUsecase _getProfileUsecase;
  final UserRepository _repository;

  SettingsController(this._getProfileUsecase, this._repository);

  SettingsStatus _status = SettingsStatus.idle;
  UserProfileEntity? _profile;
  bool _isSavingProfile = false;

  // Notificações
  bool notifNovasVagas = true;
  bool notifMensagens = true;
  bool notifEmailSemanal = false;
  bool notifPush = true;

  // Privacidade
  bool perfilVisivelParaEmpresas = true;
  bool mostrarEmailNoPerfil = false;

  // Aparência
  bool temaEscuro = false;

  // Preferências de vaga
  final Set<String> tiposVagaPreferidos = {'Remoto'};

  SettingsStatus get status => _status;
  UserProfileEntity? get profile => _profile;
  bool get isLoading => _status == SettingsStatus.loading;
  bool get isSavingProfile => _isSavingProfile;

  Future<void> loadProfile(String userId) async {
    _status = SettingsStatus.loading;
    notifyListeners();

    try {
      _profile = await _getProfileUsecase(userId);
      _status = SettingsStatus.loaded;
    } catch (_) {
      _status = SettingsStatus.error;
    }
    notifyListeners();
  }

  void setNotifNovasVagas(bool value) {
    notifNovasVagas = value;
    notifyListeners();
  }

  void setNotifMensagens(bool value) {
    notifMensagens = value;
    notifyListeners();
  }

  void setNotifEmailSemanal(bool value) {
    notifEmailSemanal = value;
    notifyListeners();
  }

  void setNotifPush(bool value) {
    notifPush = value;
    notifyListeners();
  }

  void setPerfilVisivelParaEmpresas(bool value) {
    perfilVisivelParaEmpresas = value;
    notifyListeners();
  }

  void setMostrarEmailNoPerfil(bool value) {
    mostrarEmailNoPerfil = value;
    notifyListeners();
  }

  void setTemaEscuro(bool value) {
    temaEscuro = value;
    notifyListeners();
  }

  void toggleTipoVaga(String tipo) {
    if (tiposVagaPreferidos.contains(tipo)) {
      tiposVagaPreferidos.remove(tipo);
    } else {
      tiposVagaPreferidos.add(tipo);
    }
    notifyListeners();
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
}
