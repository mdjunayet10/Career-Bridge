class PublicSalaryInsightModel {
  const PublicSalaryInsightModel({
    required this.id,
    required this.roleName,
    required this.category,
    required this.location,
    required this.experienceLevel,
    required this.minimumSalary,
    required this.medianSalary,
    required this.maximumSalary,
    required this.updatedAt,
    this.averageSalary = 0,
    this.sampleSize = 0,
  });

  final String id;
  final String roleName;
  final String category;
  final String location;
  final String experienceLevel;
  final int minimumSalary;
  final int medianSalary;
  final int maximumSalary;
  final int averageSalary;
  final int sampleSize;
  final DateTime updatedAt;

  String get minimumLabel => _salaryLabel(minimumSalary);
  String get medianLabel => _salaryLabel(medianSalary);
  String get maximumLabel => _salaryLabel(maximumSalary);
  String get averageLabel => _salaryLabel(averageSalary);

  static String _salaryLabel(int value) {
    if (value <= 0) return 'Not available';
    if (value >= 1000 && value % 1000 == 0) return '৳${value ~/ 1000}k';
    return '৳$value';
  }
}
