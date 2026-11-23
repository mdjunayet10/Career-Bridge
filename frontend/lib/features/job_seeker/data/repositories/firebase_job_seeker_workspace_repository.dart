import '../../../../core/services/live_streams.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/enums/application_status.dart';
import '../../../../core/services/cv_pdf_service.dart';
import '../../../file_storage/data/repositories/firebase_file_object_repository.dart';
import '../../../applications/data/models/application_model.dart';
import '../../../cv_builder/data/models/cv_profile_model.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../jobs/data/models/job_model.dart';
import '../models/job_seeker_profile_model.dart';
import 'job_seeker_workspace_repository.dart';

class FirebaseJobSeekerWorkspaceRepository
    implements JobSeekerWorkspaceRepository {
  FirebaseJobSeekerWorkspaceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<JobSeekerWorkspaceSnapshot> load({
    required String uid,
    required String name,
    required String email,
  }) async {
    final results = await Future.wait([
      _firestore.collection('jobSeekerProfiles').doc(uid).get(),
      _firestore.collection('savedJobs').where('userUid', isEqualTo: uid).get(),
      _firestore
          .collection('applications')
          .where('applicantUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get(),
      _firestore
          .collection('notifications')
          .where('recipientUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get(),
      _firestore.collection('cvProfiles').doc(uid).get(),
    ]);

    return _fromResults(uid, name, email, results);
  }

  Stream<JobSeekerWorkspaceSnapshot> watch(
          {required String uid, required String name, required String email}) =>
      combineLatest([
        _firestore.collection('jobSeekerProfiles').doc(uid).snapshots(),
        _firestore
            .collection('savedJobs')
            .where('userUid', isEqualTo: uid)
            .snapshots(),
        _firestore
            .collection('applications')
            .where('applicantUid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        _firestore
            .collection('notifications')
            .where('recipientUid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        _firestore.collection('cvProfiles').doc(uid).snapshots(),
      ]).map((results) => _fromResults(uid, name, email, results));

  JobSeekerWorkspaceSnapshot _fromResults(
      String uid, String name, String email, List<Object> results) {
    final profileDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final savedQuery = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final applicationsQuery = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final notificationsQuery =
        results[3] as QuerySnapshot<Map<String, dynamic>>;
    final cvDoc = results[4] as DocumentSnapshot<Map<String, dynamic>>;

    final now = DateTime.now();
    final profile = profileDoc.exists
        ? JobSeekerProfileModel.fromFirestore(
            uid,
            profileDoc.data()!,
            fallbackName: name,
            fallbackEmail: email,
          )
        : JobSeekerProfileModel(
            uid: uid, fullName: name, email: email, updatedAt: now);

    final cvProfile = cvDoc.exists
        ? CvProfileModel.fromFirestore(uid, cvDoc.data()!,
            fallbackName: name, fallbackEmail: email)
        : CvProfileModel(
            ownerUid: uid, fullName: name, email: email, updatedAt: now);

    return JobSeekerWorkspaceSnapshot(
      profile: profile,
      savedJobIds: savedQuery.docs
          .map((doc) => doc.data()['jobId'])
          .whereType<String>()
          .toSet(),
      applications: applicationsQuery.docs
          .map((doc) => ApplicationModel.fromFirestore(doc.id, doc.data()))
          .toList(growable: false),
      notifications: notificationsQuery.docs
          .map((doc) => NotificationModel.fromFirestore(doc.id, doc.data()))
          .toList(growable: false),
      cvProfile: cvProfile,
    );
  }

  @override
  Future<void> saveProfile(JobSeekerProfileModel profile) {
    return _firestore.collection('jobSeekerProfiles').doc(profile.uid).set(
          profile.toFirestore(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> setSavedJob(
      {required String uid, required String jobId, required bool saved}) async {
    final ref = _firestore.collection('savedJobs').doc('${uid}_$jobId');
    if (saved) {
      await ref.set({
        'userUid': uid,
        'jobId': jobId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  @override
  Future<void> saveProfileAndCv({
    required JobSeekerProfileModel profile,
    required CvProfileModel cvProfile,
  }) async {
    if (profile.uid != cvProfile.ownerUid) {
      throw ArgumentError('Profile and CV must have the same owner.');
    }
    final batch = _firestore.batch();
    batch.set(
      _firestore.collection('jobSeekerProfiles').doc(profile.uid),
      profile.toFirestore(),
      SetOptions(merge: true),
    );
    batch.set(
      _firestore.collection('cvProfiles').doc(cvProfile.ownerUid),
      cvProfile.toFirestore(),
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  Future<ApplicationModel> submitApplication({
    required String uid,
    required JobModel job,
    required String coverLetter,
    required CvProfileModel? cvProfile,
    required JobSeekerProfileModel applicantProfile,
  }) async {
    final active = await _firestore
        .collection('applications')
        .where('applicantUid', isEqualTo: uid)
        .where('jobId', isEqualTo: job.id)
        .limit(5)
        .get();
    final hasActive = active.docs.any(
      (doc) =>
          ApplicationStatus.fromFirestore(doc.data()['status'] as String?) !=
          ApplicationStatus.withdrawn,
    );
    if (hasActive) {
      throw StateError('You already have an active application for this job.');
    }

    final now = DateTime.now();
    final ref = _firestore.collection('applications').doc();
    String? cvFileId;

    if (cvProfile != null) {
      final preparedPdf =
          await CvPdfService.instance.prepareForUpload(cvProfile);
      final uploaded =
          await FirebaseFileObjectRepository(firestore: _firestore).upload(
        file: preparedPdf,
        ownerUid: uid,
        purpose: 'applicationCv',
        applicationId: ref.id,
      );
      cvFileId = uploaded.id;
    }

    final application = ApplicationModel(
      id: ref.id,
      jobId: job.id,
      applicantUid: uid,
      status: ApplicationStatus.applied,
      coverLetter: coverLetter.trim(),
      cvProfileId: cvProfile?.ownerUid,
      cvFileId: cvFileId,
      applicantName: applicantProfile.fullName,
      applicantEmail: applicantProfile.email,
      applicantHeadline: applicantProfile.headline,
      applicantLocation: applicantProfile.location,
      applicantExperienceYears: applicantProfile.experienceYears,
      applicantSkills: applicantProfile.allSkills,
      jobTitle: job.title,
      companyId: job.companyId,
      companyName: job.companyName,
      jobLocation: job.location,
      jobEmploymentType: job.employmentType,
      jobSalaryLabel: job.salaryLabel,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await ref.set(application.toFirestore());
      return application;
    } catch (_) {
      if (cvFileId != null) {
        await FirebaseFileObjectRepository(firestore: _firestore)
            .delete(cvFileId);
      }
      rethrow;
    }
  }

  @override
  Future<void> withdrawApplication(ApplicationModel application) {
    return _firestore.collection('applications').doc(application.id).update({
      'status': ApplicationStatus.withdrawn.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markNotificationRead(NotificationModel notification) {
    return _firestore
        .collection('notifications')
        .doc(notification.id)
        .update({'isRead': true});
  }

  @override
  Future<void> createNotification(NotificationModel notification) {
    return _firestore
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toFirestore());
  }

  @override
  Future<void> saveCvProfile(CvProfileModel cvProfile) {
    return _firestore.collection('cvProfiles').doc(cvProfile.ownerUid).set(
          cvProfile.toFirestore(),
          SetOptions(merge: true),
        );
  }
}
