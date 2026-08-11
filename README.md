# Career Bridge V2

Bangladesh-focused university job portal with separate Flutter frontend and Firebase backend folders.

## Product roles

- Job Seeker
- Employer
- Admin

Admin is intentionally absent from the public website. The protected entry point is `/admin/login`, and access requires Firebase Authentication, a Firestore `users/{uid}` document with `role: "admin"`, and admin-only Security Rules.

## Technology

### Frontend

- Flutter + Dart
- mobile app and responsive web from one codebase
- premium dark Career Bridge theme
- selected runner + bridge + flag logo
- role-aware navigation and route guards

### Backend

- Firebase Authentication
- Cloud Firestore
- Firestore Security Rules
- Firebase Hosting

No Cloud Functions, Firebase Storage, or billing-required service is used.

## Repository

```text
frontend/         Flutter mobile + responsive web application
backend/          Firebase rules, indexes, schemas, and configuration
legacy_reference/ previous HTML/JS and Express/Prisma source for feature reference
docs/             architecture, routes, workflows, and status
```

## Current progress

Version 1.4.0 adds Firebase Google Sign-In for the web app, including first-time Job Seeker creation, Employer company-registration completion, role-aware routing, and hardened error handling. The Firebase deployment scripts now copy the web build into the configured Hosting public directory and deploy the existing `careerbridgebd` target. Version 1.3.2 is a visual hotfix that removes the isolated hero glow beside the Bangladesh badge, increases company-card height to prevent bottom overflow on wrapped facts, and replaces low-resolution brand assets with Retina-ready versions for sharper authentication screens. Version 1.3.1 is the UI Polish Batch 3 compile hotfix. It restores the responsive company-profile helpers and fixes a non-constant widget expression found by Flutter 3.41.7. Version 1.3.0 introduced UI Polish Batch 3. It introduces a single-source company-logo architecture: Employers upload one company-profile logo, every job/application references only the company ID, and all public, Employer, and Admin views reuse the same live logo reference. It also polishes the Job Seeker, Employer, and Admin workspaces with a stronger responsive shell, premium metrics, clearer role context, improved loading/error states, Employer identity actions, and Admin moderation shortcuts.

The app runs in demo mode by default so every role can be reviewed before Firebase is configured. Firebase mode uses the same screens with live Firestore data. Start with `./scripts/verify_release.sh demo` or `docs/run_and_release.md`, then read `docs/ui_polish_batch_3.md`, `docs/firebase_setup_guide.md`, and `docs/first_admin_setup.md`.
