import 'package:career_bridge/core/services/account_password_service.dart';
import 'package:career_bridge/core/errors/auth_failure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAuth extends Fake implements FirebaseAuth {
  TestAuth(this.user);
  final User? user;
  @override
  User? get currentUser => user;
}

class TestUser extends Fake implements User {
  TestUser({
    this.providers = const ['google.com'],
    this.verified = true,
    this.linkError,
  });
  final List<String> providers;
  final bool verified;
  final FirebaseAuthException? linkError;
  AuthCredential? linked;
  @override
  String get uid => 'same-user';
  @override
  String? get email => 'samira@tests.invalid';
  @override
  bool get emailVerified => verified;
  @override
  List<UserInfo> get providerData =>
      [for (final p in providers) TestUserInfo(p)];
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    linked = credential;
    if (linkError != null) throw linkError!;
    return TestCredential();
  }
}

class TestUserInfo extends Fake implements UserInfo {
  TestUserInfo(this.providerId);
  @override
  final String providerId;
}

class TestCredential extends Fake implements UserCredential {}

void main() {
  test(
      'Google account adds password to existing uid, without creating an account',
      () async {
    final user = TestUser();
    final service =
        AccountPasswordService(auth: TestAuth(user), expectedUid: 'same-user');
    expect(service.canAddPassword, isTrue);
    await service.addPassword('StrongPass123!');
    final credential = user.linked! as EmailAuthCredential;
    expect(credential.email, 'samira@tests.invalid');
    expect(credential.providerId, 'password');
    expect(credential.password, 'StrongPass123!');
  });
  test('missing or changed session cannot add a password', () async {
    for (final auth in [TestAuth(null), TestAuth(TestUser())]) {
      final service =
          AccountPasswordService(auth: auth, expectedUid: 'different-user');
      expect(service.canAddPassword, isFalse);
      await expectLater(
          service.addPassword('StrongPass123!'), throwsA(isA<AuthFailure>()));
    }
  });
  test('unverified email and existing password are excluded', () async {
    for (final user in [
      TestUser(verified: false),
      TestUser(providers: ['google.com', 'password'])
    ]) {
      final service = AccountPasswordService(
          auth: TestAuth(user), expectedUid: 'same-user');
      expect(service.canAddPassword, isFalse);
      await expectLater(
          service.addPassword('StrongPass123!'), throwsA(isA<AuthFailure>()));
      expect(user.linked, isNull);
    }
  });
  test('short password rejected before provider request', () async {
    final user = TestUser();
    final service =
        AccountPasswordService(auth: TestAuth(user), expectedUid: 'same-user');
    await expectLater(
        service.addPassword('short'), throwsA(isA<AuthFailure>()));
    expect(user.linked, isNull);
  });
  test('expired recent login gives Google reauthentication guidance', () async {
    final user = TestUser(
        linkError: FirebaseAuthException(code: 'requires-recent-login'));
    final service =
        AccountPasswordService(auth: TestAuth(user), expectedUid: 'same-user');
    await expectLater(
        service.addPassword('StrongPass123!'),
        throwsA(isA<AuthFailure>()
            .having((error) => error.code, 'code', 'requires-recent-login')
            .having((error) => error.message, 'recovery guidance',
                contains('sign in with Google again'))));
  });
  for (final code in ['credential-already-in-use', 'email-already-in-use']) {
    test('$code explains the conflict without switching accounts', () async {
      final user = TestUser(linkError: FirebaseAuthException(code: code));
      final service = AccountPasswordService(
          auth: TestAuth(user), expectedUid: 'same-user');
      await expectLater(
          service.addPassword('StrongPass123!'),
          throwsA(isA<AuthFailure>()
              .having((error) => error.code, 'code', code)
              .having((error) => error.message, 'recovery guidance',
                  contains('Contact support'))));
    });
  }
}
