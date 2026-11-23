import '../widgets/applicant_actions.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../applications/data/models/application_model.dart';
import '../../../applications/presentation/widgets/application_status_badge.dart';
import '../../../file_storage/controllers/file_storage_controller.dart';
import '../../controllers/employer_workspace_controller.dart';
import '../widgets/employer_navigation.dart';
import '../widgets/employer_workspace_gate.dart';

class ApplicantDetailsPage extends StatelessWidget {
  const ApplicantDetailsPage({required this.applicationId, super.key});

  final String applicationId;

  @override
  Widget build(BuildContext context) {
    return EmployerWorkspaceGate(
      builder: (context, controller) {
        final application = controller.applicationById(applicationId);
        return DashboardShell(
          role: UserRole.employer,
          title: application?.applicantName.isNotEmpty == true
              ? application!.applicantName
              : 'Applicant details',
          subtitle: application == null
              ? 'This application could not be found.'
              : '${controller.jobTitleFor(application.jobId)} · Candidate application review',
          items: EmployerNavigation.items,
          selectedIndex: 4,
          accent: AppColors.purple,
          body: application == null
              ? const _MissingApplication()
              : _ApplicantDetails(
                  controller: controller, application: application),
        );
      },
    );
  }
}

class _ApplicantDetails extends StatelessWidget {
  const _ApplicantDetails(
      {required this.controller, required this.application});

  final EmployerWorkspaceController controller;
  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final main = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CandidateHeader(application: application),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Candidate snapshot',
              child: Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _InfoTile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: application.applicantEmail.isEmpty
                          ? 'Not shared'
                          : application.applicantEmail),
                  _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: application.applicantLocation.isEmpty
                          ? 'Not shared'
                          : application.applicantLocation),
                  _InfoTile(
                      icon: Icons.timeline_rounded,
                      label: 'Experience',
                      value: '${application.applicantExperienceYears} years'),
                  _InfoTile(
                    icon: Icons.description_outlined,
                    label: 'CV',
                    value: application.cvFileId != null
                        ? 'PDF snapshot attached'
                        : application.cvProfileId == null
                            ? 'Not attached'
                            : 'Structured CV attached',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Skills',
              child: application.applicantSkills.isEmpty
                  ? const Text(
                      'No skills were included in the application snapshot.',
                      style: TextStyle(color: AppColors.textMuted))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final skill in application.applicantSkills)
                          _SkillChip(label: skill)
                      ],
                    ),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Cover letter',
              child: Text(
                application.coverLetter.trim().isEmpty
                    ? 'No cover letter was provided.'
                    : application.coverLetter,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.65),
              ),
            ),
            if (application.employerNote?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 18),
              _InfoCard(
                title: 'Internal employer note',
                child: Text(application.employerNote!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, height: 1.55)),
              ),
            ],
          ],
        );
        final side =
            _DecisionPanel(controller: controller, application: application);

        if (!wide) {
          return Column(children: [main, const SizedBox(height: 20), side]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: main),
            const SizedBox(width: 20),
            Expanded(flex: 3, child: side),
          ],
        );
      },
    );
  }
}

class _CandidateHeader extends StatelessWidget {
  const _CandidateHeader({required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    final name = application.applicantName.isEmpty
        ? 'Career Bridge candidate'
        : application.applicantName;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.purple.withValues(alpha: .14),
            foregroundColor: AppColors.purple,
            child: Text(name[0].toUpperCase(),
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 20))),
                    ApplicationStatusBadge(status: application.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  application.applicantHeadline.isEmpty
                      ? 'Candidate profile'
                      : application.applicantHeadline,
                  style:
                      const TextStyle(color: AppColors.textMuted, height: 1.45),
                ),
                const SizedBox(height: 12),
                Text(
                  'Applied ${application.createdAt.day}/${application.createdAt.month}/${application.createdAt.year}',
                  style: const TextStyle(
                      color: AppColors.textSubtle, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionPanel extends StatelessWidget {
  const _DecisionPanel({required this.controller, required this.application});

  final EmployerWorkspaceController controller;
  final ApplicationModel application;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Recruitment action',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 6),
          const Text(
            'Choose an action below. The candidate receives the updated stage and interview details.',
            style: TextStyle(
                color: AppColors.textMuted, height: 1.5, fontSize: 11),
          ),
          const SizedBox(height: 18),
          _StageRow(
              label: 'Current stage',
              child: ApplicationStatusBadge(status: application.status)),
          if (application.interviewAt != null) ...[
            const SizedBox(height: 12),
            _StageRow(
              label: 'Interview',
              child: Text(
                '${application.interviewAt!.day}/${application.interviewAt!.month}/${application.interviewAt!.year} · ${application.interviewAt!.hour.toString().padLeft(2, '0')}:${application.interviewAt!.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                    color: AppColors.yellow,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
          const SizedBox(height: 20),
          ApplicantActions(
              key: ValueKey('applicant-actions-${application.id}'),
              application: application,
              controller: controller),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed:
                application.cvFileId == null ? null : () => _openCv(context),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Open CV PDF'),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const Text('Privacy note',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(height: 6),
          const Text(
            'Only the candidate information shared with this application is visible in the employer workspace.',
            style: TextStyle(
                color: AppColors.textSubtle, height: 1.45, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Future<void> _openCv(BuildContext context) async {
    final fileId = application.cvFileId;
    if (fileId == null) return;
    try {
      final safeName =
          application.applicantName.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      await FileStorageController.instance.sharePdf(
        fileId: fileId,
        fileName: '${safeName}_CV.pdf',
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 300),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: AppColors.blue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSubtle, fontSize: 9)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.purple.withValues(alpha: .22)),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.purple,
              fontWeight: FontWeight.w700,
              fontSize: 10)),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 10))),
        child,
      ],
    );
  }
}

class _MissingApplication extends StatelessWidget {
  const _MissingApplication();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(42),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 50, color: AppColors.textSubtle),
          SizedBox(height: 14),
          Text('Application not found',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          SizedBox(height: 6),
          Text(
              'It may have been removed or is not part of this employer workspace.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
