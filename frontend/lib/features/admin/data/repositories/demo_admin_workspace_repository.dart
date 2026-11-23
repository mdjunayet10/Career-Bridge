import '../../../../core/enums/employer_job_status.dart';
import '../../../../core/enums/employer_verification_status.dart';
import '../../../public_portal/data/demo_showcase_catalog.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../../employer/data/models/employer_job_model.dart';
import '../../../employer/data/repositories/demo_employer_workspace_repository.dart';
import '../models/admin_activity_model.dart';
import '../models/admin_company_review_model.dart';
import '../models/job_category_admin_model.dart';
import '../models/platform_report_model.dart';
import '../models/platform_settings_model.dart';
import '../models/salary_insight_admin_model.dart';
import 'admin_workspace_repository.dart';

class DemoAdminWorkspaceRepository implements AdminWorkspaceRepository {
  final List<AppUserModel> _users = <AppUserModel>[];
  final List<AdminCompanyReviewModel> _companies = <AdminCompanyReviewModel>[];
  final List<EmployerJobModel> _jobs = <EmployerJobModel>[];
  final List<PlatformReportModel> _reports = <PlatformReportModel>[];
  final List<JobCategoryAdminModel> _categories = <JobCategoryAdminModel>[];
  final List<SalaryInsightAdminModel> _salaryInsights =
      <SalaryInsightAdminModel>[];
  final List<AdminActivityModel> _activities = <AdminActivityModel>[];
  PlatformSettingsModel? _settings;
  bool _initialized = false;
  final DemoEmployerWorkspaceRepository _employerRepository =
      DemoEmployerWorkspaceRepository();

  @override
  Future<AdminWorkspaceSnapshot> load() async {
    await _wait();
    await _seed();
    return AdminWorkspaceSnapshot(
      users: List.unmodifiable(_users),
      companies: List.unmodifiable(_companies),
      jobs: List.unmodifiable(_jobs),
      reports: List.unmodifiable(_reports),
      categories: List.unmodifiable(_categories),
      salaryInsights: List.unmodifiable(_salaryInsights),
      settings: _settings!,
      activities: List.unmodifiable(_activities),
    );
  }

  Future<void> _seed() async {
    if (_initialized) return;
    _initialized = true;
    final now = DateTime(2026, 8, 6, 12, 30);

    // Source identities, companies, and published jobs from the exact public
    // presentation catalogue. They are fictional and NEVER persisted to Firebase.
    _users.addAll(DemoShowcaseCatalog.users);
    for (final account in DemoShowcaseCatalog.employers) {
      _companies.add(AdminCompanyReviewModel(
        companyId: account.companyId,
        ownerUid: account.uid,
        companyName: account.companyName,
        industry: account.industry,
        companySize: account.uid == 'demo-employer-approved'
            ? '51–200 employees (Demo)'
            : '11–50 employees (Demo)',
        email: account.email,
        website: 'https://example.com',
        address: '${account.location}, Bangladesh (Demo)',
        tradeLicenseNumber: 'DEMO-ONLY-NOT-A-LICENSE',
        status: account.verificationStatus,
        isActive: true,
        submittedAt: now,
      ));
    }
    // Read each sample Employer workspace so published, pending, draft, and
    // closed items in Admin match what that fictional company actually owns.
    final workspaces = await Future.wait([
      for (final account in DemoShowcaseCatalog.employers)
        _employerRepository.load(
          uid: account.uid,
          companyName: account.companyName,
          contactName: account.name,
          email: account.email,
        ),
    ]);
    for (final workspace in workspaces) {
      _jobs.addAll(workspace.jobs);
    }

    _reports.addAll([
      PlatformReportModel(
        id: 'report-001',
        reporterUid: 'demo-job-seeker',
        reporterName: 'Ayan Rahman (Demo)',
        targetType: 'job',
        targetId: 'qa-engineer-novatech',
        targetLabel: 'Software QA Engineer',
        reason: 'Misleading salary information',
        details:
            'The salary mentioned in the description does not match the salary range shown on the card.',
        status: PlatformReportStatus.open,
        createdAt: DateTime(2026, 8, 6, 11, 20),
      ),
      PlatformReportModel(
        id: 'report-002',
        reporterUid: 'demo-seeker-designer',
        reporterName: 'Mira Sen (Demo)',
        targetType: 'company',
        targetId: 'demo-orbit-labs',
        targetLabel: 'Orbit Labs (Demo)',
        reason: 'Company identity concern',
        details:
            'The website information is incomplete and the company address needs verification.',
        status: PlatformReportStatus.inReview,
        createdAt: DateTime(2026, 8, 6, 8, 5),
      ),
      PlatformReportModel(
        id: 'report-003',
        reporterUid: 'demo-seeker-analyst',
        reporterName: 'Tariq Noor (Demo)',
        targetType: 'job',
        targetId: 'old-job-001',
        targetLabel: 'Remote Data Entry Operator',
        reason: 'Suspicious application process',
        details: 'The poster requested payment before an interview.',
        status: PlatformReportStatus.resolved,
        createdAt: DateTime(2026, 8, 3, 12),
        resolutionNote: 'Listing removed and employer account suspended.',
        resolvedAt: DateTime(2026, 8, 3, 15, 20),
      ),
      PlatformReportModel(
        id: 'report-004',
        reporterUid: 'demo-job-seeker',
        reporterName: 'Ayan Rahman (Demo)',
        targetType: 'profile',
        targetId: 'profile-unknown',
        targetLabel: 'Candidate message',
        reason: 'Spam',
        details: 'Repeated unsolicited promotional messages.',
        status: PlatformReportStatus.open,
        createdAt: DateTime(2026, 8, 5, 16, 40),
      ),
    ]);

    _categories.addAll([
      _category('technology', 'Technology',
          'Software, data, IT, and engineering roles.', 'memory', 1),
      _category('creative', 'Creative',
          'Design, content, media, and product craft.', 'palette', 2),
      _category(
          'business',
          'Business',
          'Operations, management, finance, and strategy.',
          'business_center',
          3),
      _category('marketing', 'Marketing',
          'Growth, digital marketing, and communications.', 'campaign', 4),
      _category('education', 'Education',
          'Teaching, training, and education technology.', 'school', 5),
      _category('customer-support', 'Customer Support',
          'Customer success, support, and service.', 'support_agent', 6),
    ]);

    _salaryInsights.addAll([
      _salary('flutter-developer', 'Flutter Developer', 'Technology', 'Dhaka',
          '2–4 years', 45000, 65000, 90000),
      _salary('ui-ux-designer', 'UI/UX Designer', 'Creative', 'Dhaka',
          '1–3 years', 35000, 52000, 75000),
      _salary('data-analyst', 'Data Analyst', 'Technology', 'Dhaka',
          'Entry level', 32000, 48000, 70000),
      _salary('digital-marketer', 'Digital Marketer', 'Marketing', 'Dhaka',
          '2–4 years', 38000, 55000, 80000),
      _salary('product-manager', 'Product Manager', 'Business', 'Dhaka',
          '3–6 years', 75000, 105000, 150000),
    ]);

    _settings = PlatformSettingsModel(
      platformName: 'Career Bridge',
      supportEmail: 'support@careerbridge.edu',
      employerReviewRequired: true,
      jobReviewRequired: true,
      maintenanceMode: false,
      allowJobSeekerRegistration: true,
      allowEmployerRegistration: true,
      updatedAt: now,
    );

    _activities.addAll([
      AdminActivityModel(
          id: 'activity-1',
          action: 'Employer approved',
          subject: 'NovaTech Bangladesh',
          detail: 'Verification completed by Career Bridge Admin.',
          createdAt: DateTime(2026, 8, 6, 10, 25)),
      AdminActivityModel(
          id: 'activity-2',
          action: 'Job published',
          subject: 'Junior Data Analyst',
          detail: 'Listing passed content review.',
          createdAt: DateTime(2026, 8, 6, 9, 40)),
      AdminActivityModel(
          id: 'activity-3',
          action: 'Report resolved',
          subject: 'Remote Data Entry Operator',
          detail: 'Unsafe listing removed.',
          createdAt: DateTime(2026, 8, 5, 18, 10)),
      AdminActivityModel(
          id: 'activity-4',
          action: 'Category updated',
          subject: 'Technology',
          detail: 'Description and sort order refined.',
          createdAt: DateTime(2026, 8, 5, 14, 30)),
    ]);
  }

  JobCategoryAdminModel _category(
    String id,
    String name,
    String description,
    String iconName,
    int order,
  ) {
    return JobCategoryAdminModel(
      id: id,
      name: name,
      description: description,
      iconName: iconName,
      isActive: true,
      sortOrder: order,
      updatedAt: DateTime(2026, 8, 1),
    );
  }

  SalaryInsightAdminModel _salary(
    String id,
    String role,
    String category,
    String location,
    String experience,
    int minimum,
    int median,
    int maximum,
  ) {
    return SalaryInsightAdminModel(
      id: id,
      roleName: role,
      category: category,
      location: location,
      experienceLevel: experience,
      minimumSalary: minimum,
      medianSalary: median,
      maximumSalary: maximum,
      isActive: true,
      updatedAt: DateTime(2026, 8, 1),
    );
  }

  @override
  Future<void> reviewEmployer({
    required AdminCompanyReviewModel company,
    required EmployerVerificationStatus status,
    required String note,
  }) async {
    await _wait();
    final index =
        _companies.indexWhere((item) => item.companyId == company.companyId);
    if (index >= 0) {
      _companies[index] = company.copyWith(status: status, decisionNote: note);
    }
    final userIndex = _users.indexWhere((item) => item.uid == company.ownerUid);
    if (userIndex >= 0) {
      final user = _users[userIndex];
      _users[userIndex] = AppUserModel(
        uid: user.uid,
        name: user.name,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
        createdAt: user.createdAt,
        companyName: user.companyName,
        verificationStatus: status,
      );
    }
    _record(
      action: status == EmployerVerificationStatus.approved
          ? 'Employer approved'
          : 'Employer review updated',
      subject: company.companyName,
      detail: note,
    );
  }

  @override
  Future<void> reviewJob({
    required EmployerJobModel job,
    required EmployerJobStatus status,
    required String note,
  }) async {
    await _wait();
    final index = _jobs.indexWhere((item) => item.id == job.id);
    if (index >= 0) {
      _jobs[index] = job.copyWith(
        status: status,
        isActive: status == EmployerJobStatus.published ||
            status == EmployerJobStatus.pending,
        updatedAt: DateTime.now(),
        publishedAt: status == EmployerJobStatus.published
            ? DateTime.now()
            : job.publishedAt,
        rejectionNote: note.trim().isEmpty ? job.rejectionNote : note,
      );
    }
    _record(
      action: status == EmployerJobStatus.published
          ? 'Job approved'
          : 'Job review updated',
      subject: job.title,
      detail: note,
    );
  }

  @override
  Future<void> setUserActive(
      {required AppUserModel user, required bool isActive}) async {
    await _wait();
    final index = _users.indexWhere((item) => item.uid == user.uid);
    if (index >= 0) {
      _users[index] = AppUserModel(
        uid: user.uid,
        name: user.name,
        email: user.email,
        role: user.role,
        isActive: isActive,
        createdAt: user.createdAt,
        companyName: user.companyName,
        verificationStatus: user.verificationStatus,
      );
    }
    _record(
        action: isActive ? 'User activated' : 'User suspended',
        subject: user.name,
        detail: user.email);
  }

  @override
  Future<void> setCompanyActive({
    required AdminCompanyReviewModel company,
    required bool isActive,
  }) async {
    await _wait();
    final index =
        _companies.indexWhere((item) => item.companyId == company.companyId);
    if (index >= 0) _companies[index] = company.copyWith(isActive: isActive);
    _record(
        action: isActive ? 'Company activated' : 'Company suspended',
        subject: company.companyName,
        detail: company.email);
  }

  @override
  Future<void> updateReport({
    required PlatformReportModel report,
    required PlatformReportStatus status,
    required String note,
  }) async {
    await _wait();
    final index = _reports.indexWhere((item) => item.id == report.id);
    if (index >= 0) {
      _reports[index] = report.copyWith(
        status: status,
        resolutionNote: note,
        resolvedAt: status.isClosed ? DateTime.now() : report.resolvedAt,
      );
    }
    _record(
        action: 'Report ${status.label.toLowerCase()}',
        subject: report.targetLabel,
        detail: note);
  }

  @override
  Future<JobCategoryAdminModel> saveCategory(
      JobCategoryAdminModel category) async {
    await _wait();
    final resolved = category.id.trim().isEmpty
        ? category.copyWith(
            id: 'category-${DateTime.now().microsecondsSinceEpoch}')
        : category;
    final index = _categories.indexWhere((item) => item.id == resolved.id);
    if (index >= 0) {
      _categories[index] = resolved;
    } else {
      _categories.add(resolved);
    }
    _record(
        action: 'Category saved',
        subject: resolved.name,
        detail: resolved.description);
    return resolved;
  }

  @override
  Future<SalaryInsightAdminModel> saveSalaryInsight(
      SalaryInsightAdminModel insight) async {
    await _wait();
    final resolved = insight.id.trim().isEmpty
        ? insight.copyWith(
            id: 'salary-${DateTime.now().microsecondsSinceEpoch}')
        : insight;
    final index = _salaryInsights.indexWhere((item) => item.id == resolved.id);
    if (index >= 0) {
      _salaryInsights[index] = resolved;
    } else {
      _salaryInsights.add(resolved);
    }
    _record(
        action: 'Salary insight saved',
        subject: resolved.roleName,
        detail: resolved.location);
    return resolved;
  }

  @override
  Future<void> saveSettings(PlatformSettingsModel settings) async {
    await _wait();
    _settings = settings;
    _record(
        action: 'Platform settings updated',
        subject: settings.platformName,
        detail: settings.supportEmail);
  }

  void _record(
      {required String action,
      required String subject,
      required String detail}) {
    _activities.insert(
      0,
      AdminActivityModel(
        id: 'activity-${DateTime.now().microsecondsSinceEpoch}',
        action: action,
        subject: subject,
        detail: detail,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 140));
}
