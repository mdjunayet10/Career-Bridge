import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../app/config/app_environment.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../companies/controllers/company_logo_registry.dart';
import '../../companies/data/models/company_model.dart';
import '../../jobs/data/models/job_model.dart';
import '../data/landing_mock_data.dart';
import '../data/models/public_platform_settings_model.dart';
import '../data/models/public_salary_insight_model.dart';
import '../data/repositories/demo_public_portal_repository.dart';
import '../data/repositories/firebase_public_portal_repository.dart';
import '../data/repositories/public_portal_repository.dart';
import '../services/salary_insight_service.dart';

class PublicPortalController extends ChangeNotifier {
  PublicPortalController._() {
    AuthController.instance.addListener(_authChanged);
  }
  StreamSubscription<PublicPortalSnapshot>? _subscription;
  int _loadGeneration = 0;
  String? _authSource;

  void _authChanged() {
    final auth = AuthController.instance;
    final source = '${auth.usesFirebase}:${auth.currentUser?.uid}';
    if (_authSource == source) return;
    _authSource = source;
    if (auth.currentUser != null) _guestDemoPreview = false;
    unawaited(refresh().catchError((Object _) {}));
  }

  static final PublicPortalController instance = PublicPortalController._();

  static const int _landingJobTarget = 6;

  PublicPortalRepository _repository = const DemoPublicPortalRepository();
  List<JobModel> _jobs = const [];
  List<JobModel> _landingSampleJobs = const [];
  List<CompanyModel> _companies = const [];
  List<CompanyModel> _landingSampleCompanies = const [];
  List<JobCategory> _categories = const [];
  List<PublicSalaryInsightModel> _salaryInsights = const [];
  PublicPlatformSettingsModel _settings = PublicPlatformSettingsModel.defaults;
  bool _guestDemoPreview = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _sourceNotice;
  int _revision = 0;

  /// Real published jobs only when Firebase is active.
  /// Landing-page sample cards are intentionally kept out of this collection
  /// so live counts, search results, recommendations, and applications stay
  /// truthful and consistent.
  List<JobModel> get jobs => List.unmodifiable(_jobs);
  List<CompanyModel> get companies => List.unmodifiable(_companies);
  List<JobCategory> get categories => List.unmodifiable(_categories);
  List<PublicSalaryInsightModel> get salaryInsights =>
      List.unmodifiable(_salaryInsights);
  PublicPlatformSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get sourceNotice => _sourceNotice;
  int get revision => _revision;
  bool get hasLandingSamples => _landingSampleJobs.isNotEmpty;
  bool get isDemoCatalog => _repository is DemoPublicPortalRepository;
  bool get isGuestDemoPreview =>
      _guestDemoPreview && AuthController.instance.usesFirebase;

  /// Guest-only academic showcase. Real authenticated users cannot switch
  /// from live vacancies to fictional application targets.
  Future<void> setGuestDemoPreview(bool enabled) async {
    if (enabled && AuthController.instance.currentUser != null) return;
    if (_guestDemoPreview == enabled) return;
    _guestDemoPreview = enabled;
    await _load(initial: false);
  }

  String get landingSampleNotice =>
      'Sample jobs are clearly labelled and shown only to complete the landing-page showcase. Live job counts and search results use published Firebase jobs only.';

  List<JobModel> get featuredJobs {
    final result = <JobModel>[];
    final seen = <String>{};

    void add(JobModel job) {
      final target = isDemoCatalog ? 20 : _landingJobTarget;
      if (result.length >= target || !seen.add(job.id)) return;
      result.add(job);
    }

    for (final job in _jobs.where((job) => job.isFeatured)) {
      add(job);
    }
    for (final job in _jobs) {
      add(job);
    }
    for (final job in _landingSampleJobs) {
      add(job);
    }
    return List<JobModel>.unmodifiable(result);
  }

  List<String> get employmentTypes => _jobs
      .map((job) => job.employmentType)
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<String> get workModes => _jobs
      .map((job) => job.workMode)
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<String> get experienceLevels => _jobs
      .map((job) => job.experience)
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<String> get categoryNames {
    final values = <String>{
      ..._categories.map((category) => category.title.trim()),
      ..._jobs.map((job) => job.category.trim()),
    }..removeWhere((value) => value.isEmpty);
    return values.toList()..sort();
  }

  List<String> get industries => _companies
      .map((company) => company.industry)
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  JobModel? jobById(String id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    for (final job in _landingSampleJobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  CompanyModel? companyById(String id) {
    for (final company in _companies) {
      if (company.id == id) return company;
    }
    for (final company in _landingSampleCompanies) {
      if (company.id == id) return company;
    }
    return null;
  }

  List<JobModel> jobsByCompany(String companyId) =>
      _jobs.where((job) => job.companyId == companyId).toList(growable: false);

  Future<void> initialize() async {
    await _load(initial: true);
  }

  Future<void> refresh() => _load(initial: false);

  Future<void> _load({required bool initial}) async {
    _authSource =
        '${AuthController.instance.usesFirebase}:${AuthController.instance.currentUser?.uid}';
    final generation = ++_loadGeneration;
    await _subscription?.cancel();
    _subscription = null;
    _isLoading = true;
    _errorMessage = null;
    if (!initial) notifyListeners();

    final useFirebase =
        AuthController.instance.usesFirebase && !_guestDemoPreview;
    if (useFirebase == (_repository is DemoPublicPortalRepository)) {
      _jobs = const [];
      _companies = const [];
      _categories = const [];
      _salaryInsights = const [];
      _landingSampleJobs = const [];
      _landingSampleCompanies = const [];
      CompanyLogoRegistry.instance.clear();
    }
    try {
      _repository = useFirebase
          ? FirebasePublicPortalRepository()
          : const DemoPublicPortalRepository();
      final snapshot =
          await _repository.load().timeout(const Duration(seconds: 15));
      if (generation != _loadGeneration) return;
      _apply(snapshot);
      _sourceNotice = useFirebase
          ? null
          : 'Demo mode · Fictional sample companies and jobs only.';

      if (useFirebase && AppEnvironment.allowDemoFallback) {
        await _prepareLandingSamples();
      } else {
        _landingSampleJobs = const [];
        _landingSampleCompanies = const [];
      }
      if (_repository case final FirebasePublicPortalRepository repository) {
        _subscription = repository.watch().listen((snapshot) {
          if (generation != _loadGeneration ||
              !AuthController.instance.usesFirebase ||
              _guestDemoPreview) {
            return;
          }
          _apply(snapshot);
          _errorMessage = null;
          _sourceNotice = null;
          notifyListeners();
        }, onError: (Object error) {
          if (generation != _loadGeneration) return;
          _errorMessage = _messageFor(error);
          _sourceNotice =
              'Live updates are temporarily unavailable. Check your connection.';
          notifyListeners();
        });
      }
    } catch (error) {
      if (generation != _loadGeneration) return;
      if (useFirebase && AppEnvironment.allowDemoFallback) {
        _repository = const DemoPublicPortalRepository();
        final snapshot =
            await _repository.load().timeout(const Duration(seconds: 15));
        _apply(snapshot);
        _landingSampleJobs = const [];
        _landingSampleCompanies = const [];
        _sourceNotice =
            'Live listings could not be loaded, so sample content is being shown.';
      } else {
        _errorMessage = _messageFor(error);
        _sourceNotice =
            'Live listings could not load. Check your connection and refresh the jobs page.';
        rethrow;
      }
    } finally {
      if (generation == _loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _prepareLandingSamples() async {
    final liveIds = _jobs.map((job) => job.id).toSet();
    final orderedLiveCount =
        _jobs.length < _landingJobTarget ? _jobs.length : _landingJobTarget;
    final needed = _landingJobTarget - orderedLiveCount;
    if (needed <= 0) {
      _landingSampleJobs = const [];
      _landingSampleCompanies = const [];
      return;
    }

    final demo = await const DemoPublicPortalRepository().load();
    _landingSampleJobs = demo.jobs
        .where((job) => !liveIds.contains(job.id))
        .take(needed)
        .map((job) => job.copyWith(isSample: true))
        .toList(growable: false);
    _landingSampleCompanies = demo.companies;
  }

  void _apply(PublicPortalSnapshot snapshot) {
    _jobs = List<JobModel>.from(snapshot.jobs);
    _companies = List<CompanyModel>.from(snapshot.companies);
    CompanyLogoRegistry.instance.replaceFromCompanies(_companies);
    _categories = List<JobCategory>.from(snapshot.categories);
    _salaryInsights = SalaryInsightService.calculate(_jobs);
    _settings = snapshot.settings;
    _revision++;
  }

  String _messageFor(Object error) {
    final value = error.toString();
    return value.startsWith('Bad state: ') ? value.substring(11) : value;
  }

  @visibleForTesting
  void resetForTesting() {
    _loadGeneration++;
    _subscription?.cancel();
    _subscription = null;
    _authSource =
        '${AuthController.instance.usesFirebase}:${AuthController.instance.currentUser?.uid}';
    _repository = const DemoPublicPortalRepository();
    _guestDemoPreview = false;
    _jobs = const [];
    _landingSampleJobs = const [];
    _companies = const [];
    _landingSampleCompanies = const [];
    CompanyLogoRegistry.instance.clear();
    _categories = const [];
    _salaryInsights = const [];
    _settings = PublicPlatformSettingsModel.defaults;
    _isLoading = false;
    _errorMessage = null;
    _sourceNotice = null;
    _revision = 0;
    notifyListeners();
  }
}
