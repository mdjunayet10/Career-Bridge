const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const express = require("express");
const nodemailer = require("nodemailer");
const { z } = require("zod");
const prisma = require("../db/prisma");
const asyncHandler = require("../middleware/asyncHandler");
const { requireAuth, normalizeRole, signAccessToken, decodeTokenExpiry } = require("../middleware/auth");
const { validateBody } = require("../middleware/validate");
const { createError } = require("../utils/apiError");
const { serializeCompany, serializeProfile, serializeUser } = require("../utils/serializers");

const router = express.Router();
const demoAccounts = new Set([
  "admin@careerbridge.com",
  "employer@careerbridge.com",
  "employee@careerbridge.com"
]);

const emailSchema = z.string().trim().toLowerCase().email().max(180);
const passwordSchema = z.string().min(8).max(128);

const registerSchema = z.object({
  name: z.string().trim().min(2).max(120),
  email: emailSchema,
  password: passwordSchema,
  role: z.string().optional().default("JOB_SEEKER"),
  avatarUrl: z.string().trim().url().optional().or(z.literal("")),
  companyName: z.string().trim().min(2).max(160).optional(),
  company: z.object({
    name: z.string().trim().min(2).max(160).optional(),
    industry: z.string().trim().max(120).optional(),
    size: z.string().trim().max(80).optional(),
    location: z.string().trim().max(120).optional(),
    website: z.string().trim().url().optional().or(z.literal("")),
    description: z.string().trim().max(1000).optional()
  }).optional()
});

const loginSchema = z.object({
  role: z.string().optional(),
  email: z.string().trim().toLowerCase().email().max(180).optional(),
  password: z.string().max(128).optional(),
  employeeEmail: z.string().trim().toLowerCase().email().max(180).optional(),
  employeePassword: z.string().max(128).optional(),
  employerEmail: z.string().trim().toLowerCase().email().max(180).optional(),
  employerKey: z.string().max(128).optional()
});

const forgotPasswordSchema = z.object({
  email: emailSchema
});

const resetPasswordSchema = z.object({
  email: emailSchema.optional(),
  code: z.string().trim().min(6).max(12).optional(),
  token: z.string().trim().min(6).max(256).optional(),
  password: passwordSchema
}).refine((value) => value.code || value.token, {
  message: "Verification code is required",
  path: ["code"]
});

function hashResetToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function hashVerificationCode(userId, code) {
  return hashResetToken(`${userId}:${String(code).trim()}`);
}

function createVerificationCode() {
  return String(crypto.randomInt(100000, 1000000));
}

function getResetTokenExpiry() {
  const minutes = Number(process.env.PASSWORD_RESET_TOKEN_MINUTES || 30);
  const safeMinutes = Number.isFinite(minutes) && minutes > 0 ? minutes : 30;
  return new Date(Date.now() + safeMinutes * 60 * 1000);
}

function parseBoolean(value) {
  return ["1", "true", "yes", "on"].includes(String(value || "").trim().toLowerCase());
}

function isProduction() {
  return process.env.NODE_ENV === "production";
}

function hasSmtpConfig() {
  return Boolean(process.env.SMTP_HOST);
}

function getSmtpConfig() {
  if (!hasSmtpConfig()) {
    return null;
  }

  const config = {
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 587),
    secure: parseBoolean(process.env.SMTP_SECURE)
  };

  if (process.env.SMTP_USER && process.env.SMTP_PASS) {
    config.auth = {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    };
  }

  if (process.env.SMTP_REQUIRE_TLS) {
    config.requireTLS = parseBoolean(process.env.SMTP_REQUIRE_TLS);
  }

  if (process.env.SMTP_IGNORE_TLS) {
    config.ignoreTLS = parseBoolean(process.env.SMTP_IGNORE_TLS);
  }

  return config;
}

function escapeHtml(value) {
  return String(value || "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

async function sendPasswordResetEmail({ to, name, code }) {
  const smtpConfig = getSmtpConfig();

  if (!smtpConfig) {
    return false;
  }

  const transporter = nodemailer.createTransport(smtpConfig);
  const appName = "Career Bridge";
  const greetingName = name || "there";
  const safeGreetingName = escapeHtml(greetingName);
  const resetMinutes = Number(process.env.PASSWORD_RESET_TOKEN_MINUTES || 30);

  await transporter.sendMail({
    from: process.env.EMAIL_FROM || `"${appName}" <no-reply@careerbridge.com>`,
    to,
    subject: `${appName} password reset verification code`,
    text: [
      `Hello ${greetingName},`,
      "",
      `Your ${appName} password reset verification code is: ${code}`,
      "",
      `This code expires in ${resetMinutes} minutes.`,
      "If you did not request this, you can safely ignore this email."
    ].join("\n"),
    html: `
      <div style="font-family:Arial,sans-serif;line-height:1.5;color:#24292f">
        <h2>${appName} password reset</h2>
        <p>Hello ${safeGreetingName},</p>
        <p>Use this verification code to reset your password:</p>
        <p style="font-size:28px;font-weight:700;letter-spacing:6px;margin:20px 0">${code}</p>
        <p>This code expires in ${resetMinutes} minutes.</p>
        <p>If you did not request this, you can safely ignore this email.</p>
      </div>
    `
  });

  return true;
}

function getLegacyRole(role) {
  if (role === "EMPLOYER") {
    return "employer";
  }

  if (role === "ADMIN") {
    return "admin";
  }

  return "employee";
}

function buildAuthPayload(user, accessToken, extra = {}) {
  const expiresAt = decodeTokenExpiry(accessToken);
  const legacyRole = getLegacyRole(user.role);

  return {
    accessToken,
    expiresAt,
    tokenType: "Bearer",
    user: serializeUser(user),
    role: user.role,
    legacyRole,
    email: user.email,
    employerEmail: user.role === "EMPLOYER" ? user.email : undefined,
    displayName: user.name,
    ...extra
  };
}

router.post("/register", validateBody(registerSchema), asyncHandler(async (req, res) => {
  const requestedRole = normalizeRole(req.body.role);

  if (!requestedRole || requestedRole === "ADMIN") {
    throw createError(400, "Registration supports JOB_SEEKER or EMPLOYER roles");
  }

  const existing = await prisma.user.findUnique({
    where: {
      email: req.body.email
    }
  });

  if (existing) {
    throw createError(409, "An account with this email already exists");
  }

  const passwordHash = await bcrypt.hash(req.body.password, 12);
  const result = await prisma.$transaction(async (tx) => {
    const user = await tx.user.create({
      data: {
        name: req.body.name,
        email: req.body.email,
        passwordHash,
        role: requestedRole,
        avatarUrl: req.body.avatarUrl || null
      }
    });

    let profile = null;
    let company = null;

    if (requestedRole === "JOB_SEEKER") {
      profile = await tx.jobSeekerProfile.create({
        data: {
          userId: user.id,
          headline: "Open to career opportunities"
        }
      });
    }

    if (requestedRole === "EMPLOYER") {
      const companyPayload = req.body.company || {};
      company = await tx.company.create({
        data: {
          ownerUserId: user.id,
          name: companyPayload.name || req.body.companyName || `${req.body.name}'s Company`,
          industry: companyPayload.industry || null,
          size: companyPayload.size || null,
          location: companyPayload.location || null,
          website: companyPayload.website || null,
          description: companyPayload.description || null
        }
      });
    }

    await tx.auditLog.create({
      data: {
        actorUserId: user.id,
        action: "REGISTER_USER",
        targetType: "USER",
        targetId: user.id,
        metadata: {
          role: requestedRole
        }
      }
    });

    return { user, profile, company };
  });

  const accessToken = signAccessToken(result.user);

  res.status(201).json({
    message: "Registration successful",
    data: buildAuthPayload(result.user, accessToken, {
      profile: serializeProfile(result.profile),
      company: serializeCompany(result.company)
    })
  });
}));

router.post("/login", validateBody(loginSchema), asyncHandler(async (req, res) => {
  const inferredRole = req.body.role
    || (req.body.employeeEmail || req.body.employeePassword ? "employee" : "")
    || (req.body.employerEmail || req.body.employerKey ? "employer" : "");
  const requestedRole = inferredRole ? normalizeRole(inferredRole) : "";
  const email = req.body.email || req.body.employeeEmail || req.body.employerEmail || "";
  const password = req.body.password || req.body.employeePassword || req.body.employerKey || "";

  if (!email || !password) {
    throw createError(400, "Email and password are required");
  }

  if (inferredRole && !requestedRole) {
    throw createError(400, "role must be job seeker, employer, or admin");
  }

  const user = await prisma.user.findUnique({
    where: {
      email
    },
    include: {
      jobSeekerProfile: true,
      companies: {
        take: 1,
        orderBy: {
          createdAt: "asc"
        }
      }
    }
  });

  if (!user && demoAccounts.has(email)) {
    throw createError(401, "Demo account not found. Run npm run prisma:seed, then try logging in again.");
  }

  if (!user || !user.isActive) {
    throw createError(401, "Invalid credentials");
  }

  if (requestedRole && user.role !== requestedRole) {
    throw createError(401, "Invalid credentials for this role");
  }

  const isValidPassword = await bcrypt.compare(password, user.passwordHash);

  if (!isValidPassword) {
    throw createError(401, demoAccounts.has(email)
      ? "Invalid demo credentials. Use password demo1234 and choose the correct role."
      : "Invalid credentials");
  }

  const accessToken = signAccessToken(user);

  res.json({
    message: "Login successful",
    data: buildAuthPayload(user, accessToken, {
      profile: serializeProfile(user.jobSeekerProfile),
      company: serializeCompany(user.companies?.[0])
    })
  });
}));

router.post("/forgot-password", validateBody(forgotPasswordSchema), asyncHandler(async (req, res) => {
  const user = await prisma.user.findUnique({
    where: {
      email: req.body.email
    }
  });

  let developmentVerificationCode;
  let emailSent = false;
  let emailDeliveryFailed = false;
  const smtpConfigured = hasSmtpConfig();
  const shouldExposeDevelopmentCode = !isProduction()
    && String(process.env.SHOW_DEVELOPMENT_RESET_CODE || "").toLowerCase() === "true";

  if (user?.isActive) {
    const code = createVerificationCode();
    const tokenHash = hashVerificationCode(user.id, code);

    await prisma.$transaction([
      prisma.passwordResetToken.deleteMany({
        where: {
          userId: user.id
        }
      }),
      prisma.passwordResetToken.create({
        data: {
          userId: user.id,
          tokenHash,
          expiresAt: getResetTokenExpiry()
        }
      }),
      prisma.auditLog.create({
        data: {
          actorUserId: user.id,
          action: "REQUEST_PASSWORD_RESET_CODE",
          targetType: "USER",
          targetId: user.id,
          metadata: {
            delivery: smtpConfigured ? "email" : "not_configured"
          }
        }
      })
    ]);

    try {
      emailSent = await sendPasswordResetEmail({
        to: user.email,
        name: user.name,
        code
      });
    } catch (error) {
      emailDeliveryFailed = true;
      console.error("Password reset email delivery failed:", {
        message: error.message,
        code: error.code,
        command: error.command,
        responseCode: error.responseCode
      });
    }

    if (shouldExposeDevelopmentCode && !emailSent) {
      developmentVerificationCode = code;
    }
  }

  res.json({
    message: "If an active account exists for that email, a verification code will be sent.",
    ...(emailSent ? { delivery: "email" } : {}),
    ...(!isProduction() && !emailSent && !smtpConfigured ? { delivery: "not_configured" } : {}),
    ...(!isProduction() && emailDeliveryFailed ? { delivery: "failed" } : {}),
    ...(developmentVerificationCode ? {
      developmentVerificationCode
    } : {})
  });
}));

router.post("/reset-password", validateBody(resetPasswordSchema), asyncHandler(async (req, res) => {
  const providedCode = String(req.body.code || req.body.token || "").trim();
  let resetToken = null;

  if (req.body.email) {
    const user = await prisma.user.findUnique({
      where: {
        email: req.body.email
      }
    });

    if (user) {
      resetToken = await prisma.passwordResetToken.findUnique({
        where: {
          tokenHash: hashVerificationCode(user.id, providedCode)
        },
        include: {
          user: true
        }
      });
    }
  } else {
    resetToken = await prisma.passwordResetToken.findUnique({
      where: {
        tokenHash: hashResetToken(providedCode)
      },
      include: {
        user: true
      }
    });
  }

  if (!resetToken || resetToken.usedAt || resetToken.expiresAt < new Date() || !resetToken.user?.isActive) {
    throw createError(400, "Verification code is invalid or expired");
  }

  const passwordHash = await bcrypt.hash(req.body.password, 12);

  await prisma.$transaction([
    prisma.user.update({
      where: {
        id: resetToken.userId
      },
      data: {
        passwordHash
      }
    }),
    prisma.passwordResetToken.update({
      where: {
        id: resetToken.id
      },
      data: {
        usedAt: new Date()
      }
    }),
    prisma.passwordResetToken.updateMany({
      where: {
        userId: resetToken.userId,
        usedAt: null,
        id: {
          not: resetToken.id
        }
      },
      data: {
        usedAt: new Date()
      }
    }),
    prisma.auditLog.create({
      data: {
        actorUserId: resetToken.userId,
        action: "RESET_PASSWORD",
        targetType: "USER",
        targetId: resetToken.userId
      }
    })
  ]);

  res.json({
    message: "Password reset successful. Please sign in with your new password."
  });
}));

router.get("/me", requireAuth, asyncHandler(async (req, res) => {
  const user = await prisma.user.findUnique({
    where: {
      id: req.user.id
    },
    include: {
      jobSeekerProfile: true,
      companies: {
        take: 1,
        orderBy: {
          createdAt: "asc"
        }
      }
    }
  });

  res.json({
    data: {
      user: serializeUser(user),
      profile: serializeProfile(user.jobSeekerProfile),
      company: serializeCompany(user.companies?.[0]),
      role: user.role,
      email: user.email,
      displayName: user.name
    }
  });
}));

router.post("/logout", (_req, res) => {
  // JWT access tokens are stateless in this MVP. Logout is completed on the
  // client by deleting the stored token; server-side revocation can be added
  // later with token versioning or a short-lived token + refresh-token design.
  res.json({
    message: "Logged out successfully"
  });
});

module.exports = router;
