import 'package:flutter/foundation.dart';
import '../../domain/entities/job_details_entity.dart';
import '../../domain/usecases/apply_to_job_usecase.dart';
import '../../domain/usecases/get_job_details_usecase.dart';

enum JobDetailsStatus { loading, loaded, notFound, error }

/// State of the job details screen: the job and the user's application.
class JobDetailsController extends ChangeNotifier {
  final GetJobDetailsUsecase _getJobDetailsUsecase;
  final ApplyToJobUsecase _applyToJobUsecase;

  JobDetailsController(this._getJobDetailsUsecase, this._applyToJobUsecase);

  JobDetailsStatus _status = JobDetailsStatus.loading;
  JobDetailsEntity? _job;
  bool _isApplying = false;

  JobDetailsStatus get status => _status;
  JobDetailsEntity? get job => _job;
  bool get isApplying => _isApplying;

  Future<void> load(String jobId, {String? userId}) async {
    _status = JobDetailsStatus.loading;
    notifyListeners();
    try {
      _job = await _getJobDetailsUsecase(jobId, userId: userId);
      _status = _job == null ? JobDetailsStatus.notFound : JobDetailsStatus.loaded;
    } catch (e) {
      debugPrint('Could not load job $jobId: $e');
      _status = JobDetailsStatus.error;
    }
    notifyListeners();
  }

  /// Sends [userId]'s application to the loaded job. Returns false on error.
  Future<bool> apply(String userId) async {
    final job = _job;
    if (job == null || job.hasApplied || !job.isOpen) return false;

    _isApplying = true;
    notifyListeners();
    var ok = true;
    try {
      await _applyToJobUsecase(job.id, userId);
      _job = job.copyWith(applicationStatus: 'under_review');
    } catch (e) {
      debugPrint('Could not apply to job ${job.id}: $e');
      ok = false;
    }
    _isApplying = false;
    notifyListeners();
    return ok;
  }
}
