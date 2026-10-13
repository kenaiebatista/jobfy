/// Work arrangements the user can pick in the job preferences card.
enum JobPreferenceType { remote, hybrid, onsite }

/// Settings that have no column in the database yet, so they are kept on
/// the device (see SettingsRepositoryImpl).
class UserPreferencesEntity {
  // Notifications
  final bool newJobAlerts;
  final bool messageAlerts;
  final bool weeklyEmailSummary;
  final bool pushNotifications;

  // Privacy
  final bool profileVisibleToCompanies;
  final bool showEmailOnProfile;

  // Job preferences
  final Set<JobPreferenceType> jobTypes;

  const UserPreferencesEntity({
    this.newJobAlerts = true,
    this.messageAlerts = true,
    this.weeklyEmailSummary = false,
    this.pushNotifications = true,
    this.profileVisibleToCompanies = true,
    this.showEmailOnProfile = false,
    this.jobTypes = const {JobPreferenceType.remote},
  });

  UserPreferencesEntity copyWith({
    bool? newJobAlerts,
    bool? messageAlerts,
    bool? weeklyEmailSummary,
    bool? pushNotifications,
    bool? profileVisibleToCompanies,
    bool? showEmailOnProfile,
    Set<JobPreferenceType>? jobTypes,
  }) {
    return UserPreferencesEntity(
      newJobAlerts: newJobAlerts ?? this.newJobAlerts,
      messageAlerts: messageAlerts ?? this.messageAlerts,
      weeklyEmailSummary: weeklyEmailSummary ?? this.weeklyEmailSummary,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      profileVisibleToCompanies:
          profileVisibleToCompanies ?? this.profileVisibleToCompanies,
      showEmailOnProfile: showEmailOnProfile ?? this.showEmailOnProfile,
      jobTypes: jobTypes ?? this.jobTypes,
    );
  }
}
