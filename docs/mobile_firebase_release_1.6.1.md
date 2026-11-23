# Career Bridge 1.6.1+27

Production web and Android retain real Firebase authentication and expose the original demo-account credential panels. Using a seeded demo account switches authentication, listings, workspaces, and file storage to sample repositories for that session. Sign-out restores Firebase authentication and reloads live listings. Invalid demo credentials and mismatched roles cannot switch the repository. Automatic Firebase-to-demo fallback remains disabled.

Demo sessions display a sample-data banner. Restarting the production app restores its normal Firebase mode. No real account or Firebase administrator privilege is granted by the demo administrator portal.

Android launcher icons use the existing Career Bridge website logo in all five launcher densities. Version code 27 supports updating the preceding version 26 APK with the existing signing certificate.

Validation: two repository-switching unit tests and three authentication layout tests passed at 320, 360, and 390 logical pixels. Google account authentication limitations from release 1.6.0 still apply.

Live Safari verification: the job seeker demo panel filled credentials; sign-in opened the sample dashboard with the demo banner. The distributed APK launcher image was extracted and its decoded pixels matched the Career Bridge source logo. No Android device was connected for this update, so this APK version was build-verified but not installed on a device.
