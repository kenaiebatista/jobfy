import 'package:flutter/foundation.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';

enum UserSessionStatus { idle, loading, loaded, error }

/// Holds who is signed in and their profile, so every screen that needs it
/// (the dashboard, and anywhere the persistent sidebar appears) shares one
/// fetch instead of each page reloading it independently.
class UserSessionController extends ChangeNotifier {
  final GetUserProfileUsecase _getUserProfileUsecase;

  UserSessionController(this._getUserProfileUsecase);

  String? _userId;
  String? _companyId;
  UserSessionStatus _status = UserSessionStatus.idle;
  UserProfileEntity? _profile;

  /// The signed-in user's `users.user_id`, or null when nobody is signed in.
  String? get userId => _userId;
  bool get isSignedIn => _userId != null;

  /// The signed-in company's `companies.company_id`, or null.
  String? get companyId => _companyId;
  bool get isCompanySignedIn => _companyId != null;

  /// Called after a company signs in or registers. A company session has
  /// no user profile; the company dashboard loads its own data.
  void startCompany(String companyId) {
    _userId = null;
    _profile = null;
    _status = UserSessionStatus.idle;
    _companyId = companyId;
    notifyListeners();
  }
  UserSessionStatus get status => _status;
  UserProfileEntity? get profile => _profile;
  bool get isLoading => _status == UserSessionStatus.loading;

  /// Called after a successful login or sign-up. Drops any profile left
  /// over from a previous user; screens load the new one on demand.
  void start(String userId) {
    _companyId = null;
    _userId = userId;
    _profile = null;
    _status = UserSessionStatus.idle;
    notifyListeners();
  }

  /// Loads the signed-in user's profile unless it's already loaded or
  /// loading. Safe to call from every screen's initState: the actual load
  /// (and its first notifyListeners) is deferred to a microtask so it never
  /// fires while the caller's widget is still building.
  Future<void> ensureLoaded() {
    if (_status == UserSessionStatus.loading || _status == UserSessionStatus.loaded) {
      return Future.value();
    }
    return Future.microtask(_load);
  }

  Future<void> reload() => _load();

  /// Logs out: forgets the user and their profile.
  void clear() {
    _userId = null;
    _companyId = null;
    _profile = null;
    _status = UserSessionStatus.idle;
    notifyListeners();
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) {
      _status = UserSessionStatus.error;
      notifyListeners();
      return;
    }
    _status = UserSessionStatus.loading;
    notifyListeners();
    try {
      _profile = await _getUserProfileUsecase(userId);
      _status = UserSessionStatus.loaded;
    } catch (e) {
      debugPrint('Could not load profile for user $userId: $e');
      _status = UserSessionStatus.error;
    }
    notifyListeners();
  }
}
