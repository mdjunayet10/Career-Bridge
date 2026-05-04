const express = require("express");
const prisma = require("../db/prisma");
const asyncHandler = require("../middleware/asyncHandler");
const { requireAuth, requireRole } = require("../middleware/auth");
const { createError } = require("../utils/apiError");
const { serializeJob } = require("../utils/serializers");

const router = express.Router();

function parseId(value, label = "ID") {
  const id = Number.parseInt(value, 10);

  if (!Number.isInteger(id) || id <= 0) {
    throw createError(400, `Invalid ${label}`);
  }

  return id;
}

router.get("/me", requireAuth, requireRole("JOB_SEEKER"), asyncHandler(async (req, res) => {
  const savedJobs = await prisma.savedJob.findMany({
    where: {
      userId: req.user.id
    },
    include: {
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
    data: savedJobs.map((savedJob) => ({
      id: savedJob.id,
      jobId: savedJob.jobId,
      createdAt: savedJob.createdAt,
      job: serializeJob(savedJob.job)
    })),
    count: savedJobs.length
  });
}));

router.post("/:jobId", requireAuth, requireRole("JOB_SEEKER"), asyncHandler(async (req, res) => {
  const jobId = parseId(req.params.jobId, "job ID");
  const job = await prisma.job.findFirst({
    where: {
      id: jobId,
      status: "OPEN"
    }
  });

  if (!job) {
    throw createError(404, "Open job not found");
  }

  const savedJob = await prisma.savedJob.upsert({
    where: {
      userId_jobId: {
        userId: req.user.id,
        jobId
      }
    },
    create: {
      userId: req.user.id,
      jobId
    },
    update: {},
    include: {
      job: {
        include: {
          company: true
        }
      }
    }
  });

  res.status(201).json({
    message: "Job saved",
    data: {
      id: savedJob.id,
      jobId: savedJob.jobId,
      createdAt: savedJob.createdAt,
      job: serializeJob(savedJob.job)
    }
  });
}));

router.delete("/:jobId", requireAuth, requireRole("JOB_SEEKER"), asyncHandler(async (req, res) => {
  const jobId = parseId(req.params.jobId, "job ID");

  await prisma.savedJob.deleteMany({
    where: {
      userId: req.user.id,
      jobId
    }
  });

  res.json({
    message: "Saved job removed"
  });
}));

module.exports = router;
