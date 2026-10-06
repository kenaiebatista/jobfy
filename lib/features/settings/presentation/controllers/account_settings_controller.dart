import 'package:flutter/foundation.dart';
import 'package:jobfy/core/database/database_service.dart';
import 'package:jobfy/features/settings/domain/entities/user_preferences_entity.dart';
import 'package:jobfy/features/settings/domain/usecases/get_user_preferences_usecase.dart';
import 'package:jobfy/features/settings/domain/usecases/save_user_preferences_usecase.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/domain/usecases/change_password_usecase.dart';
import 'package:jobfy/features/user/domain/usecases/delete_account_usecase.dart';
import 'package:jobfy/features/user/domain/usecases/update_user_profile_usecase.dart';

enum SaveProfileResult { saved, emailInUse, failed }

enum ChangePasswordResult { changed, wrongPassword, failed }

/// State of the settings page beyond theme/language (those live in the
/// app-wide SettingsController): the device-only preference toggles and the
/// account actions that go to the database. Results come back as codes so
/// the page can show translated messages.
class AccountSettingsController extends ChangeNotifier {
  final GetUserPreferencesUsecase _getPreferences;
  final SaveUserPreferencesUsecase _savePreferences;
  final UpdateUserProfileUsecase _updateProfile;
  final ChangePasswordUsecase _changePassword;
  final DeleteAccountUsecase _deleteAccount;

  AccountSettingsController(
    this._getPreferences,
    this._savePreferences,
    this._updateProfile,
    this._changePassword,
    this._deleteAccount,
  );

  UserPreferencesEntity _preferences = const UserPreferencesEntity();
  bool _isSavingProfile = false;
  bool _isChangingPassword = false;
  bool _isDeleting = false;

  UserPreferencesEntity get preferences => _preferences;
  bool get isSavingProfile => _isSavingProfile;
  bool get isChangingPassword => _isChangingPassword;
  bool get isDeleting => _isDeleting;

  Future<void> loadPreferences() async {
    try {
      _preferences = await _getPreferences();
    } catch (e) {
      debugPrint('Could not load preferences: $e');
    }
    notifyListeners();
  }

  Future<void> _update(UserPreferencesEntity updated) async {
    _preferences = updated;
    notifyListeners();
    try {
      await _savePreferences(updated);
    } catch (e) {
      debugPrint('Could not save preferences: $e');
    }
  }

  void setNewJobAlerts(bool value) =>
      _update(_preferences.copyWith(newJobAlerts: value));

  void setMessageAlerts(bool value) =>
      _update(_preferences.copyWith(messageAlerts: value));

  void setWeeklyEmailSummary(bool value) =>
      _update(_preferences.copyWith(weeklyEmailSummary: value));

  void setPushNotifications(bool value) =>
      _update(_preferences.copyWith(pushNotifications: value));

  void setProfileVisibleToCompanies(bool value) =>
      _update(_preferences.copyWith(profileVisibleToCompanies: value));

  void setShowEmailOnProfile(bool value) =>
      _update(_preferences.copyWith(showEmailOnProfile: value));

  void toggleJobType(JobPreferenceType type) {
    final types = Set<JobPreferenceType>.of(_preferences.jobTypes);
    if (!types.remove(type)) types.add(type);
    _update(_preferences.copyWith(jobTypes: types));
  }

  Future<SaveProfileResult> saveProfile(
    UserProfileEntity current, {
    required String name,
    required String email,
    required String phone,
  }) async {
    _isSavingProfile = true;
    notifyListeners();
    try {
      await _updateProfile(
        current.copyWith(name: name, email: email, phone: phone),
      );
      return SaveProfileResult.saved;
    } on EmailAlreadyInUseException {
      return SaveProfileResult.emailInUse;
    } catch (e) {
      debugPrint('Could not save profile: $e');
      return SaveProfileResult.failed;
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
  }

  Future<ChangePasswordResult> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    _isChangingPassword = true;
    notifyListeners();
    try {
      final changed = await _changePassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return changed
          ? ChangePasswordResult.changed
          : ChangePasswordResult.wrongPassword;
    } catch (e) {
      debugPrint('Could not change password: $e');
      return ChangePasswordResult.failed;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  /// Returns false when the account could not be closed.
  Future<bool> deleteAccount(String userId) async {
    _isDeleting = true;
    notifyListeners();
    try {
      await _deleteAccount(userId);
      return true;
    } catch (e) {
      debugPrint('Could not delete account: $e');
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
