# Career Bridge 1.7.0+28

2026-11-01. Android demo release candidate; see `FINAL_ANDROID_REPORT.md` for evidence and incomplete runtime checks.

## Mobile interface and navigation

- Updated auth branding, responsive forms, footer, safe-area spacing, long labels and workspace components while retaining the existing dark design.
- Kept sign-in button text visible during loading and disabled repeated submission.
- Added immediate branded startup, a short intro, reduced-motion handling and restored-session role routing.
- Kept Job Seeker/Employer navigation visible on phone job lists/details; added Employer Find Jobs navigation and selected-route handling.
- Added Android root Back confirmation and workspace return behavior without stacking repeated confirmation dialogs.
- Bundled the existing Sora font family locally for offline startup.

## Separate User and Admin apps

- Added Android `user` and `admin` flavors with independent package identities and app labels.
- Added compile-time Admin mode, admin-only route enforcement and dedicated mode tests. A separate package does not grant admin privileges.
- Added `scripts/build_android_apps.sh`; retained the original User Firebase application configuration.
- Admin-specific native Firebase registration and final APK runtime checks remain outstanding. Current release signing uses the debug key and builds target ARM64.

## Authentication and account data

- Added a bounded session-restore wait and clearer cleanup/error handling when a Firebase profile cannot load.
- Awaited employer-profile creation so asynchronous failures return through the intended authentication error path.
- Preserved demo logout/repository isolation and existing role checks.
- Added owner-checked CV JSON import with preview, combined profile/CV saving and preservation of omitted fields.
- Populated the requested owner's previously missing profile/CV records using supplied facts, a private original-state backup, atomic preconditions and verified readback. No other production data or deployment was changed.

## Job alerts

- Replaced shared-topic notification behavior with real signed-in Job Seeker device registration, token refresh and stored opt-out preferences.
- Added notification channel/permission handling, pre-logout token cleanup, foreground event deduplication and queued launch/tap routing limited to valid job detail routes.
- Prepared approved live-job eligibility, role/location targeting, defensive malformed-preference handling, outbox deduplication and per-device delivery leases.
- Added scoped Firestore subscription/device ownership rules and emulator tests; documented deployment prerequisites and delivery limitations.
- Rules and Functions remain undeployed. Real-device delivery and account-switch cleanup require runtime verification; exactly-once delivery is not promised.

## Demo data and CVs

- Expanded coherent fictional companies, jobs, applications and the demo Job Seeker profile/CV without seeding production Firebase records.
- Restored licensed Latin Modern and Font Awesome PDF font assets and retained one `reference-classic` template with multipage support.
- Added PDF coverage for long names/links/projects, final-entry preservation, optional photos/sections, non-CSE fields and profile synchronization.
- Generated five sample PDFs, including an 11-page long-content example, and the supplied owner's visually checked one-page A4 CV.
- Preserved general users' content and multipage export; private personal import data is not an APK asset.

## Recorded validation

- Flutter analyzer: no issues.
- Default Flutter suite: 75 passed, one conditional Admin-mode test skipped; dedicated Admin-mode run: one passed.
- Notification backend: four passed; Firestore emulator rules: 12 passed.
- Both final User and Admin release builds succeeded; package identities and signatures verified. Both release APKs passed emulator cold-launch and fictional demo login; User Find Jobs tabs, Back and exit cancellation passed. Web release compilation passed without deployment.
- Real Google/email signup/reset, the remaining full native lifecycle/PDF-export sweep, live FCM delivery and browser interaction checks remain unverified.
