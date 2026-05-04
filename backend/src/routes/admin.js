const express = require("express");
const { z } = require("zod");
const prisma = require("../db/prisma");
const asyncHandler = require("../middleware/asyncHandler");
const { normalizeRole, requireAuth, requireRole } = require("../middleware/auth");
const { validateBody } = require("../middleware/validate");
const { createError } = require("../utils/apiError");
const { writeAuditLog } = require("../utils/audit");
const {
  serializeApplication,
  serializeCompany,
  serializeJob,
  serializeSalaryInsight,
  serializeUser
} = require("../utils/serializers");

const router = express.Router();

router.use(requireAuth, requireRole("ADMIN"));

const patchUserSchema = z.object({
  name: z.string().trim().min(2).max(120).optional(),
  role: z.string().trim().optional(),
  isActive: z.boolean().optional(),
  avatarUrl: z.string().trim().url().optional().or(z.literal(""))
});

const verifyCompanySchema = z.object({
  verified: z.boolean().optional().default(true)
});

const statusSchema = z.object({
  status: z.enum(["DRAFT", "OPEN", "CLOSED", "ARCHIVED"])
});

const reportStatusSchema = z.object({
  status: z.enum(["OPEN", "REVIEWING", "RESOLVED", "DISMISSED"])
});

const salaryInsightSchema = z.object({
  roleTitle: z.string().trim().min(2).max(160),
  location: z.string().trim().max(140).optional(),
  salaryMin: z.number().int().nonnegative(),
  salaryMax: z.number().int().nonnegative(),
  currency: z.string().trim().min(3).max(8).optional().default("BDT"),
  experienceLevel: z.string().trim().max(120).optional(),
  source: z.string().trim().max(200).optional()
});

const patchSalaryInsightSchema = salaryInsightSchema.partial();

function parseId(value, label = "ID") {
  const id = Number.parseInt(value, 10);

  if (!Number.isInteger(id) || id <= 0) {
    throw createError(400, `Invalid ${label}`);
  }

  return id;
}

function getPagination(query) {
  const page = Math.max(Number.parseInt(query.page || "1", 10) || 1, 1);
  const limit = Math.min(Math.max(Number.parseInt(query.limit || "50", 10) || 50, 1), 100);

  return {
    page,
    limit,
    skip: (page - 1) * limit
  };
}

function withPagination(data, total, page, limit) {
  const totalPages = Math.max(Math.ceil(total / limit), 1);

  return {
    data,
    count: data.length,
    total,
    page,
    limit,
    totalPages,
    pagination: {
      page,
      limit,
      total,
      totalPages
    }
  };
}

async function assertJobCanBeOpened(jobId) {
  const job = await prisma.job.findUnique({
    where: {
      id: jobId
    },
    include: {
      company: true
    }
  });

  if (!job) {
    throw createError(404, "Job not found");
  }

  if (!job.company?.verified) {
    throw createError(403, "Verify the company before publishing this job as OPEN.");
  }
}

router.get("/stats", asyncHandler(async (_req, res) => {
  const [
    totalUsers,
    usersByRole,
    totalCompanies,
    verifiedCompanies,
    totalJobs,
    openJobs,
    totalApplications,
    applicationStatuses
  ] = await Promise.all([
    prisma.user.count(),
    prisma.user.groupBy({
      by: ["role"],
      _count: {
        role: true
      }
    }),
    prisma.company.count(),
    prisma.company.count({
      where: {
        verified: true
      }
    }),
    prisma.job.count(),
    prisma.job.count({
      where: {
        status: "OPEN"
      }
    }),
    prisma.application.count(),
    prisma.application.groupBy({
      by: ["status"],
      _count: {
        status: true
      }
    })
  ]);

  const roleCounts = usersByRole.reduce((acc, item) => {
    acc[item.role] = item._count.role;
    return acc;
  }, {});
  const statusCounts = applicationStatuses.reduce((acc, item) => {
    acc[item.status] = item._count.status;
    return acc;
  }, {});

  res.json({
    data: {
      totalUsers,
      totalJobSeekers: roleCounts.JOB_SEEKER || 0,
      totalEmployers: roleCounts.EMPLOYER || 0,
      totalAdmins: roleCounts.ADMIN || 0,
      totalCompanies,
      verifiedCompanies,
      totalJobs,
      openJobs,
      totalApplications,
      applicationStatusCounts: statusCounts
    }
  });
}));

router.get("/users", asyncHandler(async (req, res) => {
  const { page, limit, skip } = getPagination(req.query);
  const q = String(req.query.q || "").trim();
  const role = req.query.role ? normalizeRole(req.query.role) : "";
  const where = {
    ...(q ? {
      OR: [
        {
          name: {
            contains: q,
            mode: "insensitive"
          }
        },
        {
          email: {
            contains: q,
            mode: "insensitive"
          }
        }
      ]
    } : {}),
    ...(role ? { role } : {})
  };

  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      orderBy: {
        createdAt: "desc"
      },
      skip,
      take: limit
    }),
    prisma.user.count({
      where
    })
  ]);

  res.json(withPagination(users.map(serializeUser), total, page, limit));
}));

router.patch("/users/:id", validateBody(patchUserSchema), asyncHandler(async (req, res) => {
  const id = parseId(req.params.id, "user ID");
  const data = {};

  if (req.body.name !== undefined) {
    data.name = req.body.name;
  }

  if (req.body.isActive !== undefined) {
    data.isActive = req.body.isActive;
  }

  if (req.body.avatarUrl !== undefined) {
    data.avatarUrl = req.body.avatarUrl || null;
  }

  if (req.body.role !== undefined) {
    const role = normalizeRole(req.body.role);
    if (!role) {
      throw createError(400, "Invalid role");
    }
    data.role = role;
  }

  const user = await prisma.user.update({
    where: {
      id
    },
    data
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "ADMIN_UPDATE_USER",
    targetType: "USER",
    targetId: id,
    metadata: data
  });

  res.json({
    message: "User updated",
    data: serializeUser(user)
  });
}));

router.get("/companies", asyncHandler(async (_req, res) => {
  const companies = await prisma.company.findMany({
    include: {
      owner: true,
      _count: {
        select: {
          jobs: true
        }
      }
    },
    orderBy: {
      createdAt: "desc"
    }
  });

  res.json({
    data: companies.map((company) => ({
      ...serializeCompany(company),
      owner: serializeUser(company.owner)
    })),
    count: companies.length
  });
}));

router.patch("/companies/:id/verify", validateBody(verifyCompanySchema), asyncHandler(async (req, res) => {
  const id = parseId(req.params.id, "company ID");
  const company = await prisma.company.update({
    where: {
      id
    },
    data: {
      verified: req.body.verified
    },
    include: {
      _count: {
        select: {
          jobs: true
        }
      }
    }
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "ADMIN_VERIFY_COMPANY",
    targetType: "COMPANY",
    targetId: id,
    metadata: {
      verified: req.body.verified
    }
  });

  res.json({
    message: "Company verification updated",
    data: serializeCompany(company)
  });
}));

router.get("/jobs", asyncHandler(async (req, res) => {
  const { page, limit, skip } = getPagination(req.query);
  const status = String(req.query.status || "").trim().toUpperCase();
  const q = String(req.query.q || "").trim();
  const where = {
    ...(status && status !== "ALL" ? { status } : {}),
    ...(q ? {
      OR: [
        {
          title: {
            contains: q,
            mode: "insensitive"
          }
        },
        {
          company: {
            name: {
              contains: q,
              mode: "insensitive"
            }
          }
        }
      ]
    } : {})
  };

  const [jobs, total] = await Promise.all([
    prisma.job.findMany({
      where,
      include: {
        company: true,
        _count: {
          select: {
            applications: true,
            savedBy: true
          }
        }
      },
      orderBy: {
        createdAt: "desc"
      },
      skip,
      take: limit
    }),
    prisma.job.count({
      where
    })
  ]);

  res.json(withPagination(jobs.map(serializeJob), total, page, limit));
}));

router.patch("/jobs/:id/status", validateBody(statusSchema), asyncHandler(async (req, res) => {
  const id = parseId(req.params.id, "job ID");

  if (req.body.status === "OPEN") {
    await assertJobCanBeOpened(id);
  }

  const job = await prisma.job.update({
    where: {
      id
    },
    data: {
      status: req.body.status
    },
    include: {
      company: true,
      _count: {
        select: {
          applications: true,
          savedBy: true
        }
      }
    }
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "ADMIN_UPDATE_JOB_STATUS",
    targetType: "JOB",
    targetId: id,
    metadata: {
      status: req.body.status
    }
  });

  res.json({
    message: "Job status updated",
    data: serializeJob(job)
  });
}));

router.get("/applications", asyncHandler(async (_req, res) => {
  const applications = await prisma.application.findMany({
    include: {
      applicant: {
        include: {
          jobSeekerProfile: true
        }
      },
      job: {
        include: {
          company: true
        }
      }
    },
    orderBy: {
      createdAt: "desc"
    }
  });

  res.json({
    data: applications.map((application) => serializeApplication(application, {
      canViewResume: true,
      includeEmployerNote: true
    })),
    count: applications.length
  });
}));

router.get("/reports", asyncHandler(async (_req, res) => {
  const reports = await prisma.report.findMany({
    include: {
      reporter: true
    },
    orderBy: {
      createdAt: "desc"
    }
  });

  res.json({
    data: reports.map((report) => ({
      id: report.id,
      reporterUserId: report.reporterUserId,
      reporter: serializeUser(report.reporter),
      targetType: report.targetType,
      targetId: report.targetId,
      reason: report.reason,
      status: report.status,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt
    })),
    count: reports.length
  });
}));

router.patch("/reports/:id/status", validateBody(reportStatusSchema), asyncHandler(async (req, res) => {
  const id = parseId(req.params.id, "report ID");
  const report = await prisma.report.update({
    where: {
      id
    },
    data: {
      status: req.body.status
    },
    include: {
      reporter: true
    }
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "ADMIN_UPDATE_REPORT_STATUS",
    targetType: "REPORT",
    targetId: id,
    metadata: {
      status: req.body.status
    }
  });

  res.json({
    message: "Report status updated",
    data: {
      id: report.id,
      reporterUserId: report.reporterUserId,
      reporter: serializeUser(report.reporter),
      targetType: report.targetType,
      targetId: report.targetId,
      reason: report.reason,
      status: report.status,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt
    }
  });
}));

router.post("/salary-insights", validateBody(salaryInsightSchema), asyncHandler(async (req, res) => {
  if (req.body.salaryMin > req.body.salaryMax) {
    throw createError(400, "salaryMin cannot be greater than salaryMax");
  }

  const salaryInsight = await prisma.salaryInsight.create({
    data: req.body
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "ADMIN_CREATE_SALARY_INSIGHT",
    targetType: "SALARY_INSIGHT",
    targetId: salaryInsight.id
  });

  res.status(201).json({
    message: "Salary insight created",
    data: serializeSalaryInsight(salaryInsight)
  });
}));

router.patch("/salary-insights/:id", validateBody(patchSalaryInsightSchema), asyncHandler(async (req, res) => {
  const id = parseId(req.params.id, "salary insight ID");
  const existing = await prisma.salaryInsight.findUnique({
    where: {
      id
    }
  });

  if (!existing) {
    throw createError(404, "Salary insight not found");
  }

  const nextMin = req.body.salaryMin ?? existing.salaryMin;
  const nextMax = req.body.salaryMax ?? existing.salaryMax;

  if (nextMin > nextMax) {
    throw createError(400, "salaryMin cannot be greater than salaryMax");
  }

  const salaryInsight = await prisma.salaryInsight.update({
    where: {
      id
    },
    data: req.body
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "ADMIN_UPDATE_SALARY_INSIGHT",
    targetType: "SALARY_INSIGHT",
    targetId: id
  });

  res.json({
    message: "Salary insight updated",
    data: serializeSalaryInsight(salaryInsight)
  });
}));

router.delete("/salary-insights/:id", asyncHandler(async (req, res) => {
  const id = parseId(req.params.id, "salary insight ID");

  await prisma.salaryInsight.delete({
    where: {
      id
    }
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "ADMIN_DELETE_SALARY_INSIGHT",
    targetType: "SALARY_INSIGHT",
    targetId: id
  });

  res.json({
    message: "Salary insight deleted"
  });
}));

module.exports = router;
