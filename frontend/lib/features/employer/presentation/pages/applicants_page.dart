import '../widgets/applicant_actions.dart';
import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/application_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../applications/data/models/application_model.dart';
import '../../../applications/presentation/widgets/application_status_badge.dart';
import '../../controllers/employer_workspace_controller.dart';
import '../../data/models/employer_job_model.dart';
import '../widgets/employer_navigation.dart';
import '../widgets/employer_workspace_gate.dart';

class ApplicantsPage extends StatefulWidget {
  const ApplicantsPage({super.key, this.initialJobId});

  final String? initialJobId;

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  final searchController = TextEditingController();
  ApplicationStatus? status;
  String? jobId;

  @override
  void initState() {
    super.initState();
    jobId = widget.initialJobId;
  }

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
        final applications = controller.applications.where((application) {
          final searchable = [
            application.applicantName,
            application.applicantEmail,
            application.applicantHeadline,
            controller.jobTitleFor(application.jobId),
            ...application.applicantSkills,
          ].join(' ').toLowerCase();
          return (query.isEmpty || searchable.contains(query)) &&
              (status == null || application.status == status) &&
              (jobId == null || application.jobId == jobId);
        }).toList();

        return DashboardShell(
          role: UserRole.employer,
          title: 'Applicants',
          subtitle:
              'Review candidate snapshots and move applicants through a transparent recruitment pipeline.',
          items: EmployerNavigation.items,
          selectedIndex: 4,
          accent: AppColors.purple,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ApplicantStats(controller: controller),
              const SizedBox(height: 22),
              _ApplicantFilters(
                searchController: searchController,
                jobs: controller.jobs,
                selectedJobId: jobId,
                selectedStatus: status,
                onChanged: () => setState(() {}),
                onJobChanged: (value) => setState(() => jobId = value),
                onStatusChanged: (value) => setState(() => status = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${applications.length} applicant${applications.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  if (query.isNotEmpty || status != null || jobId != null)
                    TextButton.icon(
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          status = null;
                          jobId = null;
                        });
                      },
                      icon: const Icon(Icons.filter_alt_off_outlined, size: 17),
                      label: const Text('Clear filters'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (applications.isEmpty)
                const _EmptyApplicants()
              else
                Column(
                  children: [
                    for (final application in applications) ...[
                      _ApplicantCard(
                        application: application,
                        controller: controller,
                        jobTitle: controller.jobTitleFor(application.jobId),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.employerApplicantDetails(application.id),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ApplicantStats extends StatelessWidget {
  const _ApplicantStats({required this.controller});

  final EmployerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final data = [
      (
        'Total applications',
        '${controller.applications.length}',
        Icons.inbox_outlined,
        AppColors.blue
      ),
      (
        'Active pipeline',
        '${controller.activeApplicantCount}',
        Icons.track_changes_rounded,
        AppColors.cyan
      ),
      (
        'Shortlisted',
        '${controller.shortlistedCount}',
        Icons.star_outline_rounded,
        AppColors.purple
      ),
      (
        'Interviews',
        '${controller.interviewCount}',
        Icons.event_outlined,
        AppColors.green
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
                ? 2
                : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in data)
              SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderMuted),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.$4.withValues(alpha: .11),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.$3, color: item.$4, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$2,
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text(item.$1,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
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

class _ApplicantFilters extends StatelessWidget {
  const _ApplicantFilters({
    required this.searchController,
    required this.jobs,
    required this.selectedJobId,
    required this.selectedStatus,
    required this.onChanged,
    required this.onJobChanged,
    required this.onStatusChanged,
  });

  final TextEditingController searchController;
  final List<EmployerJobModel> jobs;
  final String? selectedJobId;
  final ApplicationStatus? selectedStatus;
  final VoidCallback onChanged;
  final ValueChanged<String?> onJobChanged;
  final ValueChanged<ApplicationStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      controller: searchController,
      onChanged: (_) => onChanged(),
      decoration: const InputDecoration(
        hintText: 'Search candidate, skill, email, or role',
        prefixIcon: Icon(Icons.search_rounded),
      ),
    );
    final effectiveJobId =
        jobs.any((item) => item.id == selectedJobId) ? selectedJobId : null;
    final job = DropdownButtonFormField<String?>(
      initialValue: effectiveJobId,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Job'),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('All jobs')),
        ...jobs.map(
          (item) => DropdownMenuItem<String?>(
              value: item.id, child: Text(item.title)),
        ),
      ],
      onChanged: onJobChanged,
    );
    final state = DropdownButtonFormField<ApplicationStatus?>(
      initialValue: selectedStatus,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Stage'),
      items: [
        const DropdownMenuItem<ApplicationStatus?>(
            value: null, child: Text('All stages')),
        ...ApplicationStatus.values
            .where((item) => item != ApplicationStatus.withdrawn)
            .map((item) => DropdownMenuItem<ApplicationStatus?>(
                value: item, child: Text(item.label))),
      ],
      onChanged: onStatusChanged,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 850) {
            return Row(
              children: [
                Expanded(flex: 2, child: search),
                const SizedBox(width: 12),
                Expanded(child: job),
                const SizedBox(width: 12),
                Expanded(child: state),
              ],
            );
          }
          if (constraints.maxWidth >= 520) {
            return Column(
              children: [
                search,
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: job),
                  const SizedBox(width: 12),
                  Expanded(child: state)
                ]),
              ],
            );
          }
          return Column(children: [
            search,
            const SizedBox(height: 12),
            job,
            const SizedBox(height: 12),
            state
          ]);
        },
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard(
      {required this.application,
      required this.controller,
      required this.jobTitle,
      required this.onTap});

  final ApplicationModel application;
  final EmployerWorkspaceController controller;
  final String jobTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = application.applicantName.isEmpty
        ? 'Career Bridge candidate'
        : application.applicantName;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderMuted),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 650;
            final identity = Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.purple.withValues(alpha: .14),
                  foregroundColor: AppColors.purple,
                  child: Text(name[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        application.applicantHeadline.isEmpty
                            ? 'Candidate profile'
                            : application.applicantHeadline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final details = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ApplicantMeta(
                    icon: Icons.work_outline_rounded, label: jobTitle),
                if (application.applicantLocation.isNotEmpty)
                  _ApplicantMeta(
                      icon: Icons.location_on_outlined,
                      label: application.applicantLocation),
                _ApplicantMeta(
                    icon: Icons.timeline_rounded,
                    label: '${application.applicantExperienceYears} years'),
              ],
            );
            final actions = ApplicantActions(
                key: ValueKey('applicant-actions-${application.id}'),
                application: application,
                controller: controller);
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  identity,
                  const SizedBox(height: 14),
                  details,
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ApplicationStatusBadge(status: application.status),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.textSubtle),
                    ],
                  ),
                  const SizedBox(height: 14),
                  actions,
                ],
              );
            }
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(flex: 3, child: identity),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: details),
                      const SizedBox(width: 18),
                      ApplicationStatusBadge(status: application.status),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.textSubtle),
                    ],
                  ),
                  const SizedBox(height: 14),
                  actions
                ]);
          },
        ),
      ),
    );
  }
}

class _ApplicantMeta extends StatelessWidget {
  const _ApplicantMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSubtle),
        const SizedBox(width: 5),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ),
      ],
    );
  }
}

class _EmptyApplicants extends StatelessWidget {
  const _EmptyApplicants();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(44),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: const Column(
        children: [
          Icon(Icons.person_search_outlined,
              size: 52, color: AppColors.textSubtle),
          SizedBox(height: 14),
          Text('No matching applicants',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          SizedBox(height: 6),
          Text('Adjust the search, job, or stage filter.',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
