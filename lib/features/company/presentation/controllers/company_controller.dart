import 'package:flutter/foundation.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/usecases/get_company_jobs_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/get_company_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/get_job_candidates_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/publish_job_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/set_candidate_status_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/set_job_status_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/update_job_usecase.dart';

enum CompanyStatus { idle, loading, loaded, error }

/// State of the company dashboard: the signed-in company, its jobs and the
/// candidate tools.
class CompanyController extends ChangeNotifier {
  final GetCompanyUsecase _getCompanyUsecase;
  final GetCompanyJobsUsecase _getCompanyJobsUsecase;
  final PublishJobUsecase _publishJobUsecase;
  final UpdateJobUsecase _updateJobUsecase;
  final SetJobStatusUsecase _setJobStatusUsecase;
  final SetCandidateStatusUsecase _setCandidateStatusUsecase;
  final GetJobCandidatesUsecase _getJobCandidatesUsecase;

  CompanyController({
    required GetCompanyUsecase getCompanyUsecase,
    required GetCompanyJobsUsecase getCompanyJobsUsecase,
    required PublishJobUsecase publishJobUsecase,
    required UpdateJobUsecase updateJobUsecase,
    required SetJobStatusUsecase setJobStatusUsecase,
    required SetCandidateStatusUsecase setCandidateStatusUsecase,
    required GetJobCandidatesUsecase getJobCandidatesUsecase,
  })  : _getCompanyUsecase = getCompanyUsecase,
        _getCompanyJobsUsecase = getCompanyJobsUsecase,
        _publishJobUsecase = publishJobUsecase,
        _updateJobUsecase = updateJobUsecase,
        _setJobStatusUsecase = setJobStatusUsecase,
        _setCandidateStatusUsecase = setCandidateStatusUsecase,
        _getJobCandidatesUsecase = getJobCandidatesUsecase;

  CompanyStatus _status = CompanyStatus.idle;
  bool _isPublishing = false;
  bool _isLoadingCandidates = false;
  CompanyEntity? _company;
  final List<JobEntity> _jobs = [];
  List<CandidateEntity> _candidates = [];
  String? _error;

  CompanyStatus get status => _status;
  CompanyEntity? get company => _company;
  List<JobEntity> get jobs => List.unmodifiable(_jobs);
  List<CandidateEntity> get candidates => List.unmodifiable(_candidates);
  String? get error => _error;
  bool get isLoading => _status == CompanyStatus.loading;
  bool get isPublishing => _isPublishing;
  bool get isLoadingCandidates => _isLoadingCandidates;

  /// Loads the company profile and the jobs it already published.
  Future<void> load(String companyId) async {
    _status = CompanyStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _company = await _getCompanyUsecase(companyId);
      _jobs
        ..clear()
        ..addAll(await _getCompanyJobsUsecase(companyId));
      _status = CompanyStatus.loaded;
    } catch (e) {
      debugPrint('Could not load company $companyId: $e');
      _error = 'companyLoadError';
      _status = CompanyStatus.error;
    }
    notifyListeners();
  }

  /// Publishes the job and reloads the company's list. Returns false on error.
  Future<bool> publishJob(NewJobEntity job) async {
    _isPublishing = true;
    _error = null;
    notifyListeners();
    var ok = true;
    try {
      await _publishJobUsecase(job);
      _jobs
        ..clear()
        ..addAll(await _getCompanyJobsUsecase(job.companyId));
    } catch (e) {
      debugPrint('Could not publish job: $e');
      _error = 'companyJobPublishError';
      ok = false;
    }
    _isPublishing = false;
    notifyListeners();
    return ok;
  }

  /// Saves the edited job and reloads the company's list. Returns false on error.
  Future<bool> updateJob(String jobId, NewJobEntity job) async {
    return _saveJob(
      () => _updateJobUsecase(jobId, job),
      job.companyId,
      'companyJobUpdateError',
    );
  }

  /// Opens, pauses or closes the job and reloads the list. Returns false on error.
  Future<bool> setJobStatus(String jobId, JobStatus status) async {
    final companyId = _company?.companyId;
    if (companyId == null) return false;
    return _saveJob(
      () => _setJobStatusUsecase(companyId, jobId, status),
      companyId,
      'companyJobStatusError',
    );
  }

  Future<bool> _saveJob(Future<void> Function() save, String companyId, String errorCode) async {
    _isPublishing = true;
    _error = null;
    notifyListeners();
    var ok = true;
    try {
      await save();
      _jobs
        ..clear()
        ..addAll(await _getCompanyJobsUsecase(companyId));
    } catch (e) {
      debugPrint('Could not save job: $e');
      _error = errorCode;
      ok = false;
    }
    _isPublishing = false;
    notifyListeners();
    return ok;
  }

  /// Approves, rejects or puts back in review [candidate]'s application to
  /// [jobId]. Returns false on error.
  Future<bool> setCandidateStatus(
    String jobId,
    CandidateEntity candidate,
    ApplicationStatus status,
  ) async {
    final companyId = _company?.companyId;
    if (companyId == null) return false;
    try {
      await _setCandidateStatusUsecase(companyId, jobId, candidate.id, status);
      _candidates = [
        for (final c in _candidates)
          c.id == candidate.id ? c.copyWith(status: status.dbValue) : c,
      ];
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Could not answer candidate ${candidate.id}: $e');
      _error = 'companyCandidateStatusError';
      notifyListeners();
      return false;
    }
  }

  /// Loads who applied to [jobId].
  Future<void> loadCandidates(String jobId) async {
    _candidates = [];
    _isLoadingCandidates = true;
    _error = null;
    notifyListeners();
    try {
      _candidates = await _getJobCandidatesUsecase(jobId);
    } catch (e) {
      debugPrint('Could not load candidates of job $jobId: $e');
      _error = 'companyCandidateFilterError';
    }
    _isLoadingCandidates = false;
    notifyListeners();
  }
}
