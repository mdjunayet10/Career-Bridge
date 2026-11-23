import '../../../applications/data/models/application_model.dart';
import '../../../cv_builder/data/models/cv_profile_model.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../jobs/data/models/job_model.dart';
import '../models/job_seeker_profile_model.dart';

class JobSeekerWorkspaceSnapshot {
  const JobSeekerWorkspaceSnapshot({
    required this.profile,
    required this.savedJobIds,
    required this.applications,
    required this.notifications,
    required this.cvProfile,
  });

  final JobSeekerProfileModel profile;
  final Set<String> savedJobIds;
  final List<ApplicationModel> applications;
  final List<NotificationModel> notifications;
  final CvProfileModel cvProfile;
}

abstract interface class JobSeekerWorkspaceRepository {
  Future<JobSeekerWorkspaceSnapshot> load({
    required String uid,
    required String name,
    required String email,
  });

  Future<void> saveProfile(JobSeekerProfileModel profile);

  Future<void> saveProfileAndCv({
    required JobSeekerProfileModel profile,
    required CvProfileModel cvProfile,
  });

  Future<void> setSavedJob({
    required String uid,
    required String jobId,
    required bool saved,
  });

  Future<ApplicationModel> submitApplication({
    required String uid,
    required JobModel job,
    required String coverLetter,
    required CvProfileModel? cvProfile,
    required JobSeekerProfileModel applicantProfile,
  });

  Future<void> withdrawApplication(ApplicationModel application);

  Future<void> markNotificationRead(NotificationModel notification);

  Future<void> createNotification(NotificationModel notification);

  Future<void> saveCvProfile(CvProfileModel cvProfile);
}
