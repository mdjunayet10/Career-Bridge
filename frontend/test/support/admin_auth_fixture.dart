import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/core/errors/auth_failure.dart';
import 'package:career_bridge/features/auth/data/models/app_user_model.dart';
import 'package:career_bridge/features/auth/data/repositories/demo_auth_repository.dart';

// An explicit test-only administrator; no corresponding shipped demo account.
class AdminAuthFixture extends DemoAuthRepository {
  AppUserModel? _adminSession;
  @override
  Future<AppUserModel> signIn(
      {required String email, required String password}) async {
    if (email != 'admin@tests.invalid' || password != 'TestOnly123!') {
      throw const AuthFailure('Invalid test credentials');
    }
    return _adminSession = AppUserModel(
        uid: 'test-admin',
        name: 'Test Administrator',
        email: email,
        role: UserRole.admin,
        isActive: true,
        createdAt: DateTime(2026));
  }

  @override
  Future<AppUserModel?> restoreSession() async => _adminSession;
  @override
  Future<void> signOut() async => _adminSession = null;
}
