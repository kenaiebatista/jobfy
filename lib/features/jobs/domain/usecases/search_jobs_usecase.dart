import '../entities/job_listing_entity.dart';
import '../repositories/job_repository.dart';

class SearchJobsUsecase {
  final JobRepository _repository;

  SearchJobsUsecase(this._repository);

  Future<List<JobListingEntity>> call({String? query, String? location}) {
    return _repository.searchJobs(query: query, location: location);
  }
}
