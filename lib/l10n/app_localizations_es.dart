// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get homeHeadline => 'Encuentra el empleo\nde tus sueños.';

  @override
  String get homeSubheadline =>
      'Jobfy usa inteligencia para conectar talentos\ncon oportunidades reales del mercado.';

  @override
  String get homeCtaPrimary => 'Comenzar ahora';

  @override
  String get homeCtaSecondary => 'Ya tengo una cuenta';

  @override
  String get headerUserAreaTooltip => 'Área del usuario';

  @override
  String get headerSettingsTooltip => 'Configuración';

  @override
  String get loginHeroTitle => 'Conéctate a\ntu próximo empleo.';

  @override
  String get loginHeroSubtitle =>
      'Jobfy conecta talentos con oportunidades reales.\nMuestra tus habilidades, encuentra empleos\npersonalizados y acelera tu carrera\ncon inteligencia.';

  @override
  String get chipCustomJobs => 'Empleos personalizados';

  @override
  String get chipSmartMatch => 'Match inteligente';

  @override
  String get chipCareerGrowth => 'Crecimiento profesional';

  @override
  String get loginWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle => 'Ingresa tus credenciales para continuar.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailHint => 'tu@email.com';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordHintMin6 => 'Mínimo 6 caracteres';

  @override
  String get rememberMe => 'Recordarme';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get iAmCompany => 'Soy una empresa';

  @override
  String get authErrorInvalidCredentials => 'Correo o contraseña inválidos.';

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
  String get cpfHint => '000.000.000-00';

  @override
  String get genderLabel => 'Género';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderFemale => 'Femenino';

  @override
  String get genderOther => 'Otro';

  @override
  String get acceptTermsPrefix => 'Acepto los ';

  @override
  String get termsOfService => 'términos de servicio';

  @override
  String get termsRequiredError => 'Debes aceptar los términos.';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get termsDialogTitle => 'Términos de Servicio';

  @override
  String get termsDialogBody =>
      'Al crear una cuenta en Jobfy, aceptas nuestra política de privacidad y términos de uso. Tus datos se usarán exclusivamente para conectarte con oportunidades de empleo relevantes.';

  @override
  String get authErrorRegistrationFailed =>
      'No se pudo crear la cuenta. Inténtalo de nuevo.';

  @override
  String get userAreaLoadError => 'No se pudo cargar tu perfil.';

  @override
  String get searchJobsPlaceholder => 'Buscar empleos...';

  @override
  String welcomeGreeting(String name) {
    return '¡Hola, $name! 👋';
  }

  @override
  String get welcomeSubtitle =>
      'Tienes nuevos empleos que coinciden con tu perfil.';

  @override
  String get viewRecommendedJobs => 'Ver empleos recomendados';

  @override
  String get avgMatch => 'Match promedio';

  @override
  String get statApplications => 'Postulaciones';

  @override
  String get statApplicationsSub => 'este mes';

  @override
  String get statMatchScore => 'Match Score';

  @override
  String get statMatchScoreSub => 'promedio general';

  @override
  String get statProfileViews => 'Visualizaciones';

  @override
  String get statProfileViewsSub => 'de tu perfil';

  @override
  String get skillsTitle => 'Habilidades';

  @override
  String get addSkill => 'Agregar';

  @override
  String get recommendedJobsTitle => 'Empleos recomendados';

  @override
  String get viewAll => 'Ver todos';

  @override
  String get recentActivityTitle => 'Actividad reciente';

  @override
  String get profileCompletion => 'Perfil completo';

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
  String get navLogout => 'Cerrar sesión';

  @override
  String get jobsPageTitle => 'Empleos';

  @override
  String jobsAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count empleos para ti',
      one: '1 empleo para ti',
    );
    return '$_temp0';
  }

  @override
  String get jobsSearchHint => 'Puesto, empresa o ubicación';

  @override
  String get jobsSearchClearTooltip => 'Limpiar búsqueda';

  @override
  String get jobsEmptyTitle => 'No se encontraron empleos';

  @override
  String get jobsEmptySubtitle => 'Intenta ajustar la búsqueda o los filtros.';

  @override
  String get jobsErrorTitle => 'No se pudieron cargar los empleos.';

  @override
  String get jobsRetryButton => 'Intentar de nuevo';

  @override
  String jobApplySuccessMessage(String company) {
    return '¡Postulación enviada a $company!';
  }

  @override
  String get jobApplyErrorMessage => 'No se pudo enviar tu postulación.';

  @override
  String get jobRemoveSaved => 'Quitar de guardados';

  @override
  String get jobSaveJob => 'Guardar empleo';

  @override
  String get jobSalaryRangeLabel => 'Rango salarial';

  @override
  String jobPublishedPrefix(String time) {
    return 'Publicado $time';
  }

  @override
  String get jobAboutTitle => 'Sobre el empleo';

  @override
  String get jobRequirementsTitle => 'Requisitos';

  @override
  String get jobApplyButtonLabel => 'Postularme';

  @override
  String get jobAppliedLabel => 'Postulado';

  @override
  String get timeAgoNow => 'ahora';

  @override
  String timeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count min',
      one: 'hace $count min',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count horas',
      one: 'hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoYesterday => 'ayer';

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count meses',
      one: 'hace 1 mes',
    );
    return '$_temp0';
  }
}
