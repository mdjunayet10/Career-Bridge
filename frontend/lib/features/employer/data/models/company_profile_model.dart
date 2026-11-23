class CompanyProfileModel {
  const CompanyProfileModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.industry,
    required this.companySize,
    required this.website,
    required this.email,
    required this.phone,
    required this.address,
    required this.description,
    required this.tradeLicenseNumber,
    required this.verificationStatus,
    required this.isActive,
    required this.updatedAt,
    this.logoFileId = '',
  });

  final String id;
  final String ownerUid;
  final String name;
  final String industry;
  final String companySize;
  final String website;
  final String email;
  final String phone;
  final String address;
  final String description;
  final String tradeLicenseNumber;
  final String verificationStatus;
  final bool isActive;
  final DateTime updatedAt;
  final String logoFileId;

  int get completionPercent {
    final values = [
      name,
      industry,
      companySize,
      website,
      email,
      phone,
      address,
      description,
      tradeLicenseNumber,
    ];
    final completed = values.where((value) => value.trim().isNotEmpty).length;
    return ((completed / values.length) * 100).round();
  }

  CompanyProfileModel copyWith({
    String? name,
    String? industry,
    String? companySize,
    String? website,
    String? email,
    String? phone,
    String? address,
    String? description,
    String? tradeLicenseNumber,
    String? logoFileId,
    DateTime? updatedAt,
  }) {
    return CompanyProfileModel(
      id: id,
      ownerUid: ownerUid,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      companySize: companySize ?? this.companySize,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      description: description ?? this.description,
      tradeLicenseNumber: tradeLicenseNumber ?? this.tradeLicenseNumber,
      logoFileId: logoFileId ?? this.logoFileId,
      verificationStatus: verificationStatus,
      isActive: isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toFirestore() => {
        'ownerUid': ownerUid,
        'name': name.trim(),
        'industry': industry.trim(),
        'companySize': companySize.trim(),
        'website': website.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'description': description.trim(),
        'logoFileId': logoFileId.isEmpty ? null : logoFileId,
        'verificationStatus': verificationStatus,
        'isActive': isActive,
        'updatedAt': updatedAt,
      };

  factory CompanyProfileModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return CompanyProfileModel(
      id: id,
      ownerUid: (data['ownerUid'] as String?) ?? '',
      name: (data['name'] as String?) ?? 'Career Bridge Employer',
      industry: (data['industry'] as String?) ?? '',
      companySize: (data['companySize'] as String?) ?? '',
      website: (data['website'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      address: (data['address'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      logoFileId: (data['logoFileId'] as String?) ?? '',
      tradeLicenseNumber: (data['tradeLicenseNumber'] as String?) ?? '',
      verificationStatus: (data['verificationStatus'] as String?) ?? 'pending',
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
