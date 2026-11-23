import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/layouts/public_page_shell.dart';
import '../../../../shared/widgets/section_container.dart';

class EmployerPortalPage extends StatelessWidget {
  const EmployerPortalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicPageShell(
      child: Column(
        children: [
          SectionContainer(
            padding: const EdgeInsets.fromLTRB(24, 76, 24, 70),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 900;
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: AppColors.purple.withValues(alpha: .28)),
                      ),
                      child: const Text(
                        'CAREER BRIDGE FOR EMPLOYERS',
                        style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hire with clarity,\nnot complexity.',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontSize: desktop ? 56 : 42,
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                            letterSpacing: -1.6,
                          ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create a verified company profile, publish opportunities, review applicants, and move candidates through one focused recruitment workflow.',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          height: 1.7,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.employerRegister),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.purple),
                          icon: const Icon(Icons.apartment_rounded),
                          label: const Text('Register company'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.employerLogin),
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Employer sign in'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Row(
                      children: [
                        Icon(Icons.verified_user_outlined,
                            color: AppColors.green, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Company verification is required before jobs can be published.',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
                return Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: copy,
                  ),
                );
              },
            ),
          ),
          const _EmployerBenefits(),
          const _HowItWorks(),
        ],
      ),
    );
  }
}

class _EmployerBenefits extends StatelessWidget {
  const _EmployerBenefits();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.verified_outlined,
        'Verified employer identity',
        'Build trust with candidates through administrator-reviewed company profiles.'
      ),
      (
        Icons.work_outline_rounded,
        'Structured job publishing',
        'Create clear, information-rich opportunities and submit them for moderation.'
      ),
      (
        Icons.groups_2_outlined,
        'Applicant workspace',
        'Review candidates, update stages, add notes, and coordinate interviews.'
      ),
    ];
    return SectionContainer(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 70),
      child: Column(
        children: [
          Text('Everything needed to run a clearer hiring process.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const Text(
              'The full Employer workspace will use the same premium dark design system.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 30),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 850 ? 3 : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: width,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderMuted)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(item.$1, color: AppColors.purple, size: 28),
                            const SizedBox(height: 18),
                            Text(item.$2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 8),
                            Text(item.$3,
                                style: const TextStyle(
                                    color: AppColors.textMuted,
                                    height: 1.55,
                                    fontSize: 12)),
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

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        '01',
        'Register company',
        'Create the employer account and company profile.'
      ),
      (
        '02',
        'Admin verification',
        'The hidden Admin Panel reviews company details.'
      ),
      ('03', 'Start hiring', 'Approved employers can publish and manage jobs.'),
    ];
    return Container(
      color: AppColors.page,
      child: SectionContainer(
        padding: const EdgeInsets.fromLTRB(24, 56, 24, 70),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 760;
            return desktop
                ? Row(
                    children: [
                      for (var i = 0; i < steps.length; i++) ...[
                        Expanded(child: _Step(data: steps[i])),
                        if (i != steps.length - 1)
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18),
                              child: Icon(Icons.arrow_forward_rounded,
                                  color: AppColors.textSubtle)),
                      ],
                    ],
                  )
                : Column(children: [
                    for (final step in steps)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _Step(data: step))
                  ]);
          },
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.data});

  final (String, String, String) data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderMuted)),
      child: Row(
        children: [
          Text(data.$1,
              style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 25,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 15),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data.$2,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 5),
              Text(data.$3,
                  style: const TextStyle(
                      color: AppColors.textMuted, height: 1.45, fontSize: 11)),
            ]),
          ),
        ],
      ),
    );
  }
}
