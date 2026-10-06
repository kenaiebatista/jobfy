import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/settings_repository.dart';

/// Keeps the settings toggles on the device (shared_preferences), so they
/// survive navigating away from the page and restarting the app.
class SettingsRepositoryImpl implements SettingsRepository {
  static const _notifNovasVagas = 'settings.notif_novas_vagas';
  static const _notifMensagens = 'settings.notif_mensagens';
  static const _notifEmailSemanal = 'settings.notif_email_semanal';
  static const _notifPush = 'settings.notif_push';
  static const _perfilVisivel = 'settings.perfil_visivel';
  static const _mostrarEmail = 'settings.mostrar_email';
  static const _tiposVaga = 'settings.tipos_vaga';

  @override
  Future<UserPreferencesEntity> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = UserPreferencesEntity();

    final tipos = prefs.getStringList(_tiposVaga);

    return UserPreferencesEntity(
      notifNovasVagas: prefs.getBool(_notifNovasVagas) ?? defaults.notifNovasVagas,
      notifMensagens: prefs.getBool(_notifMensagens) ?? defaults.notifMensagens,
      notifEmailSemanal:
          prefs.getBool(_notifEmailSemanal) ?? defaults.notifEmailSemanal,
      notifPush: prefs.getBool(_notifPush) ?? defaults.notifPush,
      perfilVisivelParaEmpresas:
          prefs.getBool(_perfilVisivel) ?? defaults.perfilVisivelParaEmpresas,
      mostrarEmailNoPerfil:
          prefs.getBool(_mostrarEmail) ?? defaults.mostrarEmailNoPerfil,
      tiposVaga: tipos == null
          ? defaults.tiposVaga
          : TipoVaga.values.where((t) => tipos.contains(t.name)).toSet(),
    );
  }

  @override
  Future<void> savePreferences(UserPreferencesEntity p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifNovasVagas, p.notifNovasVagas);
    await prefs.setBool(_notifMensagens, p.notifMensagens);
    await prefs.setBool(_notifEmailSemanal, p.notifEmailSemanal);
    await prefs.setBool(_notifPush, p.notifPush);
    await prefs.setBool(_perfilVisivel, p.perfilVisivelParaEmpresas);
    await prefs.setBool(_mostrarEmail, p.mostrarEmailNoPerfil);
    await prefs.setStringList(
      _tiposVaga,
      p.tiposVaga.map((t) => t.name).toList(),
    );
  }
}
