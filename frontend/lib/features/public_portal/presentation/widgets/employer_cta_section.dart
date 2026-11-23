import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/section_container.dart';

class EmployerCtaSection extends StatelessWidget {
  const EmployerCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Container(
        padding: const EdgeInsets.all(38),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 760;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FOR EMPLOYERS',
                    style: TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 12)),
                const SizedBox(height: 13),
                Text('Build your team with a clearer hiring workflow.',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                const Text(
                    'Publish verified opportunities, manage applicants, shortlist candidates, and track interviews in one recruitment workspace.',
                    style: TextStyle(color: AppColors.textMuted, height: 1.6)),
              ],
            );
            final actions = Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.employerRegister),
                    icon: const Icon(Icons.business_center_outlined),
                    label: const Text('Register company')),
                OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.employerLogin),
                    child: const Text('Employer sign in')),
              ],
            );

            return desktop
                ? Row(
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: 38),
                      actions,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [copy, const SizedBox(height: 28), actions],
                  );
          },
        ),
      ),
    );
  }
}
