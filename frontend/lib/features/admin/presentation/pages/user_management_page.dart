import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../controllers/admin_workspace_controller.dart';
import '../widgets/admin_navigation.dart';
import '../widgets/admin_page_components.dart';
import '../widgets/admin_workspace_gate.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final searchController = TextEditingController();
  UserRole? roleFilter;
  bool? activeFilter;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminWorkspaceGate(
      builder: (context, controller) {
        final query = searchController.text.trim().toLowerCase();
        final users = controller.users.where((user) {
          final matchesQuery = query.isEmpty ||
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              (user.companyName ?? '').toLowerCase().contains(query);
          final matchesRole = roleFilter == null || user.role == roleFilter;
          final matchesActive =
              activeFilter == null || user.isActive == activeFilter;
          return matchesQuery && matchesRole && matchesActive;
        }).toList();

        return DashboardShell(
          role: UserRole.admin,
          title: 'User management',
          subtitle:
              'Review platform accounts and suspend or reactivate access without changing protected role assignments.',
          items: AdminNavigation.items,
          selectedIndex: 3,
          accent: AppColors.red,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Toolbar(
                searchController: searchController,
                roleFilter: roleFilter,
                activeFilter: activeFilter,
                onSearch: (_) => setState(() {}),
                onRole: (value) => setState(() => roleFilter = value),
                onActive: (value) => setState(() => activeFilter = value),
              ),
              const SizedBox(height: 18),
              _Summary(controller: controller),
              const SizedBox(height: 18),
              if (users.isEmpty)
                const AdminEmptyState(
                  title: 'No users match this view',
                  message: 'Try another search, role, or account status.',
                  icon: Icons.people_outline_rounded,
                )
              else
                AdminSectionCard(
                  padding: EdgeInsets.zero,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final desktop = constraints.maxWidth >= 860;
                      if (desktop) {
                        return _DesktopUserTable(
                            users: users,
                            controller: controller,
                            onToggle: _toggleUser);
                      }
                      return Column(
                        children: [
                          for (final user in users)
                            _MobileUserCard(
                                user: user,
                                controller: controller,
                                onToggle: _toggleUser),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleUser(
    BuildContext context,
    AdminWorkspaceController controller,
    AppUserModel user,
  ) async {
    if (user.uid == AuthController.instance.currentUser?.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('You cannot suspend the Admin account currently in use.')),
      );
      return;
    }
    final willActivate = !user.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(willActivate ? 'Reactivate account?' : 'Suspend account?'),
        content: Text(
          willActivate
              ? '${user.name} will regain access to the ${user.role.label} workspace.'
              : '${user.name} will be blocked from protected Career Bridge features.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
            style: willActivate
                ? null
                : FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(willActivate ? 'Reactivate' : 'Suspend'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await controller.setUserActive(user, willActivate);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(willActivate
                  ? 'Account reactivated.'
                  : 'Account suspended.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.controller});

  final AdminWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      AdminMetricCard(
          label: 'All users',
          value: '${controller.totalUsers}',
          icon: Icons.people_outline_rounded,
          color: AppColors.blue),
      AdminMetricCard(
          label: 'Job Seekers',
          value: '${controller.jobSeekerCount}',
          icon: Icons.person_search_outlined,
          color: AppColors.cyan),
      AdminMetricCard(
          label: 'Employers',
          value: '${controller.employerCount}',
          icon: Icons.business_center_outlined,
          color: AppColors.purple),
      AdminMetricCard(
          label: 'Suspended',
          value: '${controller.totalUsers - controller.activeUsers}',
          icon: Icons.block_outlined,
          color: AppColors.red),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980
            ? 4
            : constraints.maxWidth >= 600
                ? 2
                : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final card in cards) SizedBox(width: width, child: card)
        ]);
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.searchController,
    required this.roleFilter,
    required this.activeFilter,
    required this.onSearch,
    required this.onRole,
    required this.onActive,
  });

  final TextEditingController searchController;
  final UserRole? roleFilter;
  final bool? activeFilter;
  final ValueChanged<String> onSearch;
  final ValueChanged<UserRole?> onRole;
  final ValueChanged<bool?> onActive;

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      controller: searchController,
      onChanged: onSearch,
      decoration: const InputDecoration(
          hintText: 'Search name, email, or company',
          prefixIcon: Icon(Icons.search_rounded)),
    );
    final role = DropdownButtonFormField<UserRole?>(
      isExpanded: true,
      initialValue: roleFilter,
      decoration: const InputDecoration(labelText: 'Role'),
      items: [
        const DropdownMenuItem<UserRole?>(
            value: null, child: Text('All roles')),
        ...UserRole.values.map((value) => DropdownMenuItem<UserRole?>(
            value: value, child: Text(value.label))),
      ],
      onChanged: onRole,
    );
    final status = DropdownButtonFormField<bool?>(
      isExpanded: true,
      initialValue: activeFilter,
      decoration: const InputDecoration(labelText: 'Account status'),
      items: const [
        DropdownMenuItem<bool?>(value: null, child: Text('All accounts')),
        DropdownMenuItem<bool?>(value: true, child: Text('Active')),
        DropdownMenuItem<bool?>(value: false, child: Text('Suspended')),
      ],
      onChanged: onActive,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            SizedBox(width: 190, child: role),
            const SizedBox(width: 12),
            SizedBox(width: 190, child: status)
          ]);
        }
        if (constraints.maxWidth < 500) {
          return Column(children: [
            search,
            const SizedBox(height: 12),
            role,
            const SizedBox(height: 12),
            status
          ]);
        }
        return Column(children: [
          search,
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: role),
            const SizedBox(width: 12),
            Expanded(child: status)
          ])
        ]);
      },
    );
  }
}

typedef _UserToggle = Future<void> Function(
    BuildContext, AdminWorkspaceController, AppUserModel);

class _DesktopUserTable extends StatelessWidget {
  const _DesktopUserTable(
      {required this.users, required this.controller, required this.onToggle});

  final List<AppUserModel> users;
  final AdminWorkspaceController controller;
  final _UserToggle onToggle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowMinHeight: 80,
        dataRowMaxHeight: 120,
        headingTextStyle: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w800,
            fontSize: 10),
        dataTextStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        columns: const [
          DataColumn(label: Text('USER')),
          DataColumn(label: Text('ROLE')),
          DataColumn(label: Text('JOINED')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('ACTION')),
        ],
        rows: [
          for (final user in users)
            DataRow(cells: [
              DataCell(SizedBox(width: 260, child: _UserIdentity(user: user))),
              DataCell(_RoleBadge(role: user.role)),
              DataCell(Text(compactDate(user.createdAt))),
              DataCell(_AccountStatus(active: user.isActive)),
              DataCell(TextButton(
                  onPressed: controller.isSaving
                      ? null
                      : () => onToggle(context, controller, user),
                  child: Text(user.isActive ? 'Suspend' : 'Reactivate'))),
            ]),
        ],
      ),
    );
  }
}

class _MobileUserCard extends StatelessWidget {
  const _MobileUserCard(
      {required this.user, required this.controller, required this.onToggle});

  final AppUserModel user;
  final AdminWorkspaceController controller;
  final _UserToggle onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserIdentity(user: user),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _RoleBadge(role: user.role),
            _AccountStatus(active: user.isActive)
          ]),
          const SizedBox(height: 12),
          Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Joined ${compactDate(user.createdAt)}',
                    style: const TextStyle(
                        color: AppColors.textSubtle, fontSize: 10)),
                TextButton(
                    onPressed: controller.isSaving
                        ? null
                        : () => onToggle(context, controller, user),
                    child: Text(user.isActive ? 'Suspend' : 'Reactivate'))
              ]),
          const Divider(color: AppColors.borderMuted),
        ],
      ),
    );
  }
}

class _UserIdentity extends StatelessWidget {
  const _UserIdentity({required this.user});

  final AppUserModel user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
            backgroundColor: AppColors.blue.withValues(alpha: .12),
            foregroundColor: AppColors.blue,
            child: Text(user.name.isEmpty ? '?' : user.name[0].toUpperCase())),
        const SizedBox(width: 11),
        Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 10)),
              if (user.companyName?.trim().isNotEmpty == true)
                Text(user.companyName!,
                    style: const TextStyle(
                        color: AppColors.textSubtle, fontSize: 9))
            ])),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      UserRole.jobSeeker => AppColors.cyan,
      UserRole.employer => AppColors.purple,
      UserRole.admin => AppColors.red
    };
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(999)),
        child: Text(role.label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 9)));
  }
}

class _AccountStatus extends StatelessWidget {
  const _AccountStatus({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.green : AppColors.red;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(active ? 'Active' : 'Suspended',
          style:
              TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 9))
    ]);
  }
}
