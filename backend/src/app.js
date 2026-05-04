const path = require("path");
const cors = require("cors");
const express = require("express");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const morgan = require("morgan");
const multer = require("multer");

const adminRouter = require("./routes/admin");
const applicationsRouter = require("./routes/applications");
const authRouter = require("./routes/auth");
const companiesRouter = require("./routes/companies");
const employerRouter = require("./routes/employer");
const jobsRouter = require("./routes/jobs");
const profileRouter = require("./routes/profile");
const reportsRouter = require("./routes/reports");
const salariesRouter = require("./routes/salaries");
const savedJobsRouter = require("./routes/savedJobs");
const prisma = require("./db/prisma");
const { ApiError } = require("./utils/apiError");
const { isZodError } = require("./middleware/validate");

const frontendRoot = path.resolve(__dirname, "../..");

function parseAllowedOrigins() {
  const rawValue = process.env.ALLOWED_ORIGINS || process.env.CLIENT_ORIGIN || "*";
  const values = rawValue
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);

  return values.length ? values : ["*"];
}

function buildCorsOptions() {
  const allowedOrigins = parseAllowedOrigins();

  if (allowedOrigins.includes("*")) {
    return {
      origin: true,
      credentials: false
    };
  }

  return {
    origin(origin, callback) {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error("Not allowed by CORS"));
    }
  };
}

function createLimiter(windowMs, max) {
  return rateLimit({
    windowMs,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
      message: "Too many requests. Please try again shortly."
    }
  });
}

function createApp() {
  const app = express();
  const rateLimitWindowMs = Number(process.env.RATE_LIMIT_WINDOW_MS || 60_000);
  const rateLimitMax = Number(process.env.RATE_LIMIT_MAX || 240);
  const authRateLimitMax = Number(process.env.AUTH_RATE_LIMIT_MAX || 30);

  if (String(process.env.TRUST_PROXY || "false").toLowerCase() === "true") {
    app.set("trust proxy", 1);
  }

  app.disable("x-powered-by");
  app.use(helmet({
    crossOriginResourcePolicy: {
      policy: "same-site"
    },
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'", "'unsafe-inline'", "https://cdnjs.cloudflare.com"],
        styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com", "https://cdnjs.cloudflare.com"],
        fontSrc: ["'self'", "https://fonts.gstatic.com", "https://cdnjs.cloudflare.com", "data:"],
        imgSrc: ["'self'", "data:", "blob:"],
        connectSrc: ["'self'", "http://localhost:*", "http://127.0.0.1:*"],
        frameSrc: ["'self'", "blob:"],
        objectSrc: ["'none'"]
      }
    }
  }));
  app.use(cors(buildCorsOptions()));

  if (process.env.NODE_ENV !== "test") {
    app.use(morgan(process.env.MORGAN_FORMAT || "dev"));
  }

  app.use(express.json({ limit: process.env.JSON_BODY_LIMIT || "1mb" }));
  app.use(express.urlencoded({ extended: false, limit: "1mb" }));

  app.use("/api", createLimiter(rateLimitWindowMs, rateLimitMax));
  app.use("/api/auth", createLimiter(rateLimitWindowMs, authRateLimitMax));

  app.use("/scripts", express.static(path.join(frontendRoot, "scripts")));
  app.use("/styles", express.static(path.join(frontendRoot, "styles")));

  app.get("/api/health", async (_req, res) => {
    try {
      await prisma.$queryRaw`SELECT 1`;
      const demoUserCount = await prisma.user.count({
        where: {
          email: {
            in: ["admin@careerbridge.com", "employer@careerbridge.com", "employee@careerbridge.com"]
          }
        }
      });

      res.json({
        status: "ok",
        message: "Career Bridge backend is running",
        database: "connected",
        seededDemoAccounts: demoUserCount === 3
      });
    } catch (error) {
      res.status(503).json({
        status: "error",
        message: "Backend is running, but PostgreSQL is not ready. Start the database, run migrations, and seed demo accounts.",
        database: "unavailable",
        code: error.code || "DATABASE_UNAVAILABLE"
      });
    }
  });

  app.use("/api/auth", authRouter);
  app.use("/api/jobs", jobsRouter);
  app.use("/api/applications", applicationsRouter);
  app.use("/api/employer", employerRouter);
  app.use("/api/profile", profileRouter);
  app.use("/api/reports", reportsRouter);
  app.use("/api/saved-jobs", savedJobsRouter);
  app.use("/api/companies", companiesRouter);
  app.use("/api/salaries", salariesRouter);
  app.use("/api/salary-insights", salariesRouter);
  app.use("/api/admin", adminRouter);

  app.get("/", (_req, res) => {
    res.sendFile(path.join(frontendRoot, "index.html"));
  });

  app.use((req, res) => {
    res.status(404).json({
      message: "Route not found",
      path: req.originalUrl
    });
  });

  app.use((error, _req, res, _next) => {
    if (error instanceof multer.MulterError) {
      const message = error.code === "LIMIT_FILE_SIZE"
        ? "CV size must be 5MB or smaller"
        : error.message;

      res.status(400).json({ message });
      return;
    }

    if (isZodError(error)) {
      res.status(400).json({
        message: "Validation failed",
        details: error.issues
      });
      return;
    }

    if (error instanceof ApiError || error.statusCode) {
      res.status(error.statusCode || 500).json({
        message: error.message,
        ...(error.details ? { details: error.details } : {})
      });
      return;
    }

    if (error.code === "P2002") {
      res.status(409).json({
        message: "A record with this unique value already exists"
      });
      return;
    }

    if (error.code === "P2025") {
      res.status(404).json({
        message: "Record not found"
      });
      return;
    }

    if (["P1000", "P1001", "P1002", "P1003", "P1012", "P1017"].includes(error.code)) {
      res.status(503).json({
        message: "Database is not available. Start PostgreSQL, check DATABASE_URL, then run Prisma migrate and seed."
      });
      return;
    }

    if (["P2021", "P2022"].includes(error.code)) {
      res.status(500).json({
        message: "Database tables are missing or out of date. Run npm run prisma:migrate and npm run prisma:seed."
      });
      return;
    }

    console.error("Unhandled error:", error);

    res.status(500).json({
      message: "Internal server error",
      ...(process.env.NODE_ENV === "production" ? {} : { stack: error.stack })
    });
  });

  return app;
}

module.exports = createApp;
