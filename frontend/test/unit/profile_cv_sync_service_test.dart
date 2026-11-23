import 'dart:convert';
import 'dart:typed_data';

import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/cv_builder/data/models/cv_profile_model.dart';
import 'package:career_bridge/features/cv_builder/services/profile_cv_sync_service.dart';
import 'package:career_bridge/features/job_seeker/controllers/job_seeker_workspace_controller.dart';
import 'package:career_bridge/features/job_seeker/data/models/job_seeker_profile_model.dart';
import 'package:career_bridge/features/job_seeker/data/repositories/demo_job_seeker_workspace_repository.dart';
import 'package:career_bridge/features/jobs/data/models/job_model.dart';
import 'package:career_bridge/features/jobs/services/job_recommendation_service.dart';
import 'package:career_bridge/features/public_portal/controllers/public_portal_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final updatedAt = DateTime(2026, 10, 11);
  JobSeekerProfileModel profile() => JobSeekerProfileModel(
        uid: 'any-background',
        fullName: 'Samira Ahmed',
        email: 'samira@example.com',
        hasCvDetails: true,
        hasCvExperience: true,
        education: const [
          CvEducationItem(
            degree: 'BA in Sociology',
            institution: 'Community University',
            institutionUrl: 'https://example.com/community-university',
            period: '2021 - 2025',
            location: 'Dhaka',
            result: 'First Class',
            details: 'Research methods and community development',
          ),
        ],
        toolsAndPlatforms: const ['Excel', 'SPSS'],
        projects: const [
          CvProjectItem(
              name: 'Community survey',
              description: 'Field research',
              toolsAndMethods: 'SPSS | Field interviews'),
        ],
        experience: const [
          CvExperienceItem(
            role: 'Research Assistant',
            company: 'Community Research Center',
            period: '2025 - 2026',
            description: 'Designed community surveys\nAnalyzed social data',
          ),
        ],
        achievements: const [
          CvAchievementItem(
              title: 'Research Award', qualifier: 'Research Center'),
        ],
        references: const [
          CvReferenceItem(
              name: 'Dr. Amina', designation: 'Research Supervisor'),
        ],
        linkedInUrl: 'https://linkedin.com/in/samira',
        portfolioUrl: 'https://example.com/samira',
        updatedAt: updatedAt,
      );
  CvProfileModel cv() => CvProfileModel(
        ownerUid: 'any-background',
        fullName: 'Old name',
        email: 'old@example.com',
        updatedAt: updatedAt,
      );

  test('non-computing profile persists and fills all template sections', () {
    final original = profile();
    final restored = JobSeekerProfileModel.fromFirestore(
      original.uid,
      original.toFirestore(),
      fallbackName: '',
      fallbackEmail: '',
    );
    final synced =
        ProfileCvSyncService.sync(profile: restored, currentCv: cv());

    expect(restored.hasCvDetails, isTrue);
    expect(synced.fullName, original.fullName);
    expect(synced.education.single.degree, 'BA in Sociology');
    expect(synced.education.single.result, 'First Class');
    expect(synced.education.single.details, contains('community development'));
    expect(synced.toolsAndPlatforms, ['Excel', 'SPSS']);
    expect(synced.technicalLanguages, isEmpty);
    expect(synced.frameworks, isEmpty);
    expect(synced.projects.single.name, 'Community survey');
    expect(synced.projects.single.toolsAndMethods, 'SPSS | Field interviews');
    expect(synced.education.single.institutionUrl,
        'https://example.com/community-university');
    expect(restored.hasCvExperience, isTrue);
    expect(synced.experience.single.role, 'Research Assistant');
    expect(synced.experience.single.company, 'Community Research Center');
    expect(synced.experience.single.description,
        'Designed community surveys\nAnalyzed social data');
    expect(synced.achievements.single.title, 'Research Award');
    expect(synced.references.single.name, 'Dr. Amina');
    expect(synced.linkedInUrl, original.linkedInUrl);
    expect(synced.portfolioUrl, original.portfolioUrl);
  });

  test('deliberately cleared sections stay empty after sync and restore', () {
    final populated =
        ProfileCvSyncService.sync(profile: profile(), currentCv: cv());
    final cleared = profile().copyWith(
      education: [],
      toolsAndPlatforms: [],
      projects: [],
      experience: [],
      achievements: [],
      references: [],
      educationSummary: 'Legacy summary must not restore removed education',
    );
    final restored = JobSeekerProfileModel.fromFirestore(
      cleared.uid,
      cleared.toFirestore(),
      fallbackName: '',
      fallbackEmail: '',
    );
    final synced = ProfileCvSyncService.sync(
      profile: restored,
      currentCv: populated,
      previousProfile: profile(),
    );

    expect(synced.education, isEmpty);
    expect(synced.toolsAndPlatforms, isEmpty);
    expect(synced.projects, isEmpty);
    expect(synced.experience, isEmpty);
    expect(synced.achievements, isEmpty);
    expect(synced.references, isEmpty);
  });

  test('legacy profiles preserve manually entered CV details', () {
    final legacy = JobSeekerProfileModel.fromFirestore(
      'any-background',
      {'fullName': 'Samira Ahmed', 'educationSummary': 'BA at Other Institute'},
      fallbackName: '',
      fallbackEmail: 'samira@example.com',
    );
    final manual =
        ProfileCvSyncService.sync(profile: profile(), currentCv: cv());
    final synced =
        ProfileCvSyncService.sync(profile: legacy, currentCv: manual);

    expect(legacy.hasCvDetails, isFalse);
    expect(synced.education.single.institution, 'Community University');
    expect(synced.toolsAndPlatforms, ['Excel', 'SPSS']);
    expect(synced.projects.single.name, 'Community survey');
    expect(synced.experience.single.role, 'Research Assistant');
    expect(synced.references.single.name, 'Dr. Amina');
  });

  test(
      'older structured profiles preserve CV experience until explicitly edited',
      () {
    final oldStructured = JobSeekerProfileModel.fromFirestore(
      'any-background',
      {'fullName': 'Samira Ahmed', 'hasCvDetails': true},
      fallbackName: '',
      fallbackEmail: 'samira@example.com',
    );
    final manual =
        ProfileCvSyncService.sync(profile: profile(), currentCv: cv());
    final unchanged = ProfileCvSyncService.sync(
      profile: oldStructured.copyWith(phone: '12345'),
      currentCv: manual,
    );
    expect(oldStructured.hasCvExperience, isFalse);
    expect(unchanged.experience.single.role, 'Research Assistant');

    final cleared = oldStructured.copyWith(experience: []);
    final restored = JobSeekerProfileModel.fromFirestore(
      cleared.uid,
      cleared.toFirestore(),
      fallbackName: '',
      fallbackEmail: '',
    );
    expect(restored.hasCvExperience, isTrue);
    expect(
        ProfileCvSyncService.sync(profile: restored, currentCv: manual)
            .experience,
        isEmpty);

    final emptyField = JobSeekerProfileModel.fromFirestore(
      'any-background',
      {'hasCvDetails': true, 'experience': []},
      fallbackName: '',
      fallbackEmail: '',
    );
    expect(emptyField.hasCvExperience, isTrue);
    expect(
        ProfileCvSyncService.sync(profile: emptyField, currentCv: manual)
            .experience,
        isEmpty);
  });

  test(
      'optional experience improves strength without reducing a new applicant profile',
      () {
    final withoutExperience = profile().copyWith(experience: []);
    expect(profile().completion, greaterThan(withoutExperience.completion));
    expect(withoutExperience.completion,
        withoutExperience.copyWith(hasCvExperience: false).completion);
  });

  test('unused editor rows do not add blank CV sections', () {
    final edited = cv().copyWith(
      education: [
        const CvEducationItem(degree: ' ', institution: '', period: '')
      ],
      projects: [const CvProjectItem(name: '', description: '')],
      experience: [
        const CvExperienceItem(
            role: '', company: '', period: '', description: '')
      ],
      achievements: [const CvAchievementItem(title: '')],
      references: [const CvReferenceItem(name: '')],
      toolsAndPlatforms: [' Excel ', '', 'Excel'],
    );
    final normalized = ProfileCvSyncService.normalizeDetails(edited);
    expect(normalized.education, isEmpty);
    expect(normalized.projects, isEmpty);
    expect(normalized.experience, isEmpty);
    expect(normalized.achievements, isEmpty);
    expect(normalized.references, isEmpty);
    expect(normalized.toolsAndPlatforms, ['Excel']);
  });

  test('profile export photo is a compact JPEG with its aspect ratio retained',
      () {
    final source = img.Image(width: 800, height: 1200);
    final bytes = Uint8List.fromList(img.encodePng(source));
    final dataUrl = ProfileCvSyncService.photoThumbnailDataUrl(bytes);
    final encoded = base64Decode(dataUrl.split(',').last);
    final thumbnail = img.decodeImage(encoded)!;

    expect(dataUrl, startsWith('data:image/jpeg;base64,'));
    expect(thumbnail.height, 320);
    expect(thumbnail.width, closeTo(320 * 800 / 1200, 1));
    expect(encoded.length, lessThan(100000));
  });

  test('technical categories rank jobs without requiring frameworks', () {
    const job = JobModel(
      id: 'research',
      companyId: 'research-center',
      companyName: 'Research Center',
      title: 'Research Assistant',
      category: 'Research',
      location: 'Dhaka',
      workMode: 'On-site',
      employmentType: 'Full-time',
      experience: 'Entry level',
      salaryLabel: 'Negotiable',
      salaryMax: 0,
      postedLabel: 'Today',
      deadlineLabel: 'Open',
      openings: 1,
      description: 'Analyze surveys',
      responsibilities: [],
      requirements: ['SPSS'],
      benefits: [],
      skills: ['SPSS'],
    );
    final match = JobRecommendationService.recommendationFor(
      job: job,
      profile: profile(),
    );
    expect(match.score, greaterThanOrEqualTo(48));
    expect(match.reasons, contains('1 skill match'));
  });

  test('profile and builder edits survive saves and workspace reloads',
      () async {
    await AuthController.instance.resetForTesting();
    final workspace = JobSeekerWorkspaceController.instance;
    workspace.resetForTesting();
    PublicPortalController.instance.resetForTesting();
    await AuthController.instance.signIn(
      email: 'jobseeker@careerbridge.demo',
      password: 'Demo123!',
      expectedRole: UserRole.jobSeeker,
    );
    await workspace.ensureLoaded();
    final initial = workspace.profile!;
    await workspace.saveProfile(initial.copyWith(
      hasCvDetails: true,
      frameworks: const [],
      toolsAndPlatforms: profile().toolsAndPlatforms,
      projects: profile().projects,
      experience: profile().experience,
      education: profile().education,
      achievements: profile().achievements,
      references: profile().references,
    ));
    expect(workspace.cvProfile!.projects.single.name, 'Community survey');
    expect(workspace.cvProfile!.experience.single.role, 'Research Assistant');
    expect(workspace.cvProfile!.frameworks, isEmpty);
    final spokenLanguages = workspace.cvProfile!.languages;

    await workspace.saveCvProfile(workspace.cvProfile!.copyWith(
      professionalSummary: '',
      projects: [
        const CvProjectItem(
            name: 'Updated survey', description: 'Published research')
      ],
      references: [],
      experience: [
        const CvExperienceItem(
            role: 'Lead Researcher',
            company: 'Research Center',
            period: '2026',
            description: 'Led field studies\nPublished reports')
      ],
    ));
    expect(workspace.profile!.projects.single.name, 'Updated survey');
    expect(workspace.profile!.experience.single.role, 'Lead Researcher');
    expect(workspace.profile!.about, initial.about);
    expect(workspace.cvProfile!.professionalSummary, isEmpty);
    expect(workspace.cvProfile!.languages, spokenLanguages);
    expect(workspace.profile!.headline, initial.headline);
    expect(workspace.profile!.preferredRoles, initial.preferredRoles);
    await workspace.refresh();
    expect(workspace.profile!.about, initial.about);
    expect(workspace.cvProfile!.professionalSummary, isEmpty);
    expect(workspace.cvProfile!.languages, spokenLanguages);
    await workspace
        .saveProfile(workspace.profile!.copyWith(fullName: 'Updated Name'));
    expect(workspace.cvProfile!.fullName, 'Updated Name');
    expect(workspace.cvProfile!.projects.single.name, 'Updated survey');
    expect(workspace.cvProfile!.references, isEmpty);
    expect(workspace.cvProfile!.experience.single.role, 'Lead Researcher');
    await workspace
        .saveCvProfile(workspace.cvProfile!.copyWith(experience: []));
    await workspace.refresh();
    expect(workspace.profile!.hasCvExperience, isTrue);
    expect(workspace.profile!.experience, isEmpty);
    expect(workspace.cvProfile!.experience, isEmpty);
  });

  test('an invalid paired save leaves both existing records unchanged',
      () async {
    final repository = DemoJobSeekerWorkspaceRepository();
    final original = await repository.load(
      uid: 'any-background',
      name: 'Original name',
      email: 'old@example.com',
    );
    final wrongOwnerCv = CvProfileModel(
      ownerUid: 'another-user',
      fullName: 'Wrong owner',
      email: 'wrong@example.com',
      updatedAt: updatedAt,
    );
    await expectLater(
      repository.saveProfileAndCv(profile: profile(), cvProfile: wrongOwnerCv),
      throwsArgumentError,
    );
    final after = await repository.load(
      uid: 'any-background',
      name: 'Fallback name',
      email: 'fallback@example.com',
    );
    expect(after.profile, same(original.profile));
    expect(after.cvProfile, same(original.cvProfile));
  });
}
