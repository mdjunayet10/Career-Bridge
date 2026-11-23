import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CvProfileModel read(Map<String, dynamic> data) =>
      CvProfileModel.fromFirestore(
        'candidate',
        data,
        fallbackName: 'Candidate',
        fallbackEmail: 'candidate@example.com',
      );

  test('all universal CV fields survive save and reload', () {
    final cv = CvProfileModel(
      ownerUid: 'candidate',
      fullName: 'Finance Candidate',
      email: 'candidate@example.com',
      photoDataUrl: 'data:image/jpeg;base64,dGVzdA==',
      linkedInUrl: 'https://linkedin.com/in/candidate',
      portfolioUrl: 'https://example.com/portfolio',
      technicalLanguages: const ['SQL'],
      toolsAndPlatforms: const ['Excel', 'SPSS'],
      education: const [
        CvEducationItem(
          degree: 'BBA in Finance',
          institution: 'Independent University',
          institutionUrl: 'https://example.com/university',
          period: '2021 - 2025',
          location: 'Dhaka',
          result: 'CGPA 3.8 / 4.0',
          details: 'Finance major',
        ),
      ],
      projects: const [
        CvProjectItem(
            name: 'Market Study',
            description: 'Interviewed local businesses',
            toolsAndMethods: 'Excel | Interviews')
      ],
      achievements: const [
        CvAchievementItem(
            title: 'Research Award',
            qualifier: 'Institute',
            date: '2025',
            description: 'Recognized financial research'),
      ],
      references: const [
        CvReferenceItem(
            name: 'Supervisor',
            designation: 'Manager',
            organization: 'Company',
            email: 'manager@example.com',
            phone: '+8801700000000'),
      ],
      sectionOrder: const ['experience', 'education'],
      hiddenSections: const ['references'],
      showPhoto: false,
      updatedAt: DateTime(2026, 10, 11),
    );
    final restored = read(Map<String, dynamic>.from(cv.toFirestore()));
    expect(restored.toFirestore(), cv.toFirestore());
    expect(restored.frameworks, isEmpty);
    expect(restored.templateId, 'reference-classic');
  });

  test('old documents keep legacy content with optional new fields empty', () {
    final cv = read({
      'personal': {'fullName': 'Legacy Candidate'},
      'skills': ['Accounting'],
      'languages': ['Bangla'],
      'education': [
        {'degree': 'BBA', 'institution': 'University', 'period': '2025'}
      ],
      'certifications': [
        {'name': 'Accounting Certificate', 'issuer': 'Institute'}
      ],
    });
    expect(cv.orderedSections, CvSection.values);
    expect(cv.hiddenSections, isEmpty);
    expect(cv.showPhoto, isTrue);
    expect(cv.skills, ['Accounting']);
    expect(cv.languages, ['Bangla']);
    expect(cv.technicalLanguages, isEmpty);
    expect(cv.education.single.result, isEmpty);
    expect(cv.education.single.institutionUrl, isEmpty);
    expect(cv.achievements.single.title, 'Accounting Certificate');
    expect(cv.achievements.single.qualifier, 'Institute');
  });

  test('section order ignores duplicate and unsupported IDs', () {
    final cv = read({
      'sectionOrder': ['experience', 'experience', 'unknown']
    });
    expect(cv.orderedSections.first, CvSection.experience);
    expect(cv.orderedSections.toSet().length, CvSection.values.length);
    expect(cv.orderedSections.length, CvSection.values.length);
  });

  test('copyWith supports explicit clears without losing unrelated details',
      () {
    final cv = read({
      'frameworks': ['React'],
      'toolsAndPlatforms': ['Excel'],
      'achievements': [
        {'title': 'Award'}
      ],
      'references': [
        {'name': 'Supervisor'}
      ],
    });
    final cleared =
        cv.copyWith(frameworks: [], achievements: [], references: []);
    expect(cleared.frameworks, isEmpty);
    expect(cleared.achievements, isEmpty);
    expect(cleared.references, isEmpty);
    expect(cleared.toolsAndPlatforms, ['Excel']);
  });
}
