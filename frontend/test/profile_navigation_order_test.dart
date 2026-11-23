import 'package:career_bridge/app/router/app_router.dart';
import 'package:career_bridge/app/router/app_routes.dart';
import 'package:career_bridge/app/theme/app_theme.dart';
import 'package:career_bridge/core/enums/user_role.dart';
import 'package:career_bridge/features/admin/presentation/widgets/admin_navigation.dart';
import 'package:career_bridge/features/auth/controllers/auth_controller.dart';
import 'package:career_bridge/features/employer/controllers/employer_workspace_controller.dart';
import 'package:career_bridge/features/employer/presentation/widgets/employer_navigation.dart';
import 'package:career_bridge/features/job_seeker/controllers/job_seeker_workspace_controller.dart';
import 'package:career_bridge/features/job_seeker/presentation/widgets/job_seeker_navigation.dart';
import 'package:career_bridge/features/public_portal/controllers/public_portal_controller.dart';
import 'package:career_bridge/shared/layouts/dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Sora');
    for (final weight in [400, 500, 600, 700, 800]) {
      fonts.addFont(rootBundle.load('assets/fonts/Sora-$weight.ttf'));
    }
    await fonts.load();
  });
  for (final width in [320.0, 360.0, 390.0]) {
    for (final scale in [1.0, 1.3, 1.5, 2.0]) {
      for (final role in UserRole.values) {
        testWidgets(
            '${role.name} mobile tabs keep one aligned line at $width / $scale',
            (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await _pumpNavigation(tester,
              role: role, selectedIndex: 0, textScale: scale);
          final barFinder = find.byType(NavigationBar);
          final bar = tester.widget<NavigationBar>(barFinder);
          final barBounds = tester.getRect(barFinder);
          final iconCenters = <double>[];
          final labelCenters = <double>[];
          final cellWidths = <double>[];
          for (final destination in bar.destinations) {
            final cell = find.byWidget(destination);
            final bounds = tester.getRect(cell);
            cellWidths.add(bounds.width);
            expect(bounds.width, greaterThanOrEqualTo(48));
            expect(bounds.height, greaterThanOrEqualTo(48));
            final text = find.descendant(of: cell, matching: find.byType(Text));
            final paragraph = tester.renderObject<RenderParagraph>(text);
            final boxes = paragraph.getBoxesForSelection(TextSelection(
                baseOffset: 0,
                extentOffset: paragraph.text.toPlainText().length));
            expect(boxes.map((box) => box.top).toSet(), hasLength(1),
                reason: '${paragraph.text.toPlainText()} must use one line');
            expect(paragraph.textScaler.scale(10), closeTo(scale * 10, .01),
                reason: 'Mobile labels must respect the chosen text size');
            final labelBounds = tester.getRect(text);
            expect(labelBounds.left, greaterThanOrEqualTo(bounds.left));
            expect(labelBounds.right, lessThanOrEqualTo(bounds.right));
            expect(labelBounds.bottom, lessThanOrEqualTo(barBounds.bottom));
            labelCenters.add(labelBounds.center.dy);
            iconCenters.add(tester
                .getCenter(find
                    .descendant(of: cell, matching: find.byType(Icon))
                    .first)
                .dy);
          }
          for (var index = 1; index < cellWidths.length; index++) {
            expect(cellWidths[index], closeTo(cellWidths.first, .01));
            expect(iconCenters[index], closeTo(iconCenters.first, .01));
            expect(labelCenters[index], closeTo(labelCenters.first, .01));
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  for (final width in [320.0, 360.0, 390.0]) {
    for (final role in [UserRole.jobSeeker, UserRole.employer]) {
      testWidgets('${role.name} shows a readable fourth profile tab at $width',
          (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final seeker = role == UserRole.jobSeeker;
        await _pumpNavigation(tester, role: role, selectedIndex: 3);

        final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(bar.selectedIndex, 3);
        expect(
          _bottomLabels(tester),
          seeker
              ? ['Home', 'Jobs', 'Saved', 'Profile', 'More']
              : ['Home', 'Post', 'Jobs', 'Company', 'More'],
        );
        final barBounds = tester.getRect(find.byType(NavigationBar));
        for (final label in _bottomLabels(tester)) {
          final finder = find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          );
          final paragraph = tester.renderObject<RenderParagraph>(finder);
          expect(paragraph.maxLines, 1,
              reason: '$label must stay on one line at $width');
          final bounds = tester.getRect(finder);
          expect(bounds.left, greaterThanOrEqualTo(barBounds.left));
          expect(bounds.right, lessThanOrEqualTo(barBounds.right));
          expect(bounds.bottom, lessThanOrEqualTo(barBounds.bottom));
        }
        expect(tester.takeException(), isNull);

        await tester.tap(find.text(seeker ? 'Profile' : 'Company'));
        await tester.pumpAndSettle();
        expect(
          find.text(seeker
              ? AppRoutes.jobSeekerProfile
              : AppRoutes.employerCompanyProfile),
          findsOneWidget,
        );
      });
    }
  }

  testWidgets('More preserves the requested job seeker workspace order',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpNavigation(tester, role: UserRole.jobSeeker, selectedIndex: 4);
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        4);
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(_menuLabels(tester), [
      'Overview',
      'Find Jobs',
      'Saved Jobs',
      'Profile',
      'Applications',
      'CV Builder',
      'Notifications',
    ]);
    expect(_selectedMenuLabel(tester), 'Applications');
    await tester.tap(find.widgetWithText(ListTile, 'CV Builder'));
    await tester.pumpAndSettle();
    expect(find.text(AppRoutes.jobSeekerCvBuilder), findsOneWidget);
  });

  testWidgets('More preserves the requested employer workspace order',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpNavigation(tester, role: UserRole.employer, selectedIndex: 4);
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        4);
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(_menuLabels(tester), [
      'Overview',
      'Post a Job',
      'Manage Jobs',
      'Company Profile',
      'Applicants',
      'Interviews',
      'Notifications',
      'Find Jobs',
    ]);
    expect(_selectedMenuLabel(tester), 'Applicants');
    await tester.tap(find.widgetWithText(ListTile, 'Interviews'));
    await tester.pumpAndSettle();
    expect(find.text(AppRoutes.employerInterviews), findsOneWidget);
  });

  testWidgets('admin retains its first three destinations and More',
      (tester) async {
    await _pumpNavigation(tester, role: UserRole.admin, selectedIndex: 3);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 3);
    expect(
      _bottomLabels(tester),
      ['Home', 'Employers', 'Approvals', 'More'],
    );
  });

  for (final role in UserRole.values) {
    testWidgets('${role.name} tabs retain full accessible destination names',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pumpNavigation(tester,
          role: role,
          selectedIndex: role == UserRole.admin ? 2 : 3,
          textScale: 2,
          bottomPadding: 24);
      final labels = switch (role) {
        UserRole.jobSeeker => [
            'Overview',
            'Find Jobs',
            'Saved Jobs',
            'Profile',
            'More'
          ],
        UserRole.employer => [
            'Overview',
            'Post a Job',
            'Manage Jobs',
            'Company Profile',
            'More'
          ],
        UserRole.admin => [
            'Overview',
            'Employer Verification',
            'Job Approvals',
            'More'
          ],
      };
      for (final label in labels) {
        expect(find.byTooltip(label), findsOneWidget);
        expect(find.bySemanticsLabel(label), findsOneWidget);
        final node = tester.getSemantics(find.bySemanticsLabel(label));
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        expect(node.flagsCollection.isSelected.toBoolOrNull(),
            labels.indexOf(label) == (role == UserRole.admin ? 2 : 3));
      }
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      for (final destination in bar.destinations) {
        expect(tester.getRect(find.byWidget(destination)).bottom,
            lessThanOrEqualTo(776));
      }
      await tester.tap(find.byTooltip(labels.first));
      await tester.pumpAndSettle();
      expect(
          find.text(switch (role) {
            UserRole.jobSeeker => AppRoutes.jobSeekerDashboard,
            UserRole.employer => AppRoutes.employerDashboard,
            UserRole.admin => AppRoutes.adminDashboard,
          }),
          findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }

  group('workspace pages retain the correct selected destination', () {
    setUp(() async {
      await AuthController.instance.resetForTesting();
      JobSeekerWorkspaceController.instance.resetForTesting();
      EmployerWorkspaceController.instance.resetForTesting();
      PublicPortalController.instance.resetForTesting();
      await PublicPortalController.instance.initialize();
    });

    for (final role in [UserRole.jobSeeker, UserRole.employer]) {
      testWidgets('${role.name} list and detail pages select their parent tab',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final seeker = role == UserRole.jobSeeker;
        await tester.runAsync(() => AuthController.instance.signIn(
              email: '${seeker ? 'jobseeker' : 'employer'}@careerbridge.demo',
              password: 'Demo123!',
            ));
        await tester.runAsync(() => seeker
            ? JobSeekerWorkspaceController.instance.ensureLoaded()
            : EmployerWorkspaceController.instance.ensureLoaded());
        final pages = seeker
            ? [
                (AppRoutes.jobSeekerProfile, 'Profile', 3),
                (AppRoutes.jobSeekerApplications, 'Applications', 4),
                (
                  AppRoutes.jobSeekerApplicationDetails('missing'),
                  'Applications',
                  4
                ),
                (AppRoutes.jobSeekerCvBuilder, 'CV Builder', 4),
                (AppRoutes.jobSeekerNotifications, 'Notifications', 4),
              ]
            : [
                (AppRoutes.employerCompanyProfile, 'Company Profile', 3),
                (AppRoutes.employerApplicants, 'Applicants', 4),
                (
                  AppRoutes.employerApplicantDetails('missing'),
                  'Applicants',
                  4
                ),
                (AppRoutes.employerInterviews, 'Interviews', 4),
                (AppRoutes.employerNotifications, 'Notifications', 4),
              ];
        final navigator = GlobalKey<NavigatorState>();
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.dark,
          navigatorKey: navigator,
          onGenerateInitialRoutes: (_) => [
            AppRouter.onGenerateRoute(RouteSettings(name: pages.first.$1)),
          ],
          onGenerateRoute: AppRouter.onGenerateRoute,
        ));
        for (var index = 0; index < pages.length; index++) {
          final (route, label, bottomIndex) = pages[index];
          if (index > 0) navigator.currentState!.pushReplacementNamed(route);
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          expect(
              tester
                  .widget<NavigationBar>(find.byType(NavigationBar))
                  .selectedIndex,
              bottomIndex,
              reason: route);
          await tester.tap(find.descendant(
              of: find.byType(NavigationBar), matching: find.text('More')));
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          expect(_selectedMenuLabel(tester), label, reason: route);
          navigator.currentState!.pop();
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          expect(tester.takeException(), isNull, reason: route);
        }
      });
    }
  });
}

Future<void> _pumpNavigation(WidgetTester tester,
    {required UserRole role,
    required int selectedIndex,
    double textScale = 1.2,
    double bottomPadding = 0}) async {
  final items = switch (role) {
    UserRole.jobSeeker => JobSeekerNavigation.items,
    UserRole.employer => EmployerNavigation.items,
    UserRole.admin => AdminNavigation.items,
  };
  final shell = DashboardShell(
    role: role,
    title: '',
    subtitle: '',
    items: items,
    selectedIndex: selectedIndex,
    body: const SizedBox.shrink(),
  );
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.dark,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          padding: EdgeInsets.only(bottom: bottomPadding)),
      child: child!,
    ),
    home: Builder(
        builder: (context) => Scaffold(
              bottomNavigationBar: shell.mobileNavigationBar(context),
            )),
    onGenerateRoute: (settings) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Scaffold(body: Text(settings.name!)),
    ),
  ));
  await tester.pumpAndSettle();
}

List<String> _bottomLabels(WidgetTester tester) => tester
    .widgetList<Text>(find.descendant(
        of: find.byType(NavigationBar), matching: find.byType(Text)))
    .map((text) => text.data!)
    .toList();

List<String> _menuLabels(WidgetTester tester) => tester
    .widgetList<ListTile>(find.byType(ListTile))
    .map((tile) => (tile.title! as Text).data!)
    .toList();

String _selectedMenuLabel(WidgetTester tester) => (tester
        .widgetList<ListTile>(find.byType(ListTile))
        .singleWhere((tile) => tile.selected)
        .title! as Text)
    .data!;
