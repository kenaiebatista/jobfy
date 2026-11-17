import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class SetJobStatusUsecase {
  final CompanyRepository _repository;

  SetJobStatusUsecase(this._repository);

  Future<void> call(String companyId, String jobId, JobStatus status) => _repository.setJobStatus(companyId, jobId, status);
}
