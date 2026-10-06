import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @errorLoadingProfile.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar perfil.'**
  String get errorLoadingProfile;

  /// No description provided for @searchJobsHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar vagas...'**
  String get searchJobsHint;

  /// No description provided for @comingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Em breve!'**
  String get comingSoon;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @userAreaTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Área do usuário'**
  String get userAreaTooltip;

  /// No description provided for @notificationsTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notificationsTooltip;

  /// No description provided for @homeHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Encontre o emprego\ndos seus sonhos.'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'A Jobfy usa inteligência para conectar talentos\na oportunidades reais no mercado.'**
  String get homeSubtitle;

  /// No description provided for @homeGetStarted.
  ///
  /// In pt, this message translates to:
  /// **'Começar agora'**
  String get homeGetStarted;

  /// No description provided for @homeHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho conta'**
  String get homeHaveAccount;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Insira suas credenciais para acessar.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In pt, this message translates to:
  /// **'seu@email.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get passwordHint;

  /// No description provided for @loginRememberMe.
  ///
  /// In pt, this message translates to:
  /// **'Lembre-me'**
  String get loginRememberMe;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a senha?'**
  String get loginForgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get createAccount;

  /// No description provided for @loginIamCompany.
  ///
  /// In pt, this message translates to:
  /// **'Sou empresa'**
  String get loginIamCompany;

  /// No description provided for @loginHeroTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conecte-se ao\nseu próximo emprego.'**
  String get loginHeroTitle;

  /// No description provided for @loginHeroDescription.
  ///
  /// In pt, this message translates to:
  /// **'A Jobfy conecta talentos a oportunidades reais.\nPublique suas habilidades, encontre vagas\npersonalizadas e acelere sua carreira\ncom inteligência.'**
  String get loginHeroDescription;

  /// No description provided for @chipPersonalizedJobs.
  ///
  /// In pt, this message translates to:
  /// **'Vagas personalizadas'**
  String get chipPersonalizedJobs;

  /// No description provided for @chipSmartMatch.
  ///
  /// In pt, this message translates to:
  /// **'Match inteligente'**
  String get chipSmartMatch;

  /// No description provided for @chipCareerGrowth.
  ///
  /// In pt, this message translates to:
  /// **'Crescimento de carreira'**
  String get chipCareerGrowth;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha inválidos.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorRegisterFailed.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao criar conta. Tente novamente.'**
  String get authErrorRegisterFailed;

  /// No description provided for @registerTermsRequired.
  ///
  /// In pt, this message translates to:
  /// **'Você precisa aceitar os termos.'**
  String get registerTermsRequired;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie sua conta'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Para o crescimento da sua carreira'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Seu nome...'**
  String get fullNameHint;

  /// No description provided for @cpfLabel.
  ///
  /// In pt, this message translates to:
  /// **'CPF'**
  String get cpfLabel;

  /// No description provided for @genderLabel.
  ///
  /// In pt, this message translates to:
  /// **'Gênero'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In pt, this message translates to:
  /// **'Masculino'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In pt, this message translates to:
  /// **'Feminino'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get genderOther;

  /// No description provided for @registerAcceptTermsPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Aceito os '**
  String get registerAcceptTermsPrefix;

  /// No description provided for @registerTermsLink.
  ///
  /// In pt, this message translates to:
  /// **'termos de serviço'**
  String get registerTermsLink;

  /// No description provided for @registerGoToLogin.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho conta → Fazer login'**
  String get registerGoToLogin;

  /// No description provided for @termsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Serviço'**
  String get termsTitle;

  /// No description provided for @termsBody.
  ///
  /// In pt, this message translates to:
  /// **'Ao criar uma conta na Jobfy, você concorda com nossa política de privacidade e termos de uso. Seus dados serão utilizados exclusivamente para conectar você a oportunidades de emprego relevantes.'**
  String get termsBody;

  /// No description provided for @navDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navJobs.
  ///
  /// In pt, this message translates to:
  /// **'Vagas'**
  String get navJobs;

  /// No description provided for @navResume.
  ///
  /// In pt, this message translates to:
  /// **'Currículo'**
  String get navResume;

  /// No description provided for @navMessages.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens'**
  String get navMessages;

  /// No description provided for @navSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get navSettings;

  /// No description provided for @navLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get navLogout;

  /// No description provided for @profileComplete.
  ///
  /// In pt, this message translates to:
  /// **'Perfil completo'**
  String get profileComplete;

  /// No description provided for @dashboardGreeting.
  ///
  /// In pt, this message translates to:
  /// **'Olá, {name}! 👋'**
  String dashboardGreeting(String name);

  /// No description provided for @dashboardNewMatches.
  ///
  /// In pt, this message translates to:
  /// **'Você tem novas vagas compatíveis com seu perfil.'**
  String get dashboardNewMatches;

  /// No description provided for @dashboardSeeRecommended.
  ///
  /// In pt, this message translates to:
  /// **'Ver vagas recomendadas'**
  String get dashboardSeeRecommended;

  /// No description provided for @averageMatch.
  ///
  /// In pt, this message translates to:
  /// **'Match médio'**
  String get averageMatch;

  /// No description provided for @statsApplications.
  ///
  /// In pt, this message translates to:
  /// **'Candidaturas'**
  String get statsApplications;

  /// No description provided for @statsApplicationsSub.
  ///
  /// In pt, this message translates to:
  /// **'este mês'**
  String get statsApplicationsSub;

  /// No description provided for @statsMatchScore.
  ///
  /// In pt, this message translates to:
  /// **'Match Score'**
  String get statsMatchScore;

  /// No description provided for @statsMatchScoreSub.
  ///
  /// In pt, this message translates to:
  /// **'média geral'**
  String get statsMatchScoreSub;

  /// No description provided for @statsViews.
  ///
  /// In pt, this message translates to:
  /// **'Visualizações'**
  String get statsViews;

  /// No description provided for @statsViewsSub.
  ///
  /// In pt, this message translates to:
  /// **'do seu perfil'**
  String get statsViewsSub;

  /// No description provided for @skillsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Habilidades'**
  String get skillsTitle;

  /// No description provided for @skillsAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get skillsAdd;

  /// No description provided for @recommendedJobs.
  ///
  /// In pt, this message translates to:
  /// **'Vagas Recomendadas'**
  String get recommendedJobs;

  /// No description provided for @seeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver todas'**
  String get seeAll;

  /// No description provided for @recentActivity.
  ///
  /// In pt, this message translates to:
  /// **'Atividade Recente'**
  String get recentActivity;

  /// No description provided for @applyButton.
  ///
  /// In pt, this message translates to:
  /// **'Candidatar'**
  String get applyButton;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Gerencie sua conta, notificações e preferências.'**
  String get settingsSubtitle;

  /// No description provided for @settingsSaved.
  ///
  /// In pt, this message translates to:
  /// **'Alterações salvas com sucesso.'**
  String get settingsSaved;

  /// No description provided for @accountInfoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Informações da conta'**
  String get accountInfoTitle;

  /// No description provided for @accountInfoSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados básicos de perfil.'**
  String get accountInfoSubtitle;

  /// No description provided for @locationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get locationLabel;

  /// No description provided for @saving.
  ///
  /// In pt, this message translates to:
  /// **'Salvando...'**
  String get saving;

  /// No description provided for @saveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get saveChanges;

  /// No description provided for @nameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu nome.'**
  String get nameRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe um e-mail válido.'**
  String get emailInvalid;

  /// No description provided for @notificationsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o que você quer ser avisado.'**
  String get notificationsSubtitle;

  /// No description provided for @notifNewJobsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novas vagas compatíveis'**
  String get notifNewJobsTitle;

  /// No description provided for @notifNewJobsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Avise quando surgirem vagas com alto match.'**
  String get notifNewJobsSubtitle;

  /// No description provided for @notifMessagesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mensagens de empresas'**
  String get notifMessagesTitle;

  /// No description provided for @notifMessagesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificar sobre novas mensagens de recrutadores.'**
  String get notifMessagesSubtitle;

  /// No description provided for @notifWeeklyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resumo semanal por e-mail'**
  String get notifWeeklyTitle;

  /// No description provided for @notifWeeklySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Receba um resumo das suas candidaturas.'**
  String get notifWeeklySubtitle;

  /// No description provided for @notifPushTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificações push'**
  String get notifPushTitle;

  /// No description provided for @notifPushSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Alertas em tempo real no dispositivo.'**
  String get notifPushSubtitle;

  /// No description provided for @privacyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade e segurança'**
  String get privacyTitle;

  /// No description provided for @privacySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Controle quem vê suas informações.'**
  String get privacySubtitle;

  /// No description provided for @privacyVisibleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil visível para empresas'**
  String get privacyVisibleTitle;

  /// No description provided for @privacyVisibleSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Empresas podem encontrar seu perfil nas buscas.'**
  String get privacyVisibleSubtitle;

  /// No description provided for @privacyShowEmailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar e-mail no perfil'**
  String get privacyShowEmailTitle;

  /// No description provided for @privacyShowEmailSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Exibir seu e-mail para recrutadores.'**
  String get privacyShowEmailSubtitle;

  /// No description provided for @changePassword.
  ///
  /// In pt, this message translates to:
  /// **'Alterar senha'**
  String get changePassword;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha atual'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar nova senha'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe a senha atual.'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 6 caracteres.'**
  String get passwordTooShort;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem.'**
  String get passwordsDontMatch;

  /// No description provided for @passwordChanged.
  ///
  /// In pt, this message translates to:
  /// **'Senha alterada com sucesso.'**
  String get passwordChanged;

  /// No description provided for @jobPrefsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Preferências de vaga'**
  String get jobPrefsTitle;

  /// No description provided for @jobPrefsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Tipos de trabalho que você aceita.'**
  String get jobPrefsSubtitle;

  /// No description provided for @jobTypeRemote.
  ///
  /// In pt, this message translates to:
  /// **'Remoto'**
  String get jobTypeRemote;

  /// No description provided for @jobTypeHybrid.
  ///
  /// In pt, this message translates to:
  /// **'Híbrido'**
  String get jobTypeHybrid;

  /// No description provided for @jobTypeOnsite.
  ///
  /// In pt, this message translates to:
  /// **'Presencial'**
  String get jobTypeOnsite;

  /// No description provided for @appearanceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearanceTitle;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Personalize a interface.'**
  String get appearanceSubtitle;

  /// No description provided for @themeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get themeLabel;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @languageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma do aplicativo.'**
  String get languageSubtitle;

  /// No description provided for @dangerZoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Zona de risco'**
  String get dangerZoneTitle;

  /// No description provided for @logoutAccount.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get logoutAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita.'**
  String get deleteAccountConfirm;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @accountDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Conta excluída.'**
  String get accountDeleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
