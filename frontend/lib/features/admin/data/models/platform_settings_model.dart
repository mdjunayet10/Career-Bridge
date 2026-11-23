class PlatformSettingsModel {
  const PlatformSettingsModel({
    required this.platformName,
    required this.supportEmail,
    required this.employerReviewRequired,
    required this.jobReviewRequired,
    required this.maintenanceMode,
    required this.allowJobSeekerRegistration,
    required this.allowEmployerRegistration,
    required this.updatedAt,
  });

  final String platformName;
  final String supportEmail;
  final bool employerReviewRequired;
  final bool jobReviewRequired;
  final bool maintenanceMode;
  final bool allowJobSeekerRegistration;
  final bool allowEmployerRegistration;
  final DateTime updatedAt;

  PlatformSettingsModel copyWith({
    String? platformName,
    String? supportEmail,
    bool? employerReviewRequired,
    bool? jobReviewRequired,
    bool? maintenanceMode,
    bool? allowJobSeekerRegistration,
    bool? allowEmployerRegistration,
    DateTime? updatedAt,
  }) {
    return PlatformSettingsModel(
      platformName: platformName ?? this.platformName,
      supportEmail: supportEmail ?? this.supportEmail,
      employerReviewRequired:
          employerReviewRequired ?? this.employerReviewRequired,
      jobReviewRequired: jobReviewRequired ?? this.jobReviewRequired,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      allowJobSeekerRegistration:
          allowJobSeekerRegistration ?? this.allowJobSeekerRegistration,
      allowEmployerRegistration:
          allowEmployerRegistration ?? this.allowEmployerRegistration,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toFirestore() => {
        'platformName': platformName.trim(),
        'supportEmail': supportEmail.trim(),
        'employerReviewRequired': employerReviewRequired,
        'jobReviewRequired': jobReviewRequired,
        'maintenanceMode': maintenanceMode,
        'allowJobSeekerRegistration': allowJobSeekerRegistration,
        'allowEmployerRegistration': allowEmployerRegistration,
        'updatedAt': updatedAt,
      };

  factory PlatformSettingsModel.fromFirestore(Map<String, dynamic> data) {
    return PlatformSettingsModel(
      platformName: (data['platformName'] as String?) ?? 'Career Bridge',
      supportEmail:
          (data['supportEmail'] as String?) ?? 'support@careerbridge.local',
      employerReviewRequired: data['employerReviewRequired'] as bool? ?? true,
      jobReviewRequired: data['jobReviewRequired'] as bool? ?? true,
      maintenanceMode: data['maintenanceMode'] as bool? ?? false,
      allowJobSeekerRegistration:
          data['allowJobSeekerRegistration'] as bool? ?? true,
      allowEmployerRegistration:
          data['allowEmployerRegistration'] as bool? ?? true,
      updatedAt: _readDate(data['updatedAt']),
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
