import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/section_container.dart';
import '../../controllers/public_portal_controller.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: PublicPortalController.instance,
        builder: (context, _) => _buildContent(context),
      );

  Widget _buildContent(BuildContext context) {
    final portal = PublicPortalController.instance;
    final stats = [
      (
        '${portal.jobs.length}',
        portal.isDemoCatalog ? 'Demo jobs' : 'Live jobs',
        Icons.work_outline_rounded
      ),
      (
        '${portal.companies.length}',
        portal.isDemoCatalog ? 'Demo companies' : 'Verified companies',
        Icons.apartment_rounded
      ),
      (
        '${portal.categories.length}',
        'Active career paths',
        Icons.category_outlined
      ),
      (
        '${portal.salaryInsights.length}',
        'Salary insights',
        Icons.insights_rounded
      ),
    ];

    return Container(
      color: AppColors.page,
      child: SectionContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 600 ? 2 : 4;
            final width = (constraints.maxWidth - (columns - 1) * 14) / columns;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final stat in stats)
                  SizedBox(
                    width: width,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderMuted),
                      ),
                      child: Row(
                        children: [
                          Icon(stat.$3, color: AppColors.blue, size: 23),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 850),
                                  builder: (context, value, _) => Opacity(
                                    opacity: value,
                                    child: Text(
                                      stat.$1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  stat.$2,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
