# Mobile completion and separate Admin APK Implementation Plan

**Goal:** Complete the supplied mobile fixes, build separate user/admin Android applications, prepare a concise one-page personal CV, and report actual verification.
**Architecture:** Retain the existing Flutter/Firebase repositories and dark design. Use Android product flavors with a compile-time admin-only route gate. Keep production resources unchanged except an account profile update only through a verified owner session and explicitly supplied CV facts.
**Tech Stack:** Flutter, Firebase Auth/Firestore/FCM, local notifications, Node Firebase Functions, existing PDF renderer.
**Spec:** User supplied complete remaining work request plus separate admin app and one-page personal CV request.

## Global Constraints
- Keep original source ZIP and initial Git backup.
- No hosting, functions, rules deployment or production demo seeds.
- Preserve role checks; separate admin package does not grant administrator privileges.
- Retain multipage support for general users; shorten this user's content for one-page output.
- Separate personal supplied facts from fictional sample data.

## Review Focus
- Cold-start and duplicate notification taps; queue until navigation ready.
- Permission denial/offline errors must not block authentication.
- Logout/token refresh/opt-out must prevent continued account subscriptions.
- Admin APK rejects non-admin sessions and public routes.
- Long CV content paginates; short personal CV remains one page.

### Task 1: Baseline and mobile fixes
- [ ] Preserve backup, install dependencies, run existing analyzer/tests.
- [ ] Compare patch files against baseline; integrate compatible logo/footer/navigation/demo changes.
- [ ] Test reduced-motion startup, Android Back and narrow forms/navigation.

### Task 2: Separate admin application
- [ ] Add testable application mode and route policy, admin authentication tests.
- [ ] Add Android user/admin product flavors and names; preserve registered application configuration.
- [ ] Verify independent package identity and admin-only route handling.

### Task 3: Push notifications
- [ ] Add authenticated token lifecycle with persisted preferences, refresh/logout cleanup, safe routing and foreground deduplication.
- [ ] Add opt-out control on notification page.
- [ ] Prepare scoped Firestore rules and approved-job backend with targeted subscriptions and idempotent dispatch.
- [ ] Run backend eligibility and routing tests; document deployment prerequisites.

### Task 4: Personal CV and profile
- [ ] Extract supplied PDF facts and links, select concise supported content.
- [ ] Generate a one-page PDF with existing renderer, verify page count and inspect rendering.
- [ ] Add account-owned, explicit profile import for exact email; preview data before saving and preserve unknown fields.
- [ ] Verify all available templates and multipage/profile-sync tests.

### Task 5: Final verification and artifacts
- [ ] Format Dart, analyze, run tests, backend tests, debug and release builds for both flavors.
- [ ] Check Android device/emulator availability; test possible mobile UI flows.
- [ ] Build web to check compatibility without deploying.
- [ ] Deliver APKs, CV PDF, source/changelog and issue-status evidence table with remaining blockers.
