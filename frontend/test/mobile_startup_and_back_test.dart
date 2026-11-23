import 'dart:async';
import 'package:career_bridge/app/config/app_mode.dart';
import 'package:career_bridge/app/mobile_bootstrap.dart';
import 'package:career_bridge/app/router/app_router.dart';
import 'package:career_bridge/app/router/app_routes.dart';
import 'package:career_bridge/app/theme/app_theme.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/auth/presentation/pages/access_denied_page.dart';
import 'package:career_bridge/features/auth/presentation/pages/admin_login_page.dart';
import 'package:career_bridge/features/job_seeker/controllers/job_seeker_workspace_controller.dart';
import 'package:career_bridge/features/job_seeker/presentation/pages/job_seeker_dashboard_page.dart';
import 'package:career_bridge/features/public_portal/controllers/public_portal_controller.dart';
import 'package:career_bridge/features/public_portal/presentation/pages/landing_page.dart';
import 'package:career_bridge/features/public_portal/presentation/pages/startup_intro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await AuthController.instance.resetForTesting();
    JobSeekerWorkspaceController.instance.resetForTesting();
    PublicPortalController.instance.resetForTesting();
    await PublicPortalController.instance.initialize();
  });
  testWidgets('branding is visible while initialization is pending',
      (tester) async {
    final ready = Completer<void>();
    await tester
        .pumpWidget(CareerBridgeBootstrap(initialize: () => ready.future));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    ready.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  for (final reducedMotion in [false, true]) {
    testWidgets(
        'intro preserves restored destination after two seconds '
        '(reduced motion: $reducedMotion)', (tester) async {
      await tester.runAsync(() => AuthController.instance
          .signIn(email: 'jobseeker@careerbridge.demo', password: 'Demo123!'));
      await _pumpIntro(tester, reducedMotion: reducedMotion);
      await tester.pump(const Duration(milliseconds: 1999));
      expect(find.byType(StartupIntroPage), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(StartupIntroPage), findsNothing);
      expect(
          find.byType(
              AppMode.adminOnly ? AccessDeniedPage : JobSeekerDashboardPage),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('signed-out intro opens the correct public or admin sign-in page',
      (tester) async {
    await _pumpIntro(tester, reducedMotion: true);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(StartupIntroPage), findsNothing);
    expect(find.byType(AppMode.adminOnly ? AdminLoginPage : LandingPage),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('disposing intro cancels its pending navigation timer',
      (tester) async {
    final replacedRoutes = <String?>[];
    await tester.pumpWidget(MaterialApp(
      home: const StartupIntroPage(),
      navigatorObservers: [_ReplacementObserver(replacedRoutes)],
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    // Finish before the deadline: the test binding rejects any timer left
    // running after disposal, even when its callback has a mounted guard.
    await tester.pump(const Duration(milliseconds: 100));
    expect(replacedRoutes, isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Android root back asks to exit and cancel retains workspace',
      (tester) async {
    await tester.runAsync(() => AuthController.instance
        .signIn(email: 'jobseeker@careerbridge.demo', password: 'Demo123!'));
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        onGenerateInitialRoutes: (_) => [
              AppRouter.onGenerateRoute(
                  const RouteSettings(name: AppRoutes.jobSeekerDashboard))
            ],
        onGenerateRoute: AppRouter.onGenerateRoute));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Exit Career Bridge?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Exit Career Bridge?'), findsNothing);
  }, skip: AppMode.adminOnly);
}

Future<void> _pumpIntro(WidgetTester tester,
    {required bool reducedMotion}) async {
  await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      onGenerateInitialRoutes: (_) => [
            MaterialPageRoute<void>(
                settings: const RouteSettings(name: '/startup-intro'),
                builder: (_) => MediaQuery(
                    data: MediaQueryData(disableAnimations: reducedMotion),
                    child: const StartupIntroPage()))
          ],
      onGenerateRoute: AppRouter.onGenerateRoute));
  await tester.pump();
}

class _ReplacementObserver extends NavigatorObserver {
  _ReplacementObserver(this.replacedRoutes);
  final List<String?> replacedRoutes;
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacedRoutes.add(newRoute?.settings.name);
  }
}
