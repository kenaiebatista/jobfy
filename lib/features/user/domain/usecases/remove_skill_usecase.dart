import '../repositories/user_repository.dart';

class RemoveSkillUsecase {
  final UserRepository _repository;

  RemoveSkillUsecase(this._repository);

  Future<void> call(String userId, String name) => _repository.removeSkill(userId, name);
}
