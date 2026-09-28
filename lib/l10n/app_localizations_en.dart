// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get headerUserAreaTooltip => 'User area';

  @override
  String get headerSettingsTooltip => 'Settings';

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
  String get authErrorRegistrationFailed =>
      'Could not create your account. Please try again.';

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
  String get jobsPageTitle => 'Jobs';

  @override
  String jobsAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs for you',
      one: '1 job for you',
    );
    return '$_temp0';
  }

  @override
  String get jobsSearchHint => 'Role, company or location';

  @override
  String get jobsSearchClearTooltip => 'Clear search';

  @override
  String get jobsEmptyTitle => 'No jobs found';

  @override
  String get jobsEmptySubtitle => 'Try adjusting the search or filters.';

  @override
  String get jobsErrorTitle => 'Could not load jobs.';

  @override
  String get jobsRetryButton => 'Try again';

  @override
  String jobApplySuccessMessage(String company) {
    return 'Application sent to $company!';
  }

  @override
  String get jobApplyErrorMessage => 'Could not submit your application.';

  @override
  String get jobRemoveSaved => 'Remove from saved';

  @override
  String get jobSaveJob => 'Save job';

  @override
  String get jobSalaryRangeLabel => 'Salary range';

  @override
  String jobPublishedPrefix(String time) {
    return 'Published $time';
  }

  @override
  String get jobAboutTitle => 'About the job';

  @override
  String get jobRequirementsTitle => 'Requirements';

  @override
  String get jobApplyButtonLabel => 'Apply';

  @override
  String get jobAppliedLabel => 'Applied';

  @override
  String get timeAgoNow => 'now';

  @override
  String timeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '$count min ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoYesterday => 'yesterday';

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }
}
