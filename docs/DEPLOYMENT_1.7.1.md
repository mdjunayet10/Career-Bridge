# Website deployment 1.7.1+29

Date: 2026-11-01, Asia/Dhaka. The user explicitly authorized updating the website only.

- Site: https://careerbridgebd.web.app
- Firebase project: `career-bridge-dd01c`
- Configuration: `firebase.hosting.local.json`, public directory `frontend/build/web`, existing site `careerbridgebd`.
- Command: `firebase deploy --project career-bridge-dd01c --config firebase.hosting.local.json --only hosting --non-interactive`.
- Result: hosting release complete, 70files; no Functions or Firestore rules deployment.
- Live verification: release marker 1.7.1+29, index, JavaScript and bootstrap all HTTP 200 and byte-for-byte equal to the verified local artifacts. Main JS SHA-256: `e3b5460b446425ac55427d20e0310e4f1cdb715b8bb611ab2faf2b2ad6359ccb`.
- Existing prior Hosting release metadata was privately saved before publishing.

## Demo company completeness audit

A fresh read-only audit used actual `DemoAuthRepository.signIn` and `DemoEmployerWorkspaceRepository.load`.

The approved demo account `employer@careerbridge.demo` (`Demo123!`) loads **NovaTech Bangladesh**, contact Nusrat Jahan, with **100% completeness (9/9 fields)**: name, industry, company size, website, email, phone, address, description and trade-license sample. No uploaded logo ID is set; the shared logo widget resolves the valid bundled NovaTech PNG. Workspace seeds include 5 jobs (2 published, 1 pending, 1 draft, 1 closed), 8 applications and 3 notifications.

The separate `pending@careerbridge.demo` account loads **Orbit Labs** at **22% (name/email only)** and remains pending in authentication. Its repository company object's verification field is hardcoded approved, a known sample inconsistency; the authenticated pending account still cannot enter the approved employer workspace. This audit did not modify it. Seeded job deadlines are historical sample dates in August/September 2026.

All demo profiles, companies, license/contact details, jobs and applications are fictional sample data. No production company/job documents were changed, no real application was submitted, and no verification was claimed for a real business.

## Remaining limitations

The Admin package registration and live provider/FCM end-to-end checks remain as documented in the previous release report. Hosting byte verification proves the intended build is served; browser interaction results, when available, are recorded separately in local audit logs.

## Live browser smoke

An isolated headless Brave session at 390×844 loaded the deployed site and signed in only through the fictional employer demo. The dashboard displayed NovaTech Bangladesh, the sample-data notice, bundled logo, 100% completion, 2 live jobs and 8 applications. The screenshot visually confirms Company Profile as the fourth bottom item. Clicking that specific bottom entry was not verified because its accessibility selector was absent; no real account or cloud data was changed. Screenshot: local sibling `audit/live-1.7.1-employer-mobile.png`.
