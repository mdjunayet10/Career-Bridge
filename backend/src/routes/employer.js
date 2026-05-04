const express = require("express");
const { z } = require("zod");
const prisma = require("../db/prisma");
const asyncHandler = require("../middleware/asyncHandler");
const { requireAuth, requireRole } = require("../middleware/auth");
const { validateBody } = require("../middleware/validate");
const { serializeApplication, serializeCompany, serializeJob } = require("../utils/serializers");

const router = express.Router();

router.use(requireAuth, requireRole("EMPLOYER"));

const patchCompanySchema = z.object({
  name: z.string().trim().min(2).max(160).optional(),
  logoUrl: z.string().trim().url().optional().or(z.literal("")),
  industry: z.string().trim().max(120).optional(),
  size: z.string().trim().max(80).optional(),
  location: z.string().trim().max(140).optional(),
  website: z.string().trim().url().optional().or(z.literal("")),
  description: z.string().trim().max(1500).optional()
});

function companyDataFromBody(body) {
  const data = {};

  for (const field of ["name", "logoUrl", "industry", "size", "location", "website", "description"]) {
    if (body[field] !== undefined) {
      data[field] = body[field] || null;
    }
  }

  return data;
}

async function getPrimaryCompany(userId) {
  let company = await prisma.company.findFirst({
    where: {
      ownerUserId: userId
    },
    include: {
      _count: {
        select: {
          jobs: true
        }
      }
    },
    orderBy: {
      createdAt: "asc"
    }
  });

  if (!company) {
    company = await prisma.company.create({
      data: {
        ownerUserId: userId,
        name: "Career Bridge Employer"
      },
      include: {
        _count: {
          select: {
            jobs: true
          }
        }
      }
    });
  }

  return company;
}

router.get("/company", asyncHandler(async (req, res) => {
  const company = await getPrimaryCompany(req.user.id);

  res.json({
    data: serializeCompany(company)
  });
}));

router.patch("/company", validateBody(patchCompanySchema), asyncHandler(async (req, res) => {
  const company = await getPrimaryCompany(req.user.id);
  const updatedCompany = await prisma.company.update({
    where: {
      id: company.id
    },
    data: companyDataFromBody(req.body),
    include: {
      _count: {
        select: {
          jobs: true
        }
      }
    }
  });

  res.json({
    message: "Company profile updated",
    data: serializeCompany(updatedCompany)
  });
}));

router.get("/applications", asyncHandler(async (req, res) => {
  const applications = await prisma.application.findMany({
    where: {
      job: {
        company: {
          ownerUserId: req.user.id
        }
      }
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

router.get("/dashboard", asyncHandler(async (req, res) => {
  const company = await getPrimaryCompany(req.user.id);
  const jobs = await prisma.job.findMany({
    where: {
      company: {
        ownerUserId: req.user.id
      },
      status: {
        not: "ARCHIVED"
      }
    },
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
    }
  });

  const [statusCounts, recentApplications] = await Promise.all([
    prisma.application.groupBy({
      by: ["status"],
      where: {
        job: {
          company: {
            ownerUserId: req.user.id
          }
        }
      },
      _count: {
        status: true
      }
    }),
    prisma.application.findMany({
      where: {
        job: {
          company: {
            ownerUserId: req.user.id
          }
        }
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
      },
      take: 8
    })
  ]);

  const countsByStatus = statusCounts.reduce((acc, item) => {
    acc[item.status] = item._count.status;
    return acc;
  }, {});

  res.json({
    data: {
      company: serializeCompany(company),
      jobs: jobs.map(serializeJob),
      counts: {
        jobsPosted: jobs.length,
        applications: statusCounts.reduce((sum, item) => sum + item._count.status, 0),
        byStatus: countsByStatus
      },
      recentApplicants: recentApplications.map((application) => serializeApplication(application, {
        canViewResume: true,
        includeEmployerNote: true
      }))
    }
  });
}));

module.exports = router;
