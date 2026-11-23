# cvProfiles/{uid}

Structured CV data is stored rather than the generated PDF.

```json
{
  "ownerUid": "Firebase Auth UID",
  "personal": {
    "fullName": "Name",
    "email": "email@example.com",
    "phone": "+880...",
    "location": "Dhaka",
    "summary": "Professional summary",
    "photoDataUrl": "optional small JPEG thumbnail",
    "linkedInUrl": "optional LinkedIn URL",
    "portfolioUrl": "optional portfolio or website URL"
  },
  "education": [{"degree": "Qualification", "institution": "Institution", "period": "Dates", "location": "", "result": "", "details": ""}],
  "experience": [{"role": "Position", "company": "Organization", "period": "Dates", "description": "First bullet\nSecond bullet"}],
  "projects": [],
  "skills": [],
  "languages": [],
  "technicalLanguages": [],
  "frameworks": [],
  "toolsAndPlatforms": [],
  "achievements": [{"title": "Award or certificate", "qualifier": "Issuer", "date": "", "description": ""}],
  "references": [{"name": "Referee", "designation": "", "organization": "", "email": "", "phone": ""}],
  "templateId": "reference-classic",
  "updatedAt": "server timestamp"
}
```

The Flutter client generates the PDF on-device.

The profile and CV editors share Education, Technical Skills, Projects, Experience, Achievements & Certifications, and References. Experience follows Projects and uses the same entry style. Projects, Experience, and Achievements descriptions use one bullet per nonblank line. Existing bullet prefixes are normalized for display without changing stored text.

The A4 export uses the reference template's Latin Modern Roman fonts from the supplied main.tex, optical bold and italic styles, ruled section headings, two-row education entries, aligned skill categories, right-aligned project tools/methods and dates, two-column references, blue links, margins, photo placement, and italic footer. Frameworks are optional and omitted when empty. One page is recommended; longer content continues automatically. Blank sections are omitted. Stored professional summaries and spoken languages remain available for compatibility but are outside this reference layout. Profile About remains available for job matching.

Profile saves synchronize these fields into the CV; CV saves mirror shared fields back into the profile. Existing custom CV sections survive migration from profiles without structured CV fields. No batch, student ID, co-curricular section, or project-status field is defined.

Education entries optionally store `institutionUrl`; projects optionally store `toolsAndMethods`. Both fields persist through profile/CV sync. Missing values in older documents default to empty strings. The supplied profile placeholder fills the photo slot when no valid photo is available.
