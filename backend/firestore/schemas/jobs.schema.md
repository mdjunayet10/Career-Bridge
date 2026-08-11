# jobs/{jobId}

```json
{
  "companyId": "company document ID",
  "employerUid": "Firebase Auth UID",
  "title": "Flutter Developer",
  "description": "Job description",
  "responsibilities": ["..."],
  "requirements": ["..."],
  "skills": ["Flutter", "Dart"],
  "categoryId": "Technology",
  "location": "Dhaka",
  "workMode": "On-site | Hybrid | Remote",
  "employmentType": "Full-time | Part-time | Internship | Contract",
  "experienceLevel": "2–3 years",
  "salaryMin": 45000,
  "salaryMax": 70000,
  "salaryPeriod": "month",
  "benefits": ["Festival bonus"],
  "deadline": "timestamp",
  "status": "draft | pending | published | rejected | closed",
  "isActive": true,
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "publishedAt": null,
  "rejectionNote": null
}
```

An approved Employer may create `draft` or `pending` jobs for their own approved company. Employer edits that require public changes return the job to `pending`; an Admin owns the publish/reject decision.

Jobs do not duplicate company logos. The UI resolves the company logo through `companyId -> companies/{companyId}.logoFileId`.
