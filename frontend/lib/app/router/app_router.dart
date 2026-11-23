import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../core/responsive/breakpoints.dart';
import '../../shared/layouts/dashboard_shell.dart';
import '../../features/job_seeker/presentation/widgets/job_seeker_navigation.dart';
import '../../features/employer/presentation/widgets/employer_navigation.dart';

import '../../core/enums/employer_verification_status.dart';
import '../../core/enums/user_role.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_settings_page.dart';
import '../../features/admin/presentation/pages/category_management_page.dart';
import '../../features/admin/presentation/pages/company_management_page.dart';
import '../../features/admin/presentation/pages/employer_verification_page.dart';
import '../../features/admin/presentation/pages/job_approval_page.dart';
import '../../features/admin/presentation/pages/reports_page.dart';
import '../../features/admin/presentation/pages/salary_insights_management_page.dart';
import '../../features/admin/presentation/pages/user_management_page.dart';
import '../../features/applications/presentation/pages/application_details_page.dart';
import '../../features/applications/presentation/pages/applications_page.dart';
import '../../features/cv_builder/presentation/pages/cv_builder_page.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/pages/access_denied_page.dart';
import '../../features/auth/presentation/pages/admin_login_page.dart';
import '../../features/auth/presentation/pages/employer_register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/job_seeker_register_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/companies/presentation/pages/companies_page.dart';
import '../../features/companies/presentation/pages/company_details_page.dart';
import '../../features/employer/presentation/pages/applicant_details_page.dart';
import '../../features/employer/presentation/pages/applicants_page.dart';
import '../../features/employer/presentation/pages/company_profile_page.dart';
import '../../features/employer/presentation/pages/employer_dashboard_page.dart';
import '../../features/employer/presentation/pages/employer_notifications_page.dart';
import '../../features/employer/presentation/pages/employer_portal_page.dart';
import '../../features/employer/presentation/pages/interviews_page.dart';
import '../../features/employer/presentation/pages/manage_jobs_page.dart';
import '../../features/employer/presentation/pages/post_job_page.dart';
import '../../features/employer/presentation/pages/verification_pending_page.dart';
import '../../features/job_seeker/presentation/pages/job_seeker_dashboard_page.dart';
import '../../features/job_seeker/presentation/pages/job_seeker_profile_page.dart';
import '../../features/job_seeker/presentation/pages/saved_jobs_page.dart';
import '../../features/jobs/presentation/pages/job_details_page.dart';
import '../../features/jobs/presentation/pages/job_list_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/public_portal/presentation/pages/landing_page.dart';
import '../../features/public_portal/presentation/pages/salary_insights_page.dart';
import 'app_routes.dart';
import '../config/app_mode.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final requested = settings.name ?? AppRoutes.home;
    final effective = AppMode.routeFor(requested,
        adminOnly: AppMode.adminOnly,
        authenticatedAdmin: AuthController.instance.canAccess(UserRole.admin));
    settings = RouteSettings(name: effective, arguments: settings.arguments);
    final uri = Uri.parse(effective);
    final pathSegments = uri.pathSegments;
    final path = uri.path;

    Widget page;

    if (path == AppRoutes.home) {
      page = const LandingPage();
    } else if (path == AppRoutes.jobs) {
      page = _MobileWorkspaceJobs(
        initialQuery: uri.queryParameters['q'] ?? '',
        initialLocation: uri.queryParameters['location'] ?? '',
      );
    } else if (pathSegments.length == 2 && pathSegments.first == 'jobs') {
      page =
          _MobileWorkspaceJobs(child: JobDetailsPage(jobId: pathSegments[1]));
    } else if (path == AppRoutes.companies) {
      page = CompaniesPage(initialQuery: uri.queryParameters['q'] ?? '');
    } else if (pathSegments.length == 2 && pathSegments.first == 'companies') {
      page = CompanyDetailsPage(companyId: pathSegments[1]);
    } else if (path == AppRoutes.salaryInsights) {
      page = const SalaryInsightsPage();
    } else if (path == AppRoutes.employers) {
      page = const EmployerPortalPage();
    } else if (path == AppRoutes.login) {
      page = _alreadySignedInOr(const LoginPage());
    } else if (path == AppRoutes.employerLogin) {
      page = _alreadySignedInOr(
        const LoginPage(expectedRole: UserRole.employer),
        requiredRole: UserRole.employer,
      );
    } else if (path == AppRoutes.register) {
      page = _alreadySignedInOr(const RoleSelectionPage());
    } else if (path == AppRoutes.jobSeekerRegister) {
      page = _alreadySignedInOr(const JobSeekerRegisterPage());
    } else if (path == AppRoutes.employerRegister) {
      final googleAccount = settings.arguments is GoogleAccountDraft
          ? settings.arguments! as GoogleAccountDraft
          : null;
      page = _alreadySignedInOr(
        EmployerRegisterPage(googleAccount: googleAccount),
      );
    } else if (path == AppRoutes.forgotPassword) {
      page = const ForgotPasswordPage();
    } else if (path == AppRoutes.adminLogin) {
      page = _alreadySignedInOr(
        const AdminLoginPage(),
        requiredRole: UserRole.admin,
      );
    } else if (path == AppRoutes.account) {
      page = _accountDestination();
    } else if (path == AppRoutes.jobSeekerDashboard) {
      page = _protected(
        role: UserRole.jobSeeker,
        requestedRoute: path,
        child: const JobSeekerDashboardPage(),
      );
    } else if (path == AppRoutes.jobSeekerSavedJobs) {
      page = _protected(
        role: UserRole.jobSeeker,
        requestedRoute: path,
        child: const SavedJobsPage(),
      );
    } else if (path == AppRoutes.jobSeekerApplications) {
      page = _protected(
        role: UserRole.jobSeeker,
        requestedRoute: path,
        child: const ApplicationsPage(),
      );
    } else if (pathSegments.length == 3 &&
        pathSegments[0] == 'job-seeker' &&
        pathSegments[1] == 'applications') {
      page = _protected(
        role: UserRole.jobSeeker,
        requestedRoute: path,
        child: ApplicationDetailsPage(applicationId: pathSegments[2]),
      );
    } else if (path == AppRoutes.jobSeekerCvBuilder) {
      page = _protected(
        role: UserRole.jobSeeker,
        requestedRoute: path,
        child: const CvBuilderPage(),
      );
    } else if (path == AppRoutes.jobSeekerNotifications) {
      page = _protected(
        role: UserRole.jobSeeker,
        requestedRoute: path,
        child: const NotificationsPage(),
      );
    } else if (path == AppRoutes.jobSeekerProfile) {
      page = _protected(
        role: UserRole.jobSeeker,
        requestedRoute: path,
        child: const JobSeekerProfilePage(),
      );
    } else if (path == AppRoutes.employerDashboard) {
      page = _protected(
        role: UserRole.employer,
        requestedRoute: path,
        child: const EmployerDashboardPage(),
        requireApprovedEmployer: true,
      );
    } else if (path == AppRoutes.employerPostJob) {
      page = _protected(
        role: UserRole.employer,
        requestedRoute: path,
        child: const PostJobPage(),
        requireApprovedEmployer: true,
      );
    } else if (path == AppRoutes.employerManageJobs) {
      page = _protected(
        role: UserRole.employer,
        requestedRoute: path,
        child: const ManageJobsPage(),
        requireApprovedEmployer: true,
      );
    } else if (pathSegments.length == 4 &&
        pathSegments[0] == 'employer' &&
        pathSegments[1] == 'jobs' &&
        pathSegments[3] == 'edit') {
      page = _protected(
        role: UserRole.employer,
        requestedRoute: path,
        child: PostJobPage(jobId: pathSegments[2]),
        requireApprovedEmployer: true,
      );
    } else if (path == AppRoutes.employerApplicants) {
      page = _protected(
        role: UserRole.employer,
        requestedRoute: path,
        child: ApplicantsPage(initialJobId: uri.queryParameters['jobId']),
        requireApprovedEmployer: true,
      );
    } else if (pathSegments.length == 3 &&
        pathSegments[0] == 'employer' &&
        pathSegments[1] == 'applicants') {
      page = _protected(
        role: UserRole.employer,
        requestedRoute: path,
        child: ApplicantDetailsPage(applicationId: pathSegments[2]),
        requireApprovedEmployer: true,
      );
    } else if (path == AppRoutes.employerInterviews) {
      page = _protected(
        role: UserRole.employer,
        requestedRoute: path,
        child: const InterviewsPage(),
        requireApprovedEmployer: true,
      );
    } else if (path == AppRoutes.employerCompanyProfile) {
      page = _protected(
        role: UserRole.employer,
        requestedRoute: path,
        child: const CompanyProfilePage(),
        requireApprovedEmployer: true,
      );
    } else if (path == AppRoutes.employerNotifications) {
      page = _protected(
        role: UserRole.employer,
        requestedRoute: path,
        child: const EmployerNotificationsPage(),
        requireApprovedEmployer: true,
      );
    } else if (path == AppRoutes.employerVerificationPending) {
      page = _protected(
        role: UserRole.employer,
        requestedRoute: path,
        child: const VerificationPendingPage(),
      );
    } else if (path == AppRoutes.adminDashboard) {
      page = _protected(
        role: UserRole.admin,
        requestedRoute: path,
        child: const AdminDashboardPage(),
      );
    } else if (path == AppRoutes.adminEmployerVerification) {
      page = _protected(
        role: UserRole.admin,
        requestedRoute: path,
        child: const EmployerVerificationPage(),
      );
    } else if (path == AppRoutes.adminJobApprovals) {
      page = _protected(
        role: UserRole.admin,
        requestedRoute: path,
        child: const JobApprovalPage(),
      );
    } else if (path == AppRoutes.adminUsers) {
      page = _protected(
        role: UserRole.admin,
        requestedRoute: path,
        child: const UserManagementPage(),
      );
    } else if (path == AppRoutes.adminCompanies) {
      page = _protected(
        role: UserRole.admin,
        requestedRoute: path,
        child: const CompanyManagementPage(),
      );
    } else if (path == AppRoutes.adminReports) {
      page = _protected(
        role: UserRole.admin,
        requestedRoute: path,
        child: const ReportsPage(),
      );
    } else if (path == AppRoutes.adminCategories) {
      page = _protected(
        role: UserRole.admin,
        requestedRoute: path,
        child: const CategoryManagementPage(),
      );
    } else if (path == AppRoutes.adminSalaryInsights) {
      page = _protected(
        role: UserRole.admin,
        requestedRoute: path,
        child: const SalaryInsightsManagementPage(),
      );
    } else if (path == AppRoutes.adminSettings) {
      page = _protected(
        role: UserRole.admin,
        requestedRoute: path,
        child: const AdminSettingsPage(),
      );
    } else {
      page = const _NotFoundPage();
    }

    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, animation, __) =>
          _MobileBackGuard(path: path, child: page),
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, .018),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
    );
  }

  static Widget _alreadySignedInOr(Widget unauthenticatedPage,
      {UserRole? requiredRole}) {
    final controller = AuthController.instance;
    final user = controller.currentUser;
    if (user == null) return unauthenticatedPage;
    if (requiredRole != null && user.role != requiredRole) {
      return AccessDeniedPage(requiredRole: requiredRole);
    }
    return _dashboardForCurrentUser();
  }

  static Widget _accountDestination() {
    if (AuthController.instance.currentUser == null) return const LoginPage();
    return _dashboardForCurrentUser();
  }

  static Widget _dashboardForCurrentUser() {
    final user = AuthController.instance.currentUser!;
    return switch (user.role) {
      UserRole.jobSeeker => const JobSeekerDashboardPage(),
      UserRole.employer
          when user.verificationStatus == EmployerVerificationStatus.approved =>
        const EmployerDashboardPage(),
      UserRole.employer => const VerificationPendingPage(),
      UserRole.admin => const AdminDashboardPage(),
    };
  }

  static Widget _protected({
    required UserRole role,
    required String requestedRoute,
    required Widget child,
    bool requireApprovedEmployer = false,
  }) {
    final controller = AuthController.instance;
    final user = controller.currentUser;

    if (user == null) {
      if (role == UserRole.admin) {
        return AdminLoginPage(redirectRoute: requestedRoute);
      }
      return LoginPage(expectedRole: role, redirectRoute: requestedRoute);
    }

    if (!user.isActive || user.role != role) {
      return AccessDeniedPage(requiredRole: role);
    }

    if (role == UserRole.employer) {
      final approved =
          user.verificationStatus == EmployerVerificationStatus.approved;
      if (requireApprovedEmployer && !approved) {
        return const VerificationPendingPage();
      }
      if (!requireApprovedEmployer &&
          approved &&
          requestedRoute == AppRoutes.employerVerificationPending) {
        return const EmployerDashboardPage();
      }
    }

    return child;
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.travel_explore_rounded, size: 64),
            const SizedBox(height: 18),
            Text('Page not found',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (_) => false,
              ),
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Public job search remains available without signing out, while signed-in
/// users retain the same workspace navigation at phone widths.
class _MobileWorkspaceJobs extends StatelessWidget {
  const _MobileWorkspaceJobs(
      {this.initialQuery = '', this.initialLocation = '', this.child});
  final Widget? child;

  final String initialQuery;
  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.currentUser;
    final jobs = child ??
        JobListPage(
            initialQuery: initialQuery, initialLocation: initialLocation);
    return LayoutBuilder(builder: (context, constraints) {
      if (user == null ||
          constraints.maxWidth >= Breakpoints.desktop ||
          user.role == UserRole.admin) {
        return jobs;
      }
      final jobSeeker = user.role == UserRole.jobSeeker;
      final items =
          jobSeeker ? JobSeekerNavigation.items : EmployerNavigation.items;
      final accent = jobSeeker ? AppColors.blue : AppColors.purple;
      final shell = DashboardShell(
        role: user.role,
        title: '',
        subtitle: '',
        body: const SizedBox.shrink(),
        items: items,
        selectedIndex: items.indexWhere((item) => item.route == AppRoutes.jobs),
        accent: accent,
      );
      return Scaffold(
        body: jobs,
        bottomNavigationBar: shell.mobileNavigationBar(context),
      );
    });
  }
}

/// The root Android route must not close the app without confirmation.
/// Back from Find Jobs returns to the signed-in workspace, even when Find Jobs
/// replaced the previous route. Non-root screens retain normal back behavior.
class _MobileBackGuard extends StatefulWidget {
  const _MobileBackGuard({required this.path, required this.child});
  final String path;
  final Widget child;

  @override
  State<_MobileBackGuard> createState() => _MobileBackGuardState();
}

class _MobileBackGuardState extends State<_MobileBackGuard> {
  bool _confirming = false;
  @override
  Widget build(BuildContext context) {
    final path = widget.path;
    final child = widget.child;
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        !(ModalRoute.of(context)?.isFirst ?? false)) {
      return child;
    }
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _confirming) return;
        final user = AuthController.instance.currentUser;
        if (user != null &&
            path != AppRoutes.account &&
            path != AppRoutes.home &&
            path != AppRoutes.jobSeekerDashboard &&
            path != AppRoutes.employerDashboard &&
            path != AppRoutes.adminDashboard) {
          Navigator.pushReplacementNamed(context, AppRoutes.account);
          return;
        }
        _confirming = true;
        final exit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Exit Career Bridge?'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Exit')),
            ],
          ),
        );
        _confirming = false;
        if (exit == true && context.mounted) SystemNavigator.pop();
      },
      child: child,
    );
  }
}
