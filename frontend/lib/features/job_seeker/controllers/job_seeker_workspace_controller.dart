import '../../demo/data/demo_application_store.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/enums/application_status.dart';
import '../../applications/data/models/application_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cv_builder/data/models/cv_profile_model.dart';
import '../../cv_builder/services/profile_cv_sync_service.dart';
import '../../file_storage/controllers/file_storage_controller.dart';
import '../../notifications/data/models/notification_model.dart';
import '../../jobs/data/models/job_model.dart';
import '../../jobs/services/job_recommendation_service.dart';
import '../../public_portal/controllers/public_portal_controller.dart';
import '../data/models/job_seeker_profile_model.dart';
import '../data/repositories/demo_job_seeker_workspace_repository.dart';
import '../data/repositories/firebase_job_seeker_workspace_repository.dart';
import '../data/repositories/job_seeker_workspace_repository.dart';

class JobSeekerWorkspaceController extends ChangeNotifier {
  JobSeekerWorkspaceController._() {
    AuthController.instance.addListener(_authChanged);
    PublicPortalController.instance.addListener(_catalogueChanged);
  }
  StreamSubscription<JobSeekerWorkspaceSnapshot>? _subscription;
  int _generation = 0;
  int _snapshotRevision = 0;
  String? _sessionKey;
  void _catalogueChanged() {
    if (isLoaded) notifyListeners();
  }

  void _authChanged() {
    final auth = AuthController.instance;
    final key = '${auth.usesFirebase}:${auth.currentUser?.uid}';
    if (_sessionKey == null || key == _sessionKey) return;
    _sessionKey = null;
    _generation++;
    _subscription?.cancel();
    _subscription = null;
    _loadedUid = null;
    _profile = null;
    _cvProfile = null;
    _savedJobIds = {};
    _applications = [];
    _notifications = [];
    notifyListeners();
  }

  static final JobSeekerWorkspaceController instance =
      JobSeekerWorkspaceController._();

  DemoJobSeekerWorkspaceRepository _demoRepository =
      DemoJobSeekerWorkspaceRepository();
  JobSeekerWorkspaceRepository? _repository;

  String? _loadedUid;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  JobSeekerProfileModel? _profile;
  CvProfileModel? _cvProfile;
  Set<String> _savedJobIds = <String>{};
  List<ApplicationModel> _applications = <ApplicationModel>[];
  List<NotificationModel> _notifications = <NotificationModel>[];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isLoaded =>
      _loadedUid != null && _profile != null && _cvProfile != null;
  String? get errorMessage => _errorMessage;
  JobSeekerProfileModel? get profile => _profile;
  CvProfileModel? get cvProfile => _cvProfile;
  Set<String> get savedJobIds => Set.unmodifiable(_savedJobIds);
  List<ApplicationModel> get applications => List.unmodifiable(_applications);
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadNotificationCount =>
      _notifications.where((item) => !item.isRead).length;

  int get activeApplicationCount =>
      _applications.where((item) => !item.status.isTerminal).length;
  int get shortlistedCount => _applications
      .where((item) => item.status == ApplicationStatus.shortlisted)
      .length;
  int get interviewCount => _applications
      .where((item) => item.status == ApplicationStatus.interview)
      .length;

  List<JobRecommendation> get jobRecommendations =>
      JobRecommendationService.rankJobs(
        jobs: PublicPortalController.instance.jobs,
        profile: _profile,
        cvProfile: _cvProfile,
      );

  bool isSaved(String jobId) => _savedJobIds.contains(jobId);

  ApplicationModel? applicationForJob(String jobId) {
    for (final application in _applications) {
      if (application.jobId == jobId &&
          application.status != ApplicationStatus.withdrawn) {
        return application;
      }
    }
    return null;
  }

  ApplicationModel? applicationById(String id) {
    for (final application in _applications) {
      if (application.id == id) return application;
    }
    return null;
  }

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
          ? FirebaseJobSeekerWorkspaceRepository()
          : _demoRepository;
      final snapshot = await _repository!.load(
        uid: user.uid,
        name: user.name,
        email: user.email,
      );
      if (generation != _generation) return;
      _loadedUid = user.uid;
      _profile = snapshot.profile;
      var loadedCv = snapshot.cvProfile;
      final profileHasCareerData = snapshot.profile.hasCvDetails ||
          snapshot.profile.experience.isNotEmpty ||
          snapshot.profile.about.trim().isNotEmpty ||
          snapshot.profile.skills.isNotEmpty ||
          snapshot.profile.educationSummary.trim().isNotEmpty;
      var shouldPersistCv = false;
      if (loadedCv.sectionCount == 0 && profileHasCareerData) {
        loadedCv = ProfileCvSyncService.sync(
          profile: snapshot.profile,
          currentCv: loadedCv,
        );
        shouldPersistCv = true;
      }
      // A photo chosen in CV Builder takes precedence over the profile photo.
      final cvWithPhoto = loadedCv.photoDataUrl.isNotEmpty
          ? loadedCv
          : await _withProfilePhoto(snapshot.profile, loadedCv);
      if (generation != _generation) return;
      shouldPersistCv |= cvWithPhoto.photoDataUrl != loadedCv.photoDataUrl;
      loadedCv = cvWithPhoto;
      if (shouldPersistCv) {
        try {
          await _repository!.saveCvProfile(loadedCv);
        } catch (_) {
          // The in-memory auto CV remains usable even if migration persistence
          // is temporarily unavailable.
        }
      }
      _cvProfile = loadedCv;
      _savedJobIds = Set<String>.from(snapshot.savedJobIds);
      _applications = List<ApplicationModel>.from(snapshot.applications);
      _notifications = List<NotificationModel>.from(snapshot.notifications);
      try {
        await _syncRecommendationNotifications(
          profile: snapshot.profile,
          cvProfile: loadedCv,
        );
      } catch (_) {
        // Recommendation syncing should never block the workspace from loading.
      }
      if (generation != _generation) return;
      final repository = _repository!;
      final Stream<JobSeekerWorkspaceSnapshot> updates = repository
              is FirebaseJobSeekerWorkspaceRepository
          ? repository.watch(uid: user.uid, name: user.name, email: user.email)
          : DemoApplicationStore.instance.changes.asyncMap((_) => repository
              .load(uid: user.uid, name: user.name, email: user.email));
      _subscription = updates.listen((snapshot) async {
        final revision = ++_snapshotRevision;
        try {
          final cv = snapshot.cvProfile.photoDataUrl.isNotEmpty
              ? snapshot.cvProfile
              : await _withProfilePhoto(snapshot.profile, snapshot.cvProfile);
          if (generation != _generation ||
              revision != _snapshotRevision ||
              _loadedUid != AuthController.instance.currentUser?.uid ||
              _sessionKey !=
                  '${AuthController.instance.usesFirebase}:${user.uid}') {
            return;
          }
          _profile = snapshot.profile;
          _cvProfile = cv;
          _savedJobIds = Set.from(snapshot.savedJobIds);
          _applications = List.from(snapshot.applications);
          _notifications = List.from(snapshot.notifications);
          notifyListeners();
        } catch (error) {
          if (generation == _generation) {
            _errorMessage = _messageFor(error);
            notifyListeners();
          }
        }
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

  Future<void> saveProfile(JobSeekerProfileModel profile) async {
    final currentCv = _cvProfile;
    if (currentCv == null) {
      throw StateError('Job Seeker workspace is not loaded.');
    }
    final previousProfile = _profile;
    var syncedCv = ProfileCvSyncService.sync(
      profile: profile,
      currentCv: currentCv,
      previousProfile: previousProfile,
    );

    await _runSavingAction(() async {
      if (profile.profileImageFileId.isEmpty &&
          (previousProfile?.profileImageFileId.isNotEmpty ?? false)) {
        syncedCv = syncedCv.copyWith(photoDataUrl: '');
      } else if (syncedCv.photoDataUrl.isEmpty ||
          profile.profileImageFileId != previousProfile?.profileImageFileId) {
        syncedCv = await _withProfilePhoto(profile, syncedCv);
      }
      final savedProfile = profile.hasCvDetails
          ? _profileWithCvDetails(profile, syncedCv)
          : profile;
      await _repository!.saveProfileAndCv(
        profile: savedProfile,
        cvProfile: syncedCv,
      );
      _profile = savedProfile;
      _cvProfile = syncedCv;
      try {
        await _createCvSyncNotification(profile: profile);
        await _syncRecommendationNotifications(
          profile: profile,
          cvProfile: syncedCv,
        );
      } catch (_) {
        // Profile and CV saving should still succeed if notifications
        // cannot be created because of a transient backend issue.
      }
    });
  }

  Future<bool> uploadProfileImage() async {
    final uid = _loadedUid;
    final current = _profile;
    if (uid == null || current == null || _repository == null) {
      throw StateError('Job Seeker workspace is not loaded.');
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    String? uploadedFileId;
    var profileSaved = false;
    try {
      final uploaded =
          await FileStorageController.instance.pickCompressAndUploadImage(
        ownerUid: uid,
        purpose: 'profileImage',
      );
      if (uploaded == null) return false;
      uploadedFileId = uploaded.id;
      final previousFileId = current.profileImageFileId;
      final updated = current.copyWith(
        profileImageFileId: uploaded.id,
        updatedAt: DateTime.now(),
      );
      final currentCv = _cvProfile;
      final updatedCv = currentCv == null
          ? null
          : await _withProfilePhoto(updated, currentCv);
      if (updatedCv == null) {
        await _repository!.saveProfile(updated);
      } else {
        await _repository!.saveProfileAndCv(
          profile: updated,
          cvProfile: updatedCv,
        );
      }
      profileSaved = true;
      _profile = updated;
      if (updatedCv != null) {
        _cvProfile = updatedCv;
      }
      if (previousFileId.isNotEmpty && previousFileId != uploaded.id) {
        try {
          await FileStorageController.instance.delete(previousFileId);
        } catch (_) {}
      }
      return true;
    } catch (error) {
      if (uploadedFileId != null && !profileSaved) {
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

  Future<void> toggleSavedJob(String jobId) async {
    final uid = _loadedUid;
    if (uid == null || _repository == null) return;
    final shouldSave = !_savedJobIds.contains(jobId);
    final previous = Set<String>.from(_savedJobIds);
    shouldSave ? _savedJobIds.add(jobId) : _savedJobIds.remove(jobId);
    notifyListeners();
    try {
      await _repository!.setSavedJob(uid: uid, jobId: jobId, saved: shouldSave);
    } catch (error) {
      _savedJobIds = previous;
      _errorMessage = _messageFor(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<ApplicationModel> submitApplication({
    required JobModel job,
    required String coverLetter,
  }) async {
    final uid = _loadedUid;
    if (uid == null || _repository == null) {
      throw StateError('Job Seeker workspace is not loaded.');
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final application = await _repository!.submitApplication(
        uid: uid,
        job: job,
        coverLetter: coverLetter,
        cvProfile: _cvProfile,
        applicantProfile: _profile!,
      );
      _applications.insert(0, application);
      return application;
    } catch (error) {
      _errorMessage = _messageFor(error);
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> withdrawApplication(ApplicationModel application) async {
    await _runSavingAction(() async {
      await _repository!.withdrawApplication(application);
      final index =
          _applications.indexWhere((item) => item.id == application.id);
      if (index >= 0) {
        _applications[index] = application.copyWith(
          status: ApplicationStatus.withdrawn,
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  Future<void> markNotificationRead(NotificationModel notification) async {
    if (notification.isRead) return;
    await _repository!.markNotificationRead(notification);
    final index =
        _notifications.indexWhere((item) => item.id == notification.id);
    if (index >= 0) _notifications[index] = notification.copyWith(isRead: true);
    notifyListeners();
  }

  Future<void> markAllNotificationsRead() async {
    for (final notification
        in _notifications.where((item) => !item.isRead).toList()) {
      await markNotificationRead(notification);
    }
  }

  /// Layout preferences never overwrite the Profile or its source details.
  Future<void> saveCvPresentation({
    required List<String> sectionOrder,
    required List<String> hiddenSections,
    required bool showPhoto,
    String? templateId,
  }) async {
    if (_cvProfile == null || _repository == null) {
      throw StateError('Job Seeker workspace is not loaded.');
    }
    await _runSavingAction(() async {
      final updated = _cvProfile!.copyWith(
        sectionOrder: List.of(sectionOrder),
        hiddenSections: List.of(hiddenSections),
        showPhoto: showPhoto,
        templateId: templateId,
        updatedAt: DateTime.now(),
      );
      await _repository!.saveCvProfile(updated);
      _cvProfile = updated;
    });
  }

  Future<void> saveCvProfile(CvProfileModel cvProfile,
      {bool syncSummaryToProfile = false}) async {
    final normalized = ProfileCvSyncService.normalizeDetails(cvProfile);
    final current = _profile;
    final mirroredProfile = current == null
        ? null
        : _profileWithCvDetails(current, normalized).copyWith(
            fullName: normalized.fullName,
            about: syncSummaryToProfile
                ? normalized.professionalSummary
                : current.about,
            email: normalized.email,
            phone: normalized.phone,
            location: normalized.location,
            skills: normalized.skills,
            portfolioUrl: normalized.portfolioUrl,
            linkedInUrl: normalized.linkedInUrl,
            updatedAt: normalized.updatedAt,
          );
    await _runSavingAction(() async {
      if (mirroredProfile == null) {
        await _repository!.saveCvProfile(normalized);
      } else {
        await _repository!.saveProfileAndCv(
          profile: mirroredProfile,
          cvProfile: normalized,
        );
      }
      _cvProfile = normalized;
      if (mirroredProfile != null) _profile = mirroredProfile;
    });
  }

  JobSeekerProfileModel _profileWithCvDetails(
    JobSeekerProfileModel profile,
    CvProfileModel cv,
  ) =>
      profile.copyWith(
        hasCvDetails: true,
        education: cv.education,
        educationSummary: cv.education
            .map((item) => [
                  item.degree,
                  item.institution,
                  item.period,
                ].where((value) => value.trim().isNotEmpty).join(', '))
            .join('; '),
        technicalLanguages: cv.technicalLanguages,
        frameworks: cv.frameworks,
        toolsAndPlatforms: cv.toolsAndPlatforms,
        projects: cv.projects,
        experience: cv.experience,
        hasCvExperience: true,
        achievements: cv.achievements,
        references: cv.references,
      );

  Future<CvProfileModel> _withProfilePhoto(
    JobSeekerProfileModel profile,
    CvProfileModel cv,
  ) async {
    if (profile.profileImageFileId.isEmpty) return cv;
    try {
      final bytes = await FileStorageController.instance.download(
        profile.profileImageFileId,
      );
      return cv.copyWith(
        photoDataUrl: ProfileCvSyncService.photoThumbnailDataUrl(bytes),
      );
    } catch (_) {
      // Keep a saved CV usable when its source photo is temporarily unavailable.
      return cv;
    }
  }

  Future<void> refresh() => ensureLoaded(force: true);

  Future<void> _createCvSyncNotification({
    required JobSeekerProfileModel profile,
  }) async {
    final repository = _repository;
    if (repository == null) return;
    final id = 'profile-cv-sync-${profile.uid}';
    if (_notifications.any((item) => item.id == id)) return;

    final notification = NotificationModel(
      id: id,
      recipientUid: profile.uid,
      title: 'Your CV was generated automatically',
      message:
          'Career Bridge synced your profile into your CV. You can review or customize it anytime.',
      type: 'profile',
      isRead: false,
      actionRoute: AppRoutes.jobSeekerCvBuilder,
      createdAt: DateTime.now(),
    );
    await repository.createNotification(notification);
    _notifications.insert(0, notification);
  }

  Future<void> _syncRecommendationNotifications({
    required JobSeekerProfileModel profile,
    required CvProfileModel cvProfile,
  }) async {
    final repository = _repository;
    if (repository == null) return;

    final recommendations = JobRecommendationService.rankJobs(
      jobs: PublicPortalController.instance.jobs,
      profile: profile,
      cvProfile: cvProfile,
    );

    var created = 0;
    for (final recommendation in recommendations) {
      if (recommendation.score < 25 || created >= 3) break;
      final id = 'recommendation-${profile.uid}-${recommendation.job.id}';
      if (_notifications.any((item) => item.id == id)) continue;

      final notification = NotificationModel(
        id: id,
        recipientUid: profile.uid,
        title: 'New job match found',
        message:
            '${recommendation.job.title} at ${recommendation.job.companyName} may be a good fit for your profile.',
        type: 'recommendation',
        isRead: false,
        actionRoute: AppRoutes.jobDetails(recommendation.job.id),
        createdAt: DateTime.now(),
      );
      await repository.createNotification(notification);
      _notifications.insert(0, notification);
      created++;
    }
  }

  Future<void> _runSavingAction(Future<void> Function() action) async {
    if (_repository == null) {
      throw StateError('Job Seeker workspace is not loaded.');
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
    _demoRepository = DemoJobSeekerWorkspaceRepository();
    _repository = null;
    _loadedUid = null;
    _isLoading = false;
    _isSaving = false;
    _errorMessage = null;
    _profile = null;
    _cvProfile = null;
    _savedJobIds = <String>{};
    _applications = <ApplicationModel>[];
    _notifications = <NotificationModel>[];
    notifyListeners();
  }
}
