# Firestore Security Rules tests

These emulator tests cover the highest-risk authorization boundaries:

- public published-job access
- blocked public Admin creation
- private Job Seeker profiles
- Employer verification self-approval prevention
- Admin platform access

Requirements:

- Node.js 20+
- Java 11+

Run:

```bash
cd backend/tests/firestore_rules
npm install
npm test
```

The tests use the local Firestore Emulator only. They do not contact production Firebase and do not require billing.
