enum PlatformReportStatus {
  open,
  inReview,
  resolved,
  dismissed;

  String get firestoreValue => switch (this) {
        PlatformReportStatus.open => 'open',
        PlatformReportStatus.inReview => 'inReview',
        PlatformReportStatus.resolved => 'resolved',
        PlatformReportStatus.dismissed => 'dismissed',
      };

  String get label => switch (this) {
        PlatformReportStatus.open => 'Open',
        PlatformReportStatus.inReview => 'In review',
        PlatformReportStatus.resolved => 'Resolved',
        PlatformReportStatus.dismissed => 'Dismissed',
      };

  bool get isClosed =>
      this == PlatformReportStatus.resolved ||
      this == PlatformReportStatus.dismissed;

  static PlatformReportStatus fromFirestore(String? value) => switch (value) {
        'inReview' => PlatformReportStatus.inReview,
        'resolved' => PlatformReportStatus.resolved,
        'dismissed' => PlatformReportStatus.dismissed,
        _ => PlatformReportStatus.open,
      };
}

class PlatformReportModel {
  const PlatformReportModel({
    required this.id,
    required this.reporterUid,
    required this.reporterName,
    required this.targetType,
    required this.targetId,
    required this.targetLabel,
    required this.reason,
    required this.details,
    required this.status,
    required this.createdAt,
    this.resolutionNote,
    this.resolvedAt,
  });

  final String id;
  final String reporterUid;
  final String reporterName;
  final String targetType;
  final String targetId;
  final String targetLabel;
  final String reason;
  final String details;
  final PlatformReportStatus status;
  final DateTime createdAt;
  final String? resolutionNote;
  final DateTime? resolvedAt;

  PlatformReportModel copyWith({
    PlatformReportStatus? status,
    String? resolutionNote,
    DateTime? resolvedAt,
  }) {
    return PlatformReportModel(
      id: id,
      reporterUid: reporterUid,
      reporterName: reporterName,
      targetType: targetType,
      targetId: targetId,
      targetLabel: targetLabel,
      reason: reason,
      details: details,
      status: status ?? this.status,
      createdAt: createdAt,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  factory PlatformReportModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return PlatformReportModel(
      id: id,
      reporterUid: (data['reporterUid'] as String?) ?? '',
      reporterName: (data['reporterName'] as String?) ?? 'Career Bridge user',
      targetType: (data['targetType'] as String?) ?? 'content',
      targetId: (data['targetId'] as String?) ?? '',
      targetLabel: (data['targetLabel'] as String?) ?? 'Reported content',
      reason: (data['reason'] as String?) ?? 'Policy concern',
      details: (data['details'] as String?) ?? '',
      status: PlatformReportStatus.fromFirestore(data['status'] as String?),
      createdAt: _readDate(data['createdAt']),
      resolutionNote: data['resolutionNote'] as String?,
      resolvedAt: _readNullableDate(data['resolvedAt']),
    );
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
