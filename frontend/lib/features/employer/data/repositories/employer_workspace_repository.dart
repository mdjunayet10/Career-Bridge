import '../../../../core/enums/application_status.dart';
import '../../../applications/data/models/application_model.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../models/company_profile_model.dart';
import '../models/employer_job_model.dart';

class EmployerWorkspaceSnapshot {
  const EmployerWorkspaceSnapshot({
    required this.company,
    required this.jobs,
    required this.applications,
    required this.notifications,
  });

  final CompanyProfileModel company;
  final List<EmployerJobModel> jobs;
  final List<ApplicationModel> applications;
  final List<NotificationModel> notifications;
}

abstract interface class EmployerWorkspaceRepository {
  Future<EmployerWorkspaceSnapshot> load({
    required String uid,
    required String companyName,
    required String contactName,
    required String email,
  });

  Future<void> saveCompany(CompanyProfileModel company);

  Future<EmployerJobModel> saveJob(EmployerJobModel job);

  Future<void> updateApplication({
    required ApplicationModel application,
    required ApplicationStatus status,
    String? employerNote,
    DateTime? interviewAt,
  });

  Future<void> markNotificationRead(NotificationModel notification);
}
