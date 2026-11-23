import 'package:flutter/material.dart';

import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/enums/user_role.dart';
import '../../core/services/account_password_service.dart';
import '../../features/auth/presentation/widgets/set_app_password_dialog.dart';
import '../../core/responsive/breakpoints.dart';
import '../../features/auth/controllers/auth_controller.dart';

class DashboardNavItem {
  const DashboardNavItem({required this.label, required this.icon, this.route});

  final String label;
  final IconData icon;
  final String? route;
}

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.body,
    super.key,
    this.selectedIndex = 0,
    this.accent = AppColors.blue,
    this.constrainBodyToViewport = false,
  });

  final UserRole role;
  final String title;
  final String subtitle;
  final List<DashboardNavItem> items;
  final Widget body;
  final int selectedIndex;
  final Color accent;
  final bool constrainBodyToViewport;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= Breakpoints.desktop;
        if (!desktop) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              titleSpacing: 8,
              title: Image.asset(
                'assets/logos/career_bridge_nav_logo.png',
                width: 146,
              ),
              actions: [
                if (constraints.maxWidth >= 480) ...[
                  _RoleChip(role: role, accent: accent),
                  const SizedBox(width: 6),
                ],
                IconButton(
                  onPressed: () => _showAccountMenu(context),
                  tooltip: 'Account',
                  icon: const Icon(Icons.account_circle_outlined),
                ),
                const SizedBox(width: 8),
              ],
            ),
            drawer: Drawer(
              width: 300,
              backgroundColor: AppColors.panel,
              child:
                  SafeArea(child: _SidebarContent(shell: this, mobile: true)),
            ),
            body: _DashboardContent(
              title: title,
              subtitle: subtitle,
              role: role,
              accent: accent,
              body: body,
              constrainBodyToViewport: constrainBodyToViewport,
            ),
            bottomNavigationBar: mobileNavigationBar(context),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              Container(
                width: 286,
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  border: const Border(
                    right: BorderSide(color: AppColors.borderMuted),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent.withValues(alpha: .055),
                      AppColors.panel,
                      AppColors.panel,
                    ],
                  ),
                ),
                child: SafeArea(child: _SidebarContent(shell: this)),
              ),
              Expanded(
                child: SafeArea(
                  child: _DashboardContent(
                    title: title,
                    subtitle: subtitle,
                    role: role,
                    accent: accent,
                    body: body,
                    constrainBodyToViewport: constrainBodyToViewport,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shared with logged-in Find Jobs to keep workspace tabs visible.
  Widget mobileNavigationBar(BuildContext context) {
    final visibleCount = role == UserRole.admin ? 3 : 4;
    final visibleDestinations =
        items.take(visibleCount).toList(growable: false);
    final hasMore = items.length > visibleCount;
    final bottomIndex = selectedIndex < 0
        ? 0
        : selectedIndex < visibleDestinations.length
            ? selectedIndex
            : (hasMore ? visibleDestinations.length : 0);
    final mobileLabels = switch (role) {
      UserRole.jobSeeker => const ['Home', 'Jobs', 'Saved', 'Profile'],
      UserRole.employer => const ['Home', 'Post', 'Jobs', 'Company'],
      UserRole.admin => const ['Home', 'Employers', 'Approvals'],
    };
    void selectDestination(int index) {
      if (hasMore && index == visibleDestinations.length) {
        _showNavigationMenu(context);
        return;
      }
      _handleNavigation(context, visibleDestinations[index]);
    }

    return NavigationBar(
      height: (44 + MediaQuery.textScalerOf(context).scale(11) * 1.2)
          .clamp(76.0, double.infinity)
          .toDouble(),
      backgroundColor: AppColors.panel,
      selectedIndex: bottomIndex,
      onDestinationSelected: selectDestination,
      destinations: [
        for (var index = 0; index < visibleDestinations.length; index++)
          _MobileNavigationDestination(
            icon: visibleDestinations[index].icon,
            label: mobileLabels[index],
            fullLabel: visibleDestinations[index].label,
            selected: bottomIndex == index,
            accent: accent,
            onTap: () => selectDestination(index),
          ),
        if (hasMore)
          _MobileNavigationDestination(
            icon: Icons.more_horiz_rounded,
            label: 'More',
            fullLabel: 'More',
            selected: bottomIndex == visibleDestinations.length,
            accent: accent,
            onTap: () => selectDestination(visibleDestinations.length),
          ),
      ],
    );
  }

  Future<void> _showNavigationMenu(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.panel,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (_, index) {
            final item = items[index];
            final selected = selectedIndex == index;
            return ListTile(
              selected: selected,
              selectedTileColor: accent.withValues(alpha: .11),
              selectedColor: accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: Icon(item.icon),
              title: Text(item.label),
              trailing: item.route == null
                  ? const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppColors.textSubtle,
                    )
                  : null,
              onTap: () {
                Navigator.pop(sheetContext);
                _handleNavigation(context, item);
              },
            );
          },
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, DashboardNavItem item) {
    if (item.route != null) {
      final current = ModalRoute.of(context)?.settings.name;
      if (current != item.route) {
        Navigator.pushReplacementNamed(context, item.route!);
      }
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.label} is not available in this build yet.'),
        ),
      );
  }

  Future<void> _showAccountMenu(BuildContext context) async {
    final auth = AuthController.instance;
    final user = auth.currentUser;
    final passwordService = auth.usesFirebase && user != null
        ? AccountPasswordService(expectedUid: user.uid)
        : null;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.panel,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _UserAvatar(accent: accent, size: 50),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Career Bridge User',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(context, AppRoutes.home);
                },
                icon: const Icon(Icons.public_rounded),
                label: const Text('Open public website'),
              ),
              if (passwordService?.canAddPassword == true) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: const Icon(Icons.password_rounded),
                  label: const Text('Set app password'),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    final saved = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          SetAppPasswordDialog(service: passwordService!),
                    );
                    if (saved == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'App password set. You can now sign in with email/password or Google.'),
                      ));
                    }
                  },
                ),
              ],
              const SizedBox(height: 10),
              FilledButton.icon(
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
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({required this.shell, this.mobile = false});

  final DashboardShell shell;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.currentUser;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/logos/career_bridge_nav_logo.png',
              width: 174,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: shell.accent.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: shell.accent.withValues(alpha: .22),
              ),
            ),
            child: Row(
              children: [
                _UserAvatar(accent: shell.accent, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Career Bridge User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shell.role.label,
                        style: TextStyle(
                          color: shell.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: shell.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final item = shell.items[index];
              final selected = shell.selectedIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected
                      ? shell.accent.withValues(alpha: .11)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? shell.accent.withValues(alpha: .22)
                        : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  selected: selected,
                  selectedColor: shell.accent,
                  textColor: AppColors.textMuted,
                  iconColor: AppColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(item.icon, size: 21),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  trailing: item.route == null
                      ? const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.textSubtle,
                        )
                      : selected
                          ? Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: shell.accent,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                  onTap: () {
                    if (mobile) Navigator.pop(context);
                    shell._handleNavigation(context, item);
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
                icon: const Icon(Icons.public_rounded, size: 18),
                label: const Text('Public website'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  await AuthController.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (_) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.title,
    required this.subtitle,
    required this.role,
    required this.accent,
    required this.body,
    required this.constrainBodyToViewport,
  });

  final String title;
  final String subtitle;
  final UserRole role;
  final Color accent;
  final Widget body;
  final bool constrainBodyToViewport;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final horizontalPadding = compact ? 18.0 : 30.0;
        final fixedViewport = constrainBodyToViewport &&
            constraints.maxWidth - horizontalPadding * 2 >= 960;
        final padding = EdgeInsets.fromLTRB(
          horizontalPadding,
          compact ? 22 : 30,
          horizontalPadding,
          fixedViewport ? 24 : 56,
        );
        final content = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.8,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 760),
                            child: Text(
                              subtitle,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 20),
                      _RoleChip(role: role, accent: accent),
                    ],
                  ],
                ),
                if (AuthController.instance.isDemoSession) ...[
                  const SizedBox(height: 16),
                  const Text(
                      'Demo mode · Sample data only. Sign out to return to real login.',
                      style: TextStyle(
                          color: AppColors.blue, fontWeight: FontWeight.w700)),
                ],
                const SizedBox(height: 28),
                if (fixedViewport) Expanded(child: body) else body,
              ],
            ),
          ),
        );
        if (fixedViewport) return Padding(padding: padding, child: content);
        return Scrollbar(
          child: SingleChildScrollView(padding: padding, child: content),
        );
      },
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role, required this.accent});

  final UserRole role;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: .22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline_rounded, color: accent, size: 15),
          const SizedBox(width: 6),
          Text(
            '${role.label} workspace',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Uses the bar's equal-width cells without NavigationDestination's text-scale
/// clamp, so large text stays accessible while every label uses a single line.
class _MobileNavigationDestination extends StatelessWidget {
  const _MobileNavigationDestination({
    required this.icon,
    required this.label,
    required this.fullLabel,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String fullLabel;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: fullLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: Tooltip(
        message: fullLabel,
        excludeFromSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: .22)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 28,
                    child: Icon(icon,
                        size: 24,
                        color:
                            selected ? Colors.white : AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          height: 1.2,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                        ),
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

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.accent, required this.size});

  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.currentUser;
    final name = user?.name.trim() ?? '';
    final letter = name.isEmpty ? 'C' : name.substring(0, 1).toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .17),
        borderRadius: BorderRadius.circular(size * .34),
        border: Border.all(color: accent.withValues(alpha: .2)),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w900,
          fontSize: size * .34,
        ),
      ),
    );
  }
}
