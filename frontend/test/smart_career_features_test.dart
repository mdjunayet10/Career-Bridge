import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:career_bridge/features/cv_builder/services/profile_cv_sync_service.dart';
import 'package:career_bridge/features/job_seeker/data/models/job_seeker_profile_model.dart';
import 'package:career_bridge/features/jobs/data/models/job_model.dart';
import 'package:career_bridge/features/jobs/services/job_recommendation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile to CV sync', () {
    test('fills CV identity, summary, skills, and education from profile', () {
      final previous = JobSeekerProfileModel(
        uid: 'user-1',
        fullName: 'Old Name',
        email: 'old@example.com',
        educationSummary: 'BSc in CSE at BUP (2023 - Present)',
        updatedAt: DateTime(2026, 9, 1),
      );
      final profile = previous.copyWith(
        fullName: 'Md Junayet',
        email: 'junayet@example.com',
        phone: '+8801700000000',
        location: 'Dhaka',
        about: 'Flutter developer focused on Firebase products.',
        skills: const ['Flutter', 'Dart', 'Firebase'],
        updatedAt: DateTime(2026, 9, 5),
      );
      final currentCv = CvProfileModel(
        ownerUid: 'user-1',
        fullName: 'Old Name',
        email: 'old@example.com',
        education: const [
          CvEducationItem(
            degree: 'BSc in CSE',
            institution: 'BUP',
            period: '2023 - Present',
          ),
        ],
        projects: const [
          CvProjectItem(
            name: 'Career Bridge',
            description: 'Recruitment platform',
          ),
        ],
        updatedAt: DateTime(2026, 9, 1),
      );

      final synced = ProfileCvSyncService.sync(
        profile: profile,
        currentCv: currentCv,
        previousProfile: previous,
      );

      expect(synced.fullName, 'Md Junayet');
      expect(synced.phone, '+8801700000000');
      expect(synced.location, 'Dhaka');
      expect(synced.professionalSummary, contains('Flutter developer'));
      expect(synced.skills, containsAll(['Flutter', 'Dart', 'Firebase']));
      expect(synced.education.single.institution, 'BUP');
      expect(synced.projects.single.name, 'Career Bridge');
    });

    test('preserves manually edited CV education', () {
      final profile = JobSeekerProfileModel(
        uid: 'user-1',
        fullName: 'Md Junayet',
        email: 'junayet@example.com',
        educationSummary: 'BSc in CSE at BUP',
        updatedAt: DateTime(2026, 9, 5),
      );
      final currentCv = CvProfileModel(
        ownerUid: 'user-1',
        fullName: 'Md Junayet',
        email: 'junayet@example.com',
        education: const [
          CvEducationItem(
            degree: 'Bachelor of Science in Computer Science',
            institution: 'Custom University Entry',
            period: '2023 - 2027',
          ),
        ],
        updatedAt: DateTime(2026, 9, 4),
      );

      final synced = ProfileCvSyncService.sync(
        profile: profile,
        currentCv: currentCv,
      );

      expect(synced.education.single.institution, 'Custom University Entry');
    });
  });

  test('CV skills and preferences rank a relevant job above an unrelated job',
      () {
    final profile = JobSeekerProfileModel(
      uid: 'user-1',
      fullName: 'Md Junayet',
      email: 'junayet@example.com',
      headline: 'Flutter Developer',
      location: 'Dhaka',
      about: 'I build Flutter apps with Firebase.',
      skills: const ['Flutter', 'Dart', 'Firebase', 'Git'],
      preferredRoles: const ['Flutter Developer'],
      preferredLocations: const ['Dhaka'],
      workModes: const ['Hybrid'],
      updatedAt: DateTime(2026, 9, 5),
    );
    final cv = CvProfileModel(
      ownerUid: 'user-1',
      fullName: 'Md Junayet',
      email: 'junayet@example.com',
      professionalSummary: 'Flutter developer with Firebase experience.',
      skills: const ['Flutter', 'Dart', 'Firebase', 'Git'],
      updatedAt: DateTime(2026, 9, 5),
    );

    final flutterJob = _job(
      id: 'flutter',
      title: 'Flutter Developer',
      category: 'Technology',
      skills: const ['Flutter', 'Dart', 'Firebase', 'Git'],
      location: 'Dhaka',
      workMode: 'Hybrid',
    );
    final financeJob = _job(
      id: 'finance',
      title: 'Finance Officer',
      category: 'Finance',
      skills: const ['Accounting', 'Excel', 'Reporting'],
      location: 'Dhaka',
      workMode: 'On-site',
    );

    final ranked = JobRecommendationService.rankJobs(
      jobs: [financeJob, flutterJob],
      profile: profile,
      cvProfile: cv,
    );

    expect(ranked.first.job.id, 'flutter');
    expect(ranked.first.score, greaterThan(ranked.last.score));
    expect(ranked.first.reasons, isNotEmpty);
  });
}

JobModel _job({
  required String id,
  required String title,
  required String category,
  required List<String> skills,
  required String location,
  required String workMode,
}) {
  return JobModel(
    id: id,
    companyId: 'company-$id',
    companyName: 'Company $id',
    title: title,
    category: category,
    location: location,
    workMode: workMode,
    employmentType: 'Full-time',
    experience: 'Entry level',
    salaryLabel: '৳40k–60k / month',
    salaryMax: 60000,
    postedLabel: 'Today',
    deadlineLabel: '30 Sep 2026',
    openings: 1,
    description: 'A role for motivated candidates with relevant skills.',
    responsibilities: const ['Build reliable work with the team.'],
    requirements: skills,
    benefits: const ['Learning budget'],
    skills: skills,
  );
}
