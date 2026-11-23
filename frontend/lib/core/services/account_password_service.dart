import 'package:firebase_auth/firebase_auth.dart';
import '../errors/auth_failure.dart';

/// Links a password to the signed-in Google identity; never creates a user.
class AccountPasswordService {
  AccountPasswordService({FirebaseAuth? auth, required this.expectedUid})
      : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;
  final String expectedUid;

  bool get canAddPassword {
    final user = _auth.currentUser;
    if (user == null ||
        user.uid != expectedUid ||
        user.email?.isNotEmpty != true ||
        !user.emailVerified) {
      return false;
    }
    final providers = user.providerData.map((provider) => provider.providerId);
    return providers.contains('google.com') && !providers.contains('password');
  }

  Future<void> addPassword(String password) async {
    if (!canAddPassword) {
      throw const AuthFailure(
          'Sign in with Google again to set an app password. If you already have a password, use Forgot password on the sign-in page.');
    }
    if (password.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      throw const AuthFailure(
          'Use at least 8 characters, including an uppercase letter and a number.');
    }
    final user = _auth.currentUser!;
    try {
      await user.linkWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: password));
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'requires-recent-login' ||
        'user-token-expired' ||
        'invalid-user-token' =>
          'For your security, sign out and sign in with Google again, then set your app password.',
        'provider-already-linked' =>
          'A password is already linked. Use Forgot password on the sign-in page to reset it.',
        'credential-already-in-use' ||
        'email-already-in-use' =>
          'This email is linked to another account. Contact support before changing your sign-in method.',
        'weak-password' => 'Choose a stronger password and try again.',
        'network-request-failed' => 'Check your connection and try again.',
        _ => 'Could not set the password. Please try again.',
      };
      throw AuthFailure(message, code: error.code);
    }
  }
}
