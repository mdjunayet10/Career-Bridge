import 'dart:convert';
import 'dart:io';

import 'package:career_bridge/core/services/cv_pdf_service.dart';
import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

import '../support/pdf_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'compact reference fits a complete CV with photo without dropping content',
      () async {
    final source = _completeProfile();
    final classicBefore = await CvPdfService.instance.buildPdf(source);
    final compact = await CvPdfService.instance
        .buildPdf(source.copyWith(templateId: 'reference-compact'));
    final classicAfter = await CvPdfService.instance.buildPdf(source);
    final destination = Platform.environment['CV_PDF_QA_DIR'];
    if (destination != null) {
      await Directory(destination).create(recursive: true);
      await File('$destination/compact-generic.pdf').writeAsBytes(compact);
    }

    expect(_pages(classicBefore), greaterThan(1));
    expect(_pages(compact), 1);
    expect(_pages(classicAfter), _pages(classicBefore),
        reason: 'Compact layout must not alter later classic exports.');
    expect(latin1.decode(compact), contains('/Subtype/Image'));

    final text = extractPdfText(compact);
    for (final marker in [
      'Professional Summary',
      'Spoken Languages',
      'Education',
      'Technical Skills',
      'Projects',
      'Experience',
      'Achievements & Certifications',
      'References',
      'Graduate diploma',
      'Higher secondary',
      'Secondary certificate',
      'Project 1',
      'Project 2',
      'Project 3',
      'Project 4',
      'Content Creator',
      'Industrial Trainee',
      'Scholarship (2 awards)',
      'Research Award',
      'Bangladesh University of Professionals (BUP)',
      'Dr. Sample One',
      'Dr. Sample Two',
      'two@example.com',
      'CGPA: 3.80/4.00',
      'French, English',
    ]) {
      expect(text, contains(marker), reason: 'Lost CV content: $marker');
    }
  });
}

int _pages(List<int> bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length;

CvProfileModel _completeProfile() => CvProfileModel(
      ownerUid: 'generic-compact-cv',
      fullName: 'Sample Candidate',
      email: 'candidate@example.com',
      phone: '+44 1234 567890',
      location: 'London, UK',
      portfolioUrl: 'https://example.com/portfolio',
      professionalSummary: 'Graduate with software and communication skills.',
      photoDataUrl:
          'data:image/png;base64,${base64Encode(image.encodePng(image.Image(width: 80, height: 100)))}',
      languages: const ['French', 'English'],
      technicalLanguages: const ['Dart', 'Python', 'SQL'],
      toolsAndPlatforms: const ['Git', 'Firebase', 'Linux'],
      education: const [
        CvEducationItem(
            degree: 'Graduate diploma',
            institution: 'Example University',
            period: '2022–2026',
            result: 'CGPA: 3.80/4.00'),
        CvEducationItem(
            degree: 'Higher secondary',
            institution: 'Example College',
            period: '2020–2022'),
        CvEducationItem(
            degree: 'Secondary certificate',
            institution: 'Example School',
            period: '2018–2020'),
      ],
      projects: [
        for (var index = 1; index <= 4; index++)
          CvProjectItem(
              name: 'Project $index',
              toolsAndMethods: 'Dart | SQL',
              description:
                  'Built and documented a useful software application.'),
      ],
      experience: const [
        CvExperienceItem(
            role: 'Content Creator',
            company: 'Example Media',
            period: '2024–Present',
            description:
                'Produced educational videos for a large online audience.'),
        CvExperienceItem(
            role: 'Industrial Trainee',
            company: 'Example Technologies',
            period: '2026',
            description: 'Participated in practical industrial training.'),
      ],
      achievements: const [
        CvAchievementItem(
            title: 'Scholarship (2 awards)',
            qualifier: 'Bangladesh University of Professionals (BUP)',
            description: 'Received two university scholarship awards.'),
        CvAchievementItem(
            title: 'Research Award',
            qualifier: 'Bangladesh University of Professionals (BUP)',
            description: 'Recognized for a student research presentation.'),
      ],
      references: const [
        CvReferenceItem(
            name: 'Dr. Sample One',
            designation: 'Lecturer',
            organization: 'Department of Computing\nExample University',
            email: 'one@example.com'),
        CvReferenceItem(
            name: 'Dr. Sample Two',
            designation: 'Lecturer',
            organization: 'Department of Computing\nExample University',
            email: 'two@example.com'),
      ],
      updatedAt: DateTime(2026),
    );
