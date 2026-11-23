# Firebase backend configuration

Career Bridge uses only services that work without adding a Google Cloud billing account:

- Firebase Authentication — Email/Password
- Cloud Firestore
- Firestore Security Rules
- Firebase Hosting

It does not use Cloud Functions or Firebase Storage.

## Authentication model

- Job Seekers and Employers register from the Flutter app.
- Admin accounts are provisioned manually in Firebase Authentication and Firestore.
- `users/{uid}.role` is the authorization source.
- `users/{uid}.isActive` can suspend access.
- Employer access also depends on `verificationStatus`.

## Atomic Employer registration

The Flutter repository creates `users/{uid}` and `companies/{uid}` in one Firestore batch. The rules use `getAfter()` to validate that the new user becomes an active Employer in the final state.

## Final manual setup

1. Create/select the Firebase project without adding billing.
2. Enable Email/Password Authentication.
3. Register Android, iOS, and Web apps.
4. Fill `frontend/config/firebase.local.json` from the Firebase app settings.
5. Replace `.firebaserc.example` with `.firebaserc` and the real project ID.
6. Deploy Firestore Rules and indexes.
7. Create the first Admin account manually.

Full instructions: `../../docs/firebase_setup_guide.md` and `../../docs/first_admin_setup.md`.
