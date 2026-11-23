import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/public_page_shell.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/location_filter_chips.dart';
import '../../../../shared/widgets/location_selector.dart';
import '../../../../shared/widgets/page_hero.dart';
import '../../../../shared/widgets/section_container.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../job_seeker/controllers/job_seeker_workspace_controller.dart';
import '../../../public_portal/controllers/public_portal_controller.dart';
import '../../data/models/job_model.dart';
import '../widgets/job_filter_panel.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/public_job_card.dart';

class JobListPage extends StatefulWidget {
  const JobListPage({
    super.key,
    this.initialQuery = '',
    this.initialLocation = '',
  });

  final String initialQuery;
  final String initialLocation;

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  int get _pageSize => _portal.isDemoCatalog ? 20 : 6;

  late final TextEditingController _queryController;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _guestSavedJobIds = <String>{};
  final _workspace = JobSeekerWorkspaceController.instance;
  final _portal = PublicPortalController.instance;

  String? _category;
  String? _employmentType;
  String? _workMode;
  String? _experience;
  late String _location;
  String _sort = 'Newest';
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
    _location = JobLocations.normalize(widget.initialLocation);
    _workspace.addListener(_workspaceChanged);
    _portal.addListener(_workspaceChanged);
    if (AuthController.instance.currentUser?.role == UserRole.jobSeeker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _workspace.ensureLoaded();
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _workspace.removeListener(_workspaceChanged);
    _portal.removeListener(_workspaceChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _workspaceChanged() {
    if (mounted) setState(() {});
  }

  Set<String> get _savedJobIds =>
      AuthController.instance.currentUser?.role == UserRole.jobSeeker &&
              _workspace.isLoaded
          ? _workspace.savedJobIds
          : _guestSavedJobIds;

  Map<String, int> get _recommendationScores {
    if (AuthController.instance.currentUser?.role != UserRole.jobSeeker ||
        !_workspace.isLoaded) {
      return const <String, int>{};
    }
    return {
      for (final recommendation in _workspace.jobRecommendations)
        recommendation.job.id: recommendation.score,
    };
  }

  Future<void> _setSavedJob(String jobId, bool saved) async {
    final user = AuthController.instance.currentUser;
    if (user?.role == UserRole.jobSeeker) {
      await _workspace.ensureLoaded();
      if (_workspace.isSaved(jobId) != saved) {
        await _workspace.toggleSavedJob(jobId);
      }
      return;
    }
    setState(() {
      saved ? _guestSavedJobIds.add(jobId) : _guestSavedJobIds.remove(jobId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(user == null
            ? 'Sign in as a Job Seeker to sync saved jobs.'
            : 'Only Job Seeker accounts can save jobs.'),
      ),
    );
  }

  List<JobModel> get _filteredJobs {
    final location = _location.trim().toLowerCase();
    final recommendationScores = _recommendationScores;
    final jobs = _portal.jobs.where((job) {
      final jobLocation = job.location.toLowerCase();
      final locationMatches = location.isEmpty ||
          jobLocation.contains(location) ||
          (location == 'chattogram' && jobLocation.contains('chittagong')) ||
          job.workMode.toLowerCase().contains(location);

      return job.matchesText(_queryController.text) &&
          locationMatches &&
          (_category == null || job.category == _category) &&
          (_employmentType == null || job.employmentType == _employmentType) &&
          (_workMode == null || job.workMode == _workMode) &&
          (_experience == null || job.experience == _experience);
    }).toList();

    switch (_sort) {
      case 'Salary: high to low':
        jobs.sort((a, b) => b.salaryMax.compareTo(a.salaryMax));
        break;
      case 'Newest':
        // Firebase already provides publication order; keep its stable ordering.
        break;
      default:
        jobs.sort((a, b) {
          final scoreCompare = (recommendationScores[b.id] ?? 0)
              .compareTo(recommendationScores[a.id] ?? 0);
          if (scoreCompare != 0) return scoreCompare;
          if (a.isFeatured == b.isFeatured) return a.title.compareTo(b.title);
          return a.isFeatured ? -1 : 1;
        });
        break;
    }

    return jobs;
  }

  void _refreshSearch() {
    setState(() => _page = 1);
  }

  void _clearFilters() {
    setState(() {
      _category = null;
      _employmentType = null;
      _workMode = null;
      _experience = null;
      _page = 1;
    });
  }

  void _setCategory(String? value) {
    setState(() {
      _category = value;
      _page = 1;
    });
  }

  void _setEmploymentType(String? value) {
    setState(() {
      _employmentType = value;
      _page = 1;
    });
  }

  void _setWorkMode(String? value) {
    setState(() {
      _workMode = value;
      _page = 1;
    });
  }

  void _setExperience(String? value) {
    setState(() {
      _experience = value;
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredJobs;
    final pageCount = math.max(1, (filtered.length / _pageSize).ceil());
    final effectivePage = math.min(_page, pageCount);

    final start = (effectivePage - 1) * _pageSize;
    final end = math.min(start + _pageSize, filtered.length);
    final pageJobs =
        filtered.isEmpty ? const <JobModel>[] : filtered.sublist(start, end);

    return PublicPageShell(
      scrollController: _scrollController,
      child: Column(
        children: [
          PageHero(
            eyebrow:
                _portal.isDemoCatalog ? '20 sample jobs · Demo' : 'Find jobs',
            title: 'Search opportunities with clearer details.',
            description: _portal.isDemoCatalog
                ? 'Browse all 20 fictional demo jobs. Filter by field, location or type. These are academic samples, not real vacancies.'
                : 'Filter verified roles by career path, work style, location, and job type—then review salary and company information before applying.',
          ),
          SectionContainer(
            padding: const EdgeInsets.fromLTRB(24, 38, 24, 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(spacing: 10, runSpacing: 8, children: [
                  ChoiceChip(
                      label: const Text('All Jobs'),
                      selected: _sort != 'Recommended',
                      onSelected: (_) => setState(() {
                            _sort = 'Newest';
                            _page = 1;
                          })),
                  ChoiceChip(
                      label: const Text('Recommended'),
                      selected: _sort == 'Recommended',
                      onSelected: (_) => setState(() {
                            _sort = 'Recommended';
                            _page = 1;
                          })),
                ]),
                const SizedBox(height: 10),
                Text(
                    _sort == 'Recommended'
                        ? 'Ordered by your CV and profile match. You can still browse every role.'
                        : 'Browse every published job, regardless of your CV or field.',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 18),
                _SearchToolbar(
                  queryController: _queryController,
                  location: _location,
                  onLocationChanged: (value) {
                    setState(() {
                      _location = value;
                      _page = 1;
                    });
                  },
                  onSearch: _refreshSearch,
                ),
                const SizedBox(height: 26),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final desktop = constraints.maxWidth >= 920;
                    final results = _ResultsColumn(
                      resultCount: filtered.length,
                      pageJobs: pageJobs,
                      sort: _sort,
                      onSortChanged: (value) => setState(() {
                        _sort = value;
                        _page = 1;
                      }),
                      savedJobIds: _savedJobIds,
                      matchScores: _recommendationScores,
                      onSave: _setSavedJob,
                      currentPage: effectivePage,
                      pageCount: pageCount,
                      onPageChanged: (page) {
                        setState(() => _page = page);
                        _scrollController.animateTo(
                          300,
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      onReset: () {
                        _queryController.clear();
                        setState(() => _location = '');
                        _clearFilters();
                      },
                    );

                    if (!desktop) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _openMobileFilters,
                            icon: const Icon(Icons.tune_rounded),
                            label: Text(_activeFilterLabel),
                          ),
                          const SizedBox(height: 18),
                          results,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 270,
                          child: JobFilterPanel(
                            categories: _portal.categoryNames,
                            employmentTypes: _portal.employmentTypes,
                            workModes: _portal.workModes,
                            experienceLevels: _portal.experienceLevels,
                            selectedCategory: _category,
                            selectedEmploymentType: _employmentType,
                            selectedWorkMode: _workMode,
                            selectedExperience: _experience,
                            onCategoryChanged: _setCategory,
                            onEmploymentTypeChanged: _setEmploymentType,
                            onWorkModeChanged: _setWorkMode,
                            onExperienceChanged: _setExperience,
                            onClear: _clearFilters,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(child: results),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _activeFilterLabel {
    final count = [_category, _employmentType, _workMode, _experience]
        .where((value) => value != null)
        .length;
    return count == 0 ? 'Filters' : 'Filters ($count active)';
  }

  Future<void> _openMobileFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void refresh(VoidCallback callback) {
              callback();
              setSheetState(() {});
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: JobFilterPanel(
                  categories: _portal.categoryNames,
                  employmentTypes: _portal.employmentTypes,
                  workModes: _portal.workModes,
                  experienceLevels: _portal.experienceLevels,
                  selectedCategory: _category,
                  selectedEmploymentType: _employmentType,
                  selectedWorkMode: _workMode,
                  selectedExperience: _experience,
                  onCategoryChanged: (value) =>
                      refresh(() => _setCategory(value)),
                  onEmploymentTypeChanged: (value) =>
                      refresh(() => _setEmploymentType(value)),
                  onWorkModeChanged: (value) =>
                      refresh(() => _setWorkMode(value)),
                  onExperienceChanged: (value) =>
                      refresh(() => _setExperience(value)),
                  onClear: () => refresh(_clearFilters),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchToolbar extends StatelessWidget {
  const _SearchToolbar({
    required this.queryController,
    required this.location,
    required this.onLocationChanged,
    required this.onSearch,
  });

  final TextEditingController queryController;
  final String location;
  final ValueChanged<String> onLocationChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 720;
          final queryField = TextField(
            controller: queryController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Job title, skill, or company',
            ),
          );
          final button = FilledButton.icon(
            onPressed: onSearch,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blueStrong,
              minimumSize: const Size(150, 56),
            ),
            icon: const Icon(Icons.search_rounded),
            label: const Text('Search jobs'),
          );

          final searchRow = stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    queryField,
                    const SizedBox(height: 10),
                    button,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: queryField),
                    const SizedBox(width: 10),
                    button,
                  ],
                );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchRow,
              const SizedBox(height: 14),
              LocationFilterChips(
                selectedLocation: location,
                onChanged: onLocationChanged,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultsColumn extends StatelessWidget {
  const _ResultsColumn({
    required this.resultCount,
    required this.pageJobs,
    required this.sort,
    required this.onSortChanged,
    required this.savedJobIds,
    required this.matchScores,
    required this.onSave,
    required this.currentPage,
    required this.pageCount,
    required this.onPageChanged,
    required this.onReset,
  });

  final int resultCount;
  final List<JobModel> pageJobs;
  final String sort;
  final ValueChanged<String> onSortChanged;
  final Set<String> savedJobIds;
  final Map<String, int> matchScores;
  final void Function(String jobId, bool saved) onSave;
  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 550;
            final count = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$resultCount opportunities found',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Only active opportunities from verified companies are shown.',
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 11),
                ),
              ],
            );
            final dropdown = SizedBox(
              width: compact ? double.infinity : 228,
              child: _SortMenu(value: sort, onChanged: onSortChanged),
            );

            return compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [count, const SizedBox(height: 14), dropdown],
                  )
                : Row(children: [Expanded(child: count), dropdown]);
          },
        ),
        const SizedBox(height: 20),
        if (pageJobs.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No matching jobs found',
            message:
                'Try a broader keyword, another location, or clear the active filters.',
            action: OutlinedButton(
                onPressed: onReset, child: const Text('Reset search')),
          )
        else ...[
          for (var index = 0; index < pageJobs.length; index++) ...[
            PublicJobCard(
              job: pageJobs[index],
              isSaved: savedJobIds.contains(pageJobs[index].id),
              matchScore: matchScores[pageJobs[index].id],
              onSave: (saved) => onSave(pageJobs[index].id, saved),
            ),
            if (index != pageJobs.length - 1) const SizedBox(height: 16),
          ],
          const SizedBox(height: 28),
          PaginationBar(
            currentPage: currentPage,
            pageCount: pageCount,
            onPageChanged: onPageChanged,
          ),
        ],
      ],
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.value, required this.onChanged});

  static const values = <String>[
    'Recommended',
    'Newest',
    'Salary: high to low',
  ];

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value,
      tooltip: 'Sort jobs',
      color: AppColors.panel,
      elevation: 16,
      position: PopupMenuPosition.under,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final option in values)
          PopupMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Expanded(child: Text(option)),
                if (option == value)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.blue,
                  ),
              ],
            ),
          ),
      ],
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      color: AppColors.textSubtle,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
