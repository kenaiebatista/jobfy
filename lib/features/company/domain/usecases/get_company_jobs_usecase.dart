import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class GetCompanyJobsUsecase {
  final CompanyRepository _repository;

  GetCompanyJobsUsecase(this._repository);

  Future<List<JobEntity>> call(String companyId) => _repository.getCompanyJobs(companyId);
}
