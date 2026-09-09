import 'package:flutter/foundation.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/usecases/rate_candidate_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/register_company_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/filter_candidates_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/send_message_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/publish_job_usecase.dart';

enum CompanyStatus { idle, loading, loaded, error }

class CompanyController extends ChangeNotifier {
  final RegisterCompanyUsecase _registerCompanyUsecase;
  final PublishJobUsecase _publishJobUsecase;
  final FilterCandidatesUsecase _filterCandidatesUsecase;
  final RateCandidateUsecase _rateCandidateUsecase;
  final SendMessageUsecase _sendMessageUsecase;

  CompanyController({
    required RegisterCompanyUsecase registerCompanyUsecase,
    required PublishJobUsecase publishJobUsecase,
    required FilterCandidatesUsecase filterCandidatesUsecase,
    required RateCandidateUsecase rateCandidateUsecase,
    required SendMessageUsecase sendMessageUsecase,
  })  : _registerCompanyUsecase = registerCompanyUsecase,
        _publishJobUsecase = publishJobUsecase,
        _filterCandidatesUsecase = filterCandidatesUsecase,
        _rateCandidateUsecase = rateCandidateUsecase,
        _sendMessageUsecase = sendMessageUsecase;

  CompanyStatus _status = CompanyStatus.idle;
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

  Future<void> registerCompany(CompanyEntity data) async {
    _status = CompanyStatus.loading;
    notifyListeners();
    try {
      _company = await _registerCompanyUsecase(data);
      _status = CompanyStatus.loaded;
    } catch (_) {
      _error = 'companyRegisterError';
      _status = CompanyStatus.error;
    }
    notifyListeners();
  }

  Future<void> publishJob(JobEntity job) async {
    try {
      final created = await _publishJobUsecase(job);
      _jobs.add(created);
    } catch (_) {
      _error = 'jobPublishError';
    }
    notifyListeners();
  }

  Future<void> filterCandidates(
    String jobId, {
    String? roleFilter,
    int? minMatch,
  }) async {
    try {
      _candidates = await _filterCandidatesUsecase(
        jobId,
        roleFilter: roleFilter,
        minMatch: minMatch,
      );
    } catch (_) {
      _error = 'candidateFilterError';
    }
    notifyListeners();
  }

  Future<void> rateCandidate(String candidateId, double rating, {String? comment}) async {
    try {
      await _rateCandidateUsecase(candidateId, rating, comment: comment);
    } catch (_) {
      _error = 'candidateRateError';
    }
    notifyListeners();
  }

  Future<void> sendMessage(String candidateId, String message) async {
    try {
      await _sendMessageUsecase(candidateId, message);
    } catch (_) {
      _error = 'messageSendError';
    }
    notifyListeners();
  }
}
