import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/application_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../data/models/application_model.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../job_seeker/controllers/job_seeker_workspace_controller.dart';
import '../../../job_seeker/presentation/widgets/job_seeker_navigation.dart';
import '../../../job_seeker/presentation/widgets/job_seeker_workspace_gate.dart';
import '../../../public_portal/controllers/public_portal_controller.dart';
import '../widgets/application_status_badge.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({super.key});

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  ApplicationStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      role: UserRole.jobSeeker,
      title: 'Applications',
      subtitle:
          'Track every stage from submission to interview and final decision.',
      items: JobSeekerNavigation.items,
      selectedIndex: 4,
      body: JobSeekerWorkspaceGate(
        builder: (context, controller) {
          final applications = controller.applications
              .where((item) => _filter == null || item.status == _filter)
              .toList(growable: false);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ApplicationSummary(controller: controller),
              const SizedBox(height: 22),
              _FilterBar(
                selected: _filter,
                onChanged: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 18),
              if (applications.isEmpty)
                EmptyState(
                  icon: Icons.assignment_outlined,
                  title: _filter == null
                      ? 'No applications yet'
                      : 'No applications in this stage',
                  message: _filter == null
                      ? 'Apply to a verified role and it will appear here with live status tracking.'
                      : 'Choose another status or clear the filter.',
                  action: _filter == null
                      ? FilledButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.jobs),
                          child: const Text('Browse jobs'),
                        )
                      : OutlinedButton(
                          onPressed: () => setState(() => _filter = null),
                          child: const Text('Clear filter'),
                        ),
                )
              else
                for (var index = 0; index < applications.length; index++) ...[
                  _ApplicationCard(application: applications[index]),
                  if (index != applications.length - 1)
                    const SizedBox(height: 14),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _ApplicationSummary extends StatelessWidget {
  const _ApplicationSummary({required this.controller});

  final JobSeekerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final values = [
      ('Total', '${controller.applications.length}', AppColors.blue),
      ('Active', '${controller.activeApplicationCount}', AppColors.cyan),
      ('Shortlisted', '${controller.shortlistedCount}', AppColors.purple),
      ('Interviews', '${controller.interviewCount}', AppColors.yellow),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in values)
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
                      Text(item.$2,
                          style: TextStyle(
                              color: item.$3,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(item.$1,
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

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final ApplicationStatus? selected;
  final ValueChanged<ApplicationStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          for (final status in ApplicationStatus.values) ...[
            ChoiceChip(
              label: Text(status.label),
              selected: selected == status,
              onSelected: (_) => onChanged(status),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    final job = PublicPortalController.instance.jobById(application.jobId) ??
        application.toJobSnapshot();
    return InkWell(
      onTap: () => Navigator.pushNamed(
          context, AppRoutes.jobSeekerApplicationDetails(application.id)),
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: AppColors.borderMuted),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final leading = CompanyLogo(
              companyId: job.companyId,
              companyName: job.companyName,
              size: 52,
              borderRadius: 15,
            );
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 5),
                Text(job.companyName,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 10),
                Text(
                  'Applied ${_formatDate(application.createdAt)} · Updated ${_formatDate(application.updatedAt)}',
                  style: const TextStyle(
                      color: AppColors.textSubtle, fontSize: 10),
                ),
              ],
            );
            final status = Column(
              crossAxisAlignment:
                  compact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                ApplicationStatusBadge(status: application.status),
                const SizedBox(height: 10),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View timeline',
                        style: TextStyle(
                            color: AppColors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_forward_rounded,
                        color: AppColors.blue, size: 16),
                  ],
                ),
              ],
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    leading,
                    const SizedBox(width: 14),
                    Expanded(child: copy)
                  ]),
                  const SizedBox(height: 16),
                  status,
                ],
              );
            }
            return Row(
              children: [
                leading,
                const SizedBox(width: 15),
                Expanded(child: copy),
                const SizedBox(width: 20),
                status
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
