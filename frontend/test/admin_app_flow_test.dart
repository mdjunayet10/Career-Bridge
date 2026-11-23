import 'support/admin_auth_fixture.dart';
import 'package:career_bridge/app/config/app_mode.dart';
import 'package:career_bridge/app/router/app_router.dart';
import 'package:career_bridge/app/router/app_routes.dart';
import 'package:career_bridge/app/theme/app_theme.dart';
import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/auth/presentation/pages/admin_login_page.dart';
import 'package:career_bridge/features/admin/controllers/admin_workspace_controller.dart';
import 'package:career_bridge/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:career_bridge/features/public_portal/controllers/public_portal_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await AuthController.instance
        .resetForTesting(repository: AdminAuthFixture());
    AdminWorkspaceController.instance.resetForTesting();
    PublicPortalController.instance.resetForTesting();
    await PublicPortalController.instance.initialize();
  });
  testWidgets('separate admin app keeps public routes behind admin login',
      (tester) async {
    expect(AppMode.adminOnly, isTrue);
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        navigatorKey: key,
        onGenerateInitialRoutes: (_) => [
              AppRouter.onGenerateRoute(
                  const RouteSettings(name: AppRoutes.jobs))
            ],
        onGenerateRoute: AppRouter.onGenerateRoute));
    await tester.pumpAndSettle();
    expect(find.byType(AdminLoginPage), findsOneWidget);
    await tester.runAsync(() => AuthController.instance.signIn(
        email: 'admin@tests.invalid',
        password: 'TestOnly123!',
        expectedRole: UserRole.admin));
    key.currentState!.pushReplacementNamed(AppRoutes.home);
    await tester.pumpAndSettle();
    expect(find.byType(AdminDashboardPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.runAsync(() => AuthController.instance.signOut());
    key.currentState!.pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    await tester.pumpAndSettle();
    expect(find.byType(AdminLoginPage), findsOneWidget);
  }, skip: !AppMode.adminOnly);
}
