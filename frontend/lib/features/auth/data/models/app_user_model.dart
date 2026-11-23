import '../../../../core/enums/employer_verification_status.dart';
import '../../../../core/enums/user_role.dart';

class AppUserModel {
  const AppUserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.companyName,
    this.verificationStatus = EmployerVerificationStatus.notRequired,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final String? companyName;
  final EmployerVerificationStatus verificationStatus;

  bool get isEmployerApproved =>
      role != UserRole.employer ||
      verificationStatus == EmployerVerificationStatus.approved;

  Map<String, Object?> toFirestore() => {
        'name': name,
        'email': email,
        'role': role.firestoreValue,
        'isActive': isActive,
        'companyName': companyName,
        'verificationStatus': verificationStatus.firestoreValue,
        'createdAt': createdAt,
        'updatedAt': createdAt,
      };

  factory AppUserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUserModel(
      uid: uid,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? data['name'] as String
          : 'Career Bridge User',
      email: (data['email'] as String?) ?? '',
      role: UserRole.fromFirestore((data['role'] as String?) ?? 'jobSeeker'),
      isActive: data['isActive'] as bool? ?? true,
      companyName: data['companyName'] as String?,
      verificationStatus: EmployerVerificationStatus.fromFirestore(
        data['verificationStatus'] as String?,
      ),
      createdAt: _readDate(data['createdAt']),
    );
  }

  static DateTime _readDate(Object? value) {
    if (value is DateTime) return value;
    try {
      final dynamic dynamicValue = value;
      final converted = dynamicValue?.toDate();
      if (converted is DateTime) return converted;
    } catch (_) {
      // Firestore Timestamp is intentionally handled without coupling the model to Firebase.
    }
    return DateTime.now();
  }
}
