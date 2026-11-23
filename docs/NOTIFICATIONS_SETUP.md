# Job notifications: prepared source and deployment prerequisites

No production rules, Functions, hosting or data were deployed during this work.

The user APK registers an Android FCM token only for a real signed-in Job Seeker. Permission denial is non-blocking. Notification preferences live in `pushSubscriptions/{uid}` and private device documents below it. Token IDs use SHA-256, token refresh replaces the previous registration, and logout tries to delete registration before sign-out and invalidate the FCM token. An offline logout can delay server/provider cleanup; verify delivery isolation on real devices before production rollout.

The Admin APK uses a distinct package (`com.careerbridge.career_bridge.admin`), no job-notification subscriptions, and existing admin role enforcement. It currently uses explicit FirebaseOptions from the supplied project for email/password Firestore access. Register this separate Android package in Firebase and supply its own app ID/config before claiming complete native provider configuration. It does not offer Google admin registration. The user package retains the original Google services configuration; verify its signing SHA-1/SHA-256 in Firebase Console.

## Deployment after explicit authorization

1. Confirm the intended project is `career-bridge-dd01c` and review the existing security rules diff. Do not replace rules from an unrelated checkout. Confirm billing permits Functions and review expected messaging/Firestore costs.
2. Use Node.js 22 for the Functions runtime. From `backend/functions`, run `npm ci`, then `npm test`.
3. From `backend/firebase`, preview the rules diff and the functions configuration (`source: ../functions`). Deploy these resources only after the owner explicitly authorizes production deployment:

```sh
firebase deploy --project career-bridge-dd01c --only firestore:rules,functions:queuePublishedJob,functions:deliverPublishedJob
```

4. Verify FCM API, Functions service account access and Eventarc/Firestore trigger region match the actual project. Ensure `companies/{companyId}.ownerUid` equals `jobs/{jobId}.employerUid`, company and employer are active and approved, and only admins can move jobs to published.
5. On an isolated test Firebase project, test first permission grant/deny, opt-out, token refresh, logout/account switch, foreground, background and terminated notification taps. Publish only an explicitly designated test job in the isolated project. Never create production demo jobs for these tests.
6. Validate that a draft, pending, closed, inactive, sample, demo, unapproved company or inactive employer produces no push. Existing published-job edits do not enqueue a fresh announcement. A job is announced at most once via `pushOutbox/{jobId}`; republishing the same ID does not reannounce it.
7. Test preferred role and location matching. Empty preferences accept all eligible jobs; nonempty preferences use case-insensitive title/location matching, including Remote.
8. Monitor outbox delivery logs. Server delivery has per-device transactional leases and sent ledgers. FCM sending and Firestore acknowledgement cannot form one transaction: a crash after send can still yield a duplicate retry. Stable Android tags/collapse keys and foreground event deduplication reduce visible duplicates; exactly-once delivery is not claimed.
9. Plan retention for server-only `pushOutbox` and delivery documents. Do not enable TTL or scheduled cleanup on production without review.

## References

- https://firebase.google.com/docs/cloud-messaging/flutter/get-started
- https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages
- https://firebase.google.com/docs/functions/firestore-events
