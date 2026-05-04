const express = require("express");
const { z } = require("zod");
const prisma = require("../db/prisma");
const asyncHandler = require("../middleware/asyncHandler");
const { optionalAuth, requireAuth, requireRole } = require("../middleware/auth");
const { validateBody } = require("../middleware/validate");
const { createError } = require("../utils/apiError");
const { writeAuditLog } = require("../utils/audit");
const {
  normalizeWorkplaceType,
  parseList,
  parseSalaryRange,
  serializeApplication,
  serializeJob
} = require("../utils/serializers");

const router = express.Router();

const jobInclude = {
  company: true,
  _count: {
    select: {
      applications: true,
      savedBy: true
    }
  }
};

const createJobSchema = z.object({
  companyId: z.preprocess((value) => (value === "" || value === undefined ? undefined : Number(value)), z.number().int().positive().optional()),
  company: z.string().trim().max(160).optional(),
  title: z.string().trim().min(2).max(160),
  description: z.string().trim().max(6000).optional(),
  requirements: z.union([z.string(), z.array(z.string())]).optional(),
  responsibilities: z.union([z.string(), z.array(z.string())]).optional(),
  location: z.string().trim().max(160).optional(),
  type: z.string().trim().max(80).optional(),
  jobType: z.string().trim().max(80).optional(),
  workplaceType: z.string().trim().max(20).optional(),
  experienceLevel: z.string().trim().max(80).optional(),
  salary: z.string().trim().max(120).optional(),
  salaryMin: z.preprocess((value) => (value === "" || value === undefined ? undefined : Number(value)), z.number().int().nonnegative().optional()),
  salaryMax: z.preprocess((value) => (value === "" || value === undefined ? undefined : Number(value)), z.number().int().nonnegative().optional()),
  currency: z.string().trim().min(3).max(8).optional(),
  deadline: z.string().trim().optional(),
  status: z.enum(["DRAFT", "OPEN", "CLOSED", "ARCHIVED"]).optional()
});

const patchJobSchema = createJobSchema.partial().extend({
  title: z.string().trim().min(2).max(160).optional()
});

const statusSchema = z.object({
  status: z.enum(["DRAFT", "OPEN", "CLOSED", "ARCHIVED"])
});

function parseId(value, label = "ID") {
  const id = Number.parseInt(value, 10);

  if (!Number.isInteger(id) || id <= 0) {
    throw createError(400, `Invalid ${label}`);
  }

  return id;
}

function parseOptionalDate(value) {
  if (!value) {
    return undefined;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    throw createError(400, "deadline must be a valid date");
  }

  return date;
}

async function getEmployerCompany(userId, payload) {
  if (payload.companyId) {
    const company = await prisma.company.findFirst({
      where: {
        id: payload.companyId,
        ownerUserId: userId
      }
    });

    if (!company) {
      throw createError(403, "You can only post jobs for your own company");
    }

    return company;
  }

  const companyName = String(payload.company || "").trim();

  if (companyName) {
    const existingCompany = await prisma.company.findFirst({
      where: {
        ownerUserId: userId,
        name: {
          equals: companyName,
          mode: "insensitive"
        }
      }
    });

    if (existingCompany) {
      return existingCompany;
    }

    return prisma.company.create({
      data: {
        ownerUserId: userId,
        name: companyName
      }
    });
  }

  const existingCompany = await prisma.company.findFirst({
    where: {
      ownerUserId: userId
    },
    orderBy: {
      createdAt: "asc"
    }
  });

  if (existingCompany) {
    return existingCompany;
  }

  return prisma.company.create({
    data: {
      ownerUserId: userId,
      name: "Career Bridge Employer"
    }
  });
}

function buildJobData(payload) {
  const salaryParts = parseSalaryRange(payload.salary);
  const salaryMin = payload.salaryMin ?? salaryParts.salaryMin;
  const salaryMax = payload.salaryMax ?? salaryParts.salaryMax;

  if (salaryMin !== undefined && salaryMax !== undefined && salaryMin > salaryMax) {
    throw createError(400, "salaryMin cannot be greater than salaryMax");
  }

  const data = {
    ...(payload.title !== undefined ? { title: payload.title } : {}),
    ...(payload.description !== undefined ? {
      description: payload.description || "No description provided yet."
    } : {}),
    ...(payload.requirements !== undefined ? { requirements: parseList(payload.requirements) } : {}),
    ...(payload.responsibilities !== undefined ? { responsibilities: parseList(payload.responsibilities) } : {}),
    ...(payload.location !== undefined ? { location: payload.location || "Bangladesh" } : {}),
    ...(payload.jobType !== undefined || payload.type !== undefined ? {
      jobType: payload.jobType || payload.type || "Not specified"
    } : {}),
    ...(payload.workplaceType !== undefined || payload.type !== undefined ? {
      workplaceType: normalizeWorkplaceType(payload.workplaceType || payload.type)
    } : {}),
    ...(payload.experienceLevel !== undefined ? { experienceLevel: payload.experienceLevel || null } : {}),
    ...(salaryMin !== undefined ? { salaryMin } : {}),
    ...(salaryMax !== undefined ? { salaryMax } : {}),
    ...(payload.currency !== undefined ? { currency: payload.currency || "BDT" } : {}),
    ...(payload.deadline !== undefined ? { deadline: parseOptionalDate(payload.deadline) || null } : {}),
    ...(payload.status !== undefined ? { status: payload.status } : {})
  };

  return data;
}

async function findJobForAccess(jobId) {
  const job = await prisma.job.findUnique({
    where: {
      id: jobId
    },
    include: jobInclude
  });

  if (!job) {
    throw createError(404, "Job not found");
  }

  return job;
}

function canManageJob(user, job) {
  return user?.role === "ADMIN" || (
    user?.role === "EMPLOYER"
    && job.company?.ownerUserId === user.id
  );
}

function assertCanManageJob(user, job, message = "You are not allowed to manage this job") {
  if (!canManageJob(user, job)) {
    throw createError(403, message);
  }
}

async function assertCompanyCanPublishOpen(companyId) {
  const company = await prisma.company.findUnique({
    where: {
      id: companyId
    },
    select: {
      verified: true
    }
  });

  if (!company?.verified) {
    throw createError(403, "Company must be verified by an admin before jobs can be published as OPEN.");
  }
}

router.get("/", optionalAuth, asyncHandler(async (req, res) => {
  const page = Math.max(Number.parseInt(req.query.page || "1", 10) || 1, 1);
  const limit = Math.min(Math.max(Number.parseInt(req.query.limit || "20", 10) || 20, 1), 100);
  const skip = (page - 1) * limit;
  const q = String(req.query.q || "").trim();
  const location = String(req.query.location || "").trim();
  const jobType = String(req.query.jobType || req.query.type || "").trim();
  const workplaceType = String(req.query.workplaceType || "").trim();
  const experienceLevel = String(req.query.experienceLevel || "").trim();
  const companyName = String(req.query.company || "").trim();
  const category = String(req.query.category || "").trim();
  const skill = String(req.query.skill || req.query.skills || "").trim();
  const status = String(req.query.status || "").trim().toUpperCase();
  const companyId = req.query.companyId ? Number.parseInt(req.query.companyId, 10) : null;
  const salaryMin = req.query.salaryMin ? Number.parseInt(req.query.salaryMin, 10) : null;
  const salaryMax = req.query.salaryMax ? Number.parseInt(req.query.salaryMax, 10) : null;
  const deadlineBefore = req.query.deadlineBefore ? new Date(String(req.query.deadlineBefore)) : null;
  const deadlineAfter = req.query.deadlineAfter ? new Date(String(req.query.deadlineAfter)) : null;
  const sort = String(req.query.sort || "newest").trim();

  const where = {};

  if (q) {
    where.OR = [
      {
        title: {
          contains: q,
          mode: "insensitive"
        }
      },
      {
        description: {
          contains: q,
          mode: "insensitive"
        }
      },
      {
        location: {
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
      },
      {
        requirements: {
          has: q
        }
      },
      {
        responsibilities: {
          has: q
        }
      }
    ];
  }

  if (location) {
    where.location = {
      contains: location,
      mode: "insensitive"
    };
  }

  if (jobType) {
    where.jobType = {
      contains: jobType,
      mode: "insensitive"
    };
  }

  if (category) {
    where.OR = [
      ...(where.OR || []),
      {
        jobType: {
          contains: category,
          mode: "insensitive"
        }
      },
      {
        title: {
          contains: category,
          mode: "insensitive"
        }
      }
    ];
  }

  if (companyName) {
    where.company = {
      ...(where.company || {}),
      name: {
        contains: companyName,
        mode: "insensitive"
      }
    };
  }

  if (skill) {
    where.OR = [
      ...(where.OR || []),
      {
        requirements: {
          has: skill
        }
      },
      {
        responsibilities: {
          has: skill
        }
      },
      {
        description: {
          contains: skill,
          mode: "insensitive"
        }
      }
    ];
  }

  if (workplaceType) {
    where.workplaceType = normalizeWorkplaceType(workplaceType);
  }

  if (experienceLevel) {
    where.experienceLevel = {
      contains: experienceLevel,
      mode: "insensitive"
    };
  }

  if (companyId) {
    where.companyId = companyId;
  }

  if (Number.isInteger(salaryMin)) {
    where.salaryMax = {
      gte: salaryMin
    };
  }

  if (Number.isInteger(salaryMax)) {
    where.salaryMin = {
      ...(where.salaryMin || {}),
      lte: salaryMax
    };
  }

  if (deadlineBefore || deadlineAfter) {
    if (deadlineBefore && Number.isNaN(deadlineBefore.getTime())) {
      throw createError(400, "deadlineBefore must be a valid date");
    }

    if (deadlineAfter && Number.isNaN(deadlineAfter.getTime())) {
      throw createError(400, "deadlineAfter must be a valid date");
    }

    where.deadline = {
      ...(deadlineBefore ? { lte: deadlineBefore } : {}),
      ...(deadlineAfter ? { gte: deadlineAfter } : {})
    };
  }

  if (req.user?.role === "EMPLOYER") {
    where.company = {
      ...(where.company || {}),
      ownerUserId: req.user.id
    };
    where.status = status && status !== "ALL" ? status : {
      not: "ARCHIVED"
    };
  } else if (req.user?.role === "ADMIN") {
    if (status && status !== "ALL") {
      where.status = status;
    }
  } else {
    where.status = status && status !== "ALL" ? status : "OPEN";
    where.company = {
      ...(where.company || {}),
      verified: true
    };
  }

  const orderByMap = {
    newest: {
      createdAt: "desc"
    },
    salary_high: {
      salaryMax: "desc"
    },
    salary_low: {
      salaryMin: "asc"
    },
    deadline: {
      deadline: "asc"
    }
  };
  const orderBy = orderByMap[sort] || orderByMap.newest;

  const [jobs, total] = await Promise.all([
    prisma.job.findMany({
      where,
      include: jobInclude,
      orderBy,
      skip,
      take: limit
    }),
    prisma.job.count({
      where
    })
  ]);

  const totalPages = Math.max(Math.ceil(total / limit), 1);

  res.json({
    data: jobs.map(serializeJob),
    count: jobs.length,
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
  });
}));

router.post("/", requireAuth, requireRole("EMPLOYER"), validateBody(createJobSchema), asyncHandler(async (req, res) => {
  const company = await getEmployerCompany(req.user.id, req.body);
  const requestedStatus = req.body.status || "OPEN";
  const status = company.verified ? requestedStatus : "DRAFT";
  const payload = {
    title: req.body.title,
    description: req.body.description || "No description provided yet.",
    location: req.body.location || company.location || "Bangladesh",
    jobType: req.body.jobType || req.body.type || "Not specified",
    workplaceType: normalizeWorkplaceType(req.body.workplaceType || req.body.type),
    currency: req.body.currency || "BDT",
    status,
    requirements: req.body.requirements,
    responsibilities: req.body.responsibilities,
    experienceLevel: req.body.experienceLevel,
    salary: req.body.salary,
    salaryMin: req.body.salaryMin,
    salaryMax: req.body.salaryMax,
    deadline: req.body.deadline
  };
  const data = buildJobData(payload);

  const job = await prisma.job.create({
    data: {
      ...data,
      companyId: company.id
    },
    include: jobInclude
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "CREATE_JOB",
    targetType: "JOB",
    targetId: job.id,
    metadata: {
      companyId: company.id
    }
  });

  res.status(201).json({
    message: company.verified
      ? "Job posted successfully"
      : "Company is not verified yet. Job was saved as a draft until an admin verifies the company.",
    data: serializeJob(job)
  });
}));

router.get("/:id/applications", requireAuth, requireRole("EMPLOYER", "ADMIN"), asyncHandler(async (req, res) => {
  const jobId = parseId(req.params.id, "job ID");
  const job = await findJobForAccess(jobId);
  assertCanManageJob(req.user, job, "You are not allowed to view applications for this job");

  const applications = await prisma.application.findMany({
    where: {
      jobId
    },
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

router.patch("/:id/status", requireAuth, requireRole("EMPLOYER", "ADMIN"), validateBody(statusSchema), asyncHandler(async (req, res) => {
  const jobId = parseId(req.params.id, "job ID");
  const job = await findJobForAccess(jobId);
  assertCanManageJob(req.user, job);

  if (req.body.status === "OPEN") {
    await assertCompanyCanPublishOpen(job.companyId);
  }

  const updatedJob = await prisma.job.update({
    where: {
      id: jobId
    },
    data: {
      status: req.body.status
    },
    include: jobInclude
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "UPDATE_JOB_STATUS",
    targetType: "JOB",
    targetId: jobId,
    metadata: {
      status: req.body.status
    }
  });

  res.json({
    message: "Job status updated",
    data: serializeJob(updatedJob)
  });
}));

router.get("/:id", optionalAuth, asyncHandler(async (req, res) => {
  const jobId = parseId(req.params.id, "job ID");
  const job = await findJobForAccess(jobId);

  if ((job.status !== "OPEN" || !job.company?.verified) && !canManageJob(req.user, job)) {
    throw createError(404, "Job not found");
  }

  res.json({
    data: serializeJob(job)
  });
}));

router.patch("/:id", requireAuth, requireRole("EMPLOYER", "ADMIN"), validateBody(patchJobSchema), asyncHandler(async (req, res) => {
  const jobId = parseId(req.params.id, "job ID");
  const job = await findJobForAccess(jobId);
  assertCanManageJob(req.user, job);

  const data = buildJobData(req.body);

  if (req.body.companyId || req.body.company) {
    const company = await getEmployerCompany(req.user.id, req.body);
    data.companyId = company.id;
  }

  if (data.status === "OPEN") {
    await assertCompanyCanPublishOpen(data.companyId || job.companyId);
  }

  const updatedJob = await prisma.job.update({
    where: {
      id: jobId
    },
    data,
    include: jobInclude
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "UPDATE_JOB",
    targetType: "JOB",
    targetId: jobId
  });

  res.json({
    message: "Job updated successfully",
    data: serializeJob(updatedJob)
  });
}));

router.delete("/:id", requireAuth, requireRole("EMPLOYER", "ADMIN"), asyncHandler(async (req, res) => {
  const jobId = parseId(req.params.id, "job ID");
  const job = await findJobForAccess(jobId);
  assertCanManageJob(req.user, job, "You are not allowed to delete this job");

  const updatedJob = await prisma.job.update({
    where: {
      id: jobId
    },
    data: {
      status: "ARCHIVED"
    },
    include: jobInclude
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "ARCHIVE_JOB",
    targetType: "JOB",
    targetId: jobId
  });

  res.json({
    message: "Job archived successfully",
    data: serializeJob(updatedJob)
  });
}));

module.exports = router;
