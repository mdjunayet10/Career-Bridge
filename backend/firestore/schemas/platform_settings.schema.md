# platformSettings/general

Public-safe operational defaults. The `general` document is publicly readable so the app can show maintenance and registration state; only Admins can write it.

```json
{
  "platformName": "Career Bridge",
  "supportEmail": "support@careerbridge.edu",
  "employerReviewRequired": true,
  "jobReviewRequired": true,
  "maintenanceMode": false,
  "allowJobSeekerRegistration": true,
  "allowEmployerRegistration": true,
  "updatedAt": "timestamp"
}
```

These values control application behavior. Do not store API keys, private notes, or any secret in this document. Registration flags are also enforced by Firestore Security Rules; UI visibility is not the security boundary.
