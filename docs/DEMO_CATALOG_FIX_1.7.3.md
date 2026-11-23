# Career Bridge 1.7.3+31 — demo consistency correction

**Scope:** changed Flutter source only. No Android build has been performed in this environment. The earlier 1.7.2 APKs are unchanged and still have the old behavior.

## Important distinction

There are **20 fictional Job Seekers, 12 fictional Employers (32 fictional accounts total), 12 fictional companies, and 20 published fictional public job postings**. These are not actual Firestore users, employers or job ads. The eleventh approved sample company, NovaTech, has three sample public jobs. Orbit Labs stays pending and its jobs do not appear in public search. Admin may show additional pending/draft/closed jobs, each labelled by status. A live Firebase deployment will continue to show the actual number of registered accounts, real company records and published job records until separately populated through legitimate workflows.

## Changes

- Single `DemoShowcaseCatalog` gives all public demo views one shared 12-company / 20-public-job identity set. The public Landing/Jobs/Companies screens offer a guest-only **Live / Demo Preview** switch when real Firebase is active; Demo Preview shows all 20 sample jobs and 12 sample companies without changing Firebase. The landing showcase now lists all 20 in demo mode, full company directory and landing companies section list all 12, and demo statistics explicitly say **Demo** (not Live/Verified).
- Admin maintains **real Firebase authentication** (no admin demo login). For a real admin, a new, explicitly labelled **Demo** switch at the top of protected Admin screens changes between live data and locally isolated sample data. The Firebase Admin demo preview is **read-only**, and never writes fictional accounts to Firebase; use Live for actual moderation. Real signed-in job seekers cannot submit applications for sample-only jobs. The preview Admin repository uses the same 32 accounts and company IDs as the public catalog, and seeds job statuses directly from the demo Employer repository. Switching sources refreshes the complete snapshot.
- Sample Employer workspaces, Admin previews and public demo job listings use the same published job IDs and company-owner IDs. Pending/unapproved Orbit jobs stay off public pages. Existing nonpublic draft/pending/closed employer jobs stay internal and explain different totals across screens.
- The first demo Job Seeker's saved-job IDs, applications and company identities now refer to published demo jobs and companies instead of removed legacy company listings.
- The Admin Categories navigation entry and misleading category-count health indicator are hidden; working job category search filters remain available. The direct category-edit screen has responsive action layout and a less truncated icon field if reached via a legacy route.
- Added `demo_showcase_consistency_test.dart` to check 20 seekers, 12 employers, 20 public jobs, 12 companies, IDs/ownership consistency, approval states and exact alignment of published listings across Employer/Admin/Public. Updated the legacy Admin test that expected two pending sample employers (the current catalog has one).

## What should and should not match

| View | Expected sample data |
|---|---|
| Demo public Jobs list and Landing Jobs section | 20 published sample jobs (unfiltered) |
| Demo public Companies list and Landing Companies section | 12 fictional companies (including pending Orbit, explicitly unverified) |
| Admin Demo preview → Users | 32 demo accounts = 20 seekers + 12 employers |
| Admin Demo preview → Companies | 12 demo companies |
| Admin Demo preview → Job Approvals | 20 published jobs **plus** separate pending/draft/closed postings |
| Each Employer demo workspace | Only that employer's own jobs, including nonpublic statuses |
| Real Admin / public Firebase views | Genuine Firestore records; **not 32/12/20 unless the database actually contains them** |

## Build and verify

Run `flutter analyze`, `flutter test --concurrency=1` and `bash scripts/build_android_apps.sh release` with a recent stable Flutter SDK, JDK 17+ and Android SDK. Alternatively launch the GitHub Actions workflow `.github/workflows/build-careerbridge-apks.yml` after setting the `CAREER_BRIDGE_FIREBASE_CONFIG_JSON` repository secret to the local client JSON (gitignored). It uploads both ARM64 APKs after verification. **Neither Flutter nor Android SDK was available to execute locally here**, so the source has not been compile-verified, tested on a device or delivered as new APKs.

IMPORTANT: GitHub-hosted runners create a fresh debug signing identity unless you provide/persist your own signing key. Since the existing 1.7.2 APKs are signed with a different local debug key, an APK built in GitHub Actions may not update the old app in-place. Back up any unsynced app data; if an install gives `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, uninstall the old version and reinstall the new one. Production Firestore changes are **not** part of this patch.
