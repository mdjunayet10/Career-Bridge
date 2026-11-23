import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/controllers/auth_controller.dart';

class PublicNavbar extends StatelessWidget {
  const PublicNavbar({super.key});

  static const _items = [
    ('Find Jobs', AppRoutes.jobs),
    ('Companies', AppRoutes.companies),
    ('Salary Insights', AppRoutes.salaryInsights),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthController.instance,
      builder: (context, _) {
        final currentPath = Uri.parse(
          ModalRoute.of(context)?.settings.name ?? AppRoutes.home,
        ).path;
        final user = AuthController.instance.currentUser;

        return Container(
          height: 78,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: .95),
            border:
                const Border(bottom: BorderSide(color: AppColors.borderMuted)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .16),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1380),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final mobile = constraints.maxWidth < 1320;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => _go(context, AppRoutes.home),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Image.asset(
                              'assets/logos/career_bridge_nav_logo.png',
                              width: mobile ? 138 : 178,
                              height: 50,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (!mobile) ...[
                          for (final item in _items)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: _NavButton(
                                label: item.$1,
                                active: currentPath == item.$2 ||
                                    currentPath.startsWith('${item.$2}/'),
                                onPressed: () => _go(context, item.$2),
                              ),
                            ),
                          _NavButton(
                            label: 'For Employers',
                            active: currentPath == AppRoutes.employers ||
                                currentPath.startsWith('/employer'),
                            onPressed: () => _go(context, AppRoutes.employers),
                          ),
                          const SizedBox(width: 8),
                          if (user == null) ...[
                            OutlinedButton(
                              onPressed: () => _go(context, AppRoutes.login),
                              child: const Text('Sign in'),
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              onPressed: () => _go(context, AppRoutes.register),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.blueStrong,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 17,
                                ),
                              ),
                              child: const Text('Create account'),
                            ),
                          ] else
                            FilledButton.icon(
                              onPressed: () => _go(context, AppRoutes.account),
                              icon: CircleAvatar(
                                radius: 12,
                                backgroundColor:
                                    Colors.white.withValues(alpha: .16),
                                foregroundColor: Colors.white,
                                child: Text(
                                  user.name.isEmpty
                                      ? 'C'
                                      : user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              label: const Text('Workspace'),
                            ),
                        ] else
                          IconButton(
                            onPressed: () => _showMenu(context, currentPath),
                            icon: const Icon(Icons.menu_rounded),
                            tooltip: 'Open menu',
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMenu(BuildContext context, String currentPath) {
    final user = AuthController.instance.currentUser;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.panel,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.blueStrong.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.blue.withValues(alpha: .20)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              AppColors.blueStrong.withValues(alpha: .18),
                          foregroundColor: AppColors.blue,
                          child: Text(
                            user.name.isEmpty
                                ? 'C'
                                : user.name[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                user.role.label,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Home'),
                  selected: currentPath == AppRoutes.home,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _go(context, AppRoutes.home);
                  },
                ),
                for (final item in _items)
                  ListTile(
                    title: Text(item.$1),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                    selected: currentPath == item.$2 ||
                        currentPath.startsWith('${item.$2}/'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _go(context, item.$2);
                    },
                  ),
                ListTile(
                  title: const Text('For Employers'),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                  selected: currentPath == AppRoutes.employers ||
                      currentPath.startsWith('/employer'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _go(context, AppRoutes.employers);
                  },
                ),
                const SizedBox(height: 8),
                if (user == null)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _go(context, AppRoutes.login);
                          },
                          child: const Text('Sign in'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _go(context, AppRoutes.register);
                          },
                          child: const Text('Create account'),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _go(context, AppRoutes.account);
                          },
                          icon: const Icon(Icons.dashboard_outlined),
                          label: const Text('Open workspace'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.outlined(
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await AuthController.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.home,
                              (_) => false,
                            );
                          }
                        },
                        tooltip: 'Sign out',
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _go(BuildContext context, String route) {
    final currentPath = Uri.parse(
      ModalRoute.of(context)?.settings.name ?? AppRoutes.home,
    ).path;
    if (currentPath == route) return;
    Navigator.pushNamed(context, route);
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: active ? AppColors.blue : AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: active ? 22 : 0,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
