# University submission checklist

## Code and architecture

- [ ] `frontend/` and `backend/` are separate
- [ ] no Cloud Functions folder
- [ ] no Firebase Storage dependency
- [ ] selected runner + bridge + flag logo is used
- [ ] Job Seeker, Employer, and Admin role flows work
- [ ] Admin is absent from public navigation

## Quality

- [ ] `python3 scripts/check_project.py` passes
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Firestore Rules emulator tests pass
- [ ] desktop and mobile visual checks are complete
- [ ] web release build succeeds

## Firebase

- [ ] Email/Password Authentication enabled
- [ ] Firestore Rules deployed
- [ ] Firestore indexes deployed
- [ ] first Admin created manually
- [ ] Employer approval tested
- [ ] Job approval tested
- [ ] `firebase.local.json` is not committed

## Demonstration

- [ ] Job Seeker registration and job application
- [ ] CV Builder and PDF generation
- [ ] Employer registration and verification pending state
- [ ] Employer posting and applicant pipeline
- [ ] Admin verification and moderation
- [ ] responsive web demonstration
