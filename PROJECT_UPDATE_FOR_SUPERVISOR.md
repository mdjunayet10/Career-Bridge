# Career Bridge — Project Update for Supervisor

## Latest improvements

1. **Improved job filtering**
   - Search by job title, skill, or company.
   - One-click location chips for Dhaka, Chattogram, Sylhet, Khulna, Rajshahi, Barishal, Rangpur, Mymensingh, Gazipur, Remote, etc.
   - Category, job type, work style, and experience filters remain available.

2. **Automatic CV generation**
   - When a Job Seeker saves their Career Profile, Career Bridge automatically creates/updates their CV.
   - Existing custom CV projects, experience, languages, and template choices are preserved.

3. **CV/Profile-based job recommendations**
   - Jobs are ranked using skills, preferred role, location, work mode, CV summary, and job requirements.
   - The Job Seeker Workspace shows the strongest matching opportunities first.

4. **Job notifications**
   - New relevant job matches can appear in Job Seeker Notifications.
   - The notification does not expose an unnecessary match percentage.
   - Application, shortlist, and interview notifications remain available.

5. **Automatic Salary Insights**
   - Salary Insights are no longer entered manually by Admin.
   - The system calculates salary ranges from active published job posts.
   - It calculates minimum, median, average, maximum, and number of listings used.
   - Insufficient data is clearly shown instead of presenting a misleading figure.

6. **Data consistency / UI cleanup**
   - Removed fake landing Career Dashboard statistics.
   - Removed fake Employer recruitment statistics and candidate pipeline.
   - Removed the Companies hero statistics box.
   - Real Firebase jobs/companies remain the source of truth for public counts.
   - Sample jobs are used only to complete the landing showcase when needed, are clearly labelled `SAMPLE`, and are not counted as live jobs.
   - Main landing content remains left-aligned and location filters no longer require horizontal scrolling.

## Demo explanation

Career Bridge can now demonstrate both real-data behavior and a polished landing page without mixing sample numbers into live platform statistics. Real jobs drive search, recommendations, counts, applications, and Salary Insights. Sample job cards, when required for presentation, are clearly separated from live data.
