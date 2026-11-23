import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../public_portal/controllers/public_portal_controller.dart';
import '../../../public_portal/data/models/public_salary_insight_model.dart';
import '../../../public_portal/services/salary_insight_service.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_page_components.dart';
import '../widgets/admin_workspace_gate.dart';

class SalaryInsightsManagementPage extends StatelessWidget {
  const SalaryInsightsManagementPage({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: PublicPortalController.instance,
    builder: (context, _) => _buildContent(context),
  );

  Widget _buildContent(BuildContext context) {
    return AdminWorkspaceGate(
      builder: (context, _) {
        final insights = PublicPortalController.instance.salaryInsights;
        return DashboardShell(
          role: UserRole.admin,
          title: 'Salary insights',
          subtitle:
              'Read-only market ranges calculated automatically from active published jobs. Admins no longer enter salary guides manually.',
          items: AdminNavigation.items,
          selectedIndex: 6,
          accent: AppColors.red,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminSectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.auto_graph_rounded,
                        color: AppColors.cyan,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Automatic salary calculation',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Career Bridge groups comparable published jobs and calculates minimum, median, average, and maximum monthly salary values. At least ${SalaryInsightService.minimumSampleSize} comparable listings are required before an insight is shown.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (insights.isEmpty)
                const AdminEmptyState(
                  title: 'Not enough salary data yet',
                  message:
                      'Insights will appear automatically after enough active jobs with comparable salary ranges are published.',
                  icon: Icons.insights_outlined,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 980 ? 2 : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 14) / columns;
                    return Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        for (final insight in insights)
                          SizedBox(
                            width: width,
                            child: _AutomaticSalaryCard(insight: insight),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AutomaticSalaryCard extends StatelessWidget {
  const _AutomaticSalaryCard({required this.insight});

  final PublicSalaryInsightModel insight;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.roleName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${insight.category} · ${insight.location} · ${insight.experienceLevel}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'AUTO',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Amount(label: 'Minimum', value: insight.minimumLabel),
              _Amount(
                  label: 'Median', value: insight.medianLabel, highlight: true),
              _Amount(label: 'Average', value: insight.averageLabel),
              _Amount(label: 'Maximum', value: insight.maximumLabel),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Based on ${insight.sampleSize} active ${insight.sampleSize == 1 ? 'job' : 'jobs'}',
            style: const TextStyle(
              color: AppColors.textSubtle,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.cyan.withValues(alpha: .08)
            : AppColors.panel.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? AppColors.cyan.withValues(alpha: .20)
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
              color: highlight ? AppColors.cyan : AppColors.textSecondary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
