import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class UpdateJobUsecase {
  final CompanyRepository _repository;

  UpdateJobUsecase(this._repository);

  Future<void> call(String jobId, NewJobEntity job) => _repository.updateJob(jobId, job);
}
