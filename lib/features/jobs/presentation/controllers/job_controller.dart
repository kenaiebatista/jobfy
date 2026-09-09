import 'package:flutter/foundation.dart';
import '../../domain/entities/job_listing_entity.dart';
import '../../domain/usecases/apply_to_job_usecase.dart';
import '../../domain/usecases/search_jobs_usecase.dart';

enum JobListStatus { idle, loading, loaded, error }

class JobController extends ChangeNotifier {
  final SearchJobsUsecase _searchJobsUsecase;
  final ApplyToJobUsecase _applyToJobUsecase;

  JobController(this._searchJobsUsecase, this._applyToJobUsecase);

  JobListStatus _status = JobListStatus.idle;
  List<JobListingEntity> _jobs = [];
  String? _error;
  final Set<String> _appliedJobIds = {};

  JobListStatus get status => _status;
  List<JobListingEntity> get jobs => List.unmodifiable(_jobs);
  String? get error => _error;
  bool get isLoading => _status == JobListStatus.loading;
  bool hasApplied(String jobId) => _appliedJobIds.contains(jobId);

  Future<void> search({String? query, String? location}) async {
    _status = JobListStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _jobs = await _searchJobsUsecase(query: query, location: location);
      _status = JobListStatus.loaded;
    } catch (_) {
      _error = 'jobSearchError';
      _status = JobListStatus.error;
    }
    notifyListeners();
  }

  Future<bool> apply(String jobId) async {
    try {
      await _applyToJobUsecase(jobId);
      _appliedJobIds.add(jobId);
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'jobApplyError';
      notifyListeners();
      return false;
    }
  }
}
