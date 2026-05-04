const express = require("express");
const prisma = require("../db/prisma");
const asyncHandler = require("../middleware/asyncHandler");
const { serializeSalaryInsight } = require("../utils/serializers");

const router = express.Router();

router.get("/", asyncHandler(async (req, res) => {
  const q = String(req.query.q || "").trim();
  const location = String(req.query.location || "").trim();
  const experienceLevel = String(req.query.experienceLevel || "").trim();

  const where = {
    ...(q ? {
      roleTitle: {
        contains: q,
        mode: "insensitive"
      }
    } : {}),
    ...(location ? {
      location: {
        contains: location,
        mode: "insensitive"
      }
    } : {}),
    ...(experienceLevel ? {
      experienceLevel: {
        contains: experienceLevel,
        mode: "insensitive"
      }
    } : {})
  };

  const salaries = await prisma.salaryInsight.findMany({
    where,
    orderBy: [
      {
        roleTitle: "asc"
      },
      {
        salaryMax: "desc"
      }
    ]
  });

  res.json({
    data: salaries.map(serializeSalaryInsight),
    count: salaries.length
  });
}));

module.exports = router;
