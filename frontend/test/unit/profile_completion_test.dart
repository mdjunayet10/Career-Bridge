import 'package:career_bridge/features/job_seeker/data/models/job_seeker_profile_model.dart';
import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  JobSeekerProfileModel complete() => JobSeekerProfileModel(
      uid: 'test',
      fullName: 'Samira Ahmed',
      email: 'samira@example.org',
      headline: 'Research assistant',
      phone: '+8801712345678',
      location: 'Dhaka',
      about: 'I study communities and analyze survey results.',
      educationSummary: 'BA in Sociology, Community University, 2025',
      skills: ['Research', 'Excel', 'SPSS'],
      preferredRoles: ['Research assistant'],
      preferredLocations: ['Dhaka'],
      workModes: ['Hybrid'],
      linkedInUrl: 'https://linkedin.com/in/samira',
      profileImageFileId: 'uploaded-photo',
      updatedAt: DateTime(2026));
  test('missing photo and placeholder references cannot earn 100 percent', () {
    final incomplete = complete().copyWith(profileImageFileId: '', references: [
      const CvReferenceItem(name: 'Available on request (Demo)')
    ]);
    expect(incomplete.completionPercent, lessThan(100));
    expect(incomplete.completion, lessThan(complete().completion));
  });
  test('complete first-time applicant needs no optional employment or awards',
      () {
    expect(complete().completionPercent, 100);
  });
  test('blank education row does not count as completed education', () {
    expect(
        complete().copyWith(
            hasCvDetails: true,
            educationSummary: '',
            education: [
              const CvEducationItem(degree: '', institution: '', period: '')
            ]).completionPercent,
        lessThan(100));
  });
  test('partial supplied experience counts only after details are filled', () {
    final partial = complete().copyWith(experience: [
      const CvExperienceItem(
          role: 'Intern', company: '', period: '', description: '')
    ]);
    final filled = partial.copyWith(experience: [
      const CvExperienceItem(
          role: 'Intern',
          company: 'Research Centre',
          period: '2026',
          description: 'Analyzed surveys')
    ]);
    expect(partial.completion, lessThan(filled.completion));
    expect(filled.completionPercent, 100);
  });
  test('example links and whitespace skill rows are not complete details', () {
    final partial = complete().copyWith(
        linkedInUrl: 'https://example.com/your-profile',
        skills: ['Research', ' ', '']);
    expect(partial.completionPercent, lessThan(100));
  });
}
