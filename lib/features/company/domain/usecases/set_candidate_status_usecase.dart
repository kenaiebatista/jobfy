import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class SetCandidateStatusUsecase {
  final CompanyRepository _repository;

  SetCandidateStatusUsecase(this._repository);

  Future<void> call(String companyId, String jobId, String userId, ApplicationStatus status) => _repository.setCandidateStatus(companyId, jobId, userId, status);
}
