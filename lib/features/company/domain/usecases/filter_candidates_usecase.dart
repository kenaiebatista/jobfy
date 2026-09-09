import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class FilterCandidatesUsecase {
  final CompanyRepository _repository;

  FilterCandidatesUsecase(this._repository);

  Future<List<CandidateEntity>> call(
    String jobId, {
    String? roleFilter,
    int? minMatch,
  }) {
    return _repository.filterCandidates(
      jobId,
      roleFilter: roleFilter,
      minMatch: minMatch,
    );
  }
}
