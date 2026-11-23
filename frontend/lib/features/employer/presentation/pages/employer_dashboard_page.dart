import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/application_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../../shared/widgets/dashboard_stat_card.dart';
import '../../../applications/presentation/widgets/application_status_badge.dart';
import '../../controllers/employer_workspace_controller.dart';
import '../widgets/employer_job_status_badge.dart';
import '../widgets/employer_navigation.dart';
import '../widgets/employer_workspace_gate.dart';

class EmployerDashboardPage extends StatelessWidget {
  const EmployerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EmployerWorkspaceGate(
      builder: (context, controller) {
        final company = controller.company!;
        return DashboardShell(
          role: UserRole.employer,
          title: company.name,
          subtitle:
              'Manage jobs, candidates, interviews, and your verified company profile from one workspace.',
          items: EmployerNavigation.items,
          selectedIndex: 0,
          accent: AppColors.purple,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompanyIdentityBanner(controller: controller),
              const SizedBox(height: 24),
              _EmployerStats(controller: controller),
              const SizedBox(height: 28),
              _QuickActions(controller: controller),
              const SizedBox(height: 32),
              _SectionHeader(
                title: 'Recruitment pipeline',
                actionLabel: 'View applicants',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.employerApplicants),
              ),
              const SizedBox(height: 14),
              _Pipeline(controller: controller),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 860;
                  final jobs = _RecentJobs(controller: controller);
                  final candidates = _RecentCandidates(controller: controller);
                  if (!wide) {
                    return Column(children: [
                      jobs,
                      const SizedBox(height: 20),
                      candidates
                    ]);
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: jobs),
                      const SizedBox(width: 20),
                      Expanded(child: candidates),
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

class _EmployerStats extends StatelessWidget {
  const _EmployerStats({required this.controller});

  final EmployerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      DashboardStatCard(
        label: 'Live jobs',
        value: '${controller.liveJobCount}',
        icon: Icons.work_outline_rounded,
        accent: AppColors.blue,
        note: '${controller.pendingJobCount} pending review',
      ),
      DashboardStatCard(
        label: 'Active applicants',
        value: '${controller.activeApplicantCount}',
        icon: Icons.groups_2_outlined,
        accent: AppColors.purple,
        note: '${controller.applications.length} total',
      ),
      DashboardStatCard(
        label: 'Shortlisted',
        value: '${controller.shortlistedCount}',
        icon: Icons.star_outline_rounded,
        accent: AppColors.cyan,
      ),
      DashboardStatCard(
        label: 'Interviews',
        value: '${controller.interviewCount}',
        icon: Icons.event_available_outlined,
        accent: AppColors.green,
        note: '${controller.hiredCount} hired',
      ),
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

class _CompanyIdentityBanner extends StatelessWidget {
  const _CompanyIdentityBanner({required this.controller});

  final EmployerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final company = controller.company!;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.purple.withValues(alpha: .24)),
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: .09),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final identity = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyLogo(
                companyId: company.id,
                companyName: company.name,
                logoFileId: company.logoFileId,
                size: compact ? 64 : 72,
                borderRadius: 20,
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            company.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.green,
                          size: 19,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${company.industry} · ${company.companySize}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: company.completionPercent / 100,
                              minHeight: 7,
                              backgroundColor: AppColors.input,
                              color: AppColors.purple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${company.completionPercent}%',
                          style: const TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.employerCompanyProfile,
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit company'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.employerPostJob,
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Post a job'),
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [identity, const SizedBox(height: 18), actions],
            );
          }
          return Row(
            children: [
              Expanded(child: identity),
              const SizedBox(width: 24),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.controller});

  final EmployerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        'Post a job',
        'Create a draft or submit it for review.',
        Icons.add_circle_outline_rounded,
        AppColors.blue,
        AppRoutes.employerPostJob
      ),
      (
        'Review applicants',
        'Move candidates through your hiring pipeline.',
        Icons.groups_2_outlined,
        AppColors.purple,
        AppRoutes.employerApplicants
      ),
      (
        'Schedule interviews',
        'See and manage upcoming interviews.',
        Icons.event_outlined,
        AppColors.green,
        AppRoutes.employerInterviews
      ),
      (
        'Update company',
        'Keep employer information accurate.',
        Icons.apartment_rounded,
        AppColors.cyan,
        AppRoutes.employerCompanyProfile
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 540
                ? 2
                : 1;
        final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final action in actions)
              SizedBox(
                width: width,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.pushNamed(context, action.$5),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderMuted),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: action.$4.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(action.$3, color: action.$4),
                        ),
                        const SizedBox(height: 16),
                        Text(action.$1,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(action.$2,
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                height: 1.45,
                                fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Pipeline extends StatelessWidget {
  const _Pipeline({required this.controller});

  final EmployerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final stages = [
      ('Applied', ApplicationStatus.applied, AppColors.blue),
      ('Reviewed', ApplicationStatus.reviewed, AppColors.cyan),
      ('Shortlisted', ApplicationStatus.shortlisted, AppColors.purple),
      ('Interview', ApplicationStatus.interview, AppColors.yellow),
      ('Hired', ApplicationStatus.hired, AppColors.green),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 5
            : constraints.maxWidth >= 520
                ? 2
                : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final stage in stages)
              SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: AppColors.borderMuted),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: stage.$3, shape: BoxShape.circle)),
                      const SizedBox(height: 16),
                      Text(
                        '${controller.applications.where((item) => item.status == stage.$2).length}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 25),
                      ),
                      const SizedBox(height: 4),
                      Text(stage.$1,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RecentJobs extends StatelessWidget {
  const _RecentJobs({required this.controller});

  final EmployerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final jobs = controller.jobs.take(4).toList();
    return _Panel(
      title: 'Recent jobs',
      actionLabel: 'Manage all',
      onAction: () =>
          Navigator.pushNamed(context, AppRoutes.employerManageJobs),
      child: jobs.isEmpty
          ? const _EmptyMessage(
              icon: Icons.work_off_outlined, message: 'No jobs created yet.')
          : Column(
              children: [
                for (var index = 0; index < jobs.length; index++) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.employerEditJob(jobs[index].id)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.work_outline_rounded,
                                color: AppColors.blue, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(jobs[index].title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                    '${controller.applicantCountFor(jobs[index].id)} applicants · ${jobs[index].location}',
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          EmployerJobStatusBadge(status: jobs[index].status),
                        ],
                      ),
                    ),
                  ),
                  if (index != jobs.length - 1) const Divider(height: 1),
                ],
              ],
            ),
    );
  }
}

class _RecentCandidates extends StatelessWidget {
  const _RecentCandidates({required this.controller});

  final EmployerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final applications = controller.applications.take(4).toList();
    return _Panel(
      title: 'Recent candidates',
      actionLabel: 'View all',
      onAction: () =>
          Navigator.pushNamed(context, AppRoutes.employerApplicants),
      child: applications.isEmpty
          ? const _EmptyMessage(
              icon: Icons.person_search_outlined,
              message: 'No applications received yet.')
          : Column(
              children: [
                for (var index = 0; index < applications.length; index++) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.employerApplicantDetails(
                          applications[index].id),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 21,
                            backgroundColor:
                                AppColors.purple.withValues(alpha: .13),
                            foregroundColor: AppColors.purple,
                            child: Text(
                              applications[index].applicantName.isEmpty
                                  ? 'C'
                                  : applications[index]
                                      .applicantName[0]
                                      .toUpperCase(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(applications[index].applicantName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                    controller
                                        .jobTitleFor(applications[index].jobId),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ApplicationStatusBadge(
                              status: applications[index].status),
                        ],
                      ),
                    ),
                  ),
                  if (index != applications.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel(
      {required this.title,
      required this.actionLabel,
      required this.onAction,
      required this.child});

  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16))),
              TextButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title,
      required this.actionLabel,
      required this.onPressed});

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800))),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.textSubtle),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
