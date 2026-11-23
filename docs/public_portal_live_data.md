# Live public portal data

Milestone 9 connects the public Career Bridge experience to the same Firestore records managed by Employer and Admin workspaces.

## Runtime behavior

`PublicPortalController` selects one repository after authentication initialization:

- `DemoPublicPortalRepository` for the default review environment
- `FirebasePublicPortalRepository` when `USE_FIREBASE_AUTH=true`

The presentation layer reads only from this controller. Public pages do not import job, company, category, or salary demo constants directly.

## Firestore publication rules

### Companies

A company is public only when:

```text
verificationStatus == approved
isActive == true
```

### Jobs

A job is public only when:

```text
status == published
isActive == true
```

The repository also requires its company to be present in the approved, active company result set. A stale job from a suspended company is therefore excluded from the UI even before Security Rules are considered.

### Categories and salary insights

Only documents with `isActive == true` are public. Category opening counts are calculated from the currently published jobs. If a published job references a category document that has not been created, the client creates a safe display-only fallback category from the job's category ID.

### Platform settings

The public app reads `platformSettings/general` for:

- platform name and support email
- maintenance-mode banner
- Job Seeker registration availability
- Employer registration availability

The settings document must never contain secrets. Security Rules allow public reads but Admin-only writes.

## Registration enforcement

Registration availability is checked twice:

1. Direct registration routes show an unavailable screen when the relevant flag is disabled.
2. Firestore Security Rules reject creation of the corresponding `users/{uid}` record.

The second layer is authoritative; hiding a form is not treated as security.

## Application history

Each new application stores a limited immutable job snapshot:

- title
- company name and initial
- location
- employment type
- salary label

This keeps Job Seeker and Employer history understandable after the original listing becomes closed, suspended, or otherwise non-public. The snapshot intentionally excludes private company data.

## Refresh behavior

In Firebase mode, successful Employer or Admin actions that can alter public content trigger a best-effort public-catalog refresh:

- company profile changes
- job status changes
- Employer verification
- job moderation
- company activation or suspension
- category and salary insight updates
- platform setting changes

A refresh failure does not roll back a moderation or Employer write that already succeeded. The public catalogue retries on the next app start or refresh.

## Required indexes

The queries depend on the composite indexes in:

```text
backend/firebase/firestore.indexes.json
```

Deploy Rules and indexes before running Firebase mode:

```bash
cd backend/firebase
firebase deploy --only firestore:rules,firestore:indexes
```
