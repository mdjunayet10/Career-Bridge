# Hosting deployment 1.7.2+30

The authorized website update was deployed on 2026-11-01 to https://careerbridgebd.web.app in project career-bridge-dd01c. The deployment selected only Hosting with firebase.hosting.local.json; Functions and Firestore rules were not deployed.

A post-deployment fetch verified HTTP 200 and exact SHA-256 equality with the final local release for release.json, index.html, main.dart.js and flutter_bootstrap.js. The main application bundle SHA-256 is 119092dd9e2225a52c0c8ece233ee9052ab81b3cee40142e9655a714000d8dbc.

A fresh isolated 390×844 live-browser session selected the fictional NovaTech Employer through the demo picker, enumerated all 12 Employer options, signed in, visited all mobile destinations and More, and inspected Company profile. The original orbital logo rendered in both Company logo and Public preview, with HTTP 200 for its bundled asset and no obsolete demo-prefixed request. No real-auth requests, current-user/profile/job save actions, uncaught browser errors or console errors occurred in this smoke check.

Earlier local browser checks covered 10 fictional sign-in/navigation cases across 320×844 and 390×844, all 20 Seeker and 12 Employer picker entries, the absence of Admin demo controls, meaningful completion percentages and missing-field text. Fresh final-build checks also verified the 320px role labels and corrected logo.

Outer audit artifacts retain the deploy log, live hash verification, browser JSON reports and screenshots. Physical-device behavior is separate from these browser checks.
