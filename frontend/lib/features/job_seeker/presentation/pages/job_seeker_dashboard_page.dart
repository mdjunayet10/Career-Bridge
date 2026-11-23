import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../../shared/widgets/dashboard_stat_card.dart';
import '../../../applications/data/models/application_model.dart';
import '../../../applications/presentation/widgets/application_status_badge.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../public_portal/controllers/public_portal_controller.dart';
import '../../controllers/job_seeker_workspace_controller.dart';
import '../widgets/job_seeker_navigation.dart';
import '../widgets/job_seeker_workspace_gate.dart';

class JobSeekerDashboardPage extends StatelessWidget {
  const JobSeekerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.currentUser!;
    return DashboardShell(
      role: UserRole.jobSeeker,
      title: 'Good morning, ${user.name.split(' ').first}.',
      subtitle:
          'Track applications, strengthen your profile, and move toward your next opportunity.',
      items: JobSeekerNavigation.items,
      selectedIndex: 0,
      body: JobSeekerWorkspaceGate(
        builder: (context, controller) =>
            _DashboardContent(controller: controller),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.controller});

  final JobSeekerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsGrid(controller: controller),
        const SizedBox(height: 24),
        _ProfileProgress(controller: controller),
        const SizedBox(height: 14),
        Align(alignment: Alignment.centerLeft, child: FilledButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.jobs),
          icon: const Icon(Icons.travel_explore_rounded), label: const Text('Browse All Jobs'))),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 920;
            final applications = _RecentApplications(controller: controller);
            final activity = _QuickActivity(controller: controller);
            return desktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: applications),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: activity),
                    ],
                  )
                : Column(children: [
                    applications,
                    const SizedBox(height: 18),
                    activity
                  ]);
          },
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: Text('Recommended for you',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.jobs),
              child: const Text('View all jobs'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980
                ? 3
                : constraints.maxWidth >= 620
                    ? 2
                    : 1;
            final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final recommendation
                    in controller.jobRecommendations.take(3))
                  SizedBox(
                    width: width,
                    child: _CompactJobCard(
                      title: recommendation.job.title,
                      companyId: recommendation.job.companyId,
                      companyName: recommendation.job.companyName,
                      meta:
                          '${recommendation.job.location} · ${recommendation.job.workMode}',
                      salary: recommendation.job.salaryLabel,
                      matchScore: recommendation.score,
                      matchReason: recommendation.reasons.join(' · '),
                      saved: controller.isSaved(recommendation.job.id),
                      onSave: () =>
                          controller.toggleSavedJob(recommendation.job.id),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.jobDetails(recommendation.job.id),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.controller});

  final JobSeekerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      DashboardStatCard(
        label: 'Applications',
        value: '${controller.applications.length}',
        icon: Icons.send_outlined,
        accent: AppColors.blue,
        note: '${controller.activeApplicationCount} active',
      ),
      DashboardStatCard(
          label: 'Shortlisted',
          value: '${controller.shortlistedCount}',
          icon: Icons.star_outline_rounded,
          accent: AppColors.purple),
      DashboardStatCard(
          label: 'Interviews',
          value: '${controller.interviewCount}',
          icon: Icons.event_available_outlined,
          accent: AppColors.green),
      DashboardStatCard(
          label: 'Saved jobs',
          value: '${controller.savedJobIds.length}',
          icon: Icons.bookmark_border_rounded,
          accent: AppColors.cyan),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
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

class _ProfileProgress extends StatelessWidget {
  const _ProfileProgress({required this.controller});

  final JobSeekerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile!;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Complete your career profile',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 7),
              Text(
                '${profile.fullName}, profile updates automatically sync to your CV and improve personalized job recommendations.',
                style: const TextStyle(color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: profile.completion,
                minHeight: 8,
                borderRadius: const BorderRadius.all(Radius.circular(99)),
              ),
              const SizedBox(height: 8),
              Text('${profile.completionPercent}% complete',
                  style: const TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w800,
                      fontSize: 11)),
              const SizedBox(height: 10),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      color: AppColors.green, size: 15),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Auto CV sync + smart recommendations active',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
          final action = FilledButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.jobSeekerProfile),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Complete profile'),
          );
          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [copy, const SizedBox(height: 18), action])
              : Row(children: [
                  Expanded(child: copy),
                  const SizedBox(width: 28),
                  action
                ]);
        },
      ),
    );
  }
}

class _RecentApplications extends StatelessWidget {
  const _RecentApplications({required this.controller});

  final JobSeekerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderMuted)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(
                child: Text('Recent applications',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
            TextButton(
                onPressed: () => Navigator.pushNamed(
                    context, AppRoutes.jobSeekerApplications),
                child: const Text('View all')),
          ]),
          const SizedBox(height: 10),
          if (controller.applications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                  'No applications yet. Your submitted roles will appear here.',
                  style: TextStyle(color: AppColors.textMuted)),
            )
          else
            for (final application in controller.applications.take(3)) ...[
              _RecentApplicationRow(application: application),
              if (application != controller.applications.take(3).last)
                const Divider(height: 24),
            ],
        ],
      ),
    );
  }
}

class _RecentApplicationRow extends StatelessWidget {
  const _RecentApplicationRow({required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    final job = PublicPortalController.instance.jobById(application.jobId) ??
        application.toJobSnapshot();
    return InkWell(
      onTap: () => Navigator.pushNamed(
          context, AppRoutes.jobSeekerApplicationDetails(application.id)),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          CompanyLogo(
            companyId: job.companyId,
            companyName: job.companyName,
            size: 38,
            borderRadius: 11,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(height: 4),
                Text(job.companyName,
                    style: const TextStyle(
                        color: AppColors.textSubtle, fontSize: 10)),
              ])),
          const SizedBox(width: 10),
          ApplicationStatusBadge(status: application.status),
        ]),
      ),
    );
  }
}

class _QuickActivity extends StatelessWidget {
  const _QuickActivity({required this.controller});

  final JobSeekerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderMuted)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Quick actions',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 14),
        _QuickAction(
            icon: Icons.description_outlined,
            label: 'Update CV',
            note: '${controller.cvProfile!.sectionCount}/6 optional sections',
            route: AppRoutes.jobSeekerCvBuilder),
        const SizedBox(height: 10),
        _QuickAction(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            note: '${controller.unreadNotificationCount} unread',
            route: AppRoutes.jobSeekerNotifications),
        const SizedBox(height: 10),
        const _QuickAction(
            icon: Icons.search_rounded,
            label: 'Find jobs',
            note: 'Browse verified roles',
            route: AppRoutes.jobs),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.note,
      required this.route});

  final IconData icon;
  final String label;
  final String note;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.page,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderMuted)),
        child: Row(children: [
          Icon(icon, color: AppColors.blue, size: 20),
          const SizedBox(width: 11),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(height: 3),
                Text(note,
                    style: const TextStyle(
                        color: AppColors.textSubtle, fontSize: 9)),
              ])),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.textSubtle, size: 13),
        ]),
      ),
    );
  }
}

class _CompactJobCard extends StatelessWidget {
  const _CompactJobCard({
    required this.title,
    required this.companyId,
    required this.companyName,
    required this.meta,
    required this.salary,
    required this.matchScore,
    required this.matchReason,
    required this.saved,
    required this.onSave,
    required this.onTap,
  });

  final String title;
  final String companyId;
  final String companyName;
  final String meta;
  final String salary;
  final int matchScore;
  final String matchReason;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderMuted),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CompanyLogo(
                  companyId: companyId,
                  companyName: companyName,
                  size: 44,
                  borderRadius: 13,
                ),
                const Spacer(),
                IconButton(
                  onPressed: onSave,
                  tooltip: saved ? 'Remove saved job' : 'Save job',
                  icon: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: saved ? AppColors.blue : AppColors.textMuted,
                      size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (matchScore > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: AppColors.green.withValues(alpha: .24)),
                ),
                child: Text(
                  '$matchScore% CV match',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (matchReason.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  matchReason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 9,
                  ),
                ),
              ],
              const SizedBox(height: 10),
            ] else
              const SizedBox(height: 4),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 5),
            Text(companyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 14),
            Text(meta,
                style:
                    const TextStyle(color: AppColors.textSubtle, fontSize: 11)),
            const SizedBox(height: 9),
            Text(salary,
                style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
