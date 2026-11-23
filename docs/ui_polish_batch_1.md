# UI polish batch 1

Version: `1.1.0+12`

## Changes based on browser review

- The Jobs page no longer shows Flutter's `OVERFLOWED BY 3.2 PIXELS` indicator beside the Recommended sort control.
- The sort control now has a fixed 58-pixel height, reserved arrow space, ellipsis protection, and a popup menu.
- Location is selected from All locations, Dhaka, Chattogram, Sylhet, Rajshahi, Khulna, Barishal, Rangpur, Mymensingh, Gazipur, or Remote.
- The same location selector is used in the landing-page hero and full Jobs search page.
- Career Resources was removed because it was outside the core Job Seeker/Employer/Admin portal scope.
- Company initials were replaced by logo marks throughout the public portal and main Job Seeker application surfaces.
- Firebase company records can provide `logoFileId`; local demo companies use assets under `assets/company_logos/`.
- The main Career Bridge wordmark was cropped and brightened for better contrast in the dark navigation and authentication layouts.

## Verification

Run from the project root:

```bash
./scripts/verify_release.sh demo
./scripts/run_demo.sh
```

Review the Jobs page at desktop and mobile widths, then verify company logos on the landing page, Companies page, Job Details, and Company Details.