class CvEducationItem {
  const CvEducationItem({
    required this.degree,
    required this.institution,
    required this.period,
    this.location = '',
    this.result = '',
    this.details = '',
    this.institutionUrl = '',
  });

  final String degree;
  final String institution;
  final String period;
  final String location;
  final String result;
  final String details;
  final String institutionUrl;

  Map<String, Object?> toMap() => {
        'degree': degree,
        'institution': institution,
        'period': period,
        'location': location,
        'result': result,
        'details': details,
        'institutionUrl': institutionUrl,
      };

  factory CvEducationItem.fromMap(Map<String, dynamic> data) => CvEducationItem(
        degree: (data['degree'] as String?) ?? '',
        institution: (data['institution'] as String?) ?? '',
        period: (data['period'] as String?) ?? '',
        location: (data['location'] as String?) ?? '',
        result: (data['result'] as String?) ?? '',
        details: (data['details'] as String?) ?? '',
        institutionUrl: (data['institutionUrl'] as String?) ?? '',
      );
}

class CvExperienceItem {
  const CvExperienceItem({
    required this.role,
    required this.company,
    required this.period,
    required this.description,
  });

  final String role;
  final String company;
  final String period;
  final String description;

  Map<String, Object?> toMap() => {
        'role': role,
        'company': company,
        'period': period,
        'description': description,
      };

  factory CvExperienceItem.fromMap(Map<String, dynamic> data) =>
      CvExperienceItem(
        role: (data['role'] as String?) ?? '',
        company: (data['company'] as String?) ?? '',
        period: (data['period'] as String?) ?? '',
        description: (data['description'] as String?) ?? '',
      );
}

class CvProjectItem {
  const CvProjectItem(
      {required this.name,
      required this.description,
      this.link = '',
      this.toolsAndMethods = ''});

  final String name;
  final String description;
  final String link;
  final String toolsAndMethods;

  Map<String, Object?> toMap() => {
        'name': name,
        'description': description,
        'link': link,
        'toolsAndMethods': toolsAndMethods
      };

  factory CvProjectItem.fromMap(Map<String, dynamic> data) => CvProjectItem(
        name: (data['name'] as String?) ?? '',
        description: (data['description'] as String?) ?? '',
        link: (data['link'] as String?) ?? '',
        toolsAndMethods: (data['toolsAndMethods'] as String?) ?? '',
      );
}

class CvAchievementItem {
  const CvAchievementItem({
    required this.title,
    this.qualifier = '',
    this.date = '',
    this.description = '',
  });

  final String title;
  final String qualifier;
  final String date;
  final String description;

  Map<String, Object?> toMap() => {
        'title': title,
        'qualifier': qualifier,
        'date': date,
        'description': description,
      };

  factory CvAchievementItem.fromMap(Map<String, dynamic> data) =>
      CvAchievementItem(
        title: (data['title'] as String?) ?? (data['name'] as String?) ?? '',
        qualifier:
            (data['qualifier'] as String?) ?? (data['issuer'] as String?) ?? '',
        date: (data['date'] as String?) ?? '',
        description: (data['description'] as String?) ?? '',
      );
}

class CvReferenceItem {
  const CvReferenceItem({
    required this.name,
    this.designation = '',
    this.organization = '',
    this.email = '',
    this.phone = '',
  });

  final String name;
  final String designation;
  final String organization;
  final String email;
  final String phone;

  Map<String, Object?> toMap() => {
        'name': name,
        'designation': designation,
        'organization': organization,
        'email': email,
        'phone': phone,
      };

  factory CvReferenceItem.fromMap(Map<String, dynamic> data) => CvReferenceItem(
        name: (data['name'] as String?) ?? '',
        designation: (data['designation'] as String?) ?? '',
        organization: (data['organization'] as String?) ?? '',
        email: (data['email'] as String?) ?? '',
        phone: (data['phone'] as String?) ?? '',
      );
}

enum CvSection {
  summary('Professional Summary'),
  education('Education'),
  skills('Technical Skills'),
  projects('Projects'),
  experience('Experience'),
  achievements('Achievements & Certifications'),
  references('References'),
  languages('Spoken Languages');

  const CvSection(this.label);
  final String label;
}

class CvProfileModel {
  const CvProfileModel({
    required this.ownerUid,
    required this.fullName,
    required this.email,
    required this.updatedAt,
    this.title = 'My Career Bridge CV',
    this.phone = '',
    this.location = '',
    this.professionalSummary = '',
    this.skills = const [],
    this.education = const [],
    this.experience = const [],
    this.projects = const [],
    this.languages = const [],
    this.technicalLanguages = const [],
    this.frameworks = const [],
    this.toolsAndPlatforms = const [],
    this.achievements = const [],
    this.references = const [],
    this.photoDataUrl = '',
    this.linkedInUrl = '',
    this.portfolioUrl = '',
    this.templateId = 'reference-classic',
    this.sectionOrder = const [],
    this.hiddenSections = const [],
    this.showPhoto = true,
  });

  final String ownerUid;
  final String title;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String professionalSummary;
  final List<String> skills;
  final List<CvEducationItem> education;
  final List<CvExperienceItem> experience;
  final List<CvProjectItem> projects;
  final List<String> languages;
  final List<String> technicalLanguages;
  final List<String> frameworks;
  final List<String> toolsAndPlatforms;
  final List<CvAchievementItem> achievements;
  final List<CvReferenceItem> references;
  final String photoDataUrl;
  final String linkedInUrl;
  final String portfolioUrl;
  final String templateId;
  final DateTime updatedAt;
  final List<String> sectionOrder;
  final List<String> hiddenSections;
  final bool showPhoto;

  /// Old documents and future/invalid IDs retain each supported section once.
  List<CvSection> get orderedSections {
    final byId = {
      for (final section in CvSection.values) section.name: section
    };
    return {
      for (final id in sectionOrder)
        if (byId.containsKey(id)) byId[id]!,
      ...CvSection.values,
    }.toList(growable: false);
  }

  bool isSectionVisible(CvSection section) =>
      !hiddenSections.contains(section.name);

  int get sectionCount => [
        professionalSummary.trim().isNotEmpty,
        languages.isNotEmpty,
        education.isNotEmpty,
        experience.isNotEmpty,
        projects.isNotEmpty,
        skills.isNotEmpty ||
            technicalLanguages.isNotEmpty ||
            frameworks.isNotEmpty ||
            toolsAndPlatforms.isNotEmpty,
        achievements.isNotEmpty,
        references.isNotEmpty,
      ].where((value) => value).length;

  CvProfileModel copyWith({
    String? title,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? professionalSummary,
    List<String>? skills,
    List<CvEducationItem>? education,
    List<CvExperienceItem>? experience,
    List<CvProjectItem>? projects,
    List<String>? languages,
    List<String>? technicalLanguages,
    List<String>? frameworks,
    List<String>? toolsAndPlatforms,
    List<CvAchievementItem>? achievements,
    List<CvReferenceItem>? references,
    String? photoDataUrl,
    String? linkedInUrl,
    String? portfolioUrl,
    String? templateId,
    DateTime? updatedAt,
    List<String>? sectionOrder,
    List<String>? hiddenSections,
    bool? showPhoto,
  }) {
    return CvProfileModel(
      ownerUid: ownerUid,
      title: title ?? this.title,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      professionalSummary: professionalSummary ?? this.professionalSummary,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      languages: languages ?? this.languages,
      technicalLanguages: technicalLanguages ?? this.technicalLanguages,
      frameworks: frameworks ?? this.frameworks,
      toolsAndPlatforms: toolsAndPlatforms ?? this.toolsAndPlatforms,
      achievements: achievements ?? this.achievements,
      references: references ?? this.references,
      photoDataUrl: photoDataUrl ?? this.photoDataUrl,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      templateId: templateId ?? this.templateId,
      updatedAt: updatedAt ?? this.updatedAt,
      sectionOrder: sectionOrder ?? this.sectionOrder,
      hiddenSections: hiddenSections ?? this.hiddenSections,
      showPhoto: showPhoto ?? this.showPhoto,
    );
  }

  Map<String, Object?> toFirestore() => {
        'ownerUid': ownerUid,
        'title': title,
        'personal': {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'location': location,
          'summary': professionalSummary,
          'photoDataUrl': photoDataUrl,
          'linkedInUrl': linkedInUrl,
          'portfolioUrl': portfolioUrl,
        },
        'skills': skills,
        'education':
            education.map((item) => item.toMap()).toList(growable: false),
        'experience':
            experience.map((item) => item.toMap()).toList(growable: false),
        'projects':
            projects.map((item) => item.toMap()).toList(growable: false),
        'languages': languages,
        'technicalLanguages': technicalLanguages,
        'frameworks': frameworks,
        'toolsAndPlatforms': toolsAndPlatforms,
        'achievements':
            achievements.map((item) => item.toMap()).toList(growable: false),
        'references':
            references.map((item) => item.toMap()).toList(growable: false),
        'templateId': templateId,
        'sectionOrder': sectionOrder,
        'hiddenSections': hiddenSections,
        'showPhoto': showPhoto,
        'updatedAt': updatedAt,
      };

  factory CvProfileModel.fromFirestore(
    String uid,
    Map<String, dynamic> data, {
    required String fallbackName,
    required String fallbackEmail,
  }) {
    final personal =
        Map<String, dynamic>.from(data['personal'] as Map? ?? const {});
    return CvProfileModel(
      ownerUid: uid,
      title: (data['title'] as String?) ?? 'My Career Bridge CV',
      fullName: (personal['fullName'] as String?) ?? fallbackName,
      email: (personal['email'] as String?) ?? fallbackEmail,
      phone: (personal['phone'] as String?) ?? '',
      location: (personal['location'] as String?) ?? '',
      professionalSummary: (personal['summary'] as String?) ?? '',
      photoDataUrl: (personal['photoDataUrl'] as String?) ?? '',
      linkedInUrl: (personal['linkedInUrl'] as String?) ?? '',
      portfolioUrl: (personal['portfolioUrl'] as String?) ?? '',
      skills: _readStrings(data['skills']),
      education: _readMaps(data['education'])
          .map(CvEducationItem.fromMap)
          .toList(growable: false),
      experience: _readMaps(data['experience'])
          .map(CvExperienceItem.fromMap)
          .toList(growable: false),
      projects: _readMaps(data['projects'])
          .map(CvProjectItem.fromMap)
          .toList(growable: false),
      languages: _readStrings(data['languages']),
      technicalLanguages: _readStrings(data['technicalLanguages']),
      frameworks: _readStrings(data['frameworks']),
      toolsAndPlatforms: _readStrings(data['toolsAndPlatforms']),
      achievements: _readMaps(data['achievements'] ?? data['certifications'])
          .map(CvAchievementItem.fromMap)
          .toList(growable: false),
      references: _readMaps(data['references'])
          .map(CvReferenceItem.fromMap)
          .toList(growable: false),
      templateId: (data['templateId'] as String?) ?? 'reference-classic',
      sectionOrder: _readStrings(data['sectionOrder']),
      hiddenSections: _readStrings(data['hiddenSections']),
      showPhoto: (data['showPhoto'] as bool?) ?? true,
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  static List<String> _readStrings(Object? value) => value is Iterable
      ? value.whereType<String>().toList(growable: false)
      : const [];

  static List<Map<String, dynamic>> _readMaps(Object? value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
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
