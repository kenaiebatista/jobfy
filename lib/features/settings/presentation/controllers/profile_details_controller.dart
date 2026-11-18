import 'package:flutter/foundation.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/domain/usecases/add_experience_usecase.dart';
import 'package:jobfy/features/user/domain/usecases/add_skill_usecase.dart';
import 'package:jobfy/features/user/domain/usecases/delete_experience_usecase.dart';
import 'package:jobfy/features/user/domain/usecases/remove_skill_usecase.dart';

/// Edits to the skills and experiences of the signed-in user, from the
/// settings screen. Each call returns false when it could not be saved; the
/// screen then reloads the profile and shows the result.
class ProfileDetailsController extends ChangeNotifier {
  final AddSkillUsecase _addSkill;
  final RemoveSkillUsecase _removeSkill;
  final AddExperienceUsecase _addExperience;
  final DeleteExperienceUsecase _deleteExperience;

  ProfileDetailsController(
    this._addSkill,
    this._removeSkill,
    this._addExperience,
    this._deleteExperience,
  );

  bool _isBusy = false;

  bool get isBusy => _isBusy;

  Future<bool> addSkill(String userId, String name, SkillLevel level) =>
      _run(() => _addSkill(userId, name, level));

  Future<bool> removeSkill(String userId, String name) =>
      _run(() => _removeSkill(userId, name));

  Future<bool> addExperience(String userId, ExperienceEntity experience) =>
      _run(() => _addExperience(userId, experience));

  Future<bool> deleteExperience(String userId, String experienceId) =>
      _run(() => _deleteExperience(userId, experienceId));

  Future<bool> _run(Future<void> Function() action) async {
    _isBusy = true;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      debugPrint('Could not save the profile change: $e');
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
