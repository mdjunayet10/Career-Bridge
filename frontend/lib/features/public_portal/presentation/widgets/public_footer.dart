import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/section_container.dart';

class PublicFooter extends StatelessWidget {
  const PublicFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF03050A),
      child: SectionContainer(
        padding: EdgeInsets.fromLTRB(
            24, 42, 24, 36 + MediaQuery.viewPaddingOf(context).bottom),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 820;
                final brand = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/logos/career_bridge_nav_logo.png',
                      width: 188,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                        'A Bangladesh-focused career platform connecting job seekers, verified employers, and better opportunities.',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            height: 1.55,
                            fontSize: 12)),
                  ],
                );
                final links = Wrap(
                  spacing: desktop ? 48 : 18,
                  runSpacing: desktop ? 24 : 26,
                  children: const [
                    _FooterColumn(title: 'Job seekers', links: [
                      'Find Jobs',
                      'Companies',
                      'CV Builder',
                      'Salary Insights'
                    ]),
                    _FooterColumn(title: 'Employers', links: [
                      'Employer Portal',
                      'Post a Job',
                      'Applicants',
                      'Company Profile'
                    ]),
                    _FooterColumn(title: 'Platform', links: [
                      'About',
                      'Salary Insights',
                      'Privacy',
                      'Terms'
                    ]),
                  ],
                );
                return desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Expanded(child: brand), links])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [brand, const SizedBox(height: 36), links]);
              },
            ),
            const SizedBox(height: 44),
            const Divider(),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                const copyright = Text(
                    '© 2026 Career Bridge. University project.',
                    style:
                        TextStyle(color: AppColors.textSubtle, fontSize: 11));
                const tagline = Text('Made for careers in Bangladesh',
                    style:
                        TextStyle(color: AppColors.textSubtle, fontSize: 11));
                if (constraints.maxWidth < 640) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [copyright, SizedBox(height: 12), tagline],
                  );
                }
                return const Row(
                  children: [
                    Expanded(child: copyright),
                    SizedBox(width: 20),
                    tagline
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

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});

  final String title;
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 14),
          for (final link in links)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(link,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11)),
            ),
        ],
      ),
    );
  }
}
