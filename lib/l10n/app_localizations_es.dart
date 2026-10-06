// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get errorLoadingProfile => 'Error al cargar el perfil.';

  @override
  String get searchJobsHint => 'Buscar empleos...';

  @override
  String get comingSoon => '¡Próximamente!';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get userAreaTooltip => 'Área del usuario';

  @override
  String get notificationsTooltip => 'Notificaciones';

  @override
  String get homeHeadline => 'Encuentra el empleo\nde tus sueños.';

  @override
  String get homeSubtitle =>
      'Jobfy usa inteligencia para conectar talentos\ncon oportunidades reales en el mercado.';

  @override
  String get homeGetStarted => 'Empezar ahora';

  @override
  String get homeHaveAccount => 'Ya tengo cuenta';

  @override
  String get loginWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle => 'Ingresa tus credenciales para acceder.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailHint => 'tu@email.com';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordHint => 'Mínimo 6 caracteres';

  @override
  String get loginRememberMe => 'Recordarme';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get loginIamCompany => 'Soy empresa';

  @override
  String get loginHeroTitle => 'Conéctate a\ntu próximo empleo.';

  @override
  String get loginHeroDescription =>
      'Jobfy conecta talentos con oportunidades reales.\nPublica tus habilidades, encuentra empleos\npersonalizados y acelera tu carrera\ncon inteligencia.';

  @override
  String get chipPersonalizedJobs => 'Empleos personalizados';

  @override
  String get chipSmartMatch => 'Match inteligente';

  @override
  String get chipCareerGrowth => 'Crecimiento profesional';

  @override
  String get authErrorInvalidCredentials => 'Correo o contraseña inválidos.';

  @override
  String get authErrorRegisterFailed =>
      'Error al crear la cuenta. Inténtalo de nuevo.';

  @override
  String get registerTermsRequired => 'Debes aceptar los términos.';

  @override
  String get registerTitle => 'Crea tu cuenta';

  @override
  String get registerSubtitle => 'Para el crecimiento de tu carrera';

  @override
  String get fullNameLabel => 'Nombre completo';

  @override
  String get fullNameHint => 'Tu nombre...';

  @override
  String get cpfLabel => 'CPF';

  @override
  String get genderLabel => 'Género';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderFemale => 'Femenino';

  @override
  String get genderOther => 'Otro';

  @override
  String get registerAcceptTermsPrefix => 'Acepto los ';

  @override
  String get registerTermsLink => 'términos de servicio';

  @override
  String get registerGoToLogin => 'Ya tengo cuenta → Iniciar sesión';

  @override
  String get termsTitle => 'Términos de Servicio';

  @override
  String get termsBody =>
      'Al crear una cuenta en Jobfy, aceptas nuestra política de privacidad y términos de uso. Tus datos se utilizarán exclusivamente para conectarte con oportunidades de empleo relevantes.';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navJobs => 'Empleos';

  @override
  String get navResume => 'Currículum';

  @override
  String get navMessages => 'Mensajes';

  @override
  String get navSettings => 'Configuración';

  @override
  String get navLogout => 'Salir';

  @override
  String get profileComplete => 'Perfil completo';

  @override
  String dashboardGreeting(String name) {
    return '¡Hola, $name! 👋';
  }

  @override
  String get dashboardNewMatches =>
      'Tienes nuevos empleos compatibles con tu perfil.';

  @override
  String get dashboardSeeRecommended => 'Ver empleos recomendados';

  @override
  String get averageMatch => 'Match promedio';

  @override
  String get statsApplications => 'Postulaciones';

  @override
  String get statsApplicationsSub => 'este mes';

  @override
  String get statsMatchScore => 'Match Score';

  @override
  String get statsMatchScoreSub => 'promedio general';

  @override
  String get statsViews => 'Visualizaciones';

  @override
  String get statsViewsSub => 'de tu perfil';

  @override
  String get skillsTitle => 'Habilidades';

  @override
  String get skillsAdd => 'Agregar';

  @override
  String get recommendedJobs => 'Empleos Recomendados';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get recentActivity => 'Actividad Reciente';

  @override
  String get applyButton => 'Postularme';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsSubtitle =>
      'Administra tu cuenta, notificaciones y preferencias.';

  @override
  String get settingsSaved => 'Cambios guardados con éxito.';

  @override
  String get accountInfoTitle => 'Información de la cuenta';

  @override
  String get accountInfoSubtitle => 'Tus datos básicos de perfil.';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get saving => 'Guardando...';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get nameRequired => 'Ingresa tu nombre.';

  @override
  String get emailInvalid => 'Ingresa un correo válido.';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsSubtitle => 'Elige sobre qué quieres ser avisado.';

  @override
  String get notifNewJobsTitle => 'Nuevos empleos compatibles';

  @override
  String get notifNewJobsSubtitle =>
      'Avisar cuando surjan empleos con alto match.';

  @override
  String get notifMessagesTitle => 'Mensajes de empresas';

  @override
  String get notifMessagesSubtitle =>
      'Notificar sobre nuevos mensajes de reclutadores.';

  @override
  String get notifWeeklyTitle => 'Resumen semanal por correo';

  @override
  String get notifWeeklySubtitle => 'Recibe un resumen de tus postulaciones.';

  @override
  String get notifPushTitle => 'Notificaciones push';

  @override
  String get notifPushSubtitle => 'Alertas en tiempo real en el dispositivo.';

  @override
  String get privacyTitle => 'Privacidad y seguridad';

  @override
  String get privacySubtitle => 'Controla quién ve tu información.';

  @override
  String get privacyVisibleTitle => 'Perfil visible para empresas';

  @override
  String get privacyVisibleSubtitle =>
      'Las empresas pueden encontrar tu perfil en las búsquedas.';

  @override
  String get privacyShowEmailTitle => 'Mostrar correo en el perfil';

  @override
  String get privacyShowEmailSubtitle =>
      'Mostrar tu correo a los reclutadores.';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get passwordRequired => 'Ingresa tu contraseña actual.';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden.';

  @override
  String get passwordChanged => 'Contraseña cambiada con éxito.';

  @override
  String get jobPrefsTitle => 'Preferencias de empleo';

  @override
  String get jobPrefsSubtitle => 'Modalidades de trabajo que aceptas.';

  @override
  String get jobTypeRemote => 'Remoto';

  @override
  String get jobTypeHybrid => 'Híbrido';

  @override
  String get jobTypeOnsite => 'Presencial';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get appearanceSubtitle => 'Personaliza la interfaz.';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeToggleToLight => 'Usar tema claro';

  @override
  String get themeToggleToDark => 'Usar tema oscuro';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle => 'Elige el idioma de la aplicación.';

  @override
  String get dangerZoneTitle => 'Zona de riesgo';

  @override
  String get logoutAccount => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirm =>
      '¿Seguro que deseas eliminar tu cuenta? Esta acción no se puede deshacer.';

  @override
  String get delete => 'Eliminar';

  @override
  String get accountDeleted => 'Cuenta eliminada.';
}
