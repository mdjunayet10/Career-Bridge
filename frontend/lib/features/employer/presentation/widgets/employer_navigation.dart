import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/layouts/dashboard_shell.dart';

abstract final class EmployerNavigation {
  static const items = [
    DashboardNavItem(
      label: 'Overview',
      icon: Icons.dashboard_outlined,
      route: AppRoutes.employerDashboard,
    ),
    DashboardNavItem(
      label: 'Post a Job',
      icon: Icons.add_circle_outline_rounded,
      route: AppRoutes.employerPostJob,
    ),
    DashboardNavItem(
      label: 'Manage Jobs',
      icon: Icons.work_outline_rounded,
      route: AppRoutes.employerManageJobs,
    ),
    DashboardNavItem(
      label: 'Company Profile',
      icon: Icons.apartment_rounded,
      route: AppRoutes.employerCompanyProfile,
    ),
    DashboardNavItem(
      label: 'Applicants',
      icon: Icons.groups_2_outlined,
      route: AppRoutes.employerApplicants,
    ),
    DashboardNavItem(
      label: 'Interviews',
      icon: Icons.event_outlined,
      route: AppRoutes.employerInterviews,
    ),
    DashboardNavItem(
      label: 'Notifications',
      icon: Icons.notifications_none_rounded,
      route: AppRoutes.employerNotifications,
    ),
    DashboardNavItem(
      label: 'Find Jobs',
      icon: Icons.search_rounded,
      route: AppRoutes.jobs,
    ),
  ];
}
