// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get homeHeadline => 'Encontre o emprego\ndos seus sonhos.';

  @override
  String get homeSubheadline =>
      'A Jobfy usa inteligência para conectar talentos\na oportunidades reais no mercado.';

  @override
  String get homeCtaPrimary => 'Começar agora';

  @override
  String get homeCtaSecondary => 'Já tenho conta';

  @override
  String get headerUserAreaTooltip => 'Área do usuário';

  @override
  String get headerSettingsTooltip => 'Configurações';

  @override
  String get loginHeroTitle => 'Conecte-se ao\nseu próximo emprego.';

  @override
  String get loginHeroSubtitle =>
      'A Jobfy conecta talentos a oportunidades reais.\nPublique suas habilidades, encontre vagas\npersonalizadas e acelere sua carreira\ncom inteligência.';

  @override
  String get chipCustomJobs => 'Vagas personalizadas';

  @override
  String get chipSmartMatch => 'Match inteligente';

  @override
  String get chipCareerGrowth => 'Crescimento de carreira';

  @override
  String get loginWelcomeBack => 'Bem-vindo de volta';

  @override
  String get loginSubtitle => 'Insira suas credenciais para acessar.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'seu@email.com';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get passwordHintMin6 => 'Mínimo 6 caracteres';

  @override
  String get rememberMe => 'Lembre-me';

  @override
  String get loginButton => 'Entrar';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get iAmCompany => 'Sou empresa';

  @override
  String get authErrorInvalidCredentials => 'Email ou senha inválidos.';

  @override
  String get registerTitle => 'Crie sua conta';

  @override
  String get registerSubtitle => 'Para o crescimento da sua carreira';

  @override
  String get fullNameLabel => 'Nome completo';

  @override
  String get fullNameHint => 'Seu nome...';

  @override
  String get cpfLabel => 'CPF';

  @override
  String get cpfHint => '000.000.000-00';

  @override
  String get genderLabel => 'Gênero';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderFemale => 'Feminino';

  @override
  String get genderOther => 'Outro';

  @override
  String get acceptTermsPrefix => 'Aceito os ';

  @override
  String get termsOfService => 'termos de serviço';

  @override
  String get termsRequiredError => 'Você precisa aceitar os termos.';

  @override
  String get registerButton => 'Criar conta';

  @override
  String get alreadyHaveAccount => 'Já tenho conta → Fazer login';

  @override
  String get termsDialogTitle => 'Termos de Serviço';

  @override
  String get termsDialogBody =>
      'Ao criar uma conta na Jobfy, você concorda com nossa política de privacidade e termos de uso. Seus dados serão utilizados exclusivamente para conectar você a oportunidades de emprego relevantes.';

  @override
  String get authErrorRegistrationFailed =>
      'Erro ao criar conta. Tente novamente.';

  @override
  String get userAreaLoadError => 'Erro ao carregar perfil.';

  @override
  String get searchJobsPlaceholder => 'Buscar vagas...';

  @override
  String welcomeGreeting(String name) {
    return 'Olá, $name! 👋';
  }

  @override
  String get welcomeSubtitle =>
      'Você tem novas vagas compatíveis com seu perfil.';

  @override
  String get viewRecommendedJobs => 'Ver vagas recomendadas';

  @override
  String get avgMatch => 'Match médio';

  @override
  String get statApplications => 'Candidaturas';

  @override
  String get statApplicationsSub => 'este mês';

  @override
  String get statMatchScore => 'Match Score';

  @override
  String get statMatchScoreSub => 'média geral';

  @override
  String get statProfileViews => 'Visualizações';

  @override
  String get statProfileViewsSub => 'do seu perfil';

  @override
  String get skillsTitle => 'Habilidades';

  @override
  String get addSkill => 'Adicionar';

  @override
  String get recommendedJobsTitle => 'Vagas Recomendadas';

  @override
  String get viewAll => 'Ver todas';

  @override
  String get recentActivityTitle => 'Atividade Recente';

  @override
  String get profileCompletion => 'Perfil completo';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navJobs => 'Vagas';

  @override
  String get navResume => 'Currículo';

  @override
  String get navMessages => 'Mensagens';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navLogout => 'Sair';

  @override
  String get jobsPageTitle => 'Vagas';

  @override
  String jobsAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vagas para você',
      one: '1 vaga para você',
    );
    return '$_temp0';
  }

  @override
  String get jobsSearchHint => 'Cargo, empresa ou local';

  @override
  String get jobsSearchClearTooltip => 'Limpar busca';

  @override
  String get jobsEmptyTitle => 'Nenhuma vaga encontrada';

  @override
  String get jobsEmptySubtitle => 'Tente ajustar a busca ou os filtros.';

  @override
  String get jobsErrorTitle => 'Erro ao carregar vagas.';

  @override
  String get jobsRetryButton => 'Tentar novamente';

  @override
  String jobApplySuccessMessage(String company) {
    return 'Candidatura enviada para $company!';
  }

  @override
  String get jobApplyErrorMessage => 'Não foi possível enviar a candidatura.';

  @override
  String get jobRemoveSaved => 'Remover dos salvos';

  @override
  String get jobSaveJob => 'Salvar vaga';

  @override
  String get jobSalaryRangeLabel => 'Faixa salarial';

  @override
  String jobPublishedPrefix(String time) {
    return 'Publicada $time';
  }

  @override
  String get jobAboutTitle => 'Sobre a vaga';

  @override
  String get jobRequirementsTitle => 'Requisitos';

  @override
  String get jobApplyButtonLabel => 'Candidatar';

  @override
  String get jobAppliedLabel => 'Candidatado';

  @override
  String get timeAgoNow => 'agora';

  @override
  String timeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count min',
      one: 'há $count min',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count horas',
      one: 'há 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoYesterday => 'ontem';

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count meses',
      one: 'há 1 mês',
    );
    return '$_temp0';
  }
}
