# Career Bridge architecture

```text
Career-Bridge-V2/
├── frontend/        Flutter mobile + responsive web
├── backend/         Firebase rules, indexes, schemas, tests
├── docs/            Architecture and workflows
└── legacy_reference Previous implementation kept only for reference
```

## Runtime architecture

```text
Flutter app/web
   ├── Public portal
   ├── Job Seeker workspace
   ├── Employer workspace
   ├── hidden Admin panel
   ├── Firebase Authentication
   ├── repository-based Cloud Firestore access
   ├── device-side image compression
   ├── device-side PDF generation
   └── Firestore chunk upload for files up to 2 MB

Firebase backend
   ├── Auth identities
   ├── Firestore data
   ├── Security Rules authorization
   └── Hosting for Flutter web build
```

No Cloud Functions or Firebase Storage are used.

## Frontend boundaries

```text
presentation pages/widgets
        ↓
feature controller
        ↓
repository interface
        ↓
demo repository or Firebase repository
```

The Job Seeker, Employer, and Admin workspaces follow this boundary, keeping Firestore code out of widgets.

## Current Firestore collections

```text
users
jobSeekerProfiles
companies
companyVerifications
jobs
savedJobs
applications
cvProfiles
notifications
reports
categories
salaryInsights
platformSettings
auditLogs
fileObjects/{fileId}/chunks
```

Private role data is protected by both route guards and Firestore Security Rules. Hiding a route is never treated as authorization.


## Runtime environments

Career Bridge has two explicit compile-time modes:

- `frontend/config/demo.json` — local review with seeded repositories
- `frontend/config/firebase.local.json` — real Firebase Authentication and Firestore

The production configuration disables demo fallback and demo credentials. Firebase values are supplied with `--dart-define-from-file`, while `.gitignore` prevents the local configuration from entering source control.

## Web routing

Flutter Web uses path URL strategy so routes remain professional and direct:

```text
/jobs
/employer/dashboard
/admin/login
```

Firebase Hosting rewrites unknown paths to `index.html`, allowing page refresh and direct route entry.
