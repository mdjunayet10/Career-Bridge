import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/enums/employer_job_status.dart';
import '../../../core/enums/employer_verification_status.dart';
import '../../../core/enums/user_role.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/data/models/app_user_model.dart';
import '../../employer/data/models/employer_job_model.dart';
import '../../public_portal/controllers/public_portal_controller.dart';
import '../data/models/admin_activity_model.dart';
import '../data/models/admin_company_review_model.dart';
import '../data/models/job_category_admin_model.dart';
import '../data/models/platform_report_model.dart';
import '../data/models/platform_settings_model.dart';
import '../data/models/salary_insight_admin_model.dart';
import '../data/repositories/admin_workspace_repository.dart';
import '../data/repositories/demo_admin_workspace_repository.dart';
import '../data/repositories/firebase_admin_workspace_repository.dart';

class AdminWorkspaceController extends ChangeNotifier {
  AdminWorkspaceController._() {
    AuthController.instance.addListener(_authChanged);
  }
  String? _sessionKey;
  void _authChanged() {
    final auth = AuthController.instance;
    final key = '${auth.usesFirebase}:${auth.currentUser?.uid}';
    if (_sessionKey == null || key == _sessionKey) return;
    _loadGeneration++;
    _subscription?.cancel();
    _subscription = null;
    _loadedUid = null;
    _settings = null;
    _sessionKey = null;
    _users = [];
    _companies = [];
    _jobs = [];
    _reports = [];
    _categories = [];
    _salaryInsights = [];
    _activities = [];
    _demoPreview = false;
    notifyListeners();
  }

  static final AdminWorkspaceController instance = AdminWorkspaceController._();

  DemoAdminWorkspaceRepository _demoRepository = DemoAdminWorkspaceRepository();
  AdminWorkspaceRepository? _repository;
  String? _loadedUid;
  StreamSubscription<AdminWorkspaceSnapshot>? _subscription;
  int _loadGeneration = 0;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _demoPreview = false;
  String? _errorMessage;

  List<AppUserModel> _users = <AppUserModel>[];
  List<AdminCompanyReviewModel> _companies = <AdminCompanyReviewModel>[];
  List<EmployerJobModel> _jobs = <EmployerJobModel>[];
  List<PlatformReportModel> _reports = <PlatformReportModel>[];
  List<JobCategoryAdminModel> _categories = <JobCategoryAdminModel>[];
  List<SalaryInsightAdminModel> _salaryInsights = <SalaryInsightAdminModel>[];
  List<AdminActivityModel> _activities = <AdminActivityModel>[];
  PlatformSettingsModel? _settings;

  bool get isLoading => _isLoading;
  bool get isReadOnlyDemoPreview =>
      _demoPreview && AuthController.instance.usesFirebase;
  bool get isSaving => _isSaving || isReadOnlyDemoPreview;
  bool get isDemoPreview =>
      _demoPreview || !AuthController.instance.usesFirebase;
  bool get isLoaded => _loadedUid != null && _settings != null;
  String? get errorMessage => _errorMessage;
  List<AppUserModel> get users => List.unmodifiable(_users);
  List<AdminCompanyReviewModel> get companies => List.unmodifiable(_companies);
  List<EmployerJobModel> get jobs => List.unmodifiable(_jobs);
  List<PlatformReportModel> get reports => List.unmodifiable(_reports);
  List<JobCategoryAdminModel> get categories => List.unmodifiable(_categories);
  List<SalaryInsightAdminModel> get salaryInsights =>
      List.unmodifiable(_salaryInsights);
  List<AdminActivityModel> get activities => List.unmodifiable(_activities);
  PlatformSettingsModel? get settings => _settings;

  int get totalUsers => _users.length;
  int get activeUsers => _users.where((user) => user.isActive).length;
  int get jobSeekerCount =>
      _users.where((user) => user.role == UserRole.jobSeeker).length;
  int get employerCount =>
      _users.where((user) => user.role == UserRole.employer).length;
  int get pendingEmployerCount => _companies
      .where((company) => company.status == EmployerVerificationStatus.pending)
      .length;
  int get approvedCompanyCount => _companies
      .where(
        (company) =>
            company.status == EmployerVerificationStatus.approved &&
            company.isActive,
      )
      .length;
  int get pendingJobCount =>
      _jobs.where((job) => job.status == EmployerJobStatus.pending).length;
  int get publishedJobCount =>
      _jobs.where((job) => job.status == EmployerJobStatus.published).length;
  int get openReportCount =>
      _reports.where((report) => !report.status.isClosed).length;
  int get activeCategoryCount =>
      _categories.where((category) => category.isActive).length;

  AdminCompanyReviewModel? companyById(String id) {
    for (final company in _companies) {
      if (company.companyId == id) return company;
    }
    return null;
  }

  String companyNameForJob(EmployerJobModel job) =>
      companyById(job.companyId)?.companyName ?? 'Career Bridge Employer';

  Future<void> ensureLoaded({bool force = false}) async {
    final user = AuthController.instance.currentUser;
    if (user == null || user.role != UserRole.admin) return;
    if (!force && _loadedUid == user.uid && isLoaded) return;

    _sessionKey = '${AuthController.instance.usesFirebase}:${user.uid}';
    final generation = ++_loadGeneration;
    await _subscription?.cancel();
    _subscription = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _repository = AuthController.instance.usesFirebase && !_demoPreview
          ? FirebaseAdminWorkspaceRepository()
          : _demoRepository;
      final snapshot = await _repository!.load();
      if (generation != _loadGeneration) return;
      _loadedUid = user.uid;
      _applySnapshot(snapshot);
      if (_repository case final FirebaseAdminWorkspaceRepository repository) {
        _subscription = repository.watch().listen((snapshot) {
          if (generation != _loadGeneration ||
              _demoPreview ||
              AuthController.instance.currentUser?.uid != user.uid ||
              !AuthController.instance.usesFirebase) {
            return;
          }
          _applySnapshot(snapshot);
          notifyListeners();
        }, onError: (Object error) {
          if (generation != _loadGeneration) return;
          _errorMessage = _messageFor(error);
          notifyListeners();
        });
      }
    } catch (error) {
      if (generation == _loadGeneration) _errorMessage = _messageFor(error);
    } finally {
      if (generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _applySnapshot(AdminWorkspaceSnapshot snapshot) {
    _users = List<AppUserModel>.from(snapshot.users)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _companies = List<AdminCompanyReviewModel>.from(snapshot.companies)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    _jobs = List<EmployerJobModel>.from(snapshot.jobs)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _reports = List<PlatformReportModel>.from(snapshot.reports)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _categories = List<JobCategoryAdminModel>.from(snapshot.categories)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _salaryInsights =
        List<SalaryInsightAdminModel>.from(snapshot.salaryInsights)
          ..sort((a, b) => a.roleName.compareTo(b.roleName));
    _settings = snapshot.settings;
    _activities = List<AdminActivityModel>.from(snapshot.activities)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> reviewEmployer({
    required AdminCompanyReviewModel company,
    required EmployerVerificationStatus status,
    required String note,
  }) async {
    await _runSavingAction(() async {
      await _repository!
          .reviewEmployer(company: company, status: status, note: note);
      final index =
          _companies.indexWhere((item) => item.companyId == company.companyId);
      if (index >= 0) {
        _companies[index] =
            company.copyWith(status: status, decisionNote: note);
      }
      final userIndex =
          _users.indexWhere((item) => item.uid == company.ownerUid);
      if (userIndex >= 0) {
        final user = _users[userIndex];
        _users[userIndex] = AppUserModel(
          uid: user.uid,
          name: user.name,
          email: user.email,
          role: user.role,
          isActive: user.isActive,
          createdAt: user.createdAt,
          companyName: user.companyName,
          verificationStatus: status,
        );
      }
      _addLocalActivity(
        status == EmployerVerificationStatus.approved
            ? 'Employer approved'
            : 'Employer review updated',
        company.companyName,
        note,
      );
      await _refreshPublicPortalIfFirebase();
    });
  }

  Future<void> reviewJob({
    required EmployerJobModel job,
    required EmployerJobStatus status,
    required String note,
  }) async {
    await _runSavingAction(() async {
      await _repository!.reviewJob(job: job, status: status, note: note);
      final index = _jobs.indexWhere((item) => item.id == job.id);
      if (index >= 0) {
        _jobs[index] = job.copyWith(
          status: status,
          isActive: status == EmployerJobStatus.published ||
              status == EmployerJobStatus.pending,
          updatedAt: DateTime.now(),
          publishedAt: status == EmployerJobStatus.published
              ? DateTime.now()
              : job.publishedAt,
          rejectionNote: note.trim().isEmpty ? job.rejectionNote : note.trim(),
        );
      }
      _addLocalActivity(
        status == EmployerJobStatus.published
            ? 'Job approved'
            : 'Job review updated',
        job.title,
        note,
      );
      await _refreshPublicPortalIfFirebase();
    });
  }

  Future<void> setUserActive(AppUserModel user, bool isActive) async {
    await _runSavingAction(() async {
      await _repository!.setUserActive(user: user, isActive: isActive);
      final index = _users.indexWhere((item) => item.uid == user.uid);
      if (index >= 0) {
        _users[index] = AppUserModel(
          uid: user.uid,
          name: user.name,
          email: user.email,
          role: user.role,
          isActive: isActive,
          createdAt: user.createdAt,
          companyName: user.companyName,
          verificationStatus: user.verificationStatus,
        );
      }
      _addLocalActivity(
        isActive ? 'User activated' : 'User suspended',
        user.name,
        user.email,
      );
    });
  }

  Future<void> setCompanyActive(
      AdminCompanyReviewModel company, bool isActive) async {
    await _runSavingAction(() async {
      await _repository!.setCompanyActive(company: company, isActive: isActive);
      final index =
          _companies.indexWhere((item) => item.companyId == company.companyId);
      if (index >= 0) _companies[index] = company.copyWith(isActive: isActive);
      _addLocalActivity(
        isActive ? 'Company activated' : 'Company suspended',
        company.companyName,
        company.email,
      );
      await _refreshPublicPortalIfFirebase();
    });
  }

  Future<void> updateReport({
    required PlatformReportModel report,
    required PlatformReportStatus status,
    required String note,
  }) async {
    await _runSavingAction(() async {
      await _repository!
          .updateReport(report: report, status: status, note: note);
      final index = _reports.indexWhere((item) => item.id == report.id);
      if (index >= 0) {
        _reports[index] = report.copyWith(
          status: status,
          resolutionNote: note,
          resolvedAt: status.isClosed ? DateTime.now() : report.resolvedAt,
        );
      }
      _addLocalActivity(
          'Report ${status.label.toLowerCase()}', report.targetLabel, note);
    });
  }

  Future<JobCategoryAdminModel> saveCategory(
      JobCategoryAdminModel category) async {
    if (_repository == null) throw StateError('Admin workspace is not loaded.');
    if (isReadOnlyDemoPreview) {
      throw StateError(
          'Demo preview is read-only. Switch to Live to make changes.');
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final prepared = category.copyWith(updatedAt: DateTime.now());
      final saved = await _repository!.saveCategory(prepared);
      final index = _categories.indexWhere((item) => item.id == saved.id);
      if (index >= 0) {
        _categories[index] = saved;
      } else {
        _categories.add(saved);
      }
      _categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _addLocalActivity('Category saved', saved.name, saved.description);
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

  Future<SalaryInsightAdminModel> saveSalaryInsight(
    SalaryInsightAdminModel insight,
  ) async {
    if (_repository == null) throw StateError('Admin workspace is not loaded.');
    if (isReadOnlyDemoPreview) {
      throw StateError(
          'Demo preview is read-only. Switch to Live to make changes.');
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final prepared = insight.copyWith(updatedAt: DateTime.now());
      final saved = await _repository!.saveSalaryInsight(prepared);
      final index = _salaryInsights.indexWhere((item) => item.id == saved.id);
      if (index >= 0) {
        _salaryInsights[index] = saved;
      } else {
        _salaryInsights.add(saved);
      }
      _salaryInsights.sort((a, b) => a.roleName.compareTo(b.roleName));
      _addLocalActivity('Salary insight saved', saved.roleName, saved.location);
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

  Future<void> saveSettings(PlatformSettingsModel settings) async {
    await _runSavingAction(() async {
      final prepared = settings.copyWith(updatedAt: DateTime.now());
      await _repository!.saveSettings(prepared);
      _settings = prepared;
      _addLocalActivity(
        'Platform settings updated',
        prepared.platformName,
        prepared.supportEmail,
      );
      await _refreshPublicPortalIfFirebase();
    });
  }

  Future<void> refresh() => ensureLoaded(force: true);

  /// Switches between real Firestore records and an isolated academic sample.
  /// Admin authentication remains real; the sample preview is read-only.
  Future<void> setDemoPreview(bool enabled) async {
    if (_demoPreview == enabled) return;
    _demoPreview = enabled;
    // Avoid briefly displaying live totals under the sample preview banner.
    _loadedUid = null;
    _settings = null;
    await ensureLoaded(force: true);
  }

  Future<void> _runSavingAction(Future<void> Function() action) async {
    if (_repository == null) throw StateError('Admin workspace is not loaded.');
    if (isReadOnlyDemoPreview) {
      throw StateError(
          'Demo preview is read-only. Switch to Live to make changes.');
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

  void _addLocalActivity(String action, String subject, String detail) {
    _activities.insert(
      0,
      AdminActivityModel(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        action: action,
        subject: subject,
        detail: detail,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _refreshPublicPortalIfFirebase() async {
    if (!AuthController.instance.usesFirebase || _demoPreview) return;
    try {
      await PublicPortalController.instance.refresh();
    } catch (_) {
      // The moderation write already succeeded. Public data will retry on the
      // next app start or manual refresh instead of rolling back that decision.
    }
  }

  String _messageFor(Object error) {
    final text = error.toString();
    return text.startsWith('Bad state: ') ? text.substring(11) : text;
  }

  @visibleForTesting
  void resetForTesting() {
    _loadGeneration++;
    _subscription?.cancel();
    _subscription = null;
    _sessionKey = null;
    _demoRepository = DemoAdminWorkspaceRepository();
    _demoPreview = false;
    _repository = null;
    _loadedUid = null;
    _isLoading = false;
    _isSaving = false;
    _errorMessage = null;
    _users = <AppUserModel>[];
    _companies = <AdminCompanyReviewModel>[];
    _jobs = <EmployerJobModel>[];
    _reports = <PlatformReportModel>[];
    _categories = <JobCategoryAdminModel>[];
    _salaryInsights = <SalaryInsightAdminModel>[];
    _activities = <AdminActivityModel>[];
    _settings = null;
    notifyListeners();
  }
}
