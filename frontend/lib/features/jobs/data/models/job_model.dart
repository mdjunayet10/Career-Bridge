class JobModel {
  const JobModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.category,
    required this.location,
    required this.workMode,
    required this.employmentType,
    required this.experience,
    required this.salaryLabel,
    required this.salaryMax,
    required this.postedLabel,
    required this.deadlineLabel,
    required this.openings,
    required this.description,
    required this.responsibilities,
    required this.requirements,
    required this.benefits,
    required this.skills,
    this.salaryMin = 0,
    this.salaryPeriod = 'month',
    this.isFeatured = false,
    this.isVerified = true,
    this.isSample = false,
  });

  final String id;
  final String companyId;
  final String companyName;
  final String title;
  final String category;
  final String location;
  final String workMode;
  final String employmentType;
  final String experience;
  final String salaryLabel;
  final int salaryMin;
  final int salaryMax;
  final String salaryPeriod;
  final String postedLabel;
  final String deadlineLabel;
  final int openings;
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> benefits;
  final List<String> skills;
  final bool isFeatured;
  final bool isVerified;
  final bool isSample;

  JobModel copyWith({
    int? salaryMin,
    int? salaryMax,
    String? salaryPeriod,
    bool? isFeatured,
    bool? isVerified,
    bool? isSample,
  }) {
    return JobModel(
      id: id,
      companyId: companyId,
      companyName: companyName,
      title: title,
      category: category,
      location: location,
      workMode: workMode,
      employmentType: employmentType,
      experience: experience,
      salaryLabel: salaryLabel,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryPeriod: salaryPeriod ?? this.salaryPeriod,
      postedLabel: postedLabel,
      deadlineLabel: deadlineLabel,
      openings: openings,
      description: description,
      responsibilities: responsibilities,
      requirements: requirements,
      benefits: benefits,
      skills: skills,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      isSample: isSample ?? this.isSample,
    );
  }

  bool matchesText(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    final searchable = [
      title,
      companyName,
      category,
      location,
      workMode,
      employmentType,
      ...skills,
    ].join(' ').toLowerCase();

    return searchable.contains(normalized);
  }
}
