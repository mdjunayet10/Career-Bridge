import '../../../reports/report_button.dart';
import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/layouts/public_page_shell.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_container.dart';
import '../../../jobs/presentation/widgets/public_job_card.dart';
import '../../../public_portal/controllers/public_portal_controller.dart';
import '../../data/models/company_model.dart';

class CompanyDetailsPage extends StatelessWidget {
  const CompanyDetailsPage({required this.companyId, super.key});

  final String companyId;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: PublicPortalController.instance,
        builder: (context, _) => _buildContent(context),
      );

  Widget _buildContent(BuildContext context) {
    final portal = PublicPortalController.instance;
    final company = portal.companyById(companyId);

    if (company == null) {
      return PublicPageShell(
        child: SectionContainer(
          child: EmptyState(
            icon: Icons.domain_disabled_outlined,
            title: 'Company not found',
            message:
                'The company profile may be unavailable or the link may be incorrect.',
            action: FilledButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.companies),
              child: const Text('Browse companies'),
            ),
          ),
        ),
      );
    }

    final jobs = portal.jobsByCompany(company.id);

    return PublicPageShell(
      child: Column(
        children: [
          _CompanyHeader(company: company),
          SectionContainer(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: ReportButton(
                      targetType: 'company',
                      targetId: company.id,
                      targetLabel: company.name,
                      isSample: portal.isDemoCatalog ||
                          !portal.companies.any((c) => c.id == company.id)))),
          SectionContainer(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final desktop = constraints.maxWidth >= 900;
                    final about = _AboutCompany(company: company);
                    final overview = _CompanyOverview(company: company);

                    if (desktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: about),
                          const SizedBox(width: 22),
                          SizedBox(width: 330, child: overview),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        about,
                        const SizedBox(height: 18),
                        overview,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 44),
                _OpenPositionsHeader(
                  company: company,
                  count: jobs.length,
                ),
                const SizedBox(height: 18),
                if (jobs.isEmpty)
                  const EmptyState(
                    icon: Icons.work_outline_rounded,
                    title: 'No open roles right now',
                    message:
                        'This verified company profile is active, but no approved jobs are currently published.',
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 980
                          ? 3
                          : constraints.maxWidth >= 650
                              ? 2
                              : 1;
                      const gap = 16.0;
                      final width =
                          (constraints.maxWidth - (columns - 1) * gap) /
                              columns;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final job in jobs)
                            SizedBox(
                              width: width,
                              child: PublicJobCard(job: job, compact: true),
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

class _CompanyHeader extends StatelessWidget {
  const _CompanyHeader({required this.company});

  final CompanyModel company;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.page,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderMuted),
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.page,
            AppColors.blueStrong.withValues(alpha: .075),
            AppColors.purple.withValues(alpha: .045),
            AppColors.page,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SectionContainer(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.companies),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('All companies'),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                final companyIdentity = Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CompanyLogo(
                      companyId: company.id,
                      companyName: company.name,
                      logoFileId: company.logoFileId,
                      size: compact ? 70 : 78,
                      borderRadius: 22,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  company.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: compact ? 28 : 36,
                                        fontWeight: FontWeight.w800,
                                        height: 1.1,
                                        letterSpacing: -.8,
                                      ),
                                ),
                              ),
                              if (company.isVerified) ...[
                                const SizedBox(width: 8),
                                const Tooltip(
                                  message: 'Verified employer',
                                  child: Icon(
                                    Icons.verified_rounded,
                                    color: AppColors.green,
                                    size: 23,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            company.industry,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _HeaderFact(
                                icon: Icons.location_on_outlined,
                                label: company.location,
                              ),
                              _HeaderFact(
                                icon: Icons.groups_2_outlined,
                                label: company.size,
                              ),
                              _HeaderFact(
                                icon: Icons.calendar_today_outlined,
                                label: 'Founded ${company.founded}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final actions = Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card.withValues(alpha: .88),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${company.openings}',
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'open positions',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      FilledButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '${AppRoutes.jobs}?q=${Uri.encodeQueryComponent(company.name)}',
                        ),
                        icon: const Icon(Icons.work_outline_rounded, size: 18),
                        label: const Text('View jobs'),
                      ),
                    ],
                  ),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      companyIdentity,
                      const SizedBox(height: 18),
                      actions,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: companyIdentity),
                    const SizedBox(width: 26),
                    actions,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderFact extends StatelessWidget {
  const _HeaderFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSubtle),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCompany extends StatelessWidget {
  const _AboutCompany({required this.company});

  final CompanyModel company;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.blueStrong.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notes_rounded,
                  color: AppColors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'About ${company.name}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            company.description,
            style: const TextStyle(
              color: AppColors.textMuted,
              height: 1.72,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 26),
          const Divider(),
          const SizedBox(height: 22),
          const Text(
            'Areas of work',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final specialty in company.specialties)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.blueStrong.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.blue.withValues(alpha: .22),
                    ),
                  ),
                  child: Text(
                    specialty,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanyOverview extends StatelessWidget {
  const _CompanyOverview({required this.company});

  final CompanyModel company;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company overview',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 20),
          _OverviewItem(
            icon: Icons.category_outlined,
            label: 'Industry',
            value: company.industry,
          ),
          _OverviewItem(
            icon: Icons.groups_2_outlined,
            label: 'Team size',
            value: company.size,
          ),
          _OverviewItem(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: company.location,
          ),
          _OverviewItem(
            icon: Icons.calendar_today_outlined,
            label: 'Founded',
            value: company.founded,
          ),
          if (company.website != null)
            _OverviewItem(
              icon: Icons.language_rounded,
              label: 'Website',
              value: company.website!,
            ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.green.withValues(alpha: .22),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.green,
                  size: 19,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Verified and active employer profile.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.input,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderMuted),
            ),
            child: Icon(icon, size: 17, color: AppColors.textSubtle),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenPositionsHeader extends StatelessWidget {
  const _OpenPositionsHeader({
    required this.company,
    required this.count,
  });

  final CompanyModel company;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 10,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Open positions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              '$count approved ${count == 1 ? 'role' : 'roles'} currently available',
              style: const TextStyle(
                color: AppColors.textSubtle,
                fontSize: 11,
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(
            context,
            '${AppRoutes.jobs}?q=${Uri.encodeQueryComponent(company.name)}',
          ),
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text('View in job search'),
        ),
      ],
    );
  }
}
