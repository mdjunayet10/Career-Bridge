# Admin workspace

The Admin experience is deliberately invisible on the public website.

```text
/admin/login
   ↓ Firebase Authentication
users/{uid}.role == "admin"
   ↓ active-account and route guard
/admin/dashboard
```

Knowing an Admin URL is never treated as authorization. Firestore Security Rules enforce every Admin read and write.

## Routes

```text
/admin/dashboard
/admin/employers
/admin/jobs
/admin/users
/admin/companies
/admin/reports
/admin/categories
/admin/salary-insights
/admin/settings
```

## Responsibilities

### Employer verification

- read the public company profile
- read private `companyVerifications/{companyId}` evidence
- approve or reject with a decision note
- synchronize `companies.verificationStatus` and `users.verificationStatus`
- send an Employer notification

### Job moderation

- inspect complete listing data
- confirm the company is approved and active
- publish, request changes, or suspend a public listing
- save a moderation note and notify the Employer

### User and company management

- search/filter accounts
- suspend or reactivate protected access
- keep public company visibility aligned with account state
- never expose a public Admin-registration option

### Trust and content management

- review and resolve reports
- maintain public job categories
- maintain salary insights
- manage operational defaults

## Audit trail

Admin mutations append a record to `auditLogs`. Client rules allow Admin reads and creates but prohibit editing or deleting existing audit records.

## First real Admin account

Because public signup only supports Job Seekers and Employers, the first Admin identity is created manually:

1. Create an Email/Password user in Firebase Authentication.
2. Copy the UID.
3. Create `users/{uid}` with `role: "admin"`, `isActive: true`, and matching email.
4. Sign in only through `/admin/login`.
