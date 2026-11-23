import '../../../../core/enums/employer_job_status.dart';
import '../../../../core/enums/employer_verification_status.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../../employer/data/models/employer_job_model.dart';
import '../models/admin_activity_model.dart';
import '../models/admin_company_review_model.dart';
import '../models/job_category_admin_model.dart';
import '../models/platform_report_model.dart';
import '../models/platform_settings_model.dart';
import '../models/salary_insight_admin_model.dart';

class AdminWorkspaceSnapshot {
  const AdminWorkspaceSnapshot({
    required this.users,
    required this.companies,
    required this.jobs,
    required this.reports,
    required this.categories,
    required this.salaryInsights,
    required this.settings,
    required this.activities,
  });

  final List<AppUserModel> users;
  final List<AdminCompanyReviewModel> companies;
  final List<EmployerJobModel> jobs;
  final List<PlatformReportModel> reports;
  final List<JobCategoryAdminModel> categories;
  final List<SalaryInsightAdminModel> salaryInsights;
  final PlatformSettingsModel settings;
  final List<AdminActivityModel> activities;
}

abstract interface class AdminWorkspaceRepository {
  Future<AdminWorkspaceSnapshot> load();

  Future<void> reviewEmployer({
    required AdminCompanyReviewModel company,
    required EmployerVerificationStatus status,
    required String note,
  });

  Future<void> reviewJob({
    required EmployerJobModel job,
    required EmployerJobStatus status,
    required String note,
  });

  Future<void> setUserActive(
      {required AppUserModel user, required bool isActive});

  Future<void> setCompanyActive({
    required AdminCompanyReviewModel company,
    required bool isActive,
  });

  Future<void> updateReport({
    required PlatformReportModel report,
    required PlatformReportStatus status,
    required String note,
  });

  Future<JobCategoryAdminModel> saveCategory(JobCategoryAdminModel category);

  Future<SalaryInsightAdminModel> saveSalaryInsight(
      SalaryInsightAdminModel insight);

  Future<void> saveSettings(PlatformSettingsModel settings);
}
