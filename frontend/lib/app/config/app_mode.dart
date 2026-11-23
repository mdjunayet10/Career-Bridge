import '../router/app_routes.dart';

abstract final class AppMode {
  static const adminOnly = bool.fromEnvironment('ADMIN_APP');
  static String routeFor(String route,
      {required bool adminOnly, required bool authenticatedAdmin}) {
    if (!adminOnly) return route;
    if (!authenticatedAdmin) return AppRoutes.adminLogin;
    return route.startsWith('/admin/') && route != AppRoutes.adminLogin
        ? route
        : AppRoutes.adminDashboard;
  }
}
