const express = require("express");
const { z } = require("zod");
const prisma = require("../db/prisma");
const asyncHandler = require("../middleware/asyncHandler");
const { requireAuth, requireRole } = require("../middleware/auth");
const { validateBody } = require("../middleware/validate");
const {
  parseList,
  serializeApplication,
  serializeJob,
  serializeProfile,
  serializeUser
} = require("../utils/serializers");

const router = express.Router();

const patchProfileSchema = z.object({
  headline: z.string().trim().max(180).optional(),
  phone: z.string().trim().max(40).optional(),
  location: z.string().trim().max(140).optional(),
  bio: z.string().trim().max(2000).optional(),
  skills: z.union([z.string(), z.array(z.string())]).optional(),
  education: z.any().optional(),
  experience: z.any().optional(),
  portfolioUrl: z.string().trim().url().optional().or(z.literal("")),
  linkedinUrl: z.string().trim().url().optional().or(z.literal("")),
  githubUrl: z.string().trim().url().optional().or(z.literal("")),
  resumeUrl: z.string().trim().max(300).optional()
});

function profileDataFromBody(body) {
  const data = {};

  for (const field of ["headline", "phone", "location", "bio", "portfolioUrl", "linkedinUrl", "githubUrl", "resumeUrl"]) {
    if (body[field] !== undefined) {
      data[field] = body[field] || null;
    }
  }

  if (body.skills !== undefined) {
    data.skills = parseList(body.skills);
  }

  if (body.education !== undefined) {
    data.education = body.education || null;
  }

  if (body.experience !== undefined) {
    data.experience = body.experience || null;
  }

  return data;
}

router.get("/me", requireAuth, asyncHandler(async (req, res) => {
  const user = await prisma.user.findUnique({
    where: {
      id: req.user.id
    },
    include: {
      jobSeekerProfile: true,
      savedJobs: {
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
      },
      applications: {
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
      }
    }
  });

  res.json({
    data: {
      user: serializeUser(user),
      profile: serializeProfile(user.jobSeekerProfile),
      savedJobs: user.savedJobs.map((savedJob) => ({
        id: savedJob.id,
        createdAt: savedJob.createdAt,
        job: serializeJob(savedJob.job)
      })),
      applications: user.applications.map((application) => serializeApplication(application, {
        canViewResume: true
      }))
    }
  });
}));

router.patch("/me", requireAuth, requireRole("JOB_SEEKER"), validateBody(patchProfileSchema), asyncHandler(async (req, res) => {
  const profile = await prisma.jobSeekerProfile.upsert({
    where: {
      userId: req.user.id
    },
    create: {
      userId: req.user.id,
      ...profileDataFromBody(req.body)
    },
    update: profileDataFromBody(req.body)
  });

  res.json({
    message: "Profile updated successfully",
    data: serializeProfile(profile)
  });
}));

router.get("/:userId", asyncHandler(async (req, res) => {
  const userId = Number.parseInt(req.params.userId, 10);

  if (!Number.isInteger(userId) || userId <= 0) {
    res.status(400).json({
      message: "Invalid user ID"
    });
    return;
  }

  const user = await prisma.user.findFirst({
    where: {
      id: userId,
      role: "JOB_SEEKER",
      isActive: true
    },
    include: {
      jobSeekerProfile: true
    }
  });

  if (!user) {
    res.status(404).json({
      message: "Profile not found"
    });
    return;
  }

  res.json({
    data: {
      user: {
        id: user.id,
        name: user.name,
        avatarUrl: user.avatarUrl
      },
      profile: serializeProfile(user.jobSeekerProfile)
    }
  });
}));

module.exports = router;
