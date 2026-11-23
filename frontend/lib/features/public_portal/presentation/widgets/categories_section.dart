import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/hover_card.dart';
import '../../../../shared/widgets/section_container.dart';
import '../../controllers/public_portal_controller.dart';
import 'section_heading.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: PublicPortalController.instance,
        builder: (context, _) => _buildContent(context),
      );

  Widget _buildContent(BuildContext context) {
    final categories = PublicPortalController.instance.categories;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeading(
            eyebrow: 'Explore career paths',
            title: 'Start broad, then find the right fit.',
            description:
                'Browse opportunities by field and refine your search with salary, location, work style, and experience filters.',
          ),
          const SizedBox(height: 34),
          if (categories.isEmpty)
            EmptyState(
              icon: Icons.category_outlined,
              title: 'Career paths are being prepared',
              message:
                  'The administrator can publish categories from the protected Admin workspace.',
              action: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.jobs),
                child: const Text('Browse all jobs'),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1000
                    ? 3
                    : constraints.maxWidth >= 650
                        ? 2
                        : 1;
                const gap = 16.0;
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * gap) / columns;

                return Wrap(
                  alignment: WrapAlignment.start,
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final category in categories)
                      SizedBox(
                        width: cardWidth,
                        child: HoverCard(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '${AppRoutes.jobs}?q=${Uri.encodeQueryComponent(category.title)}',
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.blueStrong
                                          .withValues(alpha: .3),
                                      AppColors.purple.withValues(alpha: .2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  _categoryIcon(category.iconCodePoint),
                                  color: AppColors.cyan,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category.subtitle,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${category.openings}',
                                    style: const TextStyle(
                                      color: AppColors.blue,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'openings',
                                    style: TextStyle(
                                      color: AppColors.textSubtle,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

IconData _categoryIcon(int codePoint) {
  return switch (codePoint) {
    0xe30a => Icons.memory_rounded,
    0xe40a => Icons.palette_rounded,
    0xe0af => Icons.business_center_rounded,
    0xe3b7 => Icons.campaign_rounded,
    0xe227 => Icons.account_balance_rounded,
    0xe869 => Icons.engineering_rounded,
    0xe80c => Icons.school_rounded,
    0xf0e2 => Icons.support_agent_rounded,
    0xe84f => Icons.account_balance_rounded,
    0xea3d => Icons.engineering_rounded,
    _ => Icons.category_outlined,
  };
}
