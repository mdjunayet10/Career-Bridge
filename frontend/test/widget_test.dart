import 'support/admin_auth_fixture.dart';
import 'package:career_bridge/app/app.dart';
import 'package:career_bridge/app/router/app_routes.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/admin/controllers/admin_workspace_controller.dart';
import 'package:career_bridge/features/job_seeker/controllers/job_seeker_workspace_controller.dart';
import 'package:career_bridge/features/public_portal/controllers/public_portal_controller.dart';
import 'package:career_bridge/features/employer/controllers/employer_workspace_controller.dart';
import 'package:career_bridge/core/enums/application_status.dart';
import 'package:career_bridge/core/enums/employer_job_status.dart';
import 'package:career_bridge/core/enums/employer_verification_status.dart';
import 'package:career_bridge/core/enums/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await AuthController.instance.resetForTesting();
    JobSeekerWorkspaceController.instance.resetForTesting();
    EmployerWorkspaceController.instance.resetForTesting();
    AdminWorkspaceController.instance.resetForTesting();
    PublicPortalController.instance.resetForTesting();
    await PublicPortalController.instance.initialize();
  });

  testWidgets('landing page renders Career Bridge hero', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CareerBridgeApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Find the work that'), findsOneWidget);
    expect(find.text('Search jobs'), findsOneWidget);
  });

  testWidgets('public navigation opens the job listing page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CareerBridgeApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Find Jobs').first);
    await tester.pumpAndSettle();

    expect(find.text('Search opportunities with clearer details.'),
        findsOneWidget);
    expect(find.textContaining('opportunities found'), findsOneWidget);
  });

  testWidgets('job card opens a detailed job page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CareerBridgeApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/jobs/flutter-developer-novatech');
    await tester.pumpAndSettle();

    expect(find.text('Flutter Developer'), findsWidgets);
    expect(find.text('About the role'), findsOneWidget);
    expect(find.text('Apply now'), findsOneWidget);
  });

  testWidgets('job seeker demo sign-in routes to protected dashboard',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CareerBridgeApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(AppRoutes.login);
    await tester.pumpAndSettle();

    expect(find.text('Continue your career journey.'), findsOneWidget);
    await tester.tap(find.text('Use').first);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Good morning, Ayan.'), findsOneWidget);
    expect(find.text('Recommended for you'), findsOneWidget);
  });

  testWidgets('pending employer is routed to verification status page',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CareerBridgeApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(AppRoutes.employerLogin);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Orbit Labs').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use'));
    await tester.pump();
    await tester
        .tap(find.widgetWithText(FilledButton, 'Sign in to Employer Portal'));
    await tester.pumpAndSettle();

    expect(find.text('Company verification is pending.'), findsOneWidget);
    expect(find.textContaining('Orbit Labs'), findsOneWidget);
  });

  testWidgets(
      'admin dashboard route presents hidden admin login when signed out',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CareerBridgeApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(AppRoutes.adminDashboard);
    await tester.pumpAndSettle();

    expect(find.text('Career Bridge administration.'), findsOneWidget);
    expect(find.text('ADMIN CONTROL PANEL'), findsOneWidget);
  });
  test(
      'demo Job Seeker workspace loads profile, applications, saved jobs, and CV data',
      () async {
    await AuthController.instance.signIn(
      email: 'jobseeker@careerbridge.demo',
      password: 'Demo123!',
      expectedRole: UserRole.jobSeeker,
    );
    final workspace = JobSeekerWorkspaceController.instance;
    await workspace.ensureLoaded();

    expect(workspace.profile?.completionPercent, greaterThan(50));
    expect(workspace.savedJobIds, contains('flutter-developer-novatech'));
    expect(workspace.applications.length, 3);
    expect(
      workspace.notifications.map((notification) => notification.id),
      containsAll([
        'recommendation-demo-flutter',
        'notification-interview',
        'notification-shortlist',
      ]),
    );
    expect(workspace.unreadNotificationCount, greaterThanOrEqualTo(3));
    expect(workspace.cvProfile?.skills, contains('Flutter'));
  });

  test('demo Job Seeker can submit and withdraw an application', () async {
    await AuthController.instance.signIn(
      email: 'jobseeker@careerbridge.demo',
      password: 'Demo123!',
      expectedRole: UserRole.jobSeeker,
    );
    final workspace = JobSeekerWorkspaceController.instance;
    await workspace.ensureLoaded();

    final job = PublicPortalController.instance.jobs
        .firstWhere((job) => workspace.applicationForJob(job.id) == null);
    expect(job.isSample, isTrue);
    final application = await workspace.submitApplication(
      job: job,
      coverLetter:
          'I have product design experience and enjoy building clear user journeys.',
    );
    expect(workspace.applicationForJob(job.id), isNotNull);

    await workspace.withdrawApplication(application);
    expect(workspace.applicationById(application.id)?.status.name, 'withdrawn');
  });

  test(
      'demo Employer workspace loads company, jobs, applicants, and notifications',
      () async {
    await AuthController.instance.signIn(
      email: 'employer@careerbridge.demo',
      password: 'Demo123!',
      expectedRole: UserRole.employer,
    );
    final workspace = EmployerWorkspaceController.instance;
    await workspace.ensureLoaded();

    expect(workspace.company?.name, 'NovaTech Bangladesh (Demo)');
    expect(workspace.liveJobCount, 3);
    expect(workspace.pendingJobCount, 1);
    expect(workspace.applications.length, 8);
    expect(workspace.interviewCount, 1);
    expect(workspace.unreadNotificationCount, 2);
  });

  test('demo Employer can save a draft and move a candidate in the pipeline',
      () async {
    await AuthController.instance.signIn(
      email: 'employer@careerbridge.demo',
      password: 'Demo123!',
      expectedRole: UserRole.employer,
    );
    final workspace = EmployerWorkspaceController.instance;
    await workspace.ensureLoaded();

    final draft = workspace.jobs.first
        .copyWith(id: 'demo-test-draft', status: EmployerJobStatus.draft);
    final saved = await workspace.saveJob(
      draft.copyWith(title: 'Updated Mobile Engineering Intern'),
      submitForReview: false,
    );
    expect(saved.title, 'Updated Mobile Engineering Intern');
    expect(saved.status, EmployerJobStatus.draft);

    final candidate = workspace.applications.firstWhere(
      (application) => application.status == ApplicationStatus.applied,
    );
    await workspace.updateApplication(
      application: candidate,
      status: ApplicationStatus.reviewed,
      employerNote: 'Portfolio review started.',
    );
    expect(workspace.applicationById(candidate.id)?.status,
        ApplicationStatus.reviewed);
  });

  test(
      'Admin fixture workspace loads moderation, user, and platform-management data',
      () async {
    await AuthController.instance
        .resetForTesting(repository: AdminAuthFixture());
    await AuthController.instance.signIn(
      email: 'admin@tests.invalid',
      password: 'TestOnly123!',
      expectedRole: UserRole.admin,
    );
    final workspace = AdminWorkspaceController.instance;
    await workspace.ensureLoaded();

    expect(workspace.totalUsers, greaterThanOrEqualTo(8));
    expect(workspace.pendingEmployerCount, 1);
    expect(workspace.pendingJobCount, greaterThanOrEqualTo(3));
    expect(workspace.openReportCount, 3);
    expect(workspace.categories.length, 6);
    expect(workspace.salaryInsights.length, 5);
    expect(workspace.settings?.platformName, 'Career Bridge');
  });

  test('Admin fixture can approve an Employer and publish an eligible job',
      () async {
    await AuthController.instance
        .resetForTesting(repository: AdminAuthFixture());
    await AuthController.instance.signIn(
      email: 'admin@tests.invalid',
      password: 'TestOnly123!',
      expectedRole: UserRole.admin,
    );
    final workspace = AdminWorkspaceController.instance;
    await workspace.ensureLoaded();

    final pendingCompany = workspace.companies.firstWhere(
      (company) => company.status == EmployerVerificationStatus.pending,
    );
    await workspace.reviewEmployer(
      company: pendingCompany,
      status: EmployerVerificationStatus.approved,
      note: 'Identity verified in demo Admin test.',
    );
    expect(
      workspace.companyById(pendingCompany.companyId)?.status,
      EmployerVerificationStatus.approved,
    );

    final pendingJob = workspace.jobs.firstWhere(
      (job) =>
          job.status == EmployerJobStatus.pending &&
          workspace.companyById(job.companyId)?.status ==
              EmployerVerificationStatus.approved,
    );
    await workspace.reviewJob(
      job: pendingJob,
      status: EmployerJobStatus.published,
      note: 'Listing approved in demo Admin test.',
    );
    expect(
      workspace.jobs.firstWhere((job) => job.id == pendingJob.id).status,
      EmployerJobStatus.published,
    );
  });
}
