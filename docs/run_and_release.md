# One-time local run and release workflow

## Recommended single command

From the repository root, run:

```bash
./scripts/verify_release.sh demo
```

For configured Firebase mode:

```bash
./scripts/verify_release.sh firebase
```

To include Firestore Security Rules emulator tests:

```bash
RUN_RULES_TESTS=1 ./scripts/verify_release.sh demo
```

The script generates missing Flutter platform wrappers, runs the repository checker, formats Dart, executes `flutter analyze`, runs all Flutter tests, creates a release web build, and saves a timestamped log under `validation_logs/`.

---

This is the consolidated workflow requested for the end of the feature phases.

## Prerequisites

- Flutter stable in PATH
- Chrome
- Xcode for iOS builds
- Android Studio/SDK for Android builds
- Node.js and Java only if running Firestore emulator tests

## 1. Generate platform wrappers once

From the repository root:

```bash
./scripts/bootstrap_frontend.sh
```

The script backs up and restores the custom Career Bridge source while Flutter generates `android/`, `ios/`, and standard platform support.

## 2. Run the static repository check

```bash
python3 scripts/check_project.py
```

## 3. Run in demo mode

```bash
./scripts/run_demo.sh
```

Demo accounts:

```text
Job Seeker:      jobseeker@careerbridge.demo / Demo123!
Employer:        employer@careerbridge.demo / Demo123!
Pending Employer: pending@careerbridge.demo / Demo123!
Admin:           admin@careerbridge.demo / Admin123!
```

## 4. Run Flutter quality checks

```bash
cd frontend
flutter analyze
flutter test
```

## 5. Run Firestore Rules tests

```bash
cd backend/tests/firestore_rules
npm install
npm test
```

## 6. Configure Firebase

Follow `docs/firebase_setup_guide.md` and `docs/first_admin_setup.md`.

## 7. Run Firebase mode

```bash
./scripts/run_firebase.sh
```

## 8. Create the production web build

```bash
./scripts/build_web.sh firebase
```

## 9. Deploy

```bash
./scripts/deploy_firebase.sh
```

## Required visual checks

Review at minimum:

- 1440×900 desktop
- 1024×768 tablet/compact desktop
- 390×844 mobile
- 360×800 small mobile
- public landing and job pages
- Job Seeker workspace
- Employer workspace
- hidden Admin workspace
- long text, empty state, loading state, and validation errors
