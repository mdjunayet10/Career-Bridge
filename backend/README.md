# Career Bridge Backend

This project does not use a traditional always-on server. The backend folder contains Firebase configuration, Firestore schemas, security rules, indexes, seed data, and rule tests.

## Services

- Firebase Authentication
- Cloud Firestore
- Firestore Security Rules
- Firebase Hosting

## Explicitly excluded

- Cloud Functions
- Firebase Storage
- services requiring a billing account

The previous Express/PostgreSQL implementation is preserved under `legacy_reference/express_backend` for business-logic reference only.

## Admin-managed backend data

The protected Admin workspace manages `companyVerifications`, `jobs`, `users`, `companies`, `reports`, `categories`, `salaryInsights`, and `platformSettings`. Mutations append an Admin-only, client-immutable record to `auditLogs`.

## Backend verification

The Firestore Rules emulator tests live in `tests/firestore_rules/`. They verify public-job visibility, private Job Seeker profiles, blocked public Admin creation, Employer verification boundaries, and Admin access.

Platform-owned demo values live in `firestore/seed_data/`. They do not create users or bypass role workflows.

## Firestore file service

Small images and CV PDFs use `fileObjects/{fileId}` metadata plus ordered `chunks` subcollections. Security Rules enforce the 2 MB limit, supported MIME types, role-specific file purposes, immutable metadata, ready-state reads, public company-logo access, and application-scoped Employer CV access. See `docs/file_services.md`.
