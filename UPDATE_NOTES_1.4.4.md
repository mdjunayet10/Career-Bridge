# Career Bridge 1.4.4+21

- Google Sign-In buttons are present at the top of both Job Seeker and Employer registration forms.
- Web builds disable the Flutter PWA service worker to prevent stale `main.dart.js` bundles.
- The page unregisters prior service workers and clears old Cache Storage entries.
- Deploy script verifies the button labels in both source and compiled bundle before publishing.
- Every deployment publishes `/release.json` so the live version can be checked independently of Safari cache.
