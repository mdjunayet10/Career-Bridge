# Career Bridge

Career Bridge is a Bangladesh-focused job discovery and hiring platform with a GitHub-style dark UI and a real backend foundation. It supports job search, salary insights, job seeker authentication, employer job posting, CV applications, saved jobs, employer application review, and basic admin moderation.

## Role-Based Frontend Flows

The frontend now changes navigation, dashboards, and job actions by role:

- Public Visitor: sees landing content, public job search, salary insight preview, login/register actions, and public job details. Public visitors cannot apply, save jobs, post jobs, view applicants, or access admin tools.
- Job Seeker: sees a dedicated dashboard with profile completion, profile editing, saved jobs, applied jobs, and application status tracking. Job Seekers can apply and save jobs, but cannot post jobs or see employer/admin tools.
- Employer: sees a hiring dashboard with company profile editing, job posting, owned job management, applicant review, application status updates, private employer notes, and protected CV download. Employers do not see Apply or Save job actions.
- Admin: sees platform stats, users, companies, jobs, applications, shortlist queue, reports, company verification, user activation/deactivation, job moderation, and salary insight management.

The backend still enforces authorization. The frontend only hides controls to make the experience clearer.

## Architecture

- Frontend: static HTML, CSS, and JavaScript in `index.html`, `styles/`, and `scripts/`
- Backend: Node.js + Express in `backend/src`
- Database: PostgreSQL with Prisma ORM
- Auth: bcrypt-hashed passwords and JWT access tokens
- Uploads: multer-validated CV upload metadata stored in PostgreSQL, files stored under `backend/uploads/`
- Security: Helmet, CORS allowlist, rate limiting, request logging, validation, centralized errors, role checks, and ownership checks
- Tests: Vitest + Supertest health check by default, optional database integration suite
- CI: GitHub Actions backend workflow runs dependency install, Prisma generate, and tests from `backend/`

## Local Setup

From the repository root:

```bash
docker compose up -d db
cd backend
npm install
cp .env.example .env
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
npm run dev
```

Open:

- App: `http://localhost:4000`
- API health: `http://localhost:4000/api/health`

If Docker is not installed, create a local PostgreSQL database yourself and set `DATABASE_URL` in `backend/.env`.

If login/register shows a database error, open `http://localhost:4000/api/health`. It should return `"database":"connected"`. If it returns `"database":"unavailable"`, start PostgreSQL and run migrations/seed data before trying the demo accounts.

Homebrew PostgreSQL fallback:

```bash
brew install postgresql@16
brew services start postgresql@16
export PATH="$(brew --prefix postgresql@16)/bin:$PATH"
createdb career_bridge
psql -d postgres -c "CREATE USER career_bridge WITH PASSWORD 'career_bridge_password';"
psql -d postgres -c "ALTER DATABASE career_bridge OWNER TO career_bridge;"
cd backend
npm run prisma:migrate
npm run prisma:seed
npm run dev
```

## Environment Variables

`backend/.env.example` contains the required local configuration:

- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: secret used to sign access tokens
- `JWT_EXPIRES_IN`: token lifetime, default `8h`
- `PASSWORD_RESET_TOKEN_MINUTES`: password reset verification-code lifetime
- `FRONTEND_URL`: deployed frontend URL
- `ALLOWED_ORIGINS`: comma-separated CORS allowlist, or `*` for local development
- `RATE_LIMIT_WINDOW_MS`, `RATE_LIMIT_MAX`, `AUTH_RATE_LIMIT_MAX`
- `MAX_CV_UPLOAD_MB`: default `5`
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_SECURE`, `SMTP_USER`, `SMTP_PASS`, `SMTP_REQUIRE_TLS`, `SMTP_IGNORE_TLS`, `EMAIL_FROM`: email settings used to send password reset verification codes. `SMTP_HOST` enables SMTP; `SMTP_USER` and `SMTP_PASS` are optional for local relays.

Never commit real `.env` files.

## Demo Accounts

Seeded local accounts all use `demo1234`:

- Admin: `admin@careerbridge.com`
- Employer: `employer@careerbridge.com`
- Job seeker: `employee@careerbridge.com`

Passwords are stored as bcrypt hashes in the database.

## Backend Commands

Run these from `backend/`:

```bash
npm run dev              # start Express with nodemon
npm start                # start Express with node
npm test                 # run quick API tests
npm run prisma:generate  # generate Prisma client
npm run prisma:migrate   # apply checked-in migrations
npm run prisma:migrate:dev # create new migrations while developing schema changes
npm run prisma:seed      # seed demo data
npm run db:reset         # reset DB and rerun migrations/seed
```

Optional database integration tests:

```bash
RUN_DB_TESTS=true TEST_DATABASE_URL="postgresql://career_bridge:career_bridge_password@localhost:5432/career_bridge_test?schema=public" npm test
```

Use a separate test database because the integration suite truncates tables.

## API Overview

Auth:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`
- `GET /api/auth/me`

Jobs:

- `GET /api/jobs?q=&location=&jobType=&workplaceType=&experienceLevel=&salaryMin=&salaryMax=&companyId=&status=&page=&limit=&sort=`
- `GET /api/jobs/:id`
- `POST /api/jobs` employer only
- `PATCH /api/jobs/:id` owning employer or admin
- `PATCH /api/jobs/:id/status`
- `GET /api/jobs/:id/applications`

Applications and CVs:

- `POST /api/applications` job seeker only, multipart `cvFile`
- `GET /api/applications/me`
- `GET /api/applications` employer/admin
- `GET /api/employer/applications`
- `PATCH /api/applications/:id/status`
- `PATCH /api/applications/:id/note`
- `GET /api/applications/:id/resume`
- `GET /api/applications/:id/cv` legacy alias

Profiles, saved jobs, companies, salary insights, and admin:

- `GET/PATCH /api/profile/me`
- `GET /api/profile/:userId`
- `GET /api/saved-jobs/me`
- `POST /api/saved-jobs/:jobId`
- `DELETE /api/saved-jobs/:jobId`
- `GET /api/companies`
- `GET /api/companies/:id`
- `GET/PATCH /api/employer/company`
- `GET /api/employer/dashboard`
- `GET /api/salaries`
- `GET /api/salary-insights`
- `GET /api/admin/stats`
- `GET/PATCH /api/admin/users`
- `GET /api/admin/companies`
- `PATCH /api/admin/companies/:id/verify`
- `GET /api/admin/jobs`
- `PATCH /api/admin/jobs/:id/status`
- `GET /api/admin/applications`
- `GET /api/admin/reports`
- `POST /api/reports`
- `PATCH /api/admin/reports/:id/status`
- `POST/PATCH/DELETE /api/admin/salary-insights`

## Roles And Rules

- `JOB_SEEKER`: can update their profile, save jobs, apply to open jobs, view their own application statuses, and download their own submitted resume
- `EMPLOYER`: can create draft jobs, manage only jobs owned by their companies, view only applicants for their jobs, update application status and private notes, and download owned applicant resumes
- `ADMIN`: can view platform-wide stats, users, companies, jobs, applications, reports, verify/unverify companies, deactivate users, and moderate jobs

Duplicate applications are blocked by a database unique constraint on `jobId + applicantUserId`.

Companies must be verified by an admin before their jobs can be published as public `OPEN` listings. Unverified employer-created listings are saved as drafts and cannot be opened until verification.

Reports can be submitted by signed-in users for suspicious jobs, companies, or users. Admins can track reports as `OPEN`, `REVIEWING`, `RESOLVED`, or `DISMISSED`.

Password reset uses hashed one-time verification codes. With `SMTP_HOST` configured, Career Bridge emails a 6-digit code to the account email. The code is not shown in the browser. For isolated local demos only, `SHOW_DEVELOPMENT_RESET_CODE=true` can expose the code outside production.

## CV Uploads

CV uploads accept only `.pdf`, `.doc`, and `.docx` with matching MIME types. File size defaults to 5 MB. Stored filenames are generated safely, resume metadata is saved on the `Application` record, and raw upload folders are not publicly served. Future production storage should move to S3, Supabase Storage, Firebase Storage, or Cloudinary.

Uploaded files are ignored by git except `backend/uploads/.gitkeep`.

The Apply modal also includes an optional browser-side CV Builder. Job Seekers can upload an existing CV or fill the builder form, preview it, and attach a generated `career-bridge-cv.pdf` to the same application upload endpoint.

## Manual Test Checklist

1. Seed the database and start `npm run dev`.
2. Public visitor can view jobs and salary insights but cannot apply without login.
3. Job Seeker can login/register.
4. Job Seeker can save a job.
5. Job Seeker can apply to a job with a PDF/DOC/DOCX CV.
6. After applying, the job button changes to Applied immediately and still shows Applied after refresh.
7. Duplicate applications are blocked with a friendly already-applied message.
8. Job Seeker can apply with the optional CV Builder generated PDF.
9. Job Seeker can see application status in the dashboard.
10. Employer can login/register with company creation.
11. Employer can post a job.
12. Employer can view only own applicants.
13. Employer can update application status and save private notes.
14. Employer does not see Apply or Save buttons.
15. Admin can login.
16. Admin can see platform stats.
17. Admin can filter applications, understand the Shortlisted queue, update statuses, and download CVs when authorized.
18. Admin can manage users, verify companies, moderate jobs, update report statuses, and manage salary insights.
19. Forgot Password sends a verification code by email when SMTP is configured, then resets the password after code verification.
20. Unauthorized users cannot access restricted actions.
21. App still uses the GitHub dark UI and every button has a visible label.
22. Confirm `backend/uploads/`, `.env`, and `node_modules/` remain untracked.

## Deployment Notes

- Set a production `DATABASE_URL`, strong `JWT_SECRET`, and strict `ALLOWED_ORIGINS`.
- Run `npm ci`, `npm run prisma:generate`, and `npx prisma migrate deploy`.
- Use persistent object storage for CVs before production traffic.
- Keep `NODE_ENV=production` so stack traces are hidden.
- Do not expose `backend/uploads/` as a public static directory.
- GitHub Pages can host only the static frontend. It cannot run Express, Prisma, PostgreSQL, file uploads, or JWT-protected API routes.
- Deploy the backend separately on a Node-capable host such as Render, Railway, Fly.io, DigitalOcean App Platform, Heroku-compatible platforms, or a VPS.
- After deploying the backend, set the frontend API base URL with the `career-bridge-api-base` meta tag in `index.html`, for example `<meta name="career-bridge-api-base" content="https://your-api.example.com" />`, and add the frontend origin to `ALLOWED_ORIGINS`.
