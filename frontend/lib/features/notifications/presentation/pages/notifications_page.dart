import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/mobile_push_service.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../shared/layouts/dashboard_shell.dart';
import '../../../job_seeker/presentation/widgets/job_seeker_navigation.dart';
import '../../../job_seeker/presentation/widgets/job_seeker_workspace_gate.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      role: UserRole.jobSeeker,
      title: 'Notifications',
      subtitle:
          'Job matches, application updates, interview schedules, and important account reminders.',
      items: JobSeekerNavigation.items,
      selectedIndex: 6,
      body: JobSeekerWorkspaceGate(
        builder: (context, controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (MobilePushService.instance.available)
                ListenableBuilder(
                  listenable: MobilePushService.instance,
                  builder: (context, _) => SwitchListTile.adaptive(
                    title: const Text('New job notifications'),
                    subtitle: Text(MobilePushService.instance.notice ??
                        'Relevant approved jobs on this device'),
                    value: MobilePushService.instance.enabled,
                    onChanged: MobilePushService.instance.setEnabled,
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${controller.unreadNotificationCount} unread',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  if (controller.unreadNotificationCount > 0)
                    TextButton.icon(
                      onPressed: controller.markAllNotificationsRead,
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      label: const Text('Mark all as read'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (controller.notifications.isEmpty)
                const _EmptyNotifications()
              else
                for (var index = 0;
                    index < controller.notifications.length;
                    index++) ...[
                  _NotificationCard(
                    notification: controller.notifications[index],
                    onOpen: () async {
                      final notification = controller.notifications[index];
                      await controller.markNotificationRead(notification);
                      if (context.mounted && notification.actionRoute != null) {
                        Navigator.pushNamed(context, notification.actionRoute!);
                      }
                    },
                  ),
                  if (index != controller.notifications.length - 1)
                    const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onOpen});

  final NotificationModel notification;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final icon = switch (notification.type) {
      'interview' => Icons.event_available_outlined,
      'application' => Icons.assignment_turned_in_outlined,
      'profile' => Icons.person_outline_rounded,
      'recommendation' => Icons.auto_awesome_rounded,
      _ => Icons.notifications_none_rounded,
    };
    final color = switch (notification.type) {
      'interview' => AppColors.yellow,
      'application' => AppColors.blue,
      'profile' => AppColors.purple,
      'recommendation' => AppColors.green,
      _ => AppColors.cyan,
    };
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.card
              : color.withValues(alpha: .065),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notification.isRead
                ? AppColors.borderMuted
                : color.withValues(alpha: .28),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(notification.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800))),
                      if (!notification.isRead)
                        Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(notification.message,
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          height: 1.5)),
                  const SizedBox(height: 10),
                  Text(_relativeTime(notification.createdAt),
                      style: const TextStyle(
                          color: AppColors.textSubtle, fontSize: 10)),
                ],
              ),
            ),
            if (notification.actionRoute != null) ...[
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSubtle, size: 14),
            ],
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes.clamp(1, 59)} min ago';
    }
    if (difference.inHours < 24) return '${difference.inHours} hr ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderMuted)),
      child: const Column(
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 46, color: AppColors.textMuted),
          SizedBox(height: 14),
          Text('No notifications yet',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          SizedBox(height: 7),
          Text(
              'Job matches, application updates, and interview alerts will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
