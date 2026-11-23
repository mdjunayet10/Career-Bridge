import '../../../demo/data/demo_application_store.dart';
import '../../../auth/data/demo_account_catalog.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/application_status.dart';
import '../../../../core/services/cv_pdf_service.dart';
import '../../../file_storage/data/repositories/demo_file_object_repository.dart';
import '../../../applications/data/models/application_model.dart';
import '../../../cv_builder/data/models/cv_profile_model.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../jobs/data/models/job_model.dart';
import '../models/job_seeker_profile_model.dart';
import 'job_seeker_workspace_repository.dart';

class DemoJobSeekerWorkspaceRepository implements JobSeekerWorkspaceRepository {
  final Map<String, JobSeekerProfileModel> _profiles = {};
  final Map<String, Set<String>> _savedJobs = {};
  final Map<String, List<ApplicationModel>> _applications = {};
  final Map<String, List<NotificationModel>> _notifications = {};
  final Map<String, CvProfileModel> _cvProfiles = {};

  Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 260));

  @override
  Future<JobSeekerWorkspaceSnapshot> load({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _wait();
    _seedIfNeeded(uid: uid, name: name, email: email);
    return JobSeekerWorkspaceSnapshot(
      profile: _profiles[uid]!,
      savedJobIds: Set<String>.from(_savedJobs[uid]!),
      applications: DemoApplicationStore.instance.mergeApplications(
          _applications[uid]!, (app) => app.applicantUid == uid),
      notifications: DemoApplicationStore.instance
          .mergeNotifications(_notifications[uid]!, uid),
      cvProfile: _cvProfiles[uid]!,
    );
  }

  void _seedIfNeeded(
      {required String uid, required String name, required String email}) {
    if (_profiles.containsKey(uid)) return;
    final account = DemoAccountCatalog.byUid(uid);
    if (account != null &&
        account.role == UserRole.jobSeeker &&
        uid != 'demo-job-seeker') {
      _seedCatalogAccount(account);
      return;
    }
    final now = DateTime(2026, 8, 6, 10, 30);
    final isDemo = uid == 'demo-job-seeker';

    _profiles[uid] = JobSeekerProfileModel(
      uid: uid,
      fullName: name,
      email: email,
      headline:
          isDemo ? 'Flutter & Firebase Developer · CSE Student (Demo)' : '',
      phone: isDemo ? '+880 1700-000000' : '',
      location: isDemo ? 'Dhaka, Bangladesh' : '',
      about: isDemo
          ? 'Demo profile for Career Bridge: a Computer Science student interested in mobile app development, accessible UI, Firebase, and collaborative software engineering.'
          : '',
      educationSummary: isDemo
          ? 'BSc in Computer Science & Engineering · Sample University (Demo)'
          : '',
      experienceYears: isDemo ? 1 : 0,
      skills: isDemo
          ? const [
              'Flutter',
              'Dart',
              'Firebase',
              'Git',
              'REST APIs',
              'SQL',
              'UI Testing'
            ]
          : const [],
      preferredRoles: isDemo
          ? const ['Flutter Developer', 'Mobile App Developer']
          : const [],
      preferredLocations: isDemo ? const ['Dhaka', 'Remote'] : const [],
      workModes: isDemo ? const ['Remote', 'Hybrid'] : const [],
      linkedInUrl: isDemo ? 'https://example.com/demo-linkedin' : '',
      portfolioUrl: isDemo ? 'https://example.com/demo-portfolio' : '',
      hasCvDetails: isDemo,
      hasCvExperience: isDemo,
      education: isDemo
          ? const [
              CvEducationItem(
                  degree: 'BSc in Computer Science and Engineering',
                  institution: 'Sample University (Demo)',
                  period: '2023 – Present',
                  location: 'Dhaka, Bangladesh',
                  details: 'Software Engineering, Databases, Networking, HCI')
            ]
          : const [],
      technicalLanguages: isDemo ? const ['Dart', 'Python', 'SQL'] : const [],
      frameworks: isDemo ? const ['Flutter', 'Firebase'] : const [],
      toolsAndPlatforms:
          isDemo ? const ['Git', 'GitHub', 'Figma', 'REST APIs'] : const [],
      projects: isDemo
          ? const [
              CvProjectItem(
                  name: 'Career Bridge (Academic Demo)',
                  description:
                      'Flutter + Firebase career platform with job search, applicant tracking and CV Builder.',
                  toolsAndMethods: 'Flutter, Firebase, Git')
            ]
          : const [],
      experience: isDemo
          ? const [
              CvExperienceItem(
                  role: 'Mobile App Developer (Demo project)',
                  company: 'Academic Project Team (Demo)',
                  period: '2025 – 2026',
                  description:
                      'Designed responsive screens and integrated authentication and Firestore workflows for demonstration.')
            ]
          : const [],
      achievements: isDemo
          ? const [
              CvAchievementItem(
                  title: 'Career Bridge Project Demonstration',
                  qualifier: 'Academic demo',
                  date: '2026',
                  description:
                      'Showcase item; not an independently verified credential.')
            ]
          : const [],
      references: isDemo
          ? const [CvReferenceItem(name: 'Available on request (Demo)')]
          : const [],
      updatedAt: now,
    );

    _savedJobs[uid] = isDemo
        ? <String>{
            'flutter-developer-novatech',
            'demo-pixelharbor-studio-opportunity',
            'demo-bengal-dataworks-opportunity',
          }
        : <String>{};

    _applications[uid] = isDemo
        ? <ApplicationModel>[
            ApplicationModel(
              id: 'demo-app-flutter',
              jobId: 'flutter-developer-novatech',
              companyId: 'demo-novatech-bangladesh',
              companyName: 'NovaTech Bangladesh (Demo)',
              jobTitle: 'Flutter Developer',
              applicantUid: uid,
              status: ApplicationStatus.shortlisted,
              coverLetter:
                  'I have built multiple Flutter projects and would love to contribute to NovaTech.',
              cvProfileId: uid,
              employerNote:
                  'Strong mobile portfolio. Shortlisted for technical review.',
              createdAt: DateTime(2026, 8, 1, 11, 15),
              updatedAt: DateTime(2026, 8, 5, 16, 30),
            ),
            ApplicationModel(
              id: 'demo-app-data',
              jobId: 'demo-bengal-dataworks-opportunity',
              companyId: 'demo-bengal-dataworks',
              companyName: 'Bengal DataWorks (Demo)',
              jobTitle: 'Junior Data Analyst',
              applicantUid: uid,
              status: ApplicationStatus.reviewed,
              coverLetter:
                  'My coursework includes data analysis, SQL, and dashboard projects.',
              cvProfileId: uid,
              createdAt: DateTime(2026, 8, 2, 9, 40),
              updatedAt: DateTime(2026, 8, 4, 14, 10),
            ),
            ApplicationModel(
              id: 'demo-app-customer-success',
              jobId: 'demo-carenest-health-opportunity',
              companyId: 'demo-carenest-health',
              companyName: 'CareNest Health (Demo)',
              jobTitle: 'Customer Support Specialist',
              applicantUid: uid,
              status: ApplicationStatus.interview,
              coverLetter:
                  'I enjoy helping users and communicating technical ideas clearly.',
              cvProfileId: uid,
              employerNote:
                  'Online interview scheduled. Please join 10 minutes early.',
              interviewAt: DateTime(2026, 8, 10, 15, 0),
              createdAt: DateTime(2026, 7, 29, 12, 5),
              updatedAt: DateTime(2026, 8, 5, 18, 20),
            ),
          ]
        : <ApplicationModel>[];

    _notifications[uid] = isDemo
        ? <NotificationModel>[
            NotificationModel(
              id: 'recommendation-demo-flutter',
              recipientUid: uid,
              title: 'New job match found',
              message:
                  'Flutter Developer at NovaTech Bangladesh may be a good fit for your profile.',
              type: 'recommendation',
              isRead: false,
              actionRoute: '/jobs/flutter-developer-novatech',
              createdAt: DateTime(2026, 8, 6, 9, 15),
            ),
            NotificationModel(
              id: 'notification-interview',
              recipientUid: uid,
              title: 'Interview scheduled',
              message:
                  'CareNest Health (Demo) scheduled your interview for 10 August at 3:00 PM.',
              type: 'interview',
              isRead: false,
              actionRoute: '/job-seeker/applications/demo-app-customer-success',
              applicationId: 'demo-app-customer-success',
              createdAt: DateTime(2026, 8, 5, 18, 20),
            ),
            NotificationModel(
              id: 'notification-shortlist',
              recipientUid: uid,
              title: 'You were shortlisted',
              message:
                  'NovaTech Bangladesh shortlisted your Flutter Developer application.',
              type: 'application',
              isRead: false,
              actionRoute: '/job-seeker/applications/demo-app-flutter',
              applicationId: 'demo-app-flutter',
              createdAt: DateTime(2026, 8, 5, 16, 30),
            ),
            NotificationModel(
              id: 'notification-profile',
              recipientUid: uid,
              title: 'Complete your career profile',
              message:
                  'Add preferred roles and a stronger summary to improve recommendations.',
              type: 'profile',
              isRead: true,
              actionRoute: '/job-seeker/profile',
              createdAt: DateTime(2026, 8, 3, 10),
            ),
          ]
        : <NotificationModel>[];

    _cvProfiles[uid] = CvProfileModel(
      ownerUid: uid,
      fullName: name,
      email: email,
      phone: isDemo ? '+880 1700-000000' : '',
      location: isDemo ? 'Dhaka, Bangladesh' : '',
      linkedInUrl: isDemo ? 'https://example.com/demo-linkedin' : '',
      portfolioUrl: isDemo ? 'https://example.com/demo-portfolio' : '',
      professionalSummary: isDemo
          ? 'Academic demo: aspiring Flutter developer with experience prototyping responsive mobile and web experiences using Flutter, Firebase, REST APIs and Git. Demonstration information, not verified employment history.'
          : '',
      skills: isDemo ? const ['Flutter', 'Dart', 'Firebase', 'Git'] : const [],
      education: isDemo
          ? const [
              CvEducationItem(
                degree: 'BSc in Computer Science and Engineering',
                institution: 'Sample University (Demo)',
                period: '2023 – Present',
              ),
            ]
          : const [],
      projects: isDemo
          ? const [
              CvProjectItem(
                name: 'Career Bridge',
                description:
                    'Academic project with role-based dashboards, job matching, application tracking, and CV generation.',
              ),
            ]
          : const [],
      languages: isDemo ? const ['Bangla', 'English'] : const [],
      technicalLanguages: isDemo ? const ['Dart', 'Python', 'SQL'] : const [],
      frameworks: isDemo ? const ['Flutter', 'Firebase'] : const [],
      toolsAndPlatforms:
          isDemo ? const ['Git', 'GitHub', 'Figma', 'REST APIs'] : const [],
      experience: isDemo
          ? const [
              CvExperienceItem(
                role: 'Mobile App Developer (Demo project)',
                company: 'Academic Project Team (Demo)',
                period: '2025 – 2026',
                description:
                    'Created responsive Flutter UI and Firebase data flows in an academic demonstration. No employment is asserted.',
              )
            ]
          : const [],
      achievements: isDemo
          ? const [
              CvAchievementItem(
                title: 'Career Bridge Project Demonstration',
                qualifier: 'Academic demo',
                date: '2026',
                description:
                    'Demo portfolio achievement; not an independently verified award.',
              )
            ]
          : const [],
      references: isDemo
          ? const [CvReferenceItem(name: 'Available on request (Demo)')]
          : const [],
      updatedAt: now,
    );
  }

  void _seedCatalogAccount(DemoAccountDefinition account) {
    final uid = account.uid;
    final now = DateTime(2026, 11, 1, 10);
    final education = <CvEducationItem>[
      CvEducationItem(
        degree: 'Bachelor of ${account.education}',
        institution: 'Sample Learning Institute (Demo)',
        period: '2022 – 2026',
        location: account.location,
      ),
    ];
    final projects = <CvProjectItem>[
      CvProjectItem(
        name: '${account.project} (Demo)',
        description:
            'Fictional portfolio project exploring ${account.skills.take(2).join(' and ')} through a sample ${account.category.toLowerCase()} workflow.',
        toolsAndMethods: account.skills.join(', '),
      ),
    ];
    final experience = <CvExperienceItem>[
      CvExperienceItem(
        role: '${account.roleTitle} (Demo project)',
        company: 'Practice Project Group (Demo)',
        period: '2025 – 2026',
        description:
            'Academic practice using ${account.skills.join(', ')}. Fictional demo information; no employment is asserted.',
      ),
    ];
    final summary =
        'Fictional demo profile pursuing ${account.roleTitle.toLowerCase()} opportunities in ${account.location}, with practice in ${account.skills.join(', ')}. Sample data only.';
    _profiles[uid] = JobSeekerProfileModel(
      uid: uid,
      fullName: account.name,
      email: account.email,
      headline: '${account.roleTitle} (Demo)',
      phone: '+880 1700-000000',
      location: account.location,
      about: summary,
      educationSummary: '${account.education} (Demo)',
      experienceYears: 1,
      skills: account.skills,
      preferredRoles: [account.roleTitle],
      preferredLocations: [account.location, 'Remote'],
      workModes: const ['Hybrid', 'Remote'],
      portfolioUrl: 'https://example.com/$uid',
      hasCvDetails: true,
      hasCvExperience: true,
      education: education,
      projects: projects,
      experience: experience,
      toolsAndPlatforms: account.skills,
      updatedAt: now,
    );
    _cvProfiles[uid] = CvProfileModel(
      ownerUid: uid,
      fullName: account.name,
      email: account.email,
      phone: '+880 1700-000000',
      location: account.location,
      portfolioUrl: 'https://example.com/$uid',
      professionalSummary: summary,
      skills: account.skills,
      education: education,
      projects: projects,
      experience: experience,
      languages: const ['Bangla', 'English'],
      toolsAndPlatforms: account.skills,
      updatedAt: now,
    );
    final employers = DemoAccountCatalog.forRole(UserRole.employer)
        .where((employer) => !employer.isPending)
        .toList()
      ..sort((a, b) => (b.roleTitle == account.roleTitle ? 1 : 0)
          .compareTo(a.roleTitle == account.roleTitle ? 1 : 0));
    _savedJobs[uid] = employers.take(3).map((e) => e.jobId).toSet();
    _applications[uid] = [
      for (var index = 0; index < 3; index++)
        ApplicationModel(
          id: '$uid-application-$index',
          jobId: employers[index].jobId,
          companyId: employers[index].companyId,
          companyName: employers[index].companyName,
          jobTitle: employers[index].roleTitle,
          applicantUid: uid,
          applicantName: account.name,
          applicantEmail: account.email,
          applicantHeadline: '${account.roleTitle} (Demo)',
          applicantLocation: account.location,
          applicantSkills: account.skills,
          status: const [
            ApplicationStatus.applied,
            ApplicationStatus.reviewed,
            ApplicationStatus.shortlisted
          ][index],
          coverLetter:
              'Sample demo application highlighting ${account.skills.take(2).join(' and ')}.',
          cvProfileId: uid,
          createdAt: now.subtract(Duration(days: index + 1)),
          updatedAt: now,
        ),
    ];
    _notifications[uid] = [
      NotificationModel(
        id: '$uid-notification',
        recipientUid: uid,
        title: 'Demo career match',
        message:
            '${employers.first.roleTitle} at ${employers.first.companyName} matches this sample profile.',
        type: 'recommendation',
        isRead: false,
        actionRoute: '/jobs/${employers.first.jobId}',
        createdAt: now,
      ),
    ];
  }

  @override
  Future<void> saveProfile(JobSeekerProfileModel profile) async {
    await _wait();
    _profiles[profile.uid] = profile;
  }

  @override
  Future<void> setSavedJob(
      {required String uid, required String jobId, required bool saved}) async {
    await _wait();
    final jobs = _savedJobs.putIfAbsent(uid, () => <String>{});
    saved ? jobs.add(jobId) : jobs.remove(jobId);
  }

  @override
  Future<void> saveProfileAndCv({
    required JobSeekerProfileModel profile,
    required CvProfileModel cvProfile,
  }) async {
    if (profile.uid != cvProfile.ownerUid) {
      throw ArgumentError('Profile and CV must have the same owner.');
    }
    await _wait();
    _profiles[profile.uid] = profile;
    _cvProfiles[cvProfile.ownerUid] = cvProfile;
  }

  @override
  Future<ApplicationModel> submitApplication({
    required String uid,
    required JobModel job,
    required String coverLetter,
    required CvProfileModel? cvProfile,
    required JobSeekerProfileModel applicantProfile,
  }) async {
    await _wait();
    final applications =
        _applications.putIfAbsent(uid, () => <ApplicationModel>[]);
    final existing = DemoApplicationStore.instance
        .mergeApplications(applications, (app) => app.applicantUid == uid)
        .where((item) =>
            item.jobId == job.id && item.status != ApplicationStatus.withdrawn);
    if (existing.isNotEmpty) {
      throw StateError('You already have an active application for this job.');
    }
    final now = DateTime.now();
    final applicationId = 'application-${now.microsecondsSinceEpoch}';
    String? cvFileId;
    if (cvProfile != null) {
      final prepared = await CvPdfService.instance.prepareForUpload(cvProfile);
      final stored = await DemoFileObjectRepository.instance.upload(
        file: prepared,
        ownerUid: uid,
        purpose: 'applicationCv',
        applicationId: applicationId,
      );
      cvFileId = stored.id;
    }
    final application = ApplicationModel(
      id: applicationId,
      jobId: job.id,
      applicantUid: uid,
      status: ApplicationStatus.applied,
      coverLetter: coverLetter.trim(),
      cvProfileId: cvProfile?.ownerUid,
      cvFileId: cvFileId,
      applicantName: applicantProfile.fullName,
      applicantEmail: applicantProfile.email,
      applicantHeadline: applicantProfile.headline,
      applicantLocation: applicantProfile.location,
      applicantExperienceYears: applicantProfile.experienceYears,
      applicantSkills: applicantProfile.allSkills,
      jobTitle: job.title,
      companyId: job.companyId,
      companyName: job.companyName,
      jobLocation: job.location,
      jobEmploymentType: job.employmentType,
      jobSalaryLabel: job.salaryLabel,
      createdAt: now,
      updatedAt: now,
    );
    applications.insert(0, application);
    _notifications.putIfAbsent(uid, () => <NotificationModel>[]).insert(
          0,
          NotificationModel(
            id: 'notification-${now.microsecondsSinceEpoch}',
            recipientUid: uid,
            title: 'Application submitted',
            message:
                'Your application was submitted successfully and is ready to track.',
            type: 'application',
            isRead: false,
            actionRoute: '/job-seeker/applications/${application.id}',
            applicationId: application.id,
            createdAt: now,
          ),
        );
    DemoApplicationStore.instance.put(application);
    return application;
  }

  @override
  Future<void> withdrawApplication(ApplicationModel application) async {
    await _wait();
    DemoApplicationStore.instance.withdraw(application);
    final applications =
        _applications[application.applicantUid] ?? <ApplicationModel>[];
    final index = applications.indexWhere((item) => item.id == application.id);
    if (index >= 0) {
      applications[index] = application.copyWith(
        status: ApplicationStatus.withdrawn,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> markNotificationRead(NotificationModel notification) async {
    await _wait();
    DemoApplicationStore.instance.markRead(notification);
    final notifications =
        _notifications[notification.recipientUid] ?? <NotificationModel>[];
    final index =
        notifications.indexWhere((item) => item.id == notification.id);
    if (index >= 0) notifications[index] = notification.copyWith(isRead: true);
  }

  @override
  Future<void> createNotification(NotificationModel notification) async {
    await _wait();
    final notifications = _notifications.putIfAbsent(
      notification.recipientUid,
      () => <NotificationModel>[],
    );
    final index =
        notifications.indexWhere((item) => item.id == notification.id);
    if (index >= 0) {
      notifications[index] = notification;
    } else {
      notifications.insert(0, notification);
    }
  }

  @override
  Future<void> saveCvProfile(CvProfileModel cvProfile) async {
    await _wait();
    _cvProfiles[cvProfile.ownerUid] = cvProfile;
  }
}
