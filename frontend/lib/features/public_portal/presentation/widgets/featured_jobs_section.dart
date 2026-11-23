import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_container.dart';
import '../../controllers/public_portal_controller.dart';
import '../../../jobs/presentation/widgets/public_job_card.dart';
import 'section_heading.dart';

class FeaturedJobsSection extends StatelessWidget {
  const FeaturedJobsSection({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: PublicPortalController.instance,
        builder: (context, _) => _buildContent(context),
      );

  Widget _buildContent(BuildContext context) {
    final portal = PublicPortalController.instance;
    final jobs =
        portal.featuredJobs.take(portal.isDemoCatalog ? 20 : 6).toList();

    return Container(
      color: AppColors.page,
      child: SectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeading(
              eyebrow: 'Featured opportunities',
              title: 'Fresh roles from growing teams.',
              description:
                  'Clear job details, salary ranges, and company information help you decide before you apply.',
              action: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.jobs),
                icon: const Text('View all jobs'),
                label: const Icon(Icons.arrow_forward_rounded, size: 18),
              ),
            ),
            const SizedBox(height: 24),
            if (portal.isDemoCatalog || portal.hasLandingSamples) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.cyan.withValues(alpha: .18)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.cyan, size: 17),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        portal.isDemoCatalog
                            ? 'Academic demo · All 20 sample job listings are fictional. No company or vacancy here has been independently verified.'
                            : portal.landingSampleNotice,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else
              const SizedBox(height: 10),
            if (jobs.isEmpty)
              EmptyState(
                icon: Icons.work_off_outlined,
                title: 'No published jobs yet',
                message:
                    'Approved opportunities will appear here as soon as verified employers publish them.',
                action: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.jobs),
                  child: const Text('Open job search'),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 980
                      ? 3
                      : constraints.maxWidth >= 650
                          ? 2
                          : 1;
                  const gap = 18.0;
                  final cardWidth =
                      (constraints.maxWidth - (columns - 1) * gap) / columns;
                  return Wrap(
                    alignment: WrapAlignment.start,
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final job in jobs)
                        SizedBox(
                            width: cardWidth, child: PublicJobCard(job: job)),
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
