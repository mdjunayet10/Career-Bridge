# Career Bridge 1.7.2+30 — navigation, CV photo, account and demo refinements

2026-11-01. This release retains the earlier Profile/Company Profile fourth-position navigation, compact CV spacing, owner data, and separate User/Admin Android variants. Earlier version reports remain historical.

## Requested changes

1. **Navigation alignment and spacing.** Job Seeker, Employer, and Admin workspaces use consistent spacing and alignment for their navigation items, with readable labels and correct active selections on narrow screens. Profile/Company Profile retain their established positions.
2. **Circular CV photos without distortion.** Existing saved CV records receive the same circular rendering when previewed or exported; stored photos and CV fields are not migrated or rewritten. Photo rendering preserves the original image proportions within a circular crop. Profile-photo fallback is available to the automatic CV when its own photo is empty; an explicitly chosen CV photo keeps precedence.
3. **Truthful profile completion.** The percentage includes the profile photo and checks useful values rather than accepting placeholder text or example links. Supplied projects, employment, achievements, and references need their relevant details; absent optional sections do not require invented employment or awards. Missing items are available as a readable checklist. Demo profiles are not forced to 100%; the rendered default seeker shows 82% and identifies the missing photo, useful portfolio/LinkedIn link and reference details.
4. **Remove Admin demo access.** The Admin login has no demo picker, and the former Admin demo email/password cannot authenticate through the demo repository. A sample administrator directory row is only directory data, has an invalid sample address, and supplies no login. Real administrator role checks remain in place.
5. **Animated opening for at least two seconds.** The branded introduction remains visible for a minimum of two seconds even when initialization is fast. Slow initialization can extend it, and startup failures still have an error path. Normal and reduced-motion timer/destination/disposal tests passed; physical-device timing is listed separately below.
6. **Google account app password.** Eligible users can choose **Set app password** while signed in to their verified Google account. The service checks the current Firebase UID against the signed-in app account and requires a Google provider without an existing password provider, then links an email/password credential with `linkWithCredential`. It does not create a second user, read a Google password, or replace the Google provider. Recent-login, existing-provider, credential-conflict, weak-password, and network errors receive actionable messages. Accounts with an existing password use the normal password-reset flow.

## Expanded fictional demonstrations

The public sign-in pickers now offer **20 Job Seekers and 12 Employers**, with distinct career backgrounds, profiles/CVs, companies, job data, and sample application workflows. All use `Demo123!`. Orbit Labs is the pending-verification example; the other eleven are approved sample employers. No Admin demo authentication is included. See `DEMO_ACCOUNTS_1.7.2.md` for names, emails, and usage.

Exact catalog membership selects local sample repositories, including for the newly added accounts. Demo changes do not write to live Firebase collections, and signing out restores the live repository selection. Sample public jobs are explicitly marked as sample and unverified. Employer jobs and applicant records retain the owning sample company's identity. NovaTech's demo company ID uses an asset-only alias for its original bundled logo; company and ownership IDs stay unchanged.

## Existing data and deployment scope

No database migration is required. Existing Firebase users, ownership, profile/CV records, company/job records, and application data are preserved. The release does not deploy Functions or Firestore rules and does not change authentication-provider configuration. Ordinary owner-authorized profile/CV saves and the explicit password-linking action remain separate from sample data.

The authorized live owner-account password operation was completed and verified against the existing Firebase Auth identity. The UID remained unchanged, the Google provider remained linked, a password provider was added, and an email/password sign-in succeeded. Canonical SHA-256 comparisons of all documents in `users` (13), `jobSeekerProfiles` (4), and `cvProfiles` (4) were identical before and after. This operation made no Firestore writes; it only updated authentication on the existing UID. Private verification evidence is retained separately. Passwords, owner UIDs, tokens, private snapshots, and personal account backups must not be included in this document, source packages, APK assets, or public reports.

## Verification status

Current verification evidence is recorded below. Build and runtime evidence are separate from automated test results.

| Check | Current status |
|---|---|
| Demo catalog, owner isolation, picker and session tests | Passed locally: 9 distinct targeted tests across the three demo test files; all 32 catalog logins exercised |
| Analysis of demo implementation and picker/catalog tests | Passed: no issues found |
| Full Flutter analysis | Passed: no issues found |
| Full Flutter test suite | Passed: 160 tests, 2 conditional/private-input skips; Admin mode separately passed 6 tests with 1 consumer-only skip |
| Narrow-screen navigation checks for three workspaces | Passed: 50 navigation tests including 36 combinations of three roles, 320/360/390px and 1.0/1.3/1.5/2.0 text scales |
| Circular photo/PDF and automatic photo-sync checks | Passed raster tests for both templates; stored personal profile exported and visually checked as one A4 page (126,234 bytes). Photo/profile/CV records unchanged |
| Truthful completion and missing-field checks | Passed: photo, placeholder, partial optional-section and first-time applicant cases; missing items shown on Profile |
| Minimum-two-second animated introduction checks | Passed: normal/reduced motion, restored/signed-out route and early-dispose tests in User and Admin modes |
| Guarded same-UID Google/password linking tests | Passed: matching verified Google identity, wrong/missing session, existing password, weak password, recent-login and credential-conflict cases |
| Live owner-account password linking and password sign-in | Verified: same UID, Google provider retained, password provider linked, email/password sign-in succeeded |
| Live collection/ownership preservation comparison | Verified: canonical SHA-256 unchanged for users (13), jobSeekerProfiles (4), and cvProfiles (4); no Firestore writes |
| User/Admin 1.7.2+30 Android release builds and signatures | Passed: both ARM64 release APKs built, versionCode 30/versionName 1.7.2, API24+, signature v2 verified with the same existing debug certificate. User 26,654,077 bytes; Admin 26,585,561 bytes. Final checksums recorded separately |
| Android/web runtime smoke checks | Mobile browser: 10 functional cases at 390×844 and 320×844, then 2 fresh final-build checks for logo/role labels. Final ARM64 API35 emulator: both installed APK hashes match delivered artifacts; install-update, cold startup, demo seeker login, five equal-width navigation cells at 1.3 font scale and Admin login without demo controls passed. Fresh live-site Employer demo smoke also passed. Physical-device behavior not verified |
| Source/APK package delivery | Final artifacts and full-source archive are verified by the packaging checks; generated APKs, private backups, tokens and machine caches are excluded from source ZIP |
| Hosting deployment | Deployed: careerbridgebd.web.app 1.7.2+30; four remote file hashes exactly match the final local build. Fresh live Employer demo smoke passed; see DEPLOYMENT_1.7.2.md |
| Functions/Firestore rules deployment | Not performed; outside this release's deployment scope |

Build commands and prerequisites are in `README_DELIVERY.md`. Historical 1.7.0/1.7.1 build or live-account evidence must not be presented as 1.7.2 validation.
