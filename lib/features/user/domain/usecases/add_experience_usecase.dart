import '../entities/user_profile_entity.dart';
import '../repositories/user_repository.dart';

class AddExperienceUsecase {
  final UserRepository _repository;

  AddExperienceUsecase(this._repository);

  Future<void> call(String userId, ExperienceEntity experience) => _repository.addExperience(userId, experience);
}
