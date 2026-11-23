import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../widgets/employer_navigation.dart';
import '../widgets/employer_workspace_gate.dart';

class EmployerNotificationsPage extends StatelessWidget {
  const EmployerNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EmployerWorkspaceGate(
      builder: (context, controller) => DashboardShell(
        role: UserRole.employer,
        title: 'Notifications',
        subtitle:
            'Review new applications, job-review updates, and company account activity.',
        items: EmployerNavigation.items,
        selectedIndex: 6,
        accent: AppColors.purple,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${controller.unreadNotificationCount} unread',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  onPressed: controller.unreadNotificationCount == 0
                      ? null
                      : controller.markAllNotificationsRead,
                  icon: const Icon(Icons.done_all_rounded),
                  label: const Text('Mark all read'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (controller.notifications.isEmpty)
              const _EmptyNotifications()
            else
              Column(
                children: [
                  for (final notification in controller.notifications) ...[
                    _NotificationTile(
                      notification: notification,
                      onTap: () async {
                        await controller.markNotificationRead(notification);
                        if (context.mounted &&
                            notification.actionRoute != null) {
                          Navigator.pushNamed(
                              context, notification.actionRoute!);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (notification.type) {
      'application' => Icons.person_add_alt_1_outlined,
      'job' => Icons.work_outline_rounded,
      'company' => Icons.verified_outlined,
      _ => Icons.notifications_none_rounded,
    };
    final color = switch (notification.type) {
      'application' => AppColors.purple,
      'job' => AppColors.blue,
      'company' => AppColors.green,
      _ => AppColors.cyan,
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.card
              : color.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notification.isRead
                ? AppColors.borderMuted
                : color.withValues(alpha: .24),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.w700
                                : FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: const TextStyle(
                        color: AppColors.textMuted, height: 1.5, fontSize: 11),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year} · ${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        color: AppColors.textSubtle, fontSize: 9),
                  ),
                ],
              ),
            ),
            if (notification.actionRoute != null) ...[
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.textSubtle, size: 19),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(44),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: const Column(
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 52, color: AppColors.textSubtle),
          SizedBox(height: 14),
          Text('No notifications yet',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          SizedBox(height: 6),
          Text('Application and job-review updates will appear here.',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
