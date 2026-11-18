import '../repositories/user_repository.dart';

class DeleteExperienceUsecase {
  final UserRepository _repository;

  DeleteExperienceUsecase(this._repository);

  Future<void> call(String userId, String experienceId) => _repository.deleteExperience(userId, experienceId);
}
