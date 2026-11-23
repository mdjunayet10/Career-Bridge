import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../controllers/auth_controller.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({required this.requiredRole, super.key});

  final UserRole requiredRole;

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.currentUser;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: .12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: AppColors.red, size: 34),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Access denied',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This area requires a ${requiredRole.label} account. You are signed in as ${user?.role.label ?? 'another user'}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textMuted, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      user == null
                          ? AppRoutes.home
                          : AuthController.instance.homeRouteFor(user),
                      (_) => false,
                    ),
                    child: const Text('Go to my workspace'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      await AuthController.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.login, (_) => false);
                      }
                    },
                    child: const Text('Sign in with another account'),
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
