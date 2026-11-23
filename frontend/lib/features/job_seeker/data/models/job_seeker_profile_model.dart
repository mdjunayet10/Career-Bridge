import '../../../cv_builder/data/models/cv_profile_model.dart';

class JobSeekerProfileModel {
  const JobSeekerProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.updatedAt,
    this.headline = '',
    this.phone = '',
    this.location = '',
    this.about = '',
    this.educationSummary = '',
    this.experienceYears = 0,
    this.skills = const [],
    this.preferredRoles = const [],
    this.preferredLocations = const [],
    this.workModes = const [],
    this.portfolioUrl = '',
    this.linkedInUrl = '',
    this.profileImageFileId = '',
    this.hasCvDetails = false,
    this.education = const [],
    this.technicalLanguages = const [],
    this.frameworks = const [],
    this.toolsAndPlatforms = const [],
    this.projects = const [],
    this.experience = const [],
    this.hasCvExperience = false,
    this.achievements = const [],
    this.references = const [],
  });

  final String uid;
  final String fullName;
  final String email;
  final String headline;
  final String phone;
  final String location;
  final String about;
  final String educationSummary;
  final int experienceYears;
  final List<String> skills;
  final List<String> preferredRoles;
  final List<String> preferredLocations;
  final List<String> workModes;
  final String portfolioUrl;
  final String linkedInUrl;
  final String profileImageFileId;
  // Distinguishes older profiles from explicit edits, including empty lists.
  final bool hasCvDetails;
  final List<CvEducationItem> education;
  final List<String> technicalLanguages;
  final List<String> frameworks;
  final List<String> toolsAndPlatforms;
  final List<CvProjectItem> projects;
  final List<CvExperienceItem> experience;
  // Older structured profiles did not collect experience. Keep their CV data.
  final bool hasCvExperience;
  final List<CvAchievementItem> achievements;
  final List<CvReferenceItem> references;
  final DateTime updatedAt;

  List<String> get allSkills => [
        ...skills,
        ...technicalLanguages,
        ...frameworks,
        ...toolsAndPlatforms,
      ]
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(growable: false);

  // Optional sections are assessed only when supplied, so new applicants do
  // not need employment, awards or referees to complete their profile.
  Map<String, bool> get completionChecks => {
        'Full name': _filled(fullName),
        'Email': RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim()),
        'Headline': _filled(headline),
        'Phone': phone.replaceAll(RegExp(r'[^0-9]'), '').length >= 7,
        'Location': _filled(location),
        'About': _filled(about),
        'Profile photo': profileImageFileId.trim().isNotEmpty,
        'Education': education.isEmpty
            ? !hasCvDetails && _filled(educationSummary)
            : education.every((item) =>
                _filled(item.degree) &&
                _filled(item.institution) &&
                _filled(item.period)),
        'At least three skills': allSkills.length >= 3,
        'Preferred roles': preferredRoles.any(_filled),
        'Preferred locations': preferredLocations.any(_filled),
        'Work modes': workModes.any(_filled),
        'Portfolio or LinkedIn':
            _profileLink(portfolioUrl) || _profileLink(linkedInUrl),
        if (projects.isNotEmpty)
          'Project details': projects
              .every((item) => _filled(item.name) && _filled(item.description)),
        if (experience.isNotEmpty)
          'Experience details': experience.every((item) =>
              _filled(item.role) &&
              _filled(item.company) &&
              _filled(item.period) &&
              _filled(item.description)),
        if (achievements.isNotEmpty)
          'Achievement details': achievements.every((item) =>
              _filled(item.title) &&
              _filled(item.qualifier) &&
              _filled(item.description)),
        if (references.isNotEmpty)
          'Reference details': references.every((item) =>
              _filled(item.name) &&
              _filled(item.designation) &&
              _filled(item.organization) &&
              (_filled(item.email) || _filled(item.phone))),
      };

  List<String> get incompleteFields => completionChecks.entries
      .where((entry) => !entry.value)
      .map((entry) => entry.key)
      .toList(growable: false);

  double get completion {
    final checks = completionChecks.values;
    return checks.where((value) => value).length / checks.length;
  }

  int get completionPercent => (completion * 100).round();

  static bool _filled(String value) {
    final text = value.trim().toLowerCase();
    return text.isNotEmpty &&
        !{'n/a', 'na', 'tbd', 'todo', 'not provided'}.contains(text) &&
        !text.startsWith('available on request');
  }

  static bool _profileLink(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        {'http', 'https'}.contains(uri.scheme) &&
        uri.host.contains('.') &&
        !{'example.com', 'example.org', 'example.net'}.contains(uri.host);
  }

  JobSeekerProfileModel copyWith({
    String? fullName,
    String? email,
    String? headline,
    String? phone,
    String? location,
    String? about,
    String? educationSummary,
    int? experienceYears,
    List<String>? skills,
    List<String>? preferredRoles,
    List<String>? preferredLocations,
    List<String>? workModes,
    String? portfolioUrl,
    String? linkedInUrl,
    String? profileImageFileId,
    bool? hasCvDetails,
    List<CvEducationItem>? education,
    List<String>? technicalLanguages,
    List<String>? frameworks,
    List<String>? toolsAndPlatforms,
    List<CvProjectItem>? projects,
    List<CvExperienceItem>? experience,
    bool? hasCvExperience,
    List<CvAchievementItem>? achievements,
    List<CvReferenceItem>? references,
    DateTime? updatedAt,
  }) {
    return JobSeekerProfileModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      headline: headline ?? this.headline,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      about: about ?? this.about,
      educationSummary: educationSummary ?? this.educationSummary,
      experienceYears: experienceYears ?? this.experienceYears,
      skills: skills ?? this.skills,
      preferredRoles: preferredRoles ?? this.preferredRoles,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      workModes: workModes ?? this.workModes,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      profileImageFileId: profileImageFileId ?? this.profileImageFileId,
      hasCvDetails: hasCvDetails ?? this.hasCvDetails,
      education: education ?? this.education,
      technicalLanguages: technicalLanguages ?? this.technicalLanguages,
      frameworks: frameworks ?? this.frameworks,
      toolsAndPlatforms: toolsAndPlatforms ?? this.toolsAndPlatforms,
      projects: projects ?? this.projects,
      experience: experience ?? this.experience,
      hasCvExperience:
          hasCvExperience ?? (experience != null ? true : this.hasCvExperience),
      achievements: achievements ?? this.achievements,
      references: references ?? this.references,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toFirestore() => {
        'ownerUid': uid,
        'fullName': fullName,
        'email': email,
        'headline': headline,
        'phone': phone,
        'location': location,
        'about': about,
        'educationSummary': educationSummary,
        'experienceYears': experienceYears,
        'skills': skills,
        'preferredRoles': preferredRoles,
        'preferredLocations': preferredLocations,
        'workModes': workModes,
        'portfolioUrl': portfolioUrl,
        'linkedInUrl': linkedInUrl,
        'profileImageFileId':
            profileImageFileId.isEmpty ? null : profileImageFileId,
        'hasCvDetails': hasCvDetails,
        'education':
            education.map((item) => item.toMap()).toList(growable: false),
        'technicalLanguages': technicalLanguages,
        'frameworks': frameworks,
        'toolsAndPlatforms': toolsAndPlatforms,
        'projects':
            projects.map((item) => item.toMap()).toList(growable: false),
        'experience':
            experience.map((item) => item.toMap()).toList(growable: false),
        'hasCvExperience': hasCvExperience,
        'achievements':
            achievements.map((item) => item.toMap()).toList(growable: false),
        'references':
            references.map((item) => item.toMap()).toList(growable: false),
        'updatedAt': updatedAt,
      };

  factory JobSeekerProfileModel.fromFirestore(
    String uid,
    Map<String, dynamic> data, {
    required String fallbackName,
    required String fallbackEmail,
  }) {
    return JobSeekerProfileModel(
      uid: uid,
      fullName: (data['fullName'] as String?) ?? fallbackName,
      email: (data['email'] as String?) ?? fallbackEmail,
      headline: (data['headline'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      location: (data['location'] as String?) ?? '',
      about: (data['about'] as String?) ?? '',
      educationSummary: (data['educationSummary'] as String?) ?? '',
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      skills: _readStrings(data['skills']),
      preferredRoles: _readStrings(data['preferredRoles']),
      preferredLocations: _readStrings(data['preferredLocations']),
      workModes: _readStrings(data['workModes']),
      portfolioUrl: (data['portfolioUrl'] as String?) ?? '',
      linkedInUrl: (data['linkedInUrl'] as String?) ?? '',
      profileImageFileId: (data['profileImageFileId'] as String?) ?? '',
      hasCvDetails: (data['hasCvDetails'] as bool?) ?? false,
      education: _readMaps(data['education'])
          .map(CvEducationItem.fromMap)
          .toList(growable: false),
      technicalLanguages: _readStrings(data['technicalLanguages']),
      frameworks: _readStrings(data['frameworks']),
      toolsAndPlatforms: _readStrings(data['toolsAndPlatforms']),
      projects: _readMaps(data['projects'])
          .map(CvProjectItem.fromMap)
          .toList(growable: false),
      experience: _readMaps(data['experience'])
          .map(CvExperienceItem.fromMap)
          .toList(growable: false),
      hasCvExperience:
          (data['hasCvExperience'] as bool?) ?? data.containsKey('experience'),
      achievements: _readMaps(data['achievements'])
          .map(CvAchievementItem.fromMap)
          .toList(growable: false),
      references: _readMaps(data['references'])
          .map(CvReferenceItem.fromMap)
          .toList(growable: false),
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  static List<String> _readStrings(Object? value) {
    return value is Iterable
        ? value.whereType<String>().toList(growable: false)
        : const [];
  }

  static List<Map<String, dynamic>> _readMaps(Object? value) =>
      value is Iterable
          ? value
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false)
          : const [];

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
