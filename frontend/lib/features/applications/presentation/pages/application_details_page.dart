import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/application_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../job_seeker/controllers/job_seeker_workspace_controller.dart';
import '../../../job_seeker/presentation/widgets/job_seeker_navigation.dart';
import '../../../job_seeker/presentation/widgets/job_seeker_workspace_gate.dart';
import '../../../public_portal/controllers/public_portal_controller.dart';
import '../../data/models/application_model.dart';
import '../widgets/application_status_badge.dart';

class ApplicationDetailsPage extends StatelessWidget {
  const ApplicationDetailsPage({required this.applicationId, super.key});

  final String applicationId;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      role: UserRole.jobSeeker,
      title: 'Application details',
      subtitle:
          'Review the submission, employer updates, and every stage in the process.',
      items: JobSeekerNavigation.items,
      selectedIndex: 4,
      body: JobSeekerWorkspaceGate(
        builder: (context, controller) {
          final application = controller.applicationById(applicationId);
          final liveJob = application == null
              ? null
              : PublicPortalController.instance.jobById(application.jobId);
          final job = application == null
              ? null
              : (liveJob ?? application.toJobSnapshot());
          if (application == null || job == null) {
            return EmptyState(
              icon: Icons.assignment_late_outlined,
              title: 'Application not found',
              message:
                  'The application may have been removed or the link is no longer valid.',
              action: FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(
                    context, AppRoutes.jobSeekerApplications),
                child: const Text('Back to applications'),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderMuted),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 650;
                    final copy = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.companyName,
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(job.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            Text(job.location,
                                style: const TextStyle(
                                    color: AppColors.textSubtle, fontSize: 11)),
                            Text(job.employmentType,
                                style: const TextStyle(
                                    color: AppColors.textSubtle, fontSize: 11)),
                            Text(job.salaryLabel,
                                style: const TextStyle(
                                    color: AppColors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    );
                    final actions = Column(
                      crossAxisAlignment: compact
                          ? CrossAxisAlignment.stretch
                          : CrossAxisAlignment.end,
                      children: [
                        ApplicationStatusBadge(status: application.status),
                        const SizedBox(height: 12),
                        if (liveJob != null)
                          OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.jobDetails(job.id)),
                            icon:
                                const Icon(Icons.open_in_new_rounded, size: 17),
                            label: const Text('View job'),
                          )
                        else
                          const Text(
                            'The original listing is no longer public.',
                            style: TextStyle(
                                color: AppColors.textSubtle, fontSize: 11),
                          ),
                      ],
                    );
                    return compact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                copy,
                                const SizedBox(height: 18),
                                actions
                              ])
                        : Row(children: [
                            Expanded(child: copy),
                            const SizedBox(width: 24),
                            actions
                          ]);
                  },
                ),
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 900;
                  final timeline =
                      _ApplicationTimeline(status: application.status);
                  final details = _SubmissionDetails(application: application);
                  return desktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Expanded(flex: 6, child: timeline),
                              const SizedBox(width: 18),
                              Expanded(flex: 4, child: details)
                            ])
                      : Column(children: [
                          timeline,
                          const SizedBox(height: 18),
                          details
                        ]);
                },
              ),
              if (application.canWithdraw) ...[
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        _confirmWithdrawal(context, controller, application),
                    icon: const Icon(Icons.undo_rounded, color: AppColors.red),
                    label: const Text('Withdraw application',
                        style: TextStyle(color: AppColors.red)),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmWithdrawal(
      BuildContext context,
      JobSeekerWorkspaceController controller,
      ApplicationModel application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: const Text('Withdraw this application?'),
        content: const Text(
          'The employer will no longer consider this submission. This action cannot be reversed from the Job Seeker workspace.',
          style: TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep application')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.withdrawApplication(application);
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.jobSeekerApplications);
    }
  }
}

class _ApplicationTimeline extends StatelessWidget {
  const _ApplicationTimeline({required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        'Application submitted',
        'Your profile and CV were sent to the employer.'
      ),
      (
        'Employer review',
        'The hiring team reviews your experience and skills.'
      ),
      ('Shortlisted', 'Selected candidates move to the next assessment stage.'),
      ('Interview', 'Interview date and instructions appear in notifications.'),
      ('Final decision', 'The employer records the final hiring decision.'),
    ];
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Application timeline',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(height: 22),
          for (var index = 0; index < steps.length; index++)
            _TimelineStep(
              index: index,
              title: steps[index].$1,
              description: steps[index].$2,
              active: index < status.progressStep,
              current: index == status.progressStep - 1,
              last: index == steps.length - 1,
            ),
          if (status == ApplicationStatus.rejected ||
              status == ApplicationStatus.withdrawn) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.red.withValues(alpha: .2)),
              ),
              child: Text(
                status == ApplicationStatus.rejected
                    ? 'The employer completed this application without selecting the candidate.'
                    : 'You withdrew this application from consideration.',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11, height: 1.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep(
      {required this.index,
      required this.title,
      required this.description,
      required this.active,
      required this.current,
      required this.last});

  final int index;
  final String title;
  final String description;
  final bool active;
  final bool current;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (current ? AppColors.blue : AppColors.green)
        : AppColors.borderStrong;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: .15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color)),
              child: active
                  ? Icon(Icons.check_rounded, color: color, size: 16)
                  : Text('${index + 1}',
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
            ),
            if (!last)
              Container(
                  width: 1,
                  height: 54,
                  color: active
                      ? color.withValues(alpha: .45)
                      : AppColors.borderMuted),
          ],
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: active
                          ? AppColors.textPrimary
                          : AppColors.textMuted)),
              const SizedBox(height: 5),
              Text(description,
                  style: const TextStyle(
                      color: AppColors.textSubtle, fontSize: 11, height: 1.45)),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SubmissionDetails extends StatelessWidget {
  const _SubmissionDetails({required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Submission details',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(height: 18),
          const Text('Cover letter',
              style: TextStyle(
                  color: AppColors.textSubtle,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
              application.coverLetter.isEmpty
                  ? 'No cover letter was added.'
                  : application.coverLetter,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 12, height: 1.55)),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          _Fact(
            label: 'CV attachment',
            value: application.cvFileId != null
                ? 'Application PDF snapshot secured'
                : application.cvProfileId == null
                    ? 'Not attached'
                    : 'Career Bridge structured CV',
          ),
          _Fact(label: 'Submitted', value: _formatDate(application.createdAt)),
          if (application.interviewAt != null)
            _Fact(
                label: 'Interview',
                value: _formatDate(application.interviewAt!)),
          if (application.employerNote?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(13)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Employer note',
                        style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w800,
                            fontSize: 11)),
                    const SizedBox(height: 6),
                    Text(application.employerNote!,
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            height: 1.45)),
                  ]),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSubtle, fontSize: 10))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
