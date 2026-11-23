import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/core/errors/auth_failure.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/auth/data/repositories/demo_auth_repository.dart';
import 'package:career_bridge/features/public_portal/controllers/public_portal_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await AuthController.instance.resetForTesting();
    PublicPortalController.instance.resetForTesting();
    await PublicPortalController.instance.initialize();
    await AuthController.instance
        .resetForTesting(repository: DemoAuthRepository(), usesFirebase: true);
  });
  tearDown(() => AuthController.instance.resetForTesting());

  test('demo session selects sample repositories and logout restores real mode',
      () async {
    final auth = AuthController.instance;
    final user = await auth.signIn(
        email: 'jobseeker@careerbridge.demo',
        password: 'Demo123!',
        expectedRole: UserRole.jobSeeker);
    expect(user.uid, 'demo-job-seeker');
    expect(auth.usesFirebase, isFalse);
    expect(auth.isDemoSession, isTrue);
    expect(PublicPortalController.instance.jobs, isNotEmpty);
    await auth.signOut();
    expect(auth.currentUser, isNull);
    expect(auth.usesFirebase, isTrue);
    expect(auth.isDemoSession, isFalse);
  });

  test('invalid demo password and wrong portal never switch real repository',
      () async {
    final auth = AuthController.instance;
    await expectLater(
        auth.signIn(email: 'jobseeker@careerbridge.demo', password: 'wrong'),
        throwsA(isA<AuthFailure>()));
    expect(auth.usesFirebase, isTrue);
    await expectLater(
        auth.signIn(
            email: 'admin@careerbridge.demo',
            password: 'Admin123!',
            expectedRole: UserRole.jobSeeker),
        throwsA(isA<AuthFailure>()));
    expect(auth.usesFirebase, isTrue);
    expect(auth.isDemoSession, isFalse);
  });

  test('additional seeker and employer demos switch away from live data',
      () async {
    final auth = AuthController.instance;
    for (final entry in [
      ('electrical@careerbridge.demo', UserRole.jobSeeker),
      ('harbor@careerbridge.demo', UserRole.employer),
    ]) {
      final user = await auth.signIn(
          email: entry.$1, password: 'Demo123!', expectedRole: entry.$2);
      expect(user.role, entry.$2);
      expect(auth.usesFirebase, isFalse);
      expect(auth.isDemoSession, isTrue);
      expect(PublicPortalController.instance.jobs.every((j) => j.isSample),
          isTrue);
      await auth.signOut();
      expect(auth.usesFirebase, isTrue);
      expect(auth.isDemoSession, isFalse);
    }
  });
}
