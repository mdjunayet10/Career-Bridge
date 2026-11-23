import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:career_bridge/core/constants/file_limits.dart';
import 'package:career_bridge/core/services/cv_pdf_service.dart';
import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

import '../support/pdf_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'reference CV includes a non-CSE profile and optional photo on one A4 page',
      () async {
    final cv = _businessProfile(photoDataUrl: _photo());
    final bytes = await CvPdfService.instance.buildPdf(cv);
    final text = extractPdfText(bytes);

    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(bytes.lengthInBytes, lessThanOrEqualTo(FileLimits.maxFileBytes));
    expect(_pageCount(bytes), 1);
    for (final value in [
      'Amina Rahman',
      'amina@example.com',
      'Dhaka, Bangladesh',
      'Professional Summary',
      'Business student with financial modeling skills.',
      'Spoken Languages',
      'Bangla, English',
      'Education',
      'Bachelor of Business Administration',
      'National University',
      'CGPA: 3.75 / 4.00',
      'Major: Finance',
      'Technical Skills',
      'Languages SQL',
      'Tools & Platforms Microsoft Excel, SPSS',
      'Projects',
      'Community Business Survey',
      'Analyzed 250 local businesses and presented findings.',
      'Achievements & Certifications',
      'Financial Modeling',
      'Professional Certificate',
      'December 2025',
      'Dr. Hasan Ahmed',
      'Professor Department of Business Studies',
      'hasan@example.com',
    ]) {
      expect(text, contains(value), reason: 'Missing CV field: $value');
    }
    for (final omitted in [
      'Frameworks',
      'BCSE 23',
      'ID:',
      'Co-curricular',
      'Ongoing',
      'My Career Bridge CV',
    ]) {
      expect(text, isNot(contains(omitted)));
    }
    expect(latin1.decode(bytes), contains('/Subtype/Image'));
    expect(latin1.decode(bytes), contains('https://linkedin.com/in/amina'));
    expect(latin1.decode(bytes), contains('https://example.com/amina'));
    await _writeQa('reference-business.pdf', bytes);
  });

  test('CV layout changes export without removing Profile details', () async {
    final source = _businessProfile(photoDataUrl: _photo());
    final cv = source.copyWith(
      sectionOrder: ['achievements', 'projects', 'education'],
      hiddenSections: ['skills', 'references'],
      showPhoto: false,
    );
    final bytes = await CvPdfService.instance.buildPdf(cv);
    final text = extractPdfText(bytes);
    expect(text, isNot(contains('Technical Skills')));
    expect(text, isNot(contains('Dr. Hasan Ahmed')));
    expect(text.indexOf('Achievements & Certifications'),
        lessThan(text.indexOf('Projects')));
    expect(text.indexOf('Projects'), lessThan(text.indexOf('Education')));
    expect(latin1.decode(bytes), isNot(contains('/Subtype/Image')));
    expect(cv.toolsAndPlatforms, source.toolsAndPlatforms);
    expect(cv.references, source.references);
    expect(cv.photoDataUrl, source.photoDataUrl);
    await _writeQa('layout-customized.pdf', bytes);
  });

  test('frameworks render only when supplied and legacy skills remain visible',
      () async {
    final cv = _businessProfile().copyWith(
      frameworks: const ['Django'],
      skills: const ['Research design'],
    );
    final text = extractPdfText(await CvPdfService.instance.buildPdf(cv));

    expect(text, contains('Frameworks Django'));
    expect(text, contains('Additional Skills Research design'));
    expect(text, contains('Languages SQL'));
    expect(text, contains('Spoken Languages Bangla, English'));
  });

  test('one long project and many entries wrap without losing final content',
      () async {
    final longDescription = List.generate(
      400,
      (index) =>
          'Survey finding $index describes demand, cost, access, and outcomes '
          'for businesses in the local community.',
    ).join(' ');
    final cv = _businessProfile(photoDataUrl: _photo()).copyWith(
      fullName: 'Amina Rahman ${List.filled(12, 'Chowdhury').join(' ')}',
      linkedInUrl:
          'https://example.com/profile-${List.filled(25, 'research').join()}',
      professionalSummary: 'A researcher with an extensive project portfolio.',
      projects: [
        CvProjectItem(
          name: 'Extended field research',
          description: '$longDescription FinalLongProjectMarker.',
        ),
        for (var index = 0; index < 50; index++)
          CvProjectItem(
            name: 'Research project $index',
            description:
                'Documented findings, methods, and results for project '
                '$index. Published a clear report for community stakeholders.',
          ),
        const CvProjectItem(
          name: 'Final Portfolio Entry',
          description:
              'FinalPortfolioMarker is present after all other projects.',
        ),
      ],
    );
    final bytes = await CvPdfService.instance.buildPdf(cv);
    final text = extractPdfText(bytes);

    expect(_pageCount(bytes), greaterThan(1));
    expect(text, contains('FinalLongProjectMarker.'));
    expect(text, contains('Final Portfolio Entry'));
    expect(text, contains('FinalPortfolioMarker'));
    expect(text, contains('hasan@example.com'));
    expect(bytes.lengthInBytes, lessThanOrEqualTo(FileLimits.maxFileBytes));
    await _writeQa('reference-long.pdf', bytes);
  });

  test('blank added rows stay hidden and damaged photos do not block export',
      () async {
    for (final photo in [
      'data:image/png;base64,not-an-image',
      'data:image/png;base64,${base64Encode(utf8.encode('not an image'))}',
    ]) {
      final cv = CvProfileModel(
        ownerUid: 'minimal-user',
        fullName: 'Sara Karim',
        email: 'sara@example.com',
        photoDataUrl: photo,
        education: const [
          CvEducationItem(degree: '', institution: '', period: '')
        ],
        experience: const [
          CvExperienceItem(role: '', company: '', period: '', description: '')
        ],
        projects: const [CvProjectItem(name: '', description: '')],
        achievements: const [CvAchievementItem(title: '')],
        references: const [CvReferenceItem(name: '')],
        updatedAt: DateTime(2026, 10, 11),
      );
      final bytes = await CvPdfService.instance.buildPdf(cv);
      final text = extractPdfText(bytes);

      expect(text, contains('Sara Karim'));
      expect(text, contains('sara@example.com'));
      expect(_pageCount(bytes), 1);
      expect(latin1.decode(bytes),
          contains('/Subtype/Image')); // Reference avatar fallback.
      for (final section in [
        'Education',
        'Technical Skills',
        'Experience',
        'Projects',
        'Achievements & Certifications',
        'References',
      ]) {
        expect(text, isNot(contains(section)));
      }
    }
  });

  test('long names and unbroken contact links wrap without losing text',
      () async {
    final name = 'Amina${List.filled(100, 'Rahman').join()}';
    final link = 'https://example.com/${List.filled(60, 'portfolio').join()}';
    final cv = _businessProfile(photoDataUrl: _photo()).copyWith(
      fullName: name,
      linkedInUrl: link,
      portfolioUrl: link,
      location: List.filled(20, 'House 12 Road 4 Dhaka').join(', '),
    );
    final bytes = await CvPdfService.instance.buildPdf(cv);
    final text = extractPdfText(bytes).replaceAll(' ', '');

    expect(text, contains(name));
    expect(text, contains(link.replaceFirst('https://', '')));
    expect(text, contains('Dr.HasanAhmed'));
    expect(bytes.lengthInBytes, lessThanOrEqualTo(FileLimits.maxFileBytes));
  });

  test(
      'spoken languages do not create technical skills for unrelated backgrounds',
      () async {
    final cv = _businessProfile().copyWith(
      technicalLanguages: const [],
      toolsAndPlatforms: const [],
      frameworks: const [],
      skills: const [],
    );
    final text = extractPdfText(await CvPdfService.instance.buildPdf(cv));

    expect(text, isNot(contains('Languages SQL')));
    expect(text, contains('Spoken Languages Bangla, English'));
    expect(text, isNot(contains('Technical Skills')));
    expect(text, isNot(contains('Frameworks')));
  });

  test('typographic punctuation renders safely without changing profile data',
      () async {
    final cv = _businessProfile().copyWith(
      professionalSummary: 'Growth—focused analyst with “clear” goals…',
      education: const [
        CvEducationItem(
            degree: 'Business Studies',
            institution: 'Sample College',
            period: '2023 – Present'),
      ],
      projects: const [
        CvProjectItem(
            name: 'Finance‑first', description: 'Survey • Community outcomes')
      ],
    );
    final text = extractPdfText(await CvPdfService.instance.buildPdf(cv));

    expect(text, isNot(contains('Growth-focused analyst')));
    expect(text, contains('2023 – Present'));
    expect(text, contains('Finance-first'));
    expect(text, contains('Survey • Community outcomes'));
    expect(cv.education.single.period, '2023 – Present');
    expect(cv.projects.single.name, 'Finance‑first');
  });

  test('Experience follows Projects and shares circular multiline bullet style',
      () async {
    final cv = _businessProfile().copyWith(
      projects: const [
        CvProjectItem(
            name: 'Finance Study',
            description: '• First project point\n- Second project point')
      ],
      experience: const [
        CvExperienceItem(
            role: 'Business Analyst',
            company: 'Sample Firm',
            period: '2024 - 2025',
            description: '– First work point\n— Second work point')
      ],
      references: [
        ..._businessProfile().references,
        const CvReferenceItem(
            name: 'Dr. Nabila Karim',
            designation: 'Assistant Professor',
            organization: 'School of Business\nCommunity University',
            email: 'nabila@example.com'),
      ],
      achievements: const [
        CvAchievementItem(
            title: 'Business Award',
            description: '• Award point\nAnother award point')
      ],
    );
    final bytes = await CvPdfService.instance.buildPdf(cv);
    final text = extractPdfText(bytes);
    expect(text.indexOf('Projects'), lessThan(text.indexOf('Experience')));
    expect(text.indexOf('Experience'),
        lessThan(text.indexOf('Achievements & Certifications')));
    for (final point in [
      'First project point',
      'Second project point',
      'First work point',
      'Second work point',
      'Award point',
      'Another award point'
    ]) {
      expect(text, contains('• $point'));
    }
    expect('•'.allMatches(text).length,
        7); // Six descriptions plus education result.
    expect(latin1.decode(bytes), contains('/FontFile2'));
    expect(latin1.decode(bytes), contains('/CareerBridgeLMRoman10-Regular'));
    expect(latin1.decode(bytes), contains('/CareerBridgeLMRoman10-Bold'));
    expect(_pageCount(bytes), 1);
    expect(text, contains('Dr. Nabila Karim'));
    await _writeQa('reference-experience.pdf', bytes);
  });

  test('LaTeX reference supports aligned metadata and paired references',
      () async {
    final cv = CvProfileModel(
      ownerUid: 'template-review',
      fullName: 'Your Full Name',
      email: 'youremail@gmail.com',
      phone: '+880 1XXX-XXXXXX',
      location: 'House XX, Road XX, Mirpur, Dhaka-1216',
      linkedInUrl: 'linkedin.com/in/your-profile',
      portfolioUrl: 'github.com/yourusername',
      education: const [
        CvEducationItem(
            degree: 'Bachelor of Computer Science and Engineering',
            institution: 'Bangladesh University of Professionals (BUP)',
            institutionUrl: 'https://bup.edu.bd/',
            location: 'Dhaka, Bangladesh',
            period: 'Jun 2023 – Jul 2027 (Expected)',
            result: 'CGPA: X.XX / 4.00 (up to Nth semester)'),
        CvEducationItem(
            degree: 'Higher Secondary Certificate (HSC)',
            institution: 'Saint Joseph Higher Secondary School',
            institutionUrl: 'https://sjs.edu.bd/new/index.php',
            location: 'Dhaka, Bangladesh',
            period: '2020 – 2022',
            result: 'GPA: X.XX / 5.00',
            details: 'Group: Science'),
        CvEducationItem(
            degree: 'Secondary School Certificate (SSC)',
            institution: 'Islamee Adarsha Uchch Bidyalay',
            institutionUrl:
                'https://locator.eduportalbd.com/institutes/?ins=108190',
            location: 'City, Bangladesh',
            period: '2018 – 2020',
            result: 'GPA: X.XX / 5.00',
            details: 'Group: Science'),
      ],
      technicalLanguages: const [
        'C',
        'C++',
        'Python',
        'Java',
        'JavaScript',
        'PHP',
        'HTML5',
        'CSS3',
        'SQL'
      ],
      frameworks: const [
        'React.js',
        'Node.js',
        'Express.js',
        'Laravel',
        'Spring Boot',
        'Tailwind CSS',
        'PostgreSQL',
        'MongoDB'
      ],
      toolsAndPlatforms: const [
        'Git',
        'GitHub',
        'VS Code',
        'Postman',
        'Docker',
        'Linux'
      ],
      projects: const [
        CvProjectItem(
            name: 'Arkanoid Game',
            link: 'https://github.com/zishahed/Arkanoid-game-with-Raylib',
            toolsAndMethods: 'C | Raylib',
            description: 'Only one sentence description'),
        CvProjectItem(
            name: 'PharmaZen',
            link: 'https://github.com/zishahed/pharmazen-website',
            toolsAndMethods:
                'React.js | Node.js | Express.js | PostgreSQL | Prisma',
            description:
                'Building a secure, role-based online pharmacy system for the Bangladeshi market, supporting medicine browsing, prescription upload, and bKash payment processing.'),
      ],
      experience: const [
        CvExperienceItem(
            role: 'Research Assistant',
            company: 'Research Center',
            period: 'Jan 2025 – Dec 2025',
            description:
                'Documented research methods and presented findings to the team.')
      ],
      achievements: const [
        CvAchievementItem(
            title: 'Certification Title',
            qualifier: 'Brief Qualifier',
            date: 'Month Year',
            description:
                'Description of the achievement, its scope, and what it demonstrates.')
      ],
      references: const [
        CvReferenceItem(
            name: 'Iyolita Islam',
            designation: 'Lecturer',
            organization:
                'Department of Computer Science & Engineering\nBangladesh University of Professionals',
            email: 'iyolitaislam@bup.edu.bd'),
        CvReferenceItem(
            name: 'Rumana Yasmin',
            designation: 'Lecturer',
            organization:
                'Department of Computer Science & Engineering\nBangladesh University of Professionals',
            email: 'rumana.yasmin@bup.edu.bd'),
      ],
      updatedAt: DateTime(2026, 10, 11),
    );
    final bytes = await CvPdfService.instance.buildPdf(cv);
    final text = extractPdfText(bytes);
    expect(text, contains('C | Raylib'));
    expect(text, contains('Research Assistant'));
    expect(text, contains('Rumana Yasmin'));
    expect(text, isNot(contains('Ongoing')));
    expect(latin1.decode(bytes), contains('https://bup.edu.bd/'));
    expect(latin1.decode(bytes), contains('/CareerBridgeLMRoman12-Bold'));
    expect(latin1.decode(bytes), contains('/FontAwesome5Free-Solid'));
    await _writeQa('reference-template.pdf', bytes);
  });

  test('PDF prepared for upload keeps a safe name and correct MIME type',
      () async {
    final file = await CvPdfService.instance.prepareForUpload(
        _businessProfile().copyWith(fullName: 'Amina / Rahman'));

    expect(file.fileName, 'Amina___Rahman_CV.pdf');
    expect(file.mimeType, 'application/pdf');
    expect(String.fromCharCodes(file.bytes.take(4)), '%PDF');
  });
}

CvProfileModel _businessProfile({String photoDataUrl = ''}) => CvProfileModel(
      ownerUid: 'business-student',
      fullName: 'Amina Rahman',
      professionalSummary: 'Business student with financial modeling skills.',
      email: 'amina@example.com',
      phone: '+880 1700-000000',
      location: 'Dhaka, Bangladesh',
      linkedInUrl: 'linkedin.com/in/amina',
      portfolioUrl: 'https://example.com/amina',
      photoDataUrl: photoDataUrl,
      education: const [
        CvEducationItem(
          degree: 'Bachelor of Business Administration',
          institution: 'National University',
          institutionUrl: 'https://example.com/university',
          period: '2022 - 2026',
          location: 'Dhaka, Bangladesh',
          result: 'CGPA: 3.75 / 4.00',
          details: 'Major: Finance',
        ),
      ],
      technicalLanguages: const ['SQL'],
      toolsAndPlatforms: const ['Microsoft Excel', 'SPSS'],
      projects: const [
        CvProjectItem(
          name: 'Community Business Survey',
          toolsAndMethods: 'Excel | Survey research',
          description: 'Analyzed 250 local businesses and presented findings.',
          link: 'https://example.com/survey',
        ),
      ],
      achievements: const [
        CvAchievementItem(
          title: 'Financial Modeling',
          qualifier: 'Professional Certificate',
          date: 'December 2025',
          description: 'Completed a practical course in financial analysis.',
        ),
      ],
      references: const [
        CvReferenceItem(
          name: 'Dr. Hasan Ahmed',
          designation: 'Professor',
          organization: 'Department of Business Studies',
          email: 'hasan@example.com',
          phone: '+880 1800-000000',
        ),
      ],
      languages: const ['Bangla', 'English'],
      updatedAt: DateTime(2026, 10, 11),
    );

String _photo() {
  final picture = image.Image(width: 70, height: 82);
  image.fill(picture, color: image.ColorRgb8(229, 235, 240));
  image.fillCircle(picture,
      x: 35, y: 28, radius: 13, color: image.ColorRgb8(105, 117, 132));
  image.fillRect(picture,
      x1: 14, y1: 48, x2: 56, y2: 81, color: image.ColorRgb8(105, 117, 132));
  return 'data:image/png;base64,${base64Encode(image.encodePng(picture))}';
}

int _pageCount(Uint8List bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length;

Future<void> _writeQa(String name, Uint8List bytes) async {
  final destination = Platform.environment['CV_PDF_QA_DIR'];
  if (destination == null || destination.isEmpty) return;
  final directory = Directory(destination);
  await directory.create(recursive: true);
  await File('${directory.path}/$name').writeAsBytes(bytes);
}
