import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/repositories/settings_repository.dart';

/// Keeps the notification, privacy and job preference toggles on the device
/// (shared_preferences), since the database has no columns for them yet.
class SettingsRepositoryImpl implements SettingsRepository {
  static const _newJobAlerts = 'settings.new_job_alerts';
  static const _messageAlerts = 'settings.message_alerts';
  static const _weeklyEmailSummary = 'settings.weekly_email_summary';
  static const _pushNotifications = 'settings.push_notifications';
  static const _profileVisible = 'settings.profile_visible';
  static const _showEmail = 'settings.show_email';
  static const _jobTypes = 'settings.job_types';

  @override
  Future<UserPreferencesEntity> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = UserPreferencesEntity();

    final jobTypes = prefs.getStringList(_jobTypes);

    return UserPreferencesEntity(
      newJobAlerts: prefs.getBool(_newJobAlerts) ?? defaults.newJobAlerts,
      messageAlerts: prefs.getBool(_messageAlerts) ?? defaults.messageAlerts,
      weeklyEmailSummary:
          prefs.getBool(_weeklyEmailSummary) ?? defaults.weeklyEmailSummary,
      pushNotifications:
          prefs.getBool(_pushNotifications) ?? defaults.pushNotifications,
      profileVisibleToCompanies:
          prefs.getBool(_profileVisible) ?? defaults.profileVisibleToCompanies,
      showEmailOnProfile: prefs.getBool(_showEmail) ?? defaults.showEmailOnProfile,
      jobTypes: jobTypes == null
          ? defaults.jobTypes
          : JobPreferenceType.values.where((t) => jobTypes.contains(t.name)).toSet(),
    );
  }

  @override
  Future<void> savePreferences(UserPreferencesEntity p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_newJobAlerts, p.newJobAlerts);
    await prefs.setBool(_messageAlerts, p.messageAlerts);
    await prefs.setBool(_weeklyEmailSummary, p.weeklyEmailSummary);
    await prefs.setBool(_pushNotifications, p.pushNotifications);
    await prefs.setBool(_profileVisible, p.profileVisibleToCompanies);
    await prefs.setBool(_showEmail, p.showEmailOnProfile);
    await prefs.setStringList(_jobTypes, p.jobTypes.map((t) => t.name).toList());
  }
}
