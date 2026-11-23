import '../../../../core/enums/user_role.dart';
import '../models/app_user_model.dart';

class JobSeekerRegistrationData {
  const JobSeekerRegistrationData({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;
}

class EmployerRegistrationData {
  const EmployerRegistrationData({
    required this.contactName,
    required this.companyName,
    required this.industry,
    required this.companySize,
    required this.tradeLicenseNumber,
    required this.email,
    required this.password,
  });

  final String contactName;
  final String companyName;
  final String industry;
  final String companySize;
  final String tradeLicenseNumber;
  final String email;
  final String password;
}

class GoogleAccountDraft {
  const GoogleAccountDraft({
    required this.uid,
    required this.name,
    required this.email,
  });

  final String uid;
  final String name;
  final String email;
}

class GoogleEmployerRegistrationData {
  const GoogleEmployerRegistrationData({
    required this.uid,
    required this.contactName,
    required this.companyName,
    required this.industry,
    required this.companySize,
    required this.tradeLicenseNumber,
    required this.email,
  });

  final String uid;
  final String contactName;
  final String companyName;
  final String industry;
  final String companySize;
  final String tradeLicenseNumber;
  final String email;
}

class GoogleAuthResult {
  const GoogleAuthResult.authenticated(this.user)
      : pendingEmployerAccount = null;

  const GoogleAuthResult.requiresEmployerSetup(
    this.pendingEmployerAccount,
  ) : user = null;

  final AppUserModel? user;
  final GoogleAccountDraft? pendingEmployerAccount;

  bool get requiresEmployerSetup => pendingEmployerAccount != null;
}

abstract interface class AuthRepository {
  Future<AppUserModel?> restoreSession();

  Future<AppUserModel> signIn({
    required String email,
    required String password,
  });

  Future<GoogleAuthResult> signInWithGoogle({
    required UserRole expectedRole,
  });

  Future<AppUserModel> registerJobSeeker(JobSeekerRegistrationData data);

  Future<AppUserModel> registerEmployer(EmployerRegistrationData data);

  Future<AppUserModel> registerGoogleEmployer(
    GoogleEmployerRegistrationData data,
  );

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
