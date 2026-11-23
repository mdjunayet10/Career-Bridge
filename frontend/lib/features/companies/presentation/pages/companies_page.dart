import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/layouts/public_page_shell.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/page_hero.dart';
import '../../../../shared/widgets/section_container.dart';
import '../../../public_portal/controllers/public_portal_controller.dart';
import '../../data/models/company_model.dart';
import '../widgets/company_card.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  late final TextEditingController _searchController;
  String? _industry;

  @override
  void initState() {
    super.initState();
    PublicPortalController.instance.addListener(_changed);
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    PublicPortalController.instance.removeListener(_changed);
    _searchController.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  List<CompanyModel> get _companies {
    return PublicPortalController.instance.companies.where((company) {
      return company.matchesText(_searchController.text) &&
          (_industry == null || company.industry == _industry);
    }).toList();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _industry = null);
  }

  @override
  Widget build(BuildContext context) {
    final companies = _companies;
    return PublicPageShell(
      child: Column(
        children: [
          PageHero(
            eyebrow: PublicPortalController.instance.isDemoCatalog
                ? 'Fictional companies · Demo'
                : 'Verified companies',
            title: 'Meet the teams behind the opportunities.',
            description: PublicPortalController.instance.isDemoCatalog
                ? 'Browse the 12 fictional university demo companies. They are not verified employers or real hiring opportunities.'
                : 'Compare industries, locations, team sizes, and active roles before choosing where to apply.',
          ),
          SectionContainer(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CompanySearchBar(
                  searchController: _searchController,
                  industry: _industry,
                  onIndustryChanged: (value) =>
                      setState(() => _industry = value),
                  onSearch: () => setState(() {}),
                ),
                const SizedBox(height: 30),
                _ResultsHeader(
                  count: companies.length,
                  filtered: _searchController.text.trim().isNotEmpty ||
                      _industry != null,
                  onClear: _clearFilters,
                ),
                const SizedBox(height: 18),
                if (companies.isEmpty)
                  EmptyState(
                    icon: Icons.business_outlined,
                    title: 'No companies found',
                    message:
                        'Try another company name, location, or industry filter.',
                    action: OutlinedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Clear filters'),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1040
                          ? 3
                          : constraints.maxWidth >= 680
                              ? 2
                              : 1;
                      const gap = 18.0;
                      final width =
                          (constraints.maxWidth - (columns - 1) * gap) /
                              columns;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final company in companies)
                            SizedBox(
                              width: width,
                              child: CompanyCard(company: company),
                            ),
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
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.count,
    required this.filtered,
    required this.onClear,
  });

  final int count;
  final bool filtered;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count ${count == 1 ? 'company' : 'companies'} found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Only approved and active employer profiles are shown.',
                style: TextStyle(
                  color: AppColors.textSubtle,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (filtered)
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 17),
            label: const Text('Clear filters'),
          ),
      ],
    );
  }
}

class _CompanySearchBar extends StatelessWidget {
  const _CompanySearchBar({
    required this.searchController,
    required this.industry,
    required this.onIndustryChanged,
    required this.onSearch,
  });

  final TextEditingController searchController;
  final String? industry;
  final ValueChanged<String?> onIndustryChanged;
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
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 720;
          final search = TextField(
            controller: searchController,
            onChanged: (_) => onSearch(),
            onSubmitted: (_) => onSearch(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search company, industry, or location',
            ),
          );
          final industryFilter = DropdownButtonFormField<String>(
            key: ValueKey(industry ?? ''),
            initialValue: industry ?? '',
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.domain_outlined),
              hintText: 'All industries',
            ),
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Text('All industries'),
              ),
              for (final item in PublicPortalController.instance.industries)
                DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (value) => onIndustryChanged(
              value == null || value.isEmpty ? null : value,
            ),
          );
          final button = FilledButton.icon(
            onPressed: onSearch,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blueStrong,
              minimumSize: const Size(142, 56),
            ),
            icon: const Icon(Icons.search_rounded),
            label: const Text('Search'),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 10),
                industryFilter,
                const SizedBox(height: 10),
                button,
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 5, child: search),
              const SizedBox(width: 10),
              Expanded(flex: 3, child: industryFilter),
              const SizedBox(width: 10),
              button,
            ],
          );
        },
      ),
    );
  }
}
