# applications/{applicationId}

```json
{
  "jobId": "job document ID",
  "applicantUid": "Firebase Auth UID",
  "applicantName": "Candidate name snapshot",
  "applicantEmail": "Candidate email snapshot",
  "applicantHeadline": "Career headline snapshot",
  "applicantLocation": "Location snapshot",
  "applicantExperienceYears": 2,
  "applicantSkills": ["Flutter", "Dart"],
  "jobTitle": "Job title snapshot",
  "companyName": "Company name snapshot",
  "companyId": "novatech-bangladesh",
  "jobLocation": "Dhaka",
  "jobEmploymentType": "Full-time",
  "jobSalaryLabel": "৳45k–70k / month",
  "cvProfileId": "optional structured CV profile ID",
  "cvFileId": "optional immutable PDF snapshot in fileObjects",
  "coverLetter": "application-specific text",
  "status": "applied | reviewed | shortlisted | interview | hired | rejected | withdrawn",
  "employerNote": null,
  "interviewAt": null,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

Candidate and job snapshots are captured at submission time. The job snapshot keeps application history readable even after the original public listing is closed or suspended. This lets an Employer review applicants for jobs they own without receiving broad access to private user or Job Seeker profile documents.


When a Job Seeker applies with a structured CV, the device generates a PDF, validates the 2 MB limit, uploads the PDF in Firestore chunks, and stores its `fileObjects` ID in `cvFileId`. The file metadata is linked to this application so only the applicant, Admin, and the Employer who owns the job can reconstruct it.

Applications keep `companyId` for historical logo resolution but never store a copied logo reference.
