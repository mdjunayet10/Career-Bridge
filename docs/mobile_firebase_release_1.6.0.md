# Career Bridge 1.6.0+26 mobile and Firebase release

## Changes

- Native Android Google authentication uses Google Sign-In and passes its ID token to Firebase Authentication.
- Google Services Gradle integration, Android Internet permission, production Firebase options, OAuth server client ID, and signing certificate fingerprints are configured.
- Firebase production builds cannot silently fall back to demo authentication.
- Mobile login role labels wrap. The compact dashboard header, recommendation heading, and profile-sync hint fit narrow screens.
- The existing Firebase Hosting site is `https://careerbridgebd.web.app` in project `career-bridge-dd01c`.

## Rebuild

Run `./scripts/deploy_firebase.sh` for hosting and `./scripts/build_apk.sh` for Android. The APK script uses a local staging folder to avoid Google Drive placeholder failures. Output: `output/apk/Career-Bridge-1.6.0.apk`.

The existing local signing certificate is retained for compatibility with earlier APKs. Register replacement fingerprints in Firebase before changing signing keys.

## Verification scope

Mobile widget tests exercise login, account recovery, job seeker and employer registration entry points, open-keyboard email/password submission, and dashboard layout at 320, 360, and 390 logical pixels with 120% text size. Existing CV tests exercise Profile-to-CV synchronization, layout controls, and full preview at desktop and mobile widths. These use demo repositories and do not prove real Google account authentication.

A complete Google sign-in requires an interactive Google account on a device. No user credentials are embedded in the APK or test fixtures.

## Observed release checks

- Live release metadata reports `1.6.0+26`; deployed JavaScript SHA-256 matches the locally built JavaScript. JavaScript uses no-cache headers.
- All three narrow-screen authentication widget tests passed. All six Profile/CV regression cases passed in the combined run; initial authentication tap timing failures were corrected in the test and the authentication suite rerun successfully.
- Android API 35 emulator installed the release APK and initialized Firebase.
- A separate native smoke-test entry point initialized project `career-bridge-dd01c`, received `invalid-credential` from a deliberately invalid email/password request, initialized Google Sign-In, and opened Google Play services account setup. No account was created.
- Full Google authentication with a real account and physical-device behavior remain unverified. The smoke-test entry point is confined to temporary staging and is not the distributed application entry point.
