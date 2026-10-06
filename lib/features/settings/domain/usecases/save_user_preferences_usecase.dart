import '../entities/user_preferences_entity.dart';
import '../repositories/settings_repository.dart';

class SaveUserPreferencesUsecase {
  final SettingsRepository _repository;

  SaveUserPreferencesUsecase(this._repository);

  Future<void> call(UserPreferencesEntity preferences) {
    return _repository.savePreferences(preferences);
  }
}
