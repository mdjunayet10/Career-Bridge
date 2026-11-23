class AdminActivityModel {
  const AdminActivityModel({
    required this.id,
    required this.action,
    required this.subject,
    required this.detail,
    required this.createdAt,
  });

  final String id;
  final String action;
  final String subject;
  final String detail;
  final DateTime createdAt;

  factory AdminActivityModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return AdminActivityModel(
      id: id,
      action: (data['action'] as String?) ?? 'Admin action',
      subject: (data['subject'] as String?) ?? 'Platform',
      detail: (data['detail'] as String?) ?? '',
      createdAt: _readDate(data['createdAt']),
    );
  }

  Map<String, Object?> toFirestore({required String adminUid}) => {
        'adminUid': adminUid,
        'action': action,
        'subject': subject,
        'detail': detail,
        'createdAt': createdAt,
      };

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
