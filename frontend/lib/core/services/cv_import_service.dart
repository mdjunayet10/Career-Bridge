import 'dart:convert';
import '../../features/cv_builder/data/models/cv_profile_model.dart';

/// A user-chosen JSON document, never an APK-bundled personal profile.
abstract final class CvImportService {
  static CvProfileModel parse(String input,
      {required CvProfileModel current, required String authenticatedEmail}) {
    if (input.length > 500000) {
      throw const FormatException('CV import must be smaller than 500 KB.');
    }
    final data = jsonDecode(input);
    if (data is! Map<String, dynamic> ||
        data['schemaVersion'] != 1 ||
        data['cv'] is! Map<String, dynamic>) {
      throw const FormatException('Choose a Career Bridge CV import document.');
    }
    final email = authenticatedEmail.trim().toLowerCase();
    if (email.isEmpty ||
        data['expectedEmail']?.toString().trim().toLowerCase() != email) {
      throw const FormatException(
          'This CV belongs to another email address. Sign in to the matching account.');
    }
    final incoming = data['cv'] as Map<String, dynamic>;
    final merged = current.toFirestore()..addAll(incoming);
    merged['personal'] = {
      ...(current.toFirestore()['personal'] as Map),
      ...?incoming['personal'] as Map?,
      'email': authenticatedEmail,
    };
    merged['ownerUid'] = current.ownerUid;
    return CvProfileModel.fromFirestore(current.ownerUid, merged,
            fallbackName: current.fullName, fallbackEmail: authenticatedEmail)
        .copyWith(updatedAt: DateTime.now());
  }
}
