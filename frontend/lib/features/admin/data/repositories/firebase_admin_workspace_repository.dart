import '../../../../core/services/live_streams.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/enums/employer_job_status.dart';
import '../../../../core/enums/employer_verification_status.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../../employer/data/models/employer_job_model.dart';
import '../models/admin_activity_model.dart';
import '../models/admin_company_review_model.dart';
import '../models/job_category_admin_model.dart';
import '../models/platform_report_model.dart';
import '../models/platform_settings_model.dart';
import '../models/salary_insight_admin_model.dart';
import 'admin_workspace_repository.dart';

class FirebaseAdminWorkspaceRepository implements AdminWorkspaceRepository {
  FirebaseAdminWorkspaceRepository(
      {FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<AdminWorkspaceSnapshot> load() async {
    final results = await Future.wait([
      _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get(),
      _firestore
          .collection('companies')
          .orderBy('createdAt', descending: true)
          .limit(300)
          .get(),
      _firestore.collection('companyVerifications').limit(300).get(),
      _firestore
          .collection('jobs')
          .orderBy('updatedAt', descending: true)
          .limit(500)
          .get(),
      _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(300)
          .get(),
      _firestore.collection('categories').orderBy('sortOrder').get(),
      _firestore.collection('salaryInsights').orderBy('roleName').get(),
      _firestore.collection('platformSettings').doc('general').get(),
      _firestore
          .collection('auditLogs')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get(),
    ]);

    return _fromResults(results);
  }

  Stream<AdminWorkspaceSnapshot> watch() => combineLatest([
        _firestore
            .collection('users')
            .orderBy('createdAt', descending: true)
            .limit(500)
            .snapshots(),
        _firestore
            .collection('companies')
            .orderBy('createdAt', descending: true)
            .limit(300)
            .snapshots(),
        _firestore.collection('companyVerifications').limit(300).snapshots(),
        _firestore
            .collection('jobs')
            .orderBy('updatedAt', descending: true)
            .limit(500)
            .snapshots(),
        _firestore
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .limit(300)
            .snapshots(),
        _firestore.collection('categories').orderBy('sortOrder').snapshots(),
        _firestore.collection('salaryInsights').orderBy('roleName').snapshots(),
        _firestore.collection('platformSettings').doc('general').snapshots(),
        _firestore
            .collection('auditLogs')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
      ]).map(_fromResults);

  AdminWorkspaceSnapshot _fromResults(List<Object> results) {
    final usersQuery = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final companiesQuery = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final verificationsQuery =
        results[2] as QuerySnapshot<Map<String, dynamic>>;
    final jobsQuery = results[3] as QuerySnapshot<Map<String, dynamic>>;
    final reportsQuery = results[4] as QuerySnapshot<Map<String, dynamic>>;
    final categoriesQuery = results[5] as QuerySnapshot<Map<String, dynamic>>;
    final salaryQuery = results[6] as QuerySnapshot<Map<String, dynamic>>;
    final settingsDoc = results[7] as DocumentSnapshot<Map<String, dynamic>>;
    final activityQuery = results[8] as QuerySnapshot<Map<String, dynamic>>;

    final verificationById = <String, Map<String, dynamic>>{
      for (final doc in verificationsQuery.docs) doc.id: doc.data(),
    };

    return AdminWorkspaceSnapshot(
      users: usersQuery.docs
          .map((doc) => AppUserModel.fromFirestore(doc.id, doc.data()))
          .toList(growable: false),
      companies: companiesQuery.docs
          .map(
            (doc) => AdminCompanyReviewModel.fromFirestore(
              companyId: doc.id,
              company: doc.data(),
              verification: verificationById[doc.id],
            ),
          )
          .toList(growable: false),
      jobs: jobsQuery.docs
          .map((doc) => EmployerJobModel.fromFirestore(doc.id, doc.data()))
          .toList(growable: false),
      reports: reportsQuery.docs
          .map((doc) => PlatformReportModel.fromFirestore(doc.id, doc.data()))
          .toList(growable: false),
      categories: categoriesQuery.docs
          .map((doc) => JobCategoryAdminModel.fromFirestore(doc.id, doc.data()))
          .toList(growable: false),
      salaryInsights: salaryQuery.docs
          .map((doc) =>
              SalaryInsightAdminModel.fromFirestore(doc.id, doc.data()))
          .toList(growable: false),
      settings: settingsDoc.exists
          ? PlatformSettingsModel.fromFirestore(settingsDoc.data()!)
          : PlatformSettingsModel(
              platformName: 'Career Bridge',
              supportEmail: 'support@careerbridge.local',
              employerReviewRequired: true,
              jobReviewRequired: true,
              maintenanceMode: false,
              allowJobSeekerRegistration: true,
              allowEmployerRegistration: true,
              updatedAt: DateTime.now(),
            ),
      activities: activityQuery.docs
          .map((doc) => AdminActivityModel.fromFirestore(doc.id, doc.data()))
          .toList(growable: false),
    );
  }

  @override
  Future<void> reviewEmployer({
    required AdminCompanyReviewModel company,
    required EmployerVerificationStatus status,
    required String note,
  }) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    batch.update(_firestore.collection('companies').doc(company.companyId), {
      'verificationStatus': status.firestoreValue,
      'updatedAt': now,
    });
    batch.set(
      _firestore.collection('companyVerifications').doc(company.companyId),
      {
        'companyId': company.companyId,
        'ownerUid': company.ownerUid,
        'status': status.firestoreValue,
        'decisionNote': note.trim(),
        'reviewedAt': now,
        'reviewedBy': _adminUid,
      },
      SetOptions(merge: true),
    );
    batch.update(_firestore.collection('users').doc(company.ownerUid), {
      'verificationStatus': status.firestoreValue,
      'updatedAt': now,
    });
    batch.set(_firestore.collection('notifications').doc(), {
      'recipientUid': company.ownerUid,
      'title': status == EmployerVerificationStatus.approved
          ? 'Company verification approved'
          : 'Company verification update',
      'message': note.trim().isEmpty
          ? 'Your company verification status is now ${status.firestoreValue}.'
          : note.trim(),
      'type': 'company',
      'isRead': false,
      'actionRoute': '/employer/company',
      'createdAt': now,
    });
    _addAudit(
      batch,
      action: status == EmployerVerificationStatus.approved
          ? 'Employer approved'
          : 'Employer review updated',
      subject: company.companyName,
      detail: note,
    );
    await batch.commit();
  }

  @override
  Future<void> reviewJob({
    required EmployerJobModel job,
    required EmployerJobStatus status,
    required String note,
  }) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    batch.update(_firestore.collection('jobs').doc(job.id), {
      'status': status.firestoreValue,
      'isActive': status == EmployerJobStatus.published ||
          status == EmployerJobStatus.pending,
      'publishedAt':
          status == EmployerJobStatus.published ? now : job.publishedAt,
      'rejectionNote': note.trim().isEmpty ? null : note.trim(),
      'updatedAt': now,
    });
    batch.set(_firestore.collection('notifications').doc(), {
      'recipientUid': job.employerUid,
      'title': status == EmployerJobStatus.published
          ? 'Job approved'
          : 'Job review update',
      'message': note.trim().isEmpty
          ? '“${job.title}” is now ${status.label.toLowerCase()}.'
          : note.trim(),
      'type': 'job',
      'isRead': false,
      'actionRoute': '/employer/jobs',
      'createdAt': now,
    });
    _addAudit(
      batch,
      action: status == EmployerJobStatus.published
          ? 'Job approved'
          : 'Job review updated',
      subject: job.title,
      detail: note,
    );
    await batch.commit();
  }

  @override
  Future<void> setUserActive(
      {required AppUserModel user, required bool isActive}) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('users').doc(user.uid), {
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _addAudit(
      batch,
      action: isActive ? 'User activated' : 'User suspended',
      subject: user.name,
      detail: user.email,
    );
    await batch.commit();
  }

  @override
  Future<void> setCompanyActive({
    required AdminCompanyReviewModel company,
    required bool isActive,
  }) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('companies').doc(company.companyId), {
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_firestore.collection('users').doc(company.ownerUid), {
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _addAudit(
      batch,
      action: isActive ? 'Company activated' : 'Company suspended',
      subject: company.companyName,
      detail: company.email,
    );
    await batch.commit();
  }

  @override
  Future<void> updateReport({
    required PlatformReportModel report,
    required PlatformReportStatus status,
    required String note,
  }) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('reports').doc(report.id), {
      'status': status.firestoreValue,
      'resolutionNote': note.trim(),
      'resolvedAt': status.isClosed ? FieldValue.serverTimestamp() : null,
      'reviewedBy': _adminUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _addAudit(
      batch,
      action: 'Report ${status.label.toLowerCase()}',
      subject: report.targetLabel,
      detail: note,
    );
    await batch.commit();
  }

  @override
  Future<JobCategoryAdminModel> saveCategory(
      JobCategoryAdminModel category) async {
    final collection = _firestore.collection('categories');
    final ref = category.id.trim().isEmpty
        ? collection.doc()
        : collection.doc(category.id);
    final resolved =
        category.id.trim().isEmpty ? category.copyWith(id: ref.id) : category;
    final batch = _firestore.batch();
    batch.set(ref, resolved.toFirestore(),
        SetOptions(merge: category.id.trim().isNotEmpty));
    _addAudit(batch,
        action: 'Category saved',
        subject: resolved.name,
        detail: resolved.description);
    await batch.commit();
    return resolved;
  }

  @override
  Future<SalaryInsightAdminModel> saveSalaryInsight(
      SalaryInsightAdminModel insight) async {
    final collection = _firestore.collection('salaryInsights');
    final ref = insight.id.trim().isEmpty
        ? collection.doc()
        : collection.doc(insight.id);
    final resolved =
        insight.id.trim().isEmpty ? insight.copyWith(id: ref.id) : insight;
    final batch = _firestore.batch();
    batch.set(ref, resolved.toFirestore(),
        SetOptions(merge: insight.id.trim().isNotEmpty));
    _addAudit(batch,
        action: 'Salary insight saved',
        subject: resolved.roleName,
        detail: resolved.location);
    await batch.commit();
    return resolved;
  }

  @override
  Future<void> saveSettings(PlatformSettingsModel settings) async {
    final batch = _firestore.batch();
    batch.set(
      _firestore.collection('platformSettings').doc('general'),
      settings.toFirestore(),
      SetOptions(merge: true),
    );
    _addAudit(
      batch,
      action: 'Platform settings updated',
      subject: settings.platformName,
      detail: settings.supportEmail,
    );
    await batch.commit();
  }

  String get _adminUid => _auth.currentUser?.uid ?? 'unknown-admin';

  void _addAudit(
    WriteBatch batch, {
    required String action,
    required String subject,
    required String detail,
  }) {
    batch.set(_firestore.collection('auditLogs').doc(), {
      'adminUid': _adminUid,
      'action': action,
      'subject': subject,
      'detail': detail.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
