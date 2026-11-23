# Career Bridge 1.5.0

## Smart Career Experience Update

Career Bridge 1.5.0 focuses on the supervisor feedback around job discovery, automatic CV creation, personalized recommendations, and notifications.

### 1. Improved job search and filters
- Replaced the location dropdown with one-click location chips below the search bar.
- Locations include All locations, Dhaka, Chattogram, Sylhet, Rajshahi, Khulna, Barishal, Rangpur, Mymensingh, Gazipur, and Remote.
- The same location experience is available on the landing-page search and the full Jobs page.
- Existing Category, Job Type, and Work Style filters remain available.
- Added an Experience filter for more precise job discovery.
- Search still supports job title, skill, company, category, and location text.
- Recommended sorting now becomes personalized for signed-in Job Seekers.

### 2. Automatic CV generation from Career Profile
- Saving the Job Seeker Career Profile now automatically creates/updates the Career Bridge CV.
- Synced fields: full name, email, phone, location, professional summary, skills, and education summary.
- Existing manually edited CV experience, projects, languages, template, and custom education are preserved.
- Existing users with profile data but a blank CV are automatically migrated when their workspace loads.
- CV Builder clearly shows that Profile Sync is active.

### 3. CV-based job recommendation engine
- Added a reusable recommendation service instead of showing hardcoded first jobs.
- Jobs are scored using CV/profile signals including skills, professional summary, preferred roles, preferred locations, work mode, education/experience/project text, and job requirements.
- Job Seeker dashboard now ranks the strongest matches first.
- Recommended job cards show a CV match percentage and short match reasons.
- Jobs page Recommended sorting also uses the personalized score when a Job Seeker is signed in.

### 4. Smart notifications
- Existing application and interview notifications remain intact.
- After a profile/CV update, Career Bridge can create a smart notification for the strongest job match.
- If no useful match is available, the user receives a one-time CV auto-generation confirmation instead.
- Recommendation notifications link directly to the matching job.
- Notification UI now includes a dedicated recommendation icon/color and updated copy.
- Demo data includes a visible recommendation notification for presentation.

### Firebase/security update
- Firestore rules allow a Job Seeker to create only self-addressed `recommendation` or `profile` notifications.
- Employer-created application/interview notification permissions remain unchanged.

### Validation
- Added unit tests for Profile-to-CV sync behavior and recommendation ranking.
- `scripts/check_project.py` remains the fast no-Flutter integrity check.
- Full release verification still runs `dart format`, `flutter analyze`, `flutter test`, and the web build on a machine with Flutter installed.

### Landing alignment correction
- The three landing sections shown in the supervisor screenshots now keep their content/cards aligned to the left edge of the shared content grid instead of drifting toward the center when only a few live items are available.
- Updated sections: Explore Career Paths, Recommended Opportunities, and Trusted Employers.
- No Admin authentication, Admin route, or Admin dashboard source files were changed in this update; the clean working Admin flow from the supplied baseline is preserved.

### Location filter layout refinement
- Location chips now wrap onto multiple lines instead of using horizontal scrolling.
- All location options remain visible at once on desktop and mobile.
- Compact spacing is used on narrower layouts to keep the filter tidy.
