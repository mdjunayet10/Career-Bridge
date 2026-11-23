import '../../../../core/enums/employer_verification_status.dart';

class AdminCompanyReviewModel {
  const AdminCompanyReviewModel({
    required this.companyId,
    required this.ownerUid,
    required this.companyName,
    required this.industry,
    required this.companySize,
    required this.email,
    required this.website,
    required this.address,
    required this.tradeLicenseNumber,
    required this.status,
    required this.isActive,
    required this.submittedAt,
    this.logoFileId = '',
    this.decisionNote,
  });

  final String companyId;
  final String ownerUid;
  final String companyName;
  final String industry;
  final String companySize;
  final String email;
  final String website;
  final String address;
  final String tradeLicenseNumber;
  final EmployerVerificationStatus status;
  final bool isActive;
  final DateTime submittedAt;
  final String logoFileId;
  final String? decisionNote;

  AdminCompanyReviewModel copyWith({
    EmployerVerificationStatus? status,
    bool? isActive,
    String? decisionNote,
  }) {
    return AdminCompanyReviewModel(
      companyId: companyId,
      ownerUid: ownerUid,
      companyName: companyName,
      industry: industry,
      companySize: companySize,
      email: email,
      website: website,
      address: address,
      tradeLicenseNumber: tradeLicenseNumber,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      submittedAt: submittedAt,
      logoFileId: logoFileId,
      decisionNote: decisionNote ?? this.decisionNote,
    );
  }

  factory AdminCompanyReviewModel.fromFirestore({
    required String companyId,
    required Map<String, dynamic> company,
    Map<String, dynamic>? verification,
  }) {
    return AdminCompanyReviewModel(
      companyId: companyId,
      ownerUid: (company['ownerUid'] as String?) ?? '',
      companyName: (company['name'] as String?) ?? 'Unnamed company',
      industry: (company['industry'] as String?) ?? '',
      companySize: (company['companySize'] as String?) ?? '',
      email: (company['email'] as String?) ?? '',
      website: (company['website'] as String?) ?? '',
      address: (company['address'] as String?) ?? '',
      tradeLicenseNumber:
          (verification?['tradeLicenseNumber'] as String?) ?? '',
      status: EmployerVerificationStatus.fromFirestore(
        (verification?['status'] as String?) ??
            company['verificationStatus'] as String?,
      ),
      isActive: company['isActive'] as bool? ?? true,
      submittedAt:
          _readDate(verification?['submittedAt'] ?? company['createdAt']),
      logoFileId: (company['logoFileId'] as String?) ?? '',
      decisionNote: verification?['decisionNote'] as String?,
    );
  }

  static DateTime _readDate(Object? value) {
    if (value is DateTime) return value;
    try {
      final dynamic dynamicValue = value;
      final converted = dynamicValue?.toDate();
      if (converted is DateTime) return converted;
    } catch (_) {}
    return DateTime.now();
  }
}
