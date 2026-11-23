# Public and protected routes

## Public

```text
/                          Landing page
/jobs                      Job listing, search, filters, sort, pagination
/jobs/:jobId               Job details
/companies                 Company listing and search
/companies/:companyId      Verified company profile and open jobs
/salary-insights           Admin-curated public salary ranges
/employers                 Employer marketing portal
/login                     Job Seeker / Employer sign-in
/register                  Account-role selection
/register/job-seeker       Job Seeker registration
/register/employer         Employer company registration
/employer/login            Employer-specific sign-in
/forgot-password           Password recovery
```

## Protected

```text
/account                          Routes the current user to the correct workspace
/job-seeker/dashboard             Job Seeker only
/employer/dashboard               Approved Employer only
/employer/verification-pending    Employer only
/admin/dashboard                  Admin only
```

## Hidden Admin entry

```text
/admin/login
```

The Admin route is never linked from public navigation. Hiding it is not considered security; Firebase Authentication, Firestore role checks, and Security Rules enforce access.

## Current data source

The public portal follows the selected runtime mode:

- **Demo mode:** realistic local jobs, companies, categories, salary ranges, and settings.
- **Firebase mode:** approved and active companies, published and active jobs, active categories, active salary insights, and `platformSettings/general` are loaded from Cloud Firestore.

Public screens never import demo data directly. They read through `PublicPortalController`, so the same interface works in both modes. See `public_portal_live_data.md`.
