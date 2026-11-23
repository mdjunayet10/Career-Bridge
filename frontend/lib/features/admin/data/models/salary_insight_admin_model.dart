class SalaryInsightAdminModel {
  const SalaryInsightAdminModel({
    required this.id,
    required this.roleName,
    required this.category,
    required this.location,
    required this.experienceLevel,
    required this.minimumSalary,
    required this.medianSalary,
    required this.maximumSalary,
    required this.isActive,
    required this.updatedAt,
  });

  final String id;
  final String roleName;
  final String category;
  final String location;
  final String experienceLevel;
  final int minimumSalary;
  final int medianSalary;
  final int maximumSalary;
  final bool isActive;
  final DateTime updatedAt;

  SalaryInsightAdminModel copyWith({
    String? id,
    String? roleName,
    String? category,
    String? location,
    String? experienceLevel,
    int? minimumSalary,
    int? medianSalary,
    int? maximumSalary,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return SalaryInsightAdminModel(
      id: id ?? this.id,
      roleName: roleName ?? this.roleName,
      category: category ?? this.category,
      location: location ?? this.location,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      minimumSalary: minimumSalary ?? this.minimumSalary,
      medianSalary: medianSalary ?? this.medianSalary,
      maximumSalary: maximumSalary ?? this.maximumSalary,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toFirestore() => {
        'roleName': roleName.trim(),
        'category': category.trim(),
        'location': location.trim(),
        'experienceLevel': experienceLevel.trim(),
        'minimumSalary': minimumSalary,
        'medianSalary': medianSalary,
        'maximumSalary': maximumSalary,
        'isActive': isActive,
        'updatedAt': updatedAt,
      };

  factory SalaryInsightAdminModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return SalaryInsightAdminModel(
      id: id,
      roleName: (data['roleName'] as String?) ?? 'Untitled role',
      category: (data['category'] as String?) ?? 'Other',
      location: (data['location'] as String?) ?? 'Bangladesh',
      experienceLevel: (data['experienceLevel'] as String?) ?? 'All levels',
      minimumSalary: (data['minimumSalary'] as num?)?.round() ?? 0,
      medianSalary: (data['medianSalary'] as num?)?.round() ?? 0,
      maximumSalary: (data['maximumSalary'] as num?)?.round() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  static DateTime _readDate(Object? value) {
    if (value is DateTime) return value;
    try {
      final dynamic dynamicValue = value;
      final converted = dynamicValue?.toDate();
      if (converted is DateTime) return converted;
    } catch (_) {}
    return DateTime.now();
  }
}
