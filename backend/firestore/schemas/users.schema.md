# users/{uid}

```json
{
  "name": "User name",
  "email": "user@example.com",
  "role": "jobSeeker | employer | admin",
  "isActive": true,
  "companyName": null,
  "verificationStatus": "notRequired | pending | approved | rejected",
  "avatarFileId": null,
  "phone": null,
  "location": null,
  "headline": null,
  "createdAt": "server timestamp",
  "updatedAt": "server timestamp"
}
```

Rules:

- Public registration may create only `jobSeeker` or `employer`.
- Job Seekers use `verificationStatus: "notRequired"`.
- Employers begin with `verificationStatus: "pending"`.
- Admin users are created manually in Firebase Authentication and Firestore.
- Admin approval should update the Employer user and company documents together.
