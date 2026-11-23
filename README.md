<div align="center">
  <img src="frontend/assets/logos/career_bridge_selected_logo.png" alt="Career Bridge logo" width="190" />

  <h1>Career Bridge</h1>

  <p><strong>Discover opportunities. Connect talent. Build careers.</strong></p>
  <p>A Bangladesh-focused job discovery and hiring platform for job seekers, employers, and administrators.</p>

  <p>
    <a href="https://careerbridgebd.web.app">Live Website</a> ·
    <a href="https://github.com/mdjunayet10/Career-Bridge/releases">Releases</a> ·
    <a href="https://github.com/mdjunayet10/Career-Bridge/issues">Report an Issue</a>
  </p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-3.41.7-02569B?logo=flutter&logoColor=white" alt="Flutter 3.41.7" />
    <img src="https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black" alt="Firebase" />
    <img src="https://img.shields.io/badge/Release-v1.7.5%2B33-2ea44f" alt="Version 1.7.5 build 33" />
  </p>

  <a href="https://github.com/mdjunayet10/Career-Bridge/actions/workflows/build-careerbridge-apks.yml">
    <img src="https://github.com/mdjunayet10/Career-Bridge/actions/workflows/build-careerbridge-apks.yml/badge.svg" alt="GitHub Actions validation status" />
  </a>
</div>

---

## Overview

**Career Bridge** brings job browsing, employer recruitment, and administration together in one responsive Flutter application. It supports **web and Android**, with iOS project scaffolding included.

You can explore the interface in **Demo Mode** without a Firebase project, or configure **Firebase Mode** for authentication, Firestore-backed data, and role-protected workflows.

## What you can do

| Job Seekers | Employers | Administrators |
| --- | --- | --- |
| Browse and search jobs and companies | Create and manage job listings | Review and publish pending jobs |
| See all jobs or recommended opportunities | Review applicants and applications | Verify employers and manage users |
| Build a CV and manage a profile | Shortlist, schedule interviews, and select candidates | Moderate companies, reports, and categories |
| Save jobs and track applications | Update company profiles and review notifications | Manage platform settings and salary insights |

Additional highlights:

- **Live updates:** Firestore listeners refresh connected jobs, applications, and management screens without a restart.
- **Job discovery:** Filters, company pages, salary insights, and a dedicated **All Jobs** view.
- **Application workflow:** Employer decisions and candidate notifications are coordinated; pending jobs are not publicly listed until approved.
- **Demo experience:** Fictional accounts, sample jobs, and interactive applications stay in a local demo session—no writes to production Firestore.
- **Role-aware access:** Firebase Authentication, Firestore rules, and navigation guards protect sensitive areas. The Admin entry point is <code>/admin/login</code>.

## Latest source version

**v1.7.5+33**

- Live Firestore updates across public, seeker, employer, and admin views.
- Shortlist, interview scheduling, candidate selection, and rejection actions.
- Improved All Jobs navigation and recommendation choice.
- More usable sample application flows with local-only demo changes.
- Responsive Admin workflows and reporting improvements.

> This is the **source version**. A GitHub Release APK is only available when an APK has actually been attached under [Releases](https://github.com/mdjunayet10/Career-Bridge/releases).

## Built with

| Layer | Technology |
| --- | --- |
| App and web UI | Flutter, Dart |
| Authentication | Firebase Authentication, Google Sign-In |
| Data and authorization | Cloud Firestore, Firestore Security Rules |
| Hosting | Firebase Hosting |
| Notifications | Flutter local notifications and Firebase Messaging integration; optional Firebase Functions code |
| Automated validation | GitHub Actions, Flutter analyzer and tests, backend Node.js tests |

## Project structure

~~~text
Career-Bridge/
├── frontend/
│   ├── lib/               # Flutter features, state, routing, and UI
│   ├── assets/            # Brand images, fonts, company assets
│   ├── config/            # Demo and Firebase example settings
│   ├── android/           # Android project and user/admin flavors
│   ├── ios/               # iOS project scaffolding
│   ├── test/              # Flutter test suites
│   └── pubspec.yaml
├── backend/
│   ├── firebase/          # Firestore rules, indexes, hosting config
│   ├── firestore/         # Seed data and related resources
│   ├── functions/         # Optional notification functions and tests
│   └── tests/             # Firestore rules tests
├── scripts/               # Run, verify, build, and deployment helpers
├── .github/workflows/     # CI validation and optional APK artifacts
└── README.md
~~~

## Getting started

**Prerequisites:** Flutter **3.41.7**, a working Flutter environment (<code>flutter doctor</code>), and Chrome or another supported Flutter target. Android builds additionally need Java and the Android SDK.

### 1. Clone the project

~~~bash
git clone https://github.com/mdjunayet10/Career-Bridge.git
cd Career-Bridge
~~~

### 2. Run Demo Mode (no Firebase required)

~~~bash
bash scripts/run_demo.sh
~~~

Or start Flutter directly:

~~~bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define-from-file=config/demo.json
~~~

Demo accounts can be selected through the in-app demo interface. Demo data is for exploration, not production use.

### 3. Configure Firebase Mode (optional)

From the repository root:

~~~bash
cp frontend/config/firebase.example.json frontend/config/firebase.local.json
~~~

Edit <code>frontend/config/firebase.local.json</code> and replace every placeholder with the correct client-app values from **Firebase Console → Project settings**. Enable the authentication methods and configure Firestore access for your project.

~~~bash
bash scripts/run_firebase.sh
~~~

**Never commit** your local configuration, service-account files, signing keys, or passwords. The repository's <code>.gitignore</code> excludes local and sensitive files.

## Validation and builds

Run the project's full demo verification (Flutter analysis, tests, and web build):

~~~bash
bash scripts/verify_release.sh demo
~~~

Run the backend functions tests separately:

~~~bash
cd backend/functions
npm ci
npm test
~~~

To build a Firebase-configured website or Android User/Admin APKs, first complete the Firebase configuration above:

~~~bash
bash scripts/build_web.sh firebase
bash scripts/build_android_apps.sh release
~~~

The Android build script generates User and Admin APKs in <code>output/apk/</code>. The Admin flavor uses a separate application ID and still requires an authorized Admin account.

**GitHub Actions:** The workflow runs Flutter analysis and selected tests. APK creation is **skipped** when the repository secret <code>CAREER_BRIDGE_FIREBASE_CONFIG_JSON</code> is absent. A successful validation run does not necessarily mean an APK was built.

## Deployment and security notes

- Review your Firebase project settings and Firestore rules before deployment. The included scripts target the existing Career Bridge Firebase project; do not deploy them to another project without checking the configuration.
- Pending, draft, and closed jobs must not appear in public job results.
- Installing the Admin APK does **not** grant an Admin role.
- Firebase Functions notification code is present, but production function deployment and end-to-end push delivery have **not** been confirmed.
- The Android Gradle configuration currently uses **debug signing for release builds**. Configure a private production signing key before distributing an APK as a trusted public release or publishing to an app store.

---

<div align="center">
  <strong>Career Bridge — connecting ambition with opportunity.</strong><br />
  Made for job seekers and employers in Bangladesh.
</div>
