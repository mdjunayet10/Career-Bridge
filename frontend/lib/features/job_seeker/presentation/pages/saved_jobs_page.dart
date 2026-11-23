import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../public_portal/controllers/public_portal_controller.dart';
import '../../../jobs/data/models/job_model.dart';
import '../../../jobs/presentation/widgets/public_job_card.dart';
import '../../controllers/job_seeker_workspace_controller.dart';
import '../widgets/job_seeker_navigation.dart';
import '../widgets/job_seeker_workspace_gate.dart';

class SavedJobsPage extends StatelessWidget {
  const SavedJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      role: UserRole.jobSeeker,
      title: 'Saved jobs',
      subtitle:
          'Keep promising opportunities together and return before their deadlines.',
      items: JobSeekerNavigation.items,
      selectedIndex: 2,
      body: JobSeekerWorkspaceGate(
        builder: (context, controller) =>
            _SavedJobsContent(controller: controller),
      ),
    );
  }
}

class _SavedJobsContent extends StatelessWidget {
  const _SavedJobsContent({required this.controller});

  final JobSeekerWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final jobs = controller.savedJobIds
        .map(PublicPortalController.instance.jobById)
        .whereType<JobModel>()
        .toList(growable: false);

    if (jobs.isEmpty) {
      return EmptyState(
        icon: Icons.bookmark_add_outlined,
        title: 'No saved jobs yet',
        message:
            'Save roles from the job listing or job details page to build a focused shortlist.',
        action: FilledButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.jobs),
          icon: const Icon(Icons.search_rounded),
          label: const Text('Find jobs'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.blueStrong.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.blue.withValues(alpha: .2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bookmark_rounded, color: AppColors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${jobs.length} saved opportunit${jobs.length == 1 ? 'y' : 'ies'}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.jobs),
                child: const Text('Browse more'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final job in jobs)
                  SizedBox(
                    width: width,
                    child: PublicJobCard(
                      job: job,
                      isSaved: true,
                      onSave: (_) => controller.toggleSavedJob(job.id),
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
