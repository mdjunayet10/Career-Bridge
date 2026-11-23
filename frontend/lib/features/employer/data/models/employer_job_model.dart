import '../../../../core/enums/employer_job_status.dart';

class EmployerJobModel {
  const EmployerJobModel({
    required this.id,
    required this.employerUid,
    required this.companyId,
    required this.title,
    required this.categoryId,
    required this.location,
    required this.workMode,
    required this.employmentType,
    required this.experienceLevel,
    required this.salaryMin,
    required this.salaryMax,
    required this.salaryPeriod,
    required this.description,
    required this.responsibilities,
    required this.requirements,
    required this.skills,
    required this.benefits,
    required this.deadline,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.rejectionNote,
  });

  final String id;
  final String employerUid;
  final String companyId;
  final String title;
  final String categoryId;
  final String location;
  final String workMode;
  final String employmentType;
  final String experienceLevel;
  final int salaryMin;
  final int salaryMax;
  final String salaryPeriod;
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> skills;
  final List<String> benefits;
  final DateTime deadline;
  final EmployerJobStatus status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final String? rejectionNote;

  String get salaryLabel {
    final min = (salaryMin / 1000).round();
    final max = (salaryMax / 1000).round();
    return '৳${min}k–${max}k / $salaryPeriod';
  }

  EmployerJobModel copyWith({
    String? id,
    String? title,
    String? categoryId,
    String? location,
    String? workMode,
    String? employmentType,
    String? experienceLevel,
    int? salaryMin,
    int? salaryMax,
    String? salaryPeriod,
    String? description,
    List<String>? responsibilities,
    List<String>? requirements,
    List<String>? skills,
    List<String>? benefits,
    DateTime? deadline,
    EmployerJobStatus? status,
    bool? isActive,
    DateTime? updatedAt,
    DateTime? publishedAt,
    String? rejectionNote,
  }) {
    return EmployerJobModel(
      id: id ?? this.id,
      employerUid: employerUid,
      companyId: companyId,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      location: location ?? this.location,
      workMode: workMode ?? this.workMode,
      employmentType: employmentType ?? this.employmentType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryPeriod: salaryPeriod ?? this.salaryPeriod,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      requirements: requirements ?? this.requirements,
      skills: skills ?? this.skills,
      benefits: benefits ?? this.benefits,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      rejectionNote: rejectionNote ?? this.rejectionNote,
    );
  }

  Map<String, Object?> toFirestore() => {
        'employerUid': employerUid,
        'companyId': companyId,
        'title': title.trim(),
        'categoryId': categoryId.trim(),
        'location': location.trim(),
        'workMode': workMode,
        'employmentType': employmentType,
        'experienceLevel': experienceLevel,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'salaryPeriod': salaryPeriod,
        'description': description.trim(),
        'responsibilities': responsibilities,
        'requirements': requirements,
        'skills': skills,
        'benefits': benefits,
        'deadline': deadline,
        'status': status.firestoreValue,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'publishedAt': publishedAt,
        'rejectionNote': rejectionNote,
      };

  factory EmployerJobModel.fromFirestore(String id, Map<String, dynamic> data) {
    return EmployerJobModel(
      id: id,
      employerUid: (data['employerUid'] as String?) ?? '',
      companyId: (data['companyId'] as String?) ?? '',
      title: (data['title'] as String?) ?? 'Untitled job',
      categoryId: (data['categoryId'] as String?) ?? 'Other',
      location: (data['location'] as String?) ?? '',
      workMode: (data['workMode'] as String?) ?? 'On-site',
      employmentType: (data['employmentType'] as String?) ?? 'Full-time',
      experienceLevel: (data['experienceLevel'] as String?) ?? 'Entry level',
      salaryMin: (data['salaryMin'] as num?)?.round() ?? 0,
      salaryMax: (data['salaryMax'] as num?)?.round() ?? 0,
      salaryPeriod: (data['salaryPeriod'] as String?) ?? 'month',
      description: (data['description'] as String?) ?? '',
      responsibilities: _readStrings(data['responsibilities']),
      requirements: _readStrings(data['requirements']),
      skills: _readStrings(data['skills']),
      benefits: _readStrings(data['benefits']),
      deadline: _readDate(data['deadline']),
      status: EmployerJobStatus.fromFirestore(data['status'] as String?),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
      publishedAt: _readNullableDate(data['publishedAt']),
      rejectionNote: data['rejectionNote'] as String?,
    );
  }

  static List<String> _readStrings(Object? value) {
    if (value is Iterable) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }

  static DateTime _readDate(Object? value) =>
      _readNullableDate(value) ?? DateTime.now();

  static DateTime? _readNullableDate(Object? value) {
    if (value is DateTime) return value;
    try {
      final dynamic dynamicValue = value;
      final converted = dynamicValue?.toDate();
      if (converted is DateTime) return converted;
    } catch (_) {}
    return null;
  }
}
