const express = require("express");
const { z } = require("zod");
const prisma = require("../db/prisma");
const asyncHandler = require("../middleware/asyncHandler");
const { requireAuth } = require("../middleware/auth");
const { validateBody } = require("../middleware/validate");
const { createError } = require("../utils/apiError");
const { writeAuditLog } = require("../utils/audit");

const router = express.Router();

const reportSchema = z.object({
  targetType: z.string().trim().toUpperCase().pipe(z.enum(["JOB", "COMPANY", "USER"])),
  targetId: z.preprocess((value) => Number(value), z.number().int().positive()),
  reason: z.string().trim().min(10).max(1000)
});

async function ensureReportTargetExists(targetType, targetId) {
  if (targetType === "JOB") {
    return prisma.job.findUnique({ where: { id: targetId } });
  }

  if (targetType === "COMPANY") {
    return prisma.company.findUnique({ where: { id: targetId } });
  }

  return prisma.user.findUnique({ where: { id: targetId } });
}

router.post("/", requireAuth, validateBody(reportSchema), asyncHandler(async (req, res) => {
  const target = await ensureReportTargetExists(req.body.targetType, req.body.targetId);

  if (!target) {
    throw createError(404, "Report target not found");
  }

  const report = await prisma.report.create({
    data: {
      reporterUserId: req.user.id,
      targetType: req.body.targetType,
      targetId: req.body.targetId,
      reason: req.body.reason
    }
  });

  await writeAuditLog({
    actorUserId: req.user.id,
    action: "CREATE_REPORT",
    targetType: "REPORT",
    targetId: report.id,
    metadata: {
      reportedTargetType: req.body.targetType,
      reportedTargetId: req.body.targetId
    }
  });

  res.status(201).json({
    message: "Report submitted for admin review",
    data: report
  });
}));

module.exports = router;
