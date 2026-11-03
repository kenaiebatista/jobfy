import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class PublishJobUsecase {
  final CompanyRepository _repository;

  PublishJobUsecase(this._repository);

  Future<void> call(NewJobEntity job) => _repository.publishJob(job);
}
