import request from "supertest";
import crypto from "node:crypto";
import { describe, it, expect, beforeAll, afterAll } from "vitest";

process.env.NODE_ENV = "test";
process.env.JWT_SECRET = process.env.JWT_SECRET || "career-bridge-test-secret";
process.env.SHOW_DEVELOPMENT_RESET_CODE = "true";

if (process.env.TEST_DATABASE_URL) {
  process.env.DATABASE_URL = process.env.TEST_DATABASE_URL;
}

const bcrypt = (await import("bcryptjs")).default;
const createApp = (await import("../src/app.js")).default;
const prisma = (await import("../src/db/prisma.js")).default;

const app = createApp();
const shouldRunDbTests = process.env.RUN_DB_TESTS === "true" && Boolean(process.env.TEST_DATABASE_URL);
const describeDb = shouldRunDbTests ? describe : describe.skip;

async function login(email, password, role) {
  const response = await request(app)
    .post("/api/auth/login")
    .send({ email, password, role });

  expect(response.status).toBe(200);
  return response.body.data.accessToken;
}

function hashResetToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

describe("Career Bridge API", () => {
  it("returns health information", async () => {
    const response = await request(app).get("/api/health");

    expect([200, 503]).toContain(response.status);
    expect(["ok", "error"]).toContain(response.body.status);
    expect(response.body.database).toBeTruthy();
  });
});

describeDb("Career Bridge database-backed flows", () => {
  let employerToken;
  let otherEmployerToken;
  let seekerToken;
  let adminToken;
  let jobId;

  beforeAll(async () => {
    await prisma.$executeRawUnsafe(`
      TRUNCATE TABLE
        "PasswordResetToken",
        "AuditLog",
        "Report",
        "SavedJob",
        "Application",
        "Job",
        "SalaryInsight",
        "Company",
        "JobSeekerProfile",
        "User"
      RESTART IDENTITY CASCADE
    `);

    const passwordHash = await bcrypt.hash("demo1234", 12);
    const [admin, employer, otherEmployer, seeker] = await Promise.all([
      prisma.user.create({
        data: {
          name: "Admin",
          email: "admin.test@careerbridge.com",
          passwordHash,
          role: "ADMIN"
        }
      }),
      prisma.user.create({
        data: {
          name: "Employer",
          email: "employer.test@careerbridge.com",
          passwordHash,
          role: "EMPLOYER"
        }
      }),
      prisma.user.create({
        data: {
          name: "Other Employer",
          email: "other-employer.test@careerbridge.com",
          passwordHash,
          role: "EMPLOYER"
        }
      }),
      prisma.user.create({
        data: {
          name: "Job Seeker",
          email: "seeker.test@careerbridge.com",
          passwordHash,
          role: "JOB_SEEKER",
          jobSeekerProfile: {
            create: {
              headline: "Test candidate"
            }
          }
        }
      })
    ]);

    const [company] = await Promise.all([
      prisma.company.create({
        data: {
          ownerUserId: employer.id,
          name: "Test Company",
          verified: true
        }
      }),
      prisma.company.create({
        data: {
          ownerUserId: otherEmployer.id,
          name: "Other Company",
          verified: true
        }
      })
    ]);

    const job = await prisma.job.create({
      data: {
        companyId: company.id,
        title: "Test Backend Developer",
        description: "Build tested APIs.",
        requirements: ["Node.js"],
        responsibilities: ["Write APIs"],
        location: "Dhaka",
        jobType: "Full-time",
        workplaceType: "HYBRID",
        experienceLevel: "Mid",
        salaryMin: 50000,
        salaryMax: 80000
      }
    });

    jobId = job.id;
    employerToken = await login(employer.email, "demo1234", "EMPLOYER");
    otherEmployerToken = await login(otherEmployer.email, "demo1234", "EMPLOYER");
    seekerToken = await login(seeker.email, "demo1234", "JOB_SEEKER");
    adminToken = await login(admin.email, "demo1234", "ADMIN");
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it("registers and logs in a job seeker without exposing passwordHash", async () => {
    const registerResponse = await request(app)
      .post("/api/auth/register")
      .send({
        name: "Registered Seeker",
        email: "registered-seeker.test@careerbridge.com",
        password: "demo1234",
        role: "JOB_SEEKER"
      });

    expect(registerResponse.status).toBe(201);
    expect(registerResponse.body.data.user.passwordHash).toBeUndefined();

    const loginResponse = await request(app)
      .post("/api/auth/login")
      .send({
        email: "registered-seeker.test@careerbridge.com",
        password: "demo1234",
        role: "JOB_SEEKER"
      });

    expect(loginResponse.status).toBe(200);
    expect(loginResponse.body.data.accessToken).toBeTruthy();
  });

  it("lists jobs with pagination metadata", async () => {
    const response = await request(app).get("/api/jobs?q=backend&page=1&limit=5");

    expect(response.status).toBe(200);
    expect(response.body.data.length).toBeGreaterThan(0);
    expect(response.body.page).toBe(1);
    expect(response.body.totalPages).toBeGreaterThanOrEqual(1);
  });

  it("allows an employer to create a job for their company", async () => {
    const response = await request(app)
      .post("/api/jobs")
      .set("Authorization", `Bearer ${employerToken}`)
      .send({
        title: "API Engineer",
        company: "Test Company",
        location: "Dhaka",
        type: "Full-time",
        salaryMin: 60000,
        salaryMax: 90000,
        description: "Own API endpoints.",
        requirements: ["Express", "PostgreSQL"]
      });

    expect(response.status).toBe(201);
    expect(response.body.data.company).toBe("Test Company");
  });

  it("rejects protected admin routes without a token", async () => {
    const response = await request(app).get("/api/admin/stats");

    expect(response.status).toBe(401);
  });

  it("prevents a job seeker from posting a job", async () => {
    const response = await request(app)
      .post("/api/jobs")
      .set("Authorization", `Bearer ${seekerToken}`)
      .send({
        title: "Should Not Work",
        location: "Dhaka"
      });

    expect(response.status).toBe(403);
  });

  it("prevents an employer from applying to jobs", async () => {
    const response = await request(app)
      .post("/api/applications")
      .set("Authorization", `Bearer ${employerToken}`)
      .field("jobId", String(jobId))
      .attach("cvFile", Buffer.from("%PDF-1.4\n"), {
        filename: "resume.pdf",
        contentType: "application/pdf"
      });

    expect(response.status).toBe(403);
  });

  it("allows a job seeker to apply once and blocks duplicate applications", async () => {
    const firstResponse = await request(app)
      .post("/api/applications")
      .set("Authorization", `Bearer ${seekerToken}`)
      .field("jobId", String(jobId))
      .field("applicantName", "Job Seeker")
      .field("coverLetter", "I can build APIs.")
      .attach("cvFile", Buffer.from("%PDF-1.4\n"), {
        filename: "resume.pdf",
        contentType: "application/pdf"
      });

    expect(firstResponse.status).toBe(201);
    expect(firstResponse.body.data.status).toBe("SUBMITTED");

    const duplicateResponse = await request(app)
      .post("/api/applications")
      .set("Authorization", `Bearer ${seekerToken}`)
      .field("jobId", String(jobId))
      .field("applicantName", "Job Seeker")
      .attach("cvFile", Buffer.from("%PDF-1.4\n"), {
        filename: "resume.pdf",
        contentType: "application/pdf"
      });

    expect(duplicateResponse.status).toBe(409);
  });

  it("prevents another employer from managing an application they do not own", async () => {
    const application = await prisma.application.findFirstOrThrow({
      where: {
        jobId
      }
    });

    const response = await request(app)
      .patch(`/api/applications/${application.id}/status`)
      .set("Authorization", `Bearer ${otherEmployerToken}`)
      .send({
        status: "REVIEWED"
      });

    expect(response.status).toBe(403);
  });

  it("lets owning employer and admin update application status", async () => {
    const application = await prisma.application.findFirstOrThrow({
      where: {
        jobId
      }
    });

    const employerResponse = await request(app)
      .patch(`/api/applications/${application.id}/status`)
      .set("Authorization", `Bearer ${employerToken}`)
      .send({
        status: "REVIEWED"
      });

    expect(employerResponse.status).toBe(200);
    expect(employerResponse.body.data.status).toBe("REVIEWED");

    const adminResponse = await request(app)
      .patch(`/api/applications/${application.id}/status`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({
        status: "SHORTLISTED"
      });

    expect(adminResponse.status).toBe(200);
    expect(adminResponse.body.data.status).toBe("SHORTLISTED");
  });

  it("prevents another employer from editing a job they do not own", async () => {
    const response = await request(app)
      .patch(`/api/jobs/${jobId}`)
      .set("Authorization", `Bearer ${otherEmployerToken}`)
      .send({
        title: "Hijacked Title"
      });

    expect(response.status).toBe(403);
  });

  it("saves unverified employer jobs as drafts and blocks publishing them", async () => {
    const passwordHash = await bcrypt.hash("demo1234", 12);
    const unverifiedEmployer = await prisma.user.create({
      data: {
        name: "Unverified Employer",
        email: "unverified-employer.test@careerbridge.com",
        passwordHash,
        role: "EMPLOYER",
        companies: {
          create: {
            name: "Unverified Company",
            verified: false
          }
        }
      }
    });
    const unverifiedToken = await login(unverifiedEmployer.email, "demo1234", "EMPLOYER");

    const createResponse = await request(app)
      .post("/api/jobs")
      .set("Authorization", `Bearer ${unverifiedToken}`)
      .send({
        title: "Draft Until Verified",
        location: "Dhaka",
        description: "Cannot publish yet."
      });

    expect(createResponse.status).toBe(201);
    expect(createResponse.body.data.status).toBe("DRAFT");

    const publishResponse = await request(app)
      .patch(`/api/jobs/${createResponse.body.data.id}/status`)
      .set("Authorization", `Bearer ${unverifiedToken}`)
      .send({
        status: "OPEN"
      });

    expect(publishResponse.status).toBe(403);
  });

  it("returns admin stats", async () => {
    const response = await request(app)
      .get("/api/admin/stats")
      .set("Authorization", `Bearer ${adminToken}`);

    expect(response.status).toBe(200);
    expect(response.body.data.totalUsers).toBeGreaterThanOrEqual(4);
    expect(response.body.data.totalApplications).toBeGreaterThanOrEqual(1);
  });

  it("creates a report and lets admin update report status", async () => {
    const createResponse = await request(app)
      .post("/api/reports")
      .set("Authorization", `Bearer ${seekerToken}`)
      .send({
        targetType: "JOB",
        targetId: jobId,
        reason: "This listing looks suspicious and should be reviewed."
      });

    expect(createResponse.status).toBe(201);
    expect(createResponse.body.data.status).toBe("OPEN");

    const updateResponse = await request(app)
      .patch(`/api/admin/reports/${createResponse.body.data.id}/status`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({
        status: "REVIEWING"
      });

    expect(updateResponse.status).toBe(200);
    expect(updateResponse.body.data.status).toBe("REVIEWING");
  });

  it("supports development password reset verification codes", async () => {
    const forgotResponse = await request(app)
      .post("/api/auth/forgot-password")
      .send({
        email: "seeker.test@careerbridge.com"
      });

    expect(forgotResponse.status).toBe(200);
    expect(forgotResponse.body.developmentVerificationCode).toMatch(/^\d{6}$/);

    const resetResponse = await request(app)
      .post("/api/auth/reset-password")
      .send({
        email: "seeker.test@careerbridge.com",
        code: forgotResponse.body.developmentVerificationCode,
        password: "newpass123"
      });

    expect(resetResponse.status).toBe(200);

    const newToken = await login("seeker.test@careerbridge.com", "newpass123", "JOB_SEEKER");
    expect(newToken).toBeTruthy();

    const reusedResponse = await request(app)
      .post("/api/auth/reset-password")
      .send({
        email: "seeker.test@careerbridge.com",
        code: forgotResponse.body.developmentVerificationCode,
        password: "anotherpass123"
      });

    expect(reusedResponse.status).toBe(400);
  });

  it("does not reveal whether a forgot-password email exists", async () => {
    const response = await request(app)
      .post("/api/auth/forgot-password")
      .send({
        email: "missing-user.test@careerbridge.com"
      });

    expect(response.status).toBe(200);
    expect(response.body.message).toMatch(/if an active account exists/i);
    expect(response.body.developmentVerificationCode).toBeUndefined();
    expect(response.body.developmentResetToken).toBeUndefined();
  });

  it("rejects invalid and expired password reset tokens", async () => {
    const invalidResponse = await request(app)
      .post("/api/auth/reset-password")
      .send({
        token: "invalid-token-value-that-is-long-enough-for-validation",
        password: "newpass123"
      });

    expect(invalidResponse.status).toBe(400);

    const seeker = await prisma.user.findUniqueOrThrow({
      where: {
        email: "seeker.test@careerbridge.com"
      }
    });
    const expiredToken = "expired-token-value-that-is-long-enough-for-validation";
    await prisma.passwordResetToken.create({
      data: {
        userId: seeker.id,
        tokenHash: hashResetToken(expiredToken),
        expiresAt: new Date(Date.now() - 60_000)
      }
    });

    const expiredResponse = await request(app)
      .post("/api/auth/reset-password")
      .send({
        token: expiredToken,
        password: "newpass123"
      });

    expect(expiredResponse.status).toBe(400);
  });

  it("rejects invalid CV uploads", async () => {
    const response = await request(app)
      .post("/api/applications")
      .set("Authorization", `Bearer ${seekerToken}`)
      .field("jobId", String(jobId))
      .field("applicantName", "Job Seeker")
      .attach("cvFile", Buffer.from("not a cv"), {
        filename: "resume.txt",
        contentType: "text/plain"
      });

    expect(response.status).toBe(400);
  });
});
