import 'dart:async';
import '../../applications/data/models/application_model.dart';
import '../../notifications/data/models/notification_model.dart';
import '../../../core/enums/application_status.dart';

/// Session-local sample mutations shared by demo seekers and demo employers.
/// This store has no Firebase dependency and never writes production records.
class DemoApplicationStore {
  DemoApplicationStore._();
  static final instance = DemoApplicationStore._();
  final _applications = <String, ApplicationModel>{};
  final _notifications = <String, NotificationModel>{};
  final _changes = StreamController<void>.broadcast();
  Stream<void> get changes => _changes.stream;

  List<ApplicationModel> mergeApplications(List<ApplicationModel> seed,
      bool Function(ApplicationModel application) accepts) {
    final merged = <String, ApplicationModel>{
      for (final app in seed) app.id: _applications[app.id] ?? app
    };
    for (final app in _applications.values.where(accepts)) {
      merged[app.id] = app;
    }
    return merged.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<NotificationModel> mergeNotifications(
      List<NotificationModel> seed, String uid) {
    final merged = <String, NotificationModel>{
      for (final item in seed) item.id: _notifications[item.id] ?? item
    };
    for (final item
        in _notifications.values.where((item) => item.recipientUid == uid)) {
      merged[item.id] = item;
    }
    return merged.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void put(ApplicationModel application) {
    _applications[application.id] = application;
    _changes.add(null);
  }

  void update(
      {required ApplicationModel application,
      required ApplicationStatus status,
      String? note,
      DateTime? interviewAt}) {
    final current = _applications[application.id] ?? application;
    if (current.status == ApplicationStatus.withdrawn) {
      throw StateError('The candidate withdrew this application.');
    }
    if (status == ApplicationStatus.withdrawn) {
      throw StateError('Only a candidate can withdraw an application.');
    }
    final now = DateTime.now();
    final updated = current.copyWith(
        status: status,
        employerNote: note,
        interviewAt: interviewAt,
        updatedAt: now,
        clearEmployerNote: note == null,
        clearInterviewAt: status != ApplicationStatus.interview);
    _applications[application.id] = updated;
    final notification = NotificationModel(
        id: 'demo-stage-${application.id}-${now.microsecondsSinceEpoch}',
        recipientUid: current.applicantUid,
        title: status == ApplicationStatus.hired
            ? 'Selected for ${current.jobTitle}'
            : '${status.label}: ${current.jobTitle}',
        message: status == ApplicationStatus.interview
            ? 'Demo interview scheduled for $interviewAt. ${note ?? ''}'
            : 'Your demo application is now ${status.label.toLowerCase()}.',
        type:
            status == ApplicationStatus.interview ? 'interview' : 'application',
        isRead: false,
        actionRoute: '/job-seeker/applications/${current.id}',
        applicationId: current.id,
        createdAt: now);
    _notifications[notification.id] = notification;
    _changes.add(null);
  }

  void withdraw(ApplicationModel application) {
    final current = _applications[application.id] ?? application;
    if (current.status.isTerminal) {
      throw StateError('This application is already closed.');
    }
    put(current.copyWith(
        status: ApplicationStatus.withdrawn, updatedAt: DateTime.now()));
  }

  void markRead(NotificationModel notification) {
    if (!_notifications.containsKey(notification.id)) return;
    _notifications[notification.id] = notification.copyWith(isRead: true);
    _changes.add(null);
  }

  void clear() {
    _applications.clear();
    _notifications.clear();
  }
}
