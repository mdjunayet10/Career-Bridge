import '../../../../core/enums/employer_verification_status.dart';
import '../demo_account_catalog.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/auth_failure.dart';
import '../models/app_user_model.dart';
import 'auth_repository.dart';

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository() {
    _seedUsers();
  }

  final Map<String, _DemoAccount> _accounts = {};
  AppUserModel? _session;

  void _seedUsers() {
    for (final account in DemoAccountCatalog.accounts) {
      _add(account.user, DemoAccountCatalog.password);
    }
  }

  void _add(AppUserModel user, String password) {
    _accounts[user.email.toLowerCase()] = _DemoAccount(user, password);
  }

  Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 480));

  @override
  Future<AppUserModel?> restoreSession() async => _session;

  @override
  Future<AppUserModel> signIn(
      {required String email, required String password}) async {
    await _wait();
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthFailure(
        'Email or password is incorrect. Check the demo credentials and try again.',
        code: 'invalid-credential',
      );
    }
    if (!account.user.isActive) {
      throw const AuthFailure('This account has been suspended.',
          code: 'user-disabled');
    }
    _session = account.user;
    return account.user;
  }

  @override
  Future<GoogleAuthResult> signInWithGoogle({
    required UserRole expectedRole,
  }) async {
    throw const AuthFailure(
      'Google sign-in is available only when Career Bridge is running with Firebase.',
      code: 'google-sign-in-unavailable',
    );
  }

  @override
  Future<AppUserModel> registerJobSeeker(JobSeekerRegistrationData data) async {
    await _wait();
    _ensureEmailAvailable(data.email);
    final user = AppUserModel(
      uid: 'job-seeker-${DateTime.now().microsecondsSinceEpoch}',
      name: data.name.trim(),
      email: data.email.trim().toLowerCase(),
      role: UserRole.jobSeeker,
      isActive: true,
      createdAt: DateTime.now(),
    );
    _add(user, data.password);
    _session = user;
    return user;
  }

  @override
  Future<AppUserModel> registerEmployer(EmployerRegistrationData data) async {
    await _wait();
    _ensureEmailAvailable(data.email);
    final user = AppUserModel(
      uid: 'employer-${DateTime.now().microsecondsSinceEpoch}',
      name: data.contactName.trim(),
      email: data.email.trim().toLowerCase(),
      role: UserRole.employer,
      isActive: true,
      companyName: data.companyName.trim(),
      verificationStatus: EmployerVerificationStatus.pending,
      createdAt: DateTime.now(),
    );
    _add(user, data.password);
    _session = user;
    return user;
  }

  @override
  Future<AppUserModel> registerGoogleEmployer(
    GoogleEmployerRegistrationData data,
  ) async {
    throw const AuthFailure(
      'Google employer registration is available only in Firebase mode.',
      code: 'google-sign-in-unavailable',
    );
  }

  void _ensureEmailAvailable(String email) {
    if (_accounts.containsKey(email.trim().toLowerCase())) {
      throw const AuthFailure(
        'An account already exists with this email address.',
        code: 'email-already-in-use',
      );
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _wait();
    if (!_accounts.containsKey(email.trim().toLowerCase())) {
      throw const AuthFailure(
        'No account was found for that email address.',
        code: 'user-not-found',
      );
    }
  }

  @override
  Future<void> signOut() async {
    _session = null;
  }
}

class _DemoAccount {
  const _DemoAccount(this.user, this.password);

  final AppUserModel user;
  final String password;
}
