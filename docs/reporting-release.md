# Reporting release 1.7.4+32

Job and company details expose reporting to signed-in active users. Reports use existing Firestore `reports` records with reporter, target, reason, optional description, server submission time and open status. One report per reporter/type/target is enforced by deterministic IDs and create-only user permissions. Admin Live subscribes to actual reports; existing Demo Preview stays separate. Admin review, resolve and dismiss retain their existing persistent status/audit behavior.

Admin action buttons wrap whole controls instead of sharing insufficient row widths. Filters expand within bounds and stack on smaller phones; reports keep target/status readable; note dialogs scroll with keyboard and small viewports. Existing horizontally scrollable Users table remains available.

## Build from the source ZIP

Install Flutter and Java 21/Android SDK. Copy `frontend/config/firebase.example.json` to `frontend/config/firebase.local.json` and populate your Firebase public client settings. No service account is needed for client builds. The Android build script generates missing `google-services.json` from these settings. Preserve the correct registered package `com.careerbridge.career_bridge`; Admin uses the existing `.admin` flavor and explicit FirebaseOptions.

Run `bash scripts/build_android_apps.sh release` for universal User/Admin APKs, or `bash scripts/build_web.sh firebase` for the site. Existing release builds use the project's existing debug signing configuration; use your own release signing key for store publication. No private key or signing credential is included in the ZIP.

Hosting site `careerbridgebd` belongs to existing project `career-bridge-dd01c`. Root firebase.json includes Hosting and Firestore rules only; deployment uses `firebase deploy --only hosting,firestore:rules --project career-bridge-dd01c`. Collection contents and authentication users are not replaced.
