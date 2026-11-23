# Implementation status

## Completed in milestone 1

- inspected the previous static frontend and Express/PostgreSQL backend
- separated the new code into `frontend/` and `backend/`
- preserved the previous implementation under `legacy_reference/`
- integrated the selected runner + bridge + flag logo
- created the premium responsive Flutter landing-page source
- added Firebase Hosting, Firestore rules, indexes, schemas, and role model
- documented the no-billing Firebase architecture

## Completed in milestone 2 — public job portal

- added named web/mobile routing with animated page transitions
- connected landing-page search, category cards, featured jobs, and company cards
- added responsive Job Listing and Job Details pages
- added Companies listing and Company Details pages
- added Salary Insights and focused the public portal on job discovery
- expanded realistic local demo data
- added public portal widget tests

## Completed in milestone 3 — authentication and role routing

- added Firebase Core, Firebase Authentication, and Cloud Firestore dependencies
- added app initialization boundary with demo-mode fallback
- created an authenticated user model with role, active state, company, and verification status
- created repository boundaries for authentication
- implemented a Firebase repository for:
  - session restoration
  - Email/Password sign-in
  - Job Seeker registration
  - atomic Employer user/company registration
  - password-reset email
  - sign-out
- implemented a local demo repository with seeded Job Seeker, approved Employer, pending Employer, and Admin accounts
- added Job Seeker / Employer role selection
- added responsive Job Seeker registration, Employer registration, shared login, password recovery, and hidden Admin login screens
- added role guards for:
  - `/job-seeker/dashboard`
  - `/employer/dashboard`
  - `/employer/verification-pending`
  - `/admin/dashboard`
- added role mismatch and suspended-account protection
- added employer verification routing
- added responsive dashboard shells and realistic role-dashboard foundations
- added a public Employer Portal page
- updated public navigation and employer CTAs to use working auth routes
- updated Firestore rules to support atomic Employer registration using `getAfter()`
- added authentication and role-routing widget tests

## Completed in milestone 4 — Job Seeker workspace

- added a Job Seeker workspace repository boundary with demo and Firebase implementations
- added a private career profile with computed completion strength and editable professional preferences
- added saved jobs persisted through the repository and connected them to:
  - public Job Listing cards
  - public Job Details
  - Job Seeker dashboard recommendations
  - protected Saved Jobs page
- added functional application submission from Job Details with:
  - structured CV attachment
  - cover letter validation
  - duplicate active-application protection
- added protected application history, status filtering, application details, progress timeline, employer notes, interview information, and withdrawal
- added a responsive notification center with unread counts and deep links into applications and profile
- added a structured CV Builder foundation with:
  - personal information
  - professional summary
  - skills and languages
  - education
  - experience
  - projects
  - template selection
  - desktop live preview
- replaced placeholder Job Seeker dashboard metrics with live workspace data
- added `jobSeekerProfiles` and `notifications` schemas
- tightened Firestore rules for Job Seeker profiles, CV ownership, saved jobs, and notification read state
- added Firestore indexes for duplicate-application checks and saved-job ordering

## Completed in milestone 5 — Employer workspace

- replaced the Employer dashboard placeholder with live workspace data
- added approved-company profile management with a public profile preview
- added responsive Post Job and Edit Job forms with:
  - draft saving
  - pending-review submission
  - salary validation
  - deadline selection
  - responsibilities, requirements, skills, and benefits
- added Manage Jobs with search, status filtering, applicant counts, edit actions, and job closing
- added employer job lifecycle states: draft, pending, published, rejected, and closed
- added Applicants with candidate search, job filtering, recruitment-stage filtering, and responsive candidate cards
- added Applicant Details with:
  - privacy-conscious candidate snapshots
  - cover letter
  - shared skills and experience
  - internal employer notes
  - recruitment-stage updates
  - interview scheduling
- added Interviews and Employer Notifications pages
- added Employer workspace demo and Firebase repositories
- added application-linked Job Seeker notifications when an Employer updates a candidate
- added approved-employer route protection across the complete Employer workspace
- added Firestore indexes for Employer jobs and job-specific applications
- tightened Security Rules so only approved Employers with approved companies can create/update jobs
- prevented Employer edits to Admin-controlled company verification fields
- separated private trade-license evidence into `companyVerifications/{companyId}` so public company reads cannot expose it
- added candidate snapshot fields to application creation and schema documentation

## Completed in milestone 6 — Admin workspace

- replaced the Admin dashboard placeholder with a live protected workspace
- added platform metrics, moderation queues, platform health, and audit activity
- added Employer verification review with:
  - private trade-license evidence
  - approve/reject decisions
  - decision notes
  - Employer notification and verification-status synchronization
- added Job moderation with:
  - complete listing review
  - approved-company eligibility checks
  - approve/publish
  - request changes
  - public-listing suspension
- added user management with role/search/status filtering and account suspension/reactivation
- added company management with verification visibility and company/account suspension synchronization
- added report investigation with open, in-review, resolved, and dismissed states
- added Admin-managed job categories and public-visibility controls
- added Admin-managed salary insights with range validation and public-visibility controls
- added platform settings for moderation defaults, registration availability, identity, and maintenance messaging
- added demo and Firebase Admin repositories behind a shared controller
- added Admin notifications to Employers for verification and job decisions
- added append-only `auditLogs` and Admin-only `platformSettings`
- updated Security Rules and schema documentation for the complete Admin data surface
- kept every Admin route hidden from public navigation and protected by the Admin role guard

## Completed in milestone 7 — file services and CV PDF

- added device-side CV PDF preview and export with three template palettes
- kept structured CV data as the canonical editable source
- generated an immutable PDF snapshot when a Job Seeker applies
- added application-linked `cvFileId` access for authorized Employers
- added reusable JPG/PNG/WebP picking and on-device image compression
- resized images to a maximum 1600 px longest side and normalized uploads to JPEG
- enforced a strict 2 MB final-file limit in client validation and Security Rules
- added Firestore metadata plus ordered Base64 chunk upload and reconstruction
- added SHA-256 and expected-byte-count integrity checks
- added upload state transitions, failure cleanup, deletion, and memory caching
- integrated Job Seeker profile photos and Employer company logos
- made ready company logos publicly readable while keeping profile images private
- added demo and Firebase file repositories behind a shared file controller
- added unit tests for chunk round-trips, oversize rejection, image compression, and PDF generation
- added complete schema and architecture documentation for the no-Storage file workflow

## Not run in this environment

Flutter SDK is not installed in the implementation environment, so `flutter analyze`, widget tests, browser visual checks, and release builds have not been executed. The user requested that local running wait until all feature phases are complete.


## Completed in milestone 8 — final integration and release preparation

- added explicit demo and Firebase runtime environment files
- added platform-aware Firebase options for Web, Android, and iOS through `--dart-define-from-file`
- made production Firebase startup fail visibly instead of silently showing demo data
- retained optional demo fallback only when the environment explicitly permits it
- hid demo credentials when `SHOW_DEMO_ACCESS` is false
- added clean path-based Flutter web URLs, including `/admin/login`
- added a startup diagnostics screen for invalid Firebase configuration
- added complete PWA favicon, regular icons, and maskable icons using the selected Career Bridge logo
- added one-command scripts for:
  - Flutter platform bootstrap
  - demo run
  - Firebase run
  - analyze/test/release web build
  - Firebase Rules/indexes/Hosting deployment
- added a no-Flutter static repository checker
- aligned platform category, salary-insight, and settings seed references with the Admin demo workspace
- added Firestore Rules emulator tests for critical role boundaries
- added complete Firebase setup, first-Admin setup, run/release, and university submission guides
- updated the archive to version `0.8.0+8`

## Completed in milestone 9 — live public portal and security hardening

- replaced presentation-layer demo-data reads with a shared public-portal repository boundary
- connected Firebase mode to approved companies, published jobs, active categories, active salary insights, and public platform settings
- preserved complete demo-mode review data behind the same controller
- added live category opening counts and safe fallback categories for referenced IDs
- replaced fictional public counters with counts derived from the current catalogue
- added empty states for new Firebase projects with no published content
- added maintenance and controlled demo-fallback notices to the public shell
- enforced Job Seeker and Employer registration availability in both direct-route UI and Firestore Security Rules
- normalized authentication emails before Firebase operations
- added immutable job snapshots to applications so closed listings remain understandable
- tightened public company and logo reads to approved, active, attached records
- synchronized public-catalog refreshes after relevant Employer and Admin writes in Firebase mode
- added composite indexes and Firestore Rules tests for the new public queries and registration boundaries
- added public-portal and application-snapshot Flutter test source
- updated the archive to version `0.9.0+9`

## Execution status after milestone 9

Static repository checks, JSON parsing, Dart import/delimiter checks, shell syntax checks, JavaScript syntax checks, and ZIP integrity are performed in the implementation environment. Flutter SDK and the Firebase emulator dependencies are not installed here, so `flutter analyze`, Flutter tests, browser visual review, Firestore emulator execution, and release builds still require the user's local environment.

## Next local validation workflow

1. `./scripts/bootstrap_frontend.sh`
2. `python3 scripts/check_project.py`
3. `./scripts/run_demo.sh`
4. `flutter analyze`
5. `flutter test`
6. desktop and mobile visual review
7. Firebase configuration, Rules/index deployment, and first Admin creation
8. Firebase-mode workflow test and release build



## Completed in milestone 10 — release-candidate stabilization

- removed analyzer-detectable unused local imports
- isolated in-memory private file bytes by authenticated user session
- prevented a later signed-in user from inheriting a previous user's file cache
- hardened Firestore Rules so a Job Seeker can withdraw only an active application, not a hired or rejected application
- added a matching Firestore emulator regression test
- added `scripts/verify_release.sh` for one-command platform bootstrap, formatting, analysis, Flutter tests, optional Rules tests, release web build, and timestamped logs
- strengthened the no-Flutter repository checker with final release invariants
- updated the release candidate to version `1.0.0+10`

## Execution status after milestone 10

All checks available without Flutter have been executed in the implementation environment. Flutter SDK and Firebase emulator npm packages are not installed here, so the authoritative `flutter analyze`, Flutter test run, browser/responsive visual review, Firestore emulator execution, and release build must be executed on the user's Mac with `./scripts/verify_release.sh demo`.


## Completed in UI Polish Batch 2 — companies and authentication

- replaced all bundled company badges with symbol-only logo marks and removed text-based logo fallbacks
- redesigned Companies cards with clearer hierarchy, compact company facts, and consistent opening indicators
- tightened the Companies hero, search controls, filter result summary, and responsive grid
- rebuilt Company Details with a compact identity header, clearer overview, and balanced content layout
- improved the authentication shell with a visible brand treatment, scroll-safe laptop layout, and stronger surface contrast
- redesigned role selection into responsive, feature-led Job Seeker and Employer cards
- reorganized Job Seeker and Employer registration forms into clearer sections and responsive field pairs
- updated the project to version `1.2.0+13`

## Completed in UI Polish Batch 3 — workspaces and company-logo architecture

- moved company logos to a single company-profile source of truth
- removed logo and initial fields from Job models and application snapshots
- added `companyId` to application snapshots so closed jobs can still resolve the company logo
- added a shared company-logo registry that updates every listening logo widget after replacement
- reused the same logo across public jobs, companies, Job Seeker applications, Employer profile/dashboard, and Admin review/management
- kept local symbol-only logo assets only as demo fallbacks
- replaced employer logo-letter placeholders with generic marks
- polished the responsive dashboard shell, role context, account controls, navigation, and spacing
- upgraded dashboard metrics and shared loading/error states
- added a premium Employer identity banner with logo, completion progress, and primary actions
- added Admin moderation shortcuts and company logos in moderation queues
- added unit coverage for the shared company-logo registry
- updated the project to version `1.3.0+14`


## Version 1.3.1+15 compile hotfix

- restored `_ResponsivePair` and `_VerificationBanner` in the Employer company-profile page
- removed an invalid `const Expanded(child: details)` expression
- removed two analyzer warnings introduced by the shared company-logo registry update
- verified static project structure across 160 Dart files
