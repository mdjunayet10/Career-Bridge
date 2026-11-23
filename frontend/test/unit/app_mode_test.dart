import 'package:career_bridge/app/config/app_mode.dart';
import 'package:career_bridge/app/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin route policy excludes public and role-registration screens', () {
    expect(
        AppMode.routeFor('/jobs', adminOnly: true, authenticatedAdmin: false),
        AppRoutes.adminLogin);
    expect(AppMode.routeFor('/', adminOnly: true, authenticatedAdmin: true),
        AppRoutes.adminDashboard);
    expect(
        AppMode.routeFor('/admin/users',
            adminOnly: true, authenticatedAdmin: true),
        '/admin/users');
    expect(
        AppMode.routeFor('/admin/users',
            adminOnly: true, authenticatedAdmin: false),
        AppRoutes.adminLogin);
    expect(
        AppMode.routeFor('/jobs', adminOnly: false, authenticatedAdmin: false),
        '/jobs');
  });
}
