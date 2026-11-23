# Google Sign-In update

Version 1.4.0 adds Firebase Google Sign-In for the Flutter web app.

- Job Seeker: a first Google sign-in creates `users/{uid}` with the Job Seeker role.
- Employer: a first Google sign-in opens the company-registration form with the verified Google name and email prefilled; completing it creates the user, company, and verification documents atomically.
- Existing users are routed by the role already stored in Firestore.
- Public Google sign-in never creates an Admin profile.
- Android and iOS native Google Sign-In still require a separate mobile plugin flow; this update is web-only.
