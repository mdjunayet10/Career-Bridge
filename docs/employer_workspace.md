# Employer workspace

Milestone 5 replaces the Employer dashboard placeholder with a complete recruitment workspace.

## Protected routes

```text
/employer/dashboard
/employer/jobs/new
/employer/jobs
/employer/jobs/{jobId}/edit
/employer/applicants
/employer/applicants/{applicationId}
/employer/interviews
/employer/company
/employer/notifications
```

Every route requires:

1. an authenticated user,
2. `role == employer`,
3. `verificationStatus == approved`, and
4. an active account.

Pending or rejected employers remain in `/employer/verification-pending`.

## Job lifecycle

```text
Draft → Pending Review → Published
                    ↘ Needs Changes
Published → Closed
```

Employers can save drafts, submit jobs for review, resubmit changed jobs, review job-specific applicant counts, and close published recruitment. Only an Admin can change a job from pending to published/rejected.

## Candidate privacy model

A job application stores a limited candidate snapshot at submission time:

- name
- email
- headline
- location
- experience years
- skills
- CV reference
- cover letter

The Employer reads this snapshot only through an application belonging to a job they own. Company trade-license evidence is separately stored in private `companyVerifications/{companyId}` documents, never in publicly readable company profiles. Employers do not receive unrestricted read access to `users/{uid}`, `jobSeekerProfiles/{uid}`, or `cvProfiles/{uid}`.

## Recruitment pipeline

```text
Applied → Under Review → Shortlisted → Interview → Hired / Not Selected
```

When an Employer updates a candidate stage, the repository updates the application and creates an application-linked notification for the Job Seeker in one Firestore batch.

## Demo workspace

Use the approved Employer demo account:

```text
Email: employer@careerbridge.demo
Password: Demo123!
```

The demo includes approved company data, live/pending/draft/closed jobs, realistic candidates, interviews, notifications, and recruitment metrics.
