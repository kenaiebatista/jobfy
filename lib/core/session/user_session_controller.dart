import 'package:flutter/foundation.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';

enum UserSessionStatus { idle, loading, loaded, error }

/// Holds the signed-in user's profile so every screen that needs it — the
/// dashboard, and anywhere the persistent sidebar appears — shares one
/// fetch instead of each page reloading it independently.
class UserSessionController extends ChangeNotifier {
  final GetUserProfileUsecase _getUserProfileUsecase;

  UserSessionController(this._getUserProfileUsecase);

  UserSessionStatus _status = UserSessionStatus.idle;
  UserProfileEntity? _profile;

  UserSessionStatus get status => _status;
  UserProfileEntity? get profile => _profile;
  bool get isLoading => _status == UserSessionStatus.loading;

  /// Loads the profile unless it's already loaded or loading. Safe to call
  /// from every screen's initState: the actual load (and its first
  /// notifyListeners) is deferred to a microtask so it never fires while
  /// the caller's widget is still building.
  Future<void> ensureLoaded(String userId) {
    if (_status == UserSessionStatus.loading || _status == UserSessionStatus.loaded) {
      return Future.value();
    }
    return Future.microtask(() => _load(userId));
  }

  Future<void> reload(String userId) => _load(userId);

  void clear() {
    _profile = null;
    _status = UserSessionStatus.idle;
    notifyListeners();
  }

  Future<void> _load(String userId) async {
    _status = UserSessionStatus.loading;
    notifyListeners();
    try {
      _profile = await _getUserProfileUsecase(userId);
      _status = UserSessionStatus.loaded;
    } catch (_) {
      _status = UserSessionStatus.error;
    }
    notifyListeners();
  }
}
