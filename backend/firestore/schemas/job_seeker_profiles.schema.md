# jobSeekerProfiles/{uid}

Private Job Seeker career profile. The document ID and `ownerUid` both match the Firebase Authentication UID.

```json
{
  "ownerUid": "Firebase Auth UID",
  "fullName": "Job Seeker name",
  "email": "account email",
  "headline": "Professional headline",
  "phone": "+880...",
  "location": "Dhaka, Bangladesh",
  "about": "professional summary",
  "educationSummary": "Legacy education summary",
  "experienceYears": 1,
  "skills": ["Research", "Communication"],
  "hasCvDetails": true,
  "education": [],
  "projects": [],
  "experience": [],
  "hasCvExperience": true,
  "achievements": [],
  "references": [],
  "technicalLanguages": [],
  "frameworks": [],
  "toolsAndPlatforms": [],
  "preferredRoles": ["Research Assistant"],
  "preferredLocations": ["Dhaka", "Remote"],
  "workModes": ["Remote", "Hybrid"],
  "portfolioUrl": "https://...",
  "linkedInUrl": "https://...",
  "profileImageFileId": "optional fileObjects ID",
  "updatedAt": "timestamp"
}
```

Only the owner and Admin can read the document. Only the owner can create or edit their own profile; Security Rules prevent ownership changes.

Structured education, projects, experience, achievements, and references use the item shapes in `cv_profiles.schema.md`. `hasCvDetails` distinguishes legacy profiles from intentional clears of optional fields. `hasCvExperience` separately tracks experience edits because older structured profiles did not collect that section. Missing experience data preserves an existing CV's experience; a saved empty list explicitly removes it.

Saving profile details generates or updates the CV automatically. Profile and CV edits persist together in one Firestore batch, including reverse sync from the CV Builder. Frameworks and experience are optional; no institution or academic background is required by the CV template. Description text in projects, experience, and achievements uses one bullet point per line.
