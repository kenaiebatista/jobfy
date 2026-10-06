/// Work arrangements the user can pick in "Preferências de vaga".
enum TipoVaga { remoto, hibrido, presencial }

class UserPreferencesEntity {
  // Notificações
  final bool notifNovasVagas;
  final bool notifMensagens;
  final bool notifEmailSemanal;
  final bool notifPush;

  // Privacidade
  final bool perfilVisivelParaEmpresas;
  final bool mostrarEmailNoPerfil;

  // Preferências de vaga
  final Set<TipoVaga> tiposVaga;

  const UserPreferencesEntity({
    this.notifNovasVagas = true,
    this.notifMensagens = true,
    this.notifEmailSemanal = false,
    this.notifPush = true,
    this.perfilVisivelParaEmpresas = true,
    this.mostrarEmailNoPerfil = false,
    this.tiposVaga = const {TipoVaga.remoto},
  });

  UserPreferencesEntity copyWith({
    bool? notifNovasVagas,
    bool? notifMensagens,
    bool? notifEmailSemanal,
    bool? notifPush,
    bool? perfilVisivelParaEmpresas,
    bool? mostrarEmailNoPerfil,
    Set<TipoVaga>? tiposVaga,
  }) {
    return UserPreferencesEntity(
      notifNovasVagas: notifNovasVagas ?? this.notifNovasVagas,
      notifMensagens: notifMensagens ?? this.notifMensagens,
      notifEmailSemanal: notifEmailSemanal ?? this.notifEmailSemanal,
      notifPush: notifPush ?? this.notifPush,
      perfilVisivelParaEmpresas:
          perfilVisivelParaEmpresas ?? this.perfilVisivelParaEmpresas,
      mostrarEmailNoPerfil: mostrarEmailNoPerfil ?? this.mostrarEmailNoPerfil,
      tiposVaga: tiposVaga ?? this.tiposVaga,
    );
  }
}
