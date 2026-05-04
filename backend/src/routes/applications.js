const fs = require("fs");
const express = require("express");
const { z } = require("zod");
const prisma = require("../db/prisma");
const asyncHandler = require("../middleware/asyncHandler");
const { requireAuth, requireRole } = require("../middleware/auth");
const { validateBody } = require("../middleware/validate");
const { createError } = require("../utils/apiError");
const { writeAuditLog } = require("../utils/audit");
const {
  getResumePath,
  removeUploadedFile,
  sanitizeDownloadFileName,
  uploadResume
} = require("../utils/files");
const { serializeApplication } = require("../utils/serializers");

const router = express.Router();

const applicationInclude = {
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
};

const applicationStatusAliases = {
  PENDING: "SUBMITTED",
  ACCEPTED: "HIRED"
};

const statusSchema = z.object({
  status: z.preprocess((value) => {
    const normalized = String(value || "").trim().toUpperCase();
    return applicationStatusAliases[normalized] || normalized;
  }, z.enum(["SUBMITTED", "REVIEWED", "SHORTLISTED", "INTERVIEW", "REJECTED", "HIRED"]))
});

const noteSchema = z.object({
  employerNote: z.string().trim().max(2000).optional().default("")
});

function parseId(value, label = "ID") {
  const id = Number.parseInt(value, 10);

  if (!Number.isInteger(id) || id <= 0) {
    throw createError(400, `Invalid ${label}`);
  }

  return id;
}

function canEmployerAccessApplication(user, application) {
  return user.role === "ADMIN" || (
    user.role === "EMPLOYER"
    && application.job?.company?.ownerUserId === user.id
  );
}

function canDownloadResume(user, application) {
  return user.role === "ADMIN"
    || application.applicantUserId === user.id
    || canEmployerAccessApplication(user, application);
}

async function findApplication(applicationId) {
  const application = await prisma.application.findUnique({
    where: {
      id: applicationId
    },
    include: applicationInclude
  });

  if (!application) {
    throw createError(404, "Application not found");
  }

  return application;
}

const downloadResumeHandler = asyncHandler(async (req, res) => {
  const applicationId = parseId(req.params.id, "application ID");
  const application = await findApplication(applicationId);

  if (!canDownloadResume(req.user, application)) {
    throw createError(403, "You are not allowed to view this CV");
  }

  if (!application.resumeStorageName) {
    throw createError(404, "CV file is not available for this application");
  }

  const resumePath = getResumePath(application.resumeStorageName);

  if (!resumePath || !fs.existsSync(resumePath)) {
    throw createError(404, "CV file is missing from the server");
  }

  const displayName = sanitizeDownloadFileName(application.resumeOriginalName);
  res.setHeader("Content-Disposition", `inline; filename="${displayName}"`);
  res.sendFile(resumePath);
});

router.get("/", requireAuth, requireRole("EMPLOYER", "ADMIN"), asyncHandler(async (req, res) => {
  const jobId = req.query.jobId ? parseId(req.query.jobId, "job ID") : null;
  const where = {};

  if (jobId) {
    where.jobId = jobId;
  }

  if (req.user.role === "EMPLOYER") {
    where.job = {
      company: {
        ownerUserId: req.user.id
      }
    };
  }

  const applications = await prisma.application.findMany({
    where,
    include: applicationInclude,
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

router.get("/me", requireAuth, requireRole("JOB_SEEKER"), asyncHandler(async (req, res) => {
  const applications = await prisma.application.findMany({
    where: {
      applicantUserId: req.user.id
    },
    include: applicationInclude,
    orderBy: {
      createdAt: "desc"
    }
  });

  res.json({
    data: applications.map((application) => serializeApplication(application, {
      canViewResume: true
    })),
    count: applications.length
  });
}));

router.post("/", requireAuth, requireRole("JOB_SEEKER"), uploadResume.single("cvFile"), asyncHandler(async (req, res) => {
  try {
    const jobId = parseId(req.body.jobId, "job ID");
    const applicantName = String(req.body.applicantName || "").trim();
    const applicantPhone = String(req.body.applicantPhone || "").trim();
    const coverLetter = String(req.body.coverLetter || "").trim();

    if (!req.file) {
      throw createError(400, "A CV file is required");
    }

    if (applicantName && applicantName.length > 120) {
      throw createError(400, "applicantName must be 120 characters or less");
    }

    if (applicantPhone.length > 40) {
      throw createError(400, "applicantPhone must be 40 characters or less");
    }

    if (coverLetter.length > 3000) {
      throw createError(400, "coverLetter must be 3000 characters or less");
    }

    const job = await prisma.job.findUnique({
      where: {
        id: jobId
      },
      include: {
        company: true
      }
    });

    if (!job || job.status !== "OPEN") {
      throw createError(404, "Open job not found");
    }

    let application;

    try {
      application = await prisma.application.create({
        data: {
          jobId,
          applicantUserId: req.user.id,
          resumeStorageName: req.file.filename,
          resumeOriginalName: req.file.originalname,
          coverLetter: coverLetter || null
        }
      });
    } catch (error) {
      if (error.code === "P2002") {
        throw createError(409, "You have already applied to this job");
      }

      throw error;
    }

    const resumeUrl = `/api/applications/${application.id}/resume`;

    const [updatedApplication] = await prisma.$transaction([
      prisma.application.update({
        where: {
          id: application.id
        },
        data: {
          resumeUrl
        },
        include: applicationInclude
      }),
      prisma.jobSeekerProfile.upsert({
        where: {
          userId: req.user.id
        },
        create: {
          userId: req.user.id,
          phone: applicantPhone || null,
          resumeUrl
        },
        update: {
          ...(applicantPhone ? { phone: applicantPhone } : {}),
          resumeUrl
        }
      }),
      ...(applicantName && applicantName !== req.user.name ? [
        prisma.user.update({
          where: {
            id: req.user.id
          },
          data: {
            name: applicantName
          }
        })
      ] : [])
    ]);

    await writeAuditLog({
      actorUserId: req.user.id,
      action: "SUBMIT_APPLICATION",
      targetType: "APPLICATION",
      targetId: updatedApplication.id,
      metadata: {
        jobId
      }
    });

    res.status(201).json({
      message: "Application submitted successfully",
      data: serializeApplication(updatedApplication, {
        canViewResume: true
      })
    });
  } catch (error) {
    removeUploadedFile(req.file);
    throw error;
  }
}));

router.patch("/:id/status", requireAuth, requireRole("EMPLOYER", "ADMIN"), validateBody(statusSchema), asyncHandler(async (req, res) => {
  const applicationId = parseId(req.params.id, "application ID");
  const application = await findApplication(applicationId);

  if (!canEmployerAccessApplication(req.user, application)) {
    throw createError(403, "You are not allowed to update this application");
  }

  const updatedApplication = await prisma.application.update({
    where: {
      id: applicationId
    },
    data: {
      status: req.body.status
    },
    include: applicationInclude
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "UPDATE_APPLICATION_STATUS",
    targetType: "APPLICATION",
    targetId: applicationId,
    metadata: {
      status: req.body.status
    }
  });

  res.json({
    message: "Application status updated",
    data: serializeApplication(updatedApplication, {
      canViewResume: true,
      includeEmployerNote: true
    })
  });
}));

router.patch("/:id/note", requireAuth, requireRole("EMPLOYER", "ADMIN"), validateBody(noteSchema), asyncHandler(async (req, res) => {
  const applicationId = parseId(req.params.id, "application ID");
  const application = await findApplication(applicationId);

  if (!canEmployerAccessApplication(req.user, application)) {
    throw createError(403, "You are not allowed to update this application");
  }

  const updatedApplication = await prisma.application.update({
    where: {
      id: applicationId
    },
    data: {
      employerNote: req.body.employerNote || null
    },
    include: applicationInclude
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "UPDATE_APPLICATION_NOTE",
    targetType: "APPLICATION",
    targetId: applicationId
  });

  res.json({
    message: "Employer note updated",
    data: serializeApplication(updatedApplication, {
      canViewResume: true,
      includeEmployerNote: true
    })
  });
}));

router.get("/:id/resume", requireAuth, downloadResumeHandler);
router.get("/:id/cv", requireAuth, downloadResumeHandler);

module.exports = router;
