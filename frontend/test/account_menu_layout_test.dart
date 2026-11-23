import 'package:career_bridge/app/theme/app_theme.dart';
import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/shared/layouts/dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => AuthController.instance.resetForTesting());

  testWidgets('account actions remain reachable in landscape with large text',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(568, 320));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(2)),
        child: child!,
      ),
      home: const DashboardShell(
        role: UserRole.jobSeeker,
        title: 'Workspace',
        subtitle: '',
        items: [
          DashboardNavItem(label: 'Home', icon: Icons.home_outlined),
          DashboardNavItem(label: 'Jobs', icon: Icons.work_outline),
        ],
        body: SizedBox.shrink(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull,
        reason: 'The account menu must scroll instead of overflowing.');

    final signOut = find.widgetWithText(FilledButton, 'Sign out');
    await tester.scrollUntilVisible(signOut, 80,
        scrollable: find.descendant(
            of: find.byType(BottomSheet), matching: find.byType(Scrollable)));
    expect(signOut.hitTestable(), findsOneWidget);
    final signOutBounds = tester.getRect(signOut);
    expect(signOutBounds.top, greaterThanOrEqualTo(0));
    expect(signOutBounds.bottom, lessThanOrEqualTo(320));
    expect(tester.takeException(), isNull);
  });
}
