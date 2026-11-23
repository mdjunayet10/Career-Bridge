import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/layouts/dashboard_shell.dart';

abstract final class JobSeekerNavigation {
  static const items = [
    DashboardNavItem(
      label: 'Overview',
      icon: Icons.dashboard_outlined,
      route: AppRoutes.jobSeekerDashboard,
    ),
    DashboardNavItem(
      label: 'Find Jobs',
      icon: Icons.search_rounded,
      route: AppRoutes.jobs,
    ),
    DashboardNavItem(
      label: 'Saved Jobs',
      icon: Icons.bookmark_border_rounded,
      route: AppRoutes.jobSeekerSavedJobs,
    ),
    DashboardNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      route: AppRoutes.jobSeekerProfile,
    ),
    DashboardNavItem(
      label: 'Applications',
      icon: Icons.assignment_outlined,
      route: AppRoutes.jobSeekerApplications,
    ),
    DashboardNavItem(
      label: 'CV Builder',
      icon: Icons.description_outlined,
      route: AppRoutes.jobSeekerCvBuilder,
    ),
    DashboardNavItem(
      label: 'Notifications',
      icon: Icons.notifications_none_rounded,
      route: AppRoutes.jobSeekerNotifications,
    ),
  ];
}
