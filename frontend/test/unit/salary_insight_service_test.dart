import 'package:career_bridge/features/jobs/data/models/job_model.dart';
import 'package:career_bridge/features/public_portal/services/salary_insight_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('salary insights require enough comparable published salary data', () {
    final twoJobs = [
      _job('a', 40000, 60000),
      _job('b', 50000, 70000),
    ];
    expect(SalaryInsightService.calculate(twoJobs), isEmpty);

    final insights = SalaryInsightService.calculate([
      ...twoJobs,
      _job('c', 45000, 75000),
    ]);

    expect(insights, hasLength(1));
    final insight = insights.single;
    expect(insight.roleName, 'Flutter Developer');
    expect(insight.minimumSalary, 40000);
    expect(insight.maximumSalary, 75000);
    expect(insight.medianSalary, 60000);
    expect(insight.averageSalary, 56667);
    expect(insight.sampleSize, 3);
  });
}

JobModel _job(String id, int min, int max) {
  return JobModel(
    id: id,
    companyId: 'company-$id',
    companyName: 'Company $id',
    title: 'Flutter Developer',
    category: 'Technology',
    location: 'Dhaka',
    workMode: 'Hybrid',
    employmentType: 'Full-time',
    experience: '2–3 years',
    salaryLabel: '৳${min ~/ 1000}k–${max ~/ 1000}k / month',
    salaryMin: min,
    salaryMax: max,
    salaryPeriod: 'month',
    postedLabel: 'Today',
    deadlineLabel: '30 Sep 2026',
    openings: 1,
    description: 'Role description',
    responsibilities: const ['Build products'],
    requirements: const ['Flutter'],
    benefits: const ['Learning budget'],
    skills: const ['Flutter', 'Dart'],
  );
}
