import '../../../../core/services/live_streams.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/enums/application_status.dart';
import '../../../applications/data/models/application_model.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../models/company_profile_model.dart';
import '../models/employer_job_model.dart';
import 'employer_workspace_repository.dart';

class FirebaseEmployerWorkspaceRepository
    implements EmployerWorkspaceRepository {
  FirebaseEmployerWorkspaceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<EmployerWorkspaceSnapshot> watch({required String uid}) {
    final company = _firestore
        .collection('companies')
        .where('ownerUid', isEqualTo: uid)
        .limit(1);
    final jobs = _firestore
        .collection('jobs')
        .where('employerUid', isEqualTo: uid)
        .orderBy('updatedAt', descending: true);
    return switchLatest(combineLatest([company.snapshots(), jobs.snapshots()]),
        (initial) {
      final companies = initial[0] as QuerySnapshot<Map<String, dynamic>>;
      final jobQuery = initial[1] as QuerySnapshot<Map<String, dynamic>>;
      if (companies.docs.isEmpty) {
        return Stream<EmployerWorkspaceSnapshot>.error(StateError(
            'No company profile is linked to this employer account.'));
      }
      final companyDoc = companies.docs.first;
      return combineLatest([
        _firestore
            .collection('companyVerifications')
            .doc(companyDoc.id)
            .snapshots(),
        _firestore
            .collection('notifications')
            .where('recipientUid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .snapshots(),
        for (final job in jobQuery.docs)
          _firestore
              .collection('applications')
              .where('jobId', isEqualTo: job.id)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      ]).map((results) {
        final verification =
            results[0] as DocumentSnapshot<Map<String, dynamic>>;
        final notifications = results[1] as QuerySnapshot<Map<String, dynamic>>;
        var profile =
            CompanyProfileModel.fromFirestore(companyDoc.id, companyDoc.data());
        if (verification.data() != null) {
          profile = profile.copyWith(
              tradeLicenseNumber:
                  verification.data()!['tradeLicenseNumber'] as String? ?? '');
        }
        final applications = [
          for (final result in results.skip(2))
            for (final doc
                in (result as QuerySnapshot<Map<String, dynamic>>).docs)
              ApplicationModel.fromFirestore(doc.id, doc.data()),
        ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return EmployerWorkspaceSnapshot(
            company: profile,
            jobs: jobQuery.docs
                .map(
                    (doc) => EmployerJobModel.fromFirestore(doc.id, doc.data()))
                .toList(),
            applications: applications,
            notifications: notifications.docs
                .map((doc) =>
                    NotificationModel.fromFirestore(doc.id, doc.data()))
                .toList());
      });
    });
  }

  @override
  Future<EmployerWorkspaceSnapshot> load({
    required String uid,
    required String companyName,
    required String contactName,
    required String email,
  }) async {
    final companyQuery = await _firestore
        .collection('companies')
        .where('ownerUid', isEqualTo: uid)
        .limit(1)
        .get();

    if (companyQuery.docs.isEmpty) {
      throw StateError(
          'No company profile is linked to this employer account.');
    }

    final companyDoc = companyQuery.docs.first;
    var company =
        CompanyProfileModel.fromFirestore(companyDoc.id, companyDoc.data());
    final verificationDoc = await _firestore
        .collection('companyVerifications')
        .doc(companyDoc.id)
        .get();
    final verificationData = verificationDoc.data();
    if (verificationData != null) {
      company = company.copyWith(
        tradeLicenseNumber:
            (verificationData['tradeLicenseNumber'] as String?) ?? '',
      );
    }

    final jobsQuery = await _firestore
        .collection('jobs')
        .where('employerUid', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .get();
    final jobs = jobsQuery.docs
        .map((doc) => EmployerJobModel.fromFirestore(doc.id, doc.data()))
        .toList(growable: false);

    final applications = <ApplicationModel>[];
    for (final job in jobs) {
      final query = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: job.id)
          .orderBy('createdAt', descending: true)
          .get();
      applications.addAll(
        query.docs
            .map((doc) => ApplicationModel.fromFirestore(doc.id, doc.data())),
      );
    }
    applications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final notificationsQuery = await _firestore
        .collection('notifications')
        .where('recipientUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    return EmployerWorkspaceSnapshot(
      company: company,
      jobs: jobs,
      applications: applications,
      notifications: notificationsQuery.docs
          .map((doc) => NotificationModel.fromFirestore(doc.id, doc.data()))
          .toList(growable: false),
    );
  }

  @override
  Future<void> saveCompany(CompanyProfileModel company) {
    return _firestore.collection('companies').doc(company.id).set(
          company.toFirestore(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<EmployerJobModel> saveJob(EmployerJobModel job) async {
    final collection = _firestore.collection('jobs');
    final ref =
        job.id.trim().isEmpty ? collection.doc() : collection.doc(job.id);
    final resolved = job.id.trim().isEmpty ? job.copyWith(id: ref.id) : job;
    await ref.set(
        resolved.toFirestore(), SetOptions(merge: job.id.trim().isNotEmpty));
    return resolved;
  }

  @override
  Future<void> updateApplication({
    required ApplicationModel application,
    required ApplicationStatus status,
    String? employerNote,
    DateTime? interviewAt,
  }) async {
    final applicationRef =
        _firestore.collection('applications').doc(application.id);
    final notificationRef = _firestore.collection('notifications').doc();
    if (status == ApplicationStatus.withdrawn) {
      throw StateError('Only the candidate can withdraw an application.');
    }
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(applicationRef);
      if (!snapshot.exists) {
        throw StateError('This application is no longer available.');
      }
      if (snapshot.data()!['status'] == 'withdrawn') {
        throw StateError('The candidate withdrew this application.');
      }

      transaction.update(applicationRef, {
        'status': status.firestoreValue,
        'employerNote': employerNote,
        'interviewAt': interviewAt,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(notificationRef, {
        'recipientUid': snapshot.data()!['applicantUid'],
        'title': _notificationTitle(status),
        'message': _notificationMessage(status, interviewAt),
        'type':
            status == ApplicationStatus.interview ? 'interview' : 'application',
        'isRead': false,
        'actionRoute': '/job-seeker/applications/${application.id}',
        'applicationId': application.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> markNotificationRead(NotificationModel notification) {
    return _firestore
        .collection('notifications')
        .doc(notification.id)
        .update({'isRead': true});
  }

  String _notificationTitle(ApplicationStatus status) => switch (status) {
        ApplicationStatus.reviewed => 'Application under review',
        ApplicationStatus.shortlisted => 'You were shortlisted',
        ApplicationStatus.interview => 'Interview scheduled',
        ApplicationStatus.hired => 'You were selected',
        ApplicationStatus.rejected => 'Application update',
        ApplicationStatus.applied => 'Application received',
        ApplicationStatus.withdrawn => 'Application withdrawn',
      };

  String _notificationMessage(ApplicationStatus status, DateTime? interviewAt) {
    if (status == ApplicationStatus.interview && interviewAt != null) {
      return 'Your interview has been scheduled for ${interviewAt.day}/${interviewAt.month}/${interviewAt.year} at ${interviewAt.hour.toString().padLeft(2, '0')}:${interviewAt.minute.toString().padLeft(2, '0')}.';
    }
    return 'Your application status is now ${status.label.toLowerCase()}.';
  }
}
