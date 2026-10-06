// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Jobfy';

  @override
  String get headerSettingsTooltip => 'Configuración';

  @override
  String get headerUserAreaTooltip => 'Área del usuario';

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
  String get authErrorRegistrationFailed =>
      'No se pudo crear la cuenta. Inténtalo de nuevo.';

  @override
  String get authErrorEmailInUse => 'Este correo ya está registrado.';

  @override
  String get authErrorNetwork =>
      'No se pudo conectar con el servidor. Inténtalo más tarde.';

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
  String get statApplicationsSub => 'en total';

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
  String get applyButton => 'Postularme';

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
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsAppearanceDescription =>
      'Elige cómo se ve Jobfy en este dispositivo.';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDescription => 'Elige el idioma de la aplicación.';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get settingsBack => 'Volver';

  @override
  String get settingsSubtitle =>
      'Administra tu cuenta, notificaciones y preferencias.';

  @override
  String get settingsAccountTitle => 'Información de la cuenta';

  @override
  String get settingsAccountDescription => 'Tus datos básicos de perfil.';

  @override
  String get settingsSaveChanges => 'Guardar cambios';

  @override
  String get settingsSaving => 'Guardando...';

  @override
  String get settingsSaved => 'Cambios guardados con éxito.';

  @override
  String get settingsSaveError =>
      'No se pudieron guardar los cambios. Inténtalo de nuevo.';

  @override
  String get settingsNameRequired => 'Ingresa tu nombre.';

  @override
  String get settingsEmailInvalid => 'Ingresa un correo válido.';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsDescription =>
      'Elige sobre qué quieres ser avisado.';

  @override
  String get settingsNotifNewJobs => 'Nuevos empleos compatibles';

  @override
  String get settingsNotifNewJobsDescription =>
      'Avisar cuando surjan empleos con alto match.';

  @override
  String get settingsNotifMessages => 'Mensajes de empresas';

  @override
  String get settingsNotifMessagesDescription =>
      'Notificar sobre nuevos mensajes de reclutadores.';

  @override
  String get settingsNotifWeekly => 'Resumen semanal por correo';

  @override
  String get settingsNotifWeeklyDescription =>
      'Recibe un resumen de tus postulaciones.';

  @override
  String get settingsNotifPush => 'Notificaciones push';

  @override
  String get settingsNotifPushDescription =>
      'Alertas en tiempo real en el dispositivo.';

  @override
  String get settingsPrivacy => 'Privacidad y seguridad';

  @override
  String get settingsPrivacyDescription => 'Controla quién ve tu información.';

  @override
  String get settingsProfileVisible => 'Perfil visible para empresas';

  @override
  String get settingsProfileVisibleDescription =>
      'Las empresas pueden encontrar tu perfil en las búsquedas.';

  @override
  String get settingsShowEmail => 'Mostrar correo en el perfil';

  @override
  String get settingsShowEmailDescription =>
      'Mostrar tu correo a los reclutadores.';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsCurrentPassword => 'Contraseña actual';

  @override
  String get settingsNewPassword => 'Nueva contraseña';

  @override
  String get settingsConfirmPassword => 'Confirmar nueva contraseña';

  @override
  String get settingsPasswordRequired => 'Ingresa tu contraseña actual.';

  @override
  String get settingsPasswordTooShort =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get settingsPasswordsDontMatch => 'Las contraseñas no coinciden.';

  @override
  String get settingsWrongPassword => 'La contraseña actual es incorrecta.';

  @override
  String get settingsPasswordChanged => 'Contraseña cambiada con éxito.';

  @override
  String get settingsPasswordError =>
      'No se pudo cambiar la contraseña. Inténtalo de nuevo.';

  @override
  String get settingsSave => 'Guardar';

  @override
  String get settingsJobPreferences => 'Preferencias de empleo';

  @override
  String get settingsJobPreferencesDescription =>
      'Modalidades de trabajo que aceptas.';

  @override
  String get settingsJobTypeRemote => 'Remoto';

  @override
  String get settingsJobTypeHybrid => 'Híbrido';

  @override
  String get settingsJobTypeOnsite => 'Presencial';

  @override
  String get settingsDangerZone => 'Zona de riesgo';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountConfirm =>
      '¿Seguro que deseas eliminar tu cuenta? Ya no podrás iniciar sesión con ella.';

  @override
  String get settingsDelete => 'Eliminar';

  @override
  String get settingsAccountDeleted => 'Cuenta eliminada.';

  @override
  String get settingsDeleteError =>
      'No se pudo eliminar la cuenta. Inténtalo de nuevo.';

  @override
  String get settingsThemeToggleToLight => 'Usar tema claro';

  @override
  String get settingsThemeToggleToDark => 'Usar tema oscuro';

  @override
  String get companyRegisterTitle => 'Registra tu empresa';

  @override
  String get companyRegisterSubtitle =>
      'Empieza a publicar empleos y encontrar talento en Jobfy.';

  @override
  String get companyNameLabel => 'Nombre de la empresa';

  @override
  String get companyNameHint => 'El nombre de tu empresa...';

  @override
  String get companyCnpjLabel => 'CNPJ';

  @override
  String get companyCnpjHint => '00.000.000/0000-00';

  @override
  String get companyPhoneLabel => 'Teléfono';

  @override
  String get companyPhoneHint => '(00) 00000-0000';

  @override
  String get companyRegisterButton => 'Registrar empresa';

  @override
  String get companyRegisterError =>
      'No se pudo registrar la empresa. Inténtalo de nuevo.';

  @override
  String companyWelcome(String companyName) {
    return 'Bienvenido, $companyName';
  }

  @override
  String get companyPublishJobTitle => 'Publicar un empleo';

  @override
  String get jobTitleLabel => 'Título del empleo';

  @override
  String get jobTitleHint => 'ej.: Desarrollador Flutter';

  @override
  String get jobDescriptionLabel => 'Descripción';

  @override
  String get jobDescriptionHint => 'Responsabilidades, requisitos...';

  @override
  String get jobLocationLabel => 'Ubicación';

  @override
  String get jobLocationHint => 'ej.: Remoto, Madrid';

  @override
  String get jobContractTypeLabel => 'Tipo de contrato';

  @override
  String get jobContractTypeHint => 'ej.: Tiempo completo, Freelance';

  @override
  String get jobSalaryLabel => 'Rango salarial';

  @override
  String get jobSalaryHint => 'ej.: 2.000 – 3.000 €';

  @override
  String get companyPublishJobButton => 'Publicar empleo';

  @override
  String get companyJobPublishError =>
      'No se pudo publicar el empleo. Inténtalo de nuevo.';

  @override
  String get companyJobsTitle => 'Empleos publicados';

  @override
  String get companyNoJobsYet =>
      'Aún no hay empleos publicados. Publica el primero arriba.';

  @override
  String get companyViewCandidates => 'Ver candidatos';

  @override
  String companyCandidatesTitle(String jobTitle) {
    return 'Candidatos para $jobTitle';
  }

  @override
  String get companyRoleFilterLabel => 'Filtrar por puesto deseado';

  @override
  String companyMinMatchLabel(int percent) {
    return 'Match mínimo: $percent%';
  }

  @override
  String get companyNoCandidates =>
      'Ningún candidato coincide con este filtro todavía.';

  @override
  String get companyCandidateFilterError =>
      'No se pudieron cargar los candidatos. Inténtalo de nuevo.';

  @override
  String get companyRateCandidate => 'Calificar';

  @override
  String get companyMessageCandidate => 'Mensaje';

  @override
  String get companyRatingLabel => 'Calificación (0-5)';

  @override
  String get companyMessageLabel => 'Mensaje';

  @override
  String get companyMessageHint => 'Escribe un mensaje para este candidato...';

  @override
  String get companySend => 'Enviar';

  @override
  String get companyCandidateRateError =>
      'No se pudo guardar la calificación. Inténtalo de nuevo.';

  @override
  String get companyMessageSendError =>
      'No se pudo enviar el mensaje. Inténtalo de nuevo.';

  @override
  String get companyRatingSaved => 'Calificación guardada.';

  @override
  String get companyMessageSent => 'Mensaje enviado.';

  @override
  String get jobsPageTitle => 'Empleos';

  @override
  String get jobsLocationHint => 'Ubicación...';

  @override
  String get jobsNoResults => 'No se encontraron empleos para esta búsqueda.';

  @override
  String get jobSearchError =>
      'No se pudieron cargar los empleos. Inténtalo de nuevo.';

  @override
  String get jobApplyError =>
      'No se pudo enviar tu postulación. Inténtalo de nuevo.';

  @override
  String get jobApplySuccess => '¡Postulación enviada!';

  @override
  String get jobAlreadyApplied => 'Postulado';

  @override
  String get jobViewDetails => 'Ver detalles';

  @override
  String get authErrorCpfInUse => 'Este CPF ya está registrado.';

  @override
  String get registerSectionPersonal => 'Datos personales';

  @override
  String get registerSectionSkills => 'Habilidades';

  @override
  String get registerSectionExperience => 'Experiencia';

  @override
  String get registerSkillsHint =>
      'Toca las habilidades que tienes y elige tu nivel.';

  @override
  String get registerSkillsLoadError =>
      'No se pudo cargar la lista de habilidades.';

  @override
  String get otherSkillHint => 'Otra habilidad...';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get phoneHint => '(00) 00000-0000';

  @override
  String get birthDateLabel => 'Fecha de nacimiento';

  @override
  String get educationLevelLabel => 'Escolaridad';

  @override
  String get optionalSuffix => '(opcional)';

  @override
  String get educationElementaryIncomplete => 'Primaria (incompleta)';

  @override
  String get educationElementaryComplete => 'Primaria (completa)';

  @override
  String get educationHighSchoolIncomplete => 'Secundaria (incompleta)';

  @override
  String get educationHighSchoolComplete => 'Secundaria (completa)';

  @override
  String get educationTechnical => 'Curso técnico';

  @override
  String get educationBachelorIncomplete => 'Grado universitario (incompleto)';

  @override
  String get educationBachelorComplete => 'Grado universitario (completo)';

  @override
  String get educationPostgraduate => 'Posgrado';

  @override
  String get skillLevelBeginner => 'Principiante';

  @override
  String get skillLevelIntermediate => 'Intermedio';

  @override
  String get skillLevelAdvanced => 'Avanzado';

  @override
  String get addExperience => 'Añadir experiencia';

  @override
  String get noExperiencesYet =>
      'Ninguna experiencia añadida. ¡El voluntariado también cuenta!';

  @override
  String get experienceJobTitleLabel => 'Cargo';

  @override
  String get experienceCompanyLabel => 'Empresa';

  @override
  String get experienceDescriptionLabel => '¿Qué hacías?';

  @override
  String get experienceStartLabel => 'Inicio';

  @override
  String get experienceEndLabel => 'Fin';

  @override
  String get experienceCurrentJob => 'Trabajo aquí actualmente';

  @override
  String get experiencePresent => 'Actual';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogAdd => 'Añadir';

  @override
  String get fieldRequired => 'Campo obligatorio';

  @override
  String get emailInvalid => 'Introduce un correo válido';

  @override
  String get passwordTooShort => 'Usa al menos 6 caracteres';

  @override
  String get cpfInvalid => 'El CPF debe tener 11 dígitos';

  @override
  String get experienceDatesInvalid =>
      'La fecha de fin no puede ser anterior a la de inicio';

  @override
  String get statSkills => 'Habilidades';

  @override
  String get statSkillsSub => 'registradas';

  @override
  String get statExperiences => 'Experiencias';

  @override
  String get statExperiencesSub => 'en tu currículum';

  @override
  String get personalInfoTitle => 'Datos personales';

  @override
  String get notInformed => 'No informado';

  @override
  String get noSkillsYet => 'Aún no hay habilidades registradas.';

  @override
  String get noRecentActivity =>
      'Sin actividad reciente. Postúlate a una vacante para verla aquí.';
}
