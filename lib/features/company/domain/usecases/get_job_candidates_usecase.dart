import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class GetJobCandidatesUsecase {
  final CompanyRepository _repository;

  GetJobCandidatesUsecase(this._repository);

  Future<List<CandidateEntity>> call(String jobId) => _repository.getJobCandidates(jobId);
}
