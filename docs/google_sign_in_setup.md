# Google Sign-In setup

Web uses Firebase's Google popup. Android uses native Google Sign-In and exchanges its ID token for a Firebase credential.

For the deployed site, open Firebase Console and go to:

`Authentication > Settings > Authorized domains`

Add:

- `careerbridgebd.web.app`
- `careerbridgebd.firebaseapp.com`
- `localhost` (for local testing)

The app uses Firebase project `career-bridge-dd01c`. The hosting domain must be authorized in that same project.

## Android release

Build with `./scripts/build_apk.sh` from the repository root. This validates production Firebase configuration and builds in a local staging folder to avoid Google Drive placeholder timeouts.

- Package: `com.careerbridge.career_bridge`.
- Apply the Google Services Gradle plugin and include `android/app/google-services.json`.
- Register the APK signing certificate's SHA-1 and SHA-256 in the matching Firebase Android app. Refresh `google-services.json` after changing fingerprints.
- `GOOGLE_WEB_CLIENT_ID` must match the type-3 OAuth client in that file. The Android client must match the package and signing certificate.
- Enable Google and email/password providers in Firebase Authentication.
- Production builds disable automatic demo fallback. Explicit demo accounts remain available; choosing one uses sample repositories until sign-out. Firebase startup errors remain visible instead of silently switching repositories.

The current APK retains the existing local signing key for update compatibility. A future signing-key change requires registering its fingerprints before distribution.
