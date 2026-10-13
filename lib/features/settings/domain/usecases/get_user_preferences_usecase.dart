import '../entities/user_preferences_entity.dart';
import '../repositories/settings_repository.dart';

class GetUserPreferencesUsecase {
  final SettingsRepository _repository;

  GetUserPreferencesUsecase(this._repository);

  Future<UserPreferencesEntity> call() {
    return _repository.getPreferences();
  }
}
