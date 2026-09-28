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

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Find the job\nof your dreams.'**
  String get homeHeadline;

  /// No description provided for @homeSubheadline.
  ///
  /// In en, this message translates to:
  /// **'Jobfy uses intelligence to connect talent\nto real opportunities in the market.'**
  String get homeSubheadline;

  /// No description provided for @homeCtaPrimary.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get homeCtaPrimary;

  /// No description provided for @homeCtaSecondary.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get homeCtaSecondary;

  /// No description provided for @headerUserAreaTooltip.
  ///
  /// In en, this message translates to:
  /// **'User area'**
  String get headerUserAreaTooltip;

  /// No description provided for @headerSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get headerSettingsTooltip;

  /// No description provided for @loginHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to\nyour next job.'**
  String get loginHeroTitle;

  /// No description provided for @loginHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jobfy connects talent to real opportunities.\nShowcase your skills, find tailored jobs\nand accelerate your career\nwith intelligence.'**
  String get loginHeroSubtitle;

  /// No description provided for @chipCustomJobs.
  ///
  /// In en, this message translates to:
  /// **'Tailored jobs'**
  String get chipCustomJobs;

  /// No description provided for @chipSmartMatch.
  ///
  /// In en, this message translates to:
  /// **'Smart match'**
  String get chipSmartMatch;

  /// No description provided for @chipCareerGrowth.
  ///
  /// In en, this message translates to:
  /// **'Career growth'**
  String get chipCareerGrowth;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to continue.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHintMin6.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHintMin6;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @iAmCompany.
  ///
  /// In en, this message translates to:
  /// **'I\'m a company'**
  String get iAmCompany;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For the growth of your career'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name...'**
  String get fullNameHint;

  /// No description provided for @cpfLabel.
  ///
  /// In en, this message translates to:
  /// **'CPF'**
  String get cpfLabel;

  /// No description provided for @cpfHint.
  ///
  /// In en, this message translates to:
  /// **'000.000.000-00'**
  String get cpfHint;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @acceptTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get acceptTermsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'terms of service'**
  String get termsOfService;

  /// No description provided for @termsRequiredError.
  ///
  /// In en, this message translates to:
  /// **'You need to accept the terms.'**
  String get termsRequiredError;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @termsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsDialogTitle;

  /// No description provided for @termsDialogBody.
  ///
  /// In en, this message translates to:
  /// **'By creating a Jobfy account, you agree to our privacy policy and terms of use. Your data will be used exclusively to connect you to relevant job opportunities.'**
  String get termsDialogBody;

  /// No description provided for @authErrorRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create your account. Please try again.'**
  String get authErrorRegistrationFailed;

  /// No description provided for @userAreaLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile.'**
  String get userAreaLoadError;

  /// No description provided for @searchJobsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search jobs...'**
  String get searchJobsPlaceholder;

  /// No description provided for @welcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}! 👋'**
  String welcomeGreeting(String name);

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have new jobs matching your profile.'**
  String get welcomeSubtitle;

  /// No description provided for @viewRecommendedJobs.
  ///
  /// In en, this message translates to:
  /// **'View recommended jobs'**
  String get viewRecommendedJobs;

  /// No description provided for @avgMatch.
  ///
  /// In en, this message translates to:
  /// **'Average match'**
  String get avgMatch;

  /// No description provided for @statApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get statApplications;

  /// No description provided for @statApplicationsSub.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get statApplicationsSub;

  /// No description provided for @statMatchScore.
  ///
  /// In en, this message translates to:
  /// **'Match score'**
  String get statMatchScore;

  /// No description provided for @statMatchScoreSub.
  ///
  /// In en, this message translates to:
  /// **'overall average'**
  String get statMatchScoreSub;

  /// No description provided for @statProfileViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get statProfileViews;

  /// No description provided for @statProfileViewsSub.
  ///
  /// In en, this message translates to:
  /// **'of your profile'**
  String get statProfileViewsSub;

  /// No description provided for @skillsTitle.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skillsTitle;

  /// No description provided for @addSkill.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addSkill;

  /// No description provided for @recommendedJobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended jobs'**
  String get recommendedJobsTitle;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @recentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivityTitle;

  /// No description provided for @profileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile completion'**
  String get profileCompletion;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get navJobs;

  /// No description provided for @navResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get navResume;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get navLogout;

  /// No description provided for @jobsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobsPageTitle;

  /// No description provided for @jobsAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 job for you} other{{count} jobs for you}}'**
  String jobsAvailableCount(int count);

  /// No description provided for @jobsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Role, company or location'**
  String get jobsSearchHint;

  /// No description provided for @jobsSearchClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get jobsSearchClearTooltip;

  /// No description provided for @jobsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No jobs found'**
  String get jobsEmptyTitle;

  /// No description provided for @jobsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting the search or filters.'**
  String get jobsEmptySubtitle;

  /// No description provided for @jobsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load jobs.'**
  String get jobsErrorTitle;

  /// No description provided for @jobsRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get jobsRetryButton;

  /// No description provided for @jobApplySuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Application sent to {company}!'**
  String jobApplySuccessMessage(String company);

  /// No description provided for @jobApplyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your application.'**
  String get jobApplyErrorMessage;

  /// No description provided for @jobRemoveSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get jobRemoveSaved;

  /// No description provided for @jobSaveJob.
  ///
  /// In en, this message translates to:
  /// **'Save job'**
  String get jobSaveJob;

  /// No description provided for @jobSalaryRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Salary range'**
  String get jobSalaryRangeLabel;

  /// No description provided for @jobPublishedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Published {time}'**
  String jobPublishedPrefix(String time);

  /// No description provided for @jobAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About the job'**
  String get jobAboutTitle;

  /// No description provided for @jobRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get jobRequirementsTitle;

  /// No description provided for @jobApplyButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get jobApplyButtonLabel;

  /// No description provided for @jobAppliedLabel.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get jobAppliedLabel;

  /// No description provided for @timeAgoNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get timeAgoNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} min ago} other{{count} min ago}}'**
  String timeAgoMinutes(int count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 hour ago} other{{count} hours ago}}'**
  String timeAgoHours(int count);

  /// No description provided for @timeAgoYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get timeAgoYesterday;

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day ago} other{{count} days ago}}'**
  String timeAgoDays(int count);

  /// No description provided for @timeAgoMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 month ago} other{{count} months ago}}'**
  String timeAgoMonths(int count);
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
