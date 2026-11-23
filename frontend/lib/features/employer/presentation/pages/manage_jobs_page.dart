import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/employer_job_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../controllers/employer_workspace_controller.dart';
import '../../data/models/employer_job_model.dart';
import '../widgets/employer_job_status_badge.dart';
import '../widgets/employer_navigation.dart';
import '../widgets/employer_workspace_gate.dart';

class ManageJobsPage extends StatefulWidget {
  const ManageJobsPage({super.key});

  @override
  State<ManageJobsPage> createState() => _ManageJobsPageState();
}

class _ManageJobsPageState extends State<ManageJobsPage> {
  final searchController = TextEditingController();
  EmployerJobStatus? statusFilter;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmployerWorkspaceGate(
      builder: (context, controller) {
        final query = searchController.text.trim().toLowerCase();
        final jobs = controller.jobs.where((job) {
          final matchesQuery = query.isEmpty ||
              job.title.toLowerCase().contains(query) ||
              job.location.toLowerCase().contains(query) ||
              job.categoryId.toLowerCase().contains(query);
          final matchesStatus =
              statusFilter == null || job.status == statusFilter;
          return matchesQuery && matchesStatus;
        }).toList();

        return DashboardShell(
          role: UserRole.employer,
          title: 'Manage jobs',
          subtitle:
              'Review performance, edit drafts, track approval status, and close completed recruitment.',
          items: EmployerNavigation.items,
          selectedIndex: 2,
          accent: AppColors.purple,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Toolbar(
                searchController: searchController,
                statusFilter: statusFilter,
                onSearchChanged: (_) => setState(() {}),
                onStatusChanged: (value) =>
                    setState(() => statusFilter = value),
                onPostJob: () =>
                    Navigator.pushNamed(context, AppRoutes.employerPostJob),
              ),
              const SizedBox(height: 20),
              if (jobs.isEmpty)
                const _EmptyJobs()
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 900 ? 2 : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 16) / columns;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final job in jobs)
                          SizedBox(
                            width: width,
                            child: _JobCard(
                              job: job,
                              applicantCount:
                                  controller.applicantCountFor(job.id),
                              isSaving: controller.isSaving,
                              onEdit: () => Navigator.pushNamed(
                                  context, AppRoutes.employerEditJob(job.id)),
                              onApplicants: () => Navigator.pushNamed(
                                context,
                                '${AppRoutes.employerApplicants}?jobId=${Uri.encodeQueryComponent(job.id)}',
                              ),
                              onClose: () =>
                                  _confirmClose(context, controller, job),
                            ),
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

  Future<void> _confirmClose(
    BuildContext context,
    EmployerWorkspaceController controller,
    EmployerJobModel job,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close this job?'),
        content: Text(
            '“${job.title}” will no longer appear as an active opportunity.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Close job')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await controller.closeJob(job);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Job closed.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.searchController,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onPostJob,
  });

  final TextEditingController searchController;
  final EmployerJobStatus? statusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<EmployerJobStatus?> onStatusChanged;
  final VoidCallback onPostJob;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search jobs by title, category, or location',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        );
        final filter = DropdownButtonFormField<EmployerJobStatus?>(
          initialValue: statusFilter,
          decoration: const InputDecoration(labelText: 'Status'),
          items: [
            const DropdownMenuItem<EmployerJobStatus?>(
                value: null, child: Text('All statuses')),
            ...EmployerJobStatus.values.map(
              (status) => DropdownMenuItem<EmployerJobStatus?>(
                  value: status, child: Text(status.label)),
            ),
          ],
          onChanged: onStatusChanged,
        );
        final button = FilledButton.icon(
          onPressed: onPostJob,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Post a job'),
        );
        if (constraints.maxWidth >= 760) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              SizedBox(width: 200, child: filter),
              const SizedBox(width: 12),
              button,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            search,
            const SizedBox(height: 12),
            filter,
            const SizedBox(height: 12),
            button
          ],
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.applicantCount,
    required this.isSaving,
    required this.onEdit,
    required this.onApplicants,
    required this.onClose,
  });

  final EmployerJobModel job;
  final int applicantCount;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onApplicants;
  final VoidCallback onClose;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.work_outline_rounded,
                    color: AppColors.blue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(
                      '${job.location} · ${job.workMode} · ${job.employmentType}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              EmployerJobStatusBadge(status: job.status),
            ],
          ),
          if (job.rejectionNote?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red.withValues(alpha: .22)),
              ),
              child: Text(job.rejectionNote!,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ),
          ],
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Meta(
                  icon: Icons.people_outline_rounded,
                  label: '$applicantCount applicants'),
              _Meta(icon: Icons.payments_outlined, label: job.salaryLabel),
              _Meta(
                  icon: Icons.event_outlined,
                  label:
                      '${job.deadline.day}/${job.deadline.month}/${job.deadline.year}'),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onApplicants,
                icon: const Icon(Icons.groups_2_outlined, size: 18),
                label: const Text('Applicants'),
              ),
              if (job.status != EmployerJobStatus.closed &&
                  job.status != EmployerJobStatus.pending)
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              if (job.status == EmployerJobStatus.published)
                TextButton.icon(
                  onPressed: isSaving ? null : onClose,
                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                  label: const Text('Close'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.input,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSubtle),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _EmptyJobs extends StatelessWidget {
  const _EmptyJobs();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: const Column(
        children: [
          Icon(Icons.work_off_outlined, size: 52, color: AppColors.textSubtle),
          SizedBox(height: 14),
          Text('No matching jobs',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          SizedBox(height: 6),
          Text('Try a different search or status filter.',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
