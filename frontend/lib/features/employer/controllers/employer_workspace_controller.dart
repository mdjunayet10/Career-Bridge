import '../../demo/data/demo_application_store.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/enums/application_status.dart';
import '../../../core/enums/employer_job_status.dart';
import '../../applications/data/models/application_model.dart';
import '../../companies/controllers/company_logo_registry.dart';
import '../../file_storage/controllers/file_storage_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../notifications/data/models/notification_model.dart';
import '../../public_portal/controllers/public_portal_controller.dart';
import '../data/models/company_profile_model.dart';
import '../data/models/employer_job_model.dart';
import '../data/repositories/demo_employer_workspace_repository.dart';
import '../data/repositories/employer_workspace_repository.dart';
import '../data/repositories/firebase_employer_workspace_repository.dart';

class EmployerWorkspaceController extends ChangeNotifier {
  EmployerWorkspaceController._() {
    AuthController.instance.addListener(_authChanged);
  }
  StreamSubscription<EmployerWorkspaceSnapshot>? _subscription;
  int _generation = 0;
  String? _sessionKey;
  void _authChanged() {
    final auth = AuthController.instance;
    final key = '${auth.usesFirebase}:${auth.currentUser?.uid}';
    if (_sessionKey == null || key == _sessionKey) return;
    _sessionKey = null;
    _generation++;
    _subscription?.cancel();
    _subscription = null;
    _loadedUid = null;
    _company = null;
    _jobs = [];
    _applications = [];
    _notifications = [];
    notifyListeners();
  }

  static final EmployerWorkspaceController instance =
      EmployerWorkspaceController._();

  DemoEmployerWorkspaceRepository _demoRepository =
      DemoEmployerWorkspaceRepository();
  EmployerWorkspaceRepository? _repository;
  String? _loadedUid;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  CompanyProfileModel? _company;
  List<EmployerJobModel> _jobs = <EmployerJobModel>[];
  List<ApplicationModel> _applications = <ApplicationModel>[];
  List<NotificationModel> _notifications = <NotificationModel>[];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isLoaded => _loadedUid != null && _company != null;
  String? get errorMessage => _errorMessage;
  CompanyProfileModel? get company => _company;
  List<EmployerJobModel> get jobs => List.unmodifiable(_jobs);
  List<ApplicationModel> get applications => List.unmodifiable(_applications);
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get liveJobCount =>
      _jobs.where((job) => job.status == EmployerJobStatus.published).length;
  int get pendingJobCount =>
      _jobs.where((job) => job.status == EmployerJobStatus.pending).length;
  int get unreadNotificationCount =>
      _notifications.where((item) => !item.isRead).length;
  int get activeApplicantCount =>
      _applications.where((item) => !item.status.isTerminal).length;
  int get shortlistedCount => _applications
      .where((item) => item.status == ApplicationStatus.shortlisted)
      .length;
  int get interviewCount => _applications
      .where((item) => item.status == ApplicationStatus.interview)
      .length;
  int get hiredCount => _applications
      .where((item) => item.status == ApplicationStatus.hired)
      .length;

  EmployerJobModel? jobById(String id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  ApplicationModel? applicationById(String id) {
    for (final application in _applications) {
      if (application.id == id) return application;
    }
    return null;
  }

  String jobTitleFor(String jobId) => jobById(jobId)?.title ?? 'Job opening';

  int applicantCountFor(String jobId) =>
      _applications.where((item) => item.jobId == jobId).length;

  Future<void> ensureLoaded({bool force = false}) async {
    final user = AuthController.instance.currentUser;
    if (user == null) return;
    if (!force && _loadedUid == user.uid && isLoaded) return;

    _sessionKey = '${AuthController.instance.usesFirebase}:${user.uid}';
    final generation = ++_generation;
    await _subscription?.cancel();
    _subscription = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _repository = AuthController.instance.usesFirebase
          ? FirebaseEmployerWorkspaceRepository()
          : _demoRepository;
      final snapshot = await _repository!.load(
        uid: user.uid,
        companyName: user.companyName ?? '',
        contactName: user.name,
        email: user.email,
      );
      if (generation != _generation) return;
      _loadedUid = user.uid;
      _applySnapshot(snapshot);
      final repository = _repository!;
      final Stream<EmployerWorkspaceSnapshot> updates =
          repository is FirebaseEmployerWorkspaceRepository
              ? repository.watch(uid: user.uid)
              : DemoApplicationStore.instance.changes.asyncMap((_) =>
                  repository.load(
                      uid: user.uid,
                      companyName: user.companyName ?? '',
                      contactName: user.name,
                      email: user.email));
      _subscription = updates.listen((snapshot) {
        if (generation != _generation ||
            _loadedUid != AuthController.instance.currentUser?.uid ||
            _sessionKey !=
                '${AuthController.instance.usesFirebase}:${user.uid}') {
          return;
        }
        _applySnapshot(snapshot);
        notifyListeners();
      }, onError: (Object error) {
        if (generation != _generation) return;
        _errorMessage = _messageFor(error);
        notifyListeners();
      });
    } catch (error) {
      if (generation == _generation) _errorMessage = _messageFor(error);
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _applySnapshot(EmployerWorkspaceSnapshot snapshot) {
    _company = snapshot.company;
    CompanyLogoRegistry.instance.setLogo(
      snapshot.company.id,
      snapshot.company.logoFileId,
    );
    _jobs = List<EmployerJobModel>.from(snapshot.jobs)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _applications = List<ApplicationModel>.from(snapshot.applications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _notifications = List<NotificationModel>.from(snapshot.notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveCompany(CompanyProfileModel company) async {
    await _runSavingAction(() async {
      final updated = company.copyWith(updatedAt: DateTime.now());
      await _repository!.saveCompany(updated);
      _company = updated;
      CompanyLogoRegistry.instance.setLogo(updated.id, updated.logoFileId);
      await _refreshPublicPortalIfFirebase();
    });
  }

  Future<bool> uploadCompanyLogo() async {
    final uid = _loadedUid;
    final current = _company;
    if (uid == null || current == null || _repository == null) {
      throw StateError('Employer workspace is not loaded.');
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    String? uploadedFileId;
    try {
      final uploaded =
          await FileStorageController.instance.pickCompressAndUploadImage(
        ownerUid: uid,
        purpose: 'companyLogo',
      );
      if (uploaded == null) return false;
      uploadedFileId = uploaded.id;
      final previousFileId = current.logoFileId;
      final updated = current.copyWith(
        logoFileId: uploaded.id,
        updatedAt: DateTime.now(),
      );
      await _repository!.saveCompany(updated);
      _company = updated;
      CompanyLogoRegistry.instance.setLogo(updated.id, updated.logoFileId);
      await _refreshPublicPortalIfFirebase();
      if (previousFileId.isNotEmpty && previousFileId != uploaded.id) {
        try {
          await FileStorageController.instance.delete(previousFileId);
        } catch (_) {}
      }
      return true;
    } catch (error) {
      if (uploadedFileId != null) {
        try {
          await FileStorageController.instance.delete(uploadedFileId);
        } catch (_) {}
      }
      _errorMessage = _messageFor(error);
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<EmployerJobModel> saveJob(EmployerJobModel job,
      {required bool submitForReview}) async {
    if (_repository == null) {
      throw StateError('Employer workspace is not loaded.');
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final desiredStatus =
          submitForReview ? EmployerJobStatus.pending : EmployerJobStatus.draft;
      final prepared = job.copyWith(
        status: desiredStatus,
        isActive: true,
        updatedAt: now,
      );
      final saved = await _repository!.saveJob(prepared);
      final index = _jobs.indexWhere((item) => item.id == saved.id);
      if (index >= 0) {
        _jobs[index] = saved;
      } else {
        _jobs.insert(0, saved);
      }
      _jobs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      await _refreshPublicPortalIfFirebase();
      return saved;
    } catch (error) {
      _errorMessage = _messageFor(error);
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> closeJob(EmployerJobModel job) async {
    await _runSavingAction(() async {
      final updated = job.copyWith(
        status: EmployerJobStatus.closed,
        isActive: false,
        updatedAt: DateTime.now(),
      );
      final saved = await _repository!.saveJob(updated);
      final index = _jobs.indexWhere((item) => item.id == saved.id);
      if (index >= 0) _jobs[index] = saved;
      await _refreshPublicPortalIfFirebase();
    });
  }

  Future<void> updateApplication({
    required ApplicationModel application,
    required ApplicationStatus status,
    String? employerNote,
    DateTime? interviewAt,
  }) async {
    if (_isSaving) throw StateError('Another change is still being saved.');
    final current = applicationById(application.id) ?? application;
    if (current.status == ApplicationStatus.withdrawn) {
      throw StateError('The candidate withdrew this application.');
    }
    await _runSavingAction(() async {
      await _repository!.updateApplication(
        application: application,
        status: status,
        employerNote: employerNote,
        interviewAt: interviewAt,
      );
      final index =
          _applications.indexWhere((item) => item.id == application.id);
      if (index >= 0) {
        _applications[index] = application.copyWith(
          status: status,
          employerNote: employerNote,
          interviewAt: interviewAt,
          updatedAt: DateTime.now(),
          clearEmployerNote: employerNote == null,
          clearInterviewAt: status != ApplicationStatus.interview,
        );
      }
    });
  }

  Future<void> markNotificationRead(NotificationModel notification) async {
    if (notification.isRead || _repository == null) return;
    await _repository!.markNotificationRead(notification);
    final index =
        _notifications.indexWhere((item) => item.id == notification.id);
    if (index >= 0) _notifications[index] = notification.copyWith(isRead: true);
    notifyListeners();
  }

  Future<void> markAllNotificationsRead() async {
    for (final item in _notifications
        .where((notification) => !notification.isRead)
        .toList()) {
      await markNotificationRead(item);
    }
  }

  Future<void> refresh() => ensureLoaded(force: true);

  Future<void> _runSavingAction(Future<void> Function() action) async {
    if (_repository == null) {
      throw StateError('Employer workspace is not loaded.');
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _errorMessage = _messageFor(error);
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _refreshPublicPortalIfFirebase() async {
    if (!AuthController.instance.usesFirebase) return;
    try {
      await PublicPortalController.instance.refresh();
    } catch (_) {
      // The Employer write already succeeded. Public content can retry later.
    }
  }

  String _messageFor(Object error) {
    final text = error.toString();
    return text.startsWith('Bad state: ') ? text.substring(11) : text;
  }

  @visibleForTesting
  void resetForTesting() {
    _generation++;
    _subscription?.cancel();
    _subscription = null;
    _sessionKey = null;
    _demoRepository = DemoEmployerWorkspaceRepository();
    _repository = null;
    _loadedUid = null;
    _isLoading = false;
    _isSaving = false;
    _errorMessage = null;
    _company = null;
    _jobs = <EmployerJobModel>[];
    _applications = <ApplicationModel>[];
    _notifications = <NotificationModel>[];
    notifyListeners();
  }
}
