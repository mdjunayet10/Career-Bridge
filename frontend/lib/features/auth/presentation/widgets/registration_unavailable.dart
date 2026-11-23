import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import 'auth_shell.dart';

class RegistrationUnavailable extends StatelessWidget {
  const RegistrationUnavailable({
    required this.accountType,
    required this.supportEmail,
    this.employer = false,
    super.key,
  });

  final String accountType;
  final String supportEmail;
  final bool employer;

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      eyebrow: 'Registration unavailable',
      title: '$accountType registration is temporarily closed.',
      subtitle:
          'An administrator has paused new registrations. Existing accounts can still sign in normally.',
      accent: employer ? AppColors.purple : AppColors.blue,
      portalLabel: employer ? 'EMPLOYER PORTAL' : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'For support, contact $supportEmail.',
              style: const TextStyle(color: AppColors.textMuted, height: 1.5),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              employer ? AppRoutes.employerLogin : AppRoutes.login,
            ),
            child: const Text('Go to sign in'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (_) => false,
            ),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }
}
