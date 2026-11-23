import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/auth_shell.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      eyebrow: 'Create your account',
      title: 'Choose the workspace built for your goal.',
      subtitle:
          'Your account type controls the tools, permissions, and dashboard you receive after sign in.',
      maxFormWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 620;
              final jobSeeker = _RoleCard(
                icon: Icons.person_search_outlined,
                title: 'Job Seeker',
                description:
                    'Discover jobs, save opportunities, create a CV, and track each application.',
                accent: AppColors.blue,
                actionLabel: 'Create Job Seeker account',
                features: const [
                  'Personalised job discovery',
                  'Application tracking',
                  'CV Builder and saved jobs',
                ],
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.jobSeekerRegister,
                ),
              );
              final employer = _RoleCard(
                icon: Icons.apartment_rounded,
                title: 'Employer',
                description:
                    'Register your company, complete verification, post jobs, and review applicants.',
                accent: AppColors.purple,
                actionLabel: 'Register company',
                features: const [
                  'Verified company profile',
                  'Job and applicant management',
                  'Recruitment pipeline',
                ],
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.employerRegister,
                ),
              );

              if (!sideBySide) {
                return Column(
                  children: [
                    jobSeeker,
                    const SizedBox(height: 14),
                    employer,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: jobSeeker),
                  const SizedBox(width: 14),
                  Expanded(child: employer),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              const Text(
                'Already have an account?',
                style: TextStyle(color: AppColors.textMuted),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.login,
                ),
                child: const Text('Sign in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.actionLabel,
    required this.features,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final String actionLabel;
  final List<String> features;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.cardHover : AppColors.panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hovered
                  ? widget.accent.withValues(alpha: .58)
                  : AppColors.border,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.accent.withValues(alpha: .11),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.accent.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: widget.accent.withValues(alpha: .24),
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.accent,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _hovered
                          ? widget.accent.withValues(alpha: .14)
                          : AppColors.input,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: _hovered ? widget.accent : AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  height: 1.5,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 18),
              for (final feature in widget.features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: widget.accent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                widget.actionLabel,
                style: TextStyle(
                  color: widget.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
