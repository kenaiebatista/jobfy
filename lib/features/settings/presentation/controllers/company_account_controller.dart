import 'package:flutter/foundation.dart';
import 'package:jobfy/core/network/api_exception.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/usecases/change_company_password_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/delete_company_account_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/get_company_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/update_company_usecase.dart';
import 'package:jobfy/features/settings/presentation/controllers/account_settings_controller.dart';

/// The signed-in company's data, password and account, from the settings
/// screen. Results are codes (the user's [SaveProfileResult] and
/// [ChangePasswordResult]) so the page can show translated messages.
class CompanyAccountController extends ChangeNotifier {
  final GetCompanyUsecase _getCompany;
  final UpdateCompanyUsecase _updateCompany;
  final ChangeCompanyPasswordUsecase _changePassword;
  final DeleteCompanyAccountUsecase _deleteAccount;

  CompanyAccountController(
    this._getCompany,
    this._updateCompany,
    this._changePassword,
    this._deleteAccount,
  );

  CompanyEntity? _company;
  bool _loadFailed = false;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  bool _isDeleting = false;

  CompanyEntity? get company => _company;
  bool get loadFailed => _loadFailed;
  bool get isSaving => _isSaving;
  bool get isChangingPassword => _isChangingPassword;
  bool get isDeleting => _isDeleting;

  Future<void> load(String companyId) async {
    _loadFailed = false;
    try {
      _company = await _getCompany(companyId);
    } catch (e) {
      debugPrint('Could not load company $companyId: $e');
      _loadFailed = true;
    }
    notifyListeners();
  }

  Future<SaveProfileResult> save(CompanyEntity updated) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _updateCompany(updated);
      _company = updated;
      return SaveProfileResult.saved;
    } on ApiStatusException catch (e) {
      return e.statusCode == 409 ? SaveProfileResult.emailInUse : SaveProfileResult.failed;
    } catch (e) {
      debugPrint('Could not save company: $e');
      return SaveProfileResult.failed;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<ChangePasswordResult> changePassword({
    required String companyId,
    required String currentPassword,
    required String newPassword,
  }) async {
    _isChangingPassword = true;
    notifyListeners();
    try {
      final changed = await _changePassword(companyId, currentPassword, newPassword);
      return changed ? ChangePasswordResult.changed : ChangePasswordResult.wrongPassword;
    } catch (e) {
      debugPrint('Could not change the company password: $e');
      return ChangePasswordResult.failed;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  /// Returns false when the account could not be closed.
  Future<bool> deleteAccount(String companyId) async {
    _isDeleting = true;
    notifyListeners();
    try {
      await _deleteAccount(companyId);
      return true;
    } catch (e) {
      debugPrint('Could not delete the company account: $e');
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
