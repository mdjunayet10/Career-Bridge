# Validation report — 2026-08-06

Release candidate: `1.0.0+10`

## Executed in the implementation environment

- repository integrity checker
- required-file checks
- all relative and `package:career_bridge` import target checks
- Dart delimiter balance scan across 157 source files
- unused local-import heuristic
- JSON parsing and seed-ID checks
- demo job/company reference consistency
- web manifest icon reference checks
- PNG signature and dimension checks
- shell syntax checks for every script
- Node syntax check for the Firestore Rules test source
- Python syntax check for the repository checker
- architecture checks confirming no Cloud Functions or Firebase Storage dependency
- final security invariants for session-isolated file cache and active-only application withdrawal

## Not executable in this environment

The Flutter SDK is not installed, and the Firebase emulator npm packages are not cached. Therefore these remain authoritative local checks:

- `flutter analyze`
- `flutter test`
- browser and responsive visual review
- Firestore Emulator Rules test execution
- `flutter build web --release`

Run all Flutter checks and the release build on the development Mac with:

```bash
./scripts/verify_release.sh demo
```

Include Rules tests with:

```bash
RUN_RULES_TESTS=1 ./scripts/verify_release.sh demo
```
