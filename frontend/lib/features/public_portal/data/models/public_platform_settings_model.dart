class PublicPlatformSettingsModel {
  const PublicPlatformSettingsModel({
    required this.platformName,
    required this.supportEmail,
    required this.maintenanceMode,
    required this.allowJobSeekerRegistration,
    required this.allowEmployerRegistration,
  });

  final String platformName;
  final String supportEmail;
  final bool maintenanceMode;
  final bool allowJobSeekerRegistration;
  final bool allowEmployerRegistration;

  static const defaults = PublicPlatformSettingsModel(
    platformName: 'Career Bridge',
    supportEmail: 'support@careerbridge.edu',
    maintenanceMode: false,
    allowJobSeekerRegistration: true,
    allowEmployerRegistration: true,
  );
}
