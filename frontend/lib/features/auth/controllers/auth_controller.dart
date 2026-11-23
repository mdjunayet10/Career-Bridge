import '../../demo/data/demo_application_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../app/config/app_environment.dart';
import '../../../core/services/mobile_push_service.dart';
import '../../public_portal/controllers/public_portal_controller.dart';
import '../../../app/config/firebase_runtime_options.dart';
import '../../../app/router/app_routes.dart';
import '../../../core/enums/employer_verification_status.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/errors/auth_failure.dart';
import '../data/models/app_user_model.dart';
import '../data/demo_account_catalog.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/demo_auth_repository.dart';
import '../data/repositories/firebase_auth_repository.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

class AuthController extends ChangeNotifier {
  AuthController._();

  static final AuthController instance = AuthController._();

  AuthRepository _repository = DemoAuthRepository();
  AppUserModel? _currentUser;
  AuthStatus _status = AuthStatus.unauthenticated;
  bool _usesFirebase = false;
  AuthRepository? _liveRepository;
  bool get isDemoSession => _liveRepository != null;
  String? _initializationNotice;

  AppUserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  bool get isAuthenticated => _currentUser != null;
  bool get usesFirebase => _usesFirebase;
  String? get initializationNotice => _initializationNotice;

  Future<void> initialize() async {
    _initializationNotice = null;
    _liveRepository = null;
    _repository = DemoAuthRepository();
    _usesFirebase = false;

    if (AppEnvironment.useFirebase) {
      try {
        await Firebase.initializeApp(
          options: FirebaseRuntimeOptions.currentPlatform,
        );
        _repository = FirebaseAuthRepository();
        _usesFirebase = true;
      } catch (error) {
        if (!AppEnvironment.allowDemoFallback) rethrow;
        _repository = DemoAuthRepository();
        _usesFirebase = false;
        _initializationNotice =
            'Firebase could not start, so Career Bridge switched to demo mode. '
            'Check frontend/config/firebase.local.json before a production run.';
      }
    }

    try {
      _currentUser = await _repository
          .restoreSession()
          .timeout(const Duration(seconds: 12));
      _status = _currentUser == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    } catch (_) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<AppUserModel> signIn({
    required String email,
    required String password,
    UserRole? expectedRole,
  }) async {
    _setStatus(AuthStatus.authenticating);
    try {
      if (_usesFirebase &&
          AppEnvironment.showDemoAccess &&
          DemoAccountCatalog.byEmail(email) != null) {
        final demo = DemoAuthRepository();
        final user = await demo.signIn(email: email, password: password);
        if (expectedRole != null && user.role != expectedRole) {
          throw const AuthFailure(
              'Choose the matching portal for this demo account.',
              code: 'role-mismatch');
        }
        _liveRepository = _repository;
        _repository = demo;
        _usesFirebase = false;
        _currentUser = user;
        try {
          await PublicPortalController.instance.refresh();
        } catch (_) {
          _repository = _liveRepository!;
          _liveRepository = null;
          _usesFirebase = true;
          rethrow;
        }
        _setStatus(AuthStatus.authenticated);
        return user;
      }
      final user = await _repository.signIn(email: email, password: password);
      if (expectedRole != null && user.role != expectedRole) {
        await _repository.signOut();
        throw AuthFailure(
          'This account belongs to the ${user.role.label} portal, not the ${expectedRole.label} portal.',
          code: 'role-mismatch',
        );
      }
      if (!user.isActive) {
        await _repository.signOut();
        throw const AuthFailure('This account has been suspended.',
            code: 'user-disabled');
      }
      _currentUser = user;
      _setStatus(AuthStatus.authenticated);
      if (PublicPortalController.instance.isGuestDemoPreview) {
        try {
          await PublicPortalController.instance.setGuestDemoPreview(false);
        } catch (_) {
          // A failed public refresh must not discard a valid live login.
        }
      }
      return user;
    } catch (_) {
      _currentUser = null;
      _setStatus(AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<GoogleAuthResult> signInWithGoogle({
    required UserRole expectedRole,
  }) async {
    _setStatus(AuthStatus.authenticating);
    try {
      final result = await _repository.signInWithGoogle(
        expectedRole: expectedRole,
      );
      final user = result.user;

      if (user == null) {
        _currentUser = null;
        _setStatus(AuthStatus.unauthenticated);
        return result;
      }

      if (user.role != expectedRole) {
        await _repository.signOut();
        throw AuthFailure(
          'This Google account belongs to the ${user.role.label} portal, not the ${expectedRole.label} portal.',
          code: 'role-mismatch',
        );
      }
      if (!user.isActive) {
        await _repository.signOut();
        throw const AuthFailure(
          'This account has been suspended.',
          code: 'user-disabled',
        );
      }

      _currentUser = user;
      _setStatus(AuthStatus.authenticated);
      return result;
    } catch (_) {
      _currentUser = null;
      _setStatus(AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<AppUserModel> registerJobSeeker(JobSeekerRegistrationData data) async {
    _setStatus(AuthStatus.authenticating);
    try {
      final user = await _repository.registerJobSeeker(data);
      _currentUser = user;
      _setStatus(AuthStatus.authenticated);
      return user;
    } catch (_) {
      _setStatus(AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<AppUserModel> registerEmployer(EmployerRegistrationData data) async {
    _setStatus(AuthStatus.authenticating);
    try {
      final user = await _repository.registerEmployer(data);
      _currentUser = user;
      _setStatus(AuthStatus.authenticated);
      return user;
    } catch (_) {
      _setStatus(AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<AppUserModel> registerGoogleEmployer(
    GoogleEmployerRegistrationData data,
  ) async {
    _setStatus(AuthStatus.authenticating);
    try {
      final user = await _repository.registerGoogleEmployer(data);
      _currentUser = user;
      _setStatus(AuthStatus.authenticated);
      return user;
    } catch (_) {
      _currentUser = null;
      _setStatus(AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) =>
      _repository.sendPasswordReset(email);

  Future<void> signOut() async {
    await MobilePushService.instance.beforeSignOut();
    await _repository.signOut();
    _currentUser = null;
    if (_liveRepository != null) {
      _repository = _liveRepository!;
      _liveRepository = null;
      _usesFirebase = true;
      try {
        await PublicPortalController.instance.refresh();
      } catch (_) {
        // Returning to real login remains possible when the network is offline.
      }
    }
    _setStatus(AuthStatus.unauthenticated);
  }

  String homeRouteFor(AppUserModel user) => switch (user.role) {
        UserRole.jobSeeker => AppRoutes.jobSeekerDashboard,
        UserRole.employer =>
          user.verificationStatus == EmployerVerificationStatus.approved
              ? AppRoutes.employerDashboard
              : AppRoutes.employerVerificationPending,
        UserRole.admin => AppRoutes.adminDashboard,
      };

  bool canAccess(UserRole role) =>
      _currentUser != null &&
      _currentUser!.isActive &&
      _currentUser!.role == role;

  void _setStatus(AuthStatus value) {
    _status = value;
    notifyListeners();
  }

  @visibleForTesting
  Future<void> resetForTesting(
      {AuthRepository? repository, bool usesFirebase = false}) async {
    DemoApplicationStore.instance.clear();
    _repository = repository ?? DemoAuthRepository();
    _liveRepository = null;
    _usesFirebase = usesFirebase;
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _initializationNotice = null;
    notifyListeners();
  }
}
