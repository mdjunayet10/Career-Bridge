import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/employer_job_status.dart';
import '../../../../core/enums/employer_verification_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../employer/data/models/employer_job_model.dart';
import '../../../employer/presentation/widgets/employer_job_status_badge.dart';
import '../../controllers/admin_workspace_controller.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_page_components.dart';
import '../widgets/admin_workspace_gate.dart';

class JobApprovalPage extends StatefulWidget {
  const JobApprovalPage({super.key});

  @override
  State<JobApprovalPage> createState() => _JobApprovalPageState();
}

class _JobApprovalPageState extends State<JobApprovalPage> {
  final searchController = TextEditingController();
  EmployerJobStatus? statusFilter = EmployerJobStatus.pending;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminWorkspaceGate(
      builder: (context, controller) {
        final query = searchController.text.trim().toLowerCase();
        final jobs = controller.jobs.where((job) {
          final companyName = controller.companyNameForJob(job);
          final matchesQuery = query.isEmpty ||
              job.title.toLowerCase().contains(query) ||
              job.categoryId.toLowerCase().contains(query) ||
              companyName.toLowerCase().contains(query) ||
              job.location.toLowerCase().contains(query);
          final matchesStatus =
              statusFilter == null || job.status == statusFilter;
          return matchesQuery && matchesStatus;
        }).toList();

        return DashboardShell(
          role: UserRole.admin,
          title: 'Job approvals',
          subtitle:
              'Review job quality, salary clarity, requirements, and company eligibility before publishing.',
          items: AdminNavigation.items,
          selectedIndex: 2,
          accent: AppColors.red,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${controller.publishedJobCount} published · ${controller.pendingJobCount} pending · ${controller.jobs.length} total (all statuses)',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              _Toolbar(
                searchController: searchController,
                statusFilter: statusFilter,
                onSearch: (_) => setState(() {}),
                onStatus: (value) => setState(() => statusFilter = value),
              ),
              const SizedBox(height: 18),
              if (jobs.isEmpty)
                const AdminEmptyState(
                  title: 'No jobs match this view',
                  message: 'Try another search or moderation status.',
                  icon: Icons.fact_check_outlined,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 980 ? 2 : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 16) / columns;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final job in jobs)
                          SizedBox(
                            width: width,
                            child: _JobReviewCard(
                              job: job,
                              companyName: controller.companyNameForJob(job),
                              logoFileId: controller
                                      .companyById(job.companyId)
                                      ?.logoFileId ??
                                  '',
                              companyApproved: controller
                                          .companyById(job.companyId)
                                          ?.status ==
                                      EmployerVerificationStatus.approved &&
                                  (controller
                                          .companyById(job.companyId)
                                          ?.isActive ??
                                      false),
                              saving: controller.isSaving,
                              onDetails: () =>
                                  _showDetails(context, controller, job),
                              onApprove: () => _review(context, controller, job,
                                  EmployerJobStatus.published),
                              onReject: () => _review(context, controller, job,
                                  EmployerJobStatus.rejected),
                              onSuspend: () => _review(context, controller, job,
                                  EmployerJobStatus.closed),
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

  Future<void> _review(
    BuildContext context,
    AdminWorkspaceController controller,
    EmployerJobModel job,
    EmployerJobStatus status,
  ) async {
    final company = controller.companyById(job.companyId);
    if (status == EmployerJobStatus.published &&
        (company == null ||
            company.status != EmployerVerificationStatus.approved ||
            !company.isActive)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Approve and activate the company before publishing this job.')),
      );
      return;
    }

    final approving = status == EmployerJobStatus.published;
    final suspending = status == EmployerJobStatus.closed;
    final note = await showAdminNoteDialog(
      context,
      title: approving
          ? 'Publish this job?'
          : suspending
              ? 'Suspend this job?'
              : 'Return this job for changes?',
      message: approving
          ? '“${job.title}” will become visible to Job Seekers immediately.'
          : suspending
              ? 'The listing will be removed from public search and marked closed.'
              : 'The Employer will receive the decision note and can edit the listing before resubmitting.',
      confirmLabel: approving
          ? 'Approve and publish'
          : suspending
              ? 'Suspend job'
              : 'Request changes',
      noteRequired: !approving,
      initialValue: approving
          ? 'Job content, salary, and requirements meet Career Bridge standards.'
          : '',
      confirmColor: approving ? AppColors.green : AppColors.red,
    );
    if (note == null) return;
    try {
      await controller.reviewJob(job: job, status: status, note: note);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approving
                  ? 'Job approved and published.'
                  : suspending
                      ? 'Job suspended.'
                      : 'Job returned for changes.',
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _showDetails(
    BuildContext context,
    AdminWorkspaceController controller,
    EmployerJobModel job,
  ) async {
    final company = controller.companyById(job.companyId);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            CompanyLogo(
              companyId: job.companyId,
              companyName: controller.companyNameForJob(job),
              logoFileId: company?.logoFileId ?? '',
              size: 42,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(job.title)),
          ],
        ),
        content: SizedBox(
          width: 700,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      EmployerJobStatusBadge(status: job.status),
                      Text(controller.companyNameForJob(job),
                          style: const TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700))
                    ]),
                if (company == null ||
                    company.status != EmployerVerificationStatus.approved ||
                    !company.isActive) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.yellow.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.yellow.withValues(alpha: .24))),
                    child: const Row(children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.yellow),
                      SizedBox(width: 10),
                      Expanded(
                          child: Text(
                              'This company is not currently approved and active. The job cannot be published yet.',
                              style: TextStyle(
                                  color: AppColors.textSecondary, height: 1.4)))
                    ]),
                  ),
                ],
                const SizedBox(height: 18),
                _Detail(label: 'Category', value: job.categoryId),
                _Detail(
                    label: 'Location & work style',
                    value: '${job.location} · ${job.workMode}'),
                _Detail(
                    label: 'Employment',
                    value: '${job.employmentType} · ${job.experienceLevel}'),
                _Detail(label: 'Salary', value: job.salaryLabel),
                _Detail(
                    label: 'Application deadline',
                    value: compactDate(job.deadline)),
                _Detail(label: 'Description', value: job.description),
                _ListDetail(
                    label: 'Responsibilities', values: job.responsibilities),
                _ListDetail(label: 'Requirements', values: job.requirements),
                _ListDetail(label: 'Skills', values: job.skills),
                _ListDetail(label: 'Benefits', values: job.benefits),
                if (job.rejectionNote?.trim().isNotEmpty == true)
                  _Detail(
                      label: 'Previous moderation note',
                      value: job.rejectionNote!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close')),
          if (job.status == EmployerJobStatus.pending) ...[
            OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _review(context, controller, job, EmployerJobStatus.rejected);
              },
              child: const Text('Request changes'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _review(context, controller, job, EmployerJobStatus.published);
              },
              child: const Text('Approve'),
            ),
          ] else if (job.status == EmployerJobStatus.published)
            FilledButton.tonal(
              onPressed: () {
                Navigator.pop(dialogContext);
                _review(context, controller, job, EmployerJobStatus.closed);
              },
              child: const Text('Suspend listing'),
            ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.searchController,
    required this.statusFilter,
    required this.onSearch,
    required this.onStatus,
  });

  final TextEditingController searchController;
  final EmployerJobStatus? statusFilter;
  final ValueChanged<String> onSearch;
  final ValueChanged<EmployerJobStatus?> onStatus;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = TextField(
          controller: searchController,
          onChanged: onSearch,
          decoration: const InputDecoration(
            hintText: 'Search job, company, category, or location',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        );
        final filter = DropdownButtonFormField<EmployerJobStatus?>(
          isExpanded: true,
          initialValue: statusFilter,
          decoration: const InputDecoration(labelText: 'Status'),
          items: [
            const DropdownMenuItem<EmployerJobStatus?>(
                value: null, child: Text('All statuses')),
            ...EmployerJobStatus.values.map((status) =>
                DropdownMenuItem<EmployerJobStatus?>(
                    value: status, child: Text(status.label))),
          ],
          onChanged: onStatus,
        );
        if (constraints.maxWidth >= 760) {
          return Row(children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            SizedBox(width: 220, child: filter)
          ]);
        }
        return Column(children: [search, const SizedBox(height: 12), filter]);
      },
    );
  }
}

class _JobReviewCard extends StatelessWidget {
  const _JobReviewCard({
    required this.job,
    required this.companyName,
    required this.logoFileId,
    required this.companyApproved,
    required this.saving,
    required this.onDetails,
    required this.onApprove,
    required this.onReject,
    required this.onSuspend,
  });

  final EmployerJobModel job;
  final String companyName;
  final String logoFileId;
  final bool companyApproved;
  final bool saving;
  final VoidCallback onDetails;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSuspend;

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyLogo(
                companyId: job.companyId,
                companyName: companyName,
                logoFileId: logoFileId,
                size: 50,
                borderRadius: 15,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('$companyName · ${job.location}',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
              EmployerJobStatusBadge(status: job.status),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(text: job.categoryId),
              _Chip(text: job.workMode),
              _Chip(text: job.employmentType),
              _Chip(text: job.salaryLabel),
            ],
          ),
          if (!companyApproved && job.status == EmployerJobStatus.pending) ...[
            const SizedBox(height: 13),
            const Text('Company approval required before publication.',
                style: TextStyle(
                    color: AppColors.yellow,
                    fontWeight: FontWeight.w700,
                    fontSize: 10)),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton(
                  onPressed: onDetails, child: const Text('Review listing')),
              if (job.status == EmployerJobStatus.pending) ...[
                IconButton(
                    onPressed: saving ? null : onReject,
                    tooltip: 'Request changes',
                    icon: const Icon(Icons.edit_note_rounded,
                        color: AppColors.red)),
                FilledButton.icon(
                  onPressed: saving || !companyApproved ? null : onApprove,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Approve'),
                ),
              ] else if (job.status == EmployerJobStatus.published) ...[
                FilledButton.tonalIcon(
                  onPressed: saving ? null : onSuspend,
                  icon: const Icon(Icons.block_outlined, size: 18),
                  label: const Text('Suspend'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.mutedSurface,
          borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSubtle,
                fontSize: 10,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value,
            style:
                const TextStyle(color: AppColors.textSecondary, height: 1.45))
      ]),
    );
  }
}

class _ListDetail extends StatelessWidget {
  const _ListDetail({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSubtle,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          for (final value in values)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('•  ', style: TextStyle(color: AppColors.purple)),
                Expanded(
                    child: Text(value,
                        style: const TextStyle(
                            color: AppColors.textSecondary, height: 1.4)))
              ]),
            ),
        ],
      ),
    );
  }
}
