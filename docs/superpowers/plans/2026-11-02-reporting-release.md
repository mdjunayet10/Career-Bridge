# Reporting and Admin layout release

Use local 1.7.3 source and existing repositories. Shared report dialog: active signed-in users, deterministic user/type/target ID, server timestamp, reason and optional description. Samples never write to Firebase. Live Admin reports subscribe to Firestore; Demo Preview keeps its isolated records. Preserve moderation/auditing.

1. Reproduce narrow Admin actions and add rules regression tests.
2. Implement reporting submission, live updates, strict create validation and wrapping actions.
3. Verify Flutter tests/analysis and isolated Firestore emulator tests.
4. Build both release flavors and production web.
5. Deploy Hosting and rules to verified existing Firebase project/site.
6. Package source without caches/credentials and validate deliverables.

Review: spoofed reports/status, duplicate submissions, demo isolation, narrow actions, keyboard/dialog scrolling.
