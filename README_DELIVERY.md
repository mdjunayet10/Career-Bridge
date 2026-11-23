# Latest delivery: 1.7.5+33

See [live workflow release notes](docs/live-workflows-release.md) and [build setup](docs/reporting-release.md) for user reports, live Admin moderation, responsive fixes and portable build setup. Final artifacts: `output/apk/Career-Bridge-User-Latest.apk`, `output/apk/Career-Bridge-Admin-Latest.apk`, `output/Career-Bridge-Latest-Full-Source.zip`.

The notes below describe the preceding delivery and remain as project history.

> **Current source patch:** Career Bridge 1.7.3+31 demo consistency fixes. Read `BUILD_1.7.3_README.md` and `docs/DEMO_CATALOG_FIX_1.7.3.md`. Older 1.7.2 build reports below are historical and do not validate this revision.

# Career Bridge 1.7.2+30 — User and Admin Android apps

This is the complete updated Flutter/Firebase source, including Android/iOS/web scaffolding, original brand assets, locally bundled UI/PDF fonts, tests and the prepared notification backend.

This revision improves navigation spacing in all three workspaces, keeps CV photos circular without distortion, makes profile completion reflect missing details, removes Admin demo access, adds an animated opening of at least two seconds, and lets eligible Google users set an app password on their existing account. It also provides 20 fictional Job Seeker and 12 fictional Employer accounts in compact login pickers. See `docs/UPDATE_1.7.2.md` for the current scope and verification status.

## Build

Tested with Flutter 3.41.7 / Dart 3.11.5 and JDK 23.0.2. Configure a working Android SDK and Java installation first. The compact PDF regression also uses Poppler (`pdftotext`). The supplied `frontend/config/firebase.local.json` and `frontend/android/app/google-services.json` contain this project's client configuration; they are not server credentials. Never put Firebase Admin credentials into an APK.

```sh
cd frontend
flutter pub get
dart format .
flutter analyze
flutter test --concurrency=1
cd ..
bash scripts/build_android_apps.sh release
```

The build script produces the User and Admin ARM64 APKs under `output/apk/`. Both use the existing debug signing configuration for university demonstration; configure a private release signing identity before store distribution. The User package is `com.careerbridge.career_bridge`, and the Admin package is `com.careerbridge.career_bridge.admin`. Android 7.0/API 24 or later and an ARM64 device are required for these delivered builds.

For an explicit single build:

```sh
cd frontend
flutter build apk --release --flavor user --target-platform android-arm64 --dart-define-from-file=config/firebase.local.json
flutter build apk --release --flavor admin --target-platform android-arm64 --dart-define-from-file=config/firebase.local.json --dart-define=ADMIN_APP=true
flutter test --dart-define=ADMIN_APP=true test/admin_app_flow_test.dart
```

The distinct Admin package still needs its own Firebase Android registration/configuration for a fully validated native setup. Current email/password/Firestore initialization uses explicit project options. Admin role/security rules are enforced; having the APK grants no administrator role.

## Demonstration

Choose a fictional account from the login screen’s demo picker, then select **Use** to fill its credentials. There are 20 Job Seeker and 12 Employer accounts; all use `Demo123!`. Orbit Labs is the pending Employer example. No Admin demo login is supplied. These sessions use local sample repositories and do not create Firebase accounts. Sign out to return to live login. See `docs/DEMO_ACCOUNTS_1.7.2.md` for the complete list.

## Notifications

Client, preference/token security rules, approved-job trigger/outbox and regression tests are supplied. Functions and security rules were **not deployed**. Until authorized deployment and end-to-end verification, do not expect automatic production push delivery. See `docs/NOTIFICATIONS_SETUP.md`.

## CV and account

The app retains the classic and optional compact CV spacing, configurable sections/photo, and multipage support. CV photos use circular clipping and preserve image proportions. Profile completion now lists the required or supplied details still missing; demo content is not forced to 100%. Existing user records and ownership are preserved, and no database migration is required. Personal CV/import/backup files and password values must remain outside source archives and APK assets.

An eligible user signed in with verified Google credentials can choose **Set app password** to link email/password sign-in to that same Firebase UID. Google sign-in remains available. A Google password is never requested or copied. Linking requires a matching current identity; accounts with an existing password use the normal password-reset flow. The authorized live owner-account password link was verified on the same UID: Google sign-in was retained, email/password sign-in succeeded, and before/after comparisons of the users/profile/CV collections were unchanged. No password values, authentication tokens or owner UIDs are included in the release verification reports.

Current 1.7.2 checks, build/package status, and live-account verification are recorded in `docs/UPDATE_1.7.2.md`; pending items must be completed before claiming delivery. `docs/FINAL_ANDROID_REPORT.md`, `docs/UPDATE_1.7.1.md`, and `docs/CHANGELOG_1.7.0.md` are historical reports for their named versions. Build caches, node_modules, machine-specific local.properties, personal account backups and generated APKs are omitted from the source archive. Run the commands above to regenerate outputs.
