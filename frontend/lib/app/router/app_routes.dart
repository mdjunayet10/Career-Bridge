abstract final class AppRoutes {
  static const home = '/';
  static const jobs = '/jobs';
  static const companies = '/companies';
  static const salaryInsights = '/salary-insights';

  static const login = '/login';
  static const register = '/register';
  static const jobSeekerRegister = '/register/job-seeker';
  static const employerRegister = '/register/employer';
  static const forgotPassword = '/forgot-password';
  static const account = '/account';

  static const employers = '/employers';
  static const employerLogin = '/employer/login';
  static const employerDashboard = '/employer/dashboard';
  static const employerPostJob = '/employer/jobs/new';
  static const employerManageJobs = '/employer/jobs';
  static const employerApplicants = '/employer/applicants';
  static const employerInterviews = '/employer/interviews';
  static const employerCompanyProfile = '/employer/company';
  static const employerNotifications = '/employer/notifications';
  static const employerVerificationPending = '/employer/verification-pending';

  static const jobSeekerDashboard = '/job-seeker/dashboard';
  static const jobSeekerSavedJobs = '/job-seeker/saved';
  static const jobSeekerApplications = '/job-seeker/applications';
  static const jobSeekerCvBuilder = '/job-seeker/cv-builder';
  static const jobSeekerNotifications = '/job-seeker/notifications';
  static const jobSeekerProfile = '/job-seeker/profile';

  static const adminLogin = '/admin/login';
  static const adminDashboard = '/admin/dashboard';
  static const adminEmployerVerification = '/admin/employers';
  static const adminJobApprovals = '/admin/jobs';
  static const adminUsers = '/admin/users';
  static const adminCompanies = '/admin/companies';
  static const adminReports = '/admin/reports';
  static const adminCategories = '/admin/categories';
  static const adminSalaryInsights = '/admin/salary-insights';
  static const adminSettings = '/admin/settings';

  static String jobDetails(String jobId) => '/jobs/$jobId';
  static String companyDetails(String companyId) => '/companies/$companyId';
  static String jobSeekerApplicationDetails(String applicationId) =>
      '/job-seeker/applications/$applicationId';
  static String employerEditJob(String jobId) => '/employer/jobs/$jobId/edit';
  static String employerApplicantDetails(String applicationId) =>
      '/employer/applicants/$applicationId';
}
