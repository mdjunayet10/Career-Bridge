# Career Bridge 1.7.1 — profile, complete CV and fourth-position profile tabs

2026-11-01. This update preserves all 1.7.0 fixes and adds:

- Job Seeker order: Overview, Find Jobs, Saved Jobs, **Profile**, Applications, CV Builder, Notifications. The first four are directly visible in the mobile bottom bar; More remains fifth.
- Employer order: Overview, Post a Job, Manage Jobs, **Company Profile**, Applicants, Interviews, Notifications, Find Jobs. Company Profile is directly fourth; More fifth. Administrator navigation remains unchanged.
- Correct active selections for reordered pages and their detail screens. Narrow-screen tests use actual Sora fonts at 320/360/390 px with 1.2x text and validate label bounds and route selection.
- An opt-in **Compact spacing** CV layout. It retains readable body text and every saved section, with less whitespace. Classic export remains unchanged. The layout selection is saved with `templateId: reference-compact` and is used by preview and export.
- A reproduced Applicants job-filter dropdown overflow was corrected with expanded-width layout.

## Requested own-account data

A fresh private backup was taken before updating only the requested owner's profile/CV. The supplied JPEG was stored unmodified in the existing owner-scoped file-object/chunk format; readback SHA-256 equals the input. The profile image reference and CV photo were saved together with the revised records in one atomic commit using document-version preconditions.

The user supplied the corrections: CGPA 3.83 through sixth semester; two Chancellor Scholarships; a verified YouTube channel with 100K+ subscribers; industrial training at Kloud Technologies in 2026. Original-CV references were restored. Both scholarship issuers use **Bangladesh University of Professionals (BUP)** in full, with short descriptions. YouTube was moved from achievements to Experience. No reference phone numbers, training topics, training months or second scholarship year were invented.

Missing editable search preferences were filled from the stated location and demonstrated skills: Flutter/Software roles, Dhaka/Remote locations and On-site/Hybrid/Remote work modes. Experience years reflect content creation since the supplied 2023 start, not a claim of three years of software employment. These preferences can be changed in Profile.

The real profile's existing completion calculation reports **100%**. Its formula was not changed. Photo, references and achievements were explicitly checked in addition to the percentage. The revised production-rendered CV contains the photo, two experiences, two references, corrected education and two scholarship entries on **one A4 page**. Private photo/import/backup data are excluded from source archives and APK assets.

## Website deployment

The owner explicitly authorized hosting deployment after reviewing the APK/CV changes. Version **1.7.1+29** is now deployed to **https://careerbridgebd.web.app**. Live `release.json`, `index.html`, `main.dart.js` and `flutter_bootstrap.js` returned HTTP200 and matched the tested local build byte-for-byte. The new compact renderer and fourth-position profile navigation are included in the live bundle. Existing browser tabs may need a reload to load the new code.

Only Firebase Hosting was deployed. Functions, Firestore rules, authentication providers and the Admin Android registration were not changed. The previous Hosting release was recorded privately for rollback. See `DEPLOYMENT_1.7.1.md` for evidence and scope.

## Build and verification

Build with Flutter 3.41.7 and a working Android SDK/JDK. Install Poppler (`pdftotext`) to run the compact PDF text-preservation regression. See `README_DELIVERY.md` for build commands and unchanged Firebase/signing caveats. Final results are recorded under `validation_logs/` and the local sibling `audit/` directory.

## Recorded verification

- Full Flutter suite: **87 passed**, one separate Admin-mode test conditionally skipped in this run.
- Full analyzer: **No issues found**.
- Both ARM64 Android release builds: **succeeded**, version 1.7.1+29, signatures verified.
- Private server-readback profile/PDF regression: **100% completion**, original JPEG integrity verified, all requested sections present, **one A4 page** (126145 bytes).
- Focused navigation regressions: **13 passed**; compact/PDF/import/sync/desktop-mobile CV checks: **30 passed**.
- Fresh independent cross-review found no compact-layout persistence or navigation selection blockers.

- Dedicated Admin-mode test: **1 passed**.
- Previous version 1.7.0 build/runtime reports are historical; this document describes the current 1.7.1 behavior.

## Native smoke limitation

The final User 1.7.1 APK installed with existing data preserved and opened the signed-out public home. Android emulator System UI then stopped responding during menu interaction; testing was bounded and stopped without clearing data. Native Profile/Company Profile tab taps remain unverified. The 13 focused actual-font widget tests cover the new ordering and selections; previous 1.7.0 runtime smoke remains historical. See the local `audit/android-1.7.1/result.md` for captured screenshots.

- Web release build: **passed**; hosting deployment explicitly authorized and completed, with live byte/hash verification.
