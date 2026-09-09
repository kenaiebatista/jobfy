import 'package:jobfy/features/company/domain/repositories/company_repository.dart';

class RateCandidateUsecase {
  final CompanyRepository _repository;

  RateCandidateUsecase(this._repository);

  Future<void> call(String candidateId, double rating, {String? comment}) {
    return _repository.rateCandidate(candidateId, rating, comment: comment);
  }
}
