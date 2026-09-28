// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Jobfy';

  @override
  String get headerSettingsTooltip => 'Settings';

  @override
  String get headerUserAreaTooltip => 'User area';

  @override
  String get homeHeadline => 'Find the job\nof your dreams.';

  @override
  String get homeSubheadline =>
      'Jobfy uses intelligence to connect talent\nto real opportunities in the market.';

  @override
  String get homeCtaPrimary => 'Get started';

  @override
  String get homeCtaSecondary => 'I already have an account';

  @override
  String get loginHeroTitle => 'Connect to\nyour next job.';

  @override
  String get loginHeroSubtitle =>
      'Jobfy connects talent to real opportunities.\nShowcase your skills, find tailored jobs\nand accelerate your career\nwith intelligence.';

  @override
  String get chipCustomJobs => 'Tailored jobs';

  @override
  String get chipSmartMatch => 'Smart match';

  @override
  String get chipCareerGrowth => 'Career growth';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Enter your credentials to continue.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@email.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHintMin6 => 'At least 6 characters';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get loginButton => 'Sign in';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get createAccount => 'Create account';

  @override
  String get iAmCompany => 'I\'m a company';

  @override
  String get authErrorInvalidCredentials => 'Invalid email or password.';

  @override
  String get authErrorRegistrationFailed =>
      'Could not create your account. Please try again.';

  @override
  String get authErrorNetwork =>
      'Could not reach the server. Please try again later.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'For the growth of your career';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Your name...';

  @override
  String get cpfLabel => 'CPF';

  @override
  String get cpfHint => '000.000.000-00';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get acceptTermsPrefix => 'I accept the ';

  @override
  String get termsOfService => 'terms of service';

  @override
  String get termsRequiredError => 'You need to accept the terms.';

  @override
  String get registerButton => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get termsDialogTitle => 'Terms of Service';

  @override
  String get termsDialogBody =>
      'By creating a Jobfy account, you agree to our privacy policy and terms of use. Your data will be used exclusively to connect you to relevant job opportunities.';

  @override
  String get userAreaLoadError => 'Could not load your profile.';

  @override
  String get searchJobsPlaceholder => 'Search jobs...';

  @override
  String welcomeGreeting(String name) {
    return 'Hi, $name! 👋';
  }

  @override
  String get welcomeSubtitle => 'You have new jobs matching your profile.';

  @override
  String get viewRecommendedJobs => 'View recommended jobs';

  @override
  String get avgMatch => 'Average match';

  @override
  String get statApplications => 'Applications';

  @override
  String get statApplicationsSub => 'this month';

  @override
  String get statMatchScore => 'Match score';

  @override
  String get statMatchScoreSub => 'overall average';

  @override
  String get statProfileViews => 'Views';

  @override
  String get statProfileViewsSub => 'of your profile';

  @override
  String get skillsTitle => 'Skills';

  @override
  String get addSkill => 'Add';

  @override
  String get recommendedJobsTitle => 'Recommended jobs';

  @override
  String get viewAll => 'View all';

  @override
  String get applyButton => 'Apply';

  @override
  String get recentActivityTitle => 'Recent activity';

  @override
  String get profileCompletion => 'Profile completion';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navJobs => 'Jobs';

  @override
  String get navResume => 'Resume';

  @override
  String get navMessages => 'Messages';

  @override
  String get navSettings => 'Settings';

  @override
  String get navLogout => 'Log out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceDescription =>
      'Choose how Jobfy looks on this device.';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDescription => 'Choose the app language.';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsBack => 'Back';

  @override
  String get companyRegisterTitle => 'Register your company';

  @override
  String get companyRegisterSubtitle =>
      'Start publishing jobs and finding talent on Jobfy.';

  @override
  String get companyNameLabel => 'Company name';

  @override
  String get companyNameHint => 'Your company\'s name...';

  @override
  String get companyCnpjLabel => 'CNPJ';

  @override
  String get companyCnpjHint => '00.000.000/0000-00';

  @override
  String get companyPhoneLabel => 'Phone';

  @override
  String get companyPhoneHint => '(00) 00000-0000';

  @override
  String get companyRegisterButton => 'Register company';

  @override
  String get companyRegisterError =>
      'Could not register the company. Please try again.';

  @override
  String companyWelcome(String companyName) {
    return 'Welcome, $companyName';
  }

  @override
  String get companyPublishJobTitle => 'Publish a job';

  @override
  String get jobTitleLabel => 'Job title';

  @override
  String get jobTitleHint => 'e.g. Flutter Developer';

  @override
  String get jobDescriptionLabel => 'Description';

  @override
  String get jobDescriptionHint => 'Responsibilities, requirements...';

  @override
  String get jobLocationLabel => 'Location';

  @override
  String get jobLocationHint => 'e.g. Remote, São Paulo';

  @override
  String get jobContractTypeLabel => 'Contract type';

  @override
  String get jobContractTypeHint => 'e.g. Full-time, Contract';

  @override
  String get jobSalaryLabel => 'Salary range';

  @override
  String get jobSalaryHint => 'e.g. \$4,000 – \$6,000';

  @override
  String get companyPublishJobButton => 'Publish job';

  @override
  String get companyJobPublishError =>
      'Could not publish the job. Please try again.';

  @override
  String get companyJobsTitle => 'Published jobs';

  @override
  String get companyNoJobsYet =>
      'No jobs published yet. Publish your first one above.';

  @override
  String get companyViewCandidates => 'View candidates';

  @override
  String companyCandidatesTitle(String jobTitle) {
    return 'Candidates for $jobTitle';
  }

  @override
  String get companyRoleFilterLabel => 'Filter by desired role';

  @override
  String companyMinMatchLabel(int percent) {
    return 'Minimum match: $percent%';
  }

  @override
  String get companyNoCandidates => 'No candidates match this filter yet.';

  @override
  String get companyCandidateFilterError =>
      'Could not load candidates. Please try again.';

  @override
  String get companyRateCandidate => 'Rate';

  @override
  String get companyMessageCandidate => 'Message';

  @override
  String get companyRatingLabel => 'Rating (0-5)';

  @override
  String get companyMessageLabel => 'Message';

  @override
  String get companyMessageHint => 'Write a message to this candidate...';

  @override
  String get companySend => 'Send';

  @override
  String get companyCandidateRateError =>
      'Could not save the rating. Please try again.';

  @override
  String get companyMessageSendError =>
      'Could not send the message. Please try again.';

  @override
  String get companyRatingSaved => 'Rating saved.';

  @override
  String get companyMessageSent => 'Message sent.';

  @override
  String get jobsPageTitle => 'Jobs';

  @override
  String get jobsLocationHint => 'Location...';

  @override
  String get jobsNoResults => 'No jobs found for this search.';

  @override
  String get jobSearchError => 'Could not load jobs. Please try again.';

  @override
  String get jobApplyError =>
      'Could not submit your application. Please try again.';

  @override
  String get jobApplySuccess => 'Application submitted!';

  @override
  String get jobAlreadyApplied => 'Applied';

  @override
  String get jobViewDetails => 'View details';
}
