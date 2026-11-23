class JobCategoryAdminModel {
  const JobCategoryAdminModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.isActive,
    required this.sortOrder,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String iconName;
  final bool isActive;
  final int sortOrder;
  final DateTime updatedAt;

  JobCategoryAdminModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    bool? isActive,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return JobCategoryAdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toFirestore() => {
        'name': name.trim(),
        'description': description.trim(),
        'iconName': iconName.trim(),
        'isActive': isActive,
        'sortOrder': sortOrder,
        'updatedAt': updatedAt,
      };

  factory JobCategoryAdminModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return JobCategoryAdminModel(
      id: id,
      name: (data['name'] as String?) ?? 'Untitled category',
      description: (data['description'] as String?) ?? '',
      iconName: (data['iconName'] as String?) ?? 'work_outline',
      isActive: data['isActive'] as bool? ?? true,
      sortOrder: (data['sortOrder'] as num?)?.round() ?? 0,
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
