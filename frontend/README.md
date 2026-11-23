# Career Bridge Frontend

Flutter source for the mobile app and responsive web experience.

## Milestone 10: release-candidate stabilization

Implemented across the completed feature phases:

- premium responsive public job portal
- Job Seeker workspace, applications, notifications, and CV Builder
- Employer portal, jobs, applicants, interview pipeline, and company profile
- hidden Admin login and complete moderation workspace
- device-side CV PDF generation
- image compression and 2 MB Firestore chunk storage
- compile-time demo/Firebase configuration
- clean path-based web URLs such as `/admin/login`
- startup diagnostics instead of a blank screen when Firebase config is invalid
- live Firestore-backed public jobs, companies, categories, salary guides, and settings
- public registration availability enforced in both UI and Security Rules
- immutable application job snapshots for closed or suspended listings
- PWA icons and manifest

## One-command local verification

From the repository root:

```bash
./scripts/verify_release.sh demo
```

This generates missing platform wrappers, formats the Dart source, runs static checks, Flutter analysis, tests, and a release web build. Set `RUN_RULES_TESTS=1` to include Firestore emulator tests.

## Demo mode

```bash
flutter run -d chrome --dart-define-from-file=config/demo.json
```

## Firebase mode

Copy `config/firebase.example.json` to `config/firebase.local.json`, replace the placeholders, then run:

```bash
flutter run -d chrome --dart-define-from-file=config/firebase.local.json
```

`firebase.local.json` is ignored by Git.

## Final quality commands

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release --dart-define-from-file=config/firebase.local.json
```

See `../docs/run_and_release.md`.
