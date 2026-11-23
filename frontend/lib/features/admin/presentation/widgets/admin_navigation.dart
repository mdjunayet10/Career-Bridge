import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/layouts/dashboard_shell.dart';

abstract final class AdminNavigation {
  static const items = [
    DashboardNavItem(
      label: 'Overview',
      icon: Icons.dashboard_outlined,
      route: AppRoutes.adminDashboard,
    ),
    DashboardNavItem(
      label: 'Employer Verification',
      icon: Icons.verified_user_outlined,
      route: AppRoutes.adminEmployerVerification,
    ),
    DashboardNavItem(
      label: 'Job Approvals',
      icon: Icons.fact_check_outlined,
      route: AppRoutes.adminJobApprovals,
    ),
    DashboardNavItem(
      label: 'Users',
      icon: Icons.people_outline_rounded,
      route: AppRoutes.adminUsers,
    ),
    DashboardNavItem(
      label: 'Companies',
      icon: Icons.apartment_rounded,
      route: AppRoutes.adminCompanies,
    ),
    DashboardNavItem(
      label: 'Reports',
      icon: Icons.flag_outlined,
      route: AppRoutes.adminReports,
    ),
    DashboardNavItem(
      label: 'Salary Insights',
      icon: Icons.payments_outlined,
      route: AppRoutes.adminSalaryInsights,
    ),
    DashboardNavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      route: AppRoutes.adminSettings,
    ),
  ];
}
