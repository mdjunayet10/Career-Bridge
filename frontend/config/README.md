# Runtime configuration

Career Bridge uses compile-time environment files so Firebase values do not have to be hardcoded in Dart source.

## Demo mode

`config/demo.json` is committed and safe to use:

```bash
flutter run -d chrome --dart-define-from-file=config/demo.json
```

## Firebase mode

1. Copy `firebase.example.json` to `firebase.local.json`.
2. Replace every `REPLACE_...` value with the settings shown in Firebase Console → Project settings → Your apps.
3. Never commit `firebase.local.json`.
4. Run:

```bash
flutter run -d chrome --dart-define-from-file=config/firebase.local.json
```

The same file can contain Web, Android, and iOS app identifiers. Career Bridge selects the correct values for the current platform.
