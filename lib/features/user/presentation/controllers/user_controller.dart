import 'package:flutter/foundation.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';

enum UserProfileStatus { idle, loading, loaded, error }

class UserController extends ChangeNotifier {
  final GetUserProfileUsecase _getProfileUsecase;

  UserController(this._getProfileUsecase);

  UserProfileStatus _status = UserProfileStatus.idle;
  UserProfileEntity? _profile;
  int _selectedNavIndex = 0;

  UserProfileStatus get status => _status;
  UserProfileEntity? get profile => _profile;
  int get selectedNavIndex => _selectedNavIndex;
  bool get isLoading => _status == UserProfileStatus.loading;

  Future<void> loadProfile(String userId) async {
    _status = UserProfileStatus.loading;
    notifyListeners();

    try {
      _profile = await _getProfileUsecase(userId);
      _status = UserProfileStatus.loaded;
    } catch (_) {
      _status = UserProfileStatus.error;
    }
    notifyListeners();
  }

  void selectNav(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }
}
