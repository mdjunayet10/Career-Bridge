import 'package:career_bridge/features/public_portal/data/repositories/demo_public_portal_repository.dart';
import 'package:career_bridge/features/public_portal/services/salary_insight_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('demo public portal exposes a complete reviewable catalogue', () async {
    const repository = DemoPublicPortalRepository();
    final snapshot = await repository.load();

    expect(snapshot.jobs, isNotEmpty);
    expect(snapshot.companies, isNotEmpty);
    expect(snapshot.categories, isNotEmpty);
    expect(snapshot.settings.allowJobSeekerRegistration, isTrue);
    expect(snapshot.settings.allowEmployerRegistration, isTrue);

    final companyIds = snapshot.companies.map((company) => company.id).toSet();
    expect(
      snapshot.jobs.every((job) => companyIds.contains(job.companyId)),
      isTrue,
    );

    final automaticInsights = SalaryInsightService.calculate(snapshot.jobs);
    expect(automaticInsights, isNotEmpty);
    expect(
      automaticInsights.every(
        (insight) =>
            insight.sampleSize >= SalaryInsightService.minimumSampleSize,
      ),
      isTrue,
    );
  });
}
