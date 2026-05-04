const jwt = require("jsonwebtoken");
const prisma = require("../db/prisma");
const { createError } = require("../utils/apiError");

const roleAliases = {
  employee: "JOB_SEEKER",
  jobseeker: "JOB_SEEKER",
  job_seeker: "JOB_SEEKER",
  JOBSEEKER: "JOB_SEEKER",
  JOB_SEEKER: "JOB_SEEKER",
  employer: "EMPLOYER",
  EMPLOYER: "EMPLOYER",
  admin: "ADMIN",
  ADMIN: "ADMIN"
};

function getJwtSecret() {
  const secret = process.env.JWT_SECRET || process.env.AUTH_JWT_SECRET;

  if (secret) {
    return secret;
  }

  if (process.env.NODE_ENV === "production") {
    throw createError(500, "JWT_SECRET must be configured in production");
  }

  return "career-bridge-local-dev-secret-change-me";
}

function normalizeRole(value) {
  const key = String(value || "").trim();
  return roleAliases[key] || roleAliases[key.toLowerCase()] || "";
}

function toPublicAuthUser(user) {
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

function extractBearerToken(req) {
  const authHeader = String(req.header("authorization") || "").trim();

  if (!authHeader.toLowerCase().startsWith("bearer ")) {
    return "";
  }

  return authHeader.slice(7).trim();
}

function signAccessToken(user) {
  return jwt.sign(
    {
      sub: String(user.id),
      role: user.role,
      email: user.email
    },
    getJwtSecret(),
    {
      expiresIn: process.env.JWT_EXPIRES_IN || "8h"
    }
  );
}

function decodeTokenExpiry(token) {
  const decoded = jwt.decode(token);
  if (!decoded || !decoded.exp) {
    return "";
  }

  return new Date(decoded.exp * 1000).toISOString();
}

async function loadUserFromToken(token) {
  let decoded;

  try {
    decoded = jwt.verify(token, getJwtSecret());
  } catch (_error) {
    throw createError(401, "Session expired. Please sign in again.");
  }

  const userId = Number.parseInt(decoded.sub, 10);
  if (!Number.isInteger(userId) || userId <= 0) {
    throw createError(401, "Invalid authentication token");
  }

  const user = await prisma.user.findUnique({
    where: {
      id: userId
    }
  });

  if (!user || !user.isActive) {
    throw createError(401, "User account is inactive or no longer exists");
  }

  return user;
}

async function optionalAuth(req, _res, next) {
  try {
    const token = extractBearerToken(req);

    if (!token) {
      next();
      return;
    }

    const user = await loadUserFromToken(token);
    req.user = toPublicAuthUser(user);
    next();
  } catch (error) {
    next(error);
  }
}

async function requireAuth(req, _res, next) {
  try {
    const token = extractBearerToken(req);

    if (!token) {
      throw createError(401, "Authentication required");
    }

    const user = await loadUserFromToken(token);
    req.user = toPublicAuthUser(user);
    next();
  } catch (error) {
    next(error);
  }
}

function requireRole(...roles) {
  const allowedRoles = roles.flat().map(normalizeRole).filter(Boolean);

  return (req, _res, next) => {
    if (!req.user) {
      next(createError(401, "Authentication required"));
      return;
    }

    if (!allowedRoles.includes(req.user.role)) {
      next(createError(403, "You do not have permission to perform this action"));
      return;
    }

    next();
  };
}

module.exports = {
  decodeTokenExpiry,
  extractBearerToken,
  normalizeRole,
  optionalAuth,
  requireAuth,
  requireRole,
  signAccessToken,
  toPublicAuthUser
};
