# Career Bridge 1.4.3

- Google sign-in is always visible on Job Seeker registration, Employer registration, and Sign in.
- Job Seeker Google sign-in is placed above the email registration fields.
- Employer Google sign-in begins identity verification and then continues to company setup.
- Firebase deployment no longer stops because of stale widget snapshot tests; release build errors still stop deployment.
- Firebase project files and the existing `careerbridgebd` Hosting target are preserved.
- Hosting cache headers now force the browser to fetch the newest Flutter bundle after every deployment.
- Deployment verifies that `main.dart.js` actually contains the Job Seeker Google button before publishing.
