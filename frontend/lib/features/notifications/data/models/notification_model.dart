class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.recipientUid,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.actionRoute,
    this.applicationId,
  });

  final String id;
  final String recipientUid;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? actionRoute;
  final String? applicationId;

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        recipientUid: recipientUid,
        title: title,
        message: message,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        actionRoute: actionRoute,
        applicationId: applicationId,
      );

  Map<String, Object?> toFirestore() => {
        'recipientUid': recipientUid,
        'title': title,
        'message': message,
        'type': type,
        'isRead': isRead,
        'actionRoute': actionRoute,
        'applicationId': applicationId,
        'createdAt': createdAt,
      };

  factory NotificationModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    final type = (data['type'] as String?) ?? 'general';
    final rawTitle = (data['title'] as String?) ?? 'Career Bridge update';
    final title = type == 'recommendation' && rawTitle.contains('%')
        ? 'New job match found'
        : rawTitle;
    return NotificationModel(
      id: id,
      recipientUid: (data['recipientUid'] as String?) ?? '',
      title: title,
      message: (data['message'] as String?) ?? '',
      type: type,
      isRead: data['isRead'] as bool? ?? false,
      actionRoute: data['actionRoute'] as String?,
      applicationId: data['applicationId'] as String?,
      createdAt: _readDate(data['createdAt']),
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
