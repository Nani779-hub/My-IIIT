import '../models/app_user.dart';
import 'fake_db.dart';

class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String identifier, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final id = identifier.trim().toLowerCase();
    final pwd = password.trim();

    AppUser? found;

    for (final u in FakeDb.users) {
      final role = u.role;

      // 🔴 FIXED HERE: we only have rollNo now, no rollNumber
      final userRoll = (u.rollNo ?? '').toLowerCase();
      final dept = u.department.toLowerCase();
      final userPwd = u.password;

      if (userPwd != pwd) continue;

      if (role == UserRole.student) {
        if (userRoll == id) {
          found = u;
          break;
        }
      } else {
        if (userRoll == id || dept == id) {
          found = u;
          break;
        }
      }
    }

    if (found != null) {
      _currentUser = found;
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }
}

