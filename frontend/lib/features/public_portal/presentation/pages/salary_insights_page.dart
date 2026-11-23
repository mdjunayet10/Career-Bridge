import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/layouts/public_page_shell.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/page_hero.dart';
import '../../../../shared/widgets/section_container.dart';
import '../../controllers/public_portal_controller.dart';
import '../../data/models/public_salary_insight_model.dart';
import '../../services/salary_insight_service.dart';

class SalaryInsightsPage extends StatelessWidget {
  const SalaryInsightsPage({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: PublicPortalController.instance,
        builder: (context, _) => _buildContent(context),
      );

  Widget _buildContent(BuildContext context) {
    final roles = PublicPortalController.instance.salaryInsights;

    return PublicPageShell(
      child: Column(
        children: [
          const PageHero(
            eyebrow: 'Salary insights',
            title: 'Understand the range before the conversation.',
            description:
                'Automatically calculated from active published jobs with salary data. Career Bridge uses real listing ranges instead of manually entered salary guides.',
          ),
          SectionContainer(
            padding: const EdgeInsets.fromLTRB(24, 42, 24, 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: .20),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_graph_rounded,
                        color: AppColors.cyan,
                      ),
                      SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          'Insights are generated automatically when at least ${SalaryInsightService.minimumSampleSize} comparable active jobs provide monthly salary ranges. They are guidance, not guaranteed offers.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (roles.isEmpty)
                  const EmptyState(
                    icon: Icons.insights_outlined,
                    title: 'Not enough salary data yet',
                    message:
                        'Salary insights will appear automatically after enough active jobs with comparable salary ranges are published.',
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final desktop = constraints.maxWidth >= 900;
                        if (!desktop) {
                          return Column(
                            children: [
                              for (var i = 0; i < roles.length; i++) ...[
                                _MobileSalaryCard(role: roles[i]),
                                if (i != roles.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          );
                        }

                        return Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1.55),
                            1: FlexColumnWidth(1.25),
                            2: FlexColumnWidth(.9),
                            3: FlexColumnWidth(.9),
                            4: FlexColumnWidth(.9),
                            5: FlexColumnWidth(.9),
                            6: FlexColumnWidth(.65),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          border: const TableBorder(
                            horizontalInside: BorderSide(
                              color: AppColors.borderMuted,
                            ),
                          ),
                          children: [
                            const TableRow(
                              decoration: BoxDecoration(
                                color: AppColors.panel,
                              ),
                              children: [
                                _TableCell('Role / market', header: true),
                                _TableCell('Context', header: true),
                                _TableCell('Minimum', header: true),
                                _TableCell('Median', header: true),
                                _TableCell('Average', header: true),
                                _TableCell('Maximum', header: true),
                                _TableCell('Jobs', header: true),
                              ],
                            ),
                            for (final role in roles)
                              TableRow(
                                children: [
                                  _TableCell(role.roleName, strong: true),
                                  _TableCell(
                                    '${role.experienceLevel} • ${role.location}',
                                  ),
                                  _TableCell(role.minimumLabel),
                                  _TableCell(role.medianLabel, accent: true),
                                  _TableCell(role.averageLabel),
                                  _TableCell(role.maximumLabel),
                                  _TableCell('${role.sampleSize}'),
                                ],
                              ),
                          ],
                        );
                      },
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

class _TableCell extends StatelessWidget {
  const _TableCell(
    this.value, {
    this.header = false,
    this.strong = false,
    this.accent = false,
  });

  final String value;
  final bool header;
  final bool strong;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
        value,
        style: TextStyle(
          color: accent
              ? AppColors.cyan
              : header
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
          fontSize: header ? 10.5 : 11.5,
          fontWeight:
              header || strong || accent ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _MobileSalaryCard extends StatelessWidget {
  const _MobileSalaryCard({required this.role});

  final PublicSalaryInsightModel role;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role.roleName,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 5),
          Text(
            '${role.category} • ${role.location} • ${role.experienceLevel}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SalaryMetric(label: 'Minimum', value: role.minimumLabel),
              _SalaryMetric(
                label: 'Median',
                value: role.medianLabel,
                accent: true,
              ),
              _SalaryMetric(label: 'Average', value: role.averageLabel),
              _SalaryMetric(label: 'Maximum', value: role.maximumLabel),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            'Based on ${role.sampleSize} active ${role.sampleSize == 1 ? 'job' : 'jobs'}',
            style: const TextStyle(
              color: AppColors.textSubtle,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryMetric extends StatelessWidget {
  const _SalaryMetric({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.cyan.withValues(alpha: .08)
            : AppColors.panel.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent
              ? AppColors.cyan.withValues(alpha: .22)
              : AppColors.borderMuted,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSubtle,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: accent ? AppColors.cyan : AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
