# companies/{companyId}

The public company document contains only information that may be shown to Job Seekers. Sensitive verification evidence lives in `companyVerifications/{companyId}`.

```json
{
  "ownerUid": "Firebase Auth UID",
  "name": "Company name",
  "industry": "Software & Technology",
  "companySize": "51–200 employees",
  "contactName": "Hiring contact",
  "website": "https://example.com",
  "email": "hr@example.com",
  "phone": "+880...",
  "address": "Dhaka, Bangladesh",
  "description": "Company overview",
  "logoFileId": "optional fileObjects ID",
  "verificationStatus": "pending | approved | rejected | suspended",
  "isActive": true,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

`logoFileId` is the only logo reference in the data model. Jobs and applications store `companyId`; clients resolve the current logo from the company profile.
