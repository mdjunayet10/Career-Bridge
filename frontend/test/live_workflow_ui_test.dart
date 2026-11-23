import 'package:career_bridge/features/jobs/presentation/pages/job_details_page.dart';
import 'package:career_bridge/app/theme/app_theme.dart';
import 'package:career_bridge/core/enums/application_status.dart';
import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/employer/controllers/employer_workspace_controller.dart';
import 'package:career_bridge/features/employer/presentation/pages/applicants_page.dart';
import 'package:career_bridge/features/job_seeker/controllers/job_seeker_workspace_controller.dart';
import 'package:career_bridge/features/jobs/presentation/pages/job_list_page.dart';
import 'package:career_bridge/features/jobs/presentation/widgets/public_job_card.dart';
import 'package:career_bridge/features/public_portal/controllers/public_portal_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await AuthController.instance.resetForTesting();
    EmployerWorkspaceController.instance.resetForTesting();
    JobSeekerWorkspaceController.instance.resetForTesting();
    PublicPortalController.instance.resetForTesting();
    await PublicPortalController.instance.initialize();
  });
  testWidgets('applicant can be shortlisted directly on the applicant list',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      await AuthController.instance.signIn(
          email: 'employer@careerbridge.demo',
          password: 'Demo123!',
          expectedRole: UserRole.employer);
      await EmployerWorkspaceController.instance.ensureLoaded();
    });
    final candidate = EmployerWorkspaceController.instance.applications
        .firstWhere((a) => a.status == ApplicationStatus.applied);
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const ApplicantsPage()));
    await tester.pumpAndSettle();
    final actions = find.byKey(ValueKey('applicant-actions-${candidate.id}'));
    expect(actions, findsOneWidget);
    final shortlist =
        find.descendant(of: actions, matching: find.text('Shortlist'));
    await tester.ensureVisible(shortlist);
    await tester.tap(shortlist);
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 600)));
    await tester.pumpAndSettle();
    expect(
        EmployerWorkspaceController.instance
            .applicationById(candidate.id)
            ?.status,
        ApplicationStatus.shortlisted);
    expect(find.byType(ApplicantsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'all jobs and recommended choices are visible and sample cards open details',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? opened;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: const JobListPage(),
        onGenerateRoute: (settings) {
          opened = settings.name;
          return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Job details test')));
        }));
    await tester.pumpAndSettle();
    expect(find.text('All Jobs'), findsWidgets);
    expect(find.text('Recommended'), findsWidgets);
    final card = find.byType(PublicJobCard).first;
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(opened, startsWith('/jobs/'));
  });
  testWidgets('interview and selection are handled from visible list actions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      await AuthController.instance.signIn(
          email: 'employer@careerbridge.demo',
          password: 'Demo123!',
          expectedRole: UserRole.employer);
      await EmployerWorkspaceController.instance.ensureLoaded();
    });
    final controller = EmployerWorkspaceController.instance;
    final candidate = controller.applications
        .firstWhere((a) => a.status == ApplicationStatus.applied);
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const ApplicantsPage()));
    await tester.pumpAndSettle();
    Finder button(String label) => find.descendant(
        of: find.byKey(ValueKey('applicant-actions-${candidate.id}')),
        matching: find.text(label));
    await tester.ensureVisible(button('Interview'));
    await tester.tap(button('Interview'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule interview'), findsOneWidget);
    await tester.tap(find.text('Schedule & notify'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 600)));
    await tester.pumpAndSettle();
    expect(controller.applicationById(candidate.id)?.status,
        ApplicationStatus.interview);
    expect(
        controller
            .applicationById(candidate.id)
            ?.interviewAt
            ?.isAfter(DateTime.now()),
        isTrue);
    await tester.ensureVisible(button('Select'));
    await tester.tap(button('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select candidate'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 600)));
    await tester.pumpAndSettle();
    expect(controller.applicationById(candidate.id)?.status,
        ApplicationStatus.hired);
    expect(tester.takeException(), isNull);
  });
  testWidgets('guest can enter a clearly isolated demo application flow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: const JobDetailsPage(jobId: 'mobile-intern-novatech')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Apply now'));
    await tester.tap(find.text('Apply now'));
    await tester.pumpAndSettle();
    expect(find.text('Try a demo application'), findsOneWidget);
    await tester.tap(find.text('Use demo & apply'));
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpAndSettle();
    expect(AuthController.instance.usesFirebase, isFalse);
    expect(AuthController.instance.currentUser?.role, UserRole.jobSeeker);
    expect(find.text('Submit application'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
