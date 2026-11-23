# Final stabilization

Career Bridge V2 release candidate: `1.0.0+10`.

## Stabilization changes

- Removed unused local imports that would be reported by the Dart analyzer.
- Added authenticated-session ownership to the in-memory file cache. When the active UID changes, cached private bytes and the repository instance are reset before any new file operation.
- Updated Firestore Security Rules so only active application stages can transition to `withdrawn`. Terminal `hired` and `rejected` records cannot be rewritten by the Job Seeker.
- Added a Firestore Rules regression test for active versus terminal withdrawal.
- Added a one-command local release verifier with timestamped logs.

## Run on the development Mac

```bash
./scripts/verify_release.sh demo
```

This is the first authoritative Flutter execution because the implementation environment does not contain Flutter. After it passes, run the app for visual review:

```bash
./scripts/run_demo.sh
```

Review 1440×900, 1024×768, 390×844, and 360×800 before Firebase configuration and deployment.


## 1.0.1 web-run hotfix

- Fixed the invalid const expression in the public landing-page hero.
- `scripts/run_demo.sh` now detects Chrome automatically and falls back to Flutter web-server on systems without Google Chrome.
- The fallback serves the app at `http://127.0.0.1:7357` and attempts to open the default browser on macOS.

## 1.1.0 UI polish batch 1

- Removed Career Resources from the public navigation, landing page, routes, and footer.
- Replaced typed location search with an All locations/division/Remote selector on both the landing page and Jobs page.
- Rebuilt the Jobs sort control as a fixed-height popup menu to remove the 3.2-pixel overflow indicator.
- Added 12 local demo company logo marks and a reusable logo widget with Firebase-uploaded-logo support and an initial fallback.
- Applied company logos to job cards, company cards, job details, company details, landing preview cards, and Job Seeker application surfaces.
- Added a brighter, tightly cropped Career Bridge wordmark for navigation, authentication, dashboards, and footer use.


## 1.2.0 UI polish batch 2

- Removed all text and initials from bundled company logo artwork; missing assets now use a generic business glyph.
- Redesigned Companies cards, search controls, result header, and responsive grid.
- Reduced Company Details header height and balanced identity, overview, and open-role content.
- Rebuilt the authentication shell for stronger logo contrast and safe scrolling on shorter laptop displays.
- Redesigned role selection and reorganized Job Seeker and Employer registration forms into responsive sections.
