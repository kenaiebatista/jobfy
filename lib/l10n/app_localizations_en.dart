// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errorLoadingProfile => 'Could not load profile.';

  @override
  String get searchJobsHint => 'Search jobs...';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get userAreaTooltip => 'User area';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get homeHeadline => 'Find the job\nof your dreams.';

  @override
  String get homeSubtitle =>
      'Jobfy uses intelligence to connect talent\nwith real opportunities in the market.';

  @override
  String get homeGetStarted => 'Get started';

  @override
  String get homeHaveAccount => 'I have an account';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Enter your credentials to sign in.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'you@email.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'At least 6 characters';

  @override
  String get loginRememberMe => 'Remember me';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get createAccount => 'Create account';

  @override
  String get loginIamCompany => 'I\'m a company';

  @override
  String get loginHeroTitle => 'Connect to\nyour next job.';

  @override
  String get loginHeroDescription =>
      'Jobfy connects talent with real opportunities.\nShowcase your skills, find personalized\njobs and accelerate your career\nwith intelligence.';

  @override
  String get chipPersonalizedJobs => 'Personalized jobs';

  @override
  String get chipSmartMatch => 'Smart match';

  @override
  String get chipCareerGrowth => 'Career growth';

  @override
  String get authErrorInvalidCredentials => 'Invalid e-mail or password.';

  @override
  String get authErrorRegisterFailed =>
      'Could not create account. Please try again.';

  @override
  String get registerTermsRequired => 'You must accept the terms.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'To grow your career';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Your name...';

  @override
  String get cpfLabel => 'CPF';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get registerAcceptTermsPrefix => 'I accept the ';

  @override
  String get registerTermsLink => 'terms of service';

  @override
  String get registerGoToLogin => 'I have an account → Sign in';

  @override
  String get termsTitle => 'Terms of Service';

  @override
  String get termsBody =>
      'By creating a Jobfy account, you agree to our privacy policy and terms of use. Your data will be used exclusively to connect you with relevant job opportunities.';

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
  String get profileComplete => 'Profile complete';

  @override
  String dashboardGreeting(String name) {
    return 'Hi, $name! 👋';
  }

  @override
  String get dashboardNewMatches => 'You have new jobs matching your profile.';

  @override
  String get dashboardSeeRecommended => 'See recommended jobs';

  @override
  String get averageMatch => 'Average match';

  @override
  String get statsApplications => 'Applications';

  @override
  String get statsApplicationsSub => 'this month';

  @override
  String get statsMatchScore => 'Match Score';

  @override
  String get statsMatchScoreSub => 'overall average';

  @override
  String get statsViews => 'Views';

  @override
  String get statsViewsSub => 'of your profile';

  @override
  String get skillsTitle => 'Skills';

  @override
  String get skillsAdd => 'Add';

  @override
  String get recommendedJobs => 'Recommended Jobs';

  @override
  String get seeAll => 'See all';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get applyButton => 'Apply';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Manage your account, notifications and preferences.';

  @override
  String get settingsSaved => 'Changes saved successfully.';

  @override
  String get accountInfoTitle => 'Account information';

  @override
  String get accountInfoSubtitle => 'Your basic profile data.';

  @override
  String get locationLabel => 'Location';

  @override
  String get saving => 'Saving...';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get nameRequired => 'Please enter your name.';

  @override
  String get emailInvalid => 'Please enter a valid e-mail.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle =>
      'Choose what you want to be notified about.';

  @override
  String get notifNewJobsTitle => 'New matching jobs';

  @override
  String get notifNewJobsSubtitle => 'Notify me when high-match jobs appear.';

  @override
  String get notifMessagesTitle => 'Messages from companies';

  @override
  String get notifMessagesSubtitle =>
      'Notify me about new messages from recruiters.';

  @override
  String get notifWeeklyTitle => 'Weekly e-mail summary';

  @override
  String get notifWeeklySubtitle => 'Get a summary of your applications.';

  @override
  String get notifPushTitle => 'Push notifications';

  @override
  String get notifPushSubtitle => 'Real-time alerts on your device.';

  @override
  String get privacyTitle => 'Privacy and security';

  @override
  String get privacySubtitle => 'Control who sees your information.';

  @override
  String get privacyVisibleTitle => 'Profile visible to companies';

  @override
  String get privacyVisibleSubtitle =>
      'Companies can find your profile in searches.';

  @override
  String get privacyShowEmailTitle => 'Show e-mail on profile';

  @override
  String get privacyShowEmailSubtitle => 'Display your e-mail to recruiters.';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm new password';

  @override
  String get passwordRequired => 'Please enter your current password.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordsDontMatch => 'Passwords do not match.';

  @override
  String get passwordChanged => 'Password changed successfully.';

  @override
  String get jobPrefsTitle => 'Job preferences';

  @override
  String get jobPrefsSubtitle => 'Work arrangements you accept.';

  @override
  String get jobTypeRemote => 'Remote';

  @override
  String get jobTypeHybrid => 'Hybrid';

  @override
  String get jobTypeOnsite => 'On-site';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceSubtitle => 'Customize the interface.';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose the app language.';

  @override
  String get dangerZoneTitle => 'Danger zone';

  @override
  String get logoutAccount => 'Log out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get accountDeleted => 'Account deleted.';
}
