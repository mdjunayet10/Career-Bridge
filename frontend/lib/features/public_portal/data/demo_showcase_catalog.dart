import '../../../core/enums/user_role.dart';
import '../../auth/data/demo_account_catalog.dart';
import '../../auth/data/models/app_user_model.dart';
import '../../companies/data/models/company_model.dart';
import '../../jobs/data/models/job_model.dart';

/// One canonical, fictional presentation catalogue used by User and Admin.
/// Never write these rows into Firebase or count them as actual registrations.
abstract final class DemoShowcaseCatalog {
  static List<DemoAccountDefinition> get employers =>
      DemoAccountCatalog.forRole(UserRole.employer);

  static List<AppUserModel> get users => [
        ...DemoAccountCatalog.forRole(UserRole.jobSeeker).map((a) => a.user),
        ...employers.map((a) => a.user),
      ];

  static List<CompanyModel> get companies => [
        for (final employer in employers)
          CompanyModel(
            id: employer.companyId,
            name: employer.companyName,
            industry: employer.industry,
            location: employer.location,
            size: employer.uid == 'demo-employer-approved'
                ? '51–200 employees (Demo)'
                : '11–50 employees (Demo)',
            founded: '2025 (Demo)',
            description:
                'Fictional university demonstration company. This is not a real registered business or a verified employer.',
            specialties: employer.skills,
            openings:
                jobs.where((j) => j.companyId == employer.companyId).length,
            website: 'example.com',
            isVerified: false,
          ),
      ];

  /// 20 published fictional jobs: 11 primary approved-company jobs,
  /// two additional NovaTech jobs and 7 approved-company traineeships.
  /// Orbit Labs is pending verification and intentionally has zero public jobs.
  static List<JobModel> get jobs {
    final approved = employers.where((e) => !e.isPending).toList();
    final additional = approved
        .where((e) => e.uid != 'demo-employer-approved')
        .take(7)
        .toList();
    return [
      for (final employer in approved)
        _job(employer, employer.jobId, employer.roleTitle),
      _job(
        approved.firstWhere((e) => e.uid == 'demo-employer-approved'),
        'qa-engineer-novatech',
        'Software QA Engineer',
      ),
      _job(
        approved.firstWhere((e) => e.uid == 'demo-employer-approved'),
        'mobile-intern-novatech',
        'Mobile Engineering Intern',
        internship: true,
      ),
      for (final employer in additional)
        _job(
          employer,
          '${employer.companyId}-job-1',
          '${employer.roleTitle} Trainee',
          internship: true,
        ),
    ];
  }

  static JobModel _job(
    DemoAccountDefinition employer,
    String id,
    String title, {
    bool internship = false,
  }) =>
      JobModel(
        id: id,
        companyId: employer.companyId,
        companyName: employer.companyName,
        title: title,
        category: employer.category,
        location: employer.location,
        workMode: internship ? 'On-site' : 'Hybrid',
        employmentType: internship ? 'Internship' : 'Full-time',
        experience: internship
            ? 'Student / Fresh graduate'
            : id == 'flutter-developer-novatech'
                ? '2–3 years'
                : '1–3 years',
        salaryLabel: id == 'mobile-intern-novatech'
            ? '৳18k–25k / month (Demo)'
            : id == 'flutter-developer-novatech'
                ? '৳45k–70k / month (Demo)'
                : id == 'qa-engineer-novatech'
                    ? '৳38k–58k / month (Demo)'
                    : internship
                        ? '৳25k–50k / month (Demo)'
                        : '৳20k–40k / month (Demo)',
        salaryMin: id == 'mobile-intern-novatech'
            ? 18000
            : id == 'flutter-developer-novatech'
                ? 45000
                : id == 'qa-engineer-novatech'
                    ? 38000
                    : internship
                        ? 25000
                        : 20000,
        salaryMax: id == 'mobile-intern-novatech'
            ? 25000
            : id == 'flutter-developer-novatech'
                ? 70000
                : id == 'qa-engineer-novatech'
                    ? 58000
                    : internship
                        ? 50000
                        : 40000,
        postedLabel: 'Demo listing',
        deadlineLabel: '15 Dec 2026 (Demo)',
        openings: 1,
        description:
            'Fictional academic demonstration opportunity at ${employer.companyName}. This is not an active vacancy.',
        responsibilities: [
          'Practice ${employer.category.toLowerCase()} project delivery.',
          'Collaborate with the fictional demo team.',
        ],
        requirements: [
          'Basic familiarity with ${employer.skills.first}.',
          'Good collaboration and communication skills.',
        ],
        benefits: const ['Illustrative benefits for demonstration only'],
        skills: employer.skills,
        isFeatured: !internship,
        isSample: true,
        isVerified: false,
      );
}
