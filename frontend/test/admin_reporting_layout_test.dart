import 'package:career_bridge/app/theme/app_theme.dart';
import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/admin/controllers/admin_workspace_controller.dart';
import 'package:career_bridge/features/admin/presentation/pages/job_approval_page.dart';
import 'package:career_bridge/features/admin/presentation/pages/employer_verification_page.dart';
import 'package:career_bridge/features/admin/presentation/pages/reports_page.dart';
import 'package:career_bridge/features/admin/presentation/pages/company_management_page.dart';
import 'package:career_bridge/features/admin/presentation/pages/user_management_page.dart';
import 'package:career_bridge/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:career_bridge/features/admin/presentation/pages/category_management_page.dart';
import 'package:career_bridge/features/admin/presentation/pages/salary_insights_management_page.dart';
import 'package:career_bridge/features/admin/presentation/pages/admin_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/admin_auth_fixture.dart';

void main() {
  for (final width in [320.0, 390.0, 768.0, 1440.0]) {
    testWidgets('all Admin pages keep actions readable at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await AuthController.instance
          .resetForTesting(repository: AdminAuthFixture());
      AdminWorkspaceController.instance.resetForTesting();
      await AuthController.instance.signIn(
          email: 'admin@tests.invalid',
          password: 'TestOnly123!',
          expectedRole: UserRole.admin);
      for (final page in const <Widget>[
        JobApprovalPage(),
        EmployerVerificationPage(),
        ReportsPage(),
        CompanyManagementPage(),
        UserManagementPage(),
        AdminDashboardPage(),
        CategoryManagementPage(),
        SalaryInsightsManagementPage(),
        AdminSettingsPage(),
      ]) {
        await tester.pumpWidget(MaterialApp(theme: AppTheme.dark, home: page));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: '${page.runtimeType} at $width');
        for (final text in find
            .descendant(
                of: find.byType(ButtonStyleButton), matching: find.byType(Text))
            .evaluate()) {
          final widget = text.widget as Text;
          if (widget.data == null) continue;
          final box = text.renderObject;
          if (box is RenderBox && box.hasSize) {
            final painter = TextPainter(
                text: TextSpan(
                    text: widget.data,
                    style: DefaultTextStyle.of(text).style.merge(widget.style)),
                textDirection: TextDirection.ltr)
              ..layout();
            expect(box.size.width, greaterThanOrEqualTo(painter.width - 1),
                reason: '${widget.data} splits at $width');
          }
        }
        await tester.pumpWidget(const SizedBox());
      }
    });
  }
}
