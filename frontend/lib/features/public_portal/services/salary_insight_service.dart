import '../../jobs/data/models/job_model.dart';
import '../data/models/public_salary_insight_model.dart';

/// Builds salary insights directly from active/published job data.
///
/// No administrator-authored salary guide is required. Role-level insights are
/// preferred when enough comparable listings exist. Category-level insights
/// are used as a fallback so broader market trends can still be shown without
/// pretending that a single job posting represents the market.
abstract final class SalaryInsightService {
  static const int minimumSampleSize = 3;

  static List<PublicSalaryInsightModel> calculate(List<JobModel> jobs) {
    final usable = jobs.where(_hasComparableMonthlySalary).toList();
    if (usable.isEmpty) return const [];

    final roleGroups = <String, List<JobModel>>{};
    for (final job in usable) {
      final key = [
        _normalize(job.title),
        _normalize(job.location),
        _normalize(job.experience),
      ].join('|');
      roleGroups.putIfAbsent(key, () => <JobModel>[]).add(job);
    }

    final insights = <PublicSalaryInsightModel>[];
    final roleCoveredJobIds = <String>{};
    for (final group in roleGroups.values) {
      if (group.length < minimumSampleSize) continue;
      insights.add(_buildInsight(
        group,
        roleName: group.first.title,
        experienceLevel: group.first.experience,
      ));
      roleCoveredJobIds.addAll(group.map((job) => job.id));
    }

    final categoryGroups = <String, List<JobModel>>{};
    for (final job in usable) {
      if (roleCoveredJobIds.contains(job.id)) continue;
      final key = [
        _normalize(job.category),
        _normalize(job.location),
      ].join('|');
      categoryGroups.putIfAbsent(key, () => <JobModel>[]).add(job);
    }

    for (final group in categoryGroups.values) {
      if (group.length < minimumSampleSize) continue;
      insights.add(_buildInsight(
        group,
        roleName: '${group.first.category} roles',
        experienceLevel: 'Mixed experience',
      ));
    }

    insights.sort((a, b) {
      final sampleCompare = b.sampleSize.compareTo(a.sampleSize);
      if (sampleCompare != 0) return sampleCompare;
      return a.roleName.compareTo(b.roleName);
    });
    return List<PublicSalaryInsightModel>.unmodifiable(insights);
  }

  static bool _hasComparableMonthlySalary(JobModel job) {
    final period = job.salaryPeriod.trim().toLowerCase();
    final monthly = period.isEmpty ||
        period == 'month' ||
        period == 'monthly' ||
        period == 'per month';
    if (!monthly) return false;
    final min = _salaryMin(job);
    return min > 0 && job.salaryMax >= min;
  }

  static PublicSalaryInsightModel _buildInsight(
    List<JobModel> jobs, {
    required String roleName,
    required String experienceLevel,
  }) {
    final minimums = jobs.map(_salaryMin).toList()..sort();
    final maximums = jobs.map((job) => job.salaryMax).toList()..sort();
    final midpoints = jobs
        .map((job) => ((_salaryMin(job) + job.salaryMax) / 2).round())
        .toList()
      ..sort();

    final average =
        (midpoints.fold<int>(0, (sum, value) => sum + value) / midpoints.length)
            .round();
    final median = _median(midpoints);
    final first = jobs.first;
    final id = [
      _slug(roleName),
      _slug(first.location),
      _slug(experienceLevel),
    ].where((part) => part.isNotEmpty).join('-');

    return PublicSalaryInsightModel(
      id: id,
      roleName: roleName,
      category: first.category,
      location: first.location,
      experienceLevel: experienceLevel,
      minimumSalary: minimums.first,
      medianSalary: median,
      maximumSalary: maximums.last,
      averageSalary: average,
      sampleSize: jobs.length,
      updatedAt: DateTime.now(),
    );
  }

  static int _salaryMin(JobModel job) {
    if (job.salaryMin > 0) return job.salaryMin;
    final matches = RegExp(r'(\d+(?:\.\d+)?)\s*k', caseSensitive: false)
        .allMatches(job.salaryLabel)
        .toList();
    if (matches.isNotEmpty) {
      final value = double.tryParse(matches.first.group(1) ?? '');
      if (value != null) return (value * 1000).round();
    }
    return 0;
  }

  static int _median(List<int> values) {
    if (values.isEmpty) return 0;
    final middle = values.length ~/ 2;
    if (values.length.isOdd) return values[middle];
    return ((values[middle - 1] + values[middle]) / 2).round();
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String _slug(String value) => _normalize(value)
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
