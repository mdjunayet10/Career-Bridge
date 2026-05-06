const configuredApiBase = document
  .querySelector("meta[name='career-bridge-api-base']")
  ?.getAttribute("content");

const API_BASE = String(configuredApiBase || "").trim()
  || (window.location.protocol === "file:" ? "http://localhost:4000" : "");
const REQUEST_TIMEOUT_MS = 12_000;
const AUTH_STORAGE_KEY = "careerBridgeAuth";
const CV_BUILDER_STORAGE_KEY = "careerBridgeCvBuilderDraft";

const fallbackSalaries = [
  {
    role: "Frontend Developer",
    salaryRange: "BDT 30,000 - 70,000",
    level: "Junior to Mid",
    trend: "High demand"
  },
  {
    role: "Backend Developer",
    salaryRange: "BDT 40,000 - 90,000",
    level: "Mid",
    trend: "Growing"
  },
  {
    role: "UI/UX Designer",
    salaryRange: "BDT 25,000 - 65,000",
    level: "Junior to Mid",
    trend: "Stable"
  }
];

const fallbackJobs = [
  {
    id: 1,
    title: "Junior Frontend Developer",
    company: "Dhaka Tech Hub",
    location: "Dhaka",
    type: "Full-time",
    salary: "BDT 35,000 - 45,000",
    status: "OPEN",
    description: "Build and maintain responsive interfaces with modern JavaScript.",
    requirements: ["HTML, CSS, JavaScript", "Git basics"],
    postedAt: new Date().toISOString()
  },
  {
    id: 2,
    title: "Backend Node.js Developer",
    company: "BridgeStack",
    location: "Dhaka",
    type: "Hybrid",
    salary: "BDT 55,000 - 80,000",
    status: "OPEN",
    description: "Create scalable APIs and optimize backend services.",
    requirements: ["Node.js + Express", "Database knowledge"],
    postedAt: new Date().toISOString()
  },
  {
    id: 3,
    title: "Data Analyst",
    company: "Insight Grid",
    location: "Dhaka",
    type: "Full-time",
    salary: "BDT 45,000 - 70,000",
    status: "OPEN",
    description: "Analyze datasets and convert findings into business insights.",
    requirements: ["SQL and Excel", "Dashboard reporting"],
    postedAt: new Date().toISOString()
  }
];

const applicationStatuses = ["SUBMITTED", "REVIEWED", "SHORTLISTED", "INTERVIEW", "REJECTED", "HIRED"];
const applicationStatusFilterOptions = ["ALL", ...applicationStatuses];
const jobStatuses = ["OPEN", "CLOSED"];
const reportStatuses = ["OPEN", "REVIEWING", "RESOLVED", "DISMISSED"];
const adminPageSize = 10;
const seededDemoEmails = new Set([
  "admin@careerbridge.com",
  "employer@careerbridge.com",
  "employee@careerbridge.com"
]);

const state = {
  apiOnline: false,
  currentUser: null,
  authToken: "",
  currentRole: "PUBLIC",
  selectedJob: null,
  currentKeyword: "",
  authMode: "login",
  authRole: "JOB_SEEKER",
  jobs: [...fallbackJobs],
  salaries: [...fallbackSalaries],
  savedJobs: [],
  savedJobIds: new Set(),
  applications: [],
  jobSeekerApplicationFilter: "ALL",
  appliedJobIds: new Set(),
  profile: null,
  employerDashboard: null,
  employerCompany: null,
  employerJobs: [],
  employerJobFilter: "ACTIVE",
  employerApplications: [],
  employerApplicationFilter: "ALL",
  adminStats: null,
  adminUsers: [],
  adminUserFilter: "ALL",
  adminCompanies: [],
  adminCompanyFilter: "ALL",
  adminJobs: [],
  adminJobFilter: "ALL",
  adminApplications: [],
  adminApplicationFilters: {
    search: "",
    status: ""
  },
  adminReports: [],
  paginationPages: {
    publicJobs: 1,
    savedJobs: 1,
    jobSeekerApplications: 1,
    employerJobs: 1,
    employerApplications: 1,
    users: 1,
    companies: 1,
    jobs: 1,
    applications: 1,
    reports: 1,
    salaryInsights: 1
  },
  cvMode: "upload",
  generatedCvFile: null,
  cvBuilderPhotoDataUrl: "",
  cvBuilderPhotoPdfData: null,
  cvPreview: {
    objectUrl: "",
    fileName: "",
    returnFocus: null
  }
};

const elements = {
  siteNav: document.querySelector("#siteNav"),
  brandHome: document.querySelector("[data-nav-home]"),
  menuButton: document.querySelector("#menuButton"),
  authQuickStatus: document.querySelector("#authQuickStatus"),
  loginButton: document.querySelector("#loginButton"),
  registerButton: document.querySelector("#registerButton"),
  logoutButton: document.querySelector("#logoutButton"),
  jobCount: document.querySelector("#jobCount"),
  jobSectionHint: document.querySelector("#jobSectionHint"),
  jobSearch: document.querySelector("#jobSearch"),
  filterChips: document.querySelector("#filterChips"),
  jobList: document.querySelector("#jobList"),
  jobActionStatus: document.querySelector("#jobActionStatus"),
  salaryGrid: document.querySelector("#salaryGrid"),
  jobSeekerWelcome: document.querySelector("#jobSeekerWelcome"),
  jobSeekerStats: document.querySelector("#jobSeekerStats"),
  openProfileModalButton: document.querySelector("#openProfileModalButton"),
  profileModal: document.querySelector("#profileModal"),
  closeProfileModalButton: document.querySelector("#closeProfileModalButton"),
  profileModalBackdrop: document.querySelector("[data-close-profile-modal]"),
  profileForm: document.querySelector("#profileForm"),
  profileStatus: document.querySelector("#profileStatus"),
  jobSeekerApplicationFilterTabs: document.querySelector("#jobSeekerApplicationFilterTabs"),
  jobSeekerApplications: document.querySelector("#jobSeekerApplications"),
  savedJobsList: document.querySelector("#savedJobsList"),
  employerWelcome: document.querySelector("#employerWelcome"),
  companyVerificationNotice: document.querySelector("#companyVerificationNotice"),
  employerStats: document.querySelector("#employerStats"),
  openCompanyModalButton: document.querySelector("#openCompanyModalButton"),
  companyProfileModal: document.querySelector("#companyProfileModal"),
  closeCompanyModalButton: document.querySelector("#closeCompanyModalButton"),
  companyModalBackdrop: document.querySelector("[data-close-company-modal]"),
  companyForm: document.querySelector("#companyForm"),
  companyStatus: document.querySelector("#companyStatus"),
  openPostJobModalButton: document.querySelector("#openPostJobModalButton"),
  employerPostJobModal: document.querySelector("#employerPostJobModal"),
  closePostJobModalButton: document.querySelector("#closePostJobModalButton"),
  postJobModalBackdrop: document.querySelector("[data-close-post-job-modal]"),
  postJobForm: document.querySelector("#postJobForm"),
  postJobStatus: document.querySelector("#postJobStatus"),
  employerJobFilterTabs: document.querySelector("#employerJobFilterTabs"),
  employerJobsList: document.querySelector("#employerJobsList"),
  employerApplicationFilterTabs: document.querySelector("#employerApplicationFilterTabs"),
  employerApplicationsList: document.querySelector("#employerApplicationsList"),
  adminStatsGrid: document.querySelector("#adminStatsGrid"),
  adminUserStatusSummary: document.querySelector("#adminUserStatusSummary"),
  adminUserFilterTabs: document.querySelector("#adminUserFilterTabs"),
  adminUsersTable: document.querySelector("#adminUsersTable"),
  adminCompanyStatusSummary: document.querySelector("#adminCompanyStatusSummary"),
  adminCompanyFilterTabs: document.querySelector("#adminCompanyFilterTabs"),
  adminCompaniesTable: document.querySelector("#adminCompaniesTable"),
  adminJobStatusSummary: document.querySelector("#adminJobStatusSummary"),
  adminJobFilterTabs: document.querySelector("#adminJobFilterTabs"),
  adminJobsTable: document.querySelector("#adminJobsTable"),
  adminApplicationStatusSummary: document.querySelector("#adminApplicationStatusSummary"),
  adminApplicationFilterTabs: document.querySelector("#adminApplicationFilterTabs"),
  adminApplicationFilters: document.querySelector("#adminApplicationFilters"),
  adminApplicationsTable: document.querySelector("#adminApplicationsTable"),
  adminReportsList: document.querySelector("#adminReportsList"),
  openSalaryInsightModalButton: document.querySelector("#openSalaryInsightModalButton"),
  salaryInsightModal: document.querySelector("#salaryInsightModal"),
  closeSalaryInsightModalButton: document.querySelector("#closeSalaryInsightModalButton"),
  salaryInsightModalBackdrop: document.querySelector("[data-close-salary-insight-modal]"),
  salaryInsightForm: document.querySelector("#salaryInsightForm"),
  salaryInsightStatus: document.querySelector("#salaryInsightStatus"),
  adminSalaryInsights: document.querySelector("#adminSalaryInsights"),
  authModal: document.querySelector("#authModal"),
  closeAuthModalButton: document.querySelector("#closeAuthModalButton"),
  authModalBackdrop: document.querySelector("[data-close-auth-modal]"),
  authModalTitle: document.querySelector("#authModalTitle"),
  authModalHelper: document.querySelector("#authModalHelper"),
  authModeSwitch: document.querySelector("#authModeSwitch"),
  authRoleSwitch: document.querySelector("#authRoleSwitch"),
  authLoginMode: document.querySelector("#authLoginMode"),
  authRegisterMode: document.querySelector("#authRegisterMode"),
  authForm: document.querySelector("#authForm"),
  authName: document.querySelector("#authName"),
  authEmail: document.querySelector("#authEmail"),
  authPassword: document.querySelector("#authPassword"),
  togglePasswordButton: document.querySelector("#togglePasswordButton"),
  passwordHelper: document.querySelector("#passwordHelper"),
  authCompanyName: document.querySelector("#authCompanyName"),
  authSubmitButton: document.querySelector("#authSubmitButton"),
  authStatus: document.querySelector("#authStatus"),
  authDemoHint: document.querySelector("#authDemoHint"),
  forgotPasswordPanel: document.querySelector("#forgotPasswordPanel"),
  forgotPasswordButton: document.querySelector("#forgotPasswordButton"),
  passwordRecoveryPanel: document.querySelector("#passwordRecoveryPanel"),
  forgotPasswordForm: document.querySelector("#forgotPasswordForm"),
  recoveryEmailInput: document.querySelector("#recoveryEmailInput"),
  resetPasswordForm: document.querySelector("#resetPasswordForm"),
  resetTokenInput: document.querySelector("#resetTokenInput"),
  resetPasswordInput: document.querySelector("#resetPasswordInput"),
  backToLoginButton: document.querySelector("#backToLoginButton"),
  resetStatus: document.querySelector("#resetStatus"),
  jobModal: document.querySelector("#jobModal"),
  closeModalButton: document.querySelector("#closeModalButton"),
  modalBackdrop: document.querySelector("[data-close-modal]"),
  jobDetailPanel: document.querySelector("#jobDetailPanel"),
  applyPanel: document.querySelector("#applyPanel"),
  alreadyAppliedNotice: document.querySelector("#alreadyAppliedNotice"),
  applyForm: document.querySelector("#applyForm"),
  applyJobId: document.querySelector("#applyJobId"),
  applyName: document.querySelector("#applyName"),
  applyEmail: document.querySelector("#applyEmail"),
  applyPhone: document.querySelector("#applyPhone"),
  applyCvFile: document.querySelector("#applyCvFile"),
  cvUploadModeButton: document.querySelector("#cvUploadModeButton"),
  cvBuilderModeButton: document.querySelector("#cvBuilderModeButton"),
  cvUploadPanel: document.querySelector("#cvUploadPanel"),
  cvBuilderPanel: document.querySelector("#cvBuilderPanel"),
  cvBuilderPhoto: document.querySelector("#cvBuilderPhoto"),
  cvBuilderProgram: document.querySelector("#cvBuilderProgram"),
  cvBuilderStudentId: document.querySelector("#cvBuilderStudentId"),
  cvBuilderLocation: document.querySelector("#cvBuilderLocation"),
  cvBuilderAddress: document.querySelector("#cvBuilderAddress"),
  cvBuilderLinkedin: document.querySelector("#cvBuilderLinkedin"),
  cvBuilderGithub: document.querySelector("#cvBuilderGithub"),
  cvBuilderEducationList: document.querySelector("#cvBuilderEducationList"),
  cvBuilderSkillsList: document.querySelector("#cvBuilderSkillsList"),
  cvBuilderProjectsList: document.querySelector("#cvBuilderProjectsList"),
  cvBuilderAchievementsList: document.querySelector("#cvBuilderAchievementsList"),
  cvBuilderActivitiesList: document.querySelector("#cvBuilderActivitiesList"),
  cvBuilderReferencesList: document.querySelector("#cvBuilderReferencesList"),
  addEducationButton: document.querySelector("#addEducationButton"),
  addSkillCategoryButton: document.querySelector("#addSkillCategoryButton"),
  addProjectButton: document.querySelector("#addProjectButton"),
  addAchievementButton: document.querySelector("#addAchievementButton"),
  addActivityButton: document.querySelector("#addActivityButton"),
  addReferenceButton: document.querySelector("#addReferenceButton"),
  previewCvBuilderButton: document.querySelector("#previewCvBuilderButton"),
  downloadCvBuilderButton: document.querySelector("#downloadCvBuilderButton"),
  useGeneratedCvButton: document.querySelector("#useGeneratedCvButton"),
  resetCvBuilderButton: document.querySelector("#resetCvBuilderButton"),
  cvBuilderStatus: document.querySelector("#cvBuilderStatus"),
  cvBuilderPreview: document.querySelector("#cvBuilderPreview"),
  applyStatus: document.querySelector("#applyStatus"),
  cvModal: document.querySelector("#cvModal"),
  closeCvModalButton: document.querySelector("#closeCvModalButton"),
  cvModalBackdrop: document.querySelector("[data-close-cv-modal]"),
  cvPreviewFrame: document.querySelector("#cvPreviewFrame"),
  cvModalDetails: document.querySelector("#cvModalDetails"),
  cvModalStatus: document.querySelector("#cvModalStatus"),
  downloadCvButton: document.querySelector("#downloadCvButton"),
  toast: document.querySelector("#toast")
};

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function normalizeRole(value) {
  const normalized = String(value || "").trim().toUpperCase();
  const roleMap = {
    EMPLOYEE: "JOB_SEEKER",
    JOBSEEKER: "JOB_SEEKER",
    JOB_SEEKER: "JOB_SEEKER",
    EMPLOYER: "EMPLOYER",
    ADMIN: "ADMIN",
    PUBLIC: "PUBLIC"
  };

  return roleMap[normalized] || "PUBLIC";
}

function roleLabel(role = state.currentRole) {
  const labels = {
    PUBLIC: "Public Visitor",
    JOB_SEEKER: "Job Seeker",
    EMPLOYER: "Employer",
    ADMIN: "Admin"
  };

  return labels[normalizeRole(role)] || "Public Visitor";
}

function isAuthenticated() {
  return Boolean(state.authToken && state.currentUser);
}

function getAuthHeaders() {
  if (!state.authToken) {
    return {};
  }

  return {
    authorization: `Bearer ${state.authToken}`
  };
}

function setFormStatus(element, message, tone = "") {
  if (!element) {
    return;
  }

  element.classList.remove("success", "error");
  element.textContent = message || "";

  if (tone) {
    element.classList.add(tone);
  }
}

function showToast(message, tone = "") {
  if (!elements.toast) {
    return;
  }

  elements.toast.classList.remove("success", "error");
  elements.toast.textContent = message;
  elements.toast.hidden = false;

  if (tone) {
    elements.toast.classList.add(tone);
  }

  window.clearTimeout(showToast.timeoutId);
  showToast.timeoutId = window.setTimeout(() => {
    elements.toast.hidden = true;
  }, 3600);
}

function getFriendlyErrorMessage(error, fallback = "Request failed.") {
  const message = error?.message || fallback;

  if (message === "Internal server error") {
    return "Backend could not complete the request. Check that PostgreSQL is running and migrations/seed data are applied.";
  }

  if (/database is not available/i.test(message)) {
    return "Database is not available. Run: docker compose up -d db, then cd backend && npm run prisma:migrate && npm run prisma:seed";
  }

  if (/database tables are missing/i.test(message)) {
    return "Database tables are missing. Run: cd backend && npm run prisma:migrate && npm run prisma:seed";
  }

  if (/demo account not found/i.test(message)) {
    return "Demo account not found. In Terminal run: cd backend && npm run prisma:seed";
  }

  if (/invalid credentials for this role/i.test(message)) {
    return "This account exists under a different role. Choose the correct role tab and try again.";
  }

  if (/invalid demo credentials/i.test(message)) {
    return "Demo login uses password demo1234. Also make sure the selected role matches the email.";
  }

  if (/invalid credentials/i.test(message)) {
    return "Email or password is incorrect. Check the account and try again.";
  }

  if (/already applied/i.test(message)) {
    return "You have already applied for this job. I marked it as Applied here too.";
  }

  return message;
}

function formatDate(value) {
  if (!value) {
    return "Just now";
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return "Just now";
  }

  return date.toLocaleDateString("en-BD", {
    year: "numeric",
    month: "short",
    day: "numeric"
  });
}

function truncateText(value, maxLength = 130) {
  const normalized = String(value || "").replace(/\s+/g, " ").trim();

  if (normalized.length <= maxLength) {
    return normalized;
  }

  return `${normalized.slice(0, maxLength - 1).trim()}...`;
}

function normalizeList(value) {
  if (Array.isArray(value)) {
    return value.map((item) => String(item).trim()).filter(Boolean);
  }

  if (typeof value !== "string") {
    return [];
  }

  return value.split(/\n|,/).map((item) => item.trim()).filter(Boolean);
}

function getInitials(value) {
  return String(value || "CB")
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join("") || "CB";
}

function getSafeFileName(value, fallback = "cv-file") {
  const source = String(value || fallback).trim();
  const sanitized = source.replace(/[\\/:*?"<>|]/g, "-").replace(/\s+/g, " ").trim();
  return sanitized || fallback;
}

function parseFileNameFromDisposition(dispositionValue) {
  if (!dispositionValue) {
    return "";
  }

  const utfMatch = dispositionValue.match(/filename\*=UTF-8''([^;]+)/i);
  if (utfMatch?.[1]) {
    return decodeURIComponent(utfMatch[1]);
  }

  const basicMatch = dispositionValue.match(/filename="?([^";]+)"?/i);
  return basicMatch?.[1] || "";
}

function triggerFileDownload(fileUrl, fileName) {
  const link = document.createElement("a");
  link.href = fileUrl;
  link.download = getSafeFileName(fileName);
  link.rel = "noopener noreferrer";
  document.body.append(link);
  link.click();
  link.remove();
}

function isPreviewableCvFile(mimeType, fileName) {
  return String(mimeType || "").toLowerCase().includes("pdf")
    || String(fileName || "").toLowerCase().endsWith(".pdf");
}

function getApplicationJobId(application) {
  return Number(application?.jobId || application?.job?.id || 0);
}

function isAlreadyApplied(jobId) {
  return state.appliedJobIds.has(Number(jobId));
}

async function fetchWithTimeout(url, options = {}) {
  const { timeoutMs = REQUEST_TIMEOUT_MS, ...fetchOptions } = options;
  const controller = new AbortController();
  const timeoutId = window.setTimeout(() => controller.abort(), timeoutMs);

  try {
    return await fetch(url, {
      ...fetchOptions,
      signal: controller.signal
    });
  } catch (error) {
    if (error?.name === "AbortError") {
      throw new Error("Request timed out. Please try again.");
    }

    throw error;
  } finally {
    window.clearTimeout(timeoutId);
  }
}

async function requestJson(path, options = {}) {
  const isFormData = options.body instanceof FormData;
  const shouldSendJson = options.body && !isFormData && typeof options.body !== "string";
  const headers = {
    ...(isFormData ? {} : { "Content-Type": "application/json" }),
    ...(options.auth === false ? {} : getAuthHeaders()),
    ...(options.headers || {})
  };

  const response = await fetchWithTimeout(`${API_BASE}${path}`, {
    ...options,
    headers,
    body: shouldSendJson ? JSON.stringify(options.body) : options.body
  });

  const payload = await response.json().catch(() => ({}));

  if (!response.ok) {
    const requestError = new Error(payload.message || "Request failed");
    requestError.status = response.status;
    requestError.payload = payload;
    throw requestError;
  }

  return payload;
}

function setApiStatus(online, message = "") {
  state.apiOnline = online;
}

function persistSession() {
  if (!isAuthenticated()) {
    window.localStorage.removeItem(AUTH_STORAGE_KEY);
    return;
  }

  window.localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify({
    authToken: state.authToken,
    currentUser: state.currentUser,
    currentRole: state.currentRole
  }));
}

function applySession(authData) {
  const user = authData.user || {
    id: authData.id,
    name: authData.displayName || authData.name || authData.email,
    email: authData.email,
    role: normalizeRole(authData.role)
  };

  state.authToken = String(authData.accessToken || authData.authToken || "").trim();
  state.currentUser = user;
  state.currentRole = normalizeRole(user.role || authData.role);
  persistSession();
}

function clearSession() {
  state.currentUser = null;
  state.authToken = "";
  state.currentRole = "PUBLIC";
  state.savedJobs = [];
  state.savedJobIds = new Set();
  state.applications = [];
  state.appliedJobIds = new Set();
  state.profile = null;
  state.employerDashboard = null;
  state.employerCompany = null;
  state.employerJobs = [];
  state.employerApplications = [];
  state.adminStats = null;
  state.adminUsers = [];
  state.adminUserFilter = "ALL";
  state.adminCompanies = [];
  state.adminCompanyFilter = "ALL";
  state.adminJobs = [];
  state.adminJobFilter = "ALL";
  state.adminApplications = [];
  state.adminApplicationFilters = {
    search: "",
    status: ""
  };
  state.adminReports = [];
  state.paginationPages = {
    publicJobs: 1,
    savedJobs: 1,
    jobSeekerApplications: 1,
    employerJobs: 1,
    employerApplications: 1,
    users: 1,
    companies: 1,
    jobs: 1,
    applications: 1,
    reports: 1,
    salaryInsights: 1
  };
  state.generatedCvFile = null;
  state.cvMode = "upload";
  window.localStorage.removeItem(AUTH_STORAGE_KEY);
}

async function loadStoredSession() {
  const rawValue = window.localStorage.getItem(AUTH_STORAGE_KEY);

  if (!rawValue) {
    return;
  }

  try {
    const parsed = JSON.parse(rawValue);
    state.authToken = String(parsed.authToken || "").trim();
    state.currentUser = parsed.currentUser || null;
    state.currentRole = normalizeRole(parsed.currentRole || parsed.currentUser?.role);

    if (!state.authToken || !state.currentUser) {
      clearSession();
      return;
    }

    const response = await requestJson("/api/auth/me");
    const user = response.data?.user || response.data;
    state.currentUser = user;
    state.currentRole = normalizeRole(user?.role);
    persistSession();
  } catch (_error) {
    clearSession();
  }
}

function handleAuthError(error) {
  if (error?.status === 401 || error?.status === 403) {
    clearSession();
    renderAll();
    openAuthModal("login", "JOB_SEEKER");
    showToast("Your session expired. Please login again.", "error");
    return true;
  }

  return false;
}

async function loadPublicData() {
  try {
    const [salaryResponse, jobResponse] = await Promise.all([
      requestJson("/api/salaries", { auth: false }),
      requestJson("/api/jobs", { auth: false })
    ]);

    state.salaries = Array.isArray(salaryResponse.data) ? salaryResponse.data : [];
    state.jobs = Array.isArray(jobResponse.data) ? jobResponse.data : [];
    setApiStatus(true);
  } catch (_error) {
    state.salaries = [...fallbackSalaries];
    state.jobs = [...fallbackJobs];
    setApiStatus(false);
  }
}

async function loadJobSeekerData() {
  const [profileResponse, savedResponse, applicationsResponse] = await Promise.all([
    requestJson("/api/profile/me"),
    requestJson("/api/saved-jobs/me"),
    requestJson("/api/applications/me")
  ]);

  state.profile = profileResponse.data?.profile || null;
  state.savedJobs = Array.isArray(savedResponse.data) ? savedResponse.data : [];
  state.savedJobIds = new Set(state.savedJobs.map((item) => item.jobId || item.job?.id).filter(Boolean));
  state.applications = Array.isArray(applicationsResponse.data) ? applicationsResponse.data : [];
  state.appliedJobIds = new Set(state.applications.map(getApplicationJobId).filter(Boolean));
}

async function loadEmployerData() {
  const [dashboardResponse, companyResponse, applicationsResponse] = await Promise.all([
    requestJson("/api/employer/dashboard"),
    requestJson("/api/employer/company"),
    requestJson("/api/employer/applications")
  ]);

  state.employerDashboard = dashboardResponse.data || null;
  state.employerCompany = companyResponse.data || state.employerDashboard?.company || null;
  state.employerJobs = Array.isArray(state.employerDashboard?.jobs) ? state.employerDashboard.jobs : [];
  state.employerApplications = Array.isArray(applicationsResponse.data) ? applicationsResponse.data : [];
}

async function requestAllPaginated(path, limit = 100) {
  const separator = path.includes("?") ? "&" : "?";
  const firstResponse = await requestJson(`${path}${separator}page=1&limit=${limit}`);
  const data = Array.isArray(firstResponse.data) ? [...firstResponse.data] : [];
  const totalPages = Number(firstResponse.totalPages) || 1;

  if (totalPages <= 1) {
    return data;
  }

  const remainingResponses = await Promise.all(
    Array.from({ length: totalPages - 1 }, (_, index) => requestJson(`${path}${separator}page=${index + 2}&limit=${limit}`))
  );

  remainingResponses.forEach((response) => {
    if (Array.isArray(response.data)) {
      data.push(...response.data);
    }
  });

  return data;
}

async function loadAdminData() {
  const [
    statsResponse,
    users,
    companiesResponse,
    jobs,
    applicationsResponse,
    reportsResponse,
    salaryResponse
  ] = await Promise.all([
    requestJson("/api/admin/stats"),
    requestAllPaginated("/api/admin/users"),
    requestJson("/api/admin/companies"),
    requestAllPaginated("/api/admin/jobs?status=ALL"),
    requestJson("/api/admin/applications"),
    requestJson("/api/admin/reports"),
    requestJson("/api/salary-insights")
  ]);

  state.adminStats = statsResponse.data || null;
  state.adminUsers = users;
  state.adminCompanies = Array.isArray(companiesResponse.data) ? companiesResponse.data : [];
  state.adminJobs = jobs;
  state.adminApplications = Array.isArray(applicationsResponse.data) ? applicationsResponse.data : [];
  state.adminReports = Array.isArray(reportsResponse.data) ? reportsResponse.data : [];
  state.salaries = Array.isArray(salaryResponse.data) ? salaryResponse.data : state.salaries;
}

async function loadRoleData() {
  if (!isAuthenticated()) {
    return;
  }

  try {
    if (state.currentRole === "JOB_SEEKER") {
      await loadJobSeekerData();
    } else if (state.currentRole === "EMPLOYER") {
      await loadEmployerData();
    } else if (state.currentRole === "ADMIN") {
      await loadAdminData();
    }
  } catch (error) {
    if (!handleAuthError(error)) {
      showToast(error.message || "Could not load dashboard data.", "error");
    }
  }
}

function renderAll() {
  renderNavigation();
  renderRoleSections();
  renderSalaryCards();
  renderJobCards();
  renderJobSeekerDashboard();
  renderEmployerDashboard();
  renderAdminDashboard();
  renderAuthModal();
}

function renderNavigation() {
  const navItemsByRole = {
    PUBLIC: [
      ["Home", "#home"],
      ["Jobs", "#jobs"],
      ["Salaries", "#salaries"],
      ["For Employers", "#publicEmployers"]
    ],
    JOB_SEEKER: [
      ["Dashboard", "#jobSeekerDashboard"],
      ["Find Jobs", "#jobs"],
      ["Saved Jobs", "#savedJobsList"],
      ["Applications", "#jobSeekerApplications"]
    ],
    EMPLOYER: [
      ["Dashboard", "#employerDashboard"],
      ["My Jobs", "#myJobsPanel"],
      ["Applicants", "#applicantsPanel"]
    ],
    ADMIN: [
      ["Dashboard", "#adminDashboard"],
      ["Users", "#adminUsersPanel"],
      ["Companies", "#adminCompaniesPanel"],
      ["Jobs", "#adminJobsPanel"],
      ["Applications", "#adminApplicationsPanel"],
      ["Reports", "#adminReportsPanel"]
    ]
  };
  const homeByRole = {
    PUBLIC: "#home",
    JOB_SEEKER: "#jobSeekerDashboard",
    EMPLOYER: "#employerDashboard",
    ADMIN: "#adminDashboard"
  };

  if (elements.siteNav) {
    elements.siteNav.innerHTML = (navItemsByRole[state.currentRole] || navItemsByRole.PUBLIC)
      .map(([label, href]) => `<a href="${href}">${escapeHtml(label)}</a>`)
      .join("");
  }

  if (elements.brandHome) {
    elements.brandHome.setAttribute("href", homeByRole[state.currentRole] || "#home");
  }

  if (elements.authQuickStatus) {
    elements.authQuickStatus.textContent = isAuthenticated()
      ? `${roleLabel()} - ${state.currentUser?.name || state.currentUser?.email}`
      : "Not signed in";
  }

  if (elements.loginButton) {
    elements.loginButton.hidden = isAuthenticated();
  }

  if (elements.registerButton) {
    elements.registerButton.hidden = isAuthenticated();
  }

  if (elements.logoutButton) {
    elements.logoutButton.hidden = !isAuthenticated();
  }
}

function renderRoleSections() {
  document.querySelectorAll("[data-visible-roles]").forEach((section) => {
    const roles = String(section.dataset.visibleRoles || "")
      .split(",")
      .map((item) => item.trim());
    const shouldShow = roles.includes(state.currentRole);
    section.hidden = !shouldShow;

    if (shouldShow) {
      section.classList.add("in-view");
    }
  });
}

function createStatCard(label, value, _icon = "fa-chart-simple", tone = "") {
  return `
    <article class="stat-card ${tone}">
      <div>
        <p>${escapeHtml(label)}</p>
        <strong>${escapeHtml(value)}</strong>
      </div>
    </article>
  `;
}

function renderSalaryCards() {
  if (!elements.salaryGrid) {
    return;
  }

  elements.salaryGrid.innerHTML = state.salaries.slice(0, 6).map((item) => {
    const title = item.role || item.roleTitle || "Role";
    const salaryRange = item.salaryRange || "Salary benchmark";
    const level = item.level || item.experienceLevel || "Role benchmark";
    const trendLabel = item.trend || item.source || "Market signal";

    return `
      <article class="card salary-card">
        <div class="salary-card-top">
          <div>
            <p class="eyebrow">Compensation</p>
            <h3>${escapeHtml(title)}</h3>
          </div>
        </div>
        <p class="salary-value">${escapeHtml(salaryRange)}</p>
        <p>${escapeHtml(level)}</p>
        <span class="badge success">${escapeHtml(trendLabel)}</span>
      </article>
    `;
  }).join("");
}

function getFilteredJobs() {
  const value = state.currentKeyword.trim().toLowerCase();

  if (!value) {
    return [...state.jobs];
  }

  return state.jobs.filter((job) => {
    const combined = `${job.title} ${job.company} ${job.location} ${job.type || job.jobType}`.toLowerCase();
    return combined.includes(value);
  });
}

function isEmployerOwnerOfJob(job) {
  if (state.currentRole !== "EMPLOYER") {
    return false;
  }

  return state.employerJobs.some((item) => item.id === job.id);
}

function createJobCard(job) {
  const requirements = normalizeList(job.requirements);
  const requirementPreview = requirements.length
    ? truncateText(requirements.slice(0, 2).join(" - "), 120)
    : "Requirements will be shared by the employer.";
  const isSaved = state.savedJobIds.has(job.id);
  const hasApplied = isAlreadyApplied(job.id);
  const companyName = job.company || job.companyProfile?.name || "Company";
  let actionMarkup = `
    <button class="btn-action" type="button" data-action="details" data-id="${job.id}">
      <i class="fa-regular fa-eye" aria-hidden="true"></i>Details
    </button>
  `;

  if (["PUBLIC", "JOB_SEEKER"].includes(state.currentRole)) {
    actionMarkup += `
      <button class="btn-action" type="button" data-action="report-job" data-id="${job.id}">
        <i class="fa-regular fa-flag" aria-hidden="true"></i>Report
      </button>
    `;
  }

  if (state.currentRole === "PUBLIC") {
    actionMarkup += `
      <button class="btn-action strong" type="button" data-action="login-to-apply" data-id="${job.id}">
        <i class="fa-solid fa-right-to-bracket" aria-hidden="true"></i>Login to Apply
      </button>
    `;
  } else if (state.currentRole === "JOB_SEEKER") {
    actionMarkup += hasApplied
      ? `
      <button class="btn-action applied" type="button" data-action="applied" data-id="${job.id}" disabled aria-disabled="true">
        <i class="fa-solid fa-circle-check" aria-hidden="true"></i>Applied
      </button>
    `
      : `
      <button class="btn-action strong" type="button" data-action="apply" data-id="${job.id}">
        <i class="fa-solid fa-paper-plane" aria-hidden="true"></i>Apply
      </button>
    `;
    actionMarkup += `
      <button class="btn-action" type="button" data-action="save-job" data-id="${job.id}">
        <i class="${isSaved ? "fa-solid" : "fa-regular"} fa-bookmark" aria-hidden="true"></i>${isSaved ? "Saved" : "Save"}
      </button>
    `;
  } else if (state.currentRole === "EMPLOYER" && isEmployerOwnerOfJob(job)) {
    actionMarkup += `
      <a class="btn-action" href="#myJobsPanel">
        <i class="fa-solid fa-briefcase" aria-hidden="true"></i>Manage
      </a>
    `;
  } else if (state.currentRole === "ADMIN") {
    actionMarkup += `
      <a class="btn-action" href="#adminJobsPanel">
        <i class="fa-solid fa-shield-halved" aria-hidden="true"></i>Moderate
      </a>
    `;
  }

  return `
    <article class="job-card">
      <div class="job-card-top">
        <div>
          <h3>${escapeHtml(job.title)}</h3>
          <p><strong>${escapeHtml(companyName)}</strong></p>
        </div>
        <span class="icon-bubble" aria-hidden="true">${escapeHtml(getInitials(companyName))}</span>
      </div>
      <div class="job-meta-list">
        <span class="meta-pill"><i class="fa-solid fa-location-dot" aria-hidden="true"></i>${escapeHtml(job.location || "Bangladesh")}</span>
        <span class="meta-pill"><i class="fa-solid fa-briefcase" aria-hidden="true"></i>${escapeHtml(job.type || job.jobType || "Not specified")}</span>
        <span class="meta-pill"><i class="fa-regular fa-calendar" aria-hidden="true"></i>${escapeHtml(formatDate(job.postedAt || job.createdAt))}</span>
      </div>
      <p class="job-salary">${escapeHtml(job.salary || "Salary negotiable")}</p>
      <p class="requirements-preview">${escapeHtml(requirementPreview)}</p>
      <div class="job-actions">${actionMarkup}</div>
    </article>
  `;
}

function renderJobCards() {
  if (!elements.jobList) {
    return;
  }

  const filteredJobs = getFilteredJobs();

  if (elements.jobCount) {
    elements.jobCount.textContent = String(filteredJobs.length);
  }

  if (elements.jobSectionHint) {
    elements.jobSectionHint.textContent = state.currentRole === "JOB_SEEKER"
      ? "Save jobs, apply with a CV, and track status from your dashboard."
      : "Public visitors can view jobs. Sign in as a Job Seeker to apply or save roles.";
  }

  if (filteredJobs.length === 0) {
    elements.jobList.innerHTML = createEmptyState("No result found", "Try another keyword like role, company, or city.", "fa-magnifying-glass");
    return;
  }

  elements.jobList.innerHTML = createPaginatedCards("publicJobs", filteredJobs, createJobCard);
}

function createEmptyState(title, description, _icon = "fa-circle-info") {
  return `
    <article class="empty-state">
      <h3>${escapeHtml(title)}</h3>
      <p>${escapeHtml(description)}</p>
    </article>
  `;
}

function getJobById(jobId) {
  return state.jobs.find((job) => job.id === jobId)
    || state.employerJobs.find((job) => job.id === jobId)
    || state.adminJobs.find((job) => job.id === jobId)
    || null;
}

function statusBadge(status) {
  const normalized = String(status || "SUBMITTED").toUpperCase();
  return `<span class="badge status-badge status-${normalized.toLowerCase()}">${escapeHtml(normalized.replaceAll("_", " "))}</span>`;
}

function getStatusFilterLabel(status) {
  if (status === "ALL") {
    return "All";
  }

  const labels = {
    INTERVIEW: "Interviewed"
  };
  const normalized = String(status || "").toUpperCase();

  return labels[normalized] || normalized.replaceAll("_", " ").toLowerCase().replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function createApplicationStatusTabs(activeStatus, dataAttributeName) {
  return createFilterTabs(applicationStatusFilterOptions, activeStatus || "ALL", dataAttributeName, getStatusFilterLabel);
}

function createFilterTabs(options, activeStatus, dataAttributeName, labelFormatter = getStatusFilterLabel) {
  const active = activeStatus || "ALL";

  return options.map((status) => `
    <button class="filter-chip ${active === status ? "active" : ""}" type="button" data-${dataAttributeName}="${status}" role="tab" aria-selected="${active === status ? "true" : "false"}">
      ${escapeHtml(labelFormatter(status))}
    </button>
  `).join("");
}

function filterApplicationsByStatus(applications, status) {
  if (!status || status === "ALL") {
    return applications;
  }

  return applications.filter((application) => application.status === status);
}

function fillForm(form, values = {}) {
  if (!form) {
    return;
  }

  Array.from(form.elements).forEach((element) => {
    if (!element.name || element.type === "submit") {
      return;
    }

    const value = values[element.name];
    element.value = value === undefined || value === null ? "" : String(value);
  });
}

function renderJobSeekerDashboard() {
  if (state.currentRole !== "JOB_SEEKER") {
    return;
  }

  const completion = state.profile?.completion || 0;
  const savedCount = state.savedJobs.length;
  const appliedCount = state.applications.length;
  const interviewCount = state.applications.filter((item) => ["SHORTLISTED", "INTERVIEW"].includes(item.status)).length;
  const filteredApplications = filterApplicationsByStatus(state.applications, state.jobSeekerApplicationFilter);

  if (elements.jobSeekerWelcome) {
    elements.jobSeekerWelcome.textContent = `Welcome, ${state.currentUser?.name || "Job Seeker"}.`;
  }

  if (elements.jobSeekerStats) {
    elements.jobSeekerStats.innerHTML = [
      createStatCard("Profile completion", `${completion}%`, "fa-user-check", completion >= 70 ? "success" : ""),
      createStatCard("Saved jobs", savedCount, "fa-bookmark"),
      createStatCard("Applications", appliedCount, "fa-paper-plane"),
      createStatCard("Active leads", interviewCount, "fa-list-check")
    ].join("");
  }

  if (elements.profileForm && elements.profileModal?.hidden) {
    fillForm(elements.profileForm, getProfileFormValues());
  }

  if (elements.jobSeekerApplicationFilterTabs) {
    elements.jobSeekerApplicationFilterTabs.innerHTML = createApplicationStatusTabs(state.jobSeekerApplicationFilter, "job-seeker-application-filter");
  }

  if (elements.jobSeekerApplications) {
    const selectedLabel = getStatusFilterLabel(state.jobSeekerApplicationFilter).toLowerCase();
    const createJobSeekerApplicationItem = (application) => {
        const job = application.job || {};
        return `
          <article class="application-item" data-application-id="${application.id}">
            <div class="application-top">
              <div>
                <h3>${escapeHtml(application.jobTitle || job.title || "Application")}</h3>
                <p><strong>${escapeHtml(application.company || job.company || job.companyProfile?.name || "Company")}</strong></p>
              </div>
              ${statusBadge(application.status)}
            </div>
            <p class="cover-preview">${escapeHtml(truncateText(application.coverLetter || "No cover letter provided.", 140))}</p>
            <div class="application-actions">
              <button class="btn-action" type="button" data-action="view-my-application" data-id="${application.id}">
                <i class="fa-regular fa-eye" aria-hidden="true"></i>View
              </button>
            </div>
            <p class="helper-note">Submitted ${escapeHtml(formatDate(application.createdAt))}</p>
          </article>
        `;
      };
    elements.jobSeekerApplications.innerHTML = filteredApplications.length
      ? createPaginatedCards("jobSeekerApplications", filteredApplications, createJobSeekerApplicationItem)
      : createEmptyState(
        state.applications.length ? `No ${selectedLabel} applications` : "No applications yet",
        state.applications.length ? "Choose another status to see more applications." : "Apply to an open role and your status will appear here.",
        "fa-paper-plane"
      );
  }

  if (elements.savedJobsList) {
    elements.savedJobsList.innerHTML = state.savedJobs.length
      ? createPaginatedCards("savedJobs", state.savedJobs, (savedJob) => createJobCard(savedJob.job || savedJob))
      : createEmptyState("No saved jobs yet", "Use Save on a job card to build your shortlist.", "fa-bookmark");
  }
}

function createEmployerJobItem(job) {
  return `
    <article class="listing-item">
      <div class="listing-top">
        <div>
          <h3>${escapeHtml(job.title)}</h3>
          <p>${escapeHtml(job.company || job.companyProfile?.name || "Company")} | ${escapeHtml(job.location)} | ${escapeHtml(job.type || job.jobType)}</p>
        </div>
        ${statusBadge(job.status || "OPEN")}
      </div>
      <p>${escapeHtml(job.salary || "Salary negotiable")}</p>
      <p class="helper-note">${Number(job.applicationCount || 0)} applicants</p>
      <div class="listing-actions">
        <button class="btn-action" type="button" data-action="employer-job-status" data-id="${job.id}" data-status="OPEN">
          <i class="fa-solid fa-circle-play" aria-hidden="true"></i>Open
        </button>
        <button class="btn-action" type="button" data-action="employer-job-status" data-id="${job.id}" data-status="CLOSED">
          <i class="fa-solid fa-lock" aria-hidden="true"></i>Close
        </button>
      </div>
    </article>
  `;
}

function getFilteredEmployerJobs() {
  if (state.employerJobFilter === "CLOSED") {
    return state.employerJobs.filter((job) => job.status === "CLOSED");
  }

  return state.employerJobs.filter((job) => ["DRAFT", "OPEN"].includes(job.status || "OPEN"));
}

function createEmployerApplicationItem(application) {
  const statusOptions = applicationStatuses
    .map((status) => `<option value="${status}" ${application.status === status ? "selected" : ""}>${getStatusFilterLabel(status)}</option>`)
    .join("");

  return `
    <article class="application-item">
      <div class="application-top">
        <div>
          <h3>${escapeHtml(application.applicantName || "Applicant")}</h3>
          <p><strong>${escapeHtml(application.jobTitle || application.job?.title || "Job")}</strong> - ${escapeHtml(application.company || application.job?.company || application.job?.companyProfile?.name || "Company")}</p>
        </div>
        ${statusBadge(application.status)}
      </div>
      <div class="application-contact">
        <span class="meta-pill"><i class="fa-regular fa-user" aria-hidden="true"></i>${escapeHtml(application.applicantName || "Applicant")}</span>
        <span class="meta-pill"><i class="fa-regular fa-envelope" aria-hidden="true"></i>${escapeHtml(application.applicantEmail || "No email")}</span>
        ${application.applicantPhone ? `<span class="meta-pill"><i class="fa-solid fa-phone" aria-hidden="true"></i>${escapeHtml(application.applicantPhone)}</span>` : ""}
      </div>
      <p class="cover-preview">${escapeHtml(truncateText(application.coverLetter || "No cover letter provided.", 160))}</p>
      <div class="application-management">
        <label class="application-status-control">
          Status
          <select class="application-status-select" data-action="application-status" data-id="${application.id}">
            ${statusOptions}
          </select>
        </label>
        <label>
          Private note
          <textarea data-note-id="${application.id}" rows="2">${escapeHtml(application.employerNote || "")}</textarea>
        </label>
      </div>
      <div class="application-actions">
        <button class="btn-action" type="button" data-action="save-note" data-id="${application.id}">
          <i class="fa-regular fa-floppy-disk" aria-hidden="true"></i>Save Note
        </button>
        <button class="btn-action" type="button" data-action="download-cv" data-id="${application.id}">
          <i class="fa-solid fa-download" aria-hidden="true"></i>CV
        </button>
      </div>
    </article>
  `;
}

function renderEmployerDashboard() {
  if (state.currentRole !== "EMPLOYER") {
    return;
  }

  const counts = state.employerDashboard?.counts || {};
  const openJobs = state.employerJobs.filter((job) => job.status === "OPEN").length;
  const filteredEmployerJobs = getFilteredEmployerJobs();
  const filteredEmployerApplications = filterApplicationsByStatus(state.employerApplications, state.employerApplicationFilter);

  if (elements.employerWelcome) {
    elements.employerWelcome.textContent = `Hiring workspace for ${state.employerCompany?.name || state.currentUser?.name || "your company"}.`;
  }

  if (elements.companyVerificationNotice) {
    const isVerified = Boolean(state.employerCompany?.verified);
    elements.companyVerificationNotice.hidden = isVerified;
    elements.companyVerificationNotice.innerHTML = isVerified
      ? ""
      : `
        <strong>Company verification required</strong>
        <p>Your company is not verified yet. New jobs will be saved as drafts, and they cannot be opened publicly until an admin verifies the company.</p>
      `;
  }

  if (elements.employerStats) {
    elements.employerStats.innerHTML = [
      createStatCard("Verification", state.employerCompany?.verified ? "Verified" : "Pending", "fa-circle-check", state.employerCompany?.verified ? "success" : ""),
      createStatCard("Posted jobs", counts.jobsPosted ?? state.employerJobs.length, "fa-briefcase"),
      createStatCard("Open jobs", openJobs, "fa-circle-play", "success"),
      createStatCard("Applicants", counts.applications ?? state.employerApplications.length, "fa-users")
    ].join("");
  }

  if (elements.companyForm) {
    fillForm(elements.companyForm, state.employerCompany || {});
  }

  if (elements.employerJobFilterTabs) {
    elements.employerJobFilterTabs.querySelectorAll("[data-employer-job-filter]").forEach((button) => {
      button.classList.toggle("active", button.dataset.employerJobFilter === state.employerJobFilter);
    });
  }

  if (elements.employerJobsList) {
    const emptyMessages = {
      ACTIVE: ["No active jobs", "Open or draft jobs will appear here."],
      CLOSED: ["No closed jobs", "Jobs you close will appear here."]
    };
    const [title, message] = emptyMessages[state.employerJobFilter] || emptyMessages.ACTIVE;
    elements.employerJobsList.innerHTML = filteredEmployerJobs.length
      ? createPaginatedCards("employerJobs", filteredEmployerJobs, createEmployerJobItem)
      : createEmptyState(title, message, "fa-briefcase");
  }

  if (elements.employerApplicationFilterTabs) {
    elements.employerApplicationFilterTabs.innerHTML = createApplicationStatusTabs(state.employerApplicationFilter, "employer-application-filter");
  }

  if (elements.employerApplicationsList) {
    const selectedLabel = getStatusFilterLabel(state.employerApplicationFilter).toLowerCase();
    elements.employerApplicationsList.innerHTML = filteredEmployerApplications.length
      ? createPaginatedCards("employerApplications", filteredEmployerApplications, createEmployerApplicationItem)
      : createEmptyState(
        state.employerApplications.length ? `No ${selectedLabel} applicants` : "No applicants yet",
        state.employerApplications.length ? "Choose another status to see more applicants." : "Applications for your own jobs will appear here.",
        "fa-users"
      );
  }
}

function createTable(headers, rows) {
  if (!rows.length) {
    return createEmptyState("Nothing to show", "No records found for this section.", "fa-table");
  }

  return `
    <table class="data-table">
      <thead>
        <tr>${headers.map((header) => `<th>${escapeHtml(header)}</th>`).join("")}</tr>
      </thead>
      <tbody>${rows.join("")}</tbody>
    </table>
  `;
}

function getItemSortValue(item) {
  const dateValue = item.createdAt || item.updatedAt || item.submittedAt;
  const timestamp = dateValue ? Date.parse(dateValue) : Number.NaN;

  if (Number.isFinite(timestamp)) {
    return timestamp;
  }

  return Number(item.id) || 0;
}

function sortLatestFirst(items) {
  return [...items].sort((first, second) => getItemSortValue(second) - getItemSortValue(first));
}

function getPaginatedItems(items, pageKey) {
  const totalPages = Math.max(1, Math.ceil(items.length / adminPageSize));
  const currentPage = Math.min(Math.max(Number(state.paginationPages[pageKey]) || 1, 1), totalPages);
  state.paginationPages[pageKey] = currentPage;

  const start = (currentPage - 1) * adminPageSize;

  return {
    currentPage,
    totalPages,
    items: items.slice(start, start + adminPageSize)
  };
}

function createPaginationControls(pageKey, currentPage, totalPages, totalItems) {
  const pages = [];
  const addPage = (page) => {
    if (page >= 1 && page <= totalPages && !pages.includes(page)) {
      pages.push(page);
    }
  };

  [1, currentPage - 2, currentPage - 1, currentPage, currentPage + 1, currentPage + 2, totalPages].forEach(addPage);
  pages.sort((first, second) => first - second);

  const pageButtons = pages.flatMap((page, index) => {
    const controls = [];
    const previous = pages[index - 1];

    if (previous && page - previous > 1) {
      controls.push(`<span class="pagination-ellipsis" aria-hidden="true">...</span>`);
    }

    controls.push(`
      <button class="pagination-button ${page === currentPage ? "active" : ""}" type="button" data-pagination="${pageKey}" data-page="${page}" aria-current="${page === currentPage ? "page" : "false"}">
        ${page}
      </button>
    `);

    return controls;
  }).join("");

  return `
    <nav class="pagination-bar" aria-label="Pagination">
      <span class="pagination-summary">Page ${escapeHtml(currentPage)} of ${escapeHtml(totalPages)} · Showing ${escapeHtml(Math.min((currentPage - 1) * adminPageSize + 1, totalItems))}-${escapeHtml(Math.min(currentPage * adminPageSize, totalItems))} of ${escapeHtml(totalItems)}</span>
      <div class="pagination-controls">
        <button class="pagination-button" type="button" data-pagination="${pageKey}" data-page="1" ${currentPage === 1 ? "disabled" : ""}>First</button>
        <button class="pagination-button" type="button" data-pagination="${pageKey}" data-page="${currentPage - 1}" ${currentPage === 1 ? "disabled" : ""}>Prev</button>
        ${pageButtons}
        <button class="pagination-button" type="button" data-pagination="${pageKey}" data-page="${currentPage + 1}" ${currentPage === totalPages ? "disabled" : ""}>Next</button>
      </div>
    </nav>
  `;
}

function createPaginatedTable(pageKey, headers, items, rowRenderer) {
  const latestItems = sortLatestFirst(items);
  const pagination = getPaginatedItems(latestItems, pageKey);
  const rows = pagination.items.map(rowRenderer);

  return createTable(headers, rows) + createPaginationControls(pageKey, pagination.currentPage, pagination.totalPages, latestItems.length);
}

function createPaginatedList(pageKey, items, itemRenderer, emptyTitle, emptyDescription, emptyIcon) {
  const latestItems = sortLatestFirst(items);
  const pagination = getPaginatedItems(latestItems, pageKey);

  if (!latestItems.length) {
    return createEmptyState(emptyTitle, emptyDescription, emptyIcon);
  }

  return pagination.items.map(itemRenderer).join("") + createPaginationControls(pageKey, pagination.currentPage, pagination.totalPages, latestItems.length);
}

function createPaginatedCards(pageKey, items, itemRenderer) {
  const latestItems = sortLatestFirst(items);
  const pagination = getPaginatedItems(latestItems, pageKey);

  return pagination.items.map(itemRenderer).join("") + createPaginationControls(pageKey, pagination.currentPage, pagination.totalPages, latestItems.length);
}

function getApplicationSearchText(application) {
  return [
    application.applicantName,
    application.applicantEmail,
    application.jobTitle,
    application.job?.title,
    application.company,
    application.job?.company,
    application.job?.companyProfile?.name
  ].filter(Boolean).join(" ").toLowerCase();
}

function getFilteredAdminApplications() {
  const search = state.adminApplicationFilters.search.trim().toLowerCase();
  const status = state.adminApplicationFilters.status;

  return state.adminApplications.filter((application) => {
    const matchesStatus = !status || application.status === status;
    const matchesSearch = !search || getApplicationSearchText(application).includes(search);
    return matchesStatus && matchesSearch;
  });
}

function createApplicationActionButtons(application, prefix = "admin") {
  const actions = [
    ["REVIEWED", "Mark Reviewed"],
    ["SHORTLISTED", "Shortlist"],
    ["INTERVIEW", "Move to Interview"],
    ["REJECTED", "Reject"],
    ["HIRED", "Hire"]
  ];

  return actions.map(([status, label]) => `
    <button class="btn-action ${["REJECTED"].includes(status) ? "danger" : ""}" type="button" data-action="${prefix}-application-status" data-id="${application.id}" data-status="${status}" ${application.status === status ? "disabled" : ""}>
      ${escapeHtml(label)}
    </button>
  `).join("");
}

function renderAdminDashboard() {
  if (state.currentRole !== "ADMIN") {
    return;
  }

  const stats = state.adminStats || {};
  const activeUsers = state.adminUsers.filter((user) => user.isActive);
  const inactiveUsers = state.adminUsers.filter((user) => !user.isActive);
  const verifiedCompanies = state.adminCompanies.filter((company) => company.verified);
  const unverifiedCompanies = state.adminCompanies.filter((company) => !company.verified);
  const openJobs = state.adminJobs.filter((job) => job.status === "OPEN");
  const closedJobs = state.adminJobs.filter((job) => job.status === "CLOSED");
  const filteredUsers = state.adminUserFilter === "ACTIVE"
    ? activeUsers
    : state.adminUserFilter === "INACTIVE"
      ? inactiveUsers
      : state.adminUsers;
  const filteredCompanies = state.adminCompanyFilter === "VERIFIED"
    ? verifiedCompanies
    : state.adminCompanyFilter === "UNVERIFIED"
      ? unverifiedCompanies
      : state.adminCompanies;
  const filteredJobs = state.adminJobFilter === "OPEN"
    ? openJobs
    : state.adminJobFilter === "CLOSED"
      ? closedJobs
      : state.adminJobs.filter((job) => job.status === "OPEN" || job.status === "CLOSED");

  if (elements.adminStatsGrid) {
    elements.adminStatsGrid.innerHTML = [
      createStatCard("Job seekers", stats.totalJobSeekers || 0, "fa-user-graduate"),
      createStatCard("Employers", stats.totalEmployers || 0, "fa-building"),
      createStatCard("Companies", `${stats.verifiedCompanies || 0}/${stats.totalCompanies || 0} verified`, "fa-circle-check", "success"),
      createStatCard("Jobs", `${stats.openJobs || 0}/${stats.totalJobs || 0} open`, "fa-briefcase")
    ].join("");
  }

  if (elements.adminUserStatusSummary) {
    elements.adminUserStatusSummary.innerHTML = [
      createStatCard("Active", activeUsers.length, "fa-user-check", "success"),
      createStatCard("Inactive", inactiveUsers.length, "fa-user-slash")
    ].join("");
  }

  if (elements.adminUserFilterTabs) {
    elements.adminUserFilterTabs.innerHTML = createFilterTabs(["ALL", "ACTIVE", "INACTIVE"], state.adminUserFilter, "admin-user-filter");
  }

  const createAdminUserRows = (users) => users.map((user) => `
      <tr>
        <td>${escapeHtml(user.name)}</td>
        <td>${escapeHtml(user.email)}</td>
        <td>${statusBadge(user.role)}</td>
        <td>${user.isActive ? statusBadge("ACTIVE") : statusBadge("INACTIVE")}</td>
        <td>
          <button class="btn-action" type="button" data-action="toggle-user" data-id="${user.id}" data-active="${user.isActive ? "false" : "true"}">
            ${user.isActive ? "Deactivate" : "Activate"}
          </button>
        </td>
      </tr>
    `);

  if (elements.adminUsersTable) {
    elements.adminUsersTable.innerHTML = createPaginatedTable("users", ["Name", "Email", "Role", "Status", "Action"], filteredUsers, (user) => createAdminUserRows([user]).join(""));
  }

  if (elements.adminCompanyStatusSummary) {
    elements.adminCompanyStatusSummary.innerHTML = [
      createStatCard("Verified", verifiedCompanies.length, "fa-circle-check", "success"),
      createStatCard("Unverified", unverifiedCompanies.length, "fa-circle-xmark")
    ].join("");
  }

  if (elements.adminCompanyFilterTabs) {
    elements.adminCompanyFilterTabs.innerHTML = createFilterTabs(["ALL", "VERIFIED", "UNVERIFIED"], state.adminCompanyFilter, "admin-company-filter");
  }

  const createCompanyRows = (companies) => companies.map((company) => `
      <tr>
        <td>${escapeHtml(company.name)}</td>
        <td>${escapeHtml(company.owner?.email || "Owner")}</td>
        <td>${escapeHtml(company.location || "Not set")}</td>
        <td>${company.verified ? statusBadge("VERIFIED") : statusBadge("UNVERIFIED")}</td>
        <td>
          <button class="btn-action" type="button" data-action="verify-company" data-id="${company.id}" data-verified="${company.verified ? "false" : "true"}">
            ${company.verified ? "Unverify" : "Verify"}
          </button>
        </td>
      </tr>
    `);

  if (elements.adminCompaniesTable) {
    elements.adminCompaniesTable.innerHTML = createPaginatedTable("companies", ["Company", "Owner", "Location", "Verified", "Action"], filteredCompanies, (company) => createCompanyRows([company]).join(""));
  }

  if (elements.adminJobStatusSummary) {
    elements.adminJobStatusSummary.innerHTML = [
      createStatCard("Open", openJobs.length, "fa-briefcase", "success"),
      createStatCard("Closed", closedJobs.length, "fa-lock")
    ].join("");
  }

  if (elements.adminJobFilterTabs) {
    elements.adminJobFilterTabs.innerHTML = createFilterTabs(["ALL", "OPEN", "CLOSED"], state.adminJobFilter, "admin-job-filter");
  }

  const createJobRows = (jobs) => jobs.map((job) => {
      const options = jobStatuses
        .map((status) => `<option value="${status}" ${job.status === status ? "selected" : ""}>${status}</option>`)
        .join("");
      return `
        <tr>
          <td>${escapeHtml(job.title)}</td>
          <td>${escapeHtml(job.company || job.companyProfile?.name || "Company")}</td>
          <td>${escapeHtml(job.location || "")}</td>
          <td>${statusBadge(job.status)}</td>
          <td>
            <select data-action="admin-job-status" data-id="${job.id}">${options}</select>
          </td>
        </tr>
      `;
    });

  if (elements.adminJobsTable) {
    elements.adminJobsTable.innerHTML = createPaginatedTable("jobs", ["Title", "Company", "Location", "Status", "Moderate"], filteredJobs, (job) => createJobRows([job]).join(""));
  }

  if (elements.adminApplicationsTable) {
    const filteredApplications = getFilteredAdminApplications();
    const createApplicationRow = (application) => `
      <tr>
        <td>${escapeHtml(application.applicantName || "Applicant")}</td>
        <td>${escapeHtml(application.applicantEmail || "")}</td>
        <td>${escapeHtml(application.jobTitle || application.job?.title || "Job")}</td>
        <td>${escapeHtml(application.company || application.job?.company || application.job?.companyProfile?.name || "Company")}</td>
        <td>${statusBadge(application.status)}</td>
        <td>${escapeHtml(formatDate(application.createdAt))}</td>
        <td>
          <div class="table-actions">
            ${createApplicationActionButtons(application)}
            <button class="btn-action" type="button" data-action="admin-download-cv" data-id="${application.id}">
              <i class="fa-solid fa-download" aria-hidden="true"></i>CV
            </button>
          </div>
        </td>
      </tr>
    `;
    elements.adminApplicationsTable.innerHTML = createPaginatedTable("applications", ["Applicant", "Email", "Job", "Company", "Status", "Submitted", "Actions"], filteredApplications, createApplicationRow);
  }

  if (elements.adminApplicationStatusSummary) {
    elements.adminApplicationStatusSummary.innerHTML = applicationStatuses.map((status) => {
      const count = state.adminApplications.filter((application) => application.status === status).length;
      return createStatCard(getStatusFilterLabel(status), count, status === "SHORTLISTED" ? "fa-star" : "fa-list-check", status === "HIRED" ? "success" : "");
    }).join("");
  }

  if (elements.adminApplicationFilterTabs) {
    elements.adminApplicationFilterTabs.innerHTML = createApplicationStatusTabs(state.adminApplicationFilters.status || "ALL", "admin-application-filter");
  }

  if (elements.adminReportsList) {
    elements.adminReportsList.innerHTML = createPaginatedList(
      "reports",
      state.adminReports,
      (report) => {
        const options = reportStatuses
          .map((status) => `<option value="${status}" ${report.status === status ? "selected" : ""}>${status}</option>`)
          .join("");

        return `
          <article class="compact-list-item">
            <div>
              <strong>${escapeHtml(report.targetType)} #${escapeHtml(report.targetId)}</strong>
              <p>${escapeHtml(report.reason)}</p>
              <p class="helper-note">Reported by ${escapeHtml(report.reporter?.email || "User")}</p>
            </div>
            <label class="compact-select-label">
              Status
              <select data-action="report-status" data-id="${report.id}">${options}</select>
            </label>
          </article>
        `;
      },
      "No reports",
      "Moderation reports will appear here.",
      "fa-shield-halved"
    );
  }

  if (elements.adminSalaryInsights) {
    elements.adminSalaryInsights.innerHTML = createPaginatedList(
      "salaryInsights",
      state.salaries,
      (item) => `
        <article class="compact-list-item">
          <div>
            <strong>${escapeHtml(item.role || item.roleTitle)}</strong>
            <p>${escapeHtml(item.salaryRange || `${item.salaryMin} - ${item.salaryMax}`)} ${item.location ? `- ${escapeHtml(item.location)}` : ""}</p>
          </div>
          <button class="btn-action danger" type="button" data-action="delete-salary" data-id="${item.id}">
            Delete
          </button>
        </article>
      `,
      "No salary insights",
      "Add the first benchmark using the form above.",
      "fa-chart-line"
    );
  }
}

function renderAuthModal() {
  const isRecovery = state.authMode === "recovery";

  if (state.authRole === "ADMIN" && state.authMode === "register") {
    state.authMode = "login";
  }

  const isRegister = state.authMode === "register";
  const isEmployerRegister = isRegister && state.authRole === "EMPLOYER";

  if (elements.authModalTitle) {
    elements.authModalTitle.textContent = isRecovery ? "Recover your account" : "Welcome to Career Bridge";
  }

  if (elements.authModalHelper) {
    elements.authModalHelper.textContent = isRecovery
      ? "Enter your account email and follow the reset instructions."
      : "Choose your role and continue securely.";
  }

  if (elements.authModeSwitch) {
    elements.authModeSwitch.hidden = isRecovery;
  }

  if (elements.authRoleSwitch) {
    elements.authRoleSwitch.hidden = isRecovery;
  }

  if (elements.authForm) {
    elements.authForm.hidden = isRecovery;
  }

  if (elements.passwordRecoveryPanel) {
    elements.passwordRecoveryPanel.hidden = !isRecovery;
  }

  if (elements.authLoginMode) {
    elements.authLoginMode.classList.toggle("active", !isRegister);
  }

  if (elements.authRegisterMode) {
    elements.authRegisterMode.classList.toggle("active", isRegister);
    elements.authRegisterMode.disabled = state.authRole === "ADMIN";
  }

  document.querySelectorAll("[data-auth-role]").forEach((button) => {
    button.classList.toggle("active", button.dataset.authRole === state.authRole);
  });

  document.querySelectorAll(".auth-register-only").forEach((element) => {
    element.hidden = !isRegister;
  });

  document.querySelectorAll(".auth-employer-register-only").forEach((element) => {
    element.hidden = !isEmployerRegister;
  });

  if (elements.authSubmitButton) {
    elements.authSubmitButton.textContent = isRegister ? `Register as ${roleLabel(state.authRole)}` : `Login as ${roleLabel(state.authRole)}`;
  }

  if (elements.authPassword) {
    elements.authPassword.setAttribute("autocomplete", isRegister ? "new-password" : "current-password");
  }

  if (elements.passwordHelper) {
    elements.passwordHelper.textContent = isRegister
      ? "Use at least 8 characters. A mix of letters and numbers is recommended."
      : "Use demo1234 for seeded demo accounts.";
  }

  if (elements.forgotPasswordPanel) {
    elements.forgotPasswordPanel.hidden = isRegister || isRecovery;
  }

  if (elements.resetPasswordForm && (isRegister || !isRecovery)) {
    elements.resetPasswordForm.hidden = true;
  }

  if (elements.authDemoHint) {
    const hints = {
      JOB_SEEKER: "Demo Job Seeker: employee@careerbridge.com / demo1234",
      EMPLOYER: "Demo Employer: employer@careerbridge.com / demo1234",
      ADMIN: "Demo Admin: admin@careerbridge.com / demo1234"
    };
    elements.authDemoHint.textContent = isRecovery ? "" : hints[state.authRole] || "";
  }
}

function openPasswordRecovery() {
  state.authMode = "recovery";
  renderAuthModal();
  setFormStatus(elements.authStatus, "");
  setFormStatus(elements.resetStatus, "");

  const email = String(elements.authEmail?.value || "").trim();
  if (elements.recoveryEmailInput && email) {
    elements.recoveryEmailInput.value = email;
  }

  if (elements.resetPasswordForm) {
    elements.resetPasswordForm.hidden = true;
  }

  window.requestAnimationFrame(() => elements.recoveryEmailInput?.focus());
}

function returnToLoginFromRecovery(message = "") {
  state.authMode = "login";
  renderAuthModal();

  if (elements.resetPasswordForm) {
    elements.resetPasswordForm.hidden = true;
  }

  if (message) {
    setFormStatus(elements.authStatus, message, "success");
  }
}

function openAuthModal(mode = "login", role = "JOB_SEEKER") {
  state.authMode = mode === "recovery" ? "recovery" : mode === "register" ? "register" : "login";
  state.authRole = normalizeRole(role);
  renderAuthModal();
  setFormStatus(elements.authStatus, "");
  setFormStatus(elements.resetStatus, "");

  if (elements.resetPasswordForm) {
    elements.resetPasswordForm.hidden = true;
  }

  if (elements.authModal) {
    elements.authModal.hidden = false;
    syncModalOpenState();
    window.requestAnimationFrame(() => {
      const focusTarget = state.authMode === "register" ? elements.authName : elements.authEmail;
      focusTarget?.focus();
    });
  }
}

function closeAuthModal() {
  if (elements.authModal) {
    elements.authModal.hidden = true;
    syncModalOpenState();
  }
}

const cvBuilderListConfig = {
  education: {
    container: () => elements.cvBuilderEducationList,
    fields: [
      ["degree", "What did you study?", "Bachelor of Business Administration"],
      ["years", "When?", "2020 - 2024 or Present"],
      ["institution", "Where?", "University, training center, or certification body"],
      ["location", "Location", "Dhaka, Bangladesh"],
      ["resultType", "Result type", "CGPA", "select", ["CGPA", "GPA", "Grade", "Percentage", "Division", "Result"]],
      ["resultValue", "Result value", "3.80"],
      ["resultScale", "Out of", "4.00"],
      ["group", "Main subject/focus", "Marketing, Finance, HR, Design, Software, etc."],
      ["awards", "Relevant coursework or thesis", "Relevant coursework, thesis, capstone, or academic focus notes", "textarea"]
    ]
  },
  skills: {
    container: () => elements.cvBuilderSkillsList,
    fields: [
      ["category", "Skill group", "Core Skills"],
      ["values", "Skills", "Customer service, reporting, negotiation, stakeholder communication"]
    ]
  },
  projects: {
    container: () => elements.cvBuilderProjectsList,
    fields: [
      ["title", "Work sample title", "Customer Retention Campaign"],
      ["source", "Link title", "Portfolio"],
      ["link", "Source URL", "https://your-portfolio.example.com/project"],
      ["technologies", "Tools, methods, or keywords", "Excel, CRM, market research, reporting"],
      ["bullets", "What did you do?", "Analyzed customer feedback to identify churn patterns.\nPrepared weekly reports that helped improve follow-up speed.", "textarea"]
    ]
  },
  achievements: {
    container: () => elements.cvBuilderAchievementsList,
    fields: [
      ["title", "Title", "Employee of the Month"],
      ["organization", "Given by", "Company, platform, or awarding body"],
      ["dates", "When?", "2024"],
      ["link", "Link", "https://example.com"],
      ["bullets", "Details", "Recognized for consistently exceeding service quality targets.\nMentored two new team members during onboarding.", "textarea"]
    ]
  },
  activities: {
    container: () => elements.cvBuilderActivitiesList,
    fields: [
      ["role", "Your role", "Volunteer Coordinator"],
      ["organization", "Organization", "Community organization, club, association, or event"],
      ["dates", "When?", "2022 - Present"]
    ]
  },
  references: {
    container: () => elements.cvBuilderReferencesList,
    fields: [
      ["name", "Name", "Reference Name"],
      ["position", "Position", "Manager, supervisor, faculty member, or client"],
      ["department", "Department/team", "Operations, HR, Sales, Academic Department"],
      ["institution", "Organization", "Company, university, or organization"],
      ["email", "Email", "reference@example.com"]
    ]
  }
};

function getCvBuilderScalarFields() {
  return Array.from(elements.cvBuilderPanel?.querySelectorAll("[data-cv-scalar]") || []);
}

function normalizeCvBuilderBullets(value) {
  const source = Array.isArray(value) ? value.join("\n") : value;
  return String(source || "")
    .split(/\n+/)
    .map((item) => item.replace(/^[•*-]\s*/, "").trim())
    .filter(Boolean);
}

function hasCvBuilderItemValue(item) {
  return Object.values(item || {}).some((value) => String(value || "").trim());
}

function createCvBuilderInput(field, value = "") {
  const [name, label, placeholder, type, options = []] = field;
  let inputMarkup = `<input data-cv-field="${name}" type="${name === "email" ? "email" : name === "link" ? "url" : "text"}" placeholder="${escapeHtml(placeholder)}" value="${escapeHtml(value)}" />`;

  if (type === "textarea") {
    inputMarkup = `<textarea data-cv-field="${name}" rows="3" placeholder="${escapeHtml(placeholder)}">${escapeHtml(value)}</textarea>`;
  }

  if (type === "select") {
    inputMarkup = `
      <select data-cv-field="${name}">
        ${options.map((option) => `<option value="${escapeHtml(option)}" ${String(value || placeholder) === option ? "selected" : ""}>${escapeHtml(option)}</option>`).join("")}
      </select>
    `;
  }

  return `<label>${escapeHtml(label)}${inputMarkup}</label>`;
}

function addCvBuilderItem(type, values = {}) {
  const config = cvBuilderListConfig[type];
  const container = config?.container();

  if (!config || !container) {
    return null;
  }

  const item = document.createElement("div");
  item.className = "cv-repeatable-item";
  item.dataset.cvItem = type;
  item.innerHTML = `
    <div class="cv-repeatable-fields">
      ${config.fields.map((field) => createCvBuilderInput(field, values[field[0]])).join("")}
    </div>
    <button class="btn btn-secondary cv-remove-item" type="button" data-cv-remove="${type}">Remove</button>
  `;
  container.append(item);
  return item;
}

function clearCvBuilderList(type) {
  const container = cvBuilderListConfig[type]?.container();
  if (container) {
    container.innerHTML = "";
  }
}

function addDefaultCvBuilderRows() {
  const defaults = {
    education: [{}],
    skills: [
      { category: "Core Skills" },
      { category: "Tools & Platforms" },
      { category: "Industry Knowledge" },
      { category: "Languages" }
    ],
    projects: [{}],
    achievements: [{}],
    activities: [{}],
    references: [{}, {}]
  };

  Object.entries(defaults).forEach(([type, items]) => {
    const container = cvBuilderListConfig[type]?.container();
    if (container && !container.children.length) {
      items.forEach((item) => addCvBuilderItem(type, item));
    }
  });
}

function getCvBuilderDraft() {
  const scalars = Object.fromEntries(getCvBuilderScalarFields().map((element) => [
    element.dataset.cvScalar,
    String(element.value || "").trim()
  ]));
  const lists = {};

  Object.keys(cvBuilderListConfig).forEach((type) => {
    const container = cvBuilderListConfig[type].container();
    lists[type] = Array.from(container?.querySelectorAll("[data-cv-item]") || [])
      .map((item) => Object.fromEntries(Array.from(item.querySelectorAll("[data-cv-field]")).map((field) => [
        field.dataset.cvField,
        String(field.value || "").trim()
      ])))
      .filter(hasCvBuilderItemValue);
  });

  return { scalars, ...lists };
}

function saveCvBuilderDraft() {
  window.localStorage.setItem(CV_BUILDER_STORAGE_KEY, JSON.stringify(getCvBuilderDraft()));
}

function migrateLegacyCvBuilderDraft(draft) {
  if (draft.scalars) {
    return draft;
  }

  return {
    scalars: {
      program: draft.program || "",
      studentId: draft.studentId || "",
      summary: draft.summary || "",
      location: draft.location || "",
      address: draft.address || "",
      linkedin: draft.linkedin || "",
      github: draft.github || ""
    },
    education: draft.education ? [{ degree: draft.education }] : [],
    skills: [
      draft.skillLanguages ? { category: "Languages", values: draft.skillLanguages } : null,
      draft.skillFrameworks ? { category: "Frameworks", values: draft.skillFrameworks } : null,
      draft.skillTools ? { category: "Tools & Platforms", values: draft.skillTools } : null
    ].filter(Boolean),
    projects: draft.projects ? [{ title: draft.projects }] : [],
    achievements: draft.certifications ? [{ title: draft.certifications }] : [],
    activities: draft.activities ? [{ role: draft.activities }] : [],
    references: [draft.referenceOne ? { name: draft.referenceOne } : null, draft.referenceTwo ? { name: draft.referenceTwo } : null].filter(Boolean)
  };
}

function loadCvBuilderDraft() {
  let draft = {};

  try {
    draft = migrateLegacyCvBuilderDraft(JSON.parse(window.localStorage.getItem(CV_BUILDER_STORAGE_KEY) || "{}"));
  } catch (_error) {
    draft = {};
  }

  getCvBuilderScalarFields().forEach((element) => {
    const value = draft.scalars?.[element.dataset.cvScalar];
    if (value) {
      element.value = value;
    }
  });

  Object.keys(cvBuilderListConfig).forEach((type) => {
    clearCvBuilderList(type);
    (Array.isArray(draft[type]) ? draft[type] : []).forEach((item) => addCvBuilderItem(type, item));
  });
  addDefaultCvBuilderRows();
}

function resetCvBuilderForm() {
  getCvBuilderScalarFields().forEach((element) => {
    element.value = "";
  });
  Object.keys(cvBuilderListConfig).forEach(clearCvBuilderList);
  addDefaultCvBuilderRows();
  state.cvBuilderPhotoDataUrl = "";
  state.cvBuilderPhotoPdfData = null;
  state.generatedCvFile = null;
  window.localStorage.removeItem(CV_BUILDER_STORAGE_KEY);
  if (elements.cvBuilderPreview) {
    elements.cvBuilderPreview.hidden = true;
    elements.cvBuilderPreview.innerHTML = "";
  }
  if (elements.cvBuilderPhoto) {
    elements.cvBuilderPhoto.value = "";
  }
  setFormStatus(elements.cvBuilderStatus, "CV Builder form cleared.", "success");
}

function getCvBuilderData() {
  const draft = getCvBuilderDraft();
  const scalars = draft.scalars || {};

  return {
    fullName: String(elements.applyName?.value || state.currentUser?.name || "").trim(),
    email: String(elements.applyEmail?.value || state.currentUser?.email || "").trim(),
    phone: String(elements.applyPhone?.value || state.profile?.phone || "").trim(),
    program: scalars.program || "",
    studentId: scalars.studentId || "",
    summary: scalars.summary || state.profile?.bio || "",
    location: scalars.location || state.profile?.location || "",
    address: scalars.address || "",
    linkedin: scalars.linkedin || state.profile?.linkedinUrl || "",
    github: scalars.github || state.profile?.githubUrl || "",
    education: draft.education || [],
    skills: draft.skills || [],
    projects: draft.projects || [],
    achievements: draft.achievements || [],
    activities: draft.activities || [],
    references: draft.references || []
  };
}

function validateCvBuilderData(data) {
  if (!data.fullName || !data.email) {
    return "Full name and email are required before generating a CV.";
  }

  return "";
}

function formatCvUrlLabel(url) {
  return String(url || "").replace(/^https?:\/\//i, "").replace(/\/$/, "");
}

function renderCvLink(url, label = "") {
  if (!url) {
    return label ? escapeHtml(label) : "";
  }

  const safeUrl = escapeHtml(url);
  return `<a href="${safeUrl}" target="_blank" rel="noopener">${escapeHtml(label || formatCvUrlLabel(url))}</a>`;
}

function renderCvBullets(items) {
  const bullets = Array.isArray(items) ? items : normalizeCvBuilderBullets(items);
  return bullets.length
    ? `<ul>${bullets.map((item) => `<li>${escapeHtml(item)}</li>`).join("")}</ul>`
    : "";
}

function renderCvSection(title, content) {
  const trimmed = String(content || "").trim();
  return trimmed ? `<section class="cv-doc-section"><h4>${escapeHtml(title)}</h4>${trimmed}</section>` : "";
}

function formatEducationResult(item) {
  if (item.result) {
    return item.result;
  }

  const value = String(item.resultValue || "").trim();
  if (!value) {
    return "";
  }

  const type = String(item.resultType || "Result").trim();
  const scale = String(item.resultScale || "").trim();
  return scale ? `${type}: ${value} / ${scale}` : `${type}: ${value}`;
}

function buildCvPreviewMarkup(data) {
  const photoMarkup = state.cvBuilderPhotoDataUrl
    ? `<img class="cv-photo-preview" src="${state.cvBuilderPhotoDataUrl}" alt="Profile preview" />`
    : "";
  const identity = [data.program, data.studentId].filter(Boolean).join(" • ");
  const contact = [data.phone, data.email ? renderCvLink(`mailto:${data.email}`, data.email) : ""].filter(Boolean).join(" &nbsp; ");
  const links = [renderCvLink(data.linkedin, "LinkedIn"), renderCvLink(data.github, "GitHub")].filter(Boolean).join(" &nbsp; ");
  const education = data.education.filter(hasCvBuilderItemValue).map((item) => {
    const meta = [formatEducationResult(item), item.group ? `Focus: ${item.group}` : ""].filter(Boolean);
    return `
      <div class="cv-doc-entry">
        <div class="cv-doc-entry-head">
          <strong>${escapeHtml(item.degree || "Education")}</strong>
          ${item.years ? `<span>${escapeHtml(item.years)}</span>` : ""}
        </div>
        <div class="cv-doc-entry-sub">
          <em>${escapeHtml(item.institution || "")}</em>
          ${item.location ? `<span>${escapeHtml(item.location)}</span>` : ""}
        </div>
        ${renderCvBullets(meta)}
      </div>
    `;
  }).join("");
  const skills = data.skills.filter((item) => String(item.values || "").trim()).map((item) => `
    <div class="cv-doc-skill-row">
      <strong>${escapeHtml(item.category || "Skills")}</strong>
      <span>${escapeHtml(item.values || "")}</span>
    </div>
  `).join("");
  const projects = data.projects.filter(hasCvBuilderItemValue).map((item) => `
    <div class="cv-doc-entry">
      <div class="cv-doc-entry-head">
        <strong>${escapeHtml(item.title || "Project")}${item.source || item.link ? ` | ${renderCvLink(item.link, item.source || "Source")}` : ""}</strong>
        ${item.technologies ? `<span>${escapeHtml(item.technologies)}</span>` : ""}
      </div>
      ${renderCvBullets(item.bullets)}
    </div>
  `).join("");
  const achievements = data.achievements.filter(hasCvBuilderItemValue).map((item) => `
    <div class="cv-doc-entry">
      <div class="cv-doc-entry-head">
        <strong>${escapeHtml(item.title || "Achievement")}${item.link ? ` | ${renderCvLink(item.link, "Link")}` : ""}</strong>
        ${item.dates ? `<span>${escapeHtml(item.dates)}</span>` : ""}
      </div>
      ${item.organization ? `<div class="cv-doc-entry-sub"><em>${escapeHtml(item.organization)}</em></div>` : ""}
      ${renderCvBullets(item.bullets)}
    </div>
  `).join("");
  const activities = data.activities.filter(hasCvBuilderItemValue).map((item) => `
    <div class="cv-doc-entry cv-doc-activity">
      <strong>${escapeHtml(item.role || "Activity")}</strong>
      ${item.organization ? `<span>${escapeHtml(item.organization)}</span>` : ""}
      ${item.dates ? `<span>${escapeHtml(item.dates)}</span>` : ""}
    </div>
  `).join("");
  const references = data.references.filter(hasCvBuilderItemValue).map((item) => `
    <div class="cv-doc-reference">
      <strong>${escapeHtml(item.name || "Reference")}</strong>
      ${[item.position, item.department, item.institution].filter(Boolean).map((line) => `<span>${escapeHtml(line)}</span>`).join("")}
      ${item.email ? `<span>${renderCvLink(`mailto:${item.email}`, item.email)}</span>` : ""}
    </div>
  `).join("");

  return `
    <div class="cv-document">
      <header class="cv-doc-header">
        <div>
          <h3>${escapeHtml(data.fullName)}</h3>
      ${identity ? `<p>${escapeHtml(identity)}</p>` : ""}
      ${contact ? `<p>${contact}</p>` : ""}
      ${data.address || data.location ? `<p>${escapeHtml(data.address || data.location)}</p>` : ""}
      ${links ? `<p>${links}</p>` : ""}
        </div>
        ${photoMarkup}
      </header>
      ${renderCvSection("Professional Summary", data.summary ? `<p>${escapeHtml(data.summary)}</p>` : "")}
      ${renderCvSection("Education", education)}
      ${renderCvSection("Skills", skills)}
      ${renderCvSection("Projects / Work Samples", projects)}
      ${renderCvSection("Achievements", achievements)}
      ${renderCvSection("Leadership & Activities", activities)}
      ${renderCvSection("References", references ? `<div class="cv-doc-reference-grid">${references}</div>` : "")}
      <footer class="cv-doc-footer">${escapeHtml(data.fullName)} — Page 1 of 2</footer>
    </div>
  `;
}

function renderCvBuilderPreview() {
  const data = getCvBuilderData();
  const validationMessage = validateCvBuilderData(data);

  if (validationMessage) {
    setFormStatus(elements.cvBuilderStatus, validationMessage, "error");
    return false;
  }

  if (elements.cvBuilderPreview) {
    elements.cvBuilderPreview.hidden = false;
    elements.cvBuilderPreview.innerHTML = buildCvPreviewMarkup(data);
  }

  saveCvBuilderDraft();
  setFormStatus(elements.cvBuilderStatus, "CV preview is ready. Download it or attach the generated CV to your application.", "success");
  return true;
}

function dataUrlToBytes(dataUrl) {
  const base64 = String(dataUrl || "").split(",")[1] || "";
  const binary = window.atob(base64);
  const bytes = new Uint8Array(binary.length);

  for (let index = 0; index < binary.length; index += 1) {
    bytes[index] = binary.charCodeAt(index);
  }

  return bytes;
}

function prepareCvBuilderPhotoForPdf(dataUrl) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.addEventListener("load", () => {
      const targetWidth = 280;
      const targetHeight = 352;
      const portraitFocalY = 0.42;
      const canvas = document.createElement("canvas");
      const context = canvas.getContext("2d");

      canvas.width = targetWidth;
      canvas.height = targetHeight;

      const sourceRatio = image.naturalWidth / image.naturalHeight;
      const targetRatio = targetWidth / targetHeight;
      let sourceWidth = image.naturalWidth;
      let sourceHeight = image.naturalHeight;
      let sourceX = 0;
      let sourceY = 0;

      if (sourceRatio > targetRatio) {
        sourceWidth = image.naturalHeight * targetRatio;
        sourceX = (image.naturalWidth - sourceWidth) / 2;
      } else {
        sourceHeight = image.naturalWidth / targetRatio;
        sourceY = (image.naturalHeight * portraitFocalY) - (sourceHeight * portraitFocalY);
      }

      sourceX = Math.max(0, Math.min(sourceX, image.naturalWidth - sourceWidth));
      sourceY = Math.max(0, Math.min(sourceY, image.naturalHeight - sourceHeight));

      context.fillStyle = "#ffffff";
      context.fillRect(0, 0, targetWidth, targetHeight);
      context.drawImage(image, sourceX, sourceY, sourceWidth, sourceHeight, 0, 0, targetWidth, targetHeight);

      const jpegDataUrl = canvas.toDataURL("image/jpeg", 0.88);
      resolve({
        width: targetWidth,
        height: targetHeight,
        bytes: dataUrlToBytes(jpegDataUrl)
      });
    });
    image.addEventListener("error", () => reject(new Error("Could not read profile picture.")));
    image.src = dataUrl;
  });
}

function escapePdfText(value) {
  return String(value || "")
    .replaceAll("\\", "\\\\")
    .replaceAll("(", "\\(")
    .replaceAll(")", "\\)")
    .replace(/[^\x09\x0A\x0D\x20-\x7E]/g, "");
}

function wrapPdfLines(text, maxLength = 82) {
  const words = String(text || "").replace(/\s+/g, " ").trim().split(" ").filter(Boolean);
  const lines = [];
  let current = "";

  words.forEach((word) => {
    if (`${current} ${word}`.trim().length > maxLength) {
      if (current) {
        lines.push(current);
      }
      current = word;
      return;
    }

    current = `${current} ${word}`.trim();
  });

  if (current) {
    lines.push(current);
  }

  return lines;
}

function createStructuredCvPdfFile(data) {
  const pageWidth = 595.276;
  const pageHeight = 841.89;
  const marginX = 48;
  const rightX = pageWidth - marginX;
  const bottomY = 58;
  const pages = [];
  let content = [];
  let y = 786;

  const add = (command) => {
    content.push(command);
  };
  const newPage = () => {
    pages.push(content.join("\n"));
    content = [];
    y = 786;
  };
  const ensureSpace = (height) => {
    if (y - height < bottomY) {
      newPage();
    }
  };
  const text = (value, x, currentY, options = {}) => {
    const font = options.font || "F1";
    const size = options.size || 9.2;
    const color = options.color || "0 0 0";
    add("BT");
    add(`${color} rg`);
    add(`/${font} ${size} Tf`);
    add(`1 0 0 1 ${x} ${currentY} Tm`);
    add(`(${escapePdfText(value)}) Tj`);
    add("ET");
  };
  const rightText = (value, currentY, options = {}) => {
    const size = options.size || 9;
    const approximateWidth = escapePdfText(value).length * size * 0.45;
    text(value, Math.max(marginX, rightX - approximateWidth), currentY, options);
  };
  const line = (x1, y1, x2, y2, width = 0.45, color = "0.35 0.35 0.35") => {
    add(`${color} RG`);
    add(`${width} w`);
    add(`${x1} ${y1} m ${x2} ${y2} l S`);
  };
  const wrappedText = (value, x = marginX, options = {}) => {
    const size = options.size || 9.2;
    const maxLength = options.maxLength || 98;
    const leading = options.leading || size + 3;
    const firstPrefix = options.prefix || "";
    wrapPdfLines(value, maxLength).forEach((item, index) => {
      ensureSpace(leading + 2);
      text(`${index === 0 ? firstPrefix : "  "}${item}`, x, y, {
        font: options.font || "F1",
        size,
        color: options.color
      });
      y -= leading;
    });
  };
  const section = (title) => {
    ensureSpace(34);
    y -= 8;
    text(title, marginX, y, { font: "F2", size: 12 });
    line(marginX, y - 6, rightX, y - 6);
    y -= 20;
  };
  const bulletLines = (value, x = marginX + 8) => {
    normalizeCvBuilderBullets(value).forEach((item) => {
      wrappedText(item, x, { size: 9, maxLength: 106, leading: 12, prefix: "- " });
    });
  };
  const addSectionIf = (title, values, renderer) => {
    const items = (values || []).filter(hasCvBuilderItemValue);
    if (!items.length) {
      return;
    }
    section(title);
    items.forEach(renderer);
    y -= 4;
  };

  text(data.fullName || "Your Full Name", marginX, y, { font: "F2", size: 18 });
  y -= 18;
  const identity = [data.program, data.studentId].filter(Boolean).join(" - ");
  if (identity) {
    text(identity, marginX, y, { size: 9 });
    y -= 13;
  }
  text([data.phone, data.email].filter(Boolean).join("   "), marginX, y, { size: 8.8, color: "0 0.18 0.45" });
  y -= 12;
  if (data.address || data.location) {
    wrappedText(data.address || data.location, marginX, { size: 8.8, maxLength: 90, leading: 11 });
  }
  const links = [data.linkedin, data.github].filter(Boolean).join("   ");
  if (links) {
    wrappedText(links, marginX, { size: 8.8, maxLength: 90, leading: 11, color: "0 0.18 0.45" });
  }
  if (state.cvBuilderPhotoPdfData) {
    add("q");
    add("70 0 0 88 466 696 cm");
    add("/Im1 Do");
    add("Q");
    add("0.72 0.72 0.72 RG");
    add("0.6 w");
    add("466 696 70 88 re S");
  } else if (state.cvBuilderPhotoDataUrl) {
    add("0.86 0.86 0.86 rg");
    add("466 696 70 88 re f");
    add("0.72 0.72 0.72 RG");
    add("0.6 w");
    add("466 696 70 88 re S");
    add("0 0 0 rg");
  }
  y -= 10;

  if (String(data.summary || "").trim()) {
    section("Professional Summary");
    wrappedText(data.summary, marginX, { size: 9.2, maxLength: 104, leading: 12 });
    y -= 4;
  }

  addSectionIf("Education", data.education, (item) => {
    ensureSpace(44);
    text(item.degree || "Education", marginX, y, { font: "F2", size: 9.8 });
    if (item.years) {
      rightText(item.years, y, { font: "F2", size: 9 });
    }
    y -= 12;
    text(item.institution || "", marginX, y, { font: "F3", size: 9, color: "0 0.18 0.45" });
    if (item.location) {
      rightText(item.location, y, { font: "F3", size: 8.6 });
    }
    y -= 12;
    bulletLines([formatEducationResult(item), item.group ? `Focus: ${item.group}` : ""].filter(Boolean));
    y -= 3;
  });

  addSectionIf("Skills", data.skills.filter((item) => String(item.values || "").trim()), (item) => {
    ensureSpace(16);
    text(item.category || "Skills", marginX, y, { font: "F2", size: 9 });
    wrappedText(item.values || "", marginX + 105, { size: 9, maxLength: 72, leading: 11 });
  });

  addSectionIf("Projects / Work Samples", data.projects, (item) => {
    ensureSpace(42);
    text([item.title || "Project", item.source || "", item.technologies || ""].filter(Boolean).join(" | "), marginX, y, { font: "F2", size: 9.4 });
    y -= 12;
    bulletLines(item.bullets);
    y -= 3;
  });

  addSectionIf("Achievements", data.achievements, (item) => {
    ensureSpace(42);
    text([item.title || "Achievement", item.organization || ""].filter(Boolean).join(" | "), marginX, y, { font: "F2", size: 9.4 });
    if (item.dates) {
      rightText(item.dates, y, { font: "F2", size: 8.8 });
    }
    y -= 12;
    if (item.link) {
      wrappedText(item.link, marginX, { size: 8.6, maxLength: 98, leading: 11, color: "0 0.18 0.45" });
    }
    bulletLines(item.bullets);
    y -= 3;
  });

  addSectionIf("Leadership & Activities", data.activities, (item) => {
    ensureSpace(16);
    wrappedText([item.role || "Activity", item.organization || "", item.dates || ""].filter(Boolean).join(" | "), marginX, {
      font: "F2",
      size: 9.2,
      maxLength: 102,
      leading: 12
    });
  });

  const references = (data.references || []).filter(hasCvBuilderItemValue);
  if (references.length) {
    section("References");
    references.forEach((item, index) => {
      const x = references.length > 1 && index % 2 === 1 ? 310 : marginX;
      if (index % 2 === 0) {
        ensureSpace(54);
      }
      const startY = y;
      text(item.name || "Reference", x, startY, { font: "F2", size: 9.2 });
      text(item.position || "", x, startY - 11, { size: 8.8 });
      text(item.department || "", x, startY - 22, { size: 8.8 });
      text(item.institution || "", x, startY - 33, { size: 8.8 });
      text(item.email || "", x, startY - 44, { size: 8.8, color: "0 0.18 0.45" });
      if (references.length === 1 || index % 2 === 1 || index === references.length - 1) {
        y -= 58;
      }
    });
  }

  pages.push(content.join("\n"));

  const imageData = state.cvBuilderPhotoPdfData;
  const imageObjectId = imageData ? 6 : null;
  const imageResource = imageData ? ` /XObject << /Im1 ${imageObjectId} 0 R >>` : "";
  const pageAndContentObjects = [];
  const pageKids = [];
  let nextObjectId = imageData ? 7 : 6;

  if (imageData) {
    pageAndContentObjects.push([
      `${imageObjectId} 0 obj << /Type /XObject /Subtype /Image /Width ${imageData.width} /Height ${imageData.height} /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length ${imageData.bytes.length} >> stream\n`,
      imageData.bytes,
      "\nendstream endobj"
    ]);
  }

  pages.forEach((stream, index) => {
    const pageObjectId = nextObjectId++;
    const contentObjectId = nextObjectId++;
    pageKids.push(`${pageObjectId} 0 R`);
    const footer = [
      stream,
      "BT",
      "0.55 0.55 0.55 rg",
      "/F3 8 Tf",
      `1 0 0 1 222 24 Tm (${escapePdfText(`${data.fullName || "Career Bridge CV"} -- Page ${index + 1} of ${pages.length}`)}) Tj`,
      "ET"
    ].join("\n");
    pageAndContentObjects.push(`${pageObjectId} 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 ${pageWidth} ${pageHeight}] /Resources << /Font << /F1 3 0 R /F2 4 0 R /F3 5 0 R >>${imageResource} >> /Contents ${contentObjectId} 0 R >> endobj`);
    pageAndContentObjects.push(`${contentObjectId} 0 obj << /Length ${new TextEncoder().encode(footer).length} >> stream\n${footer}\nendstream endobj`);
  });

  const objects = [
    "1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj",
    `2 0 obj << /Type /Pages /Kids [${pageKids.join(" ")}] /Count ${pages.length} >> endobj`,
    "3 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Times-Roman >> endobj",
    "4 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Times-Bold >> endobj",
    "5 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Times-Italic >> endobj",
    ...pageAndContentObjects
  ];
  const encoder = new TextEncoder();
  const chunks = [];
  const offsets = [0];
  let byteLength = 0;
  const pushChunk = (chunk) => {
    const bytes = typeof chunk === "string" ? encoder.encode(chunk) : chunk;
    chunks.push(bytes);
    byteLength += bytes.length;
  };

  pushChunk("%PDF-1.4\n");
  objects.forEach((object) => {
    offsets.push(byteLength);
    (Array.isArray(object) ? object : [object]).forEach(pushChunk);
    pushChunk("\n");
  });
  const xrefOffset = byteLength;
  pushChunk(`xref\n0 ${objects.length + 1}\n0000000000 65535 f \n`);
  offsets.slice(1).forEach((offset) => {
    pushChunk(`${String(offset).padStart(10, "0")} 00000 n \n`);
  });
  pushChunk(`trailer << /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n${xrefOffset}\n%%EOF`);

  const blob = new Blob(chunks, { type: "application/pdf" });
  return new File([blob], "career-bridge-cv.pdf", { type: "application/pdf" });
}

function downloadCvBuilderPdf() {
  if (!renderCvBuilderPreview()) {
    return;
  }

  const file = createStructuredCvPdfFile(getCvBuilderData());
  const fileUrl = URL.createObjectURL(file);
  const link = document.createElement("a");
  link.href = fileUrl;
  link.download = file.name;
  document.body.append(link);
  link.click();
  link.remove();
  window.setTimeout(() => URL.revokeObjectURL(fileUrl), 1000);
  setFormStatus(elements.cvBuilderStatus, "CV PDF downloaded.", "success");
}

function setCvMode(mode) {
  state.cvMode = mode === "builder" ? "builder" : "upload";
  state.generatedCvFile = state.cvMode === "upload" ? null : state.generatedCvFile;

  elements.cvUploadModeButton?.classList.toggle("active", state.cvMode === "upload");
  elements.cvBuilderModeButton?.classList.toggle("active", state.cvMode === "builder");

  if (elements.cvUploadPanel) {
    elements.cvUploadPanel.hidden = state.cvMode !== "upload";
  }

  if (elements.cvBuilderPanel) {
    elements.cvBuilderPanel.hidden = state.cvMode !== "builder";
  }

  setFormStatus(elements.cvBuilderStatus, state.cvMode === "builder" ? "Fill the CV Builder fields, preview, then use the generated CV." : "");
}

function openJobModal(job, showApply = false) {
  if (!elements.jobModal || !elements.jobDetailPanel) {
    return;
  }

  state.selectedJob = job;
  const requirements = normalizeList(job.requirements);
  const responsibilities = normalizeList(job.responsibilities);
  const companyName = job.company || job.companyProfile?.name || "Company";
  const requirementsMarkup = requirements.length
    ? requirements.map((item) => `<li>${escapeHtml(item)}</li>`).join("")
    : "<li>No specific requirements listed yet.</li>";
  const responsibilityMarkup = responsibilities.length
    ? `<h3>Responsibilities</h3><ul class="job-detail-list">${responsibilities.map((item) => `<li>${escapeHtml(item)}</li>`).join("")}</ul>`
    : "";

  const jobSummaryMarkup = `
    <h2 id="modalJobTitle">${escapeHtml(job.title)}</h2>
    <div class="job-meta-list">
      <span class="meta-pill"><i class="fa-solid fa-building" aria-hidden="true"></i>${escapeHtml(companyName)}</span>
      <span class="meta-pill"><i class="fa-solid fa-location-dot" aria-hidden="true"></i>${escapeHtml(job.location || "Bangladesh")}</span>
      <span class="meta-pill"><i class="fa-solid fa-briefcase" aria-hidden="true"></i>${escapeHtml(job.type || job.jobType || "Not specified")}</span>
      ${job.status ? `<span class="meta-pill">${escapeHtml(job.status)}</span>` : ""}
    </div>
  `;

  elements.jobDetailPanel.innerHTML = showApply
    ? `<div class="apply-job-summary">${jobSummaryMarkup}</div><p id="modalJobDescription" class="sr-only">Application form for ${escapeHtml(job.title)} at ${escapeHtml(companyName)}.</p>`
    : `
      ${jobSummaryMarkup}
      <p class="job-salary">${escapeHtml(job.salary || "Salary negotiable")}</p>
      <p id="modalJobDescription">${escapeHtml(job.description || "No description provided yet.")}</p>
      <h3>Requirements</h3>
      <ul class="job-detail-list">${requirementsMarkup}</ul>
      ${responsibilityMarkup}
    `;

  if (elements.applyJobId) {
    elements.applyJobId.value = String(job.id);
  }

  if (elements.applyName) {
    elements.applyName.value = state.currentUser?.name || "";
  }

  if (elements.applyEmail) {
    elements.applyEmail.value = state.currentUser?.email || "";
  }

  const alreadyApplied = isAlreadyApplied(job.id);
  const canShowApply = showApply && state.currentRole === "JOB_SEEKER";

  if (elements.applyPanel) {
    elements.applyPanel.hidden = !canShowApply;
  }

  if (elements.alreadyAppliedNotice) {
    elements.alreadyAppliedNotice.hidden = !canShowApply || !alreadyApplied;
  }

  if (elements.applyForm) {
    elements.applyForm.hidden = !canShowApply || alreadyApplied;
  }

  if (canShowApply && !alreadyApplied) {
    loadCvBuilderDraft();
    setCvMode("upload");
  }

  if (!showApply) {
    setFormStatus(elements.applyStatus, "");
  } else if (state.currentRole === "PUBLIC") {
    setFormStatus(elements.applyStatus, "Login or register as a Job Seeker to apply.", "");
  } else if (state.currentRole !== "JOB_SEEKER") {
    setFormStatus(elements.applyStatus, "Only Job Seekers can apply to jobs.", "");
  } else if (alreadyApplied) {
    setFormStatus(elements.applyStatus, "You have already applied for this job.", "success");
  } else {
    setFormStatus(elements.applyStatus, "");
  }

  elements.jobModal.hidden = false;
  syncModalOpenState();

  if (canShowApply && !alreadyApplied) {
    window.requestAnimationFrame(() => elements.applyName?.focus());
  }
}

function closeJobModal() {
  if (elements.jobModal) {
    elements.jobModal.hidden = true;
    state.selectedJob = null;
    syncModalOpenState();
  }
}

async function submitJobReport(jobId) {
  if (!isAuthenticated()) {
    openAuthModal("login", "JOB_SEEKER");
    setFormStatus(elements.jobActionStatus, "Login first to report a suspicious job.", "");
    return;
  }

  const reason = window.prompt("Why are you reporting this job? Please include at least 10 characters.");
  const trimmedReason = String(reason || "").trim();

  if (!trimmedReason) {
    return;
  }

  if (trimmedReason.length < 10) {
    showToast("Please add a little more detail before submitting the report.", "error");
    return;
  }

  try {
    await requestJson("/api/reports", {
      method: "POST",
      body: {
        targetType: "JOB",
        targetId: jobId,
        reason: trimmedReason
      }
    });
    showToast("Report submitted for admin review.", "success");
  } catch (error) {
    if (!handleAuthError(error)) {
      showToast(error.message || "Could not submit report.", "error");
    }
  }
}

function clearCvPreviewState() {
  if (state.cvPreview.objectUrl) {
    URL.revokeObjectURL(state.cvPreview.objectUrl);
  }

  state.cvPreview.objectUrl = "";
  state.cvPreview.fileName = "";

  if (elements.cvPreviewFrame) {
    elements.cvPreviewFrame.removeAttribute("src");
  }

  if (elements.downloadCvButton) {
    elements.downloadCvButton.dataset.fileUrl = "";
    elements.downloadCvButton.dataset.fileName = "";
    elements.downloadCvButton.disabled = true;
  }

  if (elements.cvModalDetails) {
    elements.cvModalDetails.hidden = true;
    elements.cvModalDetails.innerHTML = "";
  }
}

function openCvModal({ fileUrl, fileName, mimeType, revokeOnClose = true, detailsHtml = "" }) {
  if (!elements.cvModal || !elements.downloadCvButton || !elements.cvPreviewFrame) {
    return;
  }

  clearCvPreviewState();
  state.cvPreview.fileName = getSafeFileName(fileName || "cv-file");

  if (revokeOnClose) {
    state.cvPreview.objectUrl = fileUrl;
  }

  if (isPreviewableCvFile(mimeType, state.cvPreview.fileName)) {
    elements.cvPreviewFrame.src = fileUrl;
    setFormStatus(elements.cvModalStatus, "CV preview ready.");
  } else {
    setFormStatus(elements.cvModalStatus, "This CV format is not previewable in-browser. Use Download CV.", "");
  }

  if (elements.cvModalDetails) {
    elements.cvModalDetails.hidden = !detailsHtml;
    elements.cvModalDetails.innerHTML = detailsHtml;
  }

  elements.downloadCvButton.dataset.fileUrl = fileUrl;
  elements.downloadCvButton.dataset.fileName = state.cvPreview.fileName;
  elements.downloadCvButton.disabled = false;
  elements.cvModal.hidden = false;
  syncModalOpenState();
}

function closeCvModal() {
  if (!elements.cvModal) {
    return;
  }

  elements.cvModal.hidden = true;
  clearCvPreviewState();
  setFormStatus(elements.cvModalStatus, "");
  syncModalOpenState();
}

function getProfileFormValues() {
  return {
    headline: state.profile?.headline,
    phone: state.profile?.phone,
    location: state.profile?.location,
    skills: (state.profile?.skills || []).join(", "),
    bio: state.profile?.bio,
    education: state.profile?.education,
    experience: state.profile?.experience,
    portfolioUrl: state.profile?.portfolioUrl,
    linkedinUrl: state.profile?.linkedinUrl,
    githubUrl: state.profile?.githubUrl,
    resumeUrl: state.profile?.resumeUrl
  };
}

function openProfileModal() {
  if (!elements.profileModal) {
    return;
  }

  if (elements.profileForm) {
    fillForm(elements.profileForm, getProfileFormValues());
  }

  setFormStatus(elements.profileStatus, "");
  elements.profileModal.hidden = false;
  syncModalOpenState();
  window.requestAnimationFrame(() => {
    elements.profileForm?.elements.headline?.focus();
  });
}

function closeProfileModal() {
  if (!elements.profileModal) {
    return;
  }

  elements.profileModal.hidden = true;
  setFormStatus(elements.profileStatus, "");
  syncModalOpenState();
}

function openCompanyModal() {
  if (!elements.companyProfileModal) {
    return;
  }

  if (elements.companyForm) {
    fillForm(elements.companyForm, state.employerCompany || {});
  }

  setFormStatus(elements.companyStatus, "");
  elements.companyProfileModal.hidden = false;
  syncModalOpenState();
  window.requestAnimationFrame(() => {
    elements.companyForm?.elements.name?.focus();
  });
}

function closeCompanyModal() {
  if (!elements.companyProfileModal) {
    return;
  }

  elements.companyProfileModal.hidden = true;
  setFormStatus(elements.companyStatus, "");
  syncModalOpenState();
}

function openEmployerPostJobModal() {
  if (!elements.employerPostJobModal) {
    return;
  }

  setFormStatus(elements.postJobStatus, "");
  elements.employerPostJobModal.hidden = false;
  syncModalOpenState();
  window.requestAnimationFrame(() => {
    elements.postJobForm?.elements.title?.focus();
  });
}

function closeEmployerPostJobModal() {
  if (!elements.employerPostJobModal) {
    return;
  }

  elements.employerPostJobModal.hidden = true;
  setFormStatus(elements.postJobStatus, "");
  syncModalOpenState();
}

function openSalaryInsightModal() {
  if (!elements.salaryInsightModal) {
    return;
  }

  setFormStatus(elements.salaryInsightStatus, "");
  elements.salaryInsightModal.hidden = false;
  syncModalOpenState();
  window.requestAnimationFrame(() => {
    elements.salaryInsightForm?.elements.roleTitle?.focus();
  });
}

function closeSalaryInsightModal() {
  if (!elements.salaryInsightModal) {
    return;
  }

  elements.salaryInsightModal.hidden = true;
  setFormStatus(elements.salaryInsightStatus, "");
  syncModalOpenState();
}

async function fetchProtectedCvBlob(applicationId) {
  const response = await fetchWithTimeout(`${API_BASE}/api/applications/${applicationId}/resume`, {
    headers: {
      ...getAuthHeaders()
    }
  });

  if (!response.ok) {
    const errorPayload = await response.json().catch(() => ({}));
    const error = new Error(errorPayload.message || "Could not open CV file.");
    error.status = response.status;
    throw error;
  }

  const fileBlob = await response.blob();
  const fileName = getSafeFileName(
    parseFileNameFromDisposition(response.headers.get("content-disposition")),
    `application-${applicationId}-cv`
  );

  return {
    fileBlob,
    fileName,
    mimeType: fileBlob.type || response.headers.get("content-type") || ""
  };
}

function createMyApplicationDetails(application) {
  const job = application.job || {};
  const rows = [
    ["Job", application.jobTitle || job.title || "Application"],
    ["Company", application.company || job.company || job.companyProfile?.name || "Company"],
    ["Status", String(application.status || "SUBMITTED").replaceAll("_", " ")],
    ["Submitted", formatDate(application.createdAt)],
    ["Name", application.applicantName || state.currentUser?.name || ""],
    ["Email", application.applicantEmail || state.currentUser?.email || ""],
    ["Phone", application.applicantPhone || state.profile?.phone || ""],
    ["CV file", application.resumeOriginalName || application.cvOriginalName || "Submitted CV"]
  ].filter(([, value]) => String(value || "").trim());

  return `
    <article class="application-submission-summary">
      <h4>Application Details</h4>
      <dl>
        ${rows.map(([label, value]) => `
          <div>
            <dt>${escapeHtml(label)}</dt>
            <dd>${escapeHtml(value)}</dd>
          </div>
        `).join("")}
      </dl>
      <div>
        <strong>Cover letter</strong>
        <p>${escapeHtml(application.coverLetter || "No cover letter provided.")}</p>
      </div>
    </article>
  `;
}

async function viewMyApplication(applicationId) {
  const application = state.applications.find((item) => Number(item.id) === Number(applicationId));

  if (!application) {
    showToast("Application details are not available yet.", "error");
    return;
  }

  try {
    const { fileBlob, fileName, mimeType } = await fetchProtectedCvBlob(application.id);
    const fileUrl = URL.createObjectURL(fileBlob);
    openCvModal({
      fileUrl,
      fileName,
      mimeType,
      revokeOnClose: true,
      detailsHtml: createMyApplicationDetails(application)
    });
  } catch (error) {
    if (!handleAuthError(error)) {
      showToast(error.message || "Could not open application details.", "error");
    }
  }
}

function syncModalOpenState() {
  const isOpen = [
    elements.authModal,
    elements.jobModal,
    elements.cvModal,
    elements.profileModal,
    elements.companyProfileModal,
    elements.employerPostJobModal,
    elements.salaryInsightModal
  ].some((modal) => modal && !modal.hidden);
  document.body.classList.toggle("modal-open", isOpen);
}

async function refreshAfterMutation() {
  await loadPublicData();
  await loadRoleData();
  renderAll();
}

function setupMenu() {
  if (!elements.menuButton || !elements.siteNav) {
    return;
  }

  elements.menuButton.addEventListener("click", () => {
    const expanded = elements.menuButton.getAttribute("aria-expanded") === "true";
    elements.menuButton.setAttribute("aria-expanded", String(!expanded));
    elements.siteNav.classList.toggle("open", !expanded);
  });

  elements.siteNav.addEventListener("click", (event) => {
    if (event.target.closest("a")) {
      elements.menuButton.setAttribute("aria-expanded", "false");
      elements.siteNav.classList.remove("open");
    }
  });
}

function setupAuthEvents() {
  elements.loginButton?.addEventListener("click", () => openAuthModal("login", "JOB_SEEKER"));
  elements.registerButton?.addEventListener("click", () => openAuthModal("register", "JOB_SEEKER"));
  elements.closeAuthModalButton?.addEventListener("click", closeAuthModal);
  elements.authModalBackdrop?.addEventListener("click", closeAuthModal);
  elements.authLoginMode?.addEventListener("click", () => {
    state.authMode = "login";
    renderAuthModal();
    setFormStatus(elements.authStatus, "");
    setFormStatus(elements.resetStatus, "");
  });
  elements.authRegisterMode?.addEventListener("click", () => {
    if (state.authRole === "ADMIN") {
      setFormStatus(elements.authStatus, "Admin accounts are created by seed/admin tooling. Use Login.", "error");
      return;
    }

    state.authMode = "register";
    renderAuthModal();
    setFormStatus(elements.authStatus, "");
    setFormStatus(elements.resetStatus, "");
  });

  document.querySelectorAll("[data-auth-role]").forEach((button) => {
    button.addEventListener("click", () => {
      state.authRole = normalizeRole(button.dataset.authRole);
      if (state.authRole === "ADMIN") {
        state.authMode = "login";
      }
      renderAuthModal();
      setFormStatus(elements.authStatus, "");
    });
  });

  elements.togglePasswordButton?.addEventListener("click", () => {
    if (!elements.authPassword) {
      return;
    }

    const shouldShow = elements.authPassword.type === "password";
    elements.authPassword.type = shouldShow ? "text" : "password";
    elements.togglePasswordButton.textContent = shouldShow ? "Hide" : "Show";
    elements.togglePasswordButton.setAttribute("aria-label", shouldShow ? "Hide password" : "Show password");
  });

  elements.forgotPasswordButton?.addEventListener("click", openPasswordRecovery);
  elements.backToLoginButton?.addEventListener("click", () => returnToLoginFromRecovery());

  elements.forgotPasswordForm?.addEventListener("submit", async (event) => {
    event.preventDefault();

    const email = String(elements.recoveryEmailInput?.value || "").trim().toLowerCase();

    if (!email) {
      setFormStatus(elements.resetStatus, "Enter the email address connected to your Career Bridge account.", "error");
      elements.recoveryEmailInput?.focus();
      return;
    }

    try {
      setFormStatus(elements.resetStatus, "Sending verification code...");
      const response = await requestJson("/api/auth/forgot-password", {
        method: "POST",
        auth: false,
        body: { email }
      });

      if (elements.resetPasswordForm) {
        elements.resetPasswordForm.hidden = false;
      }

      if (response.delivery === "email") {
        setFormStatus(elements.resetStatus, "Verification code sent. Check your email, then enter the code below.", "success");
      } else if (response.delivery === "not_configured") {
        setFormStatus(elements.resetStatus, "Email delivery is not configured yet. Add SMTP settings in backend/.env, restart the backend, then request a new code.", "error");
      } else if (response.delivery === "failed") {
        setFormStatus(elements.resetStatus, "The reset email could not be sent. Check the backend SMTP settings and server log, then try again.", "error");
      } else {
        setFormStatus(elements.resetStatus, response.message || "If the account exists and email is configured, a verification code will be sent.", "success");
      }
    } catch (error) {
      setFormStatus(elements.resetStatus, getFriendlyErrorMessage(error, "Could not request password reset."), "error");
    }
  });

  elements.resetPasswordForm?.addEventListener("submit", async (event) => {
    event.preventDefault();

    const token = String(elements.resetTokenInput?.value || "").trim();
    const email = String(elements.recoveryEmailInput?.value || "").trim().toLowerCase();
    const password = String(elements.resetPasswordInput?.value || "");

    if (!email || !token || password.length < 8) {
      setFormStatus(elements.resetStatus, "Email, verification code, and a new password of at least 8 characters are required.", "error");
      return;
    }

    try {
      setFormStatus(elements.resetStatus, "Verifying code and resetting password...");
      const response = await requestJson("/api/auth/reset-password", {
        method: "POST",
        auth: false,
        body: {
          email,
          code: token,
          password
        }
      });
      elements.resetPasswordForm.reset();
      elements.resetPasswordForm.hidden = true;
      returnToLoginFromRecovery(response.message || "Password reset successful. Please login.");
    } catch (error) {
      setFormStatus(elements.resetStatus, getFriendlyErrorMessage(error, "Could not reset password."), "error");
    }
  });

  elements.authForm?.addEventListener("submit", async (event) => {
    event.preventDefault();

    const formData = new FormData(elements.authForm);
    const email = String(formData.get("email") || "").trim().toLowerCase();
    const password = String(formData.get("password") || "");
    const name = String(formData.get("name") || "").trim();
    const companyName = String(formData.get("companyName") || "").trim();

    if (!email || !password) {
      setFormStatus(elements.authStatus, "Email and password are required.", "error");
      return;
    }

    if (state.authMode === "register") {
      if (!name || name.length < 2) {
        setFormStatus(elements.authStatus, "Full name is required for registration.", "error");
        return;
      }

      if (password.length < 8) {
        setFormStatus(elements.authStatus, "Password must be at least 8 characters.", "error");
        return;
      }

      if (state.authRole === "EMPLOYER" && !companyName) {
        setFormStatus(elements.authStatus, "Company name is required for Employer registration.", "error");
        return;
      }
    }

    if (state.authMode === "register" && seededDemoEmails.has(email)) {
      state.authMode = "login";
      renderAuthModal();
      setFormStatus(
        elements.authStatus,
        "That is a seeded demo account. Switch to Login and use the same email/password.",
        "error"
      );
      return;
    }

    try {
      setFormStatus(elements.authStatus, state.authMode === "register" ? "Creating account..." : "Signing in...");
      const response = state.authMode === "register"
        ? await requestJson("/api/auth/register", {
          method: "POST",
          auth: false,
          body: {
            name,
            email,
            password,
            role: state.authRole,
            ...(state.authRole === "EMPLOYER" ? { companyName: companyName || `${name || "Employer"} Company` } : {})
          }
        })
        : await requestJson("/api/auth/login", {
          method: "POST",
          auth: false,
          body: {
            email,
            password,
            role: state.authRole
          }
        });

      applySession(response.data || {});
      elements.authForm.reset();
      closeAuthModal();
      await refreshAfterMutation();
      showToast(`${roleLabel()} ${state.authMode === "register" ? "registered" : "logged in"} successfully.`, "success");
      window.location.hash = state.currentRole === "JOB_SEEKER"
        ? "#jobSeekerDashboard"
        : state.currentRole === "EMPLOYER"
          ? "#employerDashboard"
          : "#adminDashboard";
    } catch (error) {
      setFormStatus(elements.authStatus, getFriendlyErrorMessage(error, "Authentication failed."), "error");
    }
  });

  elements.logoutButton?.addEventListener("click", async () => {
    try {
      if (state.authToken) {
        await requestJson("/api/auth/logout", { method: "POST" });
      }
    } catch (_error) {
      // Local logout still clears the session.
    }

    closeCvModal();
    closeProfileModal();
    closeCompanyModal();
    closeEmployerPostJobModal();
    closeSalaryInsightModal();
    closeJobModal();
    closeAuthModal();
    clearSession();
    await loadPublicData();
    renderAll();
    showToast("Logged out.", "success");
    window.location.hash = "#home";
  });
}

function setupModalEvents() {
  elements.closeModalButton?.addEventListener("click", closeJobModal);
  elements.modalBackdrop?.addEventListener("click", closeJobModal);
  elements.closeCvModalButton?.addEventListener("click", closeCvModal);
  elements.cvModalBackdrop?.addEventListener("click", closeCvModal);
  elements.closeProfileModalButton?.addEventListener("click", closeProfileModal);
  elements.profileModalBackdrop?.addEventListener("click", closeProfileModal);
  elements.closeCompanyModalButton?.addEventListener("click", closeCompanyModal);
  elements.companyModalBackdrop?.addEventListener("click", closeCompanyModal);
  elements.closePostJobModalButton?.addEventListener("click", closeEmployerPostJobModal);
  elements.postJobModalBackdrop?.addEventListener("click", closeEmployerPostJobModal);
  elements.closeSalaryInsightModalButton?.addEventListener("click", closeSalaryInsightModal);
  elements.salaryInsightModalBackdrop?.addEventListener("click", closeSalaryInsightModal);
  elements.downloadCvButton?.addEventListener("click", () => {
    const fileUrl = elements.downloadCvButton.dataset.fileUrl;
    const fileName = elements.downloadCvButton.dataset.fileName || "cv-file";

    if (fileUrl) {
      triggerFileDownload(fileUrl, fileName);
    }
  });

  document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape") {
      return;
    }

    if (elements.profileModal && !elements.profileModal.hidden) {
      closeProfileModal();
    } else if (elements.employerPostJobModal && !elements.employerPostJobModal.hidden) {
      closeEmployerPostJobModal();
    } else if (elements.companyProfileModal && !elements.companyProfileModal.hidden) {
      closeCompanyModal();
    } else if (elements.salaryInsightModal && !elements.salaryInsightModal.hidden) {
      closeSalaryInsightModal();
    } else if (elements.authModal && !elements.authModal.hidden) {
      closeAuthModal();
    } else if (elements.cvModal && !elements.cvModal.hidden) {
      closeCvModal();
    } else if (elements.jobModal && !elements.jobModal.hidden) {
      closeJobModal();
    }
  });
}

function setupJobEvents() {
  elements.jobSearch?.addEventListener("input", (event) => {
    state.currentKeyword = event.target.value;
    state.paginationPages.publicJobs = 1;
    renderJobCards();
  });

  elements.filterChips?.addEventListener("click", (event) => {
    const chip = event.target.closest(".filter-chip");
    if (!chip) {
      return;
    }

    const value = chip.dataset.filter || "";
    state.currentKeyword = value;
    state.paginationPages.publicJobs = 1;

    if (elements.jobSearch) {
      elements.jobSearch.value = value;
    }

    elements.filterChips.querySelectorAll(".filter-chip").forEach((item) => {
      item.classList.toggle("active", item === chip);
    });

    renderJobCards();
  });

  elements.jobList?.addEventListener("click", async (event) => {
    const button = event.target.closest("[data-action]");
    if (!button) {
      return;
    }

    const jobId = Number.parseInt(button.dataset.id, 10);
    const job = getJobById(jobId);
    if (!job) {
      return;
    }

    const action = button.dataset.action;

    if (action === "details") {
      openJobModal(job);
      return;
    }

    if (action === "login-to-apply") {
      openAuthModal("login", "JOB_SEEKER");
      setFormStatus(elements.jobActionStatus, "Login or register as a Job Seeker to apply.", "");
      return;
    }

    if (action === "report-job") {
      await submitJobReport(jobId);
      return;
    }

    if (action === "apply") {
      if (state.currentRole !== "JOB_SEEKER") {
        openAuthModal("login", "JOB_SEEKER");
        return;
      }

      if (isAlreadyApplied(jobId)) {
        showToast("You have already applied for this job.", "success");
        renderJobCards();
        return;
      }

      openJobModal(job, true);
      return;
    }

    if (action === "save-job") {
      if (state.currentRole !== "JOB_SEEKER") {
        openAuthModal("login", "JOB_SEEKER");
        return;
      }

      const wasSaved = state.savedJobIds.has(jobId);

      try {
        await requestJson(`/api/saved-jobs/${jobId}`, {
          method: wasSaved ? "DELETE" : "POST"
        });
        await loadJobSeekerData();
        renderAll();
        setFormStatus(elements.jobActionStatus, wasSaved ? "Saved job removed." : "Job saved.", "success");
      } catch (error) {
        if (!handleAuthError(error)) {
          setFormStatus(elements.jobActionStatus, error.message || "Could not update saved job.", "error");
        }
      }
    }
  });
}

function setupApplicationForm() {
  elements.cvUploadModeButton?.addEventListener("click", () => setCvMode("upload"));
  elements.cvBuilderModeButton?.addEventListener("click", () => {
    loadCvBuilderDraft();
    setCvMode("builder");
  });

  elements.cvBuilderPanel?.addEventListener("input", (event) => {
    if (event.target.closest("[data-cv-scalar], [data-cv-field]")) {
      state.generatedCvFile = null;
      saveCvBuilderDraft();
      if (elements.cvBuilderPreview && !elements.cvBuilderPreview.hidden) {
        renderCvBuilderPreview();
      }
    }
  });

  elements.cvBuilderPanel?.addEventListener("click", (event) => {
    const removeButton = event.target.closest("[data-cv-remove]");
    if (removeButton) {
      removeButton.closest("[data-cv-item]")?.remove();
      state.generatedCvFile = null;
      saveCvBuilderDraft();
      if (elements.cvBuilderPreview && !elements.cvBuilderPreview.hidden) {
        renderCvBuilderPreview();
      }
    }
  });

  const addCvBuilderRow = (type) => {
    addCvBuilderItem(type);
    state.generatedCvFile = null;
    saveCvBuilderDraft();
    if (elements.cvBuilderPreview && !elements.cvBuilderPreview.hidden) {
      renderCvBuilderPreview();
    }
  };

  elements.addEducationButton?.addEventListener("click", () => addCvBuilderRow("education"));
  elements.addSkillCategoryButton?.addEventListener("click", () => addCvBuilderRow("skills"));
  elements.addProjectButton?.addEventListener("click", () => addCvBuilderRow("projects"));
  elements.addAchievementButton?.addEventListener("click", () => addCvBuilderRow("achievements"));
  elements.addActivityButton?.addEventListener("click", () => addCvBuilderRow("activities"));
  elements.addReferenceButton?.addEventListener("click", () => addCvBuilderRow("references"));
  elements.cvBuilderPhoto?.addEventListener("change", () => {
    const file = elements.cvBuilderPhoto.files?.[0];
    state.generatedCvFile = null;

    if (!file) {
      state.cvBuilderPhotoDataUrl = "";
      state.cvBuilderPhotoPdfData = null;
      return;
    }

    const reader = new FileReader();
    reader.addEventListener("load", async () => {
      state.cvBuilderPhotoDataUrl = String(reader.result || "");
      try {
        state.cvBuilderPhotoPdfData = await prepareCvBuilderPhotoForPdf(state.cvBuilderPhotoDataUrl);
        renderCvBuilderPreview();
      } catch (error) {
        state.cvBuilderPhotoPdfData = null;
        setFormStatus(elements.cvBuilderStatus, error.message || "Could not add profile picture to the generated PDF.", "error");
      }
    });
    reader.readAsDataURL(file);
  });
  elements.previewCvBuilderButton?.addEventListener("click", renderCvBuilderPreview);
  elements.downloadCvBuilderButton?.addEventListener("click", downloadCvBuilderPdf);
  elements.resetCvBuilderButton?.addEventListener("click", resetCvBuilderForm);
  elements.useGeneratedCvButton?.addEventListener("click", () => {
    if (!renderCvBuilderPreview()) {
      return;
    }

    const data = getCvBuilderData();
    state.generatedCvFile = createStructuredCvPdfFile(data);
    setFormStatus(elements.cvBuilderStatus, "Generated CV is attached to this application.", "success");
  });

  elements.applyForm?.addEventListener("submit", async (event) => {
    event.preventDefault();

    if (state.currentRole !== "JOB_SEEKER") {
      setFormStatus(elements.applyStatus, "Only Job Seekers can apply.", "error");
      return;
    }

    const formData = new FormData(elements.applyForm);
    const jobId = Number.parseInt(String(formData.get("jobId") || ""), 10);

    if (isAlreadyApplied(jobId)) {
      setFormStatus(elements.applyStatus, "You have already applied for this job.", "success");
      renderJobCards();
      return;
    }

    if (state.cvMode === "builder") {
      if (!state.generatedCvFile) {
        if (!renderCvBuilderPreview()) {
          return;
        }
        state.generatedCvFile = createStructuredCvPdfFile(getCvBuilderData());
      }

      formData.delete("cvPhoto");
      formData.set("cvFile", state.generatedCvFile, state.generatedCvFile.name);
    }

    const cvFile = formData.get("cvFile");

    if (!(cvFile instanceof File) || !cvFile.name) {
      setFormStatus(elements.applyStatus, state.cvMode === "builder"
        ? "Generate the CV first, then submit your application."
        : "A CV file is required.",
      "error");
      return;
    }

    try {
      setFormStatus(elements.applyStatus, "Submitting application...");
      const response = await requestJson("/api/applications", {
        method: "POST",
        body: formData
      });
      const appliedJobId = getApplicationJobId(response.data) || jobId;
      if (appliedJobId) {
        state.appliedJobIds.add(appliedJobId);
      }
      elements.applyForm.reset();
      state.generatedCvFile = null;
      closeJobModal();
      await refreshAfterMutation();
      showToast("Application submitted successfully.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        if (error.status === 409 || /already applied/i.test(error.message || "")) {
          state.appliedJobIds.add(jobId);
          renderAll();
          setFormStatus(elements.applyStatus, "You have already applied for this job.", "success");
          showToast("You have already applied for this job.", "success");
          return;
        }

        setFormStatus(elements.applyStatus, error.message || "Could not submit application.", "error");
      }
    }
  });
}

function setupJobSeekerEvents() {
  elements.openProfileModalButton?.addEventListener("click", openProfileModal);

  elements.jobSeekerApplicationFilterTabs?.addEventListener("click", (event) => {
    const button = event.target.closest("[data-job-seeker-application-filter]");

    if (!button) {
      return;
    }

    state.jobSeekerApplicationFilter = button.dataset.jobSeekerApplicationFilter || "ALL";
    state.paginationPages.jobSeekerApplications = 1;
    renderJobSeekerDashboard();
  });

  elements.jobSeekerApplications?.addEventListener("click", async (event) => {
    const button = event.target.closest("[data-action='view-my-application']");

    if (!button) {
      return;
    }

    await viewMyApplication(button.dataset.id);
  });

  elements.profileForm?.addEventListener("submit", async (event) => {
    event.preventDefault();

    if (state.currentRole !== "JOB_SEEKER") {
      return;
    }

    const formData = new FormData(elements.profileForm);
    const payload = {
      headline: String(formData.get("headline") || "").trim(),
      phone: String(formData.get("phone") || "").trim(),
      location: String(formData.get("location") || "").trim(),
      skills: String(formData.get("skills") || "").trim(),
      bio: String(formData.get("bio") || "").trim(),
      education: String(formData.get("education") || "").trim(),
      experience: String(formData.get("experience") || "").trim(),
      portfolioUrl: String(formData.get("portfolioUrl") || "").trim(),
      linkedinUrl: String(formData.get("linkedinUrl") || "").trim(),
      githubUrl: String(formData.get("githubUrl") || "").trim(),
      resumeUrl: String(formData.get("resumeUrl") || "").trim()
    };

    try {
      setFormStatus(elements.profileStatus, "Saving profile...");
      await requestJson("/api/profile/me", {
        method: "PATCH",
        body: payload
      });
      await loadJobSeekerData();
      renderAll();
      closeProfileModal();
      showToast("Profile saved.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        setFormStatus(elements.profileStatus, error.message || "Could not save profile.", "error");
      }
    }
  });

  elements.savedJobsList?.addEventListener("click", async (event) => {
    const button = event.target.closest("[data-action]");
    if (!button) {
      return;
    }

    const jobId = Number.parseInt(button.dataset.id, 10);
    const job = getJobById(jobId) || state.savedJobs.find((item) => (item.jobId || item.job?.id) === jobId)?.job;

    if (button.dataset.action === "details" && job) {
      openJobModal(job);
    } else if (button.dataset.action === "apply" && job) {
      if (isAlreadyApplied(jobId)) {
        showToast("You have already applied for this job.", "success");
        renderAll();
        return;
      }
      openJobModal(job, true);
    } else if (button.dataset.action === "report-job") {
      await submitJobReport(jobId);
    } else if (button.dataset.action === "save-job") {
      try {
        await requestJson(`/api/saved-jobs/${jobId}`, { method: "DELETE" });
        await loadJobSeekerData();
        renderAll();
        showToast("Saved job removed.", "success");
      } catch (error) {
        if (!handleAuthError(error)) {
          showToast(error.message || "Could not remove saved job.", "error");
        }
      }
    }
  });
}

function setupEmployerEvents() {
  elements.openCompanyModalButton?.addEventListener("click", openCompanyModal);
  elements.openPostJobModalButton?.addEventListener("click", openEmployerPostJobModal);

  elements.employerJobFilterTabs?.addEventListener("click", (event) => {
    const button = event.target.closest("[data-employer-job-filter]");

    if (!button) {
      return;
    }

    state.employerJobFilter = button.dataset.employerJobFilter || "ACTIVE";
    state.paginationPages.employerJobs = 1;
    renderEmployerDashboard();
  });

  elements.employerApplicationFilterTabs?.addEventListener("click", (event) => {
    const button = event.target.closest("[data-employer-application-filter]");

    if (!button) {
      return;
    }

    state.employerApplicationFilter = button.dataset.employerApplicationFilter || "ALL";
    state.paginationPages.employerApplications = 1;
    renderEmployerDashboard();
  });

  elements.companyForm?.addEventListener("submit", async (event) => {
    event.preventDefault();

    if (state.currentRole !== "EMPLOYER") {
      return;
    }

    const formData = new FormData(elements.companyForm);
    const payload = Object.fromEntries(formData.entries());

    try {
      setFormStatus(elements.companyStatus, "Saving company...");
      await requestJson("/api/employer/company", {
        method: "PATCH",
        body: payload
      });
      await loadEmployerData();
      renderAll();
      closeCompanyModal();
      showToast("Company profile saved.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        setFormStatus(elements.companyStatus, error.message || "Could not save company.", "error");
      }
    }
  });

  elements.postJobForm?.addEventListener("submit", async (event) => {
    event.preventDefault();

    if (state.currentRole !== "EMPLOYER") {
      setFormStatus(elements.postJobStatus, "Only Employers can post jobs.", "error");
      return;
    }

    const formData = new FormData(elements.postJobForm);
    const payload = {
      title: String(formData.get("title") || "").trim(),
      location: String(formData.get("location") || "").trim(),
      type: String(formData.get("type") || "").trim(),
      salaryMin: formData.get("salaryMin") ? Number(formData.get("salaryMin")) : undefined,
      salaryMax: formData.get("salaryMax") ? Number(formData.get("salaryMax")) : undefined,
      description: String(formData.get("description") || "").trim(),
      requirements: String(formData.get("requirements") || "").trim()
    };

    try {
      setFormStatus(elements.postJobStatus, "Posting job...");
      const response = await requestJson("/api/jobs", {
        method: "POST",
        body: payload
      });
      elements.postJobForm.reset();
      await refreshAfterMutation();
      closeEmployerPostJobModal();
      showToast(response.message || "Job posted successfully.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        setFormStatus(elements.postJobStatus, error.message || "Could not post job.", "error");
      }
    }
  });

  elements.employerJobsList?.addEventListener("click", async (event) => {
    const button = event.target.closest("[data-action='employer-job-status']");
    if (!button) {
      return;
    }

    const jobId = Number.parseInt(button.dataset.id, 10);
    const status = button.dataset.status;

    try {
      await requestJson(`/api/jobs/${jobId}/status`, {
        method: "PATCH",
        body: { status }
      });
      await refreshAfterMutation();
      showToast(`Job ${status.toLowerCase()} successfully.`, "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        showToast(error.message || "Could not update job status.", "error");
      }
    }
  });

  elements.employerApplicationsList?.addEventListener("change", async (event) => {
    const select = event.target.closest("[data-action='application-status']");
    if (!select) {
      return;
    }

    const applicationId = Number.parseInt(select.dataset.id, 10);
    const status = select.value;

    try {
      await requestJson(`/api/applications/${applicationId}/status`, {
        method: "PATCH",
        body: { status }
      });
      await loadEmployerData();
      renderEmployerDashboard();
      showToast("Application status updated.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        showToast(error.message || "Could not update application status.", "error");
      }
    }
  });

  elements.employerApplicationsList?.addEventListener("click", async (event) => {
    const button = event.target.closest("[data-action]");
    if (!button) {
      return;
    }

    const applicationId = Number.parseInt(button.dataset.id, 10);

    if (button.dataset.action === "save-note") {
      const noteField = elements.employerApplicationsList.querySelector(`[data-note-id="${applicationId}"]`);
      const employerNote = noteField ? noteField.value : "";

      try {
        await requestJson(`/api/applications/${applicationId}/note`, {
          method: "PATCH",
          body: { employerNote }
        });
        await loadEmployerData();
        renderEmployerDashboard();
        showToast("Private note saved.", "success");
      } catch (error) {
        if (!handleAuthError(error)) {
          showToast(error.message || "Could not save note.", "error");
        }
      }
      return;
    }

    if (button.dataset.action === "download-cv") {
      try {
        const { fileBlob, fileName, mimeType } = await fetchProtectedCvBlob(applicationId);
        const fileUrl = URL.createObjectURL(fileBlob);
        openCvModal({ fileUrl, fileName, mimeType, revokeOnClose: true });
      } catch (error) {
        if (!handleAuthError(error)) {
          showToast(error.message || "Could not open CV.", "error");
        }
      }
    }
  });
}

function setupAdminEvents() {
  document.addEventListener("click", (event) => {
    const button = event.target.closest("[data-pagination]");

    if (!button) {
      return;
    }

    const pageKey = button.dataset.pagination;

    if (!Object.prototype.hasOwnProperty.call(state.paginationPages, pageKey)) {
      return;
    }

    state.paginationPages[pageKey] = Number(button.dataset.page) || 1;
    renderAll();
  });

  elements.adminUserFilterTabs?.addEventListener("click", (event) => {
    const button = event.target.closest("[data-admin-user-filter]");

    if (!button) {
      return;
    }

    state.adminUserFilter = button.dataset.adminUserFilter || "ALL";
    state.paginationPages.users = 1;
    renderAdminDashboard();
  });

  elements.adminCompanyFilterTabs?.addEventListener("click", (event) => {
    const button = event.target.closest("[data-admin-company-filter]");

    if (!button) {
      return;
    }

    state.adminCompanyFilter = button.dataset.adminCompanyFilter || "ALL";
    state.paginationPages.companies = 1;
    renderAdminDashboard();
  });

  elements.adminJobFilterTabs?.addEventListener("click", (event) => {
    const button = event.target.closest("[data-admin-job-filter]");

    if (!button) {
      return;
    }

    state.adminJobFilter = button.dataset.adminJobFilter || "ALL";
    state.paginationPages.jobs = 1;
    renderAdminDashboard();
  });

  elements.adminApplicationFilterTabs?.addEventListener("click", (event) => {
    const button = event.target.closest("[data-admin-application-filter]");

    if (!button) {
      return;
    }

    const selectedStatus = button.dataset.adminApplicationFilter || "ALL";
    state.adminApplicationFilters.status = selectedStatus === "ALL" ? "" : selectedStatus;
    state.paginationPages.applications = 1;
    renderAdminDashboard();
  });

  const handleAdminUserClick = async (event) => {
    const button = event.target.closest("[data-action='toggle-user']");
    if (!button) {
      return;
    }

    try {
      await requestJson(`/api/admin/users/${button.dataset.id}`, {
        method: "PATCH",
        body: {
          isActive: button.dataset.active === "true"
        }
      });
      await loadAdminData();
      renderAdminDashboard();
      showToast("User updated.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        showToast(error.message || "Could not update user.", "error");
      }
    }
  };

  elements.adminUsersTable?.addEventListener("click", handleAdminUserClick);

  const handleAdminCompanyClick = async (event) => {
    const button = event.target.closest("[data-action='verify-company']");
    if (!button) {
      return;
    }

    try {
      await requestJson(`/api/admin/companies/${button.dataset.id}/verify`, {
        method: "PATCH",
        body: {
          verified: button.dataset.verified === "true"
        }
      });
      await loadAdminData();
      renderAdminDashboard();
      showToast("Company verification updated.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        showToast(error.message || "Could not update company.", "error");
      }
    }
  };

  elements.adminCompaniesTable?.addEventListener("click", handleAdminCompanyClick);

  const handleAdminJobChange = async (event) => {
    const select = event.target.closest("[data-action='admin-job-status']");
    if (!select) {
      return;
    }

    try {
      await requestJson(`/api/admin/jobs/${select.dataset.id}/status`, {
        method: "PATCH",
        body: {
          status: select.value
        }
      });
      await loadAdminData();
      renderAdminDashboard();
      showToast("Job status updated.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        showToast(error.message || "Could not update job.", "error");
      }
    }
  };

  elements.adminJobsTable?.addEventListener("change", handleAdminJobChange);

  elements.adminApplicationFilters?.addEventListener("input", (event) => {
    const formData = new FormData(elements.adminApplicationFilters);
    state.adminApplicationFilters = {
      search: String(formData.get("search") || ""),
      status: state.adminApplicationFilters.status
    };
    state.paginationPages.applications = 1;
    renderAdminDashboard();
  });

  elements.adminApplicationFilters?.addEventListener("submit", (event) => {
    event.preventDefault();
  });

  const handleAdminApplicationClick = async (event) => {
    const button = event.target.closest("[data-action]");

    if (!button) {
      return;
    }

    const applicationId = Number.parseInt(button.dataset.id, 10);

    if (button.dataset.action === "admin-download-cv") {
      try {
        const { fileBlob, fileName, mimeType } = await fetchProtectedCvBlob(applicationId);
        const fileUrl = URL.createObjectURL(fileBlob);
        openCvModal({ fileUrl, fileName, mimeType, revokeOnClose: true });
      } catch (error) {
        if (!handleAuthError(error)) {
          showToast(error.message || "Could not open CV.", "error");
        }
      }
      return;
    }

    if (button.dataset.action === "admin-application-status") {
      try {
        await requestJson(`/api/applications/${applicationId}/status`, {
          method: "PATCH",
          body: {
            status: button.dataset.status
          }
        });
        await loadAdminData();
        renderAdminDashboard();
        showToast("Application status updated.", "success");
      } catch (error) {
        if (!handleAuthError(error)) {
          showToast(error.message || "Could not update application.", "error");
        }
      }
    }
  };

  elements.adminApplicationsTable?.addEventListener("click", handleAdminApplicationClick);

  elements.adminReportsList?.addEventListener("change", async (event) => {
    const select = event.target.closest("[data-action='report-status']");
    if (!select) {
      return;
    }

    try {
      await requestJson(`/api/admin/reports/${select.dataset.id}/status`, {
        method: "PATCH",
        body: {
          status: select.value
        }
      });
      await loadAdminData();
      renderAdminDashboard();
      showToast("Report status updated.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        showToast(error.message || "Could not update report.", "error");
      }
    }
  });

  elements.openSalaryInsightModalButton?.addEventListener("click", openSalaryInsightModal);

  elements.salaryInsightForm?.addEventListener("submit", async (event) => {
    event.preventDefault();

    const formData = new FormData(elements.salaryInsightForm);
    const payload = {
      roleTitle: String(formData.get("roleTitle") || "").trim(),
      location: String(formData.get("location") || "").trim(),
      experienceLevel: String(formData.get("experienceLevel") || "").trim(),
      salaryMin: Number(formData.get("salaryMin")),
      salaryMax: Number(formData.get("salaryMax")),
      source: String(formData.get("source") || "").trim()
    };

    try {
      setFormStatus(elements.salaryInsightStatus, "Adding salary insight...");
      await requestJson("/api/admin/salary-insights", {
        method: "POST",
        body: payload
      });
      elements.salaryInsightForm.reset();
      state.paginationPages.salaryInsights = 1;
      await loadAdminData();
      renderAdminDashboard();
      setFormStatus(elements.salaryInsightStatus, "Salary insight added.", "success");
      closeSalaryInsightModal();
      showToast("Salary insight added.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        setFormStatus(elements.salaryInsightStatus, error.message || "Could not add salary insight.", "error");
      }
    }
  });

  elements.adminSalaryInsights?.addEventListener("click", async (event) => {
    const button = event.target.closest("[data-action='delete-salary']");
    if (!button) {
      return;
    }

    try {
      await requestJson(`/api/admin/salary-insights/${button.dataset.id}`, {
        method: "DELETE"
      });
      await loadAdminData();
      renderAdminDashboard();
      showToast("Salary insight deleted.", "success");
    } catch (error) {
      if (!handleAuthError(error)) {
        showToast(error.message || "Could not delete salary insight.", "error");
      }
    }
  });
}

function setupEvents() {
  setupMenu();
  setupAuthEvents();
  setupModalEvents();
  setupJobEvents();
  setupApplicationForm();
  setupJobSeekerEvents();
  setupEmployerEvents();
  setupAdminEvents();
}

async function init() {
  document.querySelectorAll(".reveal").forEach((section) => section.classList.add("in-view"));
  setupEvents();
  await loadStoredSession();
  await loadPublicData();
  await loadRoleData();
  renderAll();
}

init().catch((error) => {
  console.error(error);
  setApiStatus(false, "Frontend could not initialize. Check the browser console.");
});
