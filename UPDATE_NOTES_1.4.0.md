# Career Bridge 1.4.0

## Included

- Firebase Google Sign-In for the web login page.
- Role-aware Google authentication for Job Seekers and Employers.
- Automatic first-time Job Seeker profile creation in Firestore.
- First-time Employer Google flow that pre-fills verified identity details and completes company verification registration.
- Existing users are routed from their Firestore role; public Google sign-in cannot create Admin access.
- Google popup, cancellation, provider, domain, network, and role-mismatch error handling.
- Firebase deploy script now builds, copies `frontend/build/web` into `backend/firebase/public`, and deploys the existing `careerbridgebd` Hosting target.
- Firebase run script now falls back to `web-server` when Chrome is absent.

## Run

```bash
cd ~/Downloads/Career-Bridge
chmod +x scripts/*.sh
./scripts/run_firebase.sh
```

When web-server starts, open the printed local URL in Safari.

## Deploy

```bash
cd ~/Downloads/Career-Bridge
./scripts/deploy_firebase.sh
```

The configured Hosting target is `https://careerbridgebd.web.app`.

## Scope

Google Sign-In in this release is implemented for Flutter Web. Native Android/iOS Google Sign-In requires the mobile plugin flow in a later mobile release.
