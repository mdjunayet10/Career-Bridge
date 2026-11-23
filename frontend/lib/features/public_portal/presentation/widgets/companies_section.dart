import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_container.dart';
import '../../controllers/public_portal_controller.dart';
import '../../../companies/presentation/widgets/company_card.dart';
import 'section_heading.dart';

class CompaniesSection extends StatelessWidget {
  const CompaniesSection({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: PublicPortalController.instance,
        builder: (context, _) => _buildContent(context),
      );

  Widget _buildContent(BuildContext context) {
    final companies = PublicPortalController.instance.isDemoCatalog
        ? PublicPortalController.instance.companies
        : PublicPortalController.instance.companies.take(4).toList();

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(
            eyebrow: PublicPortalController.instance.isDemoCatalog
                ? 'Sample employers'
                : 'Trusted employers',
            title: 'Discover teams building in Bangladesh.',
            description: PublicPortalController.instance.isDemoCatalog
                ? 'University demo: browse all 12 fictional sample companies. These are not verified employers.'
                : 'Explore company profiles, active openings, and verified employer details before starting an application.',
            action: TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.companies),
              icon: const Text('View companies'),
              label: const Icon(Icons.arrow_forward_rounded, size: 18),
            ),
          ),
          const SizedBox(height: 34),
          if (companies.isEmpty)
            EmptyState(
              icon: Icons.apartment_outlined,
              title: 'No verified companies yet',
              message:
                  'Company profiles will appear after the Career Bridge administrator completes verification.',
              action: OutlinedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.companies),
                child: const Text('View companies'),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1000
                    ? 4
                    : constraints.maxWidth >= 650
                        ? 2
                        : 1;
                const gap = 16.0;
                final width =
                    (constraints.maxWidth - (columns - 1) * gap) / columns;
                return Wrap(
                  alignment: WrapAlignment.start,
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final company in companies)
                      SizedBox(
                          width: width, child: CompanyCard(company: company)),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
