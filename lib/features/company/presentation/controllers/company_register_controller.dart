import 'package:flutter/foundation.dart';
import 'package:jobfy/core/network/api_exception.dart';
import 'package:jobfy/features/company/data/datasources/brasil_api_cnpj_data_source.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/usecases/lookup_cnpj_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/register_company_usecase.dart';

/// Machine-readable errors; the page maps them to localized text.
enum CompanyRegisterError { cnpjNotFound, lookupFailed, emailInUse, cnpjInUse, network, failed }

/// State of the company sign-up form: the CNPJ lookup and the save.
class CompanyRegisterController extends ChangeNotifier {
  final LookupCnpjUsecase _lookupCnpj;
  final RegisterCompanyUsecase _registerCompany;

  CompanyRegisterController(this._lookupCnpj, this._registerCompany);

  bool _isLookingUp = false;
  bool _isSaving = false;
  CompanyRegisterError? _error;
  CnpjDataEntity? _lookupResult;

  bool get isLookingUp => _isLookingUp;
  bool get isSaving => _isSaving;
  CompanyRegisterError? get error => _error;

  /// Last successful lookup (to show its Receita Federal status).
  CnpjDataEntity? get lookupResult => _lookupResult;

  /// Fetches the company data for [cnpj] (14 digits). Returns null on error.
  Future<CnpjDataEntity?> lookup(String cnpj) async {
    _isLookingUp = true;
    _error = null;
    _lookupResult = null;
    notifyListeners();
    try {
      _lookupResult = await _lookupCnpj(cnpj);
    } on CnpjNotFoundException {
      _error = CompanyRegisterError.cnpjNotFound;
    } catch (e) {
      debugPrint('CNPJ lookup failed: $e');
      _error = CompanyRegisterError.lookupFailed;
    }
    _isLookingUp = false;
    notifyListeners();
    return _lookupResult;
  }

  /// Saves the company; returns it (with its id) or null on error.
  Future<CompanyEntity?> register(CompanyEntity company, String password) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    CompanyEntity? created;
    try {
      created = await _registerCompany(company, password);
    } on ApiStatusException catch (e) {
      // 409 = duplicate; the message says which unique field.
      _error = e.statusCode != 409
          ? CompanyRegisterError.failed
          : e.message == 'cnpj'
              ? CompanyRegisterError.cnpjInUse
              : CompanyRegisterError.emailInUse;
    } on ApiException {
      _error = CompanyRegisterError.network;
    } catch (e) {
      debugPrint('Company sign-up failed: $e');
      _error = CompanyRegisterError.failed;
    }
    _isSaving = false;
    notifyListeners();
    return created;
  }
}
