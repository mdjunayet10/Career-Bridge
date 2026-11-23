# companyVerifications/{companyId}

Private verification evidence is separated from the publicly readable company profile.

```json
{
  "companyId": "company document ID",
  "ownerUid": "Employer Firebase Auth UID",
  "tradeLicenseNumber": "registered trade license or verification reference",
  "status": "pending | approved | rejected",
  "adminNote": "private review note",
  "submittedAt": "timestamp",
  "updatedAt": "timestamp"
}
```

The Employer can create and read their own verification record. Only an Admin can update or delete it after submission. Admin approval should update `companyVerifications`, `companies`, and the Employer `users` document in one batch.
