import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/enums/employer_verification_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/auth_failure.dart';
import '../models/app_user_model.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static Future<void>? _googleInitialization;

  static Future<void> _initializeGoogle() async {
    try {
      const serverClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
      await (_googleInitialization ??= GoogleSignIn.instance.initialize(
        serverClientId: serverClientId.isEmpty ? null : serverClientId,
      ));
    } catch (_) {
      _googleInitialization = null;
      rethrow;
    }
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<AppUserModel?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _loadProfile(user.uid);
  }

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('The sign-in session could not be created.');
      }
      return await _loadProfile(user.uid);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error.code), code: error.code);
    } on FirebaseException catch (error) {
      await _safeSignOut();
      throw AuthFailure(
          'Your account profile could not be loaded. Check your connection and try again.',
          code: error.code);
    }
  }

  @override
  Future<GoogleAuthResult> signInWithGoogle({
    required UserRole expectedRole,
  }) async {
    try {
      final UserCredential credential;
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters(const {'prompt': 'select_account'});
        credential = await _auth.signInWithPopup(provider);
      } else {
        await _initializeGoogle();
        final account = await GoogleSignIn.instance.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null || idToken.isEmpty) {
          throw const AuthFailure(
              'Google did not return a sign-in token. Please try again.',
              code: 'google-token-missing');
        }
        credential = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      }
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthFailure(
          'The Google sign-in session could not be created.',
        );
      }

      final profileDocument =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      final existingData = profileDocument.data();
      if (existingData != null) {
        final profile = await _profileFromData(firebaseUser.uid, existingData);
        return GoogleAuthResult.authenticated(profile);
      }

      final email = firebaseUser.email?.trim().toLowerCase() ?? '';
      if (email.isEmpty) {
        await _auth.signOut();
        throw const AuthFailure(
          'Google did not provide an email address for this account.',
          code: 'google-email-missing',
        );
      }

      final name = _displayName(firebaseUser);

      if (expectedRole == UserRole.admin) {
        await _auth.signOut();
        throw const AuthFailure(
          'Administrator access cannot be created through Google sign-in.',
          code: 'admin-google-registration-blocked',
        );
      }

      if (expectedRole == UserRole.employer) {
        return GoogleAuthResult.requiresEmployerSetup(
          GoogleAccountDraft(
            uid: firebaseUser.uid,
            name: name,
            email: email,
          ),
        );
      }

      final now = DateTime.now();
      final profile = AppUserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        role: UserRole.jobSeeker,
        isActive: true,
        createdAt: now,
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set({
        ...profile.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return GoogleAuthResult.authenticated(profile);
    } on GoogleSignInException catch (error) {
      throw AuthFailure(
        switch (error.code) {
          GoogleSignInExceptionCode.canceled =>
            'Google sign-in was cancelled. Please try again.',
          GoogleSignInExceptionCode.clientConfigurationError ||
          GoogleSignInExceptionCode.providerConfigurationError =>
            'Google sign-in is not configured for this app build. Install the latest Career Bridge APK.',
          _ =>
            'Google sign-in could not finish. Check your connection and Google Play services, then try again.',
        },
        code: error.code.name,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error.code), code: error.code);
    } on FirebaseException catch (error) {
      await _safeSignOut();
      throw AuthFailure(
        error.code == 'permission-denied'
            ? 'Google account creation is not allowed by the current Firestore rules.'
            : 'The Google account could not be connected. Please try again.',
        code: error.code,
      );
    }
  }

  @override
  Future<AppUserModel> registerJobSeeker(
    JobSeekerRegistrationData data,
  ) async {
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: data.email.trim().toLowerCase(),
        password: data.password,
      );
      final user = credential.user!;
      await user.updateDisplayName(data.name.trim());
      final now = DateTime.now();
      final profile = AppUserModel(
        uid: user.uid,
        name: data.name.trim(),
        email: data.email.trim().toLowerCase(),
        role: UserRole.jobSeeker,
        isActive: true,
        createdAt: now,
      );
      await _firestore.collection('users').doc(user.uid).set({
        ...profile.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return profile;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error.code), code: error.code);
    } catch (error) {
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {
          // Cleanup is best-effort; the Admin Panel can remove an orphaned account.
        }
      }
      if (error is AuthFailure) rethrow;
      throw const AuthFailure(
        'The account could not be created. Please try again.',
      );
    }
  }

  @override
  Future<AppUserModel> registerEmployer(
    EmployerRegistrationData data,
  ) async {
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: data.email.trim().toLowerCase(),
        password: data.password,
      );
      final user = credential.user!;
      await user.updateDisplayName(data.contactName.trim());
      return await _createEmployerProfile(
        uid: user.uid,
        contactName: data.contactName,
        companyName: data.companyName,
        industry: data.industry,
        companySize: data.companySize,
        tradeLicenseNumber: data.tradeLicenseNumber,
        email: data.email,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error.code), code: error.code);
    } catch (error) {
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {
          // Cleanup is best-effort; the Admin Panel can remove an orphaned account.
        }
      }
      if (error is AuthFailure) rethrow;
      throw const AuthFailure(
        'The employer account could not be created. Please try again.',
      );
    }
  }

  @override
  Future<AppUserModel> registerGoogleEmployer(
    GoogleEmployerRegistrationData data,
  ) async {
    final firebaseUser = _auth.currentUser;
    final currentEmail = firebaseUser?.email?.trim().toLowerCase();
    final submittedEmail = data.email.trim().toLowerCase();

    if (firebaseUser == null ||
        firebaseUser.uid != data.uid ||
        currentEmail != submittedEmail) {
      await _safeSignOut();
      throw const AuthFailure(
        'The Google registration session expired. Sign in with Google again.',
        code: 'google-registration-session-expired',
      );
    }

    try {
      final existing =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (existing.exists) {
        return await _loadProfile(firebaseUser.uid);
      }

      await firebaseUser.updateDisplayName(data.contactName.trim());
      return await _createEmployerProfile(
        uid: firebaseUser.uid,
        contactName: data.contactName,
        companyName: data.companyName,
        industry: data.industry,
        companySize: data.companySize,
        tradeLicenseNumber: data.tradeLicenseNumber,
        email: submittedEmail,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error.code), code: error.code);
    } on FirebaseException catch (error) {
      throw AuthFailure(
        error.code == 'permission-denied'
            ? 'Employer registration is not allowed by the current Firestore rules.'
            : 'The employer profile could not be created. Please try again.',
        code: error.code,
      );
    }
  }

  Future<AppUserModel> _createEmployerProfile({
    required String uid,
    required String contactName,
    required String companyName,
    required String industry,
    required String companySize,
    required String tradeLicenseNumber,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final now = DateTime.now();
    final profile = AppUserModel(
      uid: uid,
      name: contactName.trim(),
      email: normalizedEmail,
      role: UserRole.employer,
      isActive: true,
      companyName: companyName.trim(),
      verificationStatus: EmployerVerificationStatus.pending,
      createdAt: now,
    );

    final userReference = _firestore.collection('users').doc(uid);
    final companyReference = _firestore.collection('companies').doc(uid);
    final verificationReference =
        _firestore.collection('companyVerifications').doc(uid);
    final batch = _firestore.batch();
    batch.set(userReference, {
      ...profile.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(companyReference, {
      'ownerUid': uid,
      'name': companyName.trim(),
      'industry': industry.trim(),
      'companySize': companySize,
      'email': normalizedEmail,
      'contactName': contactName.trim(),
      'description': '',
      'website': '',
      'phone': '',
      'address': '',
      'verificationStatus': 'pending',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(verificationReference, {
      'companyId': uid,
      'ownerUid': uid,
      'tradeLicenseNumber': tradeLicenseNumber.trim(),
      'status': 'pending',
      'adminNote': '',
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return profile;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error.code), code: error.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb && _googleInitialization != null) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Firebase is already signed out; Google cleanup is best-effort.
      }
    }
  }

  Future<AppUserModel> _loadProfile(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();
    final data = document.data();
    if (data == null) {
      await _auth.signOut();
      throw const AuthFailure(
        'Your account profile is missing. Contact the platform administrator.',
        code: 'profile-not-found',
      );
    }
    return _profileFromData(uid, data);
  }

  Future<AppUserModel> _profileFromData(
    String uid,
    Map<String, dynamic> data,
  ) async {
    final profile = AppUserModel.fromFirestore(uid, data);
    if (!profile.isActive) {
      await _safeSignOut();
      throw const AuthFailure(
        'This account has been suspended.',
        code: 'user-disabled',
      );
    }
    return profile;
  }

  String _displayName(User user) {
    final displayName = user.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) return displayName;

    final email = user.email?.trim() ?? '';
    if (email.contains('@')) {
      final localPart =
          email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
      final words = localPart.split(' ').where((word) => word.isNotEmpty).map(
            (word) => word.length == 1
                ? word.toUpperCase()
                : '${word[0].toUpperCase()}${word.substring(1)}',
          );
      final generated = words.join(' ').trim();
      if (generated.isNotEmpty) return generated;
    }

    return 'Career Bridge User';
  }

  Future<void> _safeSignOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Best-effort cleanup after an incomplete authentication attempt.
    }
  }

  String _friendlyMessage(String code) => switch (code) {
        'invalid-email' => 'Enter a valid email address.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Email or password is incorrect.',
        'email-already-in-use' =>
          'An account already exists with this email address.',
        'weak-password' =>
          'Use a stronger password with at least eight characters.',
        'too-many-requests' =>
          'Too many attempts. Wait a moment and try again.',
        'network-request-failed' =>
          'Check your internet connection and try again.',
        'user-disabled' => 'This account has been suspended.',
        'popup-closed-by-user' ||
        'cancelled-popup-request' =>
          'Google sign-in was cancelled.',
        'popup-blocked' =>
          'The browser blocked the Google sign-in popup. Allow popups and try again.',
        'unauthorized-domain' =>
          'This domain is not authorised for Google sign-in in Firebase.',
        'operation-not-allowed' =>
          'Google sign-in is not enabled in Firebase Authentication.',
        'account-exists-with-different-credential' =>
          'An account already exists with this email using another sign-in method.',
        _ => 'Authentication failed. Please try again.',
      };
}
