import '../../../auth/data/demo_account_catalog.dart';
import '../../../reports/report_button.dart';
import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../job_seeker/controllers/job_seeker_workspace_controller.dart';
import '../../../../shared/layouts/public_page_shell.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_container.dart';
import '../../../public_portal/controllers/public_portal_controller.dart';
import '../../data/models/job_model.dart';
import '../widgets/job_meta_chip.dart';
import '../widgets/public_job_card.dart';

class JobDetailsPage extends StatefulWidget {
  const JobDetailsPage({required this.jobId, super.key});

  final String jobId;

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  bool _guestSaved = false;
  final _workspace = JobSeekerWorkspaceController.instance;
  final _portal = PublicPortalController.instance;

  @override
  void initState() {
    super.initState();
    _portal.addListener(_changed);
    _workspace.addListener(_changed);
    if (AuthController.instance.currentUser?.role == UserRole.jobSeeker) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _workspace.ensureLoaded();
        if (mounted) setState(() {});
      });
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _portal.removeListener(_changed);
    _workspace.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = _portal.jobById(widget.jobId);

    if (job == null) {
      return PublicPageShell(
        child: SectionContainer(
          child: EmptyState(
            icon: Icons.work_off_outlined,
            title: 'Job not found',
            message:
                'This listing may have expired, been removed, or the link may be incorrect.',
            action: FilledButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.jobs),
              child: const Text('Browse available jobs'),
            ),
          ),
        ),
      );
    }

    return PublicPageShell(
      child: Column(
        children: [
          _JobHeader(
            job: job,
            saved: AuthController.instance.currentUser?.role ==
                        UserRole.jobSeeker &&
                    _workspace.isLoaded
                ? _workspace.isSaved(job.id)
                : _guestSaved,
            onSave: () => _handleSave(context, job),
          ),
          SectionContainer(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 72),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 920;
                final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _JobMainContent(job: job),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: ReportButton(
                              targetType: 'job',
                              targetId: job.id,
                              targetLabel: job.title,
                              isSample: job.isSample)),
                    ]);
                final sidebar = _JobSidebar(
                    job: job,
                    onApply: () => _showApplicationPreview(context, job));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (desktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: content),
                          const SizedBox(width: 24),
                          SizedBox(width: 340, child: sidebar),
                        ],
                      )
                    else ...[
                      sidebar,
                      const SizedBox(height: 22),
                      content,
                    ],
                    const SizedBox(height: 54),
                    _SimilarJobs(job: job),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, JobModel job) async {
    final user = AuthController.instance.currentUser;
    if (user?.role != UserRole.jobSeeker) {
      setState(() => _guestSaved = !_guestSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(user == null
              ? 'Sign in with a Job Seeker account to keep saved jobs across devices.'
              : 'Only Job Seeker accounts can save jobs.'),
          action: user == null
              ? SnackBarAction(
                  label: 'Sign in',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.login),
                )
              : null,
        ),
      );
      return;
    }
    await _workspace.ensureLoaded();
    await _workspace.toggleSavedJob(job.id);
    if (mounted) setState(() {});
  }

  Future<void> _showApplicationPreview(
      BuildContext context, JobModel job) async {
    final user = AuthController.instance.currentUser;
    if (job.isSample &&
        (AuthController.instance.usesFirebase ||
            user?.role != UserRole.jobSeeker)) {
      final tryDemo = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
                title: const Text('Try a demo application'),
                content: const Text(
                    'Use a sample Job Seeker session to apply, track progress and try the recruitment workflow. This fictional application stays in Demo mode and is never sent to a real employer.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Use demo & apply')),
                ],
              ));
      if (tryDemo != true || !context.mounted) return;
      try {
        final account = DemoAccountCatalog.forRole(UserRole.jobSeeker).first;
        await AuthController.instance.signIn(
            email: account.email,
            password: DemoAccountCatalog.password,
            expectedRole: UserRole.jobSeeker);
        await _workspace.ensureLoaded();
        if (context.mounted) await _showApplicationPreview(context, job);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Could not open the demo application. Please try again.')));
        }
      }
      return;
    }
    final signedOut = user == null;
    final canApply = user?.role == UserRole.jobSeeker;

    if (signedOut || !canApply) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.panel,
          title: Text(
              signedOut ? 'Sign in to apply' : 'Job Seeker account required'),
          content: Text(
            signedOut
                ? 'Sign in with a Job Seeker account to apply for ${job.title} and track the application from your dashboard.'
                : 'Employer and Admin accounts cannot submit job applications. Sign in with a Job Seeker account to continue.',
            style: const TextStyle(color: AppColors.textMuted, height: 1.55),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close')),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (!signedOut) await AuthController.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamed(context, AppRoutes.login);
                }
              },
              child: Text(signedOut ? 'Sign in' : 'Switch account'),
            ),
          ],
        ),
      );
      return;
    }

    await _workspace.ensureLoaded();
    if (!context.mounted) return;
    final existing = _workspace.applicationForJob(job.id);
    if (existing != null) {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.panel,
            title: const Text('Application already submitted'),
            content: Text(
              'Your application is currently ${existing.status.label.toLowerCase()}. Open the tracker to review the timeline.',
              style: const TextStyle(color: AppColors.textMuted, height: 1.55),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close')),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushNamed(context,
                      AppRoutes.jobSeekerApplicationDetails(existing.id));
                },
                child: const Text('Track application'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final coverLetterController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var submitting = false;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !submitting,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogBodyContext, setDialogState) => AlertDialog(
            scrollable: true,
            backgroundColor: AppColors.panel,
            title: Text('Apply for ${job.title}'),
            content: SizedBox(
              width: 560,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.blueStrong.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: AppColors.blue.withValues(alpha: .2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined,
                              color: AppColors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _workspace.cvProfile!.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ),
                          Text(
                            '${_workspace.cvProfile!.sectionCount}/6 sections',
                            style: const TextStyle(
                                color: AppColors.textSubtle, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: coverLetterController,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: 900,
                      decoration: const InputDecoration(
                        labelText: 'Cover letter',
                        hintText:
                            'Explain why your experience and interests fit this role.',
                      ),
                      validator: (value) {
                        final length = value?.trim().length ?? 0;
                        if (length < 40) return 'Write at least 40 characters.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A PDF snapshot will be generated on-device from your structured CV, validated under 2 MB, and attached securely to this application.',
                      style: TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 10,
                          height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    submitting ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: submitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() => submitting = true);
                        try {
                          final application =
                              await _workspace.submitApplication(
                            job: job,
                            coverLetter: coverLetterController.text,
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (context.mounted) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.jobSeekerApplicationDetails(
                                  application.id),
                            );
                          }
                        } catch (_) {
                          setDialogState(() => submitting = false);
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                  content: Text(_workspace.errorMessage ??
                                      'Could not submit application.')),
                            );
                          }
                        }
                      },
                icon: submitting
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label:
                    Text(submitting ? 'Submitting...' : 'Submit application'),
              ),
            ],
          ),
        ),
      );
    } finally {
      coverLetterController.dispose();
    }
  }
}

class _JobHeader extends StatelessWidget {
  const _JobHeader({
    required this.job,
    required this.saved,
    required this.onSave,
  });

  final JobModel job;
  final bool saved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.page,
        border: const Border(bottom: BorderSide(color: AppColors.borderMuted)),
        gradient: LinearGradient(
          colors: [
            AppColors.page,
            AppColors.blueStrong.withValues(alpha: .065),
            AppColors.page
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SectionContainer(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.jobs),
                  child: const Text('Find Jobs'),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.textSubtle),
                Text(job.category,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                final avatar = CompanyLogo(
                  companyId: job.companyId,
                  companyName: job.companyName,
                  size: 72,
                  borderRadius: 21,
                );
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            job.companyName,
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (job.isVerified) ...[
                          const SizedBox(width: 7),
                          const Icon(Icons.verified_rounded,
                              size: 18, color: AppColors.green),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      job.title,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: compact ? 32 : 44,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        JobMetaChip(
                            icon: Icons.location_on_outlined,
                            label: job.location),
                        JobMetaChip(
                            icon: Icons.work_outline_rounded,
                            label: job.employmentType),
                        JobMetaChip(
                            icon: Icons.apartment_rounded, label: job.workMode),
                        JobMetaChip(
                            icon: Icons.timeline_rounded,
                            label: job.experience),
                      ],
                    ),
                  ],
                );
                final save = OutlinedButton.icon(
                  onPressed: onSave,
                  icon: Icon(saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded),
                  label: Text(saved ? 'Saved' : 'Save job'),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      avatar,
                      const SizedBox(height: 18),
                      copy,
                      const SizedBox(height: 22),
                      SizedBox(width: double.infinity, child: save),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    avatar,
                    const SizedBox(width: 22),
                    Expanded(child: copy),
                    const SizedBox(width: 24),
                    save,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _JobMainContent extends StatelessWidget {
  const _JobMainContent({required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailsSection(
            title: 'About the role',
            child: Text(job.description,
                style:
                    const TextStyle(color: AppColors.textMuted, height: 1.75)),
          ),
          _DetailsSection(
            title: 'What you will do',
            child: _BulletList(items: job.responsibilities),
          ),
          _DetailsSection(
            title: 'What we are looking for',
            child: _BulletList(items: job.requirements),
          ),
          _DetailsSection(
            title: 'Benefits',
            child: _BulletList(
                items: job.benefits, icon: Icons.check_circle_outline_rounded),
          ),
          _DetailsSection(
            title: 'Skills',
            last: true,
            child: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                for (final skill in job.skills)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.blueStrong.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.blue.withValues(alpha: .24)),
                    ),
                    child: Text(skill,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.title,
    required this.child,
    this.last = false,
  });

  final String title;
  final Widget child;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          child,
          if (!last) ...[
            const SizedBox(height: 30),
            const Divider(),
          ],
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList(
      {required this.items, this.icon = Icons.arrow_right_rounded});

  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 19, color: AppColors.blue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item,
                      style: const TextStyle(
                          color: AppColors.textMuted, height: 1.58)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _JobSidebar extends StatelessWidget {
  const _JobSidebar({required this.job, required this.onApply});

  final JobModel job;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.card,
                AppColors.blueStrong.withValues(alpha: .08)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.blue.withValues(alpha: .3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Monthly salary',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 8),
              Text(
                job.salaryLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 22),
              _SidebarFact(
                  icon: Icons.people_outline_rounded,
                  label:
                      '${job.openings} open position${job.openings == 1 ? '' : 's'}'),
              _SidebarFact(
                  icon: Icons.schedule_rounded,
                  label: 'Posted ${job.postedLabel}'),
              _SidebarFact(
                  icon: Icons.event_outlined,
                  label: 'Deadline ${job.deadlineLabel}'),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onApply,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueStrong,
                  minimumSize: const Size.fromHeight(54),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Apply now'),
              ),
              const SizedBox(height: 10),
              const Text(
                'You will review your profile and CV before submitting.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSubtle, fontSize: 10, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: () => Navigator.pushNamed(
              context, AppRoutes.companyDetails(job.companyId)),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CompanyLogo(
                      companyId: job.companyId,
                      companyName: job.companyName,
                      size: 44,
                      borderRadius: 13,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(job.companyName,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 15, color: AppColors.textSubtle),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'View verified company profile and all open positions.',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarFact extends StatelessWidget {
  const _SidebarFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSubtle),
          const SizedBox(width: 9),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12))),
        ],
      ),
    );
  }
}

class _SimilarJobs extends StatelessWidget {
  const _SimilarJobs({required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context) {
    final similar = PublicPortalController.instance.jobs
        .where((item) =>
            item.id != job.id &&
            (item.category == job.category || item.workMode == job.workMode))
        .take(3)
        .toList();

    if (similar.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Similar opportunities',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Other roles that may match your interests.',
            style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980
                ? 3
                : constraints.maxWidth >= 650
                    ? 2
                    : 1;
            const gap = 16.0;
            final width =
                (constraints.maxWidth - (columns - 1) * gap) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final item in similar)
                  SizedBox(
                      width: width,
                      child: PublicJobCard(job: item, compact: true)),
              ],
            );
          },
        ),
      ],
    );
  }
}
