import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/application_status.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../applications/data/models/application_model.dart';
import '../widgets/employer_navigation.dart';
import '../widgets/employer_workspace_gate.dart';

class InterviewsPage extends StatelessWidget {
  const InterviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EmployerWorkspaceGate(
      builder: (context, controller) {
        final interviews = controller.applications
            .where((item) => item.status == ApplicationStatus.interview)
            .toList()
          ..sort((a, b) {
            final aDate = a.interviewAt ?? DateTime(9999);
            final bDate = b.interviewAt ?? DateTime(9999);
            return aDate.compareTo(bDate);
          });
        return DashboardShell(
          role: UserRole.employer,
          title: 'Interviews',
          subtitle:
              'Keep scheduled conversations visible and open candidate details before each interview.',
          items: EmployerNavigation.items,
          selectedIndex: 5,
          accent: AppColors.purple,
          body: interviews.isEmpty
              ? const _EmptyInterviews()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 850 ? 2 : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 16) / columns;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final interview in interviews)
                          SizedBox(
                            width: width,
                            child: _InterviewCard(
                              interview: interview,
                              jobTitle: controller.jobTitleFor(interview.jobId),
                              onOpen: () => Navigator.pushNamed(
                                context,
                                AppRoutes.employerApplicantDetails(
                                    interview.id),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}

class _InterviewCard extends StatelessWidget {
  const _InterviewCard(
      {required this.interview, required this.jobTitle, required this.onOpen});

  final ApplicationModel interview;
  final String jobTitle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final date = interview.interviewAt;
    final name = interview.applicantName.isEmpty
        ? 'Career Bridge candidate'
        : interview.applicantName;
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
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.event_available_outlined,
                    color: AppColors.yellow),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 5),
                    Text(jobTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.input,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderMuted),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    color: AppColors.yellow, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    date == null
                        ? 'Schedule not set'
                        : '${date.day}/${date.month}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          if (interview.employerNote?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Text(
              interview.employerNote!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textMuted, height: 1.45, fontSize: 11),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.person_search_outlined),
              label: const Text('Open candidate'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInterviews extends StatelessWidget {
  const _EmptyInterviews();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(46),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy_outlined,
              size: 54, color: AppColors.textSubtle),
          SizedBox(height: 14),
          Text('No interviews scheduled',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          SizedBox(height: 6),
          Text(
              'Move a shortlisted candidate to the Interview stage to add a schedule.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
