import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class PublishJobUsecase {
  final CompanyRepository _repository;

  PublishJobUsecase(this._repository);

  Future<JobEntity> call(JobEntity job) {
    return _repository.publishJob(job);
  }
}
