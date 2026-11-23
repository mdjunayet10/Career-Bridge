import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/employer_job_status.dart';
import '../../../../core/enums/employer_verification_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../controllers/admin_workspace_controller.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_page_components.dart';
import '../widgets/admin_status_badge.dart';
import '../widgets/admin_workspace_gate.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminWorkspaceGate(
      builder: (context, controller) => DashboardShell(
        role: UserRole.admin,
        title: 'Platform control centre',
        subtitle:
            'Review trust, safety, content quality, and operational health from one protected workspace.',
        items: AdminNavigation.items,
        selectedIndex: 0,
        accent: AppColors.red,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AdminActionStrip(controller: controller),
            const SizedBox(height: 20),
            _Metrics(controller: controller),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 920;
                if (desktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 6,
                          child: _ModerationQueue(controller: controller)),
                      const SizedBox(width: 16),
                      Expanded(
                          flex: 4,
                          child: _PlatformHealth(controller: controller)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _ModerationQueue(controller: controller),
                    const SizedBox(height: 16),
                    _PlatformHealth(controller: controller),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            _RecentActivity(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _AdminActionStrip extends StatelessWidget {
  const _AdminActionStrip({required this.controller});

  final AdminWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final queueCount = controller.pendingEmployerCount +
        controller.pendingJobCount +
        controller.openReportCount;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.red.withValues(alpha: .22)),
        gradient: LinearGradient(
          colors: [
            AppColors.red.withValues(alpha: .08),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final copy = Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Protected administration workspace',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      queueCount == 0
                          ? 'All moderation queues are clear.'
                          : '$queueCount item${queueCount == 1 ? '' : 's'} need admin attention.',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final actions = Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.adminEmployerVerification,
                ),
                icon: const Icon(Icons.verified_user_outlined, size: 17),
                label: const Text('Employers'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.adminJobApprovals,
                ),
                icon: const Icon(Icons.fact_check_outlined, size: 17),
                label: const Text('Review jobs'),
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [copy, const SizedBox(height: 16), actions],
            );
          }
          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 20),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.controller});

  final AdminWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      AdminMetricCard(
        label: controller.isDemoPreview ? 'Demo accounts' : 'Registered users',
        value: controller.totalUsers.toString(),
        icon: Icons.people_outline_rounded,
        color: AppColors.blue,
        note: controller.isDemoPreview
            ? '${controller.jobSeekerCount} seekers + ${controller.employerCount} employers'
            : '${controller.activeUsers} active accounts',
      ),
      AdminMetricCard(
        label: 'Pending employers',
        value: controller.pendingEmployerCount.toString(),
        icon: Icons.verified_user_outlined,
        color: AppColors.yellow,
        note: '${controller.approvedCompanyCount} approved companies',
      ),
      AdminMetricCard(
        label: 'Jobs awaiting review',
        value: controller.pendingJobCount.toString(),
        icon: Icons.fact_check_outlined,
        color: AppColors.purple,
        note: '${controller.publishedJobCount} published jobs',
      ),
      AdminMetricCard(
        label: 'Open reports',
        value: controller.openReportCount.toString(),
        icon: Icons.flag_outlined,
        color: AppColors.red,
        note: 'Trust and safety queue',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 620
                ? 2
                : 1;
        final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final card in cards) SizedBox(width: width, child: card)
          ],
        );
      },
    );
  }
}

class _ModerationQueue extends StatelessWidget {
  const _ModerationQueue({required this.controller});

  final AdminWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final pendingCompanies = controller.companies
        .where(
            (company) => company.status == EmployerVerificationStatus.pending)
        .take(3)
        .toList();
    final pendingJobs = controller.jobs
        .where((job) => job.status == EmployerJobStatus.pending)
        .take(3)
        .toList();

    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Moderation queue',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              TextButton.icon(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (pendingCompanies.isEmpty && pendingJobs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text('No items are waiting for review.',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
          for (final company in pendingCompanies)
            _QueueRow(
              icon: Icons.apartment_rounded,
              leading: CompanyLogo(
                companyId: company.companyId,
                companyName: company.companyName,
                logoFileId: company.logoFileId,
                size: 42,
                borderRadius: 12,
              ),
              color: AppColors.yellow,
              title: company.companyName,
              subtitle: '${company.industry} · Employer verification',
              trailing: AdminStatusBadge.verification(company.status),
              onTap: () => Navigator.pushReplacementNamed(
                  context, AppRoutes.adminEmployerVerification),
            ),
          for (final job in pendingJobs)
            _QueueRow(
              icon: Icons.work_outline_rounded,
              color: AppColors.purple,
              title: job.title,
              subtitle: '${controller.companyNameForJob(job)} · Job approval',
              trailing: const AdminStatusBadge(
                  label: 'Pending', color: AppColors.yellow),
              onTap: () => Navigator.pushReplacementNamed(
                  context, AppRoutes.adminJobApprovals),
            ),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.icon,
    required this.color,
    this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Widget? leading;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            leading ??
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing,
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }
}

class _PlatformHealth extends StatelessWidget {
  const _PlatformHealth({required this.controller});

  final AdminWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final settings = controller.settings!;
    final rows = [
      (
        'Authentication',
        'Operational',
        AppColors.green,
        Icons.lock_outline_rounded
      ),
      (
        'Employer review',
        settings.employerReviewRequired ? 'Required' : 'Disabled',
        settings.employerReviewRequired ? AppColors.green : AppColors.yellow,
        Icons.verified_user_outlined
      ),
      (
        'Job moderation',
        settings.jobReviewRequired ? 'Required' : 'Disabled',
        settings.jobReviewRequired ? AppColors.green : AppColors.yellow,
        Icons.fact_check_outlined
      ),
      (
        'Maintenance mode',
        settings.maintenanceMode ? 'Enabled' : 'Off',
        settings.maintenanceMode ? AppColors.red : AppColors.green,
        Icons.engineering_outlined
      ),
    ];
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform health',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  Icon(row.$4, color: row.$3, size: 20),
                  const SizedBox(width: 11),
                  Expanded(
                      child: Text(row.$1,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 11))),
                  Text(row.$2,
                      style: TextStyle(
                          color: row.$3,
                          fontWeight: FontWeight.w800,
                          fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.controller});

  final AdminWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.activities.take(8).toList();
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent admin activity',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 15),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.admin_panel_settings_outlined,
                        color: AppColors.red, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item.action} · ${item.subject}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 11)),
                        Text(compactDateTime(item.createdAt),
                            style: const TextStyle(
                                color: AppColors.textSubtle, fontSize: 9)),
                        if (item.detail.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(item.detail,
                              style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  height: 1.4)),
                        ],
                      ],
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
