import '../entities/user_preferences_entity.dart';

abstract class SettingsRepository {
  Future<UserPreferencesEntity> getPreferences();
  Future<void> savePreferences(UserPreferencesEntity preferences);
}
