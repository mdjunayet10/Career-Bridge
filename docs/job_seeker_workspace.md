# Job Seeker workspace

## Protected routes

```text
/job-seeker/dashboard
/job-seeker/saved
/job-seeker/applications
/job-seeker/applications/:applicationId
/job-seeker/cv-builder
/job-seeker/notifications
/job-seeker/profile
```

Every route requires an authenticated, active `jobSeeker` user. The public job list and job details page remain available to guests, but saving and applying persist only for Job Seeker accounts.

## Repository boundary

`JobSeekerWorkspaceController` reads and writes through `JobSeekerWorkspaceRepository`.

- Demo mode uses `DemoJobSeekerWorkspaceRepository` with seeded profile, saved jobs, applications, notifications, and structured CV data.
- Firebase mode uses `FirebaseJobSeekerWorkspaceRepository` and Firestore collections.

The presentation layer does not call Firestore directly.

## Application workflow

```text
Job details
→ Review structured CV
→ Add cover letter
→ Submit
→ Track Applied / Under review / Shortlisted / Interview / Hired or Rejected
→ Optional withdrawal while active
```

Duplicate active applications for the same job are blocked by the repository. Firestore Security Rules also require the target job to be active and published.

## CV foundation

The CV Builder stores structured fields in `cvProfiles/{uid}`:

- personal information
- technical languages, optional frameworks, and tools and platforms
- optional additional skills
- education
- projects
- experience
- achievements and certifications
- references
- profile photo and professional links

PDF export is already generated on-device from the structured CV data, including preview and share/download actions. No Firebase Storage is required.

Profile is the single editor for personal information, photo, education, skills, projects, experience, achievements, and references. Experience appears immediately after Projects by default. Projects, Experience, and Achievements accept one bullet point per line in their description fields. Saving Profile atomically updates both Profile and CV data; missing legacy experience preserves existing CV experience, while explicitly clearing it removes it.

CV Builder contains no duplicate information form. Edit Profile opens the source editor. CV layout controls show/hide sections, change their order, and show/hide the photo. Save layout persists only CV presentation preferences, preserving Profile data. Hidden sections remain stored for future use and job matching. Preferences survive Profile updates and reloads. Existing CV photo overrides remain stored for compatibility; replacing the Profile photo updates the CV thumbnail.

The default export retains the reference template: Education, Technical Skills, Projects, Experience, Achievements & Certifications, and References. Empty sections are omitted. One page is recommended, while longer CVs are supported. Section gaps follow the source's 10pt before / 4pt after spacing; education entries use a 5pt gap, and project/experience descriptions use a 2pt list gap.

CV Builder has a single, full-width PDF preview on desktop and mobile, with scrolling and 100–400% zoom. There is no separate Preview PDF button or duplicate preview dialog. CV layout opens the section/photo controls in a sheet; the same preview updates as settings change. Edit Profile remains the only information editor.

The preview renders the actual PDF export whenever its data or layout changes, with one render at a time and the newest pending input. Paper sits directly on the dashboard background without a gray surface or shadow. Preview and zoom do not print or download. Generate PDF is the only download action. PDF generation happens on-device and requires no Firebase Storage.
