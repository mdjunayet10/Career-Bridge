import '../demo_showcase_catalog.dart';
import '../landing_mock_data.dart';
import '../models/public_platform_settings_model.dart';
import 'public_portal_repository.dart';

/// Both public demo pages and the protected Admin preview use the same catalogue.
class DemoPublicPortalRepository implements PublicPortalRepository {
  const DemoPublicPortalRepository();

  @override
  Future<PublicPortalSnapshot> load() async => PublicPortalSnapshot(
        jobs: DemoShowcaseCatalog.jobs,
        companies: DemoShowcaseCatalog.companies,
        categories: LandingMockData.categories,
        salaryInsights: const [],
        settings: PublicPlatformSettingsModel.defaults,
      );
}
