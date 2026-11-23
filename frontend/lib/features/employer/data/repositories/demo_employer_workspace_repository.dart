import '../../../demo/data/demo_application_store.dart';
import '../../../auth/data/demo_account_catalog.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/application_status.dart';
import '../../../../core/enums/employer_job_status.dart';
import '../../../applications/data/models/application_model.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../models/company_profile_model.dart';
import '../models/employer_job_model.dart';
import 'employer_workspace_repository.dart';

class DemoEmployerWorkspaceRepository implements EmployerWorkspaceRepository {
  final Map<String, CompanyProfileModel> _companies = {};
  final Map<String, List<EmployerJobModel>> _jobs = {};
  final Map<String, List<ApplicationModel>> _applications = {};
  final Map<String, List<NotificationModel>> _notifications = {};

  Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 240));

  @override
  Future<EmployerWorkspaceSnapshot> load({
    required String uid,
    required String companyName,
    required String contactName,
    required String email,
  }) async {
    await _wait();
    _seedIfNeeded(uid: uid, companyName: companyName, email: email);
    return EmployerWorkspaceSnapshot(
      company: _companies[uid]!,
      jobs: List<EmployerJobModel>.from(_jobs[uid]!),
      applications: DemoApplicationStore.instance.mergeApplications(
          _applications[uid]!,
          (app) => _jobs[uid]!.any((job) => job.id == app.jobId)),
      notifications: DemoApplicationStore.instance
          .mergeNotifications(_notifications[uid]!, uid),
    );
  }

  void _seedIfNeeded(
      {required String uid,
      required String companyName,
      required String email}) {
    if (_companies.containsKey(uid)) return;
    final account = DemoAccountCatalog.byUid(uid);
    if (account != null &&
        account.role == UserRole.employer &&
        uid != 'demo-employer-approved') {
      _seedCatalogAccount(account);
      return;
    }
    final now = DateTime(2026, 8, 6, 11, 30);
    final isDemo = uid == 'demo-employer-approved';
    final companyId = isDemo ? 'demo-novatech-bangladesh' : 'company-$uid';
    final resolvedName =
        companyName.trim().isEmpty ? 'Career Bridge Employer' : companyName;

    _companies[uid] = CompanyProfileModel(
      id: companyId,
      ownerUid: uid,
      name: resolvedName,
      industry: isDemo ? 'Software & Product' : '',
      companySize: isDemo ? '51–200 employees' : '',
      website: isDemo ? 'https://novatech.example.com' : '',
      email: email,
      phone: isDemo ? '+880 1700-555555' : '',
      address: isDemo ? 'Banani, Dhaka, Bangladesh' : '',
      description: isDemo
          ? 'Fictional demo company: NovaTech builds reliable digital products for businesses in Bangladesh and international markets. Our product, engineering, and design teams work together from discovery to delivery.'
          : '',
      tradeLicenseNumber: isDemo ? 'DEMO-ONLY-NOT-A-LICENSE' : '',
      verificationStatus: 'approved',
      isActive: true,
      updatedAt: now,
    );

    _jobs[uid] = isDemo
        ? <EmployerJobModel>[
            EmployerJobModel(
              id: 'flutter-developer-novatech',
              employerUid: uid,
              companyId: companyId,
              title: 'Flutter Developer',
              categoryId: 'Technology',
              location: 'Dhaka',
              workMode: 'Hybrid',
              employmentType: 'Full-time',
              experienceLevel: '2–3 years',
              salaryMin: 45000,
              salaryMax: 70000,
              salaryPeriod: 'month',
              description:
                  'Build polished cross-platform products with our product and engineering teams.',
              responsibilities: const [
                'Develop and maintain Flutter applications for mobile and web.',
                'Collaborate with product, design, backend, and QA teams.',
                'Improve performance, accessibility, and test coverage.',
              ],
              requirements: const [
                'Strong Dart and Flutter fundamentals.',
                'Experience with Firebase, REST APIs, and Git.',
                'Clear communication and ownership.',
              ],
              skills: const ['Flutter', 'Dart', 'Firebase', 'Git'],
              benefits: const [
                'Festival bonus',
                'Hybrid schedule',
                'Learning budget'
              ],
              deadline: DateTime(2026, 12, 15),
              status: EmployerJobStatus.published,
              isActive: true,
              createdAt: DateTime(2026, 7, 27),
              updatedAt: DateTime(2026, 8, 4),
              publishedAt: DateTime(2026, 7, 29),
            ),
            EmployerJobModel(
              id: 'qa-engineer-novatech',
              employerUid: uid,
              companyId: companyId,
              title: 'Software QA Engineer',
              categoryId: 'Technology',
              location: 'Dhaka',
              workMode: 'Hybrid',
              employmentType: 'Full-time',
              experienceLevel: '1–3 years',
              salaryMin: 38000,
              salaryMax: 58000,
              salaryPeriod: 'month',
              description:
                  'Own practical testing workflows for web and mobile product releases.',
              responsibilities: const [
                'Prepare test plans.',
                'Run manual and regression testing.',
                'Report actionable defects.'
              ],
              requirements: const [
                'Software testing fundamentals.',
                'Strong attention to detail.',
                'API testing exposure.'
              ],
              skills: const [
                'QA',
                'Postman',
                'Test Cases',
                'Regression Testing'
              ],
              benefits: const [
                'Hybrid schedule',
                'Health support',
                'Performance bonus'
              ],
              deadline: DateTime(2026, 12, 15),
              status: EmployerJobStatus.published,
              isActive: true,
              createdAt: DateTime(2026, 8, 1),
              updatedAt: DateTime(2026, 8, 5),
              publishedAt: DateTime(2026, 8, 2),
            ),
            EmployerJobModel(
              id: 'product-manager-novatech',
              employerUid: uid,
              companyId: companyId,
              title: 'Associate Product Manager',
              categoryId: 'Business',
              location: 'Dhaka',
              workMode: 'Hybrid',
              employmentType: 'Full-time',
              experienceLevel: '2–4 years',
              salaryMin: 60000,
              salaryMax: 90000,
              salaryPeriod: 'month',
              description:
                  'Support product discovery, planning, delivery, and stakeholder communication.',
              responsibilities: const [
                'Maintain product backlog.',
                'Coordinate product delivery.',
                'Track product outcomes.'
              ],
              requirements: const [
                'Product or project coordination experience.',
                'Strong written communication.'
              ],
              skills: const ['Product Management', 'Analytics', 'Agile'],
              benefits: const [
                'Learning budget',
                'Hybrid work',
                'Festival bonus'
              ],
              deadline: DateTime(2026, 12, 15),
              status: EmployerJobStatus.pending,
              isActive: true,
              createdAt: DateTime(2026, 8, 5),
              updatedAt: DateTime(2026, 8, 5),
            ),
            EmployerJobModel(
              id: 'mobile-intern-novatech',
              employerUid: uid,
              companyId: companyId,
              title: 'Mobile Engineering Intern',
              categoryId: 'Technology',
              location: 'Dhaka',
              workMode: 'On-site',
              employmentType: 'Internship',
              experienceLevel: 'Student / Fresh graduate',
              salaryMin: 18000,
              salaryMax: 25000,
              salaryPeriod: 'month',
              description:
                  'Learn practical mobile product development through supervised delivery work.',
              responsibilities: const [
                'Support Flutter feature development.',
                'Write simple tests.',
                'Document learning and progress.'
              ],
              requirements: const [
                'Basic Flutter knowledge.',
                'A personal or university project portfolio.'
              ],
              skills: const ['Flutter', 'Dart', 'Git'],
              benefits: const [
                'Mentorship',
                'Certificate',
                'Potential full-time role'
              ],
              deadline: DateTime(2026, 12, 15),
              status: EmployerJobStatus.published,
              isActive: true,
              createdAt: DateTime(2026, 8, 6),
              updatedAt: DateTime(2026, 8, 6),
              publishedAt: DateTime(2026, 8, 6),
            ),
            EmployerJobModel(
              id: 'backend-engineer-closed-novatech',
              employerUid: uid,
              companyId: companyId,
              title: 'Backend Engineer',
              categoryId: 'Technology',
              location: 'Dhaka',
              workMode: 'Hybrid',
              employmentType: 'Full-time',
              experienceLevel: '3–5 years',
              salaryMin: 75000,
              salaryMax: 115000,
              salaryPeriod: 'month',
              description:
                  'Design APIs and reliable services for high-traffic products.',
              responsibilities: const [
                'Build APIs.',
                'Review code.',
                'Improve observability.'
              ],
              requirements: const [
                'Backend engineering experience.',
                'Strong database fundamentals.'
              ],
              skills: const ['APIs', 'Databases', 'Node.js'],
              benefits: const ['Health support', 'Hybrid work'],
              deadline: DateTime(2026, 7, 31),
              status: EmployerJobStatus.closed,
              isActive: false,
              createdAt: DateTime(2026, 7, 1),
              updatedAt: DateTime(2026, 8, 1),
              publishedAt: DateTime(2026, 7, 2),
            ),
          ]
        : <EmployerJobModel>[];

    _applications[uid] = isDemo
        ? <ApplicationModel>[
            _candidate(
                'app-101',
                'flutter-developer-novatech',
                'Arif Hasan',
                'arif.hasan@example.com',
                'Flutter Developer · 2 years experience',
                'Dhaka',
                2,
                const ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
                ApplicationStatus.applied,
                DateTime(2026, 8, 6, 9, 20)),
            _candidate(
                'app-102',
                'flutter-developer-novatech',
                'Nusrat Jahan',
                'nusrat.jahan@example.com',
                'Mobile App Developer',
                'Dhaka',
                3,
                const ['Flutter', 'Dart', 'Bloc', 'Git'],
                ApplicationStatus.reviewed,
                DateTime(2026, 8, 5, 14, 10)),
            _candidate(
                'app-103',
                'flutter-developer-novatech',
                'Mahin Rahman',
                'mahin.rahman@example.com',
                'CSE graduate and Flutter engineer',
                'Chattogram',
                1,
                const ['Flutter', 'Firebase', 'UI Development'],
                ApplicationStatus.shortlisted,
                DateTime(2026, 8, 4, 11, 30),
                note: 'Strong portfolio. Move to technical discussion.'),
            _candidate(
                'app-104',
                'flutter-developer-novatech',
                'Sadia Ahmed',
                'sadia.ahmed@example.com',
                'Cross-platform Mobile Engineer',
                'Dhaka',
                4,
                const ['Flutter', 'Dart', 'Testing', 'CI/CD'],
                ApplicationStatus.interview,
                DateTime(2026, 8, 3, 10, 5),
                note: 'Technical interview with mobile team.',
                interviewAt: DateTime(2026, 8, 10, 15, 0)),
            _candidate(
                'app-105',
                'qa-engineer-novatech',
                'Rafiul Islam',
                'rafiul.islam@example.com',
                'Software QA Engineer',
                'Narayanganj',
                2,
                const ['Postman', 'Manual Testing', 'Regression Testing'],
                ApplicationStatus.applied,
                DateTime(2026, 8, 6, 8, 45)),
            _candidate(
                'app-106',
                'qa-engineer-novatech',
                'Tanjila Noor',
                'tanjila.noor@example.com',
                'QA Analyst',
                'Dhaka',
                3,
                const ['QA', 'Jira', 'API Testing', 'SQL'],
                ApplicationStatus.shortlisted,
                DateTime(2026, 8, 5, 12, 20)),
            _candidate(
                'app-107',
                'backend-engineer-closed-novatech',
                'Shuvo Das',
                'shuvo.das@example.com',
                'Backend Engineer',
                'Dhaka',
                5,
                const ['Node.js', 'PostgreSQL', 'Docker'],
                ApplicationStatus.hired,
                DateTime(2026, 7, 15, 13, 40),
                note: 'Offer accepted. Joining date confirmed.'),
            _candidate(
                'app-108',
                'backend-engineer-closed-novatech',
                'Mehedi Karim',
                'mehedi.karim@example.com',
                'Software Engineer',
                'Dhaka',
                3,
                const ['Node.js', 'MongoDB', 'REST APIs'],
                ApplicationStatus.rejected,
                DateTime(2026, 7, 16, 15, 10),
                note: 'Role requires deeper production database experience.'),
          ]
        : <ApplicationModel>[];

    _notifications[uid] = isDemo
        ? <NotificationModel>[
            NotificationModel(
              id: 'employer-notification-1',
              recipientUid: uid,
              title: '5 new applications',
              message:
                  'Your Flutter Developer and QA Engineer jobs received new applications today.',
              type: 'application',
              isRead: false,
              actionRoute: '/employer/applicants',
              createdAt: DateTime(2026, 8, 6, 10, 10),
            ),
            NotificationModel(
              id: 'employer-notification-2',
              recipientUid: uid,
              title: 'Job submitted for review',
              message: 'Associate Product Manager is awaiting admin approval.',
              type: 'job',
              isRead: false,
              actionRoute: '/employer/jobs',
              createdAt: DateTime(2026, 8, 5, 17, 30),
            ),
            NotificationModel(
              id: 'employer-notification-3',
              recipientUid: uid,
              title: 'Company profile verified',
              message:
                  'NovaTech Bangladesh is verified and can publish approved job listings.',
              type: 'company',
              isRead: true,
              actionRoute: '/employer/company',
              createdAt: DateTime(2026, 8, 1, 12),
            ),
          ]
        : <NotificationModel>[];
  }

  void _seedCatalogAccount(DemoAccountDefinition account) {
    final uid = account.uid;
    final now = DateTime(2026, 11, 1, 11);
    _companies[uid] = CompanyProfileModel(
      id: account.companyId,
      ownerUid: uid,
      name: account.companyName,
      industry: account.industry,
      companySize: '11–50 employees (Demo)',
      website: 'https://example.com/${account.companyId}',
      email: account.email,
      phone: '+880 1700-000000',
      address: '${account.location}, Bangladesh (Demo)',
      description:
          'Fictional academic-demo ${account.industry.toLowerCase()} company. Sample recruitment workflows only; no real employer or vacancy is represented.',
      tradeLicenseNumber: 'DEMO-ONLY-NOT-A-LICENSE',
      verificationStatus: account.isPending ? 'pending' : 'approved',
      isActive: true,
      updatedAt: now,
    );
    final extraPublicEmployers = DemoAccountCatalog.forRole(UserRole.employer)
        .where((e) => !e.isPending && e.uid != 'demo-employer-approved')
        .take(7)
        .map((e) => e.uid)
        .toSet();
    _jobs[uid] = [
      for (var index = 0; index < 3; index++)
        EmployerJobModel(
          id: index == 0 ? account.jobId : '${account.companyId}-job-$index',
          employerUid: uid,
          companyId: account.companyId,
          title: index == 0
              ? account.roleTitle
              : '${account.roleTitle} ${index == 1 ? 'Trainee' : 'Team Lead'}',
          categoryId: account.category,
          location: account.location,
          workMode: index == 1 ? 'On-site' : 'Hybrid',
          employmentType: index == 1 ? 'Internship' : 'Full-time',
          experienceLevel:
              index == 1 ? 'Student / Fresh graduate' : '1–3 years',
          salaryMin: 20000 + index * 5000,
          salaryMax: 40000 + index * 10000,
          salaryPeriod: 'month',
          description:
              'Fictional demo opportunity at ${account.companyName} using ${account.skills.join(', ')}. Sample data only.',
          responsibilities: [
            'Support sample ${account.category.toLowerCase()} delivery.',
            'Collaborate on the ${account.companyName} demonstration project.',
          ],
          requirements: [
            'Practice with ${account.skills.first}.',
            'Clear communication and a sample project portfolio.'
          ],
          skills: account.skills,
          benefits: const ['Demo mentorship', 'Sample learning allowance'],
          deadline: DateTime(2026, 12, 15),
          status: account.isPending
              ? EmployerJobStatus.pending
              : index == 1 && extraPublicEmployers.contains(uid)
                  ? EmployerJobStatus.published
                  : const [
                      EmployerJobStatus.published,
                      EmployerJobStatus.draft,
                      EmployerJobStatus.pending
                    ][index],
          isActive: true,
          createdAt: now.subtract(Duration(days: index + 1)),
          updatedAt: now,
          publishedAt: !account.isPending &&
                  (index == 0 ||
                      (index == 1 && extraPublicEmployers.contains(uid)))
              ? now
              : null,
        ),
    ];
    final candidates = DemoAccountCatalog.forRole(UserRole.jobSeeker);
    final matching = candidates.where((c) => c.roleTitle == account.roleTitle);
    final candidate = matching.isEmpty ? candidates.first : matching.first;
    _applications[uid] = account.isPending
        ? []
        : [
            ApplicationModel(
              id: '$uid-application',
              jobId: account.jobId,
              companyId: account.companyId,
              companyName: account.companyName,
              jobTitle: account.roleTitle,
              applicantUid: candidate.uid,
              applicantName: candidate.name,
              applicantEmail: candidate.email,
              applicantHeadline: '${candidate.roleTitle} (Demo)',
              applicantLocation: candidate.location,
              applicantExperienceYears: 1,
              applicantSkills: candidate.skills,
              status: ApplicationStatus.applied,
              coverLetter: 'Fictional demo application from ${candidate.name}.',
              cvProfileId: candidate.uid,
              createdAt: now,
              updatedAt: now,
            ),
          ];
    _notifications[uid] = [
      NotificationModel(
        id: '$uid-notification',
        recipientUid: uid,
        title: account.isPending
            ? 'Demo verification pending'
            : 'Demo workspace ready',
        message:
            '${account.companyName}: sample ${account.category.toLowerCase()} recruitment data only.',
        type: 'company',
        isRead: false,
        actionRoute: '/employer/company',
        createdAt: now,
      ),
    ];
  }

  ApplicationModel _candidate(
    String id,
    String jobId,
    String name,
    String email,
    String headline,
    String location,
    int experience,
    List<String> skills,
    ApplicationStatus status,
    DateTime createdAt, {
    String? note,
    DateTime? interviewAt,
  }) {
    final jobTitle = switch (jobId) {
      'flutter-developer-novatech' => 'Flutter Developer',
      'qa-engineer-novatech' => 'Software QA Engineer',
      'backend-engineer-closed-novatech' => 'Backend Engineer',
      _ => 'NovaTech opportunity',
    };
    return ApplicationModel(
      id: id,
      jobId: jobId,
      companyId: 'demo-novatech-bangladesh',
      companyName: 'NovaTech Bangladesh (Demo)',
      jobTitle: jobTitle,
      applicantUid: 'candidate-$id',
      status: status,
      coverLetter:
          'I am excited to apply for this role. My background and project experience align with the responsibilities, and I would welcome the opportunity to contribute to the team.',
      cvProfileId: 'candidate-$id',
      employerNote: note,
      interviewAt: interviewAt,
      applicantName: name,
      applicantEmail: email,
      applicantHeadline: headline,
      applicantLocation: location,
      applicantExperienceYears: experience,
      applicantSkills: skills,
      createdAt: createdAt,
      updatedAt: interviewAt ?? createdAt,
    );
  }

  @override
  Future<void> saveCompany(CompanyProfileModel company) async {
    await _wait();
    _companies[company.ownerUid] = company;
  }

  @override
  Future<EmployerJobModel> saveJob(EmployerJobModel job) async {
    await _wait();
    final jobs = _jobs.putIfAbsent(job.employerUid, () => <EmployerJobModel>[]);
    final resolved = job.id.trim().isEmpty
        ? job.copyWith(id: 'job-${DateTime.now().microsecondsSinceEpoch}')
        : job;
    final index = jobs.indexWhere((item) => item.id == resolved.id);
    if (index >= 0) {
      jobs[index] = resolved;
    } else {
      jobs.insert(0, resolved);
    }
    return resolved;
  }

  @override
  Future<void> updateApplication({
    required ApplicationModel application,
    required ApplicationStatus status,
    String? employerNote,
    DateTime? interviewAt,
  }) async {
    await _wait();
    DemoApplicationStore.instance.update(
        application: application,
        status: status,
        note: employerNote,
        interviewAt: interviewAt);
  }

  @override
  Future<void> markNotificationRead(NotificationModel notification) async {
    await _wait();
    DemoApplicationStore.instance.markRead(notification);
    final items =
        _notifications[notification.recipientUid] ?? <NotificationModel>[];
    final index = items.indexWhere((item) => item.id == notification.id);
    if (index >= 0) items[index] = notification.copyWith(isRead: true);
  }
}
