import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/controllers/auth_controller.dart';

class VerificationPendingPage extends StatelessWidget {
  const VerificationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.currentUser!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logos/career_bridge_nav_logo.png',
                          width: 176),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () async {
                          await AuthController.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, AppRoutes.home, (_) => false);
                          }
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign out'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 70),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: .12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.yellow.withValues(alpha: .28)),
                    ),
                    child: const Icon(Icons.hourglass_top_rounded,
                        color: AppColors.yellow, size: 40),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Company verification is pending.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900, letterSpacing: -.7),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${user.companyName ?? 'Your company'} has been submitted to the Career Bridge administrator. The Employer dashboard will unlock after approval.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textMuted, height: 1.65, fontSize: 15),
                  ),
                  const SizedBox(height: 34),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border)),
                    child: const Column(
                      children: [
                        _StatusRow(
                            icon: Icons.check_circle_rounded,
                            title: 'Employer account created',
                            subtitle:
                                'Authentication and company profile saved.',
                            complete: true),
                        _StatusDivider(),
                        _StatusRow(
                            icon: Icons.fact_check_outlined,
                            title: 'Admin review',
                            subtitle:
                                'Company identity and submitted details are being reviewed.',
                            active: true),
                        _StatusDivider(),
                        _StatusRow(
                            icon: Icons.lock_open_rounded,
                            title: 'Dashboard access',
                            subtitle:
                                'Post jobs and manage applicants after approval.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.employers),
                    icon: const Icon(Icons.public_rounded),
                    label: const Text('View Employer Portal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.complete = false,
      this.active = false});

  final IconData icon;
  final String title;
  final String subtitle;
  final bool complete;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = complete
        ? AppColors.green
        : active
            ? AppColors.yellow
            : AppColors.textSubtle;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: color.withValues(alpha: .12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 21)),
        const SizedBox(width: 15),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textMuted, height: 1.45, fontSize: 12))
        ])),
      ],
    );
  }
}

class _StatusDivider extends StatelessWidget {
  const _StatusDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.fromLTRB(20, 7, 0, 7),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
                height: 26,
                child: VerticalDivider(color: AppColors.borderStrong))));
  }
}
