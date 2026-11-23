import 'package:flutter/material.dart';

import '../../../../shared/layouts/public_page_shell.dart';
import '../widgets/categories_section.dart';
import '../widgets/companies_section.dart';
import '../widgets/cv_builder_section.dart';
import '../widgets/employer_cta_section.dart';
import '../widgets/featured_jobs_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/stats_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PublicPageShell(
      child: Column(
        children: [
          HeroSection(),
          StatsSection(),
          CategoriesSection(),
          FeaturedJobsSection(),
          CompaniesSection(),
          CvBuilderSection(),
          EmployerCtaSection(),
        ],
      ),
    );
  }
}
