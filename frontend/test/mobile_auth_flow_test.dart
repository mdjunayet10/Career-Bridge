import 'package:career_bridge/app/router/app_router.dart';
import 'package:career_bridge/app/router/app_routes.dart';
import 'package:career_bridge/app/theme/app_theme.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:career_bridge/features/job_seeker/controllers/job_seeker_workspace_controller.dart';
import 'package:career_bridge/features/public_portal/controllers/public_portal_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await AuthController.instance.resetForTesting();
    JobSeekerWorkspaceController.instance.resetForTesting();
    PublicPortalController.instance.resetForTesting();
    await PublicPortalController.instance.initialize();
  });

  for (final width in [320.0, 360.0, 390.0]) {
    testWidgets('mobile authentication remains usable at ${width.toInt()}px',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        navigatorKey: navigator,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.2)),
          child: child!,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      await tester.ensureVisible(find.byType(GoogleSignInButton));
      expect(tester.getRect(find.byType(GoogleSignInButton)).width,
          lessThanOrEqualTo(width));
      expect(tester.takeException(), isNull);

      // Account recovery and both registration portals remain reachable.
      for (final route in [
        AppRoutes.forgotPassword,
        AppRoutes.jobSeekerRegister,
        AppRoutes.employerRegister,
        AppRoutes.employerLogin
      ]) {
        navigator.currentState!.pushNamed(route);
        await tester.pumpAndSettle();
        if (route != AppRoutes.forgotPassword) {
          expect(find.byType(GoogleSignInButton), findsOneWidget);
          await tester.ensureVisible(find.byType(GoogleSignInButton));
        }
        expect(tester.takeException(), isNull, reason: route);
        navigator.currentState!.pop();
        await tester.pumpAndSettle();
      }
      // An open keyboard must not hide the email/password sign-in action.
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      final email = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Email address');
      final password = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == 'Password');
      await tester.ensureVisible(email);
      await tester.enterText(email, 'jobseeker@careerbridge.demo');
      await tester.ensureVisible(password);
      await tester.enterText(password, 'Demo123!');
      await tester.pumpAndSettle();
      final signIn = find.widgetWithText(FilledButton, 'Sign in');
      await tester.ensureVisible(signIn);
      await tester.pumpAndSettle();
      await tester.tap(signIn);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(AuthController.instance.isAuthenticated, isTrue);
      expect(find.text('Recommended for you'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
