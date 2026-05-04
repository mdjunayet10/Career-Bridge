function formatMoney(value) {
  if (value === null || value === undefined) {
    return "";
  }

  return Number(value).toLocaleString("en-BD");
}

function formatSalaryRange(item) {
  const currency = item.currency || "BDT";

  if (item.salaryMin && item.salaryMax) {
    return `${currency} ${formatMoney(item.salaryMin)} - ${formatMoney(item.salaryMax)}`;
  }

  if (item.salaryMin) {
    return `${currency} ${formatMoney(item.salaryMin)}+`;
  }

  if (item.salaryMax) {
    return `Up to ${currency} ${formatMoney(item.salaryMax)}`;
  }

  return "Salary negotiable";
}

function parseList(value) {
  if (Array.isArray(value)) {
    return value.map((item) => String(item).trim()).filter(Boolean);
  }

  if (typeof value !== "string") {
    return [];
  }

  return value
    .split(/\n|,/)
    .map((item) => item.trim())
    .filter(Boolean);
}

function parseSalaryRange(value) {
  const text = String(value || "");
  const numbers = text
    .match(/\d[\d,]*/g)
    ?.map((item) => Number.parseInt(item.replace(/,/g, ""), 10))
    .filter((item) => Number.isFinite(item)) || [];

  return {
    salaryMin: numbers[0] || undefined,
    salaryMax: numbers[1] || numbers[0] || undefined
  };
}

function normalizeWorkplaceType(value, fallback = "ONSITE") {
  const normalized = String(value || fallback).trim().toUpperCase();

  if (["ONSITE", "REMOTE", "HYBRID"].includes(normalized)) {
    return normalized;
  }

  if (normalized.includes("REMOTE")) {
    return "REMOTE";
  }

  if (normalized.includes("HYBRID")) {
    return "HYBRID";
  }

  return fallback;
}

function serializeUser(user) {
  if (!user) {
    return null;
  }

  return {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    avatarUrl: user.avatarUrl,
    isActive: user.isActive,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt
  };
}

function serializeCompany(company) {
  if (!company) {
    return null;
  }

  return {
    id: company.id,
    ownerUserId: company.ownerUserId,
    name: company.name,
    logoUrl: company.logoUrl,
    industry: company.industry,
    size: company.size,
    location: company.location,
    website: company.website,
    description: company.description,
    verified: company.verified,
    jobCount: company._count?.jobs,
    createdAt: company.createdAt,
    updatedAt: company.updatedAt
  };
}

function serializeJob(job) {
  if (!job) {
    return null;
  }

  const companyName = job.company?.name || "";
  const salary = formatSalaryRange(job);

  return {
    id: job.id,
    companyId: job.companyId,
    company: companyName,
    companyProfile: serializeCompany(job.company),
    title: job.title,
    description: job.description,
    requirements: job.requirements || [],
    responsibilities: job.responsibilities || [],
    location: job.location,
    jobType: job.jobType,
    type: job.jobType,
    workplaceType: job.workplaceType,
    experienceLevel: job.experienceLevel,
    salaryMin: job.salaryMin,
    salaryMax: job.salaryMax,
    salary,
    currency: job.currency,
    deadline: job.deadline,
    status: job.status,
    postedAt: job.createdAt,
    createdAt: job.createdAt,
    updatedAt: job.updatedAt,
    applicationCount: job._count?.applications,
    savedCount: job._count?.savedBy
  };
}

function serializeSalaryInsight(item) {
  if (!item) {
    return null;
  }

  const salaryRange = formatSalaryRange(item);

  return {
    id: item.id,
    roleTitle: item.roleTitle,
    role: item.roleTitle,
    location: item.location,
    salaryMin: item.salaryMin,
    salaryMax: item.salaryMax,
    salaryRange,
    currency: item.currency,
    experienceLevel: item.experienceLevel,
    level: item.experienceLevel,
    source: item.source,
    trend: item.source || "Market benchmark",
    createdAt: item.createdAt,
    updatedAt: item.updatedAt
  };
}

function getProfileCompletion(profile) {
  if (!profile) {
    return 0;
  }

  const fields = [
    profile.headline,
    profile.phone,
    profile.location,
    profile.bio,
    profile.skills?.length,
    profile.education,
    profile.experience,
    profile.portfolioUrl,
    profile.linkedinUrl,
    profile.githubUrl,
    profile.resumeUrl
  ];

  const completed = fields.filter(Boolean).length;
  return Math.round((completed / fields.length) * 100);
}

function serializeProfile(profile) {
  if (!profile) {
    return null;
  }

  return {
    id: profile.id,
    userId: profile.userId,
    headline: profile.headline,
    phone: profile.phone,
    location: profile.location,
    bio: profile.bio,
    skills: profile.skills || [],
    education: profile.education,
    experience: profile.experience,
    portfolioUrl: profile.portfolioUrl,
    linkedinUrl: profile.linkedinUrl,
    githubUrl: profile.githubUrl,
    resumeUrl: profile.resumeUrl,
    completion: getProfileCompletion(profile),
    createdAt: profile.createdAt,
    updatedAt: profile.updatedAt
  };
}

function serializeApplication(application, options = {}) {
  if (!application) {
    return null;
  }

  const { canViewResume = false, includeEmployerNote = false } = options;
  const applicantProfile = application.applicant?.jobSeekerProfile;

  return {
    id: application.id,
    jobId: application.jobId,
    applicantUserId: application.applicantUserId,
    applicantName: application.applicant?.name || "",
    applicantEmail: application.applicant?.email || "",
    applicantPhone: applicantProfile?.phone || "",
    resumeUrl: canViewResume && application.resumeStorageName
      ? `/api/applications/${application.id}/resume`
      : null,
    resumeOriginalName: canViewResume ? application.resumeOriginalName : "",
    cvOriginalName: canViewResume ? application.resumeOriginalName : "",
    canViewResume: canViewResume && Boolean(application.resumeStorageName),
    canViewCv: canViewResume && Boolean(application.resumeStorageName),
    coverLetter: application.coverLetter,
    status: application.status,
    employerNote: includeEmployerNote ? application.employerNote : undefined,
    createdAt: application.createdAt,
    updatedAt: application.updatedAt,
    jobTitle: application.job?.title,
    company: application.job?.company?.name,
    job: application.job ? serializeJob(application.job) : undefined
  };
}

module.exports = {
  formatSalaryRange,
  getProfileCompletion,
  normalizeWorkplaceType,
  parseList,
  parseSalaryRange,
  serializeApplication,
  serializeCompany,
  serializeJob,
  serializeProfile,
  serializeSalaryInsight,
  serializeUser
};
