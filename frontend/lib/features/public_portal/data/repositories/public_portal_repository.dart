import '../../../companies/data/models/company_model.dart';
import '../../../jobs/data/models/job_model.dart';
import '../landing_mock_data.dart';
import '../models/public_platform_settings_model.dart';
import '../models/public_salary_insight_model.dart';

class PublicPortalSnapshot {
  const PublicPortalSnapshot({
    required this.jobs,
    required this.companies,
    required this.categories,
    required this.salaryInsights,
    required this.settings,
  });

  final List<JobModel> jobs;
  final List<CompanyModel> companies;
  final List<JobCategory> categories;
  final List<PublicSalaryInsightModel> salaryInsights;
  final PublicPlatformSettingsModel settings;
}

abstract interface class PublicPortalRepository {
  Future<PublicPortalSnapshot> load();
}
