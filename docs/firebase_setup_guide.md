# Firebase setup guide

Career Bridge uses Firebase Authentication, Cloud Firestore, Security Rules, indexes, and Hosting. It does not use Cloud Functions, Firebase Storage, or any billing-required deployment.

## 1. Create the Firebase project

1. Open Firebase Console.
2. Create or select the Career Bridge project.
3. Do not enable a billing account.
4. Create a Cloud Firestore database.
5. Choose the region you want to keep for the project.

## 2. Enable authentication

Firebase Console → Authentication → Sign-in method:

- enable Email/Password
- do not enable public Admin registration

## 3. Register the apps

Firebase Console → Project settings → Your apps:

- Web app
- Android app with package name `com.careerbridge.career_bridge`
- iOS app with bundle ID `com.careerbridge.app`

Copy the app IDs, API keys, project ID, sender ID, and Web auth domain.

## 4. Create the local runtime configuration

```bash
cd frontend/config
cp firebase.example.json firebase.local.json
```

Replace every `REPLACE_...` value. `firebase.local.json` is already ignored by Git.

Career Bridge reads these values with `--dart-define-from-file`; no Firebase secret is stored in Dart source.

## 5. Configure Firebase CLI

```bash
npm install -g firebase-tools
firebase login
cd backend/firebase
cp .firebaserc.example .firebaserc
```

Replace `YOUR_FIREBASE_PROJECT_ID` inside `.firebaserc`.

## 6. Deploy backend configuration

From `backend/firebase`:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## 7. Create the first Admin and platform content

Follow `docs/first_admin_setup.md` before trying `/admin/login`. Then use the Admin workspace to confirm:

- `platformSettings/general` exists
- at least one active category exists
- salary insights are added when you want that public page populated

The reference values are under `backend/firestore/seed_data/`. They are not automatically uploaded because platform content should be created through the protected Admin workflow.

Public jobs only appear after both the company and job are approved. Deploy the composite indexes before testing this flow.

## 8. Run in Firebase mode

From the repository root:

```bash
./scripts/run_firebase.sh
```

For Chrome explicitly:

```bash
./scripts/run_firebase.sh chrome
```

## 9. Build and deploy

```bash
./scripts/deploy_firebase.sh
```

The script runs `flutter analyze`, all Flutter tests, a release web build, and then deploys Firestore Rules, indexes, and Hosting.
