# jobSeekerProfiles/{uid}

Private Job Seeker career profile. The document ID and `ownerUid` both match the Firebase Authentication UID.

```json
{
  "ownerUid": "Firebase Auth UID",
  "fullName": "Job Seeker name",
  "email": "account email",
  "headline": "Flutter Developer · CSE Student",
  "phone": "+880...",
  "location": "Dhaka, Bangladesh",
  "about": "professional summary",
  "educationSummary": "BSc in CSE · Ongoing",
  "experienceYears": 1,
  "skills": ["Flutter", "Dart", "Firebase"],
  "preferredRoles": ["Flutter Developer"],
  "preferredLocations": ["Dhaka", "Remote"],
  "workModes": ["Remote", "Hybrid"],
  "portfolioUrl": "https://...",
  "linkedInUrl": "https://...",
  "profileImageFileId": "optional fileObjects ID",
  "updatedAt": "timestamp"
}
```

Only the owner and Admin can read the document. Only the owner can create or edit their own profile; Security Rules prevent ownership changes.
