# Career Bridge 1.7.3 — corrected data and APK build

**Status: source updated, NOT compiled or installed.** 1.7.2 APK attachments are OLD and must not be presented as 1.7.3 builds.

## GitHub build (easiest)

Upload/push the contents of this folder into your Career Bridge GitHub repository (keep the folder structure). Since `frontend/config/firebase.local.json` is correctly gitignored, open repository **Settings → Secrets and variables → Actions → New repository secret**, create `CAREER_BRIDGE_FIREBASE_CONFIG_JSON` and paste the full contents of the included `frontend/config/firebase.local.json` as the secret value. Do **not** publish the local config file in a public repository. Then open the GitHub **Actions** tab, choose **Build Career Bridge User and Admin APKs**, click **Run workflow**, and after a successful run download the artifact `career-bridge-1.7.3-arm64-apks`. The zipped artifact includes User and Admin release `.apk` files. Check both apps on an ARM64 Android phone. See `docs/DEMO_CATALOG_FIX_1.7.3.md` for what has and has not been fixed and data verification rules.

## Local build

Requires a recent stable Flutter SDK, an Android SDK and JDK 17 or later.

```bash
cd frontend
flutter pub get
flutter analyze
flutter test --concurrency=1
cd ..
bash scripts/build_android_apps.sh release
```

Both APKs appear under `output/apk/`. They use debug signing for university demo builds; do not distribute as a Play Store release. Installing over the previous APK may fail if the signing certificate differs. Back up unsynced data before uninstalling.
