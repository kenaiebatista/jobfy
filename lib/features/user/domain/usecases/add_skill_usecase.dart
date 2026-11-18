import '../entities/user_profile_entity.dart';
import '../repositories/user_repository.dart';

class AddSkillUsecase {
  final UserRepository _repository;

  AddSkillUsecase(this._repository);

  Future<void> call(String userId, String name, SkillLevel level) => _repository.addSkill(userId, name, level);
}
