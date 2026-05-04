const express = require("express");
const prisma = require("../db/prisma");
const asyncHandler = require("../middleware/asyncHandler");
const { serializeCompany, serializeJob } = require("../utils/serializers");

const router = express.Router();

router.get("/", asyncHandler(async (req, res) => {
  const q = String(req.query.q || "").trim();
  const location = String(req.query.location || "").trim();
  const industry = String(req.query.industry || "").trim();
  const verified = req.query.verified;

  const where = {
    ...(q ? {
      name: {
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
    ...(industry ? {
      industry: {
        contains: industry,
        mode: "insensitive"
      }
    } : {}),
    ...(verified !== undefined ? {
      verified: String(verified).toLowerCase() === "true"
    } : {})
  };

  const companies = await prisma.company.findMany({
    where,
    include: {
      _count: {
        select: {
          jobs: true
        }
      }
    },
    orderBy: {
      name: "asc"
    }
  });

  res.json({
    data: companies.map(serializeCompany),
    count: companies.length
  });
}));

router.get("/:id", asyncHandler(async (req, res) => {
  const id = Number.parseInt(req.params.id, 10);

  if (!Number.isInteger(id) || id <= 0) {
    res.status(400).json({
      message: "Invalid company ID"
    });
    return;
  }

  const company = await prisma.company.findUnique({
    where: {
      id
    },
    include: {
      jobs: {
        where: {
          status: "OPEN"
        },
        orderBy: {
          createdAt: "desc"
        }
      },
      _count: {
        select: {
          jobs: true
        }
      }
    }
  });

  if (!company) {
    res.status(404).json({
      message: "Company not found"
    });
    return;
  }

  res.json({
    data: {
      ...serializeCompany(company),
      jobs: company.jobs.map((job) => serializeJob({
        ...job,
        company
      }))
    }
  });
}));

module.exports = router;
