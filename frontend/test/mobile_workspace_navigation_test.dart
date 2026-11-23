import 'package:career_bridge/app/router/app_router.dart';
import 'package:career_bridge/app/router/app_routes.dart';
import 'package:career_bridge/app/theme/app_theme.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/public_portal/controllers/public_portal_controller.dart';
import 'package:career_bridge/features/job_seeker/controllers/job_seeker_workspace_controller.dart';
import 'package:career_bridge/features/employer/controllers/employer_workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await AuthController.instance.resetForTesting();
    JobSeekerWorkspaceController.instance.resetForTesting();
    EmployerWorkspaceController.instance.resetForTesting();
    PublicPortalController.instance.resetForTesting();
    await PublicPortalController.instance.initialize();
  });
  for (final role in ['jobseeker', 'employer']) {
    testWidgets('$role job browsing keeps navigation on list and detail',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.runAsync(() => AuthController.instance
          .signIn(email: '$role@careerbridge.demo', password: 'Demo123!'));
      if (role == 'jobseeker') {
        await tester.runAsync(
            () => JobSeekerWorkspaceController.instance.ensureLoaded());
      }
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
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
      final id = PublicPortalController.instance.jobs.first.id;
      key.currentState!.pushNamed(AppRoutes.jobDetails(id));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
      key.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
