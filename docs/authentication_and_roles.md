# Authentication and roles

## Public registration

Only two roles can be created from the app:

```text
Job Seeker
Employer
```

The Firestore `users/{uid}` create rule rejects `role: "admin"` from public clients.

## Admin provisioning

The first Admin is created manually:

1. Create an Email/Password user in Firebase Authentication.
2. Copy the UID.
3. Create `users/{uid}` in Firestore.
4. Set at minimum:

```json
{
  "name": "Career Bridge Admin",
  "email": "admin@careerbridge.com",
  "role": "admin",
  "isActive": true,
  "verificationStatus": "notRequired"
}
```

5. Open `/admin/login` directly.

## Role routing

```text
jobSeeker → /job-seeker/dashboard
employer + pending/rejected → /employer/verification-pending
employer + approved → /employer/dashboard
admin → /admin/dashboard
```

## Employer registration

The Firebase repository writes `users/{uid}`, `companies/{uid}`, and private `companyVerifications/{uid}` documents in one atomic batch. Security Rules use `getAfter()` to validate the new Employer role in the post-write state.

New companies begin with:

```text
verificationStatus: pending
```

The Admin must update the private verification document, the public company document, and its owning user to `approved` in one batch when verification succeeds.

## Demo credentials

```text
Job Seeker
jobseeker@careerbridge.demo
Demo123!

Approved Employer
employer@careerbridge.demo
Demo123!

Pending Employer
pending@careerbridge.demo
Demo123!

Admin
admin@careerbridge.demo
Admin123!
```

These exist only in memory and are not production accounts.

## Protected Admin routes

```text
/admin/dashboard
/admin/employers
/admin/jobs
/admin/users
/admin/companies
/admin/reports
/admin/categories
/admin/salary-insights
/admin/settings
```

None of these routes appear in public navigation. Each route uses the Admin role guard, and every underlying Firestore operation is authorized again by Security Rules.
