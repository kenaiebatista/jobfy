import '../repositories/auth_repository.dart';

class GetSkillNamesUsecase {
  final AuthRepository _repository;

  GetSkillNamesUsecase(this._repository);

  Future<List<String>> call() => _repository.getSkillNames();
}
